import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/backup_providers.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/export_providers.dart';
import 'package:iacaveavin/data/files/xlsx.dart';
import 'package:iacaveavin/domain/excel_layout.dart';

import '../fakes.dart';
import 'wine_flow_test.dart' show seedTwo;

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('iacav-ie-'));
  tearDown(() => root.deleteSync(recursive: true));

  testWidgets(
    'XLS-01 XLS-07 PDF-02 PDF-05 écran Import / export : export, simulation, import, catalogue',
    (tester) async {
      final shared = <(String, String)>[];
      Uint8List? picked;
      final db = await pumpRealApp(
        tester,
        location: '/import-export',
        seed: seedTwo,
        appDir: root,
        extra: [
          fileSharerProvider.overrideWithValue(
            (bytes, name, mime) async => shared.add((name, mime)),
          ),
          bytesPickerProvider.overrideWithValue(
            (ext) async => ext.contains('xlsx') && picked != null
                ? (name: 'cave.xlsx', bytes: picked)
                : null,
          ),
          binaryAssetReaderProvider.overrideWithValue(
            (path) => File(path).readAsBytes(),
          ),
          tempDirProvider.overrideWithValue(() async => root),
        ],
      );
      expect(find.text('Exporter la cave'), findsOneWidget);

      // XLS-01 : classeur partagé.
      await tester.tap(find.byKey(const ValueKey('excel-export')));
      await pumpUntil(tester, () => shared.isNotEmpty);
      expect(shared.single.$1, endsWith('.xlsx'));

      // XLS-07 : simulation d'un classeur avec une fiche nouvelle.
      final rows = <List<Object?>>[
        [for (final c in wineColumns) c.header],
        [
          for (final c in wineColumns)
            switch (c.header) {
              'Domaine' => 'Domaine Importé',
              'Pays' => 'France',
              'Couleur' => 'Blanc',
              'Millésime' => 2021,
              _ => null,
            },
        ],
      ];
      picked = writeXlsx([
        XlsxSheet(name: sheetWines, rows: rows),
        XlsxSheet(
          name: sheetLots,
          rows: [
            [for (final c in lotColumns) c.header],
          ],
        ),
      ]);
      await tester.tap(find.byKey(const ValueKey('excel-import')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('import-no-photos')));
      final report = find.text('Fiches créées : 1');
      await pumpUntil(tester, () => report.evaluate().isNotEmpty);
      expect(report, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('import-apply')));
      final done = find.text('Import terminé');
      await pumpUntil(tester, () => done.evaluate().isNotEmpty);
      final items = await tester.runAsync(
        () => CellarRepository(db).wineItems(),
      );
      expect(items!.map((w) => w.producer), contains('Domaine Importé'));

      // PDF-02, PDF-05 : catalogue généré en arrière-plan puis partagé.
      shared.clear();
      final generate = find.byKey(const ValueKey('catalogue-generate'));
      await tester.scrollUntilVisible(
        generate,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(generate);
      await settle(tester);
      await tester.tap(generate);
      await pumpUntil(tester, () => shared.isNotEmpty);
      expect(shared.single, ('iacaveavin-catalogue.pdf', 'application/pdf'));
    },
  );
}
