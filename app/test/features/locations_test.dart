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

Future<void> seed(AppDatabase db, String cellar) async {
  final ref = ReferenceRepository(db);
  final owner = await ref.saveOwner(
    cellarId: cellar,
    name: 'Bertrand',
    isDefault: true,
  );
  final cave = await ref.saveLocation(
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
}
