import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/navigation/destinations.dart';

import '../fakes.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'NAV-01 le tiroir liste les 9 entrées dans l\'ordre des captures',
    (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);
      const attendues = [
        'Mes vins',
        'À boire',
        'Emplacements',
        'Statistiques',
        "Liste d'achats",
        'Import et export',
        'Sauvegarde',
        'Paramètres',
        "Remontée d'information",
        'À propos',
      ];
      final tiles = tester
          .widgetList<ListTile>(
            find.descendant(
              of: find.byType(Drawer),
              matching: find.byType(ListTile),
            ),
          )
          .map((t) => (t.title! as Text).data)
          .toList();
      expect(tiles, attendues);
      expect(AppDestination.values, hasLength(10));
    },
  );

  testWidgets('NAV-01 Mes vins est l\'accueil et l\'entrée active', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Mes vins'), findsOneWidget);
    await openDrawer(tester);
    final tile = tester.widget<ListTile>(
      find.byKey(const ValueKey('drawer-myWines')),
    );
    expect(tile.selected, isTrue);
  });

  testWidgets('NAV-01 Paramètres puis retour à Mes vins', (tester) async {
    await pumpApp(tester);
    await openDrawer(tester);
    await tester.tap(find.byKey(const ValueKey('drawer-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Réglages'), findsOneWidget);
    await openDrawer(tester);
    await tester.tap(find.byKey(const ValueKey('drawer-myWines')));
    await tester.pumpAndSettle();
    expect(find.text('Château Bralmac · Les Terrasses'), findsOneWidget);
  });

  testWidgets('NFR-17 À propos affiche la mention sanitaire', (tester) async {
    await pumpApp(tester, location: '/a-propos');
    expect(
      find.text(
        "L'abus d'alcool est dangereux pour la santé, "
        'à consommer avec modération.',
      ),
      findsOneWidget,
    );
    expect(find.text('Version 1.0.1'), findsOneWidget);
  });
}
