import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/contract_validator.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/n8n_gateway.dart';
import 'package:iacaveavin/data/enrichment/request_signer.dart';
import 'package:iacaveavin/domain/account.dart';
import 'package:iacaveavin/domain/enrichment.dart';
import 'package:iacaveavin/domain/feedback.dart';

import 'contract_test.dart' show example, validator;

const _key = 'cle-de-test-ne-pas-utiliser-en-production';
const _installation = '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10';

/// Faux serveur n8n local : vérifie la signature comme le flux, puis répond
/// par [answer].
class FakeN8n {
  late HttpServer server;
  final requests =
      <
        ({String method, String path, Map<String, String> headers, String body})
      >[];
  (int, Object) Function(String method, String path, String body) answer = (
    m,
    p,
    b,
  ) => (200, {});
  String key = _key;

  String get url => 'http://127.0.0.1:${server.port}';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = await utf8.decodeStream(req);
      final path = req.uri.hasQuery
          ? '${req.uri.path}?${req.uri.query}'
          : req.uri.path;
      final headers = <String, String>{};
      req.headers.forEach((n, v) => headers[n.toLowerCase()] = v.first);
      requests.add((
        method: req.method,
        path: path,
        headers: headers,
        body: body,
      ));
      final ts = headers['x-iacav-horodatage'] ?? '';
      final expected = signRequest(
        key: key,
        timestamp: ts,
        method: req.method,
        path: path,
        body: utf8.encode(body),
      );
      final unsigned =
          req.uri.path.endsWith('/sante') ||
          req.uri.path.endsWith('/compte/code') ||
          req.uri.path.endsWith('/compte/session');
      final (status, json) = unsigned
          ? answer(req.method, path, body)
          : headers['x-iacav-signature'] != expected
          ? (401, _error('auth_invalide', 'Signature invalide.'))
          : answer(req.method, path, body);
      req.response.statusCode = status;
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode(json));
      await req.response.close();
    });
  }

  Future<void> stop() => server.close(force: true);
}

Map<String, Object?> _error(String code, String message) => {
  'version_contrat': '1.0',
  'job_id': '00000000-0000-4000-8000-000000000000',
  'request_id': '00000000-0000-4000-8000-000000000000',
  'type': 'enrichissement',
  'statut': 'erreur',
  'erreur': {'code': code, 'message': message, 'reessayable': false},
};

const _account = '3c9e1f4a-2b7d-4e8f-a1c3-5d6e7f8a9b0c';

N8nGateway gatewayFor(FakeN8n s, {String key = _key, ContractValidator? v}) =>
    N8nGateway(
      baseUrl: s.url,
      key: key,
      accountId: _account,
      installationId: _installation,
      validator: v ?? accountValidator(),
    );

ContractValidator accountValidator() => ContractValidator(
  responseSchema: File('assets/contrat/reponse-job.schema.json')
      .readAsStringSync(),
  feedbackResponseSchema: File('assets/contrat/reponse-remontee.schema.json')
      .readAsStringSync(),
  accountResponseSchema: File('assets/contrat/reponse-compte.schema.json')
      .readAsStringSync(),
);

const priceRequest = PriceRequest(
  requestId: 'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
  wineId: '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
  domain: "Guillaume L'Echanson",
  appellation: "Bourgogne Côte d'Or",
  vintage: 2024,
  colour: 'rouge',
  formatCl: 75,
  currency: 'EUR',
  clientDate: '2026-11-20',
);

