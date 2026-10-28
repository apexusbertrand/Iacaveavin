import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/comfort_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/export_providers.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/features/wine_detail/share_sheet.dart';

import '../fakes.dart';

late String viteId;
late String apogeeId;

Future<void> seedComfort(AppDatabase db, String cellar) async {
  final ref = ReferenceRepository(db);
  final owner = await ref.saveOwner(
    cellarId: cellar,
    name: 'Bertrand',
    isDefault: true,
  );
  final repo = CellarRepository(db);
  viteId = await repo.createWine(
    const WineDraft(
      producer: 'Clos Vite',
      country: 'FR',
      color: 'rouge',
      vintage: '2015',
      gardeStart: 2018,
      gardeEnd: 2027,
      pairings: ['gibier-a-poil'],
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: owner, quantity: 1),
  );
  apogeeId = await repo.createWine(
    const WineDraft(
      producer: 'Mas Apogee',
      country: 'FR',
      color: 'rouge',
      vintage: '2018',
      gardeStart: 2020,
      gardePeak: 2026,
      gardeEnd: 2032,
      pairings: ['gibier-a-poil', 'viande-rouge-grillee'],
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: owner, quantity: 2),
  );
  await repo.createWine(
    const WineDraft(
      producer: 'Domaine Jeune',
      country: 'FR',
      color: 'blanc',
      vintage: '2022',
      gardeStart: 2030,
      gardeEnd: 2040,
      pairings: ['gibier-a-poil'],
    ),
    cellarId: cellar,
    lot: LotDraft(ownerId: owner, quantity: 4),
  );
  await repo.addTasting(
    wineId: apogeeId,
    cellarId: cellar,
    score: 16,
    dish: 'Lièvre à la royale',
    comment: 'Belle fraîcheur',
    date: '2026-09-02',
  );
}

void go(WidgetTester tester, String path) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(path);

Finder t(String s) => find.textContaining(RegExp(s, caseSensitive: false));

