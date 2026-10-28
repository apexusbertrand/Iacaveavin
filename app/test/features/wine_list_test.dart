import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/wine_list_item.dart';
import 'package:iacaveavin/features/wine_list/wine_card.dart';

import '../fakes.dart';

List<WineListItem> manyWines(int n) => [
  for (var i = 0; i < n; i++)
    WineListItem(
      id: 'w$i',
      producer: 'Domaine $i',
      vintage: '${2005 + i % 20}',
      colorCode: const ['rouge', 'blanc', 'rose', 'champagne'][i % 4],
      countryCode: 'FR',
      countryLabel: 'France',
      region: 'Bordeaux',
      bottles: i % 7,
    ),
];

void main() {
  testWidgets('CMP-07 liste en lecture : cartes et compteur en sous-titre', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('3 vins · 18 bouteilles'), findsOneWidget);
    expect(find.byType(WineCard), findsNWidgets(3));
    expect(find.text('Château Bralmac · Les Terrasses'), findsOneWidget);
    expect(find.text('Bordeaux · Médoc'), findsOneWidget);
    expect(find.text('Pauillac'), findsOneWidget);
    expect(find.text('2019'), findsOneWidget);
    expect(find.text('NM'), findsOneWidget);
    expect(find.textContaining('42,50'), findsOneWidget);
    expect(find.text('À valider'), findsOneWidget);
    expect(find.textContaining('France'), findsNWidgets(3));
  });

  testWidgets('CMP-07 état vide : message et chargement de la démonstration', (
    tester,
  ) async {
    final repo = await pumpApp(tester, wines: Stream.value(const []));
    expect(find.text('Aucun vin.'), findsOneWidget);
    await tester.tap(find.text('Charger la démonstration'));
    await tester.pumpAndSettle();
    expect(repo.loads, 1);
  });

  testWidgets('CMP-07 état chargement : squelettes, jamais d\'écran blanc', (
    tester,
  ) async {
    final controller = StreamController<List<WineListItem>>();
    addTearDown(controller.close);
    await pumpApp(tester, wines: controller.stream);
    expect(find.bySemanticsLabel('Chargement de la cave'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('CMP-07 état erreur : message en clair et Réessayer', (
    tester,
  ) async {
    await pumpApp(tester, wines: Stream.error(StateError('base illisible')));
    expect(find.text("La cave n'a pas pu être lue."), findsOneWidget);
    expect(find.textContaining('base illisible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('CMP-07 200 fiches : liste paresseuse et bouton haut de page', (
    tester,
  ) async {
    await pumpApp(tester, wines: Stream.value(manyWines(200)));
    expect(find.text('200 vins · 594 bouteilles'), findsOneWidget);
    // ListView.builder : seules les cartes visibles sont construites.
    expect(find.byType(WineCard).evaluate().length, lessThan(20));
    expect(find.byTooltip('Haut de la page'), findsNothing);
    await tester.drag(
      find.byKey(const ValueKey('wine-list')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Haut de la page'), findsOneWidget);
    await tester.tap(find.byTooltip('Haut de la page'));
    await tester.pumpAndSettle();
    expect(find.text('Domaine 0'), findsOneWidget);
  });

  testWidgets('NFR-10 police à 200 % : aucune carte tronquée en erreur', (
    tester,
  ) async {
    await pumpApp(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    final e = tester.takeException();
    expect(e, isNull);
    expect(find.byType(WineCard), findsWidgets);
  });

  testWidgets('NFR-10 thème sombre : la liste s\'affiche sans erreur', (
    tester,
  ) async {
    await pumpApp(tester, brightness: Brightness.dark);
    final context = tester.element(find.byType(WineCard).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('NFR-10 cibles tactiles d\'au moins 48 dp', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('NFR-10 TalkBack : une carte se lit en une phrase', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      find.bySemanticsLabel(
        'Château Bralmac · Les Terrasses, millésime 2019, 6 bouteilles',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
