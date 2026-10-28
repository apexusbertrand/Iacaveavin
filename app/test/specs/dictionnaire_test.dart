import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'package:iacaveavin/domain/excel_layout.dart';

import '../helpers.dart';

/// Alignement de la base drift sur specs/dictionnaire-donnees.yaml (règle 9).
///
/// Une table par entité, une colonne par champ stocké, type et caractère
/// obligatoire conformes. Les champs `calcule` ne sont pas stockés ; les champs
/// `action` n'existent qu'à l'import Excel.
void main() {
  final dico = loadYaml(
    File('../specs/dictionnaire-donnees.yaml').readAsStringSync(),
  ) as YamlMap;
  final entites = dico['entites'] as YamlMap;
  final db = memoryDatabase();
  tearDownAll(db.close);
  final tables = {for (final t in db.allTables) t.actualTableName: t};

  const techniques = {'id', 'created_at', 'updated_at', 'deleted_at'};

  DriftSqlType<Object> typeAttendu(YamlMap champ) {
    if (champ['liste'] == 'format') return DriftSqlType.double;
    return switch (champ['type'] as String) {
      'entier' || 'annee' => DriftSqlType.int,
      'decimal' || 'montant' => DriftSqlType.double,
      'booleen' => DriftSqlType.bool,
      _ => DriftSqlType.string,
    };
  }

  test('dictionnaire : une table par entité, aucune table en trop', () {
    expect(tables.keys.toSet(), entites.keys.cast<String>().toSet());
  });

  for (final entry in entites.entries) {
    final nom = entry.key as String;
    final champs = ((entry.value as YamlMap)['champs'] as YamlList)
        .cast<YamlMap>()
        .where((c) => c['type'] != 'calcule' && c['cle'] != 'action')
        .toList();

    test('dictionnaire : colonnes de $nom = champs du dictionnaire', () {
      final table = tables[nom]!;
      final colonnes = {for (final c in table.$columns) c.name: c};
      final attendues = {
        ...techniques,
        if (nom != 'cave') 'cave_id',
        for (final c in champs) c['cle'] as String,
      };
      expect(colonnes.keys.toSet(), attendues);

      for (final champ in champs) {
        final cle = champ['cle'] as String;
        if (cle == 'id') continue;
        final colonne = colonnes[cle]!;
        expect(
          colonne.type,
          typeAttendu(champ),
          reason: '$nom.$cle de type ${champ['type']}',
        );
        final oblig = champ['oblig'] == true;
        expect(
          colonne.$nullable,
          !oblig,
          reason: '$nom.$cle ${oblig ? 'obligatoire' : 'facultatif'}',
        );
      }
    });
  }

  test(
    'dictionnaire : les champs techniques sont obligatoires sauf deleted_at',
    () {
      for (final table in db.allTables) {
        final colonnes = {for (final c in table.$columns) c.name: c};
        expect(colonnes['id']!.$nullable, isFalse);
        expect(colonnes['created_at']!.$nullable, isFalse);
        expect(colonnes['updated_at']!.$nullable, isFalse);
        expect(colonnes['deleted_at']!.$nullable, isTrue);
        if (table.actualTableName != 'cave') {
          expect(colonnes['cave_id']!.$nullable, isFalse);
        }
      }
    },
  );

  test('XLS-01 colonnes Excel = clés excel du dictionnaire, même ordre', () {
    final attendues = <String>[
      for (final entry in entites.entries)
        for (final c
            in ((entry.value as YamlMap)['champs'] as YamlList).cast<YamlMap>())
          if (c['excel'] != null) '${entry.key}.${c['cle']}=${c['excel']}',
    ];
    final par = <String, List<String>>{};
    for (final a in attendues) {
      final onglet = a.split('=').last.replaceFirst('RO:', '').split('/').first;
      par.putIfAbsent(onglet, () => []).add(a);
    }
    String key(ExcelColumn c) => '${c.entity}.${c.key}=${c.dictionaryKey}';
    expect([for (final c in wineColumns) key(c)], par[sheetWines]);
    expect([for (final c in lotColumns) key(c)], par[sheetLots]);
    expect([for (final c in movementColumns) key(c)], par[sheetMovements]);
  });
}
