import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Base locale de la cave. Version du schéma = numéro de migration.
///
/// Toute évolution du schéma : incrémenter [schemaVersion], lancer
/// `dart run drift_dev make-migrations`, écrire l'étape dans [migration]
/// et compléter le test généré dans test/drift/ (NFR-05).
@DriftDatabase(
  tables: [
    Cellars,
    Producers,
    Cuvees,
    Wines,
    CriticScores,
    StockLots,
    StockMovements,
    Tastings,
    MarketPrices,
    Photos,
    Provenances,
    StorageLocations,
    Owners,
    ListValues,
    Jobs,
    SavedStatViews,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base de l'application, ouverte dans un isolate dédié par drift_flutter.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'iacaveavin'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Les étapes numérotées arriveront ici (stepByStep généré par drift_dev).
      throw UnsupportedError('Migration $from -> $to non prévue');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
