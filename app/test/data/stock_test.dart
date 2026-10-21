import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/referentiels/referentiel_loader.dart';
import 'package:iacaveavin/data/stock_service.dart';
import 'package:iacaveavin/domain/stock_rules.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../helpers.dart';

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

void main() {
  final f = Fixture();
  setUp(f.setUp);
  tearDown(() => f.db.close());

  test(
    'FIC-01 PRX-01 création : fiche, lot, prix et mouvement d\'entrée',
    () async {
      final d = (await f.repo.wine(f.wine))!;
      expect(d.draft.producer, 'Domaine Test');
      expect(d.bottles, 6);
      expect(d.lots.single.unitPrice, 32.5);
      expect(d.movements.single.type, 'entree');
      expect(d.label('appellation', 'fr-volnay'), 'Volnay');
      final item = (await f.repo.wineItems()).single;
      expect(item.appellation, 'Volnay');
      expect(item.locationIds, {'casierA', 'cave'});
      expect(item.locationPath, 'Cave > Casier A');
      expect(item.searchText, contains('pinot noir'));
    },
  );

  test('STK-01 STK-02 ajouter puis ouvrir des bouteilles', () async {
    await f.stock.add(f.lot, 2);
    await f.stock.open(f.lot, 3);
    final d = (await f.repo.wine(f.wine))!;
    expect(d.bottles, 5);
    expect(d.consumed, 3);
  });

  test(
    'STK-R2 ouvrir plus que le stock est refusé, rien n\'est écrit',
    () async {
      await expectLater(
        f.stock.open(f.lot, 7),
        throwsA(isA<StockRuleException>()),
      );
      expect((await f.repo.wine(f.wine))!.movements, hasLength(1));
    },
  );

  test('STK-03 ajustement à la quantité réelle avec motif', () async {
    final a = await f.stock.adjust(f.lot, 4, 'casse');
    expect(a, isNotNull);
    final d = (await f.repo.wine(f.wine))!;
    expect(d.bottles, 4);
    expect(d.movements.first.type, 'ajustement');
    expect(d.movements.first.quantity, -2);
    expect(d.movements.first.reason, 'casse');
    expect(await f.stock.adjust(f.lot, 4, 'inventaire'), isNull);
  });

  test(
    'STK-05 STK-R5 transfert partiel : lot cible et deux mouvements liés',
    () async {
      await f.stock.transfer(f.lot, 2, toOwnerId: 'o2', toLocationId: 'cave');
      final d = (await f.repo.wine(f.wine))!;
      expect(d.lots, hasLength(2));
      expect(d.bottles, 6);
      expect(d.lots.map((l) => l.bottles).toList()..sort(), [2, 4]);
      final types = d.movements.map((m) => m.type).toSet();
      expect(types, containsAll(['transfert_sortant', 'transfert_entrant']));
      final item = (await f.repo.wineItems()).single;
      expect(item.owners.map((o) => '${o.name} ${o.bottles}'), [
        'Bertrand 4',
        'Julie 2',
      ]);
    },
  );

  test(
    'PRO-02 répartition par propriétaire, du plus gros au plus petit',
    () async {
      await f.repo.addLot(f.wine, const LotDraft(ownerId: 'o2', quantity: 9));
      final item = (await f.repo.wineItems()).single;
      expect(item.owners.first.name, 'Julie');
      expect(item.bottles, 15);
    },
  );

  test(
    'STK-07 annulation : le mouvement et le lot créé disparaissent',
    () async {
      final open = await f.stock.open(f.lot, 1);
      await f.stock.undo(open);
      final t = await f.stock.transfer(f.lot, 1, toOwnerId: 'o2');
      await f.stock.undo(t);
      final d = (await f.repo.wine(f.wine))!;
      expect(d.bottles, 6);
      expect(d.lots, hasLength(1));
      expect(d.movements, hasLength(1));
    },
  );

  test(
    'STK-06 une fiche à 0 bouteille reste en base et se réapprovisionne',
    () async {
      await f.stock.open(f.lot, 6);
      expect((await f.repo.wineItems()).single.bottles, 0);
      await f.stock.add(f.lot, 3);
      expect((await f.repo.wineItems()).single.bottles, 3);
    },
  );

  test('FIC-03 mouvements du plus récent au plus ancien', () async {
    await f.stock.open(f.lot, 1);
    final d = (await f.repo.wine(f.wine))!;
    expect(d.movements.map((m) => m.type), ['ouverture', 'entree']);
  });

  test('FIC-04 dégustation enregistrée et liée à l\'ouverture', () async {
    final a = await f.stock.open(f.lot, 1);
    await f.repo.addTasting(
      wineId: f.wine,
      cellarId: f.cellar,
      score: 17,
      comment: 'Fruit rouge',
      movementId: a.movementIds.single,
    );
    expect((await f.repo.wine(f.wine))!.tastings.single.score, 17);
  });

  test(
    'FIC-01 mise à jour : origine sur la cuvée, garde marquée manuelle',
    () async {
      final d = (await f.repo.wine(f.wine))!;
      await f.repo.updateWine(
        f.wine,
        WineDraft(
          producer: d.draft.producer,
          cuvee: d.draft.cuvee,
          country: 'FR',
          region: 'fr-bourgogne',
          appellation: 'fr-pommard',
          color: 'rouge',
          vintage: '2020',
          gardeStart: 2024,
          gardeEnd: 2035,
          favorite: true,
        ),
      );
      final after = (await f.repo.wine(f.wine))!;
      expect(after.draft.appellation, 'fr-pommard');
      expect(after.draft.vintage, '2020');
      expect(after.gardeSource, 'manuel');
      expect(after.draft.favorite, isTrue);
      expect(after.bottles, 6, reason: 'la mise à jour ne touche pas au stock');
    },
  );

  test('FIC-01 doublon domaine + cuvée + millésime détecté', () async {
    final dup = await f.repo.findDuplicate(
      const WineDraft(
        producer: 'domaine test',
        cuvee: 'Les Essais',
        country: 'FR',
        color: 'rouge',
        vintage: '2019',
      ),
    );
    expect(dup, f.wine);
  });

  test('FIC-01 suppression logique : la fiche quitte la liste', () async {
    await f.repo.deleteWine(f.wine);
    expect(await f.repo.wineItems(), isEmpty);
    final rows = await f.db.select(f.db.wines).get();
    expect(rows.single.deletedAt, isNotNull);
  });
}
