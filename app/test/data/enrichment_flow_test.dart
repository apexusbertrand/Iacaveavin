import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/enrichment_queue.dart';
import 'package:iacaveavin/data/enrichment/validation_service.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/garde_rules.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:yaml/yaml.dart';

import '../fixture.dart';
import 'contract_test.dart' show readExample, validator;
import 'photo_test.dart' show sharpLabel;

class Flow {
  final f = Fixture();
  late Directory root;
  late PhotoService photos;
  late FakeGateway gateway;
  late EnrichmentQueue queue;
  late ValidationService validation;
  late ReferenceRepository reference;
  DateTime now = DateTime.utc(2026, 10, 21, 9);

  Future<void> setUp() async {
    await f.setUp();
    root = Directory.systemTemp.createTempSync('iacav-flow-');
    photos = PhotoService(f.db, appDir: () async => root, clock: () => now);
    gateway = FakeGateway(validator: validator(), readExample: readExample);
    queue = EnrichmentQueue(
      f.db,
      gateway: gateway,
      photos: photos,
      clock: () => now,
    );
    reference = ReferenceRepository(f.db, clock: () => now);
    final yaml = loadYaml(
      File('assets/regles/regles-garde.yaml').readAsStringSync(),
    ) as YamlMap;
    validation = ValidationService(
      f.db,
      cellar: f.repo,
      reference: reference,
      rules: [
        for (final r in (yaml['regles'] as YamlList).cast<YamlMap>())
          GardeRule.fromJson(r),
      ],
      photos: photos,
      clock: () => now,
    );
  }

  Future<void> tearDown() async {
    await f.db.close();
    root.deleteSync(recursive: true);
  }

  /// AJO-03 : photos prises, fiche « à enrichir » et premier lot (AJO-04).
  Future<String> photographed() async {
    final wine = await validation.createPhotoWine(cellarId: f.cellar);
    await photos.save(
      wineId: wine,
      cellarId: f.cellar,
      photo: processPhoto(sharpLabel(w: 1200, h: 800)),
      type: 'etiquette',
    );
    await f.repo.addLot(
      wine,
      const LotDraft(ownerId: 'o1', quantity: 3, unitPrice: 21),
    );
    await queue.enqueue(wine);
    return wine;
  }

  Future<void> runToEnd() async {
    for (var i = 0; i < 5; i++) {
      await queue.process();
    }
  }
}

