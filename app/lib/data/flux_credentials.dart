import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clé partagée avec le flux n8n (PAR-05). Rangée dans le stockage sécurisé
/// du système (Keystore Android, Trousseau iOS), jamais dans les
/// préférences, les journaux, les exports ou les sauvegardes.
abstract interface class SecretStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'iacave_cle_flux';

  @override
  Future<String?> read() => _storage.read(key: _key);

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

/// Vrai si une clé est enregistrée. Invalidé après saisie ou effacement.
final fluxKeyPresentProvider = FutureProvider<bool>((ref) async {
  final k = await ref.watch(secretStoreProvider).read();
  return k != null && k.isNotEmpty;
});
