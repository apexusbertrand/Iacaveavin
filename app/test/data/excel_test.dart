import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/l10n/generated/app_localizations.dart';
import 'package:iacaveavin/data/backup_service.dart';
import 'package:iacaveavin/data/demo/drift_demo_repository.dart';
import 'package:iacaveavin/data/excel/excel_service.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/data/files/xlsx.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/excel_layout.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../fixture.dart';
import 'photo_test.dart' show sharpLabel;

final l = lookupAppLocalizations(const Locale('fr'));

/// Classeur modifié : [edit] reçoit les feuilles lues, en lignes mutables.
Uint8List edited(
  Uint8List xlsx,
  void Function(Map<String, List<List<Object?>>> book) edit,
) {
  final book = readXlsx(xlsx);
  // Les cellules vides de fin de ligne ne sont pas écrites : on complète.
  for (final rows in book.values) {
    if (rows.isEmpty) continue;
    final width = rows.first.length;
    for (final r in rows) {
      while (r.length < width) {
        r.add(null);
      }
    }
  }
  edit(book);
  return writeXlsx([
    for (final e in book.entries) XlsxSheet(name: e.key, rows: e.value),
  ]);
}

List<Object?> blankRow(List<ExcelColumn> cols) =>
    List<Object?>.filled(cols.length, null, growable: true);

int colOf(List<ExcelColumn> cols, String header) =>
    cols.indexWhere((c) => c.header == header);

