import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../core/flux_config.dart';
import '../domain/account.dart';
import 'enrichment/contract_validator.dart';
import 'enrichment/enrichment_gateway.dart';
import 'enrichment/enrichment_providers.dart';
import 'enrichment/n8n_gateway.dart';
import 'settings_store.dart';

/// Session du compte (CPT-02) : clé de signature comprise, elle est rangée
/// dans le stockage sécurisé du système (Keystore Android, Trousseau iOS),
/// jamais dans les préférences, les journaux, les exports ou les sauvegardes.
abstract interface class SecretStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'iacave_compte';

  /// Clé partagée des versions 1.0 (T126) : effacée à la première lecture.
  static const _legacyKey = 'iacave_cle_flux';

  @override
  Future<String?> read() async {
    await _storage.delete(key: _legacyKey);
    return _storage.read(key: _key);
  }

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Pour les tests : rien ne sort de la mémoire.
class MemorySecretStore implements SecretStore {
  MemorySecretStore([this._value]);

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;

  @override
  Future<void> delete() async => _value = null;
}

final secretStoreProvider = Provider<SecretStore>((ref) => SecureSecretStore());

/// Adresse du flux : [fluxBaseUrl], remplacée par un serveur local en test.
final fluxBaseUrlProvider = Provider<String>((ref) => fluxBaseUrl);

/// Horloge des sessions, remplaçable en test.
final accountClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Issue d'une action de compte, pour l'écran : réponse du flux, réseau
/// absent ou réponse hors contrat.
sealed class AccountOutcome {
  const AccountOutcome();
}

class AccountAnswered extends AccountOutcome {
  const AccountAnswered(this.reply);
  final AccountReply reply;
}

class AccountOffline extends AccountOutcome {
  const AccountOffline();
}

class AccountInvalid extends AccountOutcome {
  const AccountInvalid();
}

/// CPT-01 à CPT-04 : session de compte. `null` : personne n'est connecté,
/// l'identification par photo, les prix et la remontée attendent. La cave
/// fonctionne sans compte.
class AccountController extends AsyncNotifier<AccountSession?> {
  @override
  Future<AccountSession?> build() async {
    final raw = await ref.watch(secretStoreProvider).read();
    if (raw == null || raw.isEmpty) return null;
    try {
      return AccountSession.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      // Session illisible : on repart sans compte.
      await ref.read(secretStoreProvider).delete();
      return null;
    }
  }

  Future<String> _installationId() async {
    final settings = ref.read(settingsProvider.notifier);
    final id = ref.read(settingsProvider).installationId;
    if (id != null) return id;
    final fresh = const Uuid().v4();
    await settings.update((s) => s.copyWith(installationId: fresh));
    return fresh;
  }

  Future<N8nGateway> _gateway([AccountSession? session]) async {
    final validator = await ref.read(contractValidatorProvider.future);
    return N8nGateway(
      baseUrl: ref.read(fluxBaseUrlProvider),
      key: session?.key ?? '',
      accountId: session?.account.id,
      installationId: await _installationId(),
      validator: validator,
      clock: ref.read(accountClockProvider),
    );
  }

  Future<AccountOutcome> _call(
    Future<AccountReply> Function(N8nGateway g) action, [
    AccountSession? session,
  ]) async {
    final g = await _gateway(session);
    try {
      return AccountAnswered(await action(g));
    } on OfflineException {
      return const AccountOffline();
    } on ContractException {
      return const AccountInvalid();
    } finally {
      g.close();
    }
  }

  /// CPT-01 : demande d'un code de connexion par mail.
  Future<AccountOutcome> requestCode(String email) => _call(
    (g) => g.requestLoginCode(requestId: const Uuid().v4(), email: email),
  );

  /// CPT-02 : le code ouvre la session, enregistrée dans le stockage sécurisé.
  Future<AccountOutcome> signIn(String email, String code) async {
    final r = await _call(
      (g) =>
          g.openSession(requestId: const Uuid().v4(), email: email, code: code),
    );
    if (r case AccountAnswered(:final reply) when reply.session != null) {
      await _save(reply.session!);
    }
    return r;
  }

  /// CPT-04 : statut et quotas à jour. Une clé refusée ferme la session
  /// locale : il faut se reconnecter.
  Future<AccountOutcome> refresh() async {
    final session = state.value;
    if (session == null) return const AccountInvalid();
    final r = await _call((g) => g.accountState(), session);
    if (r case AccountAnswered(:final reply)) {
      if (reply.sessionRejected) {
        await _clear();
      } else if (reply.account != null) {
        await _save(session.withAccount(reply.account!));
      }
    }
    return r;
  }

  /// CPT-04 : déconnexion. La clé est révoquée côté flux si le réseau le
  /// permet, et toujours effacée du téléphone.
  Future<void> signOut() async {
    final session = state.value;
    if (session != null) await _call((g) => g.signOut(), session);
    await _clear();
  }

  Future<void> _save(AccountSession s) async {
    await ref.read(secretStoreProvider).write(jsonEncode(s.toJson()));
    state = AsyncData(s);
  }

  Future<void> _clear() async {
    await ref.read(secretStoreProvider).delete();
    state = const AsyncData(null);
  }
}

final accountProvider =
    AsyncNotifierProvider<AccountController, AccountSession?>(
      AccountController.new,
    );

/// Vrai si un compte actif est connecté (CPT-03).
final signedInProvider = Provider<bool>((ref) {
  final s = ref.watch(accountProvider).value;
  return s != null && s.isActive(ref.watch(accountClockProvider)());
});
