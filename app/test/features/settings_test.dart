import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/navigation/destinations.dart';

import '../fakes.dart';

/// Ce que Google Play refuse : écran « à venir », contenu de démonstration.
final _interdit = RegExp(
  r'arrive (avec|au) le lot|\blot \d|bientôt disponible|démonstration|\bdémo\b',
  caseSensitive: false,
);

void main() {
  test('NFR-18 aucun texte de l\'app ne parle de lot à venir ni de démo', () {
    final arb = jsonDecode(
      File('lib/core/l10n/app_fr.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final fautifs = [
      for (final e in arb.entries)
        if (!e.key.startsWith('@') && _interdit.hasMatch('${e.value}')) e.key,
    ];
    expect(fautifs, isEmpty);
  });

  for (final d in AppDestination.values) {
    testWidgets('NFR-18 écran ${d.name} sans contenu à venir ni démo', (
      tester,
    ) async {
      await pumpApp(tester, location: d.path);
      final scrollables = find.byType(Scrollable);
      // Tout l'écran, y compris le bas des listes longues (Paramètres).
      for (var i = 0; i < 12 && scrollables.evaluate().isNotEmpty; i++) {
        final textes = [
          for (final w in tester.widgetList<Text>(find.byType(Text)))
            w.data ?? w.textSpan?.toPlainText() ?? '',
        ];
        for (final t in textes) {
          expect(_interdit.hasMatch(t), isFalse, reason: t);
        }
        await tester.drag(scrollables.first, const Offset(0, -500));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const ValueKey('demo-load')), findsNothing);
      expect(find.byKey(const ValueKey('fake-scenario')), findsNothing);
    });
  }
}
