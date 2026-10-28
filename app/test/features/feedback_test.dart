import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/enrichment/enrichment_gateway.dart';
import 'package:iacaveavin/data/enrichment/enrichment_providers.dart';
import 'package:iacaveavin/data/export_providers.dart';
import 'package:iacaveavin/features/add/capture_screen.dart';

import '../data/contract_test.dart' show readExample, validator;
import '../data/photo_test.dart' show sharpLabel;
import '../fakes.dart';

void main() {
  late Directory root;
  late FakeGateway gateway;
  var connected = true;
  ({String name, Uint8List bytes})? file;

  setUp(() {
    root = Directory.systemTemp.createTempSync('iacav-remontee-');
    gateway = FakeGateway(validator: validator(), readExample: readExample);
    file = null;
    connected = true;
  });
  tearDown(() => root.deleteSync(recursive: true));

  Future<void> start(WidgetTester tester) => pumpRealApp(
    tester,
    location: '/remontee',
    appDir: root,
    extra: [
      gatewayProvider.overrideWith(
        (ref) => connected ? gateway : const NotConnectedGateway(),
      ),
      bytesPickerProvider.overrideWithValue((extensions) async => file),
      imagePickerProvider.overrideWithValue(
        ({required bool camera}) async => sharpLabel(w: 3000, h: 2000),
      ),
    ],
  );

  Future<void> fill(
    WidgetTester tester, {
    String email = 'bertrand@exemple.fr',
  }) async {
    await tester.enterText(
      find.byKey(const ValueKey('feedback-title')),
      'Fiche fausse',
    );
    await tester.enterText(
      find.byKey(const ValueKey('feedback-comment')),
      'Le millésime lu est faux.',
    );
    await tester.enterText(find.byKey(const ValueKey('feedback-email')), email);
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey(key)));
    await settle(tester);
  }

  testWidgets('RET-01 l\'écran est dans le menu', (tester) async {
    await start(tester);
    expect(find.text("Remontée d'information"), findsWidgets);
    expect(find.byKey(const ValueKey('feedback-send')), findsOneWidget);
  });

  testWidgets('RET-01 mail invalide : erreur sous le champ, rien ne part', (
    tester,
  ) async {
    await start(tester);
    await fill(tester, email: 'bertrand@exemple');
    await tapKey(tester, 'feedback-send');
    expect(find.textContaining('Adresse mail invalide'), findsOneWidget);
    expect(gateway.lastFeedback, isNull);
  });

  testWidgets('RET-01 champs vides refusés', (tester) async {
    await start(tester);
    await tapKey(tester, 'feedback-send');
    expect(find.text('Champ obligatoire.'), findsNWidgets(3));
    expect(gateway.lastFeedback, isNull);
  });

  testWidgets('RET-01 envoi avec un PDF joint, copie annoncée au contact', (
    tester,
  ) async {
    final pdf = Uint8List.fromList(ascii.encode('%PDF-1.4\n%%EOF\n'));
    file = (name: 'capture.pdf', bytes: pdf);
    await start(tester);
    await fill(tester);
    await tapKey(tester, 'feedback-attach-file');
    expect(find.text('capture.pdf'), findsOneWidget);
    await tapKey(tester, 'feedback-send');
    await pumpUntil(tester, () => gateway.lastFeedback != null);
    final sent = gateway.lastFeedback!;
    expect(sent.title, 'Fiche fausse');
    expect(sent.email, 'bertrand@exemple.fr');
    expect(sent.attachment!.mime, 'application/pdf');
    expect(sent.attachment!.bytes, pdf);
    expect(
      find.text('Message envoyé. Une copie part à bertrand@exemple.fr.'),
      findsOneWidget,
    );
    // Formulaire vidé, adresse gardée pour le prochain message.
    final title = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-title')),
        matching: find.byType(TextField),
      ),
    );
    expect(title.controller!.text, isEmpty);
    expect(find.byKey(const ValueKey('feedback-attachment')), findsNothing);
  });

  testWidgets('RET-01 une seule pièce : un fichier non PDF ni image refusé', (
    tester,
  ) async {
    file = (
      name: 'faux.pdf',
      bytes: Uint8List.fromList(ascii.encode('PK\u0003\u0004 zip deguise')),
    );
    await start(tester);
    await tapKey(tester, 'feedback-attach-file');
    expect(
      find.text('Seuls les PDF et les images sont acceptés.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('feedback-attachment')), findsNothing);
  });

  testWidgets('RET-01 photo jointe réduite à la taille d\'un écran en JPEG', (
    tester,
  ) async {
    await start(tester);
    await fill(tester);
    await tapKey(tester, 'feedback-attach-photo');
    await pumpUntil(
      tester,
      () => find
          .byKey(const ValueKey('feedback-attachment'))
          .evaluate()
          .isNotEmpty,
    );
    await tapKey(tester, 'feedback-send');
    await pumpUntil(tester, () => gateway.lastFeedback != null);
    final a = gateway.lastFeedback!.attachment!;
    expect(a.mime, 'image/jpeg');
    expect(a.name, 'photo.jpg');
    expect(a.bytes.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
    expect(a.bytes.length, lessThan(5 * 1024 * 1024));
  });

  testWidgets('RET-01 flux non connecté : rien ne part, la saisie reste', (
    tester,
  ) async {
    connected = false;
    await start(tester);
    await fill(tester);
    await tapKey(tester, 'feedback-send');
    expect(find.textContaining('Flux non connecté'), findsOneWidget);
    expect(gateway.lastFeedback, isNull);
    expect(find.textContaining('Message envoyé'), findsNothing);
    final title = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-title')),
        matching: find.byType(TextField),
      ),
    );
    expect(title.controller!.text, 'Fiche fausse');
  });

  testWidgets('RET-01 hors ligne : message gardé, invitation à réessayer', (
    tester,
  ) async {
    gateway.online = false;
    await start(tester);
    await fill(tester);
    await tapKey(tester, 'feedback-send');
    expect(find.textContaining('Pas de réseau'), findsOneWidget);
    final title = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-title')),
        matching: find.byType(TextField),
      ),
    );
    expect(title.controller!.text, 'Fiche fausse');
  });
}
