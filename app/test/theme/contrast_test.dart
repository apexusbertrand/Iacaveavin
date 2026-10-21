import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/theme/app_theme.dart';
import 'package:iacaveavin/core/theme/contrast.dart';

/// Seuil WCAG AA pour un texte courant.
const _seuilTexte = 4.5;

Color _c(String hex) => Color(int.parse('FF${hex.substring(1)}', radix: 16));

void main() {
  final tokens = jsonDecode(
    File('../specs/design-tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('contraste : formule WCAG sur des valeurs de référence', () {
    expect(contrastRatio(_c('#FFFFFF'), _c('#000000')), closeTo(21, 0.001));
    // Valeurs mesurées notées dans specs/design-tokens.json.
    expect(contrastRatio(_c('#FFFFFF'), _c('#1C1C1E')), closeTo(17.01, 0.05));
    expect(contrastRatio(_c('#1C1C1E'), _c('#F28C28')), closeTo(6.93, 0.05));
    expect(contrastRatio(_c('#B5520F'), _c('#F6F3F0')), closeTo(4.55, 0.05));
  });

  for (final nomTheme in ['themeClair', 'themeSombre']) {
    final t = (tokens[nomTheme] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, _c(v as String)),
    );
    // Paires texte / fond réellement utilisées par AppTheme et les écrans.
    final paires = <String, (Color, Color)>{
      'onAppBar sur appBar': (t['onAppBar']!, t['appBar']!),
      'primary sur appBar (onglet, icône active)': (
        t['primary']!,
        t['appBar']!,
      ),
      'onPrimary sur primary': (t['onPrimary']!, t['primary']!),
      'texte sur surface': (t['texte']!, t['surface']!),
      'texte sur carte': (t['texte']!, t['carte']!),
      'texteSecondaire sur surface': (t['texteSecondaire']!, t['surface']!),
      'texteSecondaire sur carte': (t['texteSecondaire']!, t['carte']!),
      'primaryTexte sur surface': (t['primaryTexte']!, t['surface']!),
      'primaryTexte sur carte': (t['primaryTexte']!, t['carte']!),
      'secondary sur surface': (t['secondary']!, t['surface']!),
      'secondary sur carte': (t['secondary']!, t['carte']!),
      'carte sur secondary (onSecondary)': (t['carte']!, t['secondary']!),
      'erreur sur surface': (t['erreur']!, t['surface']!),
      'erreur sur carte': (t['erreur']!, t['carte']!),
      'carte sur erreur (onError)': (t['carte']!, t['erreur']!),
      'succes sur surface': (t['succes']!, t['surface']!),
      'succes sur carte': (t['succes']!, t['carte']!),
      'onAppBar sur appBar (snackbar)': (t['onAppBar']!, t['appBar']!),
    };
    paires.forEach((nom, paire) {
      test('NFR-10 contraste $nomTheme : $nom ≥ 4,5:1', () {
        final ratio = contrastRatio(paire.$1, paire.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(_seuilTexte),
          reason: '$nom : ${ratio.toStringAsFixed(2)}:1',
        );
      });
    });
  }

  final vins = tokens['couleursVin'] as Map<String, dynamic>;
  final textes = tokens['texteSurCouleurVin'] as Map<String, dynamic>;
  for (final code in vins.keys.where((k) => !k.startsWith(r'$'))) {
    test('NFR-10 contraste texte sur chip de vin $code ≥ 4,5:1', () {
      final ratio = contrastRatio(
        _c(textes[code] as String),
        _c(vins[code] as String),
      );
      expect(ratio, greaterThanOrEqualTo(_seuilTexte));
      // La fonction utilisée par les widgets renvoie bien ces jetons.
      expect(wineColor(code).fill, _c(vins[code] as String));
      expect(wineColor(code).onFill, _c(textes[code] as String));
    });
  }

  final seuils =
      (tokens['badgeNote'] as Map<String, dynamic>)['seuils'] as List<dynamic>;
  for (final s in seuils.cast<Map<String, dynamic>>()) {
    test('NFR-10 contraste badge de note ${s['libelle']} ≥ 4,5:1', () {
      final ratio = contrastRatio(
        _c(s['texte'] as String),
        _c(s['fond'] as String),
      );
      expect(ratio, greaterThanOrEqualTo(_seuilTexte));
    });
  }

  test('NFR-10 les paires interdites restent sous le seuil (garde-fou)', () {
    final clair = tokens['themeClair'] as Map<String, dynamic>;
    final primary = _c(clair['primary'] as String);
    expect(contrastRatio(_c('#FFFFFF'), primary), lessThan(_seuilTexte));
    expect(
      contrastRatio(primary, _c(clair['surface'] as String)),
      lessThan(_seuilTexte),
    );
    // Le thème n'utilise donc jamais primary comme couleur de texte en clair.
    final theme = AppTheme.light();
    expect(theme.extension<AppPalette>()!.primaryText, isNot(primary));
    expect(
      theme.textButtonTheme.style!.foregroundColor!.resolve({}),
      isNot(primary),
    );
  });
}
