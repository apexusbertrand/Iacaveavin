// Lot 5, recette élargie : mesures sur une cave de 5 000 fiches (NFR-01,
// NFR-02, STA-06). Hors CI ; à lancer à la main depuis app/ :
//   flutter test tool/recette/mesures_5000_test.dart
// Les chiffres sont ceux d'une machine de développement, sans interface :
// ils situent l'ordre de grandeur. Démarrage à froid et fluidité de la liste
// se mesurent sur le téléphone (docs/recette-lot5.md).
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/l10n/generated/app_localizations.dart';
import 'package:iacaveavin/data/backup_service.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/demo/demo_generator.dart';
import 'package:iacaveavin/data/excel/excel_service.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/data/stats_repository.dart';
import 'package:iacaveavin/data/stock_service.dart';
import 'package:iacaveavin/domain/stats.dart';
import 'package:iacaveavin/domain/wine_query.dart';

import '../../test/fixture.dart';

/// Insère la cave de démonstration à [n] fiches dans [db].
Future<DemoDataSet> chargerCave(AppDatabase db, int n, DateTime now) async {
  final data = buildDemoDataSet(now: now, wineTarget: n);
  await db.transaction(() async {
    await db.into(db.cellars).insertOnConflictUpdate(data.cellar);
    await db.batch((b) {
      b.insertAll(db.owners, data.owners);
      b.insertAll(db.storageLocations, data.locations);
      b.insertAll(db.producers, data.producers);
      b.insertAll(db.cuvees, data.cuvees);
      b.insertAll(db.wines, data.wines);
      b.insertAll(db.stockLots, data.lots);
      b.insertAll(db.stockMovements, data.movements);
    });
  });
  return data;
}

Future<T> chrono<T>(String nom, Future<T> Function() f, {int? cibleMs}) async {
  final sw = Stopwatch()..start();
  final r = await f();
  sw.stop();
  final cible = cibleMs == null ? '' : ' (cible $cibleMs ms)';
  // ignore: avoid_print
  print('MESURE $nom : ${sw.elapsedMilliseconds} ms$cible');
  return r;
}

void main() {
  test('lot 5 : mesures sur 5 000 fiches', () async {
    final f = Fixture();
    await f.setUp();
    final root = Directory.systemTemp.createTempSync('iacav-mesures-');
    addTearDown(() async {
      await f.db.close();
      root.deleteSync(recursive: true);
    });
    final now = DateTime.utc(2026, 11, 14);
    final data = await chrono(
      'insertion de 5 000 fiches',
      () => chargerCave(f.db, 5000, now),
    );
    // ignore: avoid_print
    print(
      'VOLUME ${data.wines.length} fiches, ${data.lots.length} lots, '
      '${data.movements.length} mouvements',
    );
    final repo = CellarRepository(f.db, clock: () => now);

    // Premier chargement de la liste (part du démarrage, NFR-01).
    final items = await chrono('liste complète (wineItems)', repo.wineItems);
    expect(items.length, greaterThanOrEqualTo(5000));
    await chrono('liste, second chargement', repo.wineItems);

    // Filtre et tri (NFR-01 : sous 300 ms).
    const q = WineQuery(
      filters: WineFilters(colors: {'rouge'}, vintageMin: 2010),
    );
    final filtered = await chrono(
      'filtre couleur + millésime et tri',
      () async => q.apply(items, year: 2026),
      cibleMs: 300,
    );
    expect(filtered, isNotEmpty);
    await chrono(
      'recherche texte « bordeaux »',
      () async => const WineQuery(search: 'bordeaux').apply(items, year: 2026),
      cibleMs: 300,
    );

    // Ouverture d'une fiche (NFR-01 : sous 500 ms).
    await chrono(
      'ouverture d\'une fiche',
      () => repo.wine(items[2500].id),
      cibleMs: 500,
    );

    // Statistiques (STA-06 : sous 1 s).
    final facts = await chrono(
      'statistiques : lecture des faits',
      () => StatsRepository(f.db).facts(),
      cibleMs: 1000,
    );
    await chrono(
      'statistiques : agrégat couleur × millésime',
      () async => aggregate(
        facts,
        const StatQuery(
          measure: StatMeasure.bottles,
          dim1: StatDimension.color,
          dim2: StatDimension.vintage,
        ),
        year: 2026,
        now: now,
      ),
    );

    // Excel et sauvegarde (NFR-02 : en isolate, mesurés ici de bout en bout).
    final backup = BackupService(
      f.db,
      appDir: () async => root,
      tempDir: () async => Directory(root.path).createTemp('tmp'),
      clock: () => now,
    );
    final excel = ExcelService(
      f.db,
      cellar: repo,
      stock: StockService(f.db, clock: () => now),
      reference: ReferenceRepository(f.db, clock: () => now),
      backup: backup,
      photos: PhotoService(f.db, appDir: () async => root, clock: () => now),
      year: 2026,
      clock: () => now,
    );
    final l = lookupAppLocalizations(const Locale('fr'));
    final xlsx = await chrono('export Excel complet', () => excel.export(l));
    // ignore: avoid_print
    print('VOLUME classeur ${(xlsx.length / 1024).round()} Ko');
    final archive = await chrono(
      'archive de sauvegarde sans photos',
      () => backup.createArchive(withPhotos: false),
    );
    // ignore: avoid_print
    print('VOLUME archive ${(archive.lengthSync() / 1024).round()} Ko');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