void main() {
  test('NFR-06 signature conforme au vecteur fixe du contrat', () {
    final v = jsonDecode(
      File('../specs/contrat-n8n/vecteur-signature.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final body = utf8.encode(v['corps'] as String);
    expect(sha256.convert(body).toString(), v['sha256_corps']);
    expect(
      signRequest(
        key: v['cle'] as String,
        timestamp: v['horodatage'] as String,
        method: v['methode'] as String,
        path: v['chemin'] as String,
        body: body,
      ),
      v['signature'],
    );
  });

  group('N8nGateway contre un faux serveur local', () {
    late FakeN8n s;
    setUp(() async {
      s = FakeN8n();
      await s.start();
    });
    tearDown(() => s.stop());

    test(
      'PRX-02 POST /prix signé, corps au contrat, réponse validée',
      () async {
        s.answer = (m, p, b) => (
          202,
          {
            ...example('job-en-cours.json'),
            'type': 'prix',
            'statut': 'en_attente',
            'etape': 'prix',
          },
        );
        final r = await gatewayFor(s).requestPrice(priceRequest);
        expect(r.status, JobStatus.pending);
        final req = s.requests.single;
        expect(req.method, 'POST');
        expect(req.path, '/webhook/iacave/prix');
        expect(req.headers['x-iacav-installation'], _installation);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect((body['identite'] as Map)['millesime'], 2024);
        expect(body['forcer'], false);
        final schema = ContractValidator(
          responseSchema: File('assets/contrat/reponse-job.schema.json')
              .readAsStringSync(),
          requestSchema: File('../specs/contrat-n8n/requete-prix.schema.json')
              .readAsStringSync(),
        );
        expect(schema.requestErrors(body), isEmpty);
      },
    );

    test(
      'AJO-12 suivi signé sur le chemin avec la requête, prix lus',
      () async {
        s.answer = (m, p, b) => (200, example('prix-termine.json'));
        final r = await gatewayFor(s)
            .followJob('e5f4d3c2-b1a0-4f9e-8d7c-6b5a4f3e2d1c');
        expect(
          s.requests.single.path,
          '/webhook/iacave/jobs?job_id=e5f4d3c2-b1a0-4f9e-8d7c-6b5a4f3e2d1c',
        );
        expect(r.status, JobStatus.done);
        expect(r.prices.single.price, 25.0);
      },
    );

    test('AJO-12 réponse hors contrat refusée avant tout usage', () async {
      s.answer = (m, p, b) =>
          (200, {...example('prix-termine.json'), 'statut': 'inconnu'});
      expect(
        () => gatewayFor(s).followJob('e5f4d3c2-b1a0-4f9e-8d7c-6b5a4f3e2d1c'),
        throwsA(isA<ContractException>()),
      );
    });

    test(
      'CPT-01 code demandé sans signature, adresse normalisée au contrat 2.0',
      () async {
        s.answer = (m, p, b) => (200, example('reponse-compte-code.json'));
        final r =
            await N8nGateway(
              baseUrl: s.url,
              installationId: _installation,
              validator: accountValidator(),
            ).requestLoginCode(
              requestId: '7d1c2a9e-5b3f-4e6a-8c2d-1f0e9a8b7c6d',
              email: ' Prenom.Nom@Exemple.fr ',
            );
        final sent = s.requests.single;
        expect(sent.path, '/webhook/iacave/compte/code');
        expect(sent.headers.containsKey('x-iacav-signature'), isFalse);
        final body = jsonDecode(sent.body) as Map<String, dynamic>;
        expect(body['email'], 'prenom.nom@exemple.fr');
        expect(body['version_contrat'], '2.1');
        expect(body['installation'], _installation);
        expect(r.status, 'code_envoye');
        expect(r.codeValidSeconds, 600);
      },
    );

    test('CPT-02 bon code : session ouverte, clé et quotas lus', () async {
      s.answer = (m, p, b) => (200, example('reponse-compte-session.json'));
      final r = await gatewayFor(s, key: '').openSession(
        requestId: '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e',
        email: 'prenom.nom@exemple.fr',
        code: '123456',
      );
      expect(s.requests.single.path, '/webhook/iacave/compte/session');
      expect(jsonDecode(s.requests.single.body)['code'], '123456');
      final session = r.session!;
      expect(session.account.id, _account);
      expect(session.account.status, AccountStatus.free);
      expect(session.account.quota.enrichmentsLeft, 10);
      expect(session.key, hasLength(64));
      expect(session.isActive(DateTime.utc(2026, 11)), isTrue);
      expect(session.isActive(DateTime.utc(2027, 5)), isFalse);

      s.answer = (m, p, b) => (
        401,
        {
          'version_contrat': '2.0',
          'request_id': '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e',
          'statut': 'erreur',
          'erreur': {
            'code': 'code_invalide',
            'message': 'Code incorrect. Essais restants : 4.',
            'reessayable': true,
          },
        },
      );
      final bad = await gatewayFor(s, key: '').openSession(
        requestId: '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e',
        email: 'prenom.nom@exemple.fr',
        code: '000000',
      );
      expect(bad.session, isNull);
      expect(bad.errorCode, 'code_invalide');
    });

    test(
      'CPT-03 job signé avec la clé du compte et l\'en-tête X-IACAV-Compte',
      () async {
        s.answer = (m, p, b) => (200, example('job-en-cours.json'));
        await gatewayFor(s).followJob('9b1f6c2e-0d4a-4c51-9a77-000000000001');
        final h = s.requests.single.headers;
        expect(h['x-iacav-compte'], _account);
        expect(h['x-iacav-installation'], _installation);
        // Une autre clé que celle du compte est refusée par le flux.
        expect(
          () => gatewayFor(
            s,
            key: 'autre-cle',
          ).followJob('9b1f6c2e-0d4a-4c51-9a77-000000000001'),
          throwsA(isA<AuthException>()),
        );
      },
    );

    test('CPT-04 état du compte et déconnexion signés', () async {
      s.answer = (m, p, b) => (200, example('reponse-compte.json'));
      final state = await gatewayFor(s).accountState();
      expect(s.requests.last.method, 'GET');
      expect(s.requests.last.path, '/webhook/iacave/compte');
      expect(state.account!.quota.pricesLeft, isNonNegative);
      expect(state.session, isNull);
      s.answer = (m, p, b) =>
          (200, {...example('reponse-compte.json'), 'statut': 'deconnecte'});
      final out = await gatewayFor(s).signOut();
      expect(s.requests.last.path, '/webhook/iacave/compte/deconnexion');
      expect(s.requests.last.headers['x-iacav-compte'], _account);
      expect(out.status, 'deconnecte');
    });

    test(
      'CPT-05 suppression signée sur /compte/suppression (contrat 2.1)',
      () async {
        s.answer = (m, p, b) =>
            (200, example('reponse-compte-suppression.json'));
        final r = await gatewayFor(s).deleteAccount();
        expect(s.requests.last.method, 'POST');
        expect(s.requests.last.path, '/webhook/iacave/compte/suppression');
        expect(s.requests.last.headers['x-iacav-compte'], _account);
        expect(r.status, 'supprime');
        expect(r.account, isNull);
      },
    );

    test('RET-01 remontée signée sur /remontee, quota lu', () async {
      const request = FeedbackRequest(
        requestId: '5f0c2a8e-3b1d-4c6e-9a7f-2d4b6c8e0a1b',
        title: 'Fiche fausse',
        comment: 'Le millésime lu est faux.',
        email: 'bertrand@exemple.fr',
        clientDate: '2026-10-28',
      );
      s.answer = (m, p, b) => (
        200,
        {...example('reponse-remontee.json'), 'request_id': request.requestId},
      );
      final r = await gatewayFor(s).sendFeedback(request);
      final sent = s.requests.single;
      expect(sent.method, 'POST');
      expect(sent.path, '/webhook/iacave/remontee');
      expect(jsonDecode(sent.body)['email_contact'], 'bertrand@exemple.fr');
      expect(r.sent, isTrue);

      s.answer = (m, p, b) => (
        429,
        {
          'version_contrat': '2.0',
          'request_id': request.requestId,
          'statut': 'erreur',
          'envoi_restants_jour': 0,
          'erreur': {
            'code': 'quota_depasse',
            'message': '5 remontées par jour au plus : réessayez demain.',
            'reessayable': false,
          },
        },
      );
      final q = await gatewayFor(s).sendFeedback(request);
      expect(q.sent, isFalse);
      expect(q.errorCode, 'quota_depasse');
    });

    test('NFR-03 flux injoignable : OfflineException, le job attend', () async {
      final url = s.url;
      await s.stop();
      final g = N8nGateway(
        baseUrl: url,
        key: _key,
        installationId: _installation,
        validator: validator(),
      );
      expect(() => g.health(), throwsA(isA<OfflineException>()));
    });
  });
}
