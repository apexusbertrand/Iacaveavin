/// Garde estimée en local (décision T6, specs/regles-garde.yaml).
///
/// Utilisée seulement quand ni un critique ni le domaine ne donnent de
/// fenêtre. Déterministe et hors ligne ; la garde obtenue porte la source
/// « estimation ».
library;

import 'wine_query.dart' show normalizeSearch;

class GardeRule {
  const GardeRule({
    required this.id,
    required this.conditions,
    required this.start,
    required this.peak,
    required this.end,
  });

  /// [json] : une entrée de la clé `regles` du fichier YAML, déjà décodée.
  factory GardeRule.fromJson(Map<Object?, Object?> json) {
    final si = (json['si'] as Map?) ?? const {};
    final d = json['decalage']! as Map;
    return GardeRule(
      id: json['id']! as String,
      conditions: {
        for (final e in si.entries)
          '${e.key}': [
            for (final v in (e.value is List ? e.value as List : [e.value]))
              '$v',
          ],
      },
      start: (d['debut']! as num).toInt(),
      peak: (d['apogee']! as num).toInt(),
      end: (d['fin']! as num).toInt(),
    );
  }

  final String id;

  /// Clé du vin (couleur, millesime, classement, region, appellation) vers
  /// les valeurs acceptées. Vide : règle par défaut.
  final Map<String, List<String>> conditions;
  final int start;
  final int peak;
  final int end;

  /// Règle sans condition : la dernière, qui s'applique à tout vin.
  bool get isCatchAll => conditions.isEmpty;

  /// Même forme que le fichier YAML, pour les règles modifiées (PAR-07).
  Map<String, Object?> toJson() => {
    'id': id,
    'si': {
      for (final c in conditions.entries)
        c.key: c.value.length == 1 ? c.value.single : c.value,
    },
    'decalage': {'debut': start, 'apogee': peak, 'fin': end},
  };

  GardeRule copyWith({
    Map<String, List<String>>? conditions,
    int? start,
    int? peak,
    int? end,
  }) => GardeRule(
    id: id,
    conditions: conditions ?? this.conditions,
    start: start ?? this.start,
    peak: peak ?? this.peak,
    end: end ?? this.end,
  );
}

/// PAR-07 : décalages acceptés, en années après le millésime.
bool validGardeOffsets(int start, int peak, int end) =>
    start >= 0 && start <= peak && peak <= end && end <= maxGardeOffset;

const maxGardeOffset = 100;

/// PAR-07 : une règle ajoutée passe avant la première règle moins précise
/// (moins de conditions), pour ne pas être masquée par une règle plus
/// générale. La règle sans condition reste la dernière.
List<GardeRule> insertGardeRule(List<GardeRule> rules, GardeRule rule) {
  final at = rules.indexWhere(
    (r) => r.conditions.length < rule.conditions.length || r.isCatchAll,
  );
  return [...rules]..insert(at < 0 ? rules.length : at, rule);
}

/// Caractéristiques d'un vin utiles aux règles. Région, appellation et
/// classement sont les libellés, comme dans le fichier de règles.
class GardeInput {
  const GardeInput({
    required this.color,
    required this.vintage,
    this.classification,
    this.region,
    this.appellation,
    this.purchaseYear,
  });

  final String color;

  /// Année sur 4 chiffres ou « NM ».
  final String vintage;
  final String? classification;
  final String? region;
  final String? appellation;

  /// Pour un non millésimé, les décalages partent de l'année d'achat du
  /// premier lot.
  final int? purchaseYear;
}

class GardeEstimate {
  const GardeEstimate({
    required this.start,
    required this.peak,
    required this.end,
    required this.ruleId,
  });

  final int start;
  final int peak;
  final int end;
  final String ruleId;
}

bool _matches(GardeRule rule, GardeInput w) {
  for (final c in rule.conditions.entries) {
    final accepted = c.value.map(normalizeSearch).toSet();
    final String? actual = switch (c.key) {
      'couleur' => w.color,
      'millesime' => w.vintage == 'NM' ? 'NM' : 'millesime',
      'classement' => w.classification,
      'region' => w.region,
      'appellation' => w.appellation,
      _ => null,
    };
    if (actual == null || !accepted.contains(normalizeSearch(actual))) {
      return false;
    }
  }
  return true;
}

/// Première règle qui correspond (la dernière règle du fichier est sans
/// condition). Null si l'année de départ est inconnue (NM sans achat).
GardeEstimate? estimateGarde(List<GardeRule> rules, GardeInput w) {
  final base = int.tryParse(w.vintage) ?? w.purchaseYear;
  if (base == null) return null;
  for (final r in rules) {
    if (_matches(r, w)) {
      return GardeEstimate(
        start: base + r.start,
        peak: base + r.peak,
        end: base + r.end,
        ruleId: r.id,
      );
    }
  }
  return null;
}