void main() {
  late Fixture f;
  late Directory root;
  late ExcelService excel;
  late BackupService backup;

  setUp(() async {
    f = Fixture();
    await f.setUp();
    root = Directory.systemTemp.createTempSync('iacav-excel-');
    backup = BackupService(
      f.db,
      appDir: () async => root,
      tempDir: () async => Directory(root.path).createTemp('tmp'),
      clock: () => f.now,
    );
    excel = ExcelService(
      f.db,
      cellar: f.repo,
      stock: f.stock,
      reference: ReferenceRepository(f.db, clock: () => f.now),
      backup: backup,
      photos: PhotoService(f.db, appDir: () async => root, clock: () => f.now),
      year: 2026,
      clock: () => f.now,
    );
  });
  tearDown(() async {
    await f.db.close();
    root.deleteSync(recursive: true);
  });

  test('XLS-01 export à 5 onglets, colonnes du dictionnaire', () async {
    final book = readXlsx(await excel.export(l));
    expect(book.keys.toList(), [
      sheetWines,
      sheetLots,
      sheetMovements,
      sheetLists,
      sheetNotice,
    ]);
    expect(book[sheetWines]!.first, [for (final c in wineColumns) c.header]);
    expect(book[sheetLots]!.first, [for (final c in lotColumns) c.header]);
    expect(book[sheetMovements]!.first, [
      for (final c in movementColumns) c.header,
    ]);
    final wine = book[sheetWines]![1];
    expect(wine[colOf(wineColumns, 'Domaine')], 'Domaine Test');
    expect(wine[colOf(wineColumns, 'id')], f.wine);
    expect(wine[colOf(wineColumns, 'Stock total')], 6);
    // Aucune clé technique : libellés des listes et des énumérations.
    expect(wine[colOf(wineColumns, 'Couleur')], 'Rouge');
    expect(wine[colOf(wineColumns, 'Statut garde')], isA<String>());
    expect(book[sheetLists]!.length, greaterThan(100));
    expect(book[sheetNotice]!.first.single, contains('Règles'));
  });

  test(
    'XLS-02 cellules typées : nombres, dates et booléens jamais en texte',
    () async {
      final book = readXlsx(await excel.export(l));
      final wine = book[sheetWines]![1];
      expect(wine[colOf(wineColumns, 'Millésime')], isA<int>());
      expect(wine[colOf(wineColumns, 'Favori')], isA<bool>());
      final lot = book[sheetLots]![1];
      expect(lot[colOf(lotColumns, 'Format (cl)')], 75);
      expect(lot[colOf(lotColumns, 'Quantité')], 6);
      expect(lot[colOf(lotColumns, "Date d'achat")], isA<XlsxDate>());
      final mvt = book[sheetMovements]![1];
      expect(mvt[colOf(movementColumns, 'Date')], isA<XlsxDate>());
      // Écriture brute : pas de nombre rangé en texte.
      final zip = ZipDecoder().decodeBytes(await excel.export(l));
      final sheet = String.fromCharCodes(
        zip.findFile('xl/worksheets/sheet2.xml')!.content as List<int>,
      );
      expect(sheet, isNot(contains('<t xml:space="preserve">75</t>')));
      expect(sheet, contains('s="1"'), reason: 'date au format date');
    },
  );

  test('XLS-03 modèle vierge, même format que l\'export', () async {
    final book = readXlsx(await excel.export(l, template: true));
    expect(book.keys, hasLength(5));
    expect(book[sheetWines], hasLength(1));
    expect(book[sheetLots], hasLength(1));
    expect(book[sheetWines]!.first, [for (final c in wineColumns) c.header]);
    expect(book[sheetLists]!.length, greaterThan(100));
  });

  test(
    'XLS-04 XLS-05 XLS-07 création, mise à jour, suppression, quantité cible',
    () async {
      final other = await f.repo.createWine(
        const WineDraft(
          producer: 'Domaine Test',
          cuvee: 'Les Essais',
          country: 'FR',
          color: 'rouge',
          vintage: '2018',
        ),
        cellarId: f.cellar,
      );
      final xlsx = edited(await excel.export(l), (book) {
        final wines = book[sheetWines]!;
        final idCol = colOf(wineColumns, 'id');
        final first = wines.indexWhere((r) => r[idCol] == f.wine);
        wines[first][colOf(wineColumns, 'Mon commentaire')] = 'Pour Noël';
        final second = wines.indexWhere((r) => r[idCol] == other);
        wines[second][colOf(wineColumns, 'Action')] = 'SUPPRIMER';
        final created = blankRow(wineColumns)
          ..[colOf(wineColumns, 'Domaine')] = 'Domaine Nouveau'
          ..[colOf(wineColumns, 'Pays')] = 'France'
          ..[colOf(wineColumns, 'Couleur')] = 'Blanc'
          ..[colOf(wineColumns, 'Millésime')] = 2022
          ..[colOf(wineColumns, 'Cépages')] = 'Chardonnay 100 %';
        wines.add(created);
        final newLine = wines.length;
        final lots = book[sheetLots]!;
        lots[1][colOf(lotColumns, 'Quantité')] = 4;
        lots.add(
          blankRow(lotColumns)
            ..[colOf(lotColumns, 'id fiche')] = '#$newLine'
            ..[colOf(lotColumns, 'Format (cl)')] = 75
            ..[colOf(lotColumns, 'Propriétaire')] = 'Julie'
            ..[colOf(lotColumns, 'Emplacement')] = 'Cave > Casier A'
            ..[colOf(lotColumns, 'Quantité')] = 12
            ..[colOf(lotColumns, "Prix d'achat unitaire")] = 14.5,
        );
      });
      final plan = await excel.simulate(xlsx);
      final r = plan.report;
      expect(r.issues, isEmpty, reason: '${r.issues}');
      expect(
        (
          r.winesCreated,
          r.winesUpdated,
          r.winesDeleted,
          r.lotsCreated,
          r.stockChanges,
        ),
        (1, 1, 1, 1, 2),
      );
      // XLS-07 : la simulation n'écrit rien.
      expect((await f.repo.wine(f.wine))!.draft.personalComment, isNull);

      await excel.apply(plan, cellarId: f.cellar);
      final updated = (await f.repo.wine(f.wine))!;
      expect(updated.draft.personalComment, 'Pour Noël');
      expect(await f.repo.wine(other), isNull);
      expect(updated.bottles, 4);
      final adjust = updated.movements.first;
      expect(
        (adjust.type, adjust.quantity, adjust.reason),
        ('ajustement', -2, importReason),
      );
      final items = await f.repo.wineItems();
      final nouveau = items.singleWhere((w) => w.producer == 'Domaine Nouveau');
      expect(nouveau.bottles, 12);
      expect(nouveau.locationPath, 'Cave > Casier A');
      expect(nouveau.grapes, ['chardonnay']);
      // XLS-08 : sauvegarde automatique juste avant l'import.
      expect(await backup.autoBackups(), hasLength(1));
    },
  );

  test(
    'XLS-06 valeur de liste inconnue : erreur, ou création en bloc',
    () async {
      final xlsx = edited(await excel.export(l, template: true), (book) {
        book[sheetWines]!.add(
          blankRow(wineColumns)
            ..[colOf(wineColumns, 'Domaine')] = 'Domaine Lointain'
            ..[colOf(wineColumns, 'Pays')] = 'France'
            ..[colOf(wineColumns, 'Couleur')] = 'Rouge'
            ..[colOf(wineColumns, 'Millésime')] = 2020
            ..[colOf(wineColumns, 'Région')] = 'Vallée imaginaire'
            ..[colOf(wineColumns, 'Accords')] = 'Gibier; Plat inventé',
        );
      });
      final refused = await excel.simulate(xlsx);
      expect(
        refused.report.issues.map((i) => (i.row, i.column, i.code, i.value)),
        containsAll([
          (2, 'Région', IssueCode.unknownValue, 'Vallée imaginaire'),
          (2, 'Accords', IssueCode.unknownValue, 'Plat inventé'),
        ]),
      );
      await expectLater(
        excel.apply(refused, cellarId: f.cellar),
        throwsA(isA<ImportException>()),
      );

      final accepted = await excel.simulate(xlsx, createUnknown: true);
      expect(accepted.report.issues, isEmpty);
      expect(
        accepted.report.unknown.map((u) => (u.list, u.label)),
        containsAll([
          ('region', 'Vallée imaginaire'),
          ('accord_mets', 'Plat inventé'),
        ]),
      );
      await excel.apply(accepted, cellarId: f.cellar);
      final regions = await ReferenceRepository(f.db).values('region');
      final created = regions.singleWhere(
        (v) => v.label == 'Vallée imaginaire',
      );
      expect(created.parentCode, 'FR', reason: 'rattachée au pays de la ligne');
    },
  );

  test(
    'XLS-07 rapport d\'erreurs par ligne, colonne et motif ; rien n\'est écrit',
    () async {
      final xlsx = edited(await excel.export(l), (book) {
        final wines = book[sheetWines]!;
        wines[1][colOf(wineColumns, 'Millésime')] = 1850;
        wines[1][colOf(wineColumns, 'Degré (%)')] = 'fort';
        wines[1][colOf(wineColumns, 'EAN')] = '1234567890123';
        wines.add(
          blankRow(wineColumns)
            ..[colOf(wineColumns, 'id')] = 'inconnu'
            ..[colOf(wineColumns, 'Domaine')] = 'X',
        );
        book[sheetLots]![1][colOf(lotColumns, 'Quantité')] = -3;
      });
      final r = (await excel.simulate(xlsx)).report;
      expect(
        r.issues.map((i) => (i.sheet, i.row, i.column, i.code)),
        containsAll([
          (sheetWines, 2, 'Millésime', IssueCode.invalidVintage),
          (sheetWines, 2, 'Degré (%)', IssueCode.outOfRange),
          (sheetWines, 2, 'EAN', IssueCode.invalidEan),
          (sheetWines, 3, 'id', IssueCode.unknownId),
          (sheetLots, 2, 'Quantité', IssueCode.invalidNumber),
        ]),
      );
    },
  );

  test('XLS-08 import tout ou rien : un échec annule tout', () async {
    final xlsx = edited(await excel.export(l), (book) {
      book[sheetWines]![1][colOf(wineColumns, 'Mon commentaire')] = 'Modifié';
      book[sheetLots]![1][colOf(lotColumns, 'Quantité')] = 2;
    });
    final plan = await excel.simulate(xlsx);
    expect(plan.report.issues, isEmpty);
    // Le lot disparaît entre la simulation et l'import : l'ajustement échoue.
    await (f.db.delete(f.db.stockMovements)).go();
    await (f.db.delete(f.db.stockLots)).go();
    await expectLater(excel.apply(plan, cellarId: f.cellar), throwsA(anything));
    expect(
      (await f.repo.wine(f.wine))!.draft.personalComment,
      isNull,
      reason: 'la mise à jour de la fiche est annulée',
    );
  });

  test(
    'XLS-09 XLS-10 zip de photos : photo rattachée, fiche enrichissable',
    () async {
      final photo = Uint8List.fromList(sharpLabel(w: 600, h: 400));
      final zip = Archive()
        ..addFile(ArchiveFile('photos/etiquette-1.jpg', photo.length, photo));
      final xlsx = edited(await excel.export(l, template: true), (book) {
        book[sheetWines]!.add(
          blankRow(wineColumns)
            ..[colOf(wineColumns, 'Domaine')] = 'Domaine Photo'
            ..[colOf(wineColumns, 'Pays')] = 'France'
            ..[colOf(wineColumns, 'Couleur')] = 'Rouge'
            ..[colOf(wineColumns, 'Millésime')] = 2021
            ..[colOf(wineColumns, 'Photo principale')] = 'etiquette-1.jpg',
        );
      });
      final plan = await excel.simulate(
        xlsx,
        photosZip: Uint8List.fromList(ZipEncoder().encode(zip)),
      );
      expect((plan.report.photosFound, plan.report.enrichable), (1, 1));
      final result = await excel.apply(plan, cellarId: f.cellar);
      expect(result.createdWines, hasLength(1));
      final photos = await f.db.select(f.db.photos).get();
      expect(photos.single.ficheId, result.createdWines.single);
      expect(photos.single.principale, isTrue);
    },
  );

  test(
    'XLS-04 aller-retour sans écart sur le jeu de démonstration (500 lignes)',
    () async {
      await DriftDemoRepository(f.db, clock: () => f.now).load();
      // 200 fiches de démonstration et leurs lots, plus 60 fiches saisies.
      for (var i = 0; i < 60; i++) {
        await f.repo.createWine(
          WineDraft(
            producer: 'Domaine $i',
            country: 'FR',
            color: i.isEven ? 'rouge' : 'blanc',
            vintage: '${2000 + i % 25}',
          ),
          cellarId: f.cellar,
          lot: LotDraft(ownerId: 'o1', quantity: i % 7, unitPrice: 10.0 + i),
        );
      }
      final first = await excel.export(l);
      final book = readXlsx(first);
      final lines = book[sheetWines]!.length + book[sheetLots]!.length - 2;
      expect(lines, greaterThanOrEqualTo(500), reason: '$lines lignes');
      final watch = Stopwatch()..start();
      final plan = await excel.simulate(first);
      expect(
        plan.report.issues,
        isEmpty,
        reason: '${plan.report.issues.take(5)}',
      );
      expect(plan.report.hasChanges, isFalse, reason: 'aucun écart');
      await excel.apply(plan, cellarId: f.cellar);
      final again = readXlsx(await excel.export(l));
      for (final sheet in [sheetWines, sheetLots, sheetMovements]) {
        expect(again[sheet], book[sheet], reason: sheet);
      }
      debugPrint(
        'XLS aller-retour $lines lignes : ${watch.elapsedMilliseconds} ms',
      );
    },
  );
}