void main() {
  final w = Flow();
  setUp(w.setUp);
  tearDown(w.tearDown);

  test(
    'AJO-03 la fiche est enregistrée tout de suite « à enrichir »',
    () async {
      final wine = await w.photographed();
      final item = (await w.f.repo.wineItems()).firstWhere((x) => x.id == wine);
      expect(item.enrichmentStatus, 'a_enrichir');
      expect(item.bottles, 3);
      expect(await w.queue.pendingJobs(), hasLength(1));
    },
  );

  test(
    'AJO-09 hors ligne : le job attend, puis part au retour du réseau',
    () async {
      final wine = await w.photographed();
      w.gateway.online = false;
      final r1 = await w.queue.process();
      expect(r1.offline, isTrue);
      expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'a_enrichir');
      w.gateway.online = true;
      final r2 = await w.queue.process();
      expect(r2.sent, 1);
      expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'en_cours');
      await w.runToEnd();
      expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'a_valider');
      expect(await w.queue.pendingJobs(), isEmpty);
    },
  );

  test('AJO-09 sans réponse en 3 minutes : erreur, puis relance', () async {
    final wine = await w.photographed();
    w.gateway.scenario = FakeScenario.never;
    await w.queue.process();
    w.now = w.now.add(const Duration(minutes: 4));
    await w.queue.process();
    expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'erreur');
    expect((await w.queue.latestJobFor(wine))!.erreur, 'delai_depasse');
    w.gateway.scenario = FakeScenario.done;
    await w.queue.retry(wine);
    await w.runToEnd();
    expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'a_valider');
  });

  test(
    'AJO-12 réponse hors contrat : erreur journalisée, fiche éditable',
    () async {
      final wine = await w.photographed();
      w.gateway.scenario = FakeScenario.invalid;
      await w.queue.process();
      final job = (await w.queue.latestJobFor(wine))!;
      expect(job.statut, 'erreur');
      expect(job.erreur, startsWith('reponse_invalide'));
      expect((await w.f.repo.wine(wine))!.enrichmentStatus, 'erreur');
      expect(await w.queue.resultFor(wine), isNull, reason: 'rien enregistré');
    },
  );

  test(
    'PRV-R1 chaque valeur proposée crée une provenance « propose »',
    () async {
      final wine = await w.photographed();
      await w.runToEnd();
      final rows = await w.f.db.select(w.f.db.provenances).get();
      expect(rows.every((p) => p.statut == 'propose'), isTrue);
      final fields = rows.map((p) => p.champ).toSet();
      expect(
        fields,
        containsAll([
          'domaine',
          'appellation',
          'millesime',
          'commentaire_millesime',
        ]),
      );
      expect(
        fields,
        isNot(contains('cuvee')),
        reason: 'valeur nulle : rien à proposer',
      );
      final comment = rows.firstWhere(
        (p) => p.champ == 'commentaire_millesime',
      );
      expect(comment.url, 'https://exemple-interprofession.fr/millesime-2024');
      expect(wine, isNotEmpty);
    },
  );

  test(
    'AJO-06 AJO-08 tout accepter : fiche, listes, garde estimée, prix',
    () async {
      final wine = await w.photographed();
      await w.runToEnd();
      final response = (await w.queue.resultFor(wine))!;
      await w.validation.apply(wine, response);
      final d = (await w.f.repo.wine(wine))!;
      expect(d.draft.producer, "Guillaume L'Echanson");
      expect(d.draft.country, 'FR');
      expect(d.draft.region, 'fr-bourgogne');
      expect(
        d.label('appellation', d.draft.appellation),
        'Bourgogne Côte d\'Or',
      );
      expect(d.draft.vintage, '2024');
      expect(d.draft.grapes.single.code, 'pinot-noir');
      expect(d.draft.alcohol, 12);
      expect(d.enrichmentStatus, 'valide');
      // T6 : pas de fenêtre fournie, règle « rouge_bourgogne » appliquée.
      expect((d.draft.gardeStart, d.draft.gardeEnd), (2026, 2032));
      expect(d.gardeSource, 'estimation');
      expect(d.marketPrices.single.price, 24.5);
      expect(d.bottles, 3, reason: 'le lot saisi pendant l\'attente est gardé');
      final prov = await w.f.db.select(w.f.db.provenances).get();
      expect(prov.every((p) => p.statut == 'valide'), isTrue);
    },
  );

  test('PRV-R2 un champ corrigé devient manuel et verrouillé', () async {
    final wine = await w.photographed();
    await w.runToEnd();
    await w.validation.apply(
      wine,
      (await w.queue.resultFor(wine))!,
      decisions: const {
        'degre': FieldDecision.modify(13.5),
        'accords': FieldDecision.reject(),
      },
    );
    var d = (await w.f.repo.wine(wine))!;
    expect(d.draft.alcohol, 13.5);
    expect(d.draft.pairings, isEmpty);
    expect(await w.queue.lockedFields(wine), contains('degre'));
    // Ré-enrichissement : le degré saisi n'est jamais écrasé (règle 3).
    await w.queue.retry(wine);
    await w.runToEnd();
    await w.validation.apply(wine, (await w.queue.resultFor(wine))!);
    d = (await w.f.repo.wine(wine))!;
    expect(d.draft.alcohol, 13.5);
  });

  test('NOT-R3 notes citées enregistrées avec le site qui les cite', () async {
    final wine = await w.photographed();
    w.gateway.scenario = FakeScenario.partial;
    await w.runToEnd();
    final r = (await w.queue.resultFor(wine))!;
    expect(r.result!.disagreements, contains('degre'));
    await w.validation.apply(wine, r);
    final d = (await w.f.repo.wine(wine))!;
    expect(d.scores.single.citedBy, 'exemple-caviste-a.fr');
  });

  test('AJO-07 doublon : la bouteille rejoint la fiche existante', () async {
    final existing = await w.f.repo.createWine(
      const WineDraft(
        producer: "Guillaume L'Echanson",
        country: 'FR',
        color: 'rouge',
        vintage: '2024',
      ),
      cellarId: w.f.cellar,
      lot: const LotDraft(ownerId: 'o1', quantity: 2),
    );
    final wine = await w.photographed();
    await w.runToEnd();
    final r = (await w.queue.resultFor(wine))!;
    expect(await w.validation.duplicateOf(wine, r), existing);
    final out = await w.validation.apply(wine, r, mergeIntoWineId: existing);
    expect(out.mergedInto, existing);
    expect(await w.f.repo.wine(wine), isNull);
    expect((await w.f.repo.wine(existing))!.bottles, 5);
  });

  test(
    'AJO-13 le résultat rogne la photo, la validation supprime l\'origine',
    () async {
      final wine = await w.photographed();
      await w.runToEnd();
      // Exemple du contrat : cadre (0,18 ; 0,22 ; 0,64 × 0,5) sur la photo 0.
      var ph = (await w.photos.photosOf(wine)).single;
      expect((ph.largeur, ph.hauteur), (768, 400));
      expect(ph.cadre, isNotNull);
      final origine = File('${w.root.path}/${ph.cheminOriginal}');
      expect(origine.existsSync(), isTrue);
      await w.validation.apply(wine, (await w.queue.resultFor(wine))!);
      ph = (await w.photos.photosOf(wine)).single;
      expect(origine.existsSync(), isFalse);
      expect(ph.cheminOriginal, isNull);
      expect(
        (ph.largeur, ph.hauteur),
        (768, 400),
        reason: 'photo rognée gardée',
      );
    },
  );
}
