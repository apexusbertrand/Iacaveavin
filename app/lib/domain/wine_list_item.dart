/// Ligne de l'écran « Mes vins » : une fiche vin (cuvée + millésime) et son
/// stock calculé depuis les mouvements (STK-R1, STK-R3).
class WineListItem {
  const WineListItem({
    required this.id,
    required this.producer,
    required this.vintage,
    required this.colorCode,
    required this.countryCode,
    required this.bottles,
    this.cuvee,
    this.countryLabel,
    this.region,
    this.subRegion,
    this.appellation,
    this.purchasePrice,
    this.enrichmentStatus = 'valide',
  });

  final String id;

  /// Nom du domaine.
  final String producer;
  final String? cuvee;

  /// Année sur 4 chiffres ou « NM ».
  final String vintage;

  /// Code de la liste « couleur » du dictionnaire.
  final String colorCode;
  final String countryCode;
  final String? countryLabel;
  final String? region;
  final String? subRegion;
  final String? appellation;

  /// Somme des mouvements de tous les lots de la fiche.
  final int bottles;

  /// Prix d'achat unitaire du dernier lot acheté, s'il est connu.
  final double? purchasePrice;
  final String enrichmentStatus;

  bool get isNonVintage => vintage == 'NM';

  /// Nom affiché : domaine puis cuvée.
  String get displayName =>
      cuvee == null || cuvee!.isEmpty ? producer : '$producer · $cuvee';
}

/// Compteur de la barre de titre : vins affichés et bouteilles correspondantes.
class CellarSummary {
  const CellarSummary({required this.wines, required this.bottles});

  factory CellarSummary.of(Iterable<WineListItem> items) {
    var wines = 0;
    var bottles = 0;
    for (final item in items) {
      wines++;
      bottles += item.bottles;
    }
    return CellarSummary(wines: wines, bottles: bottles);
  }

  final int wines;
  final int bottles;
}
