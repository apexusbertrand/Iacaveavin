import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/domain/wine_validation.dart';

WineDraft draft({
  String vintage = '2019',
  double? alcohol,
  int? start,
  int? peak,
  int? end,
  String? ean,
  List<GrapeShare> grapes = const [],
}) => WineDraft(
  producer: 'D',
  country: 'FR',
  color: 'rouge',
  vintage: vintage,
  alcohol: alcohol,
  gardeStart: start,
  gardePeak: peak,
  gardeEnd: end,
  ean: ean,
  grapes: grapes,
);

void main() {
  test('FIC-01 millésime : 1900 à l\'année en cours, ou NM', () {
    expect(validateWine(draft(), currentYear: 2026), isEmpty);
    expect(validateWine(draft(vintage: 'NM'), currentYear: 2026), isEmpty);
    expect(
      validateWine(draft(vintage: '2027'), currentYear: 2026)['millesime'],
      'vintage',
    );
    expect(
      validateWine(draft(vintage: '18'), currentYear: 2026),
      contains('millesime'),
    );
  });

  test('FIC-01 degré entre 5 et 23, garde ordonnée', () {
    expect(
      validateWine(draft(alcohol: 30), currentYear: 2026),
      contains('degre'),
    );
    expect(
      validateWine(draft(start: 2018), currentYear: 2026),
      contains('garde_debut'),
    );
    expect(
      validateWine(
        draft(start: 2022, peak: 2021, end: 2030),
        currentYear: 2026,
      ),
      contains('garde_apogee'),
    );
    expect(
      validateWine(
        draft(start: 2022, peak: 2025, end: 2030),
        currentYear: 2026,
      ),
      isEmpty,
    );
  });

  test('FIC-01 EAN 13 chiffres avec clé de contrôle, cépages à 100 %', () {
    expect(isValidEan13('3017620422003'), isTrue);
    expect(isValidEan13('3017620422004'), isFalse);
    expect(validateWine(draft(ean: '123'), currentYear: 2026), contains('ean'));
    expect(
      validateWine(
        draft(grapes: const [GrapeShare('merlot', 80), GrapeShare('cot', 10)]),
        currentYear: 2026,
      ),
      contains('cepages'),
    );
    expect(
      validateWine(
        draft(grapes: const [GrapeShare('merlot', 80), GrapeShare('cot')]),
        currentYear: 2026,
      ),
      isEmpty,
    );
  });

  test('EMP-02 positions dans la grille (lignes A à Z, colonnes 1 à 50)', () {
    expect(parsePositions('a3, B5'), ['A3', 'B5']);
    expect(parsePositions(''), isEmpty);
    expect(parsePositions('A51'), isNull);
    expect(parsePositions('C2', rows: 2, cols: 8), isNull);
    expect(parsePositions('B9', rows: 6, cols: 8), isNull);
    expect(parsePositions('trois'), isNull);
  });
}
