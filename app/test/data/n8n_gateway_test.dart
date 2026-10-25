import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/contract_validator.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/n8n_gateway.dart';
import 'package:iacaveavin/data/enrichment/request_signer.dart';
import 'package:iacaveavin/domain/enrichment.dart';

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
      final (status, json) = req.uri.path.endsWith('/sante')
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

N8nGateway gatewayFor(FakeN8n s, {String key = _key, ContractValidator? v}) =>
    N8nGateway(
      baseUrl: s.url,
      key: key,
      installationId: _installation,
      validator: v ?? validator(),
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
      'PAR-05 test de connexion : clé acceptée, refusée, flux non configuré',
      () async {
        s.answer = (m, p, b) => p.endsWith('/sante')
            ? (
                200,
                {'version_flux': '0.1.0', 'version_contrat': '1.0', 'ok': true},
              )
            : (404, _error('requete_invalide', 'Job inconnu ou expiré.'));
        expect((await gatewayFor(s).check()).status, ConnectionStatus.ok);
        final bad = await gatewayFor(s, key: 'mauvaise-cle').check();
        expect(bad.status, ConnectionStatus.badKey);
        expect(bad.message, 'Signature invalide.');
        s.answer = (m, p, b) => (
          200,
          {'version_flux': '0.1.0', 'version_contrat': '1.0', 'ok': false},
        );
        expect((await gatewayFor(s).check()).status, ConnectionStatus.notReady);
      },
    );

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
