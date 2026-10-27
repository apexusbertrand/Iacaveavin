import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../fakes.dart';

late String wineId;
late String casierId;
late String caveWineId;
late String caveId;
late String ownerId;

Future<void> seed(AppDatabase db, String cellar) async {
  final ref = ReferenceRepository(db);
  final owner = ownerId = await ref.saveOwner(
    cellarId: cellar,
    name: 'Bertrand',
    isDefault: true,
  );
  final cave = caveId = await ref.saveLocation(
    cellarId: cellar,
    name: 'Cave',
    type: 'cave',
  );
  final casier = casierId = await ref.saveLocation(
    id: null,
    cellarId: cellar,
    name: 'Casier A',
    type: 'casier',
    parentId: cave,
    rows: 2,
    cols: 2,
  );
  final repo = CellarRepository(db);
  wineId = await repo.createWine(
    const WineDraft(
      producer: 'Clos Lune',
      country: 'FR',
      color: 'rouge',
      vintage: '2018',
    ),
    cellarId: cellar,
    lot: LotDraft(
      ownerId: owner,
      quantity: 5,
      locationId: casier,
      positions: 'A1, B2',
    ),
  );
}

/// EMP-03 : un second vin rangé dans la cave, hors du casier.
Future<void> seedGrid(AppDatabase db, String cellar) async {
  await seed(db, cellar);
  caveWineId = await CellarRepository(db).createWine(
    const WineDraft(
      producer: 'Mas Blanc',
      country: 'FR',
      color: 'blanc',
      vintage: '2021',
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: ownerId, quantity: 3, locationId: caveId),
  );
}

void main() {
  testWidgets('EMP-01 EMP-05 arbre, remplissage et alerte de capacité', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/emplacements', seed: seed);
    expect(find.text('Cave'), findsOneWidget);
    expect(find.text('Casier A'), findsOneWidget);
    expect(find.textContaining('5 / 4 · 125 %'), findsOneWidget);
    expect(find.text('Au-delà de la capacité'), findsOneWidget);
  });

  testWidgets('EMP-01 ajouter un emplacement depuis l\'écran', (tester) async {
    await pumpRealApp(tester, location: '/emplacements', seed: seed);
    await tester.tap(find.byTooltip('Ajouter un emplacement'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('location-name')),
      'Cellier',
    );
    await tester.tap(find.byKey(const ValueKey('location-save')));
    await settle(tester);
    expect(find.text('Cellier'), findsOneWidget);
  });

  testWidgets('EMP-04 « Où est-il ? » : positions du vin mises en évidence', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seed);
    // La fiche montre l'emplacement avec un chevron vers l'emplacement.
    await tester.tap(find.text('Clos Lune'));
    await settle(tester);
    await tester.dragUntilVisible(
      find.text('Cave > Casier A'),
      find.byType(TabBarView),
      const Offset(0, -150),
    );
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
  });

  testWidgets('EMP-04 l\'emplacement ouvert depuis la fiche surligne le vin', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/', seed: seed);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.push('/emplacements/$casierId?fiche=$wineId');
    await settle(tester);
    expect(find.text('Positions de ce vin : A1, B2'), findsOneWidget);
    expect(find.text('Clos Lune · 2018'), findsOneWidget);
  });

  testWidgets('STK-04 inventaire : correction et rapport des écarts', (
    tester,
  ) async {
    final db = await pumpRealApp(tester, location: '/inventaire', seed: seed);
    expect(find.text('0 / 1 lots vérifiés'), findsOneWidget);
    await tester.tap(find.byTooltip('Corriger'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('inventory-quantity')),
      '3',
    );
    await tester.tap(find.byKey(const ValueKey('inventory-save')));
    await settle(tester);
    expect(find.text('1 / 1 lots vérifiés'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('inventory-next')));
    await settle(tester);
    expect(find.text('1 écart corrigé'), findsOneWidget);
    expect(find.text('Clos Lune · 2018 : 5 → 3'), findsOneWidget);
    final d = await tester.runAsync(() => CellarRepository(db).wine(wineId));
    expect(d!.bottles, 3);
    expect(d.movements.first.reason, 'inventaire');
  });

  testWidgets('EMP-03 vue casier : cases occupées, tap vers la fiche, '
      'rangement par appui long', (tester) async {
    final db = await pumpRealApp(tester, location: '/', seed: seedGrid);
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .push('/emplacements/$casierId');
    await settle(tester);
    expect(find.text('Vue casier'), findsOneWidget);
    expect(find.text('3 bouteilles sans case'), findsOneWidget);
    for (final c in ['A1', 'A2', 'B1', 'B2']) {
      expect(find.byKey(ValueKey('cell-$c')), findsOneWidget);
    }
    expect(
      tester.getSemantics(find.byKey(const ValueKey('cell-A1'))).label,
      contains('Clos Lune'),
    );

    // Appui long sur une case vide : d'abord les lots du casier.
    await tester.longPress(find.byKey(const ValueKey('cell-A2')));
    await settle(tester);
    expect(find.text('Ranger en A2'), findsOneWidget);
    expect(find.text('Déjà dans ce casier, sans case'), findsOneWidget);
    expect(find.text("Venant d'un autre emplacement"), findsOneWidget);
    await tester.tap(find.text('Clos Lune · 2018').last);
    await settle(tester);
    expect(find.text('Bouteille rangée en A2'), findsOneWidget);
    expect(find.text('2 bouteilles sans case'), findsOneWidget);
    var lots = await tester.runAsync(() => CellarRepository(db).stockedLots());
    expect(lots!.firstWhere((x) => x.wineId == wineId).positions, 'A1, B2, A2');

    // Puis un lot d'ailleurs : transfert d'une bouteille.
    await tester.longPress(find.byKey(const ValueKey('cell-B1')));
    await settle(tester);
    await tester.tap(find.text('Mas Blanc · 2021'));
    await settle(tester);
    lots = await tester.runAsync(() => CellarRepository(db).stockedLots());
    final moved = lots!.where((x) => x.wineId == caveWineId).toList();
    expect(moved.map((x) => x.bottles).toSet(), {2, 1});
    expect(moved.firstWhere((x) => x.bottles == 1).positions, 'B1');
    expect(moved.firstWhere((x) => x.bottles == 1).locationId, casierId);

    // Tap sur une case occupée : la fiche.
    await tester.tap(find.byKey(const ValueKey('cell-B1')));
    await settle(tester);
    expect(find.byKey(const ValueKey('wine-menu')), findsOneWidget);
  });
}
