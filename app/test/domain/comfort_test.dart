import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/comfort.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/domain/wine_list_item.dart';

WineListItem wine(
  String id, {
  int bottles = 3,
  int? start,
  int? peak,
  int? end,
  List<String> pairings = const [],
}) => WineListItem(
  id: id,
  producer: id,
  vintage: '2015',
  colorCode: 'rouge',
  countryCode: 'FR',
  bottles: bottles,
  gardeStart: start,
  gardePeak: peak,
  gardeEnd: end,
  pairings: pairings,
);

LocationLot lot(
  String id, {
  String? location = 'casier',
  int bottles = 2,
  String? positions,
}) => LocationLot(
  lotId: id,
  wineId: 'w-$id',
  wineName: id,
  vintage: '2015',
  colorCode: 'rouge',
  locationId: location,
  ownerName: 'Bertrand',
  ownerId: 'o1',
  bottles: bottles,
  positions: positions,
);

void main() {
  const year = 2026;
  final cave = [
    wine('jeune', start: 2030, end: 2040),
    wine('garde', start: 2020, end: 2035),
    wine('proche', start: 2018, end: 2030),
    wine('vite-b', start: 2015, end: 2027),
    wine('vite-a', start: 2015, end: 2026),
    wine('apogee', start: 2020, peak: 2026, end: 2032),
    wine('vide', bottles: 0, start: 2020, end: 2030),
    wine('inconnu'),
    wine('passe', start: 2010, end: 2020),
  ];

  test('CMP-01 à boire : fenêtre ouverte, à boire vite en tête, puis fin '
      'de fenêtre la plus proche', () {
    expect(toDrinkList(cave, year).map((w) => w.id), [
      'vite-a',
      'vite-b',
      'proche',
      'apogee',
      'garde',
    ]);
  });

  test('CMP-09 vins passés : en stock, fenêtre dépassée, à part des vins '
      'à boire, fin la plus ancienne en tête', () {
    final avecPasses = [
      ...cave,
      wine('passe-ancien', start: 2000, end: 2012),
      wine('passe-vide', bottles: 0, start: 2000, end: 2010),
      wine('fin-annee-derniere', start: 2015, end: 2025),
    ];
    expect(pastList(avecPasses, year).map((w) => w.id), [
      'passe-ancien',
      'passe',
      'fin-annee-derniere',
    ]);
    final aBoire = toDrinkList(avecPasses, year).map((w) => w.id).toSet();
    expect(
      aBoire.intersection({'passe-ancien', 'passe', 'fin-annee-derniere'}),
      isEmpty,
    );
    // Fin de fenêtre cette année : encore à boire, pas passé.
    expect(
      pastList([wine('fin-cette-annee', start: 2015, end: 2026)], year),
      isEmpty,
    );
  });

  test('CMP-04 accords inversés : vins à boire qui portent le plat', () {
    final items = [
      wine('a', start: 2020, end: 2035, pairings: ['gibier', 'fromage']),
      wine('b', start: 2020, end: 2027, pairings: ['gibier']),
      wine('c', start: 2030, end: 2040, pairings: ['gibier']),
      wine('d', bottles: 0, start: 2020, end: 2035, pairings: ['poisson']),
    ];
    expect(winesForDish(items, 'gibier', year).map((w) => w.id), ['b', 'a']);
    expect(winesForDish(items, 'poisson', year), isEmpty);
    expect(dishesAvailable(items, year), {'gibier', 'fromage'});
  });

  test('CMP-02 alerte du mois : apogée cette année et à boire vite', () {
    final alert = monthlyAlert(cave, year);
    expect(alert.peak.map((w) => w.id), ['apogee']);
    expect(alert.ending.map((w) => w.id), ['vite-a', 'vite-b']);
    expect(alert.count, 3);
    expect(alertMonth(DateTime(2026, 3, 1)), '2026-03');
    final now = DateTime(2026, 10, 27);
    expect(
      alertDue(enabled: true, dismissedMonth: null, now: now, alert: alert),
      isTrue,
    );
    expect(
      alertDue(
        enabled: true,
        dismissedMonth: '2026-10',
        now: now,
        alert: alert,
      ),
      isFalse,
    );
    expect(
      alertDue(
        enabled: true,
        dismissedMonth: '2026-09',
        now: now,
        alert: alert,
      ),
      isTrue,
    );
    expect(
      alertDue(enabled: false, dismissedMonth: null, now: now, alert: alert),
      isFalse,
    );
    expect(
      alertDue(
        enabled: true,
        dismissedMonth: null,
        now: now,
        alert: monthlyAlert([wine('jeune', start: 2030, end: 2040)], year),
      ),
      isFalse,
    );
  });

  test('EMP-03 positions et noms de cases', () {
    expect(parsePositions('a3, B5;C12  zz 7'), ['A3', 'B5', 'C12']);
    expect(parsePositions(null), isEmpty);
    expect(cellName(0, 0), 'A1');
    expect(cellName(2, 11), 'C12');
  });

  test(
    'EMP-03 candidats : lots du casier sans case, puis lots d\'ailleurs',
    () {
      final stocked = [
        lot('plein', positions: 'A1, A2'),
        lot('partiel', bottles: 3, positions: 'B1'),
        lot('cave', location: 'cave'),
        lot('sans-emplacement', location: null),
      ];
      final c = placementCandidates(stocked, 'casier');
      expect(c.here.map((x) => x.lotId), ['partiel']);
      expect(c.elsewhere.map((x) => x.lotId), ['cave', 'sans-emplacement']);
      expect(unplacedBottles(stocked.take(2)), 2);
    },
  );
}
