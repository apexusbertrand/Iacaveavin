import 'feedback.dart' show isValidEmail;

/// Compte de l'app (CPT-01 à CPT-04, contrat 2.0). L'enrichissement, les prix
/// et la remontée passent par un compte ; la cave reste locale et ne dépend
/// d'aucun compte (règle 1 du projet).
enum AccountStatus {
  free('gratuit'),
  subscriber('abonne'),
  blocked('bloque');

  const AccountStatus(this.wire);

  /// Valeur du contrat (`statut_compte`).
  final String wire;

  static AccountStatus fromWire(String? v) => AccountStatus.values.firstWhere(
    (s) => s.wire == v,
    orElse: () => AccountStatus.blocked,
  );
}

class AccountQuota {
  const AccountQuota({required this.enrichmentsLeft, required this.pricesLeft});

  factory AccountQuota.fromJson(Map<String, dynamic> json) => AccountQuota(
    enrichmentsLeft: json['enrichissements_restants_mois'] as int,
    pricesLeft: json['prix_restants_mois'] as int,
  );

  final int enrichmentsLeft;
  final int pricesLeft;

  Map<String, Object?> toJson() => {
    'enrichissements_restants_mois': enrichmentsLeft,
    'prix_restants_mois': pricesLeft,
  };
}

/// Ce que l'app sait du compte, tel que le flux l'a renvoyé. L'identifiant
/// est pseudonyme : c'est lui, pas l'adresse, qui suit chaque appel.
class Account {
  const Account({
    required this.id,
    required this.email,
    required this.status,
    required this.quota,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['compte_id'] as String,
    email: json['email'] as String,
    status: AccountStatus.fromWire(json['statut_compte'] as String?),
    quota: AccountQuota.fromJson(
      Map<String, dynamic>.from(json['quota'] as Map),
    ),
  );

  final String id;
  final String email;
  final AccountStatus status;
  final AccountQuota quota;

  Map<String, Object?> toJson() => {
    'compte_id': id,
    'email': email,
    'statut_compte': status.wire,
    'quota': quota.toJson(),
  };

  Account withQuota(AccountQuota q) =>
      Account(id: id, email: email, status: status, quota: q);
}

/// Session ouverte : le compte et sa clé de signature. La clé reste dans le
/// stockage sécurisé du système, jamais dans les préférences, les journaux,
/// les exports ni les sauvegardes.
class AccountSession {
  const AccountSession({
    required this.account,
    required this.key,
    required this.expiresAt,
  });

  factory AccountSession.fromJson(Map<String, dynamic> json) => AccountSession(
    account: Account.fromJson(Map<String, dynamic>.from(json['compte'] as Map)),
    key: json['cle_session'] as String,
    expiresAt: DateTime.parse(json['cle_expire_le'] as String),
  );

  final Account account;
  final String key;
  final DateTime expiresAt;

  /// CPT-03 : une session sert tant que sa clé n'a pas expiré et que le
  /// compte n'est pas suspendu.
  bool isActive(DateTime now) =>
      key.isNotEmpty &&
      expiresAt.isAfter(now) &&
      account.status != AccountStatus.blocked;

  AccountSession withAccount(Account a) =>
      AccountSession(account: a, key: key, expiresAt: expiresAt);

  Map<String, Object?> toJson() => {
    'compte': account.toJson(),
    'cle_session': key,
    'cle_expire_le': expiresAt.toUtc().toIso8601String(),
  };
}

/// CPT-01 : adresse normalisée comme le flux (espaces retirés, minuscules).
String normalizeEmail(String email) => email.trim().toLowerCase();

/// CPT-01 : adresse acceptée par le contrat.
bool isValidAccountEmail(String email) => isValidEmail(normalizeEmail(email));

/// CPT-02 : code à six chiffres reçu par mail.
bool isValidLoginCode(String code) =>
    RegExp(r'^[0-9]{6}$').hasMatch(code.trim());

/// Réponse d'un point d'entrée /compte, déjà validée contre le contrat.
class AccountReply {
  const AccountReply({
    required this.status,
    this.codeValidSeconds,
    this.account,
    this.session,
    this.errorCode,
    this.errorMessage,
    this.retryable = false,
  });

  factory AccountReply.fromJson(Map<String, dynamic> json) {
    final compte = json['compte'] is Map
        ? Map<String, dynamic>.from(json['compte'] as Map)
        : null;
    final erreur = json['erreur'] is Map
        ? Map<String, dynamic>.from(json['erreur'] as Map)
        : null;
    final account = compte == null ? null : Account.fromJson(compte);
    return AccountReply(
      status: json['statut'] as String,
      codeValidSeconds: json['code_valable_s'] as int?,
      account: account,
      session: account != null && compte!['cle_session'] is String
          ? AccountSession(
              account: account,
              key: compte['cle_session'] as String,
              expiresAt: DateTime.parse(compte['cle_expire_le'] as String),
            )
          : null,
      errorCode: erreur?['code'] as String?,
      errorMessage: erreur?['message'] as String?,
      retryable: erreur?['reessayable'] as bool? ?? false,
    );
  }

  /// code_envoye, connecte, ok, deconnecte ou erreur.
  final String status;
  final int? codeValidSeconds;
  final Account? account;

  /// Présente seulement à l'ouverture de session (statut connecte).
  final AccountSession? session;
  final String? errorCode;
  final String? errorMessage;
  final bool retryable;

  bool get isError => status == 'erreur';

  /// Clé refusée ou expirée : la session locale n'est plus valable.
  bool get sessionRejected =>
      errorCode == 'auth_invalide' || errorCode == 'signature_expiree';
}
