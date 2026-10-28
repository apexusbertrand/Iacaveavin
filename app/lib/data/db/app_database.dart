import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
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
    ShoppingItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base de l'application, ouverte dans un isolate dédié par drift_flutter.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'iacaveavin'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      // v2 (lot 2a) : suivi des jobs d'enrichissement (dictionnaire, job).
      from1To2: (m, schema) async {
        await m.addColumn(schema.job, schema.job.envoyeLe);
        await m.addColumn(schema.job, schema.job.reponse);
      },
      // v3 (évolution 1 du 2026-10-26) : recadrage des photos (AJO-13).
      from2To3: (m, schema) async {
        await m.addColumn(schema.photo, schema.photo.cheminOriginal);
        await m.addColumn(schema.photo, schema.photo.cadre);
      },
      // v4 (lot 4) : liste d'achats (CMP-03).
      from3To4: (m, schema) async {
        await m.createTable(schema.listeAchat);
      },
      // v5 : photos rattachées à une dégustation (CMP-08).
      from4To5: (m, schema) async {
        await m.addColumn(schema.photo, schema.photo.degustationId);
        await m.create(schema.idxPhotoDegustation);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
