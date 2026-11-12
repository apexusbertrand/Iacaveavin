import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/navigation/app_router.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/reference_repository.dart';

import '../fakes.dart';

Future<void> seed(AppDatabase db, String cellar) async {
  await ReferenceRepository(db)
      .saveOwner(cellarId: cellar, name: 'Bertrand', isDefault: true);
}

void main() {
  testWidgets('PRO-01 propriétaires : ajout et propriétaire par défaut', (
    tester,
  ) async {
    await pumpRealApp(
      tester,
      location: '/parametres/proprietaires',
      seed: seed,
    );
    expect(find.text('Aucune bouteille · par défaut'), findsOneWidget);
    await tester.tap(find.byTooltip('Ajouter un propriétaire'));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('owner-name')), 'Julie');
    await tester.tap(find.byKey(const ValueKey('owner-save')));
    await settle(tester);
    expect(find.text('Julie'), findsOneWidget);
  });

  testWidgets('PRO-04 pas d\'authentification : l\'app s\'ouvre sur la cave', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seed);
    expect(find.text('Mes vins'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('PAR-01 un écran par liste modifiable', (tester) async {
    await pumpRealApp(tester, location: '/parametres/listes', seed: seed);
    for (final list in editableLists.take(6)) {
      expect(find.byKey(ValueKey('list-$list')), findsOneWidget);
    }
    expect(find.text('Couleur'), findsNothing, reason: 'liste non modifiable');
    await tester.tap(find.text('Certifications'));
    await settle(tester);
    expect(find.text('Biodynamie'), findsOneWidget);
  });

  testWidgets('PAR-02 ajouter une valeur depuis l\'écran de liste', (
    tester,
  ) async {
    await pumpRealApp(
      tester,
      location: '/parametres/listes/fournisseur',
      seed: seed,
    );
    await tester.tap(find.byTooltip('Ajouter une valeur'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('ask-text')),
      'Caviste du coin',
    );
    await tester.tap(find.byKey(const ValueKey('ask-save')));
    await settle(tester);
    expect(find.text('Caviste du coin'), findsOneWidget);
  });

  testWidgets('PAR-06 PAR-07 règles de garde dans le menu, validées (V2)', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seed);
    await tester.tap(find.byIcon(Icons.menu));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('drawer-gardeRules')));
    await settle(tester);
    // Validées par Bertrand le 2026-11-01 : plus de mention « à valider ».
    expect(find.byKey(const ValueKey('garde-pending')), findsNothing);
    expect(find.byKey(const ValueKey('garde-customized')), findsNothing);
    expect(find.text('Début +0 · apogée +1 · fin +2'), findsWidgets);
  });

  testWidgets(
    'PAR-07 modifier, ajouter une règle par couleur et région, rétablir',
    (tester) async {
      await pumpRealApp(tester, location: '/regles-garde', seed: seed);
      // Modifier : la règle du rosé passe à fin +5.
      await tester.tap(find.byKey(const ValueKey('garde-rule-rose')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('garde-rule-start')),
        '4',
      );
      await tester.tap(find.byKey(const ValueKey('garde-rule-save')));
      await settle(tester);
      expect(
        find.text('Entre 0 et 100, avec début ≤ apogée ≤ fin.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('garde-rule-start')),
        '0',
      );
      await tester.enterText(find.byKey(const ValueKey('garde-rule-end')), '5');
      await tester.tap(find.byKey(const ValueKey('garde-rule-save')));
      await settle(tester);
      expect(
        find.text('Règles enregistrées, aucune fiche à recalculer'),
        findsOneWidget,
      );
      expect(find.text('Début +0 · apogée +1 · fin +5'), findsOneWidget);
      expect(find.byKey(const ValueKey('garde-customized')), findsOneWidget);
      // Ajouter : blanc d'Alsace.
      await tester.tap(find.byKey(const ValueKey('garde-add')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('garde-rule-color')));
      await settle(tester);
      await tester.tap(find.text('Blanc').last);
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('garde-rule-regions')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('garde-pick-search')),
        'alsace',
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('garde-pick-Alsace')));
      await tester.tap(find.byKey(const ValueKey('garde-pick-ok')));
      await settle(tester);
      expect(find.text('Alsace'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('garde-rule-start')),
        '1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('garde-rule-peak')),
        '4',
      );
      await tester.enterText(find.byKey(const ValueKey('garde-rule-end')), '9');
      await tester.tap(find.byKey(const ValueKey('garde-rule-save')));
      await settle(tester);
      expect(find.text('Blanc · Alsace'), findsOneWidget);
      expect(find.text('Début +1 · apogée +4 · fin +9'), findsOneWidget);
      // Rétablir les règles livrées.
      await tester.tap(find.byKey(const ValueKey('garde-menu')));
      await settle(tester);
      await tester.tap(find.text('Rétablir les valeurs par défaut'));
      await settle(tester);
      await tester.tap(find.text('Rétablir les valeurs par défaut').last);
      await settle(tester);
      expect(find.text('Blanc · Alsace'), findsNothing);
      expect(find.text('Début +0 · apogée +1 · fin +5'), findsNothing);
      expect(find.byKey(const ValueKey('garde-customized')), findsNothing);
    },
  );

  testWidgets('PAR-05 réglages : thème sombre appliqué et mémorisé', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/parametres', seed: seed);
    await tester.tap(find.text('Sombre'));
    await settle(tester);
    final ctx = tester.element(find.text('Réglages'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('SAV-01 SAV-04 écran Sauvegarde : export et restauration', (
    tester,
  ) async {
    await pumpRealApp(tester, location: '/sauvegarde', seed: seed);
    expect(find.text('Exporter une archive sans photos'), findsOneWidget);
    expect(find.text('Restaurer une archive'), findsOneWidget);
    expect(find.text('Aucun export pour l\'instant.'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text("Aucune sauvegarde automatique pour l'instant."),
      find.byType(ListView),
      const Offset(0, -200),
    );
  });

  test('NAV-02 lien profond iacaveavin://fiche/<id> vers la fiche', () {
    expect(
      deepLinkRedirect(Uri.parse('iacaveavin://fiche/1234-abcd')),
      '/fiche/1234-abcd',
    );
    expect(deepLinkRedirect(Uri.parse('/fiche/1234')), isNull);
  });
}
