/// Contrôles de saisie d'une fiche et d'un lot (règles du dictionnaire).
library;

import 'wine_detail.dart';

/// Codes d'erreur par champ, traduits à l'écran.
typedef ValidationErrors = Map<String, String>;

ValidationErrors validateWine(WineDraft d, {required int currentYear}) {
  final e = <String, String>{};
  if (d.producer.trim().isEmpty) e['domaine'] = 'required';
  if (d.country.trim().isEmpty) e['pays'] = 'required';
  if (d.color.trim().isEmpty) e['couleur'] = 'required';
  final v = d.vintage.trim();
  final year = int.tryParse(v);
  if (v != 'NM' && (year == null || year < 1900 || year > currentYear)) {
    e['millesime'] = 'vintage';
  }
  if (d.alcohol != null && (d.alcohol! < 5 || d.alcohol! > 23)) {
    e['degre'] = 'alcohol';
  }
  final s = d.gardeStart, p = d.gardePeak, f = d.gardeEnd;
  if (s != null && year != null && s < year) e['garde_debut'] = 'garde_order';
  if ((s != null && p != null && p < s) || (p != null && f != null && f < p)) {
    e['garde_apogee'] = 'garde_order';
  }
  if (s != null && f != null && f < s) e['garde_fin'] = 'garde_order';
  if (d.ean != null && d.ean!.isNotEmpty && !isValidEan13(d.ean!)) {
    e['ean'] = 'ean';
  }
  if (d.lwin != null &&
      d.lwin!.isNotEmpty &&
      !RegExp(r'^(\d{7}|\d{11})$').hasMatch(d.lwin!)) {
    e['lwin'] = 'lwin';
  }
  final pcts = d.grapes.map((g) => g.percent).toList();
  if (pcts.isNotEmpty && pcts.every((p) => p != null)) {
    final total = pcts.fold<int>(0, (a, b) => a + b!);
    if (total != 100) e['cepages'] = 'grapes_total';
  }
  return e;
}

/// EAN-13 : 13 chiffres et clé de contrôle valide.
bool isValidEan13(String code) {
  if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    final d = code.codeUnitAt(i) - 48;
    sum += i.isEven ? d : d * 3;
  }
  return (10 - sum % 10) % 10 == code.codeUnitAt(12) - 48;
}

/// AJO-10 : premier EAN valide parmi les valeurs lues par le lecteur de
/// code-barres. Un UPC-A (12 chiffres) devient l'EAN-13 précédé de 0.
String? eanFromScan(Iterable<String?> values) {
  for (final v in values) {
    final digits = (v ?? '').replaceAll(RegExp(r'\s'), '');
    final ean = digits.length == 12 ? '0$digits' : digits;
    if (isValidEan13(ean)) return ean;
  }
  return null;
}

/// EMP-02 : positions « A3, B5 » dans une grille de [rows] lignes (A à Z) et
/// [cols] colonnes (1 à 50). Renvoie les cellules normalisées, ou null si une
/// position est invalide.
List<String>? parsePositions(String? text, {int? rows, int? cols}) {
  if (text == null || text.trim().isEmpty) return const [];
  final cells = <String>[];
  for (final raw in text.split(',')) {
    final m = RegExp(r'^\s*([A-Za-z])\s*(\d{1,2})\s*$').firstMatch(raw);
    if (m == null) return null;
    final row = m[1]!.toUpperCase().codeUnitAt(0) - 64;
    final col = int.parse(m[2]!);
    if (col < 1 || col > 50) return null;
    if (rows != null && row > rows) return null;
    if (cols != null && col > cols) return null;
    cells.add('${m[1]!.toUpperCase()}$col');
  }
  return cells;
}
