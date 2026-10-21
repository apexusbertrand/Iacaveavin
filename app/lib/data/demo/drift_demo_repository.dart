import 'package:drift/drift.dart';

import '../../domain/demo_data_repository.dart';
import '../db/app_database.dart';
import 'demo_generator.dart';

/// Jeu de démonstration stocké dans la cave [demoCellarId].
///
/// L'effacement est physique : ce sont des données fictives, pas des données
/// de l'utilisateur (la règle de suppression logique ne s'applique pas).
class DriftDemoRepository implements DemoDataRepository {
  DriftDemoRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<int> demoWineCount() async {
    final count = _db.wines.id.count();
    final query = _db.selectOnly(_db.wines)
      ..addColumns([count])
      ..where(_db.wines.caveId.equals(demoCellarId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  @override
  Future<void> load() async {
    if (await demoWineCount() > 0) return;
    final data = buildDemoDataSet(now: _clock());
    await _db.transaction(() async {
      await _db.into(_db.cellars).insertOnConflictUpdate(data.cellar);
      await _db.batch((b) {
        b.insertAll(_db.owners, data.owners);
        b.insertAll(_db.storageLocations, data.locations);
        b.insertAll(_db.producers, data.producers);
        b.insertAll(_db.cuvees, data.cuvees);
        b.insertAll(_db.wines, data.wines);
        b.insertAll(_db.stockLots, data.lots);
        b.insertAll(_db.stockMovements, data.movements);
      });
    });
  }

  @override
  Future<void> erase() async {
    await _db.transaction(() async {
      // Ordre inverse des dépendances, pour respecter les clés étrangères.
      final scoped = <TableInfo<Table, dynamic>>[
        _db.jobs,
        _db.provenances,
        _db.photos,
        _db.marketPrices,
        _db.tastings,
        _db.criticScores,
        _db.stockMovements,
        _db.stockLots,
        _db.wines,
        _db.cuvees,
        _db.producers,
        _db.storageLocations,
        _db.owners,
        _db.listValues,
        _db.savedStatViews,
      ];
      for (final table in scoped) {
        await _db.customUpdate(
          'DELETE FROM ${table.actualTableName} WHERE cave_id = ?',
          variables: [Variable.withString(demoCellarId)],
          updates: {table},
          updateKind: UpdateKind.delete,
        );
      }
      await (_db.delete(
        _db.cellars,
      )..where((c) => c.id.equals(demoCellarId))).go();
    });
  }
}
