// Génère lib/core/theme/design_tokens.g.dart depuis specs/design-tokens.json.
//
// Usage, depuis app/ : dart run tool/generate_theme_tokens.dart
// Le test test/theme/design_tokens_test.dart échoue si le fichier généré
// ne correspond plus au JSON : relancer ce script après toute modification.
import 'dart:convert';
import 'dart:io';

const sourcePath = '../specs/design-tokens.json';
const outputPath = 'lib/core/theme/design_tokens.g.dart';

void main() {
  final json =
      jsonDecode(File(sourcePath).readAsStringSync()) as Map<String, dynamic>;
  File(outputPath).writeAsStringSync(generateTokens(json));
  Process.runSync('dart', ['format', outputPath]);
  stdout.writeln('$outputPath généré depuis $sourcePath');
}

String generateTokens(Map<String, dynamic> json) {
  final b = StringBuffer()
    ..writeln('// GÉNÉRÉ par tool/generate_theme_tokens.dart depuis')
    ..writeln('// specs/design-tokens.json (version ${json['version']}).')
    ..writeln('// Ne pas modifier à la main.')
    ..writeln('// ignore_for_file: constant_identifier_names')
    ..writeln()
    ..writeln("import 'dart:ui';")
    ..writeln();

  void colorClass(String className, Map<String, dynamic> values) {
    b.writeln('abstract final class $className {');
    values.forEach((key, value) {
      if (key.startsWith(r'$')) return;
      b.writeln('  static const Color $key = Color(${_hex(value as String)});');
    });
    b.writeln('}');
    b.writeln();
  }

  void numClass(String className, Map<String, dynamic> values) {
    b.writeln('abstract final class $className {');
    values.forEach((key, value) {
      b.writeln('  static const double $key = ${(value as num).toDouble()};');
    });
    b.writeln('}');
    b.writeln();
  }

  colorClass('BrandTokens', json['marque'] as Map<String, dynamic>);
  colorClass('LightTokens', json['themeClair'] as Map<String, dynamic>);
  colorClass('DarkTokens', json['themeSombre'] as Map<String, dynamic>);
  colorClass('WineColorTokens', json['couleursVin'] as Map<String, dynamic>);
  colorClass(
    'OnWineColorTokens',
    json['texteSurCouleurVin'] as Map<String, dynamic>,
  );
  colorClass('CellarStatusTokens', json['statutGarde'] as Map<String, dynamic>);

  final typo = json['typographie'] as Map<String, dynamic>;
  numClass('FontSizeTokens', typo['tailles'] as Map<String, dynamic>);
  b.writeln('abstract final class FontWeightTokens {');
  (typo['graisses'] as Map<String, dynamic>).forEach((key, value) {
    b.writeln('  static const FontWeight $key = FontWeight.w$value;');
  });
  b.writeln('}');
  b.writeln();
  numClass('SpacingTokens', json['espacements'] as Map<String, dynamic>);
  numClass('RadiusTokens', json['rayons'] as Map<String, dynamic>);

  b.writeln('abstract final class ScoreBadgeTokens {');
  b.writeln('  /// Seuils sur 100, du plus haut au plus bas.');
  b.writeln(
    '  static const List<({int min, Color fond, Color texte})> seuils = [',
  );
  final seuils = (json['badgeNote'] as Map<String, dynamic>)['seuils'] as List;
  for (final s in seuils.cast<Map<String, dynamic>>()) {
    b.writeln(
      '    (min: ${s['min']}, fond: Color(${_hex(s['fond'] as String)}), '
      'texte: Color(${_hex(s['texte'] as String)})),',
    );
  }
  b.writeln('  ];');
  b.writeln('}');
  b.writeln();
  b.writeln(
    'const double minTouchTarget = ${(json['cibleTactileMin'] as num).toDouble()};',
  );
  return b.toString();
}

String _hex(String value) {
  final hex = value.replaceFirst('#', '').toUpperCase();
  if (hex.length != 6) {
    throw FormatException('Couleur attendue au format #RRGGBB : $value');
  }
  return '0xFF$hex';
}
