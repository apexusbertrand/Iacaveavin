import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/validation_service.dart';

import 'enrichment_flow_test.dart' show Flow;

void main() {
  final w = Flow();
  setUp(w.setUp);
  tearDown(w.tearDown);

  Future<String> enriched() async {
    final wine = await w.photographed();
    await w.runToEnd();
    await w.validation.apply(wine, (await w.queue.resultFor(wine))!);
    return wine;
  }

  test('FIC-06 provenance par valeur : source, URL, date, confiance', () async {
    final wine = await enriched();
    final d = (await w.f.repo.wine(wine))!;
    final comment = d.provenances['commentaire_millesime']!;
    expect(comment.url, 'https://exemple-interprofession.fr/millesime-2024');
    expect(comment.date, '2026-10-21');
    expect(comment.confidence, isNotNull);
    expect(comment.status, 'valide');
    final producer = d.provenances['domaine']!;
    expect(producer.source, 'etiquette');
  });

  test('FIC-07 seul un texte tiré d\'une page web est marqué IA', () async {
    final wine = await enriched();
    final d = (await w.f.repo.wine(wine))!;
    expect(d.provenances['commentaire_millesime']!.aiWritten, isTrue);
    expect(d.provenances['domaine']!.aiWritten, isFalse);
  });

  test(
    'PRV-R4 signaler une erreur : la valeur reste, marquée signalée',
    () async {
      final wine = await enriched();
      var d = (await w.f.repo.wine(wine))!;
      await w.f.repo.reportProvenance(d.provenances['appellation']!.id);
      d = (await w.f.repo.wine(wine))!;
      expect(d.provenances['appellation']!.reported, isTrue);
      expect(d.draft.appellation, isNotNull, reason: 'affichée barrée');
    },
  );

  test(
    'PRV-R3 déverrouiller rend le champ au prochain enrichissement',
    () async {
      final wine = await w.photographed();
      await w.runToEnd();
      await w.validation.apply(
        wine,
        (await w.queue.resultFor(wine))!,
        decisions: const {'degre': FieldDecision.modify(13.5)},
      );
      var d = (await w.f.repo.wine(wine))!;
      expect(d.provenances['degre']!.locked, isTrue);
      await w.f.repo.unlockField(d.provenances['degre']!.id);
      expect(await w.queue.lockedFields(wine), isNot(contains('degre')));
      await w.queue.retry(wine);
      await w.runToEnd();
      await w.validation.apply(wine, (await w.queue.resultFor(wine))!);
      d = (await w.f.repo.wine(wine))!;
      expect(d.draft.alcohol, 12);
    },
  );

  test(
    'FIC-09 ré-enrichir envoie les champs verrouillés, propose sans appliquer',
    () async {
      final wine = await w.photographed();
      await w.runToEnd();
      await w.validation.apply(
        wine,
        (await w.queue.resultFor(wine))!,
        decisions: const {'degre': FieldDecision.modify(13.5)},
      );
      await w.queue.retry(wine);
      await w.runToEnd();
      expect(w.gateway.lastRequest!.lockedFields, contains('degre'));
      // Les propositions attendent la validation : la fiche ne bouge pas.
      final d = (await w.f.repo.wine(wine))!;
      expect(d.enrichmentStatus, 'a_valider');
      expect(d.draft.alcohol, 13.5);
      expect(await w.queue.resultFor(wine), isNotNull);
    },
  );

  test(
    'FIC-08 nouveau millésime : même cuvée, photos reprises, à enrichir',
    () async {
      final wine = await enriched();
      final copy = await w.f.repo.duplicateForVintage(wine, '2022');
      final a = (await w.f.repo.wine(wine))!;
      final b = (await w.f.repo.wine(copy))!;
      expect(b.cuveeId, a.cuveeId);
      expect(b.draft.vintage, '2022');
      expect(b.enrichmentStatus, 'a_enrichir');
      expect(b.draft.vintageComment, anyOf(isNull, isEmpty));
      expect(b.bottles, 0);
      expect(await w.photos.photosOf(copy), hasLength(1));
    },
  );
}
