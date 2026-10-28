// Cadre de migrations (NFR-05). À chaque nouvelle version du schéma :
//   dart run drift_dev make-migrations
// puis ajouter ici le test de migration depuis la version précédente remplie
// du jeu de démonstration (.claude/rules/flutter.md).
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/demo/demo_generator.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

/// Insère des lignes « actuelles » dans une base d'une version précédente,
/// colonne par colonne, sans passer par les classes générées de la version.
Future<void> _insertRaw(
  DatabaseConnectionUser db,
  String table,
  Iterable<Insertable<Object?>> rows,
) async {
  for (final row in rows) {
    final cols = row.toColumns(true);
    final names = cols.keys.map((c) => '"$c"').join(', ');
    final marks = List.filled(cols.length, '?').join(', ');
    // Même codage que l'application : dates en texte ISO 8601.
    final types = db.typeMapping;
    await db.customStatement('INSERT INTO $table ($names) VALUES ($marks)', [
      for (final v in cols.values)
        types.mapToSqlVariable((v as Variable).value),
    ]);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('NFR-05 migration v1 vers v2 : schéma conforme', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  test(
    'NFR-05 migration v1 vers v2 sans perte sur le jeu de démonstration',
    () async {
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
      final data = buildDemoDataSet(now: DateTime.utc(2026, 10, 21));
      await _insertRaw(old, 'cave', [data.cellar]);
      await _insertRaw(old, 'proprietaire', data.owners);
      await _insertRaw(old, 'emplacement', data.locations);
      await _insertRaw(old, 'domaine', data.producers);
      await _insertRaw(old, 'cuvee', data.cuvees);
      await _insertRaw(old, 'fiche_vin', data.wines);
      await _insertRaw(old, 'lot', data.lots);
      await _insertRaw(old, 'mouvement', data.movements);
      await old.close();

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 2);
      final items = await CellarRepository(db).wineItems();
      expect(items, hasLength(200));
      final stock = items.fold<int>(0, (s, w) => s + w.bottles);
      final expected = data.movements.fold<int>(
        0,
        (s, m) => s + m.quantite.value,
      );
      expect(stock, expected);
      // Les nouvelles colonnes existent et sont vides.
      final jobs = await db.select(db.jobs).get();
      expect(jobs, isEmpty);
    },
  );

  test('NFR-05 la version de schéma courante a son instantané figé', () {
    final db = AppDatabase(
      DatabaseConnection(
        // Base jamais ouverte : seul schemaVersion est lu.
        LazyDatabase(() => throw StateError('non ouverte')),
      ),
    );
    addTearDown(db.close);
    expect(GeneratedHelper.versions, contains(db.schemaVersion));
    expect(db.schemaVersion, 2);
  });
}
