import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/app_info.dart';
import 'package:yaml/yaml.dart';

const _id = r'[A-Z]{2,4}-(?:R)?\d{1,2}';

void main() {
  test('NFR-14 chaque identifiant cité par un test existe dans les docs', () {
    final docs = [
      '../docs/04-modele-donnees.md',
      '../docs/05-fonctionnel.md',
      '../docs/07-exigences-non-fonctionnelles.md',
    ].map((p) => File(p).readAsStringSync()).join('\n');
    final connus = RegExp(_id).allMatches(docs).map((m) => m[0]!).toSet();
    final appel = RegExp(r'''\b(?:test|testWidgets|group)\(\s*(['"])(.*?)\1''');
    final cites = <String>{};
    for (final dir in ['test', 'integration_test']) {
      if (!Directory(dir).existsSync()) continue;
      for (final f in Directory(
        dir,
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('_test.dart')) continue;
        for (final m in appel.allMatches(f.readAsStringSync())) {
          cites.addAll(RegExp(_id).allMatches(m[2]!).map((x) => x[0]!));
        }
      }
    }
    expect(cites, isNotEmpty);
    expect(cites.difference(connus), isEmpty);
    expect(File('../scripts/matrice_exigences.py').existsSync(), isTrue);
  });

  test(
    'NFR-15 la CI lance contrat, analyse, format, tests, matrice et build',
    () {
      final workflow = loadYaml(
        File('../.github/workflows/app.yml').readAsStringSync(),
      ) as YamlMap;
      final etapes =
          ((workflow['jobs'] as YamlMap)['verifier'] as YamlMap)['steps']
              as YamlList;
      final commandes = etapes
          .whereType<YamlMap>()
          .map((s) => '${s['run'] ?? ''}')
          .join('\n');
      for (final attendu in [
        'scripts/valider_contrat.py',
        'scripts/verifier_regles.py',
        'flutter analyze',
        'dart format',
        'flutter test',
        'scripts/matrice_exigences.py --lot 0',
        'flutter build apk',
      ]) {
        expect(commandes, contains(attendu));
      }
      final on = workflow['on'] as YamlMap;
      expect(on.containsKey('push'), isTrue);
      expect(on.containsKey('pull_request'), isTrue);
      expect(((on['push'] as YamlMap)['tags'] as YamlList), contains('v*'));
    },
  );

  test('NFR-06 aucun secret ni keystore suivi par git', () {
    final ignore = File('../.gitignore').readAsStringSync();
    for (final motif in ['*.jks', '*.keystore', 'key.properties', '.env']) {
      expect(ignore, contains(motif));
    }
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('storePassword = "')));
    expect(gradle, contains('key.properties'));
  });

  test('NFR-15 identifiant Android et version alignés sur docs/09', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('applicationId = "fr.apexus.iacaveavin"'));
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final version = pubspec['version'] as String;
    expect(version, matches(RegExp(r'^\d+\.\d+\.\d+\+\d+$')));
    expect(version.split('+').first, appVersion);
  });
}
