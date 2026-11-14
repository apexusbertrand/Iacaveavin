import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/label_translator.dart';

import '../fakes.dart';
import 'wine_flow_test.dart' show seedTwo;

void main() {
  final json = jsonDecode(
    File('assets/referentiels/en.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final tr = LabelTranslator.fromJson(json['valeurs'] as Map<String, dynamic>);

  test('LNG-03 valeur livrée traduite, valeur renommée gardée', () {
    expect(tr.label('couleur:rouge', 'Rouge'), 'Red');
    expect(tr.label('region:fr-bourgogne', 'Bourgogne'), 'Burgundy');
    expect(tr.label('pays:IT', 'Italie'), 'Italy');
    // Renommée par l'utilisateur : affichée telle quelle.
    expect(tr.label('couleur:rouge', 'Rouge profond'), 'Rouge profond');
    // Hors fichier (appellation, ajout) : telle quelle.
    expect(tr.label('appellation:fr-pauillac', 'Pauillac'), 'Pauillac');
    expect(tr.byFrench('region', 'Bourgogne'), 'Burgundy');
    expect(tr.byFrench('region', 'Bordeaux'), 'Bordeaux');
    expect(LabelTranslator.identity.label('couleur:rouge', 'Rouge'), 'Rouge');
  });

  test('LNG-03 chaque traduction porte le libellé livré exact', () {
    final livres = <String, String>{};
    final dico = jsonDecode(
      File('assets/referentiels/listes-dictionnaire.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final l in dico['listes'] as List) {
      for (final v in (l as Map)['valeurs'] as List) {
        livres['${l['liste']}:${(v as Map)['code']}'] = v['libelle'] as String;
      }
    }
    for (final f in ['accords-mets', 'pays', 'regions', 'sous-regions']) {
      final d = jsonDecode(
        File('assets/referentiels/$f.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final v in d['valeurs'] as List) {
        livres['${d['liste']}:${(v as Map)['code']}'] = v['libelle'] as String;
      }
    }
    final valeurs = json['valeurs'] as Map<String, dynamic>;
    for (final e in valeurs.entries) {
      expect(livres[e.key], (e.value as Map)['fr'], reason: e.key);
      expect(((e.value as Map)['en'] as String).trim(), isNotEmpty);
    }
    // Les couleurs, types, motifs et pays livrés sont tous traduits.
    for (final k in livres.keys.where(
      (k) =>
          k.startsWith('couleur:') ||
          k.startsWith('type_vin:') ||
          k.startsWith('motif_mouvement:') ||
          k.startsWith('pays:') ||
          k.startsWith('accord_mets:'),
    )) {
      expect(valeurs.containsKey(k), isTrue, reason: k);
    }
  });

  testWidgets('LNG-03 fiche en anglais : couleur et région traduites', (
    tester,
  ) async {
    await pumpRealApp(tester, seed: seedTwo, device: const Locale('en'));
    await tester.tap(find.text('Domaine Corvizac'));
    await settle(tester);
    expect(find.text('White'), findsWidgets);
    expect(find.text('Blanc'), findsNothing);
    expect(find.text('Burgundy'), findsWidgets);
    expect(find.text('Bourgogne'), findsNothing);
  });
}
