import 'dart:convert';

import '../../domain/enrichment.dart';
import '../../domain/feedback.dart';
import 'contract_validator.dart';

/// Le flux est injoignable (mode avion, serveur arrêté) : le job attend.
class OfflineException implements Exception {
  const OfflineException();

  @override
  String toString() => 'OfflineException';
}

/// Aucune connexion au flux n'est enregistrée (PAR-05) : la fiche reste
/// « à enrichir » et partira une fois la connexion faite dans les Paramètres.
/// Traitée comme une absence de réseau par la file d'attente.
class NotConnectedException extends OfflineException {
  const NotConnectedException();

  @override
  String toString() => 'NotConnectedException';
}

class FluxHealth {
  const FluxHealth({required this.ok, this.contractVersion});

  final bool ok;
  final String? contractVersion;
}

/// Seul accès au flux n8n (docs/02-architecture.md). Toute réponse est
/// validée contre le contrat avant d'être renvoyée (AJO-12).
abstract interface class EnrichmentGateway {
  Future<JobResponse> requestEnrichment(EnrichmentRequest request);

  /// PRX-02 : relevé du prix marché d'une fiche existante.
  Future<JobResponse> requestPrice(PriceRequest request);
  Future<JobResponse> followJob(String jobId);
  Future<FluxHealth> health();

  /// RET-01 : remontée d'information envoyée par mail par le flux.
  Future<FeedbackResult> sendFeedback(FeedbackRequest request);
}

/// App publiée sans connexion enregistrée : pas de flux de démonstration,
/// chaque appel signale l'absence de connexion.
class NotConnectedGateway implements EnrichmentGateway {
  const NotConnectedGateway();

  @override
  Future<JobResponse> requestEnrichment(EnrichmentRequest request) =>
      Future.error(const NotConnectedException());

  @override
  Future<JobResponse> requestPrice(PriceRequest request) =>
      Future.error(const NotConnectedException());

  @override
  Future<JobResponse> followJob(String jobId) =>
      Future.error(const NotConnectedException());

  @override
  Future<FluxHealth> health() => Future.error(const NotConnectedException());

  @override
  Future<FeedbackResult> sendFeedback(FeedbackRequest request) =>
      Future.error(const NotConnectedException());
}

/// Scénarios rejoués par [FakeGateway].
enum FakeScenario {
  /// en_attente, puis en_cours, puis termine (enrichissement-termine.json).
  done,

  /// Résultat partiel avec désaccord étiquette/source (enrichissement-partiel.json).
  partial,

  /// Vin déjà en cache : termine dès la création du job.
  cacheHit,

  /// Quota épuisé (erreur-quota.json).
  quota,

  /// Réponse hors contrat : traitée comme une erreur (AJO-12).
  invalid,

  /// Le job ne se termine jamais : délai de 3 minutes (AJO-09).
  never,
}

/// Faux flux (lot 2a) : rejoue specs/contrat-n8n/exemples/ avec des délais
/// simulés. Chaque réponse passe par le même validateur que le vrai flux.
class FakeGateway implements EnrichmentGateway {
  FakeGateway({
    required this.validator,
    required this.readExample,
    this.scenario = FakeScenario.done,
    this.pollsBeforeDone = 2,
    this.online = true,
    this.delay = Duration.zero,
  });

  final ContractValidator validator;

  /// Lit un exemple par son nom de fichier (assets/contrat/exemples/).
  final Future<String> Function(String name) readExample;
  FakeScenario scenario;
  int pollsBeforeDone;
  bool online;

  /// Dernière demande reçue, pour vérifier ce que l'app envoie.
  EnrichmentRequest? lastRequest;
  Duration delay;

  final _jobs = <String, _FakeJob>{};
  int calls = 0;

  Future<Map<String, dynamic>> _example(String name) async =>
      jsonDecode(await readExample(name)) as Map<String, dynamic>;

