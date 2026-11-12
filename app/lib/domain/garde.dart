/// Garde : statut et années utiles (docs/04-modele-donnees.md, § Garde).
library;

/// Valeurs de l'énumération `statut_garde` du dictionnaire, dans son ordre.
enum CellarStatus {
  tooYoung('trop_jeune'),
  toDrink('a_boire'),
  peak('apogee'),
  drinkSoon('a_boire_vite'),
  past('passe'),
  unknown('inconnu');

  const CellarStatus(this.code);

  final String code;
}

/// Statut pour l'année [year] (premier cas vrai, dans l'ordre documenté).
CellarStatus cellarStatus({
  required int year,
  int? start,
  int? peak,
  int? end,
}) {
  if (start == null || end == null) return CellarStatus.unknown;
  if (year > end) return CellarStatus.past;
  if (year < start) return CellarStatus.tooYoung;
  if (year >= end - 1) return CellarStatus.drinkSoon;
  if (peak != null && (year - peak).abs() <= 1) return CellarStatus.peak;
  return CellarStatus.toDrink;
}

/// Années avant de boire = max(0, début − année).
int? yearsBeforeDrinking({required int year, int? start}) =>
    start == null ? null : (start - year).clamp(0, 1 << 30);

/// Année de consommation idéale : l'apogée, sinon le milieu de la fenêtre
/// arrondi à l'année inférieure.
int? idealYear({int? start, int? peak, int? end}) {
  if (peak != null) return peak;
  if (start == null || end == null) return null;
  return (start + end) ~/ 2;
}

/// LST-11 : années jusqu'à l'apogée (année de consommation idéale) ; 0 cette
/// année, négatif quand elle est dépassée. Null sans fenêtre de garde.
int? yearsToPeak({required int year, int? start, int? peak, int? end}) {
  final ideal = idealYear(start: start, peak: peak, end: end);
  return ideal == null ? null : ideal - year;
}

/// LST-11 : priorité de garde, croissante. Les vins passés d'abord (les plus
/// en retard en tête), puis à boire vite, à l'apogée, à boire, puis les vins
/// à garder, du moins au plus longtemps. Null (en fin de liste) sans fenêtre.
int? drinkPriority({required int year, int? start, int? peak, int? end}) {
  final s = cellarStatus(year: year, start: start, peak: peak, end: end);
  return switch (s) {
    CellarStatus.unknown => null,
    CellarStatus.past => end! - year,
    CellarStatus.drinkSoon => 0,
    CellarStatus.peak => 1,
    CellarStatus.toDrink => 2,
    CellarStatus.tooYoung => 2 + (start! - year),
  };
}
