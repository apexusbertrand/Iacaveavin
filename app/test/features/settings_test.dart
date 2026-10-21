import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// La section démo est en bas des Paramètres : on fait défiler jusqu'au bout.
Future<void> toDemo(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('demo-status')),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CMP-07 Paramètres : charger la démonstration', (tester) async {
    final repo = await pumpApp(tester, location: '/parametres');
    await toDemo(tester);
    expect(find.text('Démonstration non chargée'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('demo-load')));
    await tester.pumpAndSettle();
    expect(repo.loads, 1);
    expect(find.text('Démonstration chargée : 200 fiches'), findsOneWidget);
    expect(find.text('Démonstration chargée.'), findsOneWidget);
  });

  testWidgets('CMP-07 Paramètres : effacer demande confirmation', (
    tester,
  ) async {
    final repo = await pumpApp(
      tester,
      location: '/parametres',
      demo: FakeDemoRepository(count: 200),
    );
    await toDemo(tester);
    await tester.tap(find.byKey(const ValueKey('demo-erase')));
    await tester.pumpAndSettle();
    expect(find.text('Effacer la démonstration ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(repo.erases, 0);

    await tester.tap(find.byKey(const ValueKey('demo-erase')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-erase-confirm')));
    await tester.pumpAndSettle();
    expect(repo.erases, 1);
    expect(find.text('Démonstration non chargée'), findsOneWidget);
  });

  testWidgets('CMP-07 Paramètres : un échec de chargement est expliqué', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/parametres',
      demo: FakeDemoRepository(failWith: StateError('disque plein')),
    );
    await toDemo(tester);
    await tester.tap(find.byKey(const ValueKey('demo-load')));
    await tester.pumpAndSettle();
    expect(find.textContaining('disque plein'), findsOneWidget);
  });
}
