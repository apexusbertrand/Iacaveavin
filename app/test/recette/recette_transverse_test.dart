import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/demo/demo_generator.dart';
import 'package:iacaveavin/data/stock_service.dart';
import 'package:iacaveavin/domain/stock_rules.dart';

import '../fixture.dart';
import 'invariants.dart';

void main() {
  test(
    'NFR-01 recette transverse sur 5 000 fiches : stock égal aux mouvements, '
    'aucune valeur sans source, aucun libellé technique',
    () async {
      final f = Fixture();
      await f.setUp();
      addTearDown(f.db.close);
      final now = DateTime.utc(2026, 11, 14);
      final data = buildDemoDataSet(now: now, wineTarget: 5000);
      await f.db.transaction(() async {
        await f.db.into(f.db.cellars).insertOnConflictUpdate(data.cellar);
        await f.db.batch((b) {
          b.insertAll(f.db.owners, data.owners);
          b.insertAll(f.db.storageLocations, data.locations);
          b.insertAll(f.db.producers, data.producers);
          b.insertAll(f.db.cuvees, data.cuvees);
          b.insertAll(f.db.wines, data.wines);
          b.insertAll(f.db.stockLots, data.lots);
          b.insertAll(f.db.stockMovements, data.movements);
        });
      });
      expect(await recetteViolations(f.db), isEmpty);

      // 30 mouvements variés, puis le stock reste juste (critère du lot 1).
      final stock = StockService(f.db, clock: () => now);
      final lots = data.lots.take(10).map((l) => l.id.value).toList();
      for (final lot in lots) {
        await stock.add(lot, 2);
        await stock.open(lot, 1);
        await stock.adjust(lot, 4, adjustmentReasons.first);
      }
      expect(await recetteViolations(f.db), isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
