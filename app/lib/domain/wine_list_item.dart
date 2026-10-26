import 'garde.dart';

/// Part d'un propriétaire dans le stock d'une fiche (PRO-02).
class OwnerShare {
  const OwnerShare({
    required this.ownerId,
    required this.name,
    required this.bottles,
  });

  final String ownerId;
  final String name;
  final int bottles;
}

/// Ligne de l'écran « Mes vins » : une fiche vin (cuvée + millésime) et son
/// stock calculé depuis les mouvements (STK-R1, STK-R3), avec tout ce qu'il
/// faut pour trier, filtrer, grouper et chercher (LST-01 à LST-06).
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
    this.wineType,
    this.regionCode,
    this.appellationCode,
    this.lieuDit,
    this.owners = const [],
    this.locationIds = const {},
    this.locationPath,
    this.parkerScore,
    this.bestScore100,
    this.marketValue,
    this.createdAt,
    this.gardeStart,
    this.gardePeak,
    this.gardeEnd,
    this.grapes = const [],
    this.favorite = false,
    this.searchText = '',
    this.primaryLotId,
    this.thumbPath,
    this.neverStocked = false,
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

  final String? wineType;
  final String? regionCode;
  final String? appellationCode;
  final String? lieuDit;

  /// Répartition du stock par propriétaire, du plus gros au plus petit.
  final List<OwnerShare> owners;

  /// Emplacements des lots en stock et tous leurs parents (filtre LST-05).
  final Set<String> locationIds;

  /// Chemin de l'emplacement principal, ex. « Cave > Armoire 1 > Casier A ».
  final String? locationPath;

  /// Note Parker affichée (NOT-R1), sur son échelle d'origine.
  final double? parkerScore;

  /// Meilleure note toutes sources, ramenée sur 100 (NOT-R2).
  final double? bestScore100;

  /// Valeur marché du stock (VAL-R2), null si aucun prix marché.
  final double? marketValue;
  final DateTime? createdAt;
  final int? gardeStart;
  final int? gardePeak;
  final int? gardeEnd;

  /// Libellés des cépages.
  final List<String> grapes;
  final bool favorite;

  /// Texte de recherche déjà normalisé (LST-06).
  final String searchText;

  /// Lot le mieux fourni, utilisé par le geste « ouvrir une bouteille ».
  final String? primaryLotId;

  /// Miniature de la photo principale, relative au répertoire de l'app.
  final String? thumbPath;

  /// Aucun mouvement de stock n'a jamais été saisi : fiche identifiée sans
  /// bouteille (quantité 0), ou pas encore de lot. Elle reste dans la vue
  /// « en stock » ; « épuisé » est réservé aux fiches dont le stock a été bu.
  final bool neverStocked;

  /// Fiche créée par photo, pas encore identifiée (ni domaine ni cuvée).
  /// Une étiquette sans nom de domaine lisible garde sa cuvée comme nom.
  bool get isUnidentified => producer.isEmpty && (cuvee ?? '').isEmpty;

  bool get isNonVintage => vintage == 'NM';

  int? get vintageYear => int.tryParse(vintage);

  /// Nom affiché : domaine puis cuvée.
  String get displayName => cuvee == null || cuvee!.isEmpty
      ? producer
      : producer.isEmpty
      ? cuvee!
      : '$producer · $cuvee';

  String? get mainOwner => owners.isEmpty ? null : owners.first.name;

  CellarStatus statusIn(int year) => cellarStatus(
    year: year,
    start: gardeStart,
    peak: gardePeak,
    end: gardeEnd,
  );
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
