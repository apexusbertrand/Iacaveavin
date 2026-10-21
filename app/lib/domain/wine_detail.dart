import 'scores.dart';

/// Cépage et pourcentage facultatif, tel que stocké dans `fiche_vin.cepages`.
class GrapeShare {
  const GrapeShare(this.code, [this.percent]);

  final String code;
  final int? percent;

  Map<String, Object?> toJson() => {'cepage': code, 'pourcentage': percent};

  static GrapeShare fromJson(Map<String, dynamic> json) => GrapeShare(
    json['cepage'] as String,
    (json['pourcentage'] as num?)?.toInt(),
  );
}

/// Champs saisissables d'une fiche (FIC-01), répartis sur domaine, cuvée et
/// fiche. Les clés suivent le dictionnaire.
class WineDraft {
  const WineDraft({
    required this.producer,
    required this.country,
    required this.color,
    required this.vintage,
    this.producerWebsite,
    this.producerComment,
    this.cuvee,
    this.region,
    this.subRegion,
    this.appellation,
    this.qualitySign,
    this.classification,
    this.lieuDit,
    this.wineType,
    this.certification,
    this.grapes = const [],
    this.alcohol,
    this.vintageComment,
    this.gardeStart,
    this.gardePeak,
    this.gardeEnd,
    this.pairings = const [],
    this.ean,
    this.lwin,
    this.personalComment,
    this.favorite = false,
  });

  final String producer;
  final String? producerWebsite;
  final String? producerComment;
  final String? cuvee;
  final String country;
  final String? region;
  final String? subRegion;
  final String? appellation;
  final String? qualitySign;
  final String? classification;
  final String? lieuDit;
  final String color;
  final String? wineType;
  final String? certification;
  final String vintage;
  final List<GrapeShare> grapes;
  final double? alcohol;
  final String? vintageComment;
  final int? gardeStart;
  final int? gardePeak;
  final int? gardeEnd;
  final List<String> pairings;
  final String? ean;
  final String? lwin;
  final String? personalComment;
  final bool favorite;
}

/// Lot à créer : stock initial porté par un mouvement `entree`.
class LotDraft {
  const LotDraft({
    required this.ownerId,
    required this.quantity,
    this.formatCl = 75,
    this.locationId,
    this.positions,
    this.unitPrice,
    this.purchaseDate,
    this.supplier,
  });

  final String ownerId;
  final int quantity;
  final double formatCl;
  final String? locationId;
  final String? positions;
  final double? unitPrice;
  final String? purchaseDate;
  final String? supplier;
}

class LotView {
  const LotView({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.formatCl,
    required this.bottles,
    this.locationId,
    this.locationPath,
    this.positions,
    this.unitPrice,
    this.purchaseDate,
    this.supplier,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final double formatCl;
  final int bottles;
  final String? locationId;
  final String? locationPath;
  final String? positions;
  final double? unitPrice;
  final String? purchaseDate;
  final String? supplier;
}

class MovementView {
  const MovementView({
    required this.id,
    required this.lotId,
    required this.type,
    required this.quantity,
    required this.date,
    required this.createdAt,
    this.reason,
    this.comment,
  });

  final String id;
  final String lotId;

  /// Code de l'énumération `type_mouvement`.
  final String type;
  final int quantity;
  final String date;
  final DateTime createdAt;
  final String? reason;
  final String? comment;
}

class TastingView {
  const TastingView({
    required this.id,
    required this.date,
    this.score,
    this.comment,
    this.dish,
  });

  final String id;
  final String date;
  final double? score;
  final String? comment;
  final String? dish;
}

class MarketPriceView {
  const MarketPriceView({
    required this.date,
    required this.formatCl,
    required this.found,
    this.price,
    this.offers,
    this.site,
    this.url,
  });

  final String date;
  final double formatCl;
  final bool found;
  final double? price;
  final int? offers;
  final String? site;
  final String? url;
}

/// Provenance d'une valeur enrichie (FIC-06, PRV-R1 à PRV-R4).
class ProvenanceView {
  const ProvenanceView({
    required this.id,
    required this.field,
    required this.source,
    required this.date,
    required this.status,
    this.url,
    this.confidence,
    this.reported = false,
  });

  final String id;

  /// Nom du champ dans le contrat (domaine, appellation...).
  final String field;
  final String source;
  final String date;

  /// `valide`, `manuel` ou `verrouille`.
  final String status;
  final String? url;
  final double? confidence;

  /// PRV-R4 : signalé comme faux, affiché barré jusqu'à correction.
  final bool reported;

  bool get locked => status == 'manuel' || status == 'verrouille';

  /// FIC-07 : texte rédigé par l'agent à partir d'une page web.
  bool get aiWritten =>
      url != null && source != 'etiquette' && source != 'manuel';
}

/// Fiche complète, pour l'écran de détail (FIC-01 à FIC-05).
class WineDetail {
  const WineDetail({
    required this.id,
    required this.cuveeId,
    required this.producerId,
    required this.draft,
    required this.labels,
    required this.enrichmentStatus,
    required this.lots,
    required this.movements,
    required this.tastings,
    required this.scores,
    required this.marketPrices,
    this.gardeSource,
    this.provenances = const {},
  });

  final String id;
  final String cuveeId;
  final String producerId;
  final WineDraft draft;

  /// Libellés des codes de liste, par clé de champ (`region`, `appellation`,
  /// `cepage:merlot`...).
  final Map<String, String> labels;
  final String enrichmentStatus;
  final String? gardeSource;
  final List<LotView> lots;

  /// Du plus récent au plus ancien (FIC-03).
  final List<MovementView> movements;
  final List<TastingView> tastings;
  final List<CriticScoreValue> scores;

  /// Du plus ancien au plus récent (courbe FIC-05).
  final List<MarketPriceView> marketPrices;

  /// Provenance en vigueur par champ du contrat (FIC-06).
  final Map<String, ProvenanceView> provenances;

  int get bottles => lots.fold(0, (s, l) => s + l.bottles);

  /// STK-R3 : bouteilles consommées = somme des ouvertures en valeur absolue.
  int get consumed => movements
      .where((m) => m.type == 'ouverture')
      .fold(0, (s, m) => s - m.quantity);

  String label(String key, String? code) =>
      code == null ? '' : labels['$key:$code'] ?? code;
}

/// Lot rangé dans un emplacement (EMP-04, inventaire STK-04).
class LocationLot {
  const LocationLot({
    required this.lotId,
    required this.wineId,
    required this.wineName,
    required this.vintage,
    required this.colorCode,
    required this.locationId,
    required this.ownerName,
    required this.bottles,
    this.positions,
  });

  final String lotId;
  final String wineId;
  final String wineName;
  final String vintage;
  final String colorCode;
  final String locationId;
  final String ownerName;
  final int bottles;
  final String? positions;
}
