/// Lot 4, confort : vins à boire (CMP-01), vins passés (CMP-09), accords
/// inversés (CMP-04) et alerte du mois (CMP-02), en fonctions pures.
library;

import 'garde.dart';
import 'wine_detail.dart';
import 'wine_list_item.dart';

/// Statuts d'un vin dans sa fenêtre de garde.
const drinkable = {
  CellarStatus.toDrink,
  CellarStatus.peak,
  CellarStatus.drinkSoon,
};

/// CMP-01 : vins en stock dans leur fenêtre, `a_boire_vite` en tête, puis
/// par fin de fenêtre la plus proche.
List<WineListItem> toDrinkList(Iterable<WineListItem> items, int year) {
  final list = [
    for (final w in items)
      if (w.bottles > 0 && drinkable.contains(w.statusIn(year))) w,
  ];
  list.sort((a, b) {
    final soonA = a.statusIn(year) == CellarStatus.drinkSoon ? 0 : 1;
    final soonB = b.statusIn(year) == CellarStatus.drinkSoon ? 0 : 1;
    if (soonA != soonB) return soonA.compareTo(soonB);
    final end = (a.gardeEnd ?? 9999).compareTo(b.gardeEnd ?? 9999);
    if (end != 0) return end;
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
  return list;
}

/// CMP-09 : vins en stock dont la fenêtre de garde est dépassée, à part des
/// vins à boire. Fin de fenêtre la plus ancienne en tête, puis par nom.
List<WineListItem> pastList(Iterable<WineListItem> items, int year) {
  final list = [
    for (final w in items)
      if (w.bottles > 0 && w.statusIn(year) == CellarStatus.past) w,
  ];
  list.sort((a, b) {
    final end = (a.gardeEnd ?? 0).compareTo(b.gardeEnd ?? 0);
    if (end != 0) return end;
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
  return list;
}

/// CMP-04 : vins en stock, à boire, dont les accords contiennent le plat.
List<WineListItem> winesForDish(
  Iterable<WineListItem> items,
  String dish,
  int year,
) => toDrinkList(items.where((w) => w.pairings.contains(dish)), year);

/// Plats proposés : ceux que portent au moins un vin à boire.
Set<String> dishesAvailable(Iterable<WineListItem> items, int year) => {
  for (final w in toDrinkList(items, year)) ...w.pairings,
};

/// CMP-02 : vins qui entrent en apogée cette année, ou dans la dernière
/// période de leur fenêtre (`a_boire_vite`).
class MonthlyAlert {
  const MonthlyAlert({required this.peak, required this.ending});

  final List<WineListItem> peak;
  final List<WineListItem> ending;

  bool get isEmpty => peak.isEmpty && ending.isEmpty;

  int get count =>
      {...peak.map((w) => w.id), ...ending.map((w) => w.id)}.length;

  Set<String> get ids => {...peak.map((w) => w.id), ...ending.map((w) => w.id)};
}

MonthlyAlert monthlyAlert(Iterable<WineListItem> items, int year) {
  final stocked = items.where((w) => w.bottles > 0).toList();
  return MonthlyAlert(
    peak: [
      for (final w in stocked)
        if (w.gardePeak == year) w,
    ],
    ending: toDrinkList(
      stocked.where((w) => w.statusIn(year) == CellarStatus.drinkSoon),
      year,
    ),
  );
}

/// Mois de l'alerte (AAAA-MM) : une fois par mois, au premier lancement.
String alertMonth(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

/// L'alerte s'affiche si elle n'a pas encore été vue ce mois-ci.
bool alertDue({
  required bool enabled,
  required String? dismissedMonth,
  required DateTime now,
  required MonthlyAlert alert,
}) => enabled && !alert.isEmpty && dismissedMonth != alertMonth(now);

/// EMP-02, EMP-03 : cellules d'une liste de positions « A3, B5 ».
List<String> parsePositions(String? positions) => [
  for (final p in (positions ?? '').split(RegExp(r'[,;\s]+')))
    if (RegExp(r'^[A-Z]\d{1,2}$').hasMatch(p.trim().toUpperCase()))
      p.trim().toUpperCase(),
];

/// Nom d'une cellule de grille : ligne (A à Z) et colonne (1 à 50).
String cellName(int row, int col) =>
    '${String.fromCharCode(65 + row)}${col + 1}';

/// Bouteilles d'un lot qui n'ont pas encore de case.
int lotUnplaced(LocationLot lot) {
  final n = lot.bottles - parsePositions(lot.positions).length;
  return n < 0 ? 0 : n;
}

/// EMP-03 : bouteilles rangées dans le casier sans case attribuée.
int unplacedBottles(Iterable<LocationLot> lots) =>
    lots.fold(0, (sum, lot) => sum + lotUnplaced(lot));

/// EMP-03 : candidats pour une case vide. D'abord les lots de ce casier qui
/// ont des bouteilles sans case, puis les lots en stock ailleurs (déplacés
/// d'une bouteille par transfert, STK-05).
({List<LocationLot> here, List<LocationLot> elsewhere}) placementCandidates(
  Iterable<LocationLot> stocked,
  String locationId,
) => (
  here: [
    for (final lot in stocked)
      if (lot.locationId == locationId && lotUnplaced(lot) > 0) lot,
  ],
  elsewhere: [
    for (final lot in stocked)
      if (lot.locationId != locationId && lot.bottles > 0) lot,
  ],
);
