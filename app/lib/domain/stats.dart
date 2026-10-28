/// STA-01 à STA-06 : statistiques calculées sur le téléphone, en fonctions
/// pures. Le grain est le lot : propriétaire, emplacement, prix et date
/// d'achat sont portés par le lot, les ouvertures par ses mouvements.
library;

import 'dart:math' as math;

import 'garde.dart';

/// STA-02 : mesures de l'explorateur.
enum StatMeasure {
  bottles('bouteilles'),
  references('references'),
  purchaseValue('valeur_achat'),
  marketValue('valeur_marche'),
  gain('plus_value'),
  averagePrice('prix_moyen'),
  averageScore('note_moyenne'),
  opened('ouvertes'),
  yearsBefore('annees_avant_boire');

  const StatMeasure(this.code);

  final String code;

  /// Montant : affiché dans la devise de la cave.
  bool get money =>
      this == purchaseValue ||
      this == marketValue ||
      this == gain ||
      this == averagePrice;

  /// Moyenne : pas de total, pas de donut (une part n'a pas de sens).
  bool get average =>
      this == averagePrice || this == averageScore || this == yearsBefore;

  static StatMeasure? fromCode(String? c) =>
      values.where((m) => m.code == c).firstOrNull;
}

/// STA-02 : dimensions. [ordered] : ordre naturel (années, mois, tranches).
enum StatDimension {
  color('couleur'),
  type('type'),
  country('pays'),
  region('region'),
  subRegion('sous_region'),
  appellation('appellation'),
  producer('domaine'),
  vintage('millesime', ordered: true),
  vintageBand('tranche_millesime', ordered: true),
  mainGrape('cepage_principal'),
  owner('proprietaire'),
  location('emplacement'),
  gardeStatus('statut_garde'),
  gardeStart('annee_debut_garde', ordered: true),
  peakYear('annee_apogee', ordered: true),
  scoreBand('tranche_note', ordered: true),
  priceBand('tranche_prix', ordered: true),
  supplier('fournisseur'),
  purchaseMonth('mois_achat', ordered: true),
  openingMonth('mois_ouverture', ordered: true);

  const StatDimension(this.code, {this.ordered = false});

  final String code;
  final bool ordered;

  static StatDimension? fromCode(String? c) =>
      values.where((d) => d.code == c).firstOrNull;
}

/// STA-02 : types de graphique.
enum StatChart {
  donut('donut'),
  barsVertical('barres_verticales'),
  barsHorizontal('barres_horizontales'),
  stacked('barres_empilees'),
  line('courbe'),
  crossTable('tableau_croise'),
  kpi('indicateur');

  const StatChart(this.code);

  final String code;

  static StatChart? fromCode(String? c) =>
      values.where((x) => x.code == c).firstOrNull;
}

/// STA-03 : donut sur une dimension et 8 parts au plus, le reste en
/// « Autres ».
const donutMaxParts = 8;

/// Clé de la part « Autres » et de la valeur non renseignée.
const otherKey = '\u0000autres';
const noneKey = '';

/// STA-03 : seuls les graphiques compatibles sont proposés.
List<StatChart> compatibleCharts(
  StatMeasure measure,
  StatDimension dim1,
  StatDimension? dim2,
) {
  if (dim2 != null) {
    return [
      if (!measure.average) StatChart.stacked,
      StatChart.crossTable,
      StatChart.kpi,
    ];
  }
  return [
    if (!measure.average) StatChart.donut,
    StatChart.barsVertical,
    StatChart.barsHorizontal,
    if (dim1.ordered) StatChart.line,
    StatChart.kpi,
  ];
}

/// Un lot, avec les attributs de sa fiche.
class StatFact {
  const StatFact({
    required this.wineId,
    required this.lotId,
    required this.bottles,
    required this.keys,
    this.unitPrice,
    this.marketPrice,
    this.score100,
    this.gardeStart,
    this.gardePeak,
    this.gardeEnd,
    this.openings = const [],
    this.priceHistory = const [],
  });

  final String wineId;
  final String lotId;

  /// Stock actuel du lot (somme des mouvements, STK-R1).
  final int bottles;

