import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/app_language.dart';
import 'package:iacaveavin/domain/app_settings.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final fr = _arb('fr');
  final en = _arb('en');
  final keys = fr.keys.where((k) => !k.startsWith('@')).toSet();

  test('LNG-01 mêmes clés en français et en anglais', () {
    final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
    expect(keys.difference(enKeys), isEmpty, reason: 'absentes en anglais');
    expect(enKeys.difference(keys), isEmpty, reason: 'absentes en français');
  });

  test('LNG-01 mêmes paramètres et aucun texte anglais vide', () {
    for (final k in keys) {
      final value = en[k] as String;
      expect(value.trim(), isNotEmpty, reason: k);
      final meta = fr['@$k'];
      final placeholders = meta is Map && meta['placeholders'] is Map
          ? (meta['placeholders'] as Map).keys
          : const <String>[];
      for (final p in placeholders) {
        expect(value, contains('{$p'), reason: '$k : {$p} manque');
      }
    }
  });

  test(
    'LNG-01 LNG-02 langue effective : téléphone anglais, sinon français',
    () {
      expect(effectiveLanguage(AppLanguage.system, const Locale('en')), 'en');
      expect(
        effectiveLanguage(AppLanguage.system, const Locale('en', 'GB')),
        'en',
      );
      expect(effectiveLanguage(AppLanguage.system, const Locale('fr')), 'fr');
      expect(effectiveLanguage(AppLanguage.system, const Locale('de')), 'fr');
      expect(effectiveLanguage(AppLanguage.en, const Locale('fr')), 'en');
      expect(effectiveLanguage(AppLanguage.fr, const Locale('en')), 'fr');
    },
  );
}
