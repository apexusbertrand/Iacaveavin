import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iacaveavin/core/navigation/destinations.dart';

import '../fakes.dart';
import 'navigation_test.dart' show openDrawer;

List<String?> _drawerTitles(WidgetTester tester) => tester
    .widgetList<ListTile>(
      find.descendant(of: find.byType(Drawer), matching: find.byType(ListTile)),
    )
    .map((t) => (t.title! as Text).data)
    .toList();

void main() {
  testWidgets('LNG-01 téléphone en anglais : écrans en anglais', (
    tester,
  ) async {
    await pumpApp(tester, device: const Locale('en', 'US'));
    expect(find.text('My wines'), findsWidgets);
    await openDrawer(tester);
    expect(_drawerTitles(tester), [
      'My wines',
      'To drink',
      'Locations',
      'Statistics',
      'Ageing rules',
      'Shopping list',
      'Import and export',
      'Backup',
      'Settings',
      'Send feedback',
      'About',
    ]);
  });

  testWidgets('LNG-01 téléphone dans une autre langue : français', (
    tester,
  ) async {
    await pumpApp(tester, device: const Locale('de'));
    expect(find.text('Mes vins'), findsWidgets);
  });

  testWidgets('LNG-02 Paramètres > Langue : English puis retour au français', (
    tester,
  ) async {
    await pumpApp(tester, location: '/parametres');
    expect(find.text('Langue du téléphone'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();
    expect(find.text('Paramètres'), findsWidgets);
  });

  // LNG-01 : chaque écran du menu en anglais, parcouru jusqu'en bas, sans
  // débordement ni clé technique.
  for (final d in AppDestination.values) {
    testWidgets('LNG-01 écran ${d.name} en anglais', (tester) async {
      await pumpApp(tester, location: d.path, device: const Locale('en'));
      final scrollables = find.byType(Scrollable);
      for (var i = 0; i < 12 && scrollables.evaluate().isNotEmpty; i++) {
        for (final w in tester.widgetList<Text>(find.byType(Text))) {
          final t = w.data ?? w.textSpan?.toPlainText() ?? '';
          expect(RegExp(r'_\d').hasMatch(t), isFalse, reason: t);
        }
        await tester.drag(scrollables.first, const Offset(0, -500));
        await tester.pumpAndSettle();
      }
    });
  }
}
