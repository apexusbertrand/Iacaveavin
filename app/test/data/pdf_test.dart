import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/l10n/generated/app_localizations.dart';
import 'package:iacaveavin/data/demo/drift_demo_repository.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/data/pdf/pdf_service.dart';
import 'package:iacaveavin/domain/pdf_content.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/domain/wine_query.dart';
import 'package:iacaveavin/features/import_export/catalogue_section.dart';

import '../fixture.dart';
import 'photo_test.dart' show sharpLabel;

final l = lookupAppLocalizations(const Locale('fr'));

/// Nombre de pages d'un PDF (objets /Type /Page, hors /Pages).
int pageCount(Uint8List pdf) =>
    RegExp(r'/Type\s*/Page(?!s)').allMatches(String.fromCharCodes(pdf)).length;

String money(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

void main() {
  late Fixture f;
  late Directory root;
  late PhotoService photos;
  late PdfService pdf;

  setUp(() async {
    f = Fixture();
    await f.setUp();
    root = Directory.systemTemp.createTempSync('iacav-pdf-');
    photos = PhotoService(f.db, appDir: () async => root, clock: () => f.now);
    pdf = PdfService(
      cellar: f.repo,
      photos: photos,
      readAsset: (path) => File(path).readAsBytes(),
      year: 2026,
      accent: 0xFFB5520F,
      muted: 0xFF5A5A60,
    );
  });
  tearDown(() async {
    await f.db.close();
    root.deleteSync(recursive: true);
  });

  test('PDF-04 commentaire tronqué à la phrase entière la plus proche', () {
    const text =
        'Première phrase courte. Deuxième phrase un peu plus longue ! '
        'Troisième phrase qui dépasse la limite.';
    expect(
      truncateAtSentence(text, 70),
      'Première phrase courte. Deuxième phrase un peu plus longue !',
    );
    expect(truncateAtSentence(text, 30), 'Première phrase courte.');
    expect(
      truncateAtSentence('Un texte sans point final assez long', 20),
      'Un texte sans point…',
    );
    expect(truncateAtSentence('Court.', 100), 'Court.');
    expect(wineDeepLink('abc'), 'iacaveavin://fiche/abc');
  });

  test(
    'PDF-01 PDF-04 fiche unitaire A4 : champs du dictionnaire, photo, QR code',
    () async {
      await photos.save(
        wineId: f.wine,
        cellarId: f.cellar,
        photo: processPhoto(sharpLabel(w: 800, h: 600)),
        type: 'etiquette',
      );
      final content = (await pdf.content(f.wine, l, money: money))!;
      expect(content.title, 'Domaine Test');
      expect(content.vintage, '2019');
      final fields = {for (final (k, v) in content.fields) k: v};
      expect(fields[l.fieldAppellation], 'Volnay');
      expect(fields[l.fieldGrapes], 'Pinot noir 100 %');
      expect(fields[l.pdfStock], '6 bouteilles');
      expect(content.lines.single, contains('32,50 €'));
      expect(content.photo, isNotNull);
      final bytes = await pdf.wineSheet(
        f.wine,
        l,
        date: '27 octobre 2026',
        money: money,
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(pageCount(bytes), 1);
    },
  );

  test('PDF-02 PDF-03 catalogue : page de garde, 2 fiches par page, filtres rappelés', () async {
    for (final v in ['2015', '2016']) {
      await f.repo.createWine(
        WineDraft(
          producer: 'Domaine Test',
          cuvee: 'Les Essais',
          country: 'FR',
          color: 'rouge',
          vintage: v,
        ),
        cellarId: f.cellar,
      );
    }
    final ids = [for (final w in await f.repo.wineItems()) w.id];
    expect(ids, hasLength(3));
    final bytes = await pdf.catalogue(
      ids,
      l,
      date: '27 octobre 2026',
      money: money,
      filters: const ['Couleur : Rouge'],
    );
    expect(pageCount(bytes), 1 + 2, reason: 'garde + 2 pages de 2 fiches');
    final noCover = await pdf.catalogue(
      ids,
      l,
      date: '27 octobre 2026',
      money: money,
      cover: false,
    );
    expect(pageCount(noCover), 2);
    expect(
      describeFilters(
        l,
        const WineFilters(colors: {'rouge'}, vintageMin: 2010),
        labels: const {'couleur:rouge': 'Rouge'},
        owners: const [],
        locations: const [],
      ),
      ['Stock : En stock', 'Couleur : Rouge', 'Millésimes : de 2010 à …'],
    );
  });

  test('PDF-05 catalogue de 200 fiches en moins de 30 secondes', () async {
    await DriftDemoRepository(f.db, clock: () => f.now).load();
    final items = await f.repo.wineItems();
    // Une photo d'étiquette sur chaque fiche, comme sur un vrai téléphone.
    final photo = processPhoto(sharpLabel(w: 1200, h: 1600));
    final ids = [for (final w in items.take(200)) w.id];
    for (final id in ids) {
      await photos.save(
        wineId: id,
        cellarId: f.cellar,
        photo: photo,
        type: 'etiquette',
      );
    }
    final progress = <double>[];
    final watch = Stopwatch()..start();
    final bytes = await pdf.catalogue(
      ids,
      l,
      date: '27 octobre 2026',
      money: money,
      onProgress: progress.add,
    );
    watch.stop();
    debugPrint('PDF-05 : 200 fiches en ${watch.elapsedMilliseconds} ms');
    expect(pageCount(bytes), 1 + 100);
    expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    expect(progress.last, closeTo(1, 1e-9));
    for (var i = 1; i < progress.length; i++) {
      expect(progress[i], greaterThanOrEqualTo(progress[i - 1]));
    }
  });
}