  /// Clé par dimension (code de liste, nom, année, mois AAAA-MM…), hors
  /// tranches et statut de garde, calculés ici.
  final Map<StatDimension, String> keys;
  final double? unitPrice;

  /// Dernier prix marché trouvé pour la fiche et le format (VAL-R2).
  final double? marketPrice;
  final double? score100;
  final int? gardeStart;
  final int? gardePeak;
  final int? gardeEnd;

  /// Ouvertures : mois (AAAA-MM) et bouteilles ouvertes.
  final List<(String, int)> openings;

  /// Relevés de prix marché trouvés (date AAAA-MM-JJ, prix), du plus ancien
  /// au plus récent.
  final List<(String, double)> priceHistory;
}

/// Requête de l'explorateur (et des tableaux prêts à l'emploi).
class StatQuery {
  const StatQuery({
    required this.measure,
    required this.dim1,
    this.dim2,
    this.filters = const {},
    this.periodMonths = 12,
  });

  final StatMeasure measure;
  final StatDimension dim1;
  final StatDimension? dim2;

  /// Valeurs retenues par dimension (vide : tout).
  final Map<StatDimension, Set<String>> filters;

  /// Période des ouvertures (mesure `ouvertes`), en mois jusqu'au mois en
  /// cours compris.
  final int periodMonths;

  StatQuery copyWith({
    StatMeasure? measure,
    StatDimension? dim1,
    StatDimension? Function()? dim2,
    Map<StatDimension, Set<String>>? filters,
  }) => StatQuery(
    measure: measure ?? this.measure,
    dim1: dim1 ?? this.dim1,
    dim2: dim2 != null ? dim2() : this.dim2,
    filters: filters ?? this.filters,
    periodMonths: periodMonths,
  );
}

class StatCell {
  const StatCell(this.k1, this.k2, this.value, this.wineIds);

  final String k1;
  final String? k2;
  final double value;

  /// STA-04 : fiches de la part ou de la barre.
  final Set<String> wineIds;
}

class StatResult {
  const StatResult({
    required this.cells,
    required this.keys1,
    required this.keys2,
    required this.total,
    required this.wineIds,
  });

  final List<StatCell> cells;

  /// Clés de la première dimension, dans l'ordre d'affichage.
  final List<String> keys1;
  final List<String> keys2;

  /// Valeur sur l'ensemble (somme, ou moyenne pour une mesure moyenne).
  final double total;
  final Set<String> wineIds;

  bool get isEmpty => cells.isEmpty;

  double valueOf(String k1, [String? k2]) =>
      cells.where((c) => c.k1 == k1 && c.k2 == k2).firstOrNull?.value ?? 0;

  StatCell? cell(String k1, [String? k2]) =>
      cells.where((c) => c.k1 == k1 && c.k2 == k2).firstOrNull;
}

