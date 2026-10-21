import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Vérifie que lib/core/theme/design_tokens.g.dart reflète specs/design-tokens.json.
/// En cas d'échec : dart run tool/generate_theme_tokens.dart
void main() {
  final json = jsonDecode(
    File('../specs/design-tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final genere = File('lib/core/theme/design_tokens.g.dart')
      .readAsStringSync()
      .replaceAll(RegExp(r'\s+'), ' ');

  const sections = {
    'marque': 'BrandTokens',
    'themeClair': 'LightTokens',
    'themeSombre': 'DarkTokens',
    'couleursVin': 'WineColorTokens',
    'texteSurCouleurVin': 'OnWineColorTokens',
    'statutGarde': 'CellarStatusTokens',
  };

  sections.forEach((section, classe) {
    test('NFR-10 jetons $section générés dans $classe', () {
      final valeurs = json[section] as Map<String, dynamic>;
      final debut = genere.indexOf('abstract final class $classe {');
      expect(debut, isNot(-1), reason: 'classe $classe absente');
      final bloc = genere.substring(debut, genere.indexOf('}', debut));
      valeurs.forEach((cle, valeur) {
        if (cle.startsWith(r'$')) return;
        final hex = (valeur as String).substring(1).toUpperCase();
        expect(
          bloc,
          contains('static const Color $cle = Color(0xFF$hex);'),
          reason: '$section.$cle doit valoir $valeur',
        );
      });
    });
  });

  test('NFR-10 tailles, espacements et rayons générés', () {
    final typo = json['typographie'] as Map<String, dynamic>;
    final numeriques = {
      'FontSizeTokens': typo['tailles'],
      'SpacingTokens': json['espacements'],
      'RadiusTokens': json['rayons'],
    };
    numeriques.forEach((classe, valeurs) {
      (valeurs as Map<String, dynamic>).forEach((cle, v) {
        expect(
          genere,
          contains('static const double $cle = ${(v as num).toDouble()};'),
          reason: '$classe.$cle',
        );
      });
    });
    expect(
      genere,
      contains(
        'const double minTouchTarget = '
        '${(json['cibleTactileMin'] as num).toDouble()};',
      ),
    );
  });
}
