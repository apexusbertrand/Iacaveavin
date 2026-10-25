import 'wine_query.dart';

enum AppThemeMode { system, light, dark }

enum CardPrice { purchase, market }

/// Réglages de l'application (PAR-05) et état mémorisé de la liste (LST-09).
/// Aucun secret ici : la clé du flux n8n est dans le stockage sécurisé
/// (FluxCredentials), jamais dans les préférences.
class AppSettings {
  const AppSettings({
    this.currency = 'EUR',
    this.themeMode = AppThemeMode.system,
    this.defaultOwnerId,
    this.defaultLocationId,
    this.defaultQuery = const WineQuery(),
    this.personalScale = 20,
    this.cardPrice = CardPrice.purchase,
    this.notifications = true,
    this.autoPriceRefresh = false,
    this.listQuery = const WineQuery(),
    this.compactView = false,
    this.lastAutoBackup,
    this.lastExternalBackup,
    this.firstLaunch,
    this.photoConsent = false,
    this.fakeScenario = 'done',
    this.simulateOffline = false,
    this.fluxUrl = '',
    this.installationId,
    this.lastAutoPriceRefresh,
  });

  /// Code ISO 4217.
  final String currency;
  final AppThemeMode themeMode;
  final String? defaultOwnerId;
  final String? defaultLocationId;

  /// Tri par défaut, appliqué par « Réinitialiser ».
  final WineQuery defaultQuery;

  /// Échelle des notes personnelles : 20 ou 100.
  final int personalScale;
  final CardPrice cardPrice;
  final bool notifications;

  /// PRX-06 : désactivé par défaut (lot 2c).
  final bool autoPriceRefresh;

  /// Tri, filtres et vue mémorisés (LST-09). La recherche ne l'est pas.
  final WineQuery listQuery;
  final bool compactView;
  final DateTime? lastAutoBackup;
  final DateTime? lastExternalBackup;

  /// Premier lancement, point de départ du rappel d'export (SAV-03).
  final DateTime? firstLaunch;

  /// NFR-08 : consentement explicite avant le premier envoi de photos.
  final bool photoConsent;

  /// Lot 2a : scénario rejoué par le faux flux (nom de FakeScenario).
  final String fakeScenario;

  /// Lot 2a : le faux flux se comporte comme en mode avion.
  final bool simulateOffline;

  /// PAR-05 : adresse de l'instance n8n. Vide : faux flux du lot 2a.
  final String fluxUrl;

  /// UUID de l'installation (en-tête X-IACAV-Installation), généré une fois.
  final String? installationId;

  /// PRX-06 : dernier rafraîchissement automatique des prix.
  final DateTime? lastAutoPriceRefresh;

  /// Le vrai flux est utilisé dès qu'une adresse est enregistrée.
  bool get usesRealFlux => fluxUrl.trim().isNotEmpty;

  AppSettings copyWith({
    String? currency,
    AppThemeMode? themeMode,
    String? Function()? defaultOwnerId,
    String? Function()? defaultLocationId,
    WineQuery? defaultQuery,
    int? personalScale,
    CardPrice? cardPrice,
    bool? notifications,
    bool? autoPriceRefresh,
    WineQuery? listQuery,
    bool? compactView,
    DateTime? lastAutoBackup,
    DateTime? lastExternalBackup,
    DateTime? firstLaunch,
    bool? photoConsent,
    String? fakeScenario,
    bool? simulateOffline,
    String? fluxUrl,
    String? installationId,
    DateTime? lastAutoPriceRefresh,
  }) => AppSettings(
    currency: currency ?? this.currency,
    themeMode: themeMode ?? this.themeMode,
    defaultOwnerId: defaultOwnerId != null
        ? defaultOwnerId()
        : this.defaultOwnerId,
    defaultLocationId: defaultLocationId != null
        ? defaultLocationId()
        : this.defaultLocationId,
    defaultQuery: defaultQuery ?? this.defaultQuery,
    personalScale: personalScale ?? this.personalScale,
    cardPrice: cardPrice ?? this.cardPrice,
    notifications: notifications ?? this.notifications,
    autoPriceRefresh: autoPriceRefresh ?? this.autoPriceRefresh,
    listQuery: listQuery ?? this.listQuery,
    compactView: compactView ?? this.compactView,
    lastAutoBackup: lastAutoBackup ?? this.lastAutoBackup,
    lastExternalBackup: lastExternalBackup ?? this.lastExternalBackup,
    firstLaunch: firstLaunch ?? this.firstLaunch,
    photoConsent: photoConsent ?? this.photoConsent,
    fakeScenario: fakeScenario ?? this.fakeScenario,
    simulateOffline: simulateOffline ?? this.simulateOffline,
    fluxUrl: fluxUrl ?? this.fluxUrl,
    installationId: installationId ?? this.installationId,
    lastAutoPriceRefresh: lastAutoPriceRefresh ?? this.lastAutoPriceRefresh,
  );

