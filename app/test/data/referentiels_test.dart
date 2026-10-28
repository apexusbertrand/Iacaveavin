import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/referentiels/referentiel_loader.dart';
import 'package:yaml/yaml.dart';

import '../helpers.dart';

void main() {
  final dico = loadYaml(
    File('../specs/dictionnaire-donnees.yaml').readAsStringSync(),
  ) as YamlMap;
  final listes = dico['listes'] as YamlMap;

  test(
    'référentiels : listes fixes alignées sur le dictionnaire, même ordre',
    () {
      final json = jsonDecode(
        File('assets/referentiels/listes-dictionnaire.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final parNom = {
        for (final l in (json['listes'] as List).cast<Map<String, dynamic>>())
          l['liste'] as String: l,
      };
      for (final nom in [
        'couleur',
        'type_vin',
        'signe_qualite',
        'classement',
        'certification',
        'motif_mouvement',
        'critique',
      ]) {
        final codes = (parNom[nom]!['valeurs'] as List)
            .map((v) => (v as Map)['code'])
            .toList();
        expect(
          codes,
          (listes[nom] as YamlMap)['valeurs'],
          reason: 'Relancer : python3 scripts/generer_referentiels.py ($nom)',
        );
      }
      final formats = (parNom['format']!['valeurs'] as List)
          .map((v) => double.parse((v as Map)['code'] as String))
          .toList();
      expect(
        formats,
        ((listes['format'] as YamlMap)['valeurs_cl'] as YamlList)
            .map((v) => (v as num).toDouble())
            .toList(),
      );
    },
  );

  test('référentiels : chaque fichier a une source, des codes uniques et des '
      'parents existants', () {
    final codesParListe = <String, Set<String>>{};
    final parents = <(String, String)>[];
    for (final path in referentielAssets) {
      final json =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      expect(json['source'], isA<String>(), reason: path);
      final lists = json.containsKey('listes')
          ? (json['listes'] as List).cast<Map<String, dynamic>>()
          : [json];
      for (final list in lists) {
        final codes = <String>{};
        for (final v
            in (list['valeurs'] as List).cast<Map<String, dynamic>>()) {
          expect(
            codes.add(v['code'] as String),
            isTrue,
            reason: '${list['liste']} : code ${v['code']} en double',
          );
          expect((v['libelle'] as String).trim(), isNotEmpty);
          if (v['parent_code'] != null) {
            parents.add((list['liste'] as String, v['parent_code'] as String));
          }
        }
        codesParListe[list['liste'] as String] = codes;
      }
    }
    // Hiérarchie du dictionnaire : région -> pays, sous-région -> région,
    // appellation -> sous-région (ou région quand il n'y a pas de sous-région).
    const parentAttendu = {
      'region': ['pays'],
      'sous_region': ['region'],
      'appellation': ['sous_region', 'region'],
    };
    for (final (liste, parent) in parents) {
      final ok = parentAttendu[liste]!.any(
        (p) => codesParListe[p]!.contains(parent),
      );
      expect(ok, isTrue, reason: '$liste : parent inconnu $parent');
    }
    // Appellation jamais un signe de qualité ni un classement (dictionnaire).
    final interdits = RegExp(
      r"^(AOP|AOC|IGP|appellation d'origine)",
      caseSensitive: false,
    );
    expect(codesParListe['appellation']!.where(interdits.hasMatch), isEmpty);
  });

  test(
    'PAR-03 référentiels chargés une seule fois au premier lancement',
    () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final bootstrap = CellarBootstrap(db, readAssetFromDisk);
      final id1 = await bootstrap.ensureInitialized();
      final count1 = (await db.select(db.listValues).get()).length;
      final id2 = await bootstrap.ensureInitialized();
      final count2 = (await db.select(db.listValues).get()).length;
      expect(id2, id1);
      expect(count1, greaterThan(500));
      expect(count2, count1);
      final rose =
          await (db.select(db.listValues)..where(
                (v) => v.liste.equals('couleur') & v.code.equals('rose'),
              ))
              .getSingle();
      expect(rose.libelle, 'Rosé');
      expect(await db.select(db.cellars).get(), hasLength(1));
    },
  );

  test('règles de garde : la copie embarquée est identique à specs/', () {
    expect(
      File('assets/regles/regles-garde.yaml').readAsStringSync(),
      File('../specs/regles-garde.yaml').readAsStringSync(),
      reason: 'Recopier specs/regles-garde.yaml dans app/assets/regles/',
    );
  });
}
