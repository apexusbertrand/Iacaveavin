import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/export_providers.dart';
import 'package:iacaveavin/features/statistics/stats_wines_screen.dart';
import 'package:iacaveavin/features/wine_list/wine_card.dart';

import '../fakes.dart';
import 'wine_flow_test.dart' show seedTwo;

void main() {
  testWidgets(
    'STA-01 STA-04 STA-06 tableaux prêts à l\'emploi, liste filtrée, libellés en clair',
    (tester) async {
      await pumpRealApp(tester, location: '/statistiques', seed: seedTwo);
      await settle(tester);
      // Général : 5 bouteilles, 2 références.
      expect(find.byKey(const ValueKey('kpi-bouteilles')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('kpi-bouteilles')),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );
      // STA-06 : aucune clé technique (codes de liste) à l'écran.
      final texts = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          t.data ?? '',
      ];
      expect(texts.where((t) => RegExp(r'\bfr-|_').hasMatch(t)), isEmpty);
      expect(texts, contains('Rouge'));

      // STA-04 : la part « Rouge » ouvre la liste de ses fiches.
      await tester.tap(find.byKey(const ValueKey('stat-row-rouge')).first);
      await settle(tester);
      expect(find.byType(WineCard), findsOneWidget);
      expect(find.textContaining('Bralmac', findRichText: true), findsWidgets);
      Navigator.of(tester.element(find.byType(StatsWinesScreen))).pop();
      await settle(tester);

      // Régions : zoom du pays à la région.
      await tester.tap(find.text('Régions'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('stat-row-FR')));
      await settle(tester);
      expect(find.byKey(const ValueKey('drill-up')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('stat-row-fr-bordeaux')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'STA-02 STA-03 STA-05 explorateur : graphiques compatibles, favori, export CSV et PNG',
    (tester) async {
      final shared = <String, Uint8List>{};
      await pumpRealApp(
        tester,
        location: '/statistiques',
        seed: seedTwo,
        extra: [
          fileSharerProvider.overrideWithValue(
            (bytes, name, mime) async => shared[name] = bytes,
          ),
        ],
      );
      await settle(tester);
      await tester.ensureVisible(find.text('Explorateur'));
      await settle(tester);
      await tester.tap(find.text('Explorateur'));
      await settle(tester);

      // Seconde dimension : seuls les graphiques à deux dimensions restent.
      await tester.tap(find.byKey(const ValueKey('pick-dim2')));
      await settle(tester);
      await tester.tap(find.text('Millésime').last);
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('pick-chart')));
      await settle(tester);
      expect(find.text('Barres empilées'), findsWidgets);
      expect(find.text('Tableau croisé'), findsWidgets);
      expect(find.text('Donut'), findsNothing);
      await tester.tap(find.text('Tableau croisé').last);
      await settle(tester);
      expect(find.byKey(const ValueKey('stat-cross-table')), findsOneWidget);

      // STA-05 : favori enregistré, puis export CSV et PNG.
      await tester.ensureVisible(find.byKey(const ValueKey('save-view')));
      await tester.tap(find.byKey(const ValueKey('save-view')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('view-save')));
      final chip = find.byKey(
        const ValueKey('view-Nombre de bouteilles · Couleur · Millésime'),
      );
      await pumpUntil(tester, () => chip.evaluate().isNotEmpty);
      expect(chip, findsOneWidget);

      // Le message « Vue enregistrée » couvre le bas de l'écran.
      ScaffoldMessenger.of(
        tester.element(find.byKey(const ValueKey('export-csv'))),
      ).removeCurrentSnackBar();
      await settle(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('export-csv')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('export-csv')));
      await pumpUntil(tester, () => shared.containsKey('statistique.csv'));
      final csv = utf8.decode(shared['statistique.csv']!);
      expect(csv, contains('"Couleur";"Millésime";"Nombre de bouteilles"'));
      expect(csv, contains('"Rouge";"2015";3'));

      await tester.tap(find.byKey(const ValueKey('export-png')));
      await pumpUntil(tester, () => shared.containsKey('statistique.png'));
      expect(shared['statistique.png']!.take(4), [0x89, 0x50, 0x4E, 0x47]);
    },
  );
}
