// Cadre de migrations (NFR-05). À chaque nouvelle version du schéma :
//   dart run drift_dev make-migrations
// puis ajouter ici le test de migration depuis la version précédente remplie
// du jeu de démonstration (.claude/rules/flutter.md).
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/demo/demo_generator.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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

  test('NFR-05 migration v1 vers la version courante sans perte sur le jeu de démonstration', () async {
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
    await verifier.migrateAndValidate(db, 4);
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
  });

  test('NFR-05 migration v2 vers v3 : schéma conforme', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);
  });

  test('AJO-13 migration v2 vers v3 : photos gardées, sans cadre', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    final data = buildDemoDataSet(now: DateTime.utc(2026, 10, 21));
    await _insertRaw(old, 'cave', [data.cellar]);
    await _insertRaw(old, 'domaine', data.producers);
    await _insertRaw(old, 'cuvee', data.cuvees);
    await _insertRaw(old, 'fiche_vin', data.wines);
    final wineId = data.wines.first.id.value;
    await old.customStatement(
      'INSERT INTO photo (id, cave_id, created_at, updated_at, fiche_id, '
      'chemin, type_photo, principale) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'p1',
        data.cellar.id.value,
        '2026-10-21T00:00:00.000Z',
        '2026-10-21T00:00:00.000Z',
        wineId,
        'photos/$wineId/p1.jpg',
        'etiquette',
        1,
      ],
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);
    final photo = await db.select(db.photos).getSingle();
    expect(photo.chemin, 'photos/$wineId/p1.jpg');
    expect(photo.cheminOriginal, isNull);
    expect(photo.cadre, isNull);
  });

  test('NFR-05 CMP-03 migration v3 vers v4 : liste d\'achats créée', () async {
    final connection = await verifier.startAt(3);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);
    expect(await db.select(db.shoppingItems).get(), isEmpty);
  });

  test('NFR-05 la version de schéma courante a son instantané figé', () {
    final db = AppDatabase(
      DatabaseConnection(
        // Base jamais ouverte : seul schemaVersion est lu.
        LazyDatabase(() => throw StateError('non ouverte')),
      ),
    );
    addTearDown(db.close);
    expect(GeneratedHelper.versions, contains(db.schemaVersion));
    expect(db.schemaVersion, 4);
  });
}
