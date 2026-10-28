import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/enrichment_providers.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/features/add/barcode_reader.dart';
import 'package:iacaveavin/features/add/capture_screen.dart';

import '../data/contract_test.dart' show readExample, validator;
import '../data/photo_test.dart' show sharpLabel;
import '../fakes.dart';

/// Lecteur de code-barres sans appareil photo : renvoie [live] et [photo].
class FakeBarcodeReader implements BarcodeReader {
  FakeBarcodeReader({this.live, this.photo});

  final BarcodeResult? live;
  final BarcodeResult? photo;
  var liveCalls = 0;

  @override
  Future<BarcodeResult> scanLive(BuildContext context) async {
    liveCalls++;
    return live ?? const BarcodeResult.cancelled();
  }

  @override
  Future<BarcodeResult> fromPhoto() async =>
      photo ?? const BarcodeResult.cancelled();
}

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
    BarcodeReader? barcode,
    EnrichmentGateway? gateway,
  }) => pumpRealApp(
    tester,
    seed: seedOwner,
    appDir: root,
    prefs: prefs,
    extra: [
      imagePickerProvider.overrideWithValue(
        ({required bool camera}) async => label,
      ),
      if (barcode != null) barcodeReaderProvider.overrideWithValue(barcode),
      if (gateway != null) gatewayProvider.overrideWith((ref) => gateway),
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

  testWidgets(
    'AJO-01 AJO-02 AJO-04 AJO-05 AJO-06 AJO-08 AJO-13 NFR-08 FIC-06 FIC-07 parcours photo complet',
    (tester) async {
      final db = await start(tester);
      await tester.tap(find.byTooltip('Ajouter une bouteille'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('add-photo')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('take-photo')));
      await photoReady(tester);
      expect(find.text('Étiquette'), findsWidgets);
      await tester.ensureVisible(
        find.byKey(const ValueKey('capture-continue')),
      );
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
      // AJO-13 : photo rognée sur le cadre renvoyé, retour à la photo entière.
      expect(find.text("Recadrée sur l'étiquette"), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('crop-photo-0')));
      final editor = find.byKey(const ValueKey('crop-frame'));
      await pumpUntil(tester, () => editor.evaluate().isNotEmpty);
      expect(editor, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('crop-whole')));
      await pumpUntil(tester, () => editor.evaluate().isEmpty);
      await settle(tester);
      expect(find.text('Photo entière'), findsOneWidget);
      expect(find.text("Recadrée sur l'étiquette"), findsNothing);
      await tester.tap(find.byKey(const ValueKey('validation-save')));
      await settleLong(tester, 3);
      expect(find.text("GUILLAUME L'ECHANSON"), findsOneWidget);
      // FIC-07 : commentaire de millésime rédigé par l'agent, signalé comme tel.
      final ai = find.byKey(const ValueKey('ai-mention'));
      await tester.scrollUntilVisible(
        ai,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Rédigé par IA à partir de exemple-interprofession.fr'),
        findsOneWidget,
      );
      // FIC-06 : pastille de provenance, puis « Signaler une erreur ».
      await tester.tap(find.byTooltip('Voir la provenance').first);
      await settle(tester);
      expect(find.text('Provenance'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('report-error')));
      await settleLong(tester, 2);
      final reported = await tester.runAsync(
        () => db.select(db.provenances).get(),
      );
      expect(reported!.where((p) => p.signale == true), hasLength(1));
      final items = await tester.runAsync(
        () => CellarRepository(db).wineItems(),
      );
      expect(items!.single.enrichmentStatus, 'valide');
      expect(items.single.bottles, 1);
      expect(items.single.thumbPath, isNotNull);
    },
  );

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

  testWidgets(
    'AJO-10 code-barres : viseur ouvert d\'office, lecture sur une photo',
    (tester) async {
      final reader = FakeBarcodeReader(
        live: const BarcodeResult.found('3760256272183'),
        photo: const BarcodeResult.notFound(),
      );
      await start(tester, barcode: reader);
      await tester.tap(find.byTooltip('Ajouter une bouteille'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('add-barcode')));
      await settle(tester);
      expect(reader.liveCalls, 1, reason: 'viseur ouvert sans autre geste');
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('capture-ean')),
      );
      expect(field.controller!.text, '3760256272183');
      expect(find.text('Code-barres lu : 3760256272183'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('scan-photo')));
      await settle(tester);
      expect(
        find.text('Aucun code-barres EAN lisible sur cette photo.'),
        findsOneWidget,
      );
      expect(field.controller!.text, '3760256272183', reason: 'EAN conservé');
    },
  );

  testWidgets(
    'AJO-05 T111 lecture de l\'étiquette affichée pendant l\'enrichissement',
    (tester) async {
      final gateway = FakeGateway(
        validator: validator(),
        readExample: readExample,
        scenario: FakeScenario.never,
      );
      await start(tester, gateway: gateway);
      await tester.tap(find.byTooltip('Ajouter une bouteille'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('add-photo')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('take-photo')));
      await photoReady(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('capture-continue')),
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('capture-continue')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('consent-accept')));
      await settle(tester);
      expect(find.byKey(const ValueKey('label-preview')), findsNothing);
      // Suivi toutes les 3 s : l'étape enrichissement arrive au 3e appel.
      final preview = find.byKey(const ValueKey('label-preview'));
      for (var i = 0; i < 6 && preview.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(seconds: 3));
        await settle(tester);
      }
      expect(preview, findsOneWidget);
      expect(find.text("Lu sur l'étiquette, en attendant"), findsOneWidget);
      expect(find.text("Domaine : Guillaume L'Echanson"), findsOneWidget);
      expect(find.text('Millésime : 2024'), findsOneWidget);
      // Couleur non lue : rien d'affiché, jamais devinée.
      expect(find.byKey(const ValueKey('label-preview-couleur')), findsNothing);
      // Rien d'enregistré : la fiche reste en cours, sans domaine.
      expect(find.byKey(const ValueKey('review-proposals')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
