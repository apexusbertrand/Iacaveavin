import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/demo/demo_generator.dart';
import 'package:iacaveavin/data/demo/drift_demo_repository.dart';
import 'package:iacaveavin/data/referentiels/referentiel_loader.dart';
import 'package:iacaveavin/domain/wine_query.dart';

import '../helpers.dart';

Set<String> _codes(String file) {
  final json = jsonDecode(File('assets/referentiels/$file').readAsStringSync());
  return {
    for (final v in (json['valeurs'] as List)) (v as Map)['code'] as String,
  };
}

void main() {
  group('CMP-07 jeu de démonstration', () {
    final data = buildDemoDataSet(now: DateTime.utc(2026, 10, 21));

    test('CMP-07 contient exactement 200 fiches', () {
      expect(data.wines, hasLength(demoWineTarget));
    });

    test('CMP-07 toutes les couleurs du dictionnaire sont présentes', () {
      final couleurs = data.cuvees.map((c) => c.couleur.value).toSet();
      expect(couleurs, {
        'rouge',
        'blanc',
        'rose',
        'champagne',
        'effervescent',
        'liquoreux',
        'orange',
        'autre',
      });
    });

    test('CMP-07 millésimes de 2005 à 2024, bornes comprises', () {
      final annees = data.wines.map((w) => int.parse(w.millesime.value));
      expect(annees.reduce((a, b) => a < b ? a : b), 2005);
      expect(annees.reduce((a, b) => a > b ? a : b), 2024);
    });

    test('CMP-07 plusieurs propriétaires et emplacements utilisés', () {
      expect(data.lots.map((l) => l.proprietaireId.value).toSet().length, 3);
      expect(
        data.lots.map((l) => l.emplacementId.value).toSet().length,
        greaterThanOrEqualTo(3),
      );
    });

    test('CMP-07 génération déterministe (mêmes données à chaque appel)', () {
      final again = buildDemoDataSet(now: DateTime.utc(2026, 10, 21));
      expect(
        again.wines.map((w) => w.id.value),
        data.wines.map((w) => w.id.value),
      );
      expect(
        again.producers.map((p) => p.nom.value),
        data.producers.map((p) => p.nom.value),
      );
    });

    test('CMP-07 codes de listes présents dans les référentiels embarqués', () {
      final regions = _codes('regions.json');
      final sousRegions = _codes('sous-regions.json');
      final appellations = _codes('appellations.json');
      final pays = _codes('pays.json');
      final cepages = _codes('cepages.json');
      for (final c in data.cuvees) {
        expect(pays, contains(c.pays.value));
        if (c.region.value != null) expect(regions, contains(c.region.value));
        if (c.sousRegion.value != null) {
          expect(sousRegions, contains(c.sousRegion.value));
        }
        if (c.appellation.value != null) {
          expect(appellations, contains(c.appellation.value));
        }
      }
      for (final w in data.wines) {
        for (final e in jsonDecode(w.cepages.value!) as List) {
          expect(cepages, contains((e as Map)['cepage']));
        }
      }
    });

    test('CMP-07 STK-R1 stock de chaque lot = somme de ses mouvements, '
        'jamais négatif', () {
      final parLot = <String, int>{};
      for (final m in data.movements) {
        expect(m.quantite.value, isNot(0));
        parLot.update(
          m.lotId.value,
          (q) => q + m.quantite.value,
          ifAbsent: () => m.quantite.value,
        );
      }
      expect(parLot.keys.toSet(), data.lots.map((l) => l.id.value).toSet());
      expect(parLot.values.every((q) => q >= 0), isTrue);
      // Quelques fiches épuisées pour exercer le filtre « épuisé » au lot 1.
      expect(parLot.values.where((q) => q == 0), isNotEmpty);
    });
  });

  group('CMP-07 activable et effaçable', () {
    late AppDatabase db;
    late DriftDemoRepository repo;

    setUp(() async {
      db = memoryDatabase();
      repo = DriftDemoRepository(db);
      await CellarBootstrap(db, readAssetFromDisk).ensureInitialized();
    });

    tearDown(() => db.close());

    test('CMP-07 chargement : 200 fiches visibles dans la liste', () async {
      expect(await repo.demoWineCount(), 0);
      final chrono = Stopwatch()..start();
      await repo.load();
      final list = await CellarRepository(db).wineItems();
      chrono.stop();
      // Mesure notée dans docs/journal-lots.md (machine de CI, pas le téléphone).
      // ignore: avoid_print
      print(
        'MESURE chargement démo + lecture liste : ${chrono.elapsedMilliseconds} ms',
      );
      expect(await repo.demoWineCount(), 200);
      expect(list, hasLength(200));
      final sorted = const WineQuery(
        filters: WineFilters(stock: StockFilter.all),
      ).apply(list, year: 2026);
      expect(sorted.first.vintage, '2024');
      expect(sorted.last.vintage, '2005');
      expect(list.where((w) => w.owners.isNotEmpty), hasLength(200));
      expect(list.where((w) => w.locationPath != null), isNotEmpty);
      final withLabels = list.where((w) => w.appellation != null);
      expect(withLabels, isNotEmpty);
      expect(withLabels.first.appellation, isNot(contains('-')));
    });

    test('CMP-07 STK-R3 stock de la liste = somme des mouvements', () async {
      await repo.load();
      final total = (await CellarRepository(
        db,
      ).wineItems()).fold<int>(0, (s, w) => s + w.bottles);
      final sum = db.stockMovements.quantite.sum();
      final row = await (db.selectOnly(
        db.stockMovements,
      )..addColumns([sum])).getSingle();
      expect(total, row.read(sum));
    });

    test('CMP-07 chargement deux fois : pas de doublon', () async {
      await repo.load();
      await repo.load();
      expect(await repo.demoWineCount(), 200);
    });

    test(
      'CMP-07 effacement : la cave principale et ses listes restent',
      () async {
        await repo.load();
        final listsBefore = await db.select(db.listValues).get();
        await repo.erase();
        expect(await repo.demoWineCount(), 0);
        expect(await CellarRepository(db).wineItems(), isEmpty);
        expect(await db.select(db.stockMovements).get(), isEmpty);
        expect(await db.select(db.owners).get(), isEmpty);
        final cellars = await db.select(db.cellars).get();
        expect(cellars, hasLength(1));
        expect(cellars.single.id, isNot(demoCellarId));
        expect(
          await db.select(db.listValues).get(),
          hasLength(listsBefore.length),
        );
      },
    );

    test(
      'CMP-07 une fiche de la cave principale survit à l\'effacement',
      () async {
        final mainId = await CellarBootstrap(
          db,
          readAssetFromDisk,
        ).ensureInitialized();
        final now = DateTime.utc(2026);
        await db
            .into(db.producers)
            .insert(
              ProducersCompanion.insert(
                id: 'p1',
                caveId: mainId,
                createdAt: now,
                updatedAt: now,
                nom: 'Mon domaine',
              ),
            );
        await db
            .into(db.cuvees)
            .insert(
              CuveesCompanion.insert(
                id: 'c1',
                caveId: mainId,
                createdAt: now,
                updatedAt: now,
                domaineId: 'p1',
                pays: 'FR',
                couleur: 'rouge',
              ),
            );
        await db
            .into(db.wines)
            .insert(
              WinesCompanion.insert(
                id: 'w1',
                caveId: mainId,
                createdAt: now,
                updatedAt: now,
                cuveeId: 'c1',
                millesime: '2019',
              ),
            );
        await repo.load();
        await repo.erase();
        final list = await CellarRepository(db).wineItems();
        expect(list.map((w) => w.id), ['w1']);
        expect(list.single.bottles, 0);
        expect(list.single.countryLabel, 'France');
      },
    );
  });
}
