import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/garde_rules.dart';
import 'package:yaml/yaml.dart';

void main() {
  final yaml = loadYaml(
    File('assets/regles/regles-garde.yaml').readAsStringSync(),
  ) as YamlMap;
  final rules = [
    for (final r in (yaml['regles'] as YamlList).cast<YamlMap>())
      GardeRule.fromJson(r),
  ];

  GardeEstimate? e(GardeInput w) => estimateGarde(rules, w);

  test('garde estimée : la première règle qui correspond s\'applique', () {
    final pauillac = e(
      const GardeInput(
        color: 'rouge',
        vintage: '2016',
        region: 'Bordeaux',
        classification: 'Grand Cru Classé',
      ),
    )!;
    expect(pauillac.ruleId, 'rouge_bordeaux_classe');
    expect((pauillac.start, pauillac.peak, pauillac.end), (2024, 2031, 2046));
    expect(
      e(const GardeInput(color: 'rouge', vintage: '2016', region: 'Bordeaux'))!
          .ruleId,
      'rouge_bordeaux',
    );
    expect(
      e(
        const GardeInput(
          color: 'rouge',
          vintage: '2018',
          appellation: 'Côte-Rôtie',
        ),
      )!.ruleId,
      'rouge_rhone_nord',
    );
    expect(e(const GardeInput(color: 'rose', vintage: '2024'))!.ruleId, 'rose');
  });

  test('garde estimée : comparaison sans accents ni casse', () {
    expect(
      e(
        const GardeInput(
          color: 'rouge',
          vintage: '2019',
          appellation: 'chateauneuf-du-pape',
        ),
      )!.ruleId,
      'rouge_chateauneuf',
    );
  });

  test(
    'garde estimée : champagne millésimé ou NM depuis l\'année d\'achat',
    () {
      expect(
        e(const GardeInput(color: 'champagne', vintage: '2015'))!.ruleId,
        'champagne_millesime',
      );
      final nm = e(
        const GardeInput(color: 'champagne', vintage: 'NM', purchaseYear: 2025),
      )!;
      expect(nm.ruleId, 'champagne_nm');
      expect((nm.start, nm.end), (2025, 2029));
      expect(e(const GardeInput(color: 'champagne', vintage: 'NM')), isNull);
    },
  );

  test('garde estimée : règle par défaut en dernier recours', () {
    expect(
      e(const GardeInput(color: 'autre', vintage: '2020'))!.ruleId,
      'defaut',
    );
  });
}
