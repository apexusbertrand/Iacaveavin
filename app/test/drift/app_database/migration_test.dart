// Cadre de migrations (NFR-05). À chaque nouvelle version du schéma :
//   dart run drift_dev make-migrations
// puis ajouter ici le test de migration depuis la version précédente remplie
// du jeu de démonstration (.claude/rules/flutter.md).
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/db/app_database.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('NFR-05 le schéma courant correspond au schéma figé v1', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
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
  });
}
