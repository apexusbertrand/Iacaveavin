import 'package:drift/drift.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/referentiels/referentiel_loader.dart';
import 'package:iacaveavin/data/stock_service.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import 'helpers.dart';

/// Base en mémoire avec une cave, deux propriétaires, deux emplacements
/// et une fiche de 6 bouteilles.
class Fixture {
  late AppDatabase db;
  late CellarRepository repo;
  late StockService stock;
  late String cellar;
  late String wine;
  late String lot;
  final now = DateTime.utc(2026, 10, 21, 9);

  Future<void> setUp() async {
    db = memoryDatabase();
    repo = CellarRepository(db, clock: () => now);
    stock = StockService(db, clock: () => now);
    cellar = await CellarBootstrap(db, readAssetFromDisk).ensureInitialized();
    for (final (id, nom) in [('o1', 'Bertrand'), ('o2', 'Julie')]) {
      await db
          .into(db.owners)
          .insert(
            OwnersCompanion.insert(
              id: id,
              caveId: cellar,
              createdAt: now,
              updatedAt: now,
              nom: nom,
            ),
          );
    }
    for (final (id, nom, parent) in [
      ('cave', 'Cave', null),
      ('casierA', 'Casier A', 'cave'),
    ]) {
      await db
          .into(db.storageLocations)
          .insert(
            StorageLocationsCompanion.insert(
              id: id,
              caveId: cellar,
              createdAt: now,
              updatedAt: now,
              nom: nom,
              typeEmplacement: parent == null ? 'cave' : 'casier',
            ).copyWith(parentId: Value(parent)),
          );
    }
    wine = await repo.createWine(
      const WineDraft(
        producer: 'Domaine Test',
        cuvee: 'Les Essais',
        country: 'FR',
        region: 'fr-bourgogne',
        appellation: 'fr-volnay',
        color: 'rouge',
        vintage: '2019',
        grapes: [GrapeShare('pinot-noir', 100)],
      ),
      cellarId: cellar,
      lot: const LotDraft(
        ownerId: 'o1',
        quantity: 6,
        locationId: 'casierA',
        unitPrice: 32.5,
      ),
    );
    lot = (await repo.wine(wine))!.lots.single.id;
  }
}
