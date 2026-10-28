import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/comfort_repository.dart';
import 'package:iacaveavin/domain/comfort.dart';

import '../fixture.dart';

void main() {
  final f = Fixture();
  late ComfortRepository comfort;
  setUp(() async {
    await f.setUp();
    comfort = ComfortRepository(f.db, clock: () => f.now);
  });
  tearDown(() => f.db.close());

  test('CMP-03 liste d\'achats : ajout, pas de doublon, acheté, '
      'suppression logique', () async {
    final a = await comfort.addShopping(
      cellarId: f.cellar,
      label: 'Domaine Test 2019',
      wineId: f.wine,
      quantity: 6,
    );
    final again = await comfort.addShopping(
      cellarId: f.cellar,
      label: 'Domaine Test 2019',
      wineId: f.wine,
    );
    expect(again, a);
    final b = await comfort.addShopping(
      cellarId: f.cellar,
      label: ' Repéré chez le caviste ',
      note: '  ',
    );
    var list = await comfort.watchShopping().first;
    expect(list, hasLength(2));
    final repere = list.firstWhere((x) => x.id == b);
    expect(repere.libelle, 'Repéré chez le caviste');
    expect(repere.note, isNull);

    await comfort.setBought(a, true);
    list = await comfort.watchShopping().first;
    expect(list.map((x) => x.id), [b, a]);
    expect(list.last.achete, isTrue);

    // Une fois acheté, le vin peut revenir dans la liste.
    final c = await comfort.addShopping(
      cellarId: f.cellar,
      label: 'Domaine Test 2019',
      wineId: f.wine,
    );
    expect(c, isNot(a));

    await comfort.deleteShopping(b);
    list = await comfort.watchShopping().first;
    expect(list.map((x) => x.id), isNot(contains(b)));
    final row = await (f.db.select(
      f.db.shoppingItems,
    )..where((x) => x.id.equals(b))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('CMP-05 historique des dégustations, plus récentes en tête', () async {
    await f.repo.addTasting(
      wineId: f.wine,
      cellarId: f.cellar,
      score: 16,
      dish: 'Pigeon',
      date: '2026-01-10',
    );
    await f.repo.addTasting(
      wineId: f.wine,
      cellarId: f.cellar,
      comment: 'Plus ouvert',
      date: '2026-09-02',
    );
    final list = await comfort.watchTastings().first;
    expect(list.map((t) => t.date), ['2026-09-02', '2026-01-10']);
    expect(list.first.wineName, 'Domaine Test · Les Essais');
    expect(list.first.vintage, '2019');
    expect(list.first.colorCode, 'rouge');
    expect(list.last.score, 16);
    expect(list.last.dish, 'Pigeon');
  });

  test('EMP-03 ranger : positions sans mouvement, transfert d\'une '
      'bouteille vers une case', () async {
    await f.repo.setLotPositions(f.lot, 'A1');
    var lots = await f.repo.stockedLots();
    expect(lots.single.positions, 'A1');
    expect(lots.single.ownerId, 'o1');
    expect((await f.repo.wine(f.wine))!.movements, hasLength(1));
    expect(unplacedBottles(lots), 5);

    await f.stock.transfer(
      f.lot,
      1,
      toOwnerId: 'o1',
      toLocationId: 'cave',
      toPositions: 'B2',
    );
    lots = await f.repo.stockedLots();
    final moved = lots.firstWhere((x) => x.locationId == 'cave');
    expect(moved.bottles, 1);
    expect(moved.positions, 'B2');
    expect((await f.repo.wine(f.wine))!.bottles, 6);
  });
}
