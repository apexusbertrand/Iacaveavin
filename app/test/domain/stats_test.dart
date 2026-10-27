import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/stats.dart';

StatFact fact(
  String wine,
  int bottles, {
  String lot = '',
  String color = 'rouge',
  String vintage = '2015',
  String owner = 'o1',
  double? price,
  double? market,
  double? score,
  int? start,
  int? peak,
  int? end,
  List<(String, int)> openings = const [],
}) => StatFact(
  wineId: wine,
  lotId: lot.isEmpty ? '$wine-l' : lot,
  bottles: bottles,
  keys: {
    StatDimension.color: color,
    StatDimension.vintage: vintage,
    StatDimension.owner: owner,
    StatDimension.country: 'FR',
  },
  unitPrice: price,
  marketPrice: market,
  score100: score,
  gardeStart: start,
  gardePeak: peak,
  gardeEnd: end,
  openings: openings,
);

final now = DateTime(2026, 10, 27);

StatResult run(
  List<StatFact> facts,
  StatMeasure m,
  StatDimension d1, [
  StatDimension? d2,
  Map<StatDimension, Set<String>> filters = const {},
]) => aggregate(
  facts,
  StatQuery(measure: m, dim1: d1, dim2: d2, filters: filters),
  year: 2026,
  now: now,
);

void main() {
  final facts = [
    fact('a', 6, price: 20, market: 30, score: 92, start: 2028, end: 2040),
    fact('a', 2, lot: 'a-2', owner: 'o2', price: 25),
    fact(
      'b',
      3,
      color: 'blanc',
      vintage: '2020',
      market: 15,
      score: 88,
      start: 2024,
    ),
    fact('c', 0, color: 'blanc', openings: [('2026-09', 2), ('2024-01', 5)]),
  ];

  test(
    'STA-02 mesures : bouteilles, références, valeurs, moyennes, ouvertures',
    () {
      expect(run(facts, StatMeasure.bottles, StatDimension.color).total, 11);
      final bottles = run(facts, StatMeasure.bottles, StatDimension.color);
      expect(bottles.valueOf('rouge'), 8);
      expect(bottles.valueOf('blanc'), 3);
      expect(run(facts, StatMeasure.references, StatDimension.color).total, 2);
      expect(
        run(facts, StatMeasure.purchaseValue, StatDimension.color).total,
        6 * 20 + 2 * 25,
      );
      expect(
        run(facts, StatMeasure.marketValue, StatDimension.color).total,
        6 * 30 + 3 * 15,
      );
      // Plus-value : seulement les lots qui ont les deux prix.
      expect(
        run(facts, StatMeasure.gain, StatDimension.color).total,
        6 * (30 - 20),
      );
      expect(
        run(facts, StatMeasure.averagePrice, StatDimension.color).total,
        closeTo((6 * 20 + 2 * 25) / 8, 1e-9),
      );
      expect(
        run(facts, StatMeasure.averageScore, StatDimension.color).total,
        90,
      );
      // Ouvertures des 12 derniers mois seulement.
      expect(run(facts, StatMeasure.opened, StatDimension.color).total, 2);
      // Années avant de boire, pondérées par les bouteilles : (6×2 + 3×0) / 9.
      expect(
        run(facts, StatMeasure.yearsBefore, StatDimension.color).total,
        closeTo(12 / 9, 1e-9),
      );
    },
  );

  test(
    'STA-02 dimensions : tranches, statut de garde, mois d\'ouverture, filtres',
    () {
      final bands = run(facts, StatMeasure.bottles, StatDimension.vintageBand);
      expect(bands.keys1, ['2015', '2020']);
      final status = run(facts, StatMeasure.bottles, StatDimension.gardeStatus);
      expect(status.valueOf('trop_jeune'), 6);
      expect(status.valueOf('inconnu'), 2 + 3);
      final months = run(facts, StatMeasure.opened, StatDimension.openingMonth);
      expect(months.keys1, ['2026-09']);
      final crossed = run(
        facts,
        StatMeasure.bottles,
        StatDimension.color,
        StatDimension.owner,
      );
      expect(crossed.valueOf('rouge', 'o2'), 2);
      expect(crossed.keys2, ['o1', 'o2']);
      final filtered = run(
        facts,
        StatMeasure.bottles,
        StatDimension.color,
        null,
        {
          StatDimension.owner: {'o2'},
        },
      );
      expect(filtered.total, 2);
    },
  );

  test('STA-03 graphiques compatibles seulement ; donut à 8 parts au plus', () {
    expect(compatibleCharts(StatMeasure.bottles, StatDimension.color, null), [
      StatChart.donut,
      StatChart.barsVertical,
      StatChart.barsHorizontal,
      StatChart.kpi,
    ]);
    expect(
      compatibleCharts(StatMeasure.bottles, StatDimension.vintage, null),
      contains(StatChart.line),
    );
    expect(
      compatibleCharts(StatMeasure.averagePrice, StatDimension.color, null),
      isNot(contains(StatChart.donut)),
    );
    expect(
      compatibleCharts(
        StatMeasure.bottles,
        StatDimension.color,
        StatDimension.owner,
      ),
      [StatChart.stacked, StatChart.crossTable, StatChart.kpi],
    );
    final many = [
      for (var i = 0; i < 12; i++) fact('w$i', 12 - i, vintage: '${2000 + i}'),
    ];
    final donut = topParts(
      run(many, StatMeasure.bottles, StatDimension.vintage),
    );
    expect(donut.keys1, hasLength(donutMaxParts));
    expect(donut.keys1.last, otherKey);
    expect(donut.valueOf(otherKey), 5 + 4 + 3 + 2 + 1);
    expect(donut.cell(otherKey)!.wineIds, hasLength(5));
  });

  test('STA-04 chaque part porte les fiches de la liste filtrée', () {
    final r = run(facts, StatMeasure.bottles, StatDimension.color);
    expect(r.cell('rouge')!.wineIds, {'a'});
    expect(r.cell('blanc')!.wineIds, {'b'});
  });

  test('STA-01 valeur marché dans le temps et mois de stock restant', () {
    final history = marketValueHistory(
      [
        StatFact(
          wineId: 'a',
          lotId: 'l',
          bottles: 4,
          keys: const {},
          priceHistory: const [('2026-01-10', 20), ('2026-06-02', 30)],
        ),
      ],
      now: now,
      months: 12,
    );
    expect(history.first, ('2025-11', 0.0));
    expect(history.firstWhere((h) => h.$1 == '2026-03').$2, 80);
    expect(history.last, ('2026-10', 120.0));
    expect(monthsOfStock(stock: 24, opened12: 12), 24);
    expect(monthsOfStock(stock: 5, opened12: 0), isNull);
  });

  test('STA-06 calcul en moins d\'une seconde pour 5 000 fiches', () {
    final big = [
      for (var i = 0; i < 5000; i++)
        fact(
          'w$i',
          1 + i % 12,
          color: ['rouge', 'blanc', 'rose'][i % 3],
          vintage: '${1990 + i % 35}',
          owner: 'o${i % 4}',
          price: 10.0 + i % 90,
          market: 12.0 + i % 80,
          score: 80.0 + i % 20,
          start: 2020 + i % 15,
          openings: [('2026-0${1 + i % 9}', i % 3)],
        ),
    ];
    final watch = Stopwatch()..start();
    for (final m in StatMeasure.values) {
      run(big, m, StatDimension.vintage, StatDimension.color);
    }
    watch.stop();
    expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
