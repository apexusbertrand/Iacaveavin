// Parcours complet sur téléphone ou émulateur :
//   flutter test integration_test
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/app.dart';
import 'package:iacaveavin/data/providers.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CMP-07 NAV-01 démo chargée, liste fluide, démo effacée', (
    tester,
  ) async {
    // Le jeu de démonstration n'a plus d'écran dans l'app publiée (T122) :
    // le test le charge et l'efface par le dépôt.
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const IaCaveAVinApp(),
      ),
    );
    await tester.pumpAndSettle();
    await container.read(bootstrapProvider.future);
    final demo = container.read(demoRepositoryProvider);
    await demo.load();
    await tester.pumpAndSettle(const Duration(seconds: 1));
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

    await demo.erase();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(await demo.demoWineCount(), 0);
  });
}
