// Parcours complet sur téléphone ou émulateur :
//   flutter test integration_test
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/app.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CMP-07 NAV-01 démo chargée, liste fluide, démo effacée', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: IaCaveAVinApp()));
    await tester.pumpAndSettle();

    Future<void> goTo(String label) async {
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await goTo('Paramètres');
    if (find.byKey(const ValueKey('demo-load')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('demo-load')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    expect(find.text('Démonstration chargée : 200 fiches'), findsOneWidget);

    await goTo('Mes vins');
    expect(find.textContaining('200 vins'), findsOneWidget);

    // Mesure de fluidité : défilement de toute la liste (NFR-01 au lot 5).
    await binding.traceAction(() async {
      for (var i = 0; i < 10; i++) {
        await tester.fling(
          find.byKey(const ValueKey('wine-list')),
          const Offset(0, -2000),
          4000,
        );
        await tester.pumpAndSettle();
      }
    }, reportKey: 'defilement_liste_demo');

    await goTo('Paramètres');
    await tester.tap(find.byKey(const ValueKey('demo-erase')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-erase-confirm')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Démonstration non chargée'), findsOneWidget);
  });
}