String _month(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

/// Premier mois de la période des ouvertures.
String periodStart(DateTime now, int months) =>
    _month(DateTime(now.year, now.month - months + 1));

/// Clé d'une dimension pour un fait (tranches et statut calculés).
String keyOf(StatFact f, StatDimension d, int year) => switch (d) {
  StatDimension.vintageBand => switch (int.tryParse(
    f.keys[StatDimension.vintage] ?? '',
  )) {
    null => noneKey,
    final y => '${y - y % 5}',
  },
  StatDimension.gardeStatus => cellarStatus(
    year: year,
    start: f.gardeStart,
    peak: f.gardePeak,
    end: f.gardeEnd,
  ).code,
  StatDimension.gardeStart => f.gardeStart?.toString() ?? noneKey,
  StatDimension.peakYear => f.gardePeak?.toString() ?? noneKey,
  StatDimension.scoreBand =>
    f.score100 == null ? noneKey : '${(f.score100! ~/ 5) * 5}',
  StatDimension.priceBand =>
    f.unitPrice == null
        ? noneKey
        : '${priceBands.lastWhere((b) => f.unitPrice! >= b)}',
  _ => f.keys[d] ?? noneKey,
};

/// Bornes basses des tranches de prix (montant unitaire).
const priceBands = [0, 10, 20, 30, 50, 100, 200, 500];

/// Agrégation : une cellule par clé (ou couple de clés) de dimension.
StatResult aggregate(
  List<StatFact> facts,
  StatQuery q, {
  required int year,
  required DateTime now,
}) {
  final from = periodStart(now, q.periodMonths);
  final to = _month(now);
  bool kept(StatFact f) {
    for (final e in q.filters.entries) {
      if (e.value.isEmpty || e.key == StatDimension.openingMonth) continue;
      if (!e.value.contains(keyOf(f, e.key, year))) return false;
    }
    return true;
  }

  final openingFilter = q.filters[StatDimension.openingMonth] ?? const {};
  final byOpening =
      q.dim1 == StatDimension.openingMonth ||
      q.dim2 == StatDimension.openingMonth;

  // Lignes élémentaires : (k1, k2, fait, ouverture éventuelle).
  final groups = <(String, String?), _Acc>{};
  final all = _Acc();
  for (final f in facts.where(kept)) {
    final openings = byOpening || q.measure == StatMeasure.opened
        ? [
            for (final o in f.openings)
              if (o.$1.compareTo(from) >= 0 &&
                  o.$1.compareTo(to) <= 0 &&
                  (openingFilter.isEmpty || openingFilter.contains(o.$1)))
                o,
          ]
        : const <(String, int)>[];
    if (byOpening) {
      for (final o in openings) {
        String k(StatDimension d) =>
            d == StatDimension.openingMonth ? o.$1 : keyOf(f, d, year);
        final key = (k(q.dim1), q.dim2 == null ? null : k(q.dim2!));
        groups.putIfAbsent(key, _Acc.new).addOpening(f, o.$2);
        all.addOpening(f, o.$2);
      }
      continue;
    }
    final key = (
      keyOf(f, q.dim1, year),
      q.dim2 == null ? null : keyOf(f, q.dim2!, year),
    );
    final acc = groups.putIfAbsent(key, _Acc.new);
    acc.add(f, year, openings);
    all.add(f, year, openings);
  }

  final cells = <StatCell>[
    for (final e in groups.entries)
      if (e.value.hasData(q.measure))
        StatCell(
          e.key.$1,
          e.key.$2,
          e.value.value(q.measure),
          e.value.winesFor(q.measure),
        ),
  ];
  List<String> order(Iterable<String> keys, StatDimension d, int index) {
    final list = keys.toSet().toList();
    if (d.ordered) {
      list.sort((a, b) {
        if (a == noneKey) return 1;
        if (b == noneKey) return -1;
        return a.compareTo(b);
      });
    } else {
      double sum(String k) => cells
          .where((c) => (index == 1 ? c.k1 : c.k2) == k)
          .fold(0.0, (s, c) => s + c.value);
      list.sort((a, b) {
        if (a == noneKey) return 1;
        if (b == noneKey) return -1;
        return sum(b).compareTo(sum(a));
      });
    }
    return list;
  }

  return StatResult(
    cells: cells,
    keys1: order(cells.map((c) => c.k1), q.dim1, 1),
    keys2: q.dim2 == null
        ? const []
        : order(cells.map((c) => c.k2!), q.dim2!, 2),
    total: all.value(q.measure),
    wineIds: all.winesFor(q.measure),
  );
}

/// STA-03 : au plus [max] parts, les plus petites regroupées en « Autres ».
StatResult topParts(StatResult r, {int max = donutMaxParts}) {
  if (r.keys1.length <= max) return r;
  final kept = r.keys1.take(max - 1).toSet();
  final rest = r.cells.where((c) => !kept.contains(c.k1)).toList();
  return StatResult(
    cells: [
      ...r.cells.where((c) => kept.contains(c.k1)),
      StatCell(otherKey, null, rest.fold(0.0, (s, c) => s + c.value), {
        for (final c in rest) ...c.wineIds,
      }),
    ],
    keys1: [...r.keys1.take(max - 1), otherKey],
    keys2: r.keys2,
    total: r.total,
    wineIds: r.wineIds,
  );
}

class _Acc {
  int bottles = 0;
  final stocked = <String>{};
  final touched = <String>{};
  double purchase = 0;
  int pricedBottles = 0;
  final pricedWines = <String>{};
  double market = 0;
  final marketWines = <String>{};
  double gainPurchase = 0;
  double gainMarket = 0;
  final gainWines = <String>{};
  final scores = <String, double>{};
  int opened = 0;
  final openedWines = <String>{};
  double yearsSum = 0;
  int yearsBottles = 0;
  final yearsWines = <String>{};

  void add(StatFact f, int year, List<(String, int)> openings) {
    touched.add(f.wineId);
    final q = math.max(0, f.bottles);
    bottles += q;
    if (q > 0) {
      stocked.add(f.wineId);
      if (f.unitPrice != null) {
        purchase += q * f.unitPrice!;
        pricedBottles += q;
        pricedWines.add(f.wineId);
      }
      if (f.marketPrice != null) {
        market += q * f.marketPrice!;
        marketWines.add(f.wineId);
      }
      if (f.unitPrice != null && f.marketPrice != null) {
        gainPurchase += q * f.unitPrice!;
        gainMarket += q * f.marketPrice!;
        gainWines.add(f.wineId);
      }
      if (f.score100 != null) scores[f.wineId] = f.score100!;
      if (f.gardeStart != null) {
        yearsSum += q * math.max(0, f.gardeStart! - year);
        yearsBottles += q;
        yearsWines.add(f.wineId);
      }
    }
    for (final o in openings) {
      addOpening(f, o.$2);
    }
  }

  void addOpening(StatFact f, int n) {
    opened += n;
    openedWines.add(f.wineId);
  }

  bool hasData(StatMeasure m) => switch (m) {
    StatMeasure.bottles || StatMeasure.references => stocked.isNotEmpty,
    StatMeasure.purchaseValue || StatMeasure.averagePrice => pricedBottles > 0,
    StatMeasure.marketValue => marketWines.isNotEmpty,
    StatMeasure.gain => gainWines.isNotEmpty,
    StatMeasure.averageScore => scores.isNotEmpty,
    StatMeasure.opened => opened > 0,
    StatMeasure.yearsBefore => yearsBottles > 0,
  };

  double value(StatMeasure m) => switch (m) {
    StatMeasure.bottles => bottles.toDouble(),
    StatMeasure.references => stocked.length.toDouble(),
    StatMeasure.purchaseValue => purchase,
    StatMeasure.marketValue => market,
    StatMeasure.gain => gainMarket - gainPurchase,
    StatMeasure.averagePrice =>
      pricedBottles == 0 ? 0 : purchase / pricedBottles,
    StatMeasure.averageScore =>
      scores.isEmpty
          ? 0
          : scores.values.fold(0.0, (s, v) => s + v) / scores.length,
    StatMeasure.opened => opened.toDouble(),
    StatMeasure.yearsBefore => yearsBottles == 0 ? 0 : yearsSum / yearsBottles,
  };

  Set<String> winesFor(StatMeasure m) => switch (m) {
    StatMeasure.purchaseValue || StatMeasure.averagePrice => pricedWines,
    StatMeasure.marketValue => marketWines,
    StatMeasure.gain => gainWines,
    StatMeasure.averageScore => scores.keys.toSet(),
    StatMeasure.opened => openedWines,
    StatMeasure.yearsBefore => yearsWines,
    _ => stocked,
  };
}

/// STA-01 (Valeur) : valeur marché du stock actuel à la fin de chacun des
/// [months] derniers mois, d'après le dernier relevé connu à cette date.
List<(String, double)> marketValueHistory(
  List<StatFact> facts, {
  required DateTime now,
  int months = 24,
}) {
  final out = <(String, double)>[];
  for (var i = months - 1; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i);
    final key = _month(m);
    final end = '$key-31';
    var total = 0.0;
    for (final f in facts) {
      if (f.bottles <= 0) continue;
      double? price;
      for (final (date, p) in f.priceHistory) {
        if (date.compareTo(end) <= 0) price = p;
      }
      if (price != null) total += f.bottles * price;
    }
    out.add((key, total));
  }
  return out;
}

/// STA-01 (Aide à l'achat) : mois de stock restant au rythme des ouvertures
/// des 12 derniers mois ; null si rien n'a été ouvert.
double? monthsOfStock({required double stock, required double opened12}) =>
    opened12 <= 0 ? null : stock / (opened12 / 12);
