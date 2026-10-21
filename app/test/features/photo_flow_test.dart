import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/features/add/capture_screen.dart';

import '../data/photo_test.dart' show sharpLabel;
import '../fakes.dart';

Future<void> seedOwner(AppDatabase db, String cellar) async {
  await ReferenceRepository(db)
      .saveOwner(cellarId: cellar, name: 'Bertrand', isDefault: true);
}

void main() {
  late Directory root;
  late Uint8List label;

  setUpAll(() => label = sharpLabel(w: 1200, h: 800));
  setUp(() => root = Directory.systemTemp.createTempSync('iacav-ui-'));
  tearDown(() => root.deleteSync(recursive: true));

  Future<AppDatabase> start(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) => pumpRealApp(
    tester,
    seed: seedOwner,
    appDir: root,
    prefs: prefs,
    extra: [
      imagePickerProvider.overrideWithValue(
        ({required bool camera}) async => label,
      ),
    ],
  );

  Future<void> settleLong(WidgetTester tester, [int rounds = 6]) async {
    for (var i = 0; i < rounds; i++) {
      await settle(tester);
    }
  }

  /// Photo traitée en isolate : on attend que le bouton suivant s'active.
  Future<void> photoReady(WidgetTester tester) => pumpUntil(tester, () {
    final b = find.byKey(const ValueKey('capture-continue'));
    return b.evaluate().isNotEmpty &&
        tester.widget<FilledButton>(b).onPressed != null;
  });

  testWidgets('AJO-01 AJO-02 AJO-05 AJO-06 AJO-08 parcours photo complet', (
    tester,
  ) async {
    final db = await start(tester);
    await tester.tap(find.byTooltip('Ajouter une bouteille'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('add-photo')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('take-photo')));
    await photoReady(tester);
    expect(find.text('Étiquette'), findsWidgets);
    await tester.ensureVisible(find.byKey(const ValueKey('capture-continue')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('capture-continue')));
    await settle(tester);
    // NFR-08 : consentement explicite avant le premier envoi.
    expect(find.text('Envoi des photos'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('consent-accept')));
    await settleLong(tester);
    // AJO-04 : le lot se renseigne pendant l'attente.
    expect(find.text('Pendant ce temps, le lot'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('lot-save')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('lot-save')));
    await settleLong(tester, 10);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-proposals')),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('review-proposals')));
    await settleLong(tester, 3);
    // AJO-06 : chaque champ avec source et confiance.
    expect(find.textContaining('Étiquette · confiance 97 %'), findsOneWidget);
    expect(find.text('Confiance faible : vérifiez'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('validation-save')));
    await settleLong(tester, 3);
    expect(find.text("GUILLAUME L'ECHANSON"), findsOneWidget);
    final items = await tester.runAsync(() => CellarRepository(db).wineItems());
    expect(items!.single.enrichmentStatus, 'valide');
    expect(items.single.bottles, 1);
    expect(items.single.thumbPath, isNotNull);
  });

  testWidgets('AJO-09 NFR-03 hors ligne : fiche « à enrichir » et compteur', (
    tester,
  ) async {
    final db = await start(
      tester,
      prefs: {'reglages_v1': '{"simulateOffline":true,"photoConsent":true}'},
    );
    await tester.tap(find.byTooltip('Ajouter une bouteille'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('add-photo')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('from-gallery')));
    await photoReady(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('capture-continue')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('capture-continue')));
    final offline = find.textContaining('Hors ligne : la fiche reste');
    await pumpUntil(tester, () => offline.evaluate().isNotEmpty);
    expect(offline, findsOneWidget);
    await tester.tap(find.byTooltip('Fermer'));
    await settleLong(tester);
    // Sans lot, la fiche n'apparaît pas dans la liste « en stock » ; le
    // compteur de la file reste visible.
    expect(find.byKey(const ValueKey('pending-jobs')), findsOneWidget);
    final items = await tester.runAsync(() => CellarRepository(db).wineItems());
    expect(items!.single.enrichmentStatus, 'a_enrichir');
  });
}
