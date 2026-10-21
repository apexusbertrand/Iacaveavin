import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  testWidgets('CMP-07 Paramètres : charger la démonstration', (tester) async {
    final repo = await pumpApp(tester, location: '/parametres');
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
    await tester.tap(find.byKey(const ValueKey('demo-load')));
    await tester.pumpAndSettle();
    expect(find.textContaining('disque plein'), findsOneWidget);
  });
}
