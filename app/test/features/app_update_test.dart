import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/app_update.dart';

import '../fakes.dart';

class _Store implements AppUpdateChecker {
  _Store({required this.available});

  final bool available;
  int checks = 0;
  int updates = 0;

  @override
  Future<bool> updateAvailable() async {
    checks++;
    return available;
  }

  @override
  Future<bool> update() async {
    updates++;
    return true;
  }
}

void main() {
  testWidgets(
    'NAV-03 version plus récente : proposée au lancement, « Plus tard » ferme',
    (tester) async {
      final store = _Store(available: true);
      await pumpApp(tester, updates: store);
      expect(find.text('Nouvelle version disponible'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('update-later')));
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle version disponible'), findsNothing);
      expect(store.updates, 0);
      // Une seule fois par lancement, même si l'écran se reconstruit.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mes vins').last);
      await tester.pumpAndSettle();
      expect(store.checks, 1);
    },
  );

  testWidgets('NAV-03 « Mettre à jour » passe par le store', (tester) async {
    final store = _Store(available: true);
    await pumpApp(tester, updates: store);
    await tester.tap(find.byKey(const ValueKey('update-now')));
    await tester.pumpAndSettle();
    expect(store.updates, 1);
  });

  testWidgets('NAV-03 à jour ou hors Play Store : rien ne s\'affiche', (
    tester,
  ) async {
    await pumpApp(tester, updates: _Store(available: false));
    expect(find.text('Nouvelle version disponible'), findsNothing);
    // Hors Android (tests), le vérificateur réel ne propose rien.
    expect(await const PlayAppUpdateChecker().updateAvailable(), isFalse);
  });
}
