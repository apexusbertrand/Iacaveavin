import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/stats_repository.dart';
import 'package:iacaveavin/domain/stats.dart';

import '../fixture.dart';

void main() {
  test(
    'STA-02 faits par lot : stock par mouvements, ouvertures, prix marché',
    () async {
      final f = Fixture();
      await f.setUp();
      addTearDown(f.db.close);
      await f.stock.open(f.lot, 2);
      final facts = await StatsRepository(f.db).facts();
      final fact = facts.single;
      expect(fact.bottles, 4);
      expect(fact.openings.single.$2, 2);
      expect(fact.keys[StatDimension.appellation], 'fr-volnay');
      expect(fact.keys[StatDimension.mainGrape], 'pinot-noir');
      expect(fact.keys[StatDimension.location], 'casierA');
      expect(fact.unitPrice, 32.5);
    },
  );

  test('STA-05 favori enregistré, relu, supprimé', () async {
    final f = Fixture();
    await f.setUp();
    addTearDown(f.db.close);
    final repo = StatsRepository(f.db);
    final id = await repo.saveView(
      cellarId: f.cellar,
      name: 'Rouges par millésime',
      query: const StatQuery(
        measure: StatMeasure.bottles,
        dim1: StatDimension.vintage,
        filters: {
          StatDimension.color: {'rouge'},
        },
      ),
      chart: StatChart.line,
    );
    final view = (await repo.watchViews().first).single;
    expect(view.name, 'Rouges par millésime');
    expect(view.chart, StatChart.line);
    expect(view.query.filters[StatDimension.color], {'rouge'});
    await repo.deleteView(id);
    expect(await repo.watchViews().first, isEmpty);
  });

  test(
    'STA-06 5 000 fiches lues et agrégées en moins d\'une seconde',
    () async {
      final f = Fixture();
      await f.setUp();
      addTearDown(f.db.close);
      final now = DateTime.utc(2026, 10, 27);
      await f.db.batch((b) {
        for (var i = 0; i < 5000; i++) {
          b.insert(
            f.db.producers,
            ProducersCompanion.insert(
              id: 'p$i',
              caveId: f.cellar,
              createdAt: now,
              updatedAt: now,
              nom: 'Domaine $i',
            ),
          );
          b.insert(
            f.db.cuvees,
            CuveesCompanion.insert(
              id: 'c$i',
              caveId: f.cellar,
              createdAt: now,
              updatedAt: now,
              domaineId: 'p$i',
              pays: 'FR',
              couleur: ['rouge', 'blanc', 'rose'][i % 3],
            ),
          );
          b.insert(
            f.db.wines,
            WinesCompanion.insert(
              id: 'w$i',
              caveId: f.cellar,
              createdAt: now,
              updatedAt: now,
              cuveeId: 'c$i',
              millesime: '${1990 + i % 35}',
            ).copyWith(gardeDebut: Value(2020 + i % 12), gardeFin: Value(2035)),
          );
          b.insert(
            f.db.stockLots,
            StockLotsCompanion.insert(
              id: 'l$i',
              caveId: f.cellar,
              createdAt: now,
              updatedAt: now,
              ficheId: 'w$i',
              proprietaireId: 'o1',
            ).copyWith(prixAchatUnitaire: Value(10.0 + i % 50)),
          );
          b.insert(
            f.db.stockMovements,
            StockMovementsCompanion.insert(
              id: 'm$i',
              caveId: f.cellar,
              createdAt: now,
              updatedAt: now,
              lotId: 'l$i',
              typeMouvement: 'entree',
              quantite: 6,
              dateMouvement: '2025-01-01',
            ),
          );
        }
      });
      final watch = Stopwatch()..start();
      final facts = await StatsRepository(f.db).facts();
      final r = aggregate(
        facts,
        const StatQuery(
          measure: StatMeasure.purchaseValue,
          dim1: StatDimension.vintage,
          dim2: StatDimension.color,
        ),
        year: 2026,
        now: now,
      );
      watch.stop();
      debugPrint(
        'STA-06 : ${facts.length} lots en ${watch.elapsedMilliseconds} ms',
      );
      expect(facts, hasLength(5001));
      expect(r.keys1, hasLength(35));
      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
    },
  );
}
