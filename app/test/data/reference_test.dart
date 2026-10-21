import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/reference_repository.dart';
import 'package:iacaveavin/domain/wine_detail.dart';

import '../fixture.dart';

void main() {
  final f = Fixture();
  late ReferenceRepository ref;
  setUp(() async {
    await f.setUp();
    ref = ReferenceRepository(f.db, clock: () => f.now);
  });
  tearDown(() => f.db.close());

  group('propriétaires', () {
    test('PRO-01 un seul propriétaire par défaut', () async {
      await ref.saveOwner(
        id: 'o1',
        cellarId: f.cellar,
        name: 'Bertrand',
        isDefault: true,
      );
      await ref.saveOwner(
        id: 'o2',
        cellarId: f.cellar,
        name: 'Julie',
        isDefault: true,
      );
      final owners = await ref.owners();
      expect(owners.where((o) => o.isDefault).map((o) => o.name), ['Julie']);
      expect(await ref.defaultOwner(f.cellar), 'o2');
    });

    test(
      'PRO-01 stock par propriétaire ; un propriétaire avec lots reste',
      () async {
        final owners = {for (final o in await ref.owners()) o.id: o};
        expect(owners['o1']!.bottles, 6);
        expect(owners['o2']!.bottles, 0);
        await expectLater(
          ref.deleteOwner('o1'),
          throwsA(isA<ReferenceException>()),
        );
        await ref.deleteOwner('o2');
        expect((await ref.owners()).map((o) => o.id), ['o1']);
      },
    );
  });

  group('emplacements', () {
    test('EMP-01 arbre sur 4 niveaux au plus', () async {
      final meuble = await ref.saveLocation(
        cellarId: f.cellar,
        name: 'Armoire',
        type: 'meuble',
        parentId: 'casierA',
      );
      final clayette = await ref.saveLocation(
        cellarId: f.cellar,
        name: 'Clayette',
        type: 'clayette',
        parentId: meuble,
      );
      await expectLater(
        ref.saveLocation(
          cellarId: f.cellar,
          name: 'Trop profond',
          type: 'autre',
          parentId: clayette,
        ),
        throwsA(isA<ReferenceException>()),
      );
      final tree = await ref.locations();
      expect(tree.map((l) => '${l.depth}:${l.name}'), [
        '0:Cave',
        '1:Casier A',
        '2:Armoire',
        '3:Clayette',
      ]);
    });

    test('EMP-02 grille de 1 à 26 lignes et 1 à 50 colonnes', () async {
      await expectLater(
        ref.saveLocation(
          cellarId: f.cellar,
          name: 'X',
          type: 'casier',
          rows: 27,
          cols: 5,
        ),
        throwsA(isA<ReferenceException>()),
      );
      final id = await ref.saveLocation(
        cellarId: f.cellar,
        name: 'Casier B',
        type: 'casier',
        rows: 2,
        cols: 2,
      );
      final b = (await ref.locations()).firstWhere((l) => l.id == id);
      expect(b.capacity, 4);
    });

    test(
      'EMP-05 taux de remplissage et alerte au-delà de la capacité',
      () async {
        await ref.saveLocation(
          id: 'casierA',
          cellarId: f.cellar,
          name: 'Casier A',
          type: 'casier',
          parentId: 'cave',
          capacity: 4,
        );
        final tree = {for (final l in await ref.locations()) l.id: l};
        expect(tree['casierA']!.bottles, 6);
        expect(tree['casierA']!.fillRate, 1.5);
        expect(tree['casierA']!.overCapacity, isTrue);
        expect(
          tree['cave']!.bottles,
          6,
          reason: 'compte les sous-emplacements',
        );
      },
    );

    test('EMP-01 un emplacement occupé ne se supprime pas', () async {
      await expectLater(
        ref.deleteLocation('casierA'),
        throwsA(isA<ReferenceException>()),
      );
    });
  });

  group('listes', () {
    test('PAR-01 toutes les listes modifiables du dictionnaire', () {
      expect(editableLists, isNot(contains('couleur')));
      expect(editableLists, containsAll(['pays', 'appellation', 'cepage']));
    });

    test('PAR-02 ajouter, renommer, réordonner, désactiver', () async {
      final code = await ref.addValue(
        list: 'fournisseur',
        cellarId: f.cellar,
        label: 'Cave du Château',
      );
      expect(code, 'cave-du-chateau');
      await expectLater(
        ref.addValue(
          list: 'fournisseur',
          cellarId: f.cellar,
          label: 'cave du château',
        ),
        throwsA(isA<ReferenceException>()),
      );
      await ref.addValue(
        list: 'fournisseur',
        cellarId: f.cellar,
        label: 'Salon',
      );
      var values = await ref.values('fournisseur');
      await ref.renameValue(values.first.id, 'Cave du Château Neuf');
      await ref.reorder([values.last.id, values.first.id]);
      await ref.setActive(values.last.id, false);
      values = await ref.values('fournisseur');
      expect(values.map((v) => v.label), ['Salon', 'Cave du Château Neuf']);
      expect(values.first.active, isFalse);
      expect(await ref.values('fournisseur', activeOnly: true), hasLength(1));
    });

    test('PAR-02 suppression interdite pour une valeur utilisée', () async {
      final volnay = (await ref.values('appellation'))
          .firstWhere((v) => v.code == 'fr-volnay');
      expect(await ref.usage('appellation', 'fr-volnay'), 1);
      await expectLater(
        ref.deleteValue(volnay.id),
        throwsA(isA<ReferenceException>()),
      );
      final bourgogne = (await ref.values('region'))
          .firstWhere((v) => v.code == 'fr-bourgogne');
      expect(await ref.usage('region', bourgogne.code), greaterThan(1));
    });

    test(
      'PAR-02 fusion de deux doublons : les fiches sont re-pointées',
      () async {
        await ref.addValue(
          list: 'cepage',
          cellarId: f.cellar,
          label: 'Pinot N.',
        );
        final values = await ref.values('cepage');
        final doublon = values.firstWhere((v) => v.label == 'Pinot N.');
        final pinot = values.firstWhere((v) => v.code == 'pinot-noir');
        await ref.merge(pinot.id, doublon.id);
        final d = (await f.repo.wine(f.wine))!;
        expect(d.draft.grapes.single.code, doublon.code);
        expect(
          (await ref.values('cepage')).where((v) => v.code == 'pinot-noir'),
          isEmpty,
        );
        // L'appellation fusionnée re-pointe la cuvée.
        final appellations = await ref.values('appellation');
        final volnay = appellations.firstWhere((v) => v.code == 'fr-volnay');
        final pommard = appellations.firstWhere((v) => v.code == 'fr-pommard');
        await ref.merge(volnay.id, pommard.id);
        expect((await f.repo.wine(f.wine))!.draft.appellation, 'fr-pommard');
      },
    );

    test('PAR-04 export puis import CSV, tout ou rien', () async {
      final csv = await ref.exportCsv('certification');
      expect(csv.split('\n').first, 'code;libelle;parent;ordre;actif');
      final r = await ref.importCsv(
        'certification',
        '$csv"terra-vitis";"Terra Vitis; certifié";;9;1\n',
        cellarId: f.cellar,
      );
      expect(r.created, 1);
      expect(r.updated, 5);
      expect(
        (await ref.values('certification')).last.label,
        'Terra Vitis; certifié',
      );
      final before = (await ref.values('certification')).length;
      await expectLater(
        ref.importCsv(
          'certification',
          'code;libelle\nx;y\n;sans code\n',
          cellarId: f.cellar,
        ),
        throwsA(isA<ReferenceException>()),
      );
      expect((await ref.values('certification')).length, before);
    });
  });

  test('PRO-02 la fiche affiche la répartition par propriétaire', () async {
    await f.repo.addLot(f.wine, const LotDraft(ownerId: 'o2', quantity: 2));
    final d = (await f.repo.wine(f.wine))!;
    expect(d.lots.map((l) => '${l.ownerName} ${l.bottles}'), [
      'Bertrand 6',
      'Julie 2',
    ]);
  });
}