void main() {
  testWidgets('CMP-01 CMP-04 CMP-02 À boire : ordre, plat, alerte du mois', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/a-boire', seed: seedComfort);
    // CMP-01 : à boire vite en tête, le vin trop jeune n'apparaît pas.
    expect(t('Clos Vite'), findsOneWidget);
    expect(t('Mas Apogee'), findsOneWidget);
    expect(t('Domaine Jeune'), findsNothing);
    expect(
      tester.getTopLeft(t('Clos Vite')).dy,
      lessThan(tester.getTopLeft(t('Mas Apogee')).dy),
    );

    // CMP-02 : une apogée et une fin de fenêtre ce mois-ci.
    expect(find.byKey(const ValueKey('monthly-alert')), findsOneWidget);
    expect(t('1 vin entre en apogée'), findsOneWidget);
    expect(t('1 vin arrive en fin de fenêtre'), findsOneWidget);

    // CMP-04 : seul le vin à boire qui porte le plat reste.
    await tester.tap(find.byKey(const ValueKey('dish-pick')));
    await settle(tester);
    await tester.tap(find.text('Viande rouge grillée').last);
    await settle(tester);
    expect(t('Clos Vite'), findsNothing);
    expect(t('Mas Apogee'), findsOneWidget);
    expect(find.text('1 vin pour ce plat'), findsOneWidget);

    // CMP-02 : « Voir les vins » ouvre la liste, « Fermer » masque le mois.
    await tester.tap(find.byKey(const ValueKey('alert-see')));
    await settle(tester);
    expect(find.text('Apogée et fin de fenêtre'), findsOneWidget);
    expect(t('Clos Vite'), findsOneWidget);
    Navigator.of(tester.element(find.text('Apogée et fin de fenêtre'))).pop();
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('alert-dismiss')));
    await settle(tester);
    expect(find.byKey(const ValueKey('monthly-alert')), findsNothing);
  });

  testWidgets('CMP-02 l\'alerte suit le réglage Notifications', (tester) async {
    await pumpRealApp(
      tester,
      location: '/a-boire',
      seed: seedComfort,
      prefs: {'reglages_v1': '{"notifications":false}'},
    );
    expect(t('Clos Vite'), findsOneWidget);
    expect(find.byKey(const ValueKey('monthly-alert')), findsNothing);
  });

  testWidgets('CMP-05 onglet Dégustations : vin, date, plat, note', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/a-boire', seed: seedComfort);
    await tester.tap(find.text('Dégustations'));
    await settle(tester);
    expect(find.text('Mas Apogee · 2018'), findsOneWidget);
    expect(t('Lièvre à la royale · 16 / 20'), findsOneWidget);
    expect(t('Belle fraîcheur'), findsOneWidget);
    await tester.tap(find.text('Mas Apogee · 2018'));
    await settle(tester);
    expect(find.byKey(const ValueKey('wine-menu')), findsOneWidget);
  });

  testWidgets('CMP-03 liste d\'achats : ajout, acheté, retiré', (tester) async {
    final db = await pumpRealApp(
      tester,
      location: '/liste-achats',
      seed: seedComfort,
    );
    expect(t('Rien à acheter'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('shopping-add')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('shopping-label')),
      'Morgon Foillard',
    );
    await tester.enterText(find.byKey(const ValueKey('shopping-qty')), '6');
    await tester.enterText(
      find.byKey(const ValueKey('shopping-note')),
      'Vu chez le caviste',
    );
    await tester.tap(find.byKey(const ValueKey('shopping-save')));
    await settle(tester);
    expect(find.text('Morgon Foillard'), findsOneWidget);
    expect(find.text('6 bouteilles · Vu chez le caviste'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await settle(tester);
    var rows = await tester.runAsync(
      () => ComfortRepository(db).watchShopping().first,
    );
    expect(rows!.single.achete, isTrue);

    await tester.tap(find.byTooltip('Retirer de la liste'));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Supprimer'),
      ),
    );
    await settle(tester);
    expect(find.text('Morgon Foillard'), findsNothing);
    rows = await tester.runAsync(
      () => ComfortRepository(db).watchShopping().first,
    );
    expect(rows, isEmpty);
  });

  testWidgets('CMP-03 dernière bouteille ouverte : proposée à la liste', (
    tester,
  ) async {
    final db = await pumpRealApp(tester, seed: seedComfort);
    go(tester, '/fiche/$viteId');
    await settle(tester);
    await tester.tap(find.text('Ouvrir 1 bouteille'));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Annuler'),
      ),
    );
    await settle(tester);
    expect(find.text('Plus aucune bouteille'), findsOneWidget);
    await tester.tap(find.text('Ajouter à la liste'));
    await settle(tester);
    final rows = await tester.runAsync(
      () => ComfortRepository(db).watchShopping().first,
    );
    expect(rows!.single.ficheId, viteId);
    expect(rows.single.libelle, contains('2015'));
  });

  testWidgets('CMP-06 favori depuis la fiche et partage en image', (
    tester,
  ) async {
    final shared = <(String, String)>[];
    final db = await pumpRealApp(
      tester,
      seed: seedComfort,
      extra: [
        fileSharerProvider.overrideWithValue(
          (bytes, name, mime) async => shared.add((name, mime)),
        ),
      ],
    );
    go(tester, '/fiche/$apogeeId');
    await settle(tester);
    await tester.tap(find.byTooltip('Ajouter aux favoris'));
    await settle(tester);
    expect(find.byTooltip('Retirer des favoris'), findsOneWidget);
    final d = await tester.runAsync(() => CellarRepository(db).wine(apogeeId));
    expect(d!.draft.favorite, isTrue);

    await tester.tap(find.byKey(const ValueKey('wine-menu')));
    await settle(tester);
    await tester.tap(find.text('Partager en image'));
    await settle(tester);
    expect(find.text('Partager la fiche'), findsOneWidget);
    expect(find.byType(WineShareCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WineShareCard),
        matching: find.text('MAS APOGEE'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('share-image')));
    await pumpUntil(tester, () => shared.isNotEmpty);
    // PDF-01 : fichier au nom du vin, pas à son identifiant.
    expect(shared.single, ('Mas Apogee - 2018.png', 'image/png'));
  });
}
