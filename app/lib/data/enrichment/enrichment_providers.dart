import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

import '../../domain/garde_rules.dart';
import '../backup_providers.dart';
import '../files/photo_service.dart';
import '../flux_credentials.dart';
import '../providers.dart';
import '../settings_store.dart';
import 'contract_validator.dart';
import 'enrichment_gateway.dart';
import 'enrichment_queue.dart';
import 'n8n_gateway.dart';
import 'validation_service.dart';

final contractValidatorProvider = FutureProvider<ContractValidator>((
  ref,
) async {
  return ContractValidator(
    responseSchema: await rootBundle.loadString(
      ContractValidator.responseAsset,
    ),
    requestSchema: await rootBundle.loadString(ContractValidator.requestAsset),
    feedbackResponseSchema: await rootBundle.loadString(
      ContractValidator.feedbackResponseAsset,
    ),
  );
});

/// Vrai flux n8n dès qu'une adresse et une clé sont enregistrées (PAR-05),
/// sinon faux flux du lot 2a qui rejoue les exemples du contrat.
final gatewayProvider = FutureProvider<EnrichmentGateway>((ref) async {
  final settings = ref.watch(settingsProvider);
  final validator = await ref.watch(contractValidatorProvider.future);
  if (settings.usesRealFlux && settings.installationId != null) {
    await ref.watch(fluxKeyPresentProvider.future);
    final key = await ref.read(secretStoreProvider).read();
    if (key != null && key.isNotEmpty) {
      final gateway = N8nGateway(
        baseUrl: settings.fluxUrl,
        key: key,
        installationId: settings.installationId!,
        validator: validator,
      );
      ref.onDispose(gateway.close);
      return gateway;
    }
  }
  return FakeGateway(
    validator: validator,
    readExample: (name) =>
        rootBundle.loadString('assets/contrat/exemples/$name'),
    scenario: FakeScenario.values.firstWhere(
      (s) => s.name == settings.fakeScenario,
      orElse: () => FakeScenario.done,
    ),
    online: !settings.simulateOffline,
    delay: const Duration(milliseconds: 600),
  );
});

final photoServiceProvider = Provider<PhotoService>(
  (ref) => PhotoService(
    ref.watch(databaseProvider),
    appDir: ref.watch(appDirProvider),
  ),
);

final enrichmentQueueProvider = FutureProvider<EnrichmentQueue>((ref) async {
  return EnrichmentQueue(
    ref.watch(databaseProvider),
    gateway: await ref.watch(gatewayProvider.future),
    photos: ref.watch(photoServiceProvider),
  );
});

final gardeRulesListProvider = FutureProvider<List<GardeRule>>((ref) async {
  final yaml = loadYaml(
    await rootBundle.loadString('assets/regles/regles-garde.yaml'),
  ) as YamlMap;
  return [
    for (final r in (yaml['regles'] as YamlList).cast<YamlMap>())
      GardeRule.fromJson(r),
  ];
});

final validationServiceProvider = FutureProvider<ValidationService>((
  ref,
) async {
  return ValidationService(
    ref.watch(databaseProvider),
    cellar: ref.watch(cellarRepositoryProvider),
    reference: ref.watch(referenceRepositoryProvider),
    rules: await ref.watch(gardeRulesListProvider.future),
    photos: ref.watch(photoServiceProvider),
  );
});

/// NFR-03 : compteur visible des enrichissements en file d'attente.
final pendingJobsProvider = StreamProvider<int>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  final queue = await ref.watch(enrichmentQueueProvider.future);
  yield* queue.watchPendingCount();
});

/// Fait tourner la file : envoi, puis suivi toutes les 3 s pendant 90 s,
/// puis toutes les 10 s (docs/02), tant qu'un job attend.
class EnrichmentRunner extends Notifier<QueueReport?> {
  Timer? _timer;
  bool _busy = false;
  DateTime? _startedAt;

  @override
  QueueReport? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// À appeler après une prise de photos, au lancement et au retour réseau.
  Future<void> kick() async {
    if (_busy) return;
    _busy = true;
    _timer?.cancel();
    _startedAt ??= DateTime.now();
    try {
      final queue = await ref.read(enrichmentQueueProvider.future);
      state = await queue.process(
        currency: ref.read(settingsProvider).currency,
      );
      final pending = (await queue.pendingJobs()).length;
      if (pending == 0) {
        _startedAt = null;
        return;
      }
      final wait = state?.offline == true
          ? const Duration(seconds: 30)
          : pollDelay(DateTime.now().difference(_startedAt!));
      _timer = Timer(wait, kick);
    } on Object {
      // Base ou fichiers indisponibles : on réessaiera au prochain appel.
    } finally {
      _busy = false;
    }
  }
}

final enrichmentRunnerProvider =
    NotifierProvider<EnrichmentRunner, QueueReport?>(EnrichmentRunner.new);
