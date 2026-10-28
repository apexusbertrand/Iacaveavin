import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/enrichment.dart';
import '../../domain/feedback.dart';
import 'contract_validator.dart';
import 'enrichment_gateway.dart';
import 'request_signer.dart';

/// Délai d'une requête au flux (règles Flutter : 15 s par requête).
const requestTimeout = Duration(seconds: 15);

/// Le flux a répondu mais refuse la connexion (clé, horodatage).
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException($message)';
}

/// Vrai flux n8n (lot 2c). Seule classe de l'app qui fait des appels HTTP.
/// Chaque requête est signée (docs/02-architecture.md) et chaque réponse
/// validée contre reponse-job.schema.json avant d'être renvoyée (AJO-12).
class N8nGateway implements EnrichmentGateway {
  N8nGateway({
    required this.baseUrl,
    required this.key,
    required this.installationId,
    required this.validator,
    HttpClient? client,
    DateTime Function()? clock,
  }) : _client = client ?? HttpClient(),
       _clock = clock ?? DateTime.now {
    _client.connectionTimeout = requestTimeout;
  }

  /// Adresse de l'instance, par exemple https://apexus.app.n8n.cloud.
  final String baseUrl;
  final String key;
  final String installationId;
  final ContractValidator validator;
  final HttpClient _client;
  final DateTime Function() _clock;

  static const _prefix = '/webhook/iacave';

  Uri _uri(String pathAndQuery) {
    final base = Uri.parse(baseUrl.trim());
    final p = Uri.parse(pathAndQuery);
    return base.replace(
      path: '${base.path.replaceAll(RegExp(r'/+$'), '')}${p.path}',
      query: p.hasQuery ? p.query : null,
    );
  }

  /// Envoie une requête signée et renvoie (code HTTP, corps).
  Future<(int, String)> _send(
    String method,
    String pathAndQuery, [
    Object? json,
  ]) async {
    final uri = _uri(pathAndQuery);
    final body = json == null ? <int>[] : utf8.encode(jsonEncode(json));
    // Chemin signé : celui de l'URL après l'hôte, requête comprise.
    final signedPath = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    try {
      final req = await _client.openUrl(method, uri).timeout(requestTimeout);
      securityHeaders(
        key: key,
        installationId: installationId,
        now: _clock(),
        method: method,
        path: signedPath,
        body: body,
      ).forEach(req.headers.set);
      if (json != null) {
        req.headers.contentType = ContentType.json;
        req.contentLength = body.length;
        req.add(body);
      }
      final res = await req.close().timeout(requestTimeout);
      final text = await utf8.decodeStream(res).timeout(requestTimeout);
      return (res.statusCode, text);
    } on SocketException {
      throw const OfflineException();
    } on TimeoutException {
      throw const OfflineException();
    } on HttpException {
      throw const OfflineException();
    } on HandshakeException {
      throw const OfflineException();
    }
  }

  /// Toute réponse du flux, succès ou refus, passe le contrat. Un refus de
  /// signature devient [AuthException] pour l'écran de connexion.
  JobResponse _job(int status, String body) {
    final r = JobResponse.fromJson(validator.checkResponse(body));
    if (status == 401 && r.error != null) throw AuthException(r.error!.message);
    return r;
  }

  @override
  Future<JobResponse> requestEnrichment(EnrichmentRequest request) async {
    final (status, body) = await _send(
      'POST',
      '$_prefix/enrichissement',
      request.toJson(),
    );
    return _job(status, body);
  }

  @override
  Future<JobResponse> requestPrice(PriceRequest request) async {
    final (status, body) = await _send(
      'POST',
      '$_prefix/prix',
      request.toJson(),
    );
    return _job(status, body);
  }

  @override
  Future<JobResponse> followJob(String jobId) async {
    final (status, body) = await _send(
      'GET',
      '$_prefix/jobs?job_id=${Uri.encodeQueryComponent(jobId)}',
    );
    return _job(status, body);
  }

  /// RET-01 : POST /remontee, réponse validée contre le contrat 1.3. Un
  /// refus de signature devient [AuthException], comme pour les jobs.
  @override
  Future<FeedbackResult> sendFeedback(FeedbackRequest request) async {
    final (status, body) = await _send(
      'POST',
      '$_prefix/remontee',
      request.toJson(),
    );
    final r = FeedbackResult.fromJson(validator.checkFeedbackResponse(body));
    if (status == 401 && !r.sent) throw AuthException(r.message ?? '');
    return r;
  }

  /// GET /sante : `{version_flux, version_contrat, ok}`. `ok` faux tant que la
  /// clé n'est pas configurée côté n8n.
  @override
  Future<FluxHealth> health() async {
    final (status, body) = await _send('GET', '$_prefix/sante');
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw const ContractException(['réponse de santé non JSON']);
    }
    if (status != 200 || json is! Map || json['ok'] is! bool) {
      throw ContractException(['santé : réponse inattendue ($status)']);
    }
    return FluxHealth(
      ok: json['ok'] as bool,
      contractVersion: json['version_contrat'] as String?,
    );
  }

  /// PAR-05 « Tester la connexion » : /sante, puis un suivi signé d'un job
  /// inexistant. Une réponse 404 au contrat prouve que la clé est acceptée.
  Future<ConnectionCheck> check() async {
    final h = await health();
    if (!h.ok) return const ConnectionCheck(ConnectionStatus.notReady);
    try {
      final r = await followJob('00000000-0000-4000-8000-000000000000');
      return r.error?.code == 'auth_invalide' ||
              r.error?.code == 'signature_expiree'
          ? ConnectionCheck(ConnectionStatus.badKey, message: r.error!.message)
          : ConnectionCheck(ConnectionStatus.ok, version: h.contractVersion);
    } on AuthException catch (e) {
      return ConnectionCheck(ConnectionStatus.badKey, message: e.message);
    }
  }

  void close() => _client.close(force: true);
}

enum ConnectionStatus { ok, notReady, badKey }

class ConnectionCheck {
  const ConnectionCheck(this.status, {this.version, this.message});

  final ConnectionStatus status;
  final String? version;
  final String? message;
}
