import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/flux_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

String sessionJson({String expires = '2099-01-01T00:00:00Z'}) =>
    testSessionJson(expires: expires);

Future<void> toAccount(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'CPT-01 sans compte : les Paramètres proposent la connexion par code',
    (tester) async {
      await pumpApp(tester, location: '/parametres');
      await toAccount(tester, const ValueKey('account-request-code'));
      expect(find.text('Compte'), findsOneWidget);
      expect(find.byKey(const ValueKey('account-email-field')), findsOneWidget);
      // Plus d'adresse ni de clé à saisir (T126).
      expect(find.byKey(const ValueKey('flux-url')), findsNothing);
      expect(find.byKey(const ValueKey('flux-key')), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('account-email-field')),
        'pas-une-adresse',
      );
      await tester.tap(find.byKey(const ValueKey('account-request-code')));
      await tester.pumpAndSettle();
      expect(
        find.text('Adresse mail invalide (exemple : prenom.nom@exemple.fr).'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('account-code-field')), findsNothing);
    },
  );

  testWidgets(
    'CPT-04 compte connecté : adresse, formule et quotas ; la déconnexion efface la session',
    (tester) async {
      final store = MemorySecretStore(sessionJson());
      await pumpApp(tester, location: '/parametres', secrets: store);
      await toAccount(tester, const ValueKey('account-signout'));
      expect(find.text('Connecté : prenom.nom@exemple.fr'), findsOneWidget);
      expect(find.text('Formule : gratuite'), findsOneWidget);
      expect(
        find.text(
          'Ce mois-ci : 7 identifications et 1 relevé de prix restants.',
        ),
        findsOneWidget,
      );
      // CPT-03 : la clé reste dans le stockage sécurisé, jamais dans les
      // préférences.
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys()) {
        expect('${prefs.get(k)}', isNot(contains('ab' * 32)));
      }

      await tester.tap(find.byKey(const ValueKey('account-signout')));
      await pumpUntil(
        tester,
        () => find
            .byKey(const ValueKey('account-request-code'))
            .evaluate()
            .isNotEmpty,
      );
      expect(await store.read(), isNull);
      expect(find.byKey(const ValueKey('account-email-field')), findsOneWidget);
    },
  );

  testWidgets('CPT-03 session expirée : le compte compte comme déconnecté', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/parametres',
      secrets: MemorySecretStore(sessionJson(expires: '2020-01-01T00:00:00Z')),
    );
    await toAccount(tester, const ValueKey('account-request-code'));
    expect(find.byKey(const ValueKey('account-signout')), findsNothing);
  });

  testWidgets('CPT-03 remontée : sans compte, invitation à se connecter', (
    tester,
  ) async {
    await pumpApp(tester, location: '/remontee');
    await toAccount(tester, const ValueKey('feedback-signin'));
    expect(
      find.text('Connectez-vous à votre compte pour envoyer une remontée.'),
      findsOneWidget,
    );
  });

  testWidgets('CPT-03 remontée : l\'adresse du compte est pré-remplie', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/remontee',
      secrets: MemorySecretStore(sessionJson()),
    );
    expect(find.byKey(const ValueKey('feedback-signin')), findsNothing);
    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-email')),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.controller.text, 'prenom.nom@exemple.fr');
  });
}
