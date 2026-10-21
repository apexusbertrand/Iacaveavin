import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/features/wine_list/wine_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

Future<void> seedTwo(db, String cellar) async {
  final ref = ReferenceRepository(db);
  final owner = await ref.saveOwner(
    cellarId: cellar,
    name: 'Bertrand',
    isDefault: true,
  );
  await ref.saveOwner(cellarId: cellar, name: 'Julie');
  await ref.saveLocation(cellarId: cellar, name: 'Cave', type: 'cave');
  final repo = CellarRepository(db);
  await repo.createWine(
    const WineDraft(
      producer: 'Château Bralmac',
      country: 'FR',
      region: 'fr-bordeaux',
      appellation: 'fr-pauillac',
      color: 'rouge',
      vintage: '2015',
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: owner, quantity: 3, unitPrice: 40),
  );
  await repo.createWine(
    const WineDraft(
      producer: 'Domaine Corvizac',
      country: 'FR',
      region: 'fr-bourgogne',
      appellation: 'fr-chablis',
      color: 'blanc',
      vintage: '2022',
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: owner, quantity: 2),
  );
}

void main() {
  testWidgets('FIC-01 PRX-01 saisie manuelle d\'un vin avec son premier lot', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.byTooltip('Ajouter une bouteille'));
    await settle(tester);
    expect(find.text('Nouveau vin'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('field-producer')),
      'Mas Talvombe',
    );
    await tester.enterText(find.byKey(const ValueKey('field-vintage')), '2019');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('lot-price')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const ValueKey('lot-quantity')), '4');
    await tester.enterText(find.byKey(const ValueKey('lot-price')), '18,50');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-wine')));
    await settle(tester);
    expect(find.text('MAS TALVOMBE'), findsOneWidget);
    expect(find.text('4 restantes · 0 consommée'), findsOneWidget);
  });

  testWidgets('FIC-01 contrôle de saisie : millésime invalide refusé', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/fiche/nouvelle', seed: seedTwo);
    await tester.enterText(find.byKey(const ValueKey('field-producer')), 'X');
    await tester.enterText(find.byKey(const ValueKey('field-vintage')), '3000');
    await tester.tap(find.byKey(const ValueKey('save-wine')));
    await settle(tester);
    expect(
      find.text("Millésime entre 1900 et l'année en cours, ou NM"),
      findsOneWidget,
    );
  });

  testWidgets('STK-01 STK-02 FIC-03 ouvrir une bouteille depuis la fiche', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.text('Château Bralmac'));
    await settle(tester);
    expect(find.text('3 restantes · 0 consommée'), findsOneWidget);
    await tester.tap(find.text('Ouvrir 1 bouteille'));
    await settle(tester);
    // STK-02 : la note de dégustation est proposée, jamais imposée.
    expect(find.text('Noter cette dégustation ?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Annuler'),
      ),
    );
    await settle(tester);
    expect(find.text('2 restantes · 1 consommée'), findsOneWidget);
    await tester.ensureVisible(find.text('Opérations'));
    await tester.tap(find.text('Opérations'));
    await settle(tester);
    expect(find.text('Ouverture · -1'), findsOneWidget);
    expect(find.text('Entrée · +3'), findsOneWidget);
  });

  testWidgets('FIC-01 PRO-02 onglet Informations : origine et propriétaires', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.text('Château Bralmac'));
    await settle(tester);
    expect(find.text('Pauillac'), findsWidgets);
    await tester.dragUntilVisible(
      find.text('Bertrand 3'),
      find.byType(TabBarView),
      const Offset(0, -200),
    );
    expect(find.text('Bertrand 3'), findsOneWidget);
    expect(find.text('-'), findsWidgets, reason: 'champ vide : un tiret');
    await tester.ensureVisible(find.text('Prix'));
    await tester.tap(find.text('Prix'));
    await settle(tester);
    expect(find.textContaining('40,00'), findsWidgets);
  });

  testWidgets('LST-06 recherche instantanée depuis la barre', (tester) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.byTooltip('Rechercher'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'chablis',
    );
    await settle(tester);
    expect(find.byType(WineCard), findsOneWidget);
    expect(find.text('Domaine Corvizac'), findsOneWidget);
  });

  testWidgets('LST-01 LST-09 tri choisi puis mémorisé', (tester) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.byKey(const ValueKey('sort-chip')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('sort1')).first);
    await settle(tester);
    // Le menu déroulant montre chaque critère traduit.
    await tester.tap(find.text('Domaine').last);
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('sort-apply')));
    await settle(tester);
    // Le sens du tri précédent (millésime décroissant) est conservé.
    expect(find.text('Tri 1 : Domaine (Z-A)'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('reglages_v1')!) as Map;
    expect(((saved['listQuery'] as Map)['sort1'] as Map)['c'], 'producer');
    final names = tester
        .widgetList<WineCard>(find.byType(WineCard))
        .map((c) => c.item.producer);
    expect(names, ['Domaine Corvizac', 'Château Bralmac']);
  });

  testWidgets('LST-05 filtre couleur appliqué et supprimable en chip', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seedTwo);
    await tester.tap(find.byTooltip('Filtrer'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Blanc'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('filters-apply')));
    await settle(tester);
    expect(find.byType(WineCard), findsOneWidget);
    expect(find.text('1 filtre actif'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reset-filters')));
    await settle(tester);
    expect(find.byType(WineCard), findsNWidgets(2));
  });

  testWidgets('LST-07 vue compacte et LST-10 compteur', (tester) async {
    await pumpRealApp(tester, seed: seedTwo);
    expect(find.text('2 vins · 5 bouteilles'), findsOneWidget);
    await tester.tap(find.byTooltip('Vue compacte'));
    await settle(tester);
    expect(find.byType(CompactWineRow), findsNWidgets(2));
    expect(find.byType(WineCard), findsNothing);
  });

  testWidgets('LST-08 sélection multiple et changement de propriétaire', (
    tester,
  ) async {
    final db = await pumpRealApp(tester, seed: seedTwo);
    await tester.longPress(find.text('Château Bralmac'));
    await tester.pump();
    await tester.tap(find.text('Domaine Corvizac'));
    await tester.pump();
    expect(find.text('2 sélectionnés'), findsOneWidget);
    await tester.tap(find.byTooltip('Changer de propriétaire'));
    await settle(tester);
    await tester.tap(find.text('Julie'));
    await settle(tester);
    expect(find.text('2 fiches mises à jour'), findsOneWidget);
    final items = await tester.runAsync(() => CellarRepository(db).wineItems());
    expect(items!.every((w) => w.mainOwner == 'Julie'), isTrue);
  });

  testWidgets('STK-07 glisser pour ouvrir, puis annuler', (tester) async {
    final db = await pumpRealApp(tester, seed: seedTwo);
    await tester.drag(find.text('Domaine Corvizac'), const Offset(-500, 0));
    await settle(tester);
    expect(find.textContaining('1 bouteille ouverte'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    final items = await tester.runAsync(() => CellarRepository(db).wineItems());
    expect(
      items!.firstWhere((w) => w.producer == 'Domaine Corvizac').bottles,
      2,
    );
  });
}
