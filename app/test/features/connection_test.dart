import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/flux_credentials.dart';
import 'package:iacaveavin/data/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

Future<void> toConnection(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('flux-url')),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'PAR-05 adresse et clé du flux : clé au stockage sécurisé, jamais réaffichée ni dans les préférences',
    (tester) async {
      await pumpApp(tester, location: '/parametres');
      await toConnection(tester);
      expect(find.text('Aucune clé enregistrée'), findsOneWidget);
      expect(
        find.text(
          "Pas de connexion enregistrée : l'identification par photo et les prix attendent la connexion au flux. Le reste de l'application fonctionne.",
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('flux-url')),
        'http://exemple.fr',
      );
      await tester.tap(find.byKey(const ValueKey('flux-save')));
      await tester.pumpAndSettle();
      expect(
        find.text('Adresse invalide : elle doit commencer par https://'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('flux-url')),
        'https://apexus.app.n8n.cloud',
      );
      await tester.enterText(
        find.byKey(const ValueKey('flux-key')),
        'ma-cle-secrete-de-test',
      );
      await tester.tap(find.byKey(const ValueKey('flux-save')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byKey(const ValueKey('flux-url'))),
      );
      expect(
        await container.read(secretStoreProvider).read(),
        'ma-cle-secrete-de-test',
      );
      final s = container.read(settingsProvider);
      expect(s.fluxUrl, 'https://apexus.app.n8n.cloud');
      expect(s.installationId, isNotNull);
      // La clé ne reste pas à l'écran et n'est pas dans les préférences.
      expect(find.text('ma-cle-secrete-de-test'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys()) {
        expect('${prefs.get(k)}', isNot(contains('ma-cle-secrete-de-test')));
      }
      expect(
        find.text('Clé enregistrée dans le stockage sécurisé du téléphone'),
        findsOneWidget,
      );
      expect(
        find.text('Vrai flux utilisé pour les enrichissements et les prix.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Oublier la connexion'));
      await tester.pumpAndSettle();
      expect(await container.read(secretStoreProvider).read(), isNull);
      expect(container.read(settingsProvider).usesRealFlux, false);
    },
  );
}