  static Map<String, Object?> _query(WineQuery q) => {
    'sort1': q.sort1.toJson(),
    'sort2': q.sort2?.toJson(),
    'filters': q.filters.toJson(),
  };

  static WineQuery _queryFrom(Object? json) {
    if (json is! Map) return const WineQuery();
    return WineQuery(
      sort1: SortSpec.fromJson(json['sort1']) ?? const WineQuery().sort1,
      sort2: SortSpec.fromJson(json['sort2']),
      filters: WineFilters.fromJson(json['filters']),
    );
  }

  Map<String, Object?> toJson() => {
    'currency': currency,
    'themeMode': themeMode.name,
    'defaultOwnerId': defaultOwnerId,
    'defaultLocationId': defaultLocationId,
    'defaultQuery': _query(defaultQuery),
    'personalScale': personalScale,
    'cardPrice': cardPrice.name,
    'notifications': notifications,
    'autoPriceRefresh': autoPriceRefresh,
    'listQuery': _query(listQuery),
    'compactView': compactView,
    'lastAutoBackup': lastAutoBackup?.toIso8601String(),
    'lastExternalBackup': lastExternalBackup?.toIso8601String(),
    'firstLaunch': firstLaunch?.toIso8601String(),
    'photoConsent': photoConsent,
    'fakeScenario': fakeScenario,
    'simulateOffline': simulateOffline,
    'fluxUrl': fluxUrl,
    'installationId': installationId,
    'lastAutoPriceRefresh': lastAutoPriceRefresh?.toIso8601String(),
  };

  static AppSettings fromJson(Map<String, Object?> json) => AppSettings(
    currency: json['currency'] as String? ?? 'EUR',
    themeMode: AppThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => AppThemeMode.system,
    ),
    defaultOwnerId: json['defaultOwnerId'] as String?,
    defaultLocationId: json['defaultLocationId'] as String?,
    defaultQuery: _queryFrom(json['defaultQuery']),
    personalScale: json['personalScale'] == 100 ? 100 : 20,
    cardPrice: json['cardPrice'] == CardPrice.market.name
        ? CardPrice.market
        : CardPrice.purchase,
    notifications: json['notifications'] != false,
    autoPriceRefresh: json['autoPriceRefresh'] == true,
    listQuery: _queryFrom(json['listQuery']),
    compactView: json['compactView'] == true,
    lastAutoBackup: DateTime.tryParse('${json['lastAutoBackup']}'),
    lastExternalBackup: DateTime.tryParse('${json['lastExternalBackup']}'),
    firstLaunch: DateTime.tryParse('${json['firstLaunch']}'),
    photoConsent: json['photoConsent'] == true,
    fakeScenario: json['fakeScenario'] as String? ?? 'done',
    simulateOffline: json['simulateOffline'] == true,
    fluxUrl: json['fluxUrl'] as String? ?? '',
    installationId: json['installationId'] as String?,
    lastAutoPriceRefresh: DateTime.tryParse('${json['lastAutoPriceRefresh']}'),
  );
}