  Future<JobResponse> _answer(Map<String, dynamic> json) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final body = scenario == FakeScenario.invalid
        ? jsonEncode({...json, 'statut': 'inconnu'})
        : jsonEncode(json);
    return JobResponse.fromJson(validator.checkResponse(body));
  }

  void _checkOnline() {
    calls++;
    if (!online) throw const OfflineException();
  }

  /// Dernière remontée reçue (RET-01).
  FeedbackRequest? lastFeedback;

  /// Remontée rejouée pour les tests : rien ne part, la réponse est celle de
  /// l'exemple du contrat, validée comme une vraie.
  @override
  Future<FeedbackResult> sendFeedback(FeedbackRequest request) async {
    _checkOnline();
    lastFeedback = request;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final e = await _example('reponse-remontee.json');
    final body = jsonEncode({...e, 'request_id': request.requestId});
    return FeedbackResult.fromJson(validator.checkFeedbackResponse(body));
  }

  @override
  Future<JobResponse> requestEnrichment(EnrichmentRequest request) async {
    _checkOnline();
    lastRequest = request;
    // Idempotence : même request_id, même job.
    final existing = _jobs.values
        .where((j) => j.requestId == request.requestId)
        .firstOrNull;
    final job =
        existing ??
        _FakeJob(
          requestId: request.requestId,
          wineId: request.wineId,
          jobId: _uuidFor(_jobs.length),
        );
    _jobs[job.jobId] = job;
    if (scenario == FakeScenario.quota) {
      final e = await _example('erreur-quota.json');
      return _answer({...e, 'request_id': request.requestId});
    }
    if (scenario == FakeScenario.cacheHit) return _final(job);
    final base = await _example('job-en-cours.json');
    return _answer(
      job.stamp({
        ...base,
        'statut': 'en_attente',
        'etape': 'lecture_etiquette',
      }),
    );
  }

  /// Dernier relevé de prix demandé.
  PriceRequest? lastPriceRequest;

  @override
  Future<JobResponse> requestPrice(PriceRequest request) async {
    _checkOnline();
    lastPriceRequest = request;
    final job = _FakeJob(
      requestId: request.requestId,
      wineId: request.wineId,
      jobId: _uuidFor(_jobs.length),
      price: true,
    );
    _jobs[job.jobId] = job;
    if (scenario == FakeScenario.quota) {
      final e = await _example('erreur-quota.json');
      return _answer({...e, 'request_id': request.requestId, 'type': 'prix'});
    }
    final base = await _example('job-en-cours.json');
    return _answer(
      job.stamp({
        ...base,
        'type': 'prix',
        'statut': 'en_attente',
        'etape': 'prix',
      }),
    );
  }

  @override
  Future<JobResponse> followJob(String jobId) async {
    _checkOnline();
    final job = _jobs[jobId];
    if (job == null) throw StateError('job inconnu $jobId');
    if (job.price) {
      job.polls++;
      if (job.polls < pollsBeforeDone) {
        final base = await _example('job-en-cours.json');
        return _answer(job.stamp({...base, 'type': 'prix', 'etape': 'prix'}));
      }
      final e = await _example('prix-termine.json');
      return _answer(job.stamp(e));
    }
    job.polls++;
    if (scenario == FakeScenario.never || job.polls < pollsBeforeDone) {
      final step = jobSteps[(job.polls) % (jobSteps.length - 1)];
      // T111 : dès l'étape enrichissement, la lecture de l'étiquette suit.
      final base = await _example(
        jobSteps.indexOf(step) >= jobSteps.indexOf('enrichissement')
            ? 'job-en-cours-lecture.json'
            : 'job-en-cours.json',
      );
      return _answer(job.stamp({...base, 'etape': step}));
    }
    return _final(job);
  }

  Future<JobResponse> _final(_FakeJob job) async {
    final name = scenario == FakeScenario.partial
        ? 'enrichissement-partiel.json'
        : 'enrichissement-termine.json';
    final e = await _example(name);
    final result = Map<String, dynamic>.from(e['resultat'] as Map);
    if (scenario == FakeScenario.cacheHit) {
      result['cache'] = {...?(result['cache'] as Map?), 'hit': true};
    }
    return _answer(job.stamp({...e, 'resultat': result}));
  }

  @override
  Future<FluxHealth> health() async {
    _checkOnline();
    return const FluxHealth(ok: true, contractVersion: contractVersion);
  }

  static String _uuidFor(int n) =>
      '9b1f6c2e-0d4a-4c51-9a77-${(n + 1).toRadixString(16).padLeft(12, '0')}';
}

class _FakeJob {
  _FakeJob({
    required this.requestId,
    required this.jobId,
    this.wineId,
    this.price = false,
  });

  final String requestId;
  final String jobId;
  final String? wineId;
  final bool price;
  int polls = 0;

  Map<String, dynamic> stamp(Map<String, dynamic> json) => {
    ...json,
    'job_id': jobId,
    'request_id': requestId,
    'fiche_id': wineId,
  };
}
