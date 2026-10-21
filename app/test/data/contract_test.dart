import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/contract_validator.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/domain/enrichment.dart';

ContractValidator validator() => ContractValidator(
  responseSchema: File('assets/contrat/reponse-job.schema.json')
      .readAsStringSync(),
  requestSchema: File('assets/contrat/requete-enrichissement.schema.json')
      .readAsStringSync(),
);

Future<String> readExample(String name) =>
    File('assets/contrat/exemples/$name').readAsString();

Map<String, dynamic> example(String name) =>
    jsonDecode(File('assets/contrat/exemples/$name').readAsStringSync())
        as Map<String, dynamic>;

dynamic copy(Object? o) => jsonDecode(jsonEncode(o));

void main() {
  final v = validator();

  test('AJO-12 copie embarquée du contrat identique à specs/contrat-n8n', () {
    for (final f in Directory(
      '../specs/contrat-n8n',
    ).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      final rel = f.path.split('specs/contrat-n8n/').last;
      expect(
        File('assets/contrat/$rel').readAsStringSync(),
        f.readAsStringSync(),
        reason: 'Recopier specs/contrat-n8n/$rel dans app/assets/contrat/',
      );
    }
  });

  test('AJO-12 les exemples de réponse du contrat sont acceptés', () {
    for (final name in [
      'enrichissement-termine.json',
      'enrichissement-partiel.json',
      'job-en-cours.json',
      'erreur-quota.json',
      'prix-termine.json',
    ]) {
      expect(v.responseErrors(example(name)), isEmpty, reason: name);
    }
    expect(v.requestErrors(example('requete-enrichissement.json')), isEmpty);
  });

  group('AJO-12 réponses hors contrat rejetées (mêmes cas que scripts/valider_contrat.py)', () {
    final base = example('enrichissement-termine.json');
    final cases = <String, void Function(Map<String, dynamic>)>{
      'valeur nulle sans motif': (m) =>
          (m['resultat']['fiche']['cuvee'] as Map).remove('motif'),
      'source web sans url': (m) =>
          (m['resultat']['fiche']['commentaire_millesime'] as Map).remove(
            'url',
          ),
      'couleur inconnue': (m) =>
          m['resultat']['fiche']['couleur']['valeur'] = 'violet',
      'note citée sans citee_par': (m) => m['resultat']['notes_critiques'] = [
        {
          'source_critique': 'Robert Parker Wine Advocate',
          'note': 91,
          'echelle': 100,
          'acces': 'citee',
          'url': 'https://x.fr',
          'confiance': 0.7,
        },
      ],
      'prix trouvé sans montant': (m) =>
          ((m['resultat']['prix'] as List)[0] as Map).remove('prix'),
      'termine sans resultat': (m) => m.remove('resultat'),
      'garde estimée par l\'agent': (m) => m['resultat']['fiche']['garde'] = {
        'valeur': {'debut': 2026, 'fin': 2032},
        'source': 'estimation',
        'confiance': 0.5,
      },
      'propriété inconnue dans resultat': (m) =>
          m['resultat']['champ_inconnu'] = 1,
      'millésime hors bornes': (m) =>
          m['resultat']['fiche']['millesime']['valeur'] = 1850,
    };
    cases.forEach((name, mutate) {
      test('AJO-12 rejet : $name', () {
        final doc = copy(base) as Map<String, dynamic>;
        mutate(doc);
        expect(v.responseErrors(doc), isNotEmpty);
        expect(
          () => v.checkResponse(jsonEncode(doc)),
          throwsA(isA<ContractException>()),
        );
      });
    });
    test('AJO-12 rejet : texte non JSON', () {
      expect(
        () => v.checkResponse('<html>'),
        throwsA(isA<ContractException>()),
      );
    });
  });

  test('AJO-05 AJO-08 résultat lu : champs, notes, prix, alertes', () {
    final r = JobResponse.fromJson(
      v.checkResponse(jsonEncode(example('enrichissement-partiel.json'))),
    );
    expect(r.status, JobStatus.partial);
    expect(r.result!.disagreements, contains('degre'));
    expect(r.result!.scores.single.access, 'citee');
    expect(r.result!.scores.single.citedBy, 'exemple-caviste-a.fr');
    final full = JobResponse.fromJson(example('enrichissement-termine.json'));
    expect(full.result!.fields['domaine']!.value, "Guillaume L'Echanson");
    expect(full.result!.fields['garde']!.isEmpty, isTrue);
    expect(full.result!.prices.single.offers, hasLength(3));
    expect(full.enrichmentsLeft, 86);
  });

  test('AJO-11 quota affiché sous 20 % du quota mensuel', () {
    expect(quotaLow(86, monthlyEnrichmentQuota), isFalse);
    expect(quotaLow(19, monthlyEnrichmentQuota), isTrue);
    expect(quotaLow(null, monthlyEnrichmentQuota), isFalse);
  });

  test('AJO-10 l\'EAN part en indice dans une requête conforme', () {
    const req = EnrichmentRequest(
      requestId: '5d0c1c9e-8a3f-4f6e-9c2b-1a7e3d4f5b60',
      wineId: '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
      photos: [RequestPhoto(index: 0, type: 'etiquette', base64: '/9j/4AAQ')],
      ean: '3017620422003',
      vintageHint: 2019,
      lockedFields: ['degre', 'degre'],
      clientDate: '2026-10-21',
    );
    final json = req.toJson();
    expect(v.requestErrors(json), isEmpty);
    expect((json['indices'] as Map)['ean'], '3017620422003');
    expect(json['champs_verrouilles'], ['degre']);
  });

  group('FakeGateway', () {
    const req = EnrichmentRequest(
      requestId: '5d0c1c9e-8a3f-4f6e-9c2b-1a7e3d4f5b60',
      wineId: '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
      photos: [RequestPhoto(index: 0, type: 'etiquette', base64: '/9j/4AAQ')],
      clientDate: '2026-10-21',
    );
    FakeGateway gw([FakeScenario s = FakeScenario.done]) =>
        FakeGateway(validator: v, readExample: readExample, scenario: s);

    test('AJO-05 en_attente puis en_cours puis termine', () async {
      final g = gw();
      final created = await g.requestEnrichment(req);
      expect(created.status, JobStatus.pending);
      final running = await g.followJob(created.jobId);
      expect(running.status, JobStatus.running);
      expect(running.step, isNotNull);
      final done = await g.followJob(created.jobId);
      expect(done.status, JobStatus.done);
      expect(done.wineId, req.wineId);
    });

    test('AJO-09 idempotence : même request_id, même job', () async {
      final g = gw();
      final a = await g.requestEnrichment(req);
      final b = await g.requestEnrichment(req);
      expect(b.jobId, a.jobId);
    });

    test('AJO-09 hors ligne : OfflineException', () async {
      final g = gw()..online = false;
      await expectLater(
        g.requestEnrichment(req),
        throwsA(isA<OfflineException>()),
      );
    });

    test('AJO-12 réponse invalide : ContractException', () async {
      await expectLater(
        gw(FakeScenario.invalid).requestEnrichment(req),
        throwsA(isA<ContractException>()),
      );
    });

    test('AJO-11 quota épuisé : erreur non réessayable', () async {
      final r = await gw(FakeScenario.quota).requestEnrichment(req);
      expect(r.status, JobStatus.error);
      expect(r.error!.retryable, isFalse);
      expect(r.enrichmentsLeft, 0);
    });

    test('AJO-05 cache : termine dès la création', () async {
      final r = await gw(FakeScenario.cacheHit).requestEnrichment(req);
      expect(r.status, JobStatus.done);
      expect(r.result!.cacheHit, isTrue);
    });
  });
}
