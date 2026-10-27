/// Lecture et écriture de classeurs xlsx (Office Open XML), en Dart pur pour
/// tourner dans un isolate (NFR-02). Le paquet `excel` exige une version
/// d'`archive` incompatible avec la sauvegarde (T89) : le format est écrit
/// ici, limité à ce dont l'export et l'import ont besoin.
///
/// Valeurs d'une cellule : `String`, `num`, `bool`, [XlsxDate] ou `null`.
/// XLS-02 : nombres, dates et booléens sont écrits typés, jamais en texte.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Date sans heure (cellule au format date d'Excel).
class XlsxDate {
  const XlsxDate(this.year, this.month, this.day);

  /// AAAA-MM-JJ ; null si le texte n'est pas une date valide.
  static XlsxDate? tryParse(String? text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text ?? '');
    if (m == null) return null;
    final d = XlsxDate(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    final check = DateTime.utc(d.year, d.month, d.day);
    return check.month == d.month && check.day == d.day ? d : null;
  }

  /// Numéro de série d'Excel (jours depuis le 30 décembre 1899).
  factory XlsxDate.fromSerial(num serial) {
    final d = DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor()));
    return XlsxDate(d.year, d.month, d.day);
  }

  final int year;
  final int month;
  final int day;

  int get serial => DateTime.utc(
    year,
    month,
    day,
  ).difference(DateTime.utc(1899, 12, 30)).inDays;

  String get iso =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is XlsxDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}

class XlsxSheet {
  const XlsxSheet({
    required this.name,
    required this.rows,
    this.widths = const [],
    this.header = true,
  });

  /// 31 caractères au plus, sans `[]:*?/\`.
  final String name;
  final List<List<Object?>> rows;

  /// Largeur des colonnes, en caractères.
  final List<double> widths;

  /// Première ligne en gras et figée.
  final bool header;
}

String _col(int index) {
  var n = index + 1;
  final b = StringBuffer();
  while (n > 0) {
    final r = (n - 1) % 26;
    b.write(String.fromCharCode(65 + r));
    n = (n - 1) ~/ 26;
  }
  return b.toString().split('').reversed.join();
}

int _colIndex(String ref) {
  var n = 0;
  for (final c in ref.codeUnits) {
    if (c < 65 || c > 90) break;
    n = n * 26 + (c - 64);
  }
  return n - 1;
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    // Caractères de contrôle interdits en XML 1.0.
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

String _num(num v) {
  if (v is int || v == v.roundToDouble() && v.abs() < 1e15) {
    return v.toInt().toString();
  }
  return v.toString();
}

String _sheetXml(XlsxSheet s) {
  final b = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
  );
  if (s.header && s.rows.isNotEmpty) {
    b.write(
      '<sheetViews><sheetView workbookViewId="0">'
      '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>'
      '</sheetView></sheetViews>',
    );
  }
  if (s.widths.isNotEmpty) {
    b.write('<cols>');
    for (final (i, w) in s.widths.indexed) {
      b.write(
        '<col min="${i + 1}" max="${i + 1}" width="$w" customWidth="1"/>',
      );
    }
    b.write('</cols>');
  }
  b.write('<sheetData>');
  for (final (r, row) in s.rows.indexed) {
    b.write('<row r="${r + 1}">');
    final bold = s.header && r == 0;
    for (final (c, v) in row.indexed) {
      if (v == null) continue;
      final ref = '${_col(c)}${r + 1}';
      final style = bold ? ' s="2"' : '';
      switch (v) {
        case final bool x:
          b.write('<c r="$ref" t="b"$style><v>${x ? 1 : 0}</v></c>');
        case final num x:
          b.write('<c r="$ref"$style><v>${_num(x)}</v></c>');
        case final XlsxDate x:
          b.write('<c r="$ref" s="1"><v>${x.serial}</v></c>');
        default:
          final t = '$v';
          if (t.isEmpty) continue;
          b.write(
            '<c r="$ref" t="inlineStr"$style><is><t xml:space="preserve">'
            '${_esc(t)}</t></is></c>',
          );
      }
    }
    b.write('</row>');
  }
  b.write('</sheetData></worksheet>');
  return b.toString();
}

/// Classeur xlsx des feuilles [sheets], dans l'ordre.
Uint8List writeXlsx(List<XlsxSheet> sheets) {
  final a = Archive();
  void add(String name, String text) {
    final bytes = utf8.encode(text);
    a.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add(
    '[Content_Types].xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '${[for (var i = 1; i <= sheets.length; i++) '<Override PartName="/xl/worksheets/sheet$i.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'].join()}'
        '</Types>',
  );
  add(
    '_rels/.rels',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>',
  );
  add(
    'xl/workbook.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>'
        '${[for (final (i, s) in sheets.indexed) '<sheet name="${_esc(s.name)}" sheetId="${i + 1}" r:id="rId${i + 1}"/>'].join()}'
        '</sheets></workbook>',
  );
  add(
    'xl/_rels/workbook.xml.rels',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '${[for (var i = 1; i <= sheets.length; i++) '<Relationship Id="rId$i" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet$i.xml"/>'].join()}'
        '<Relationship Id="rId${sheets.length + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
  );
  // Styles : 0 normal, 1 date (format 14, jj/mm/aaaa en français), 2 gras.
  add(
    'xl/styles.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
        '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
        '<fills count="2"><fill><patternFill patternType="none"/></fill>'
        '<fill><patternFill patternType="gray125"/></fill></fills>'
        '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        '<cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
        '<xf numFmtId="14" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
        '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
        '</styleSheet>',
  );
  for (final (i, s) in sheets.indexed) {
    add('xl/worksheets/sheet${i + 1}.xml', _sheetXml(s));
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

class XlsxFormatException implements Exception {
  const XlsxFormatException(this.message);

  final String message;

  @override
  String toString() => 'XlsxFormatException($message)';
}

/// Feuilles d'un classeur xlsx, par nom : lignes de cellules, colonnes vides
/// comblées par null. Les nombres au format date reviennent en [XlsxDate].
Map<String, List<List<Object?>>> readXlsx(Uint8List bytes) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const XlsxFormatException('fichier xlsx illisible');
  }
  String? text(String name) {
    final f = zip.findFile(name);
    return f == null ? null : utf8.decode(f.content as List<int>);
  }

  final workbook = text('xl/workbook.xml');
  if (workbook == null) throw const XlsxFormatException('classeur absent');
  final rels = <String, String>{};
  final relsText = text('xl/_rels/workbook.xml.rels');
  if (relsText != null) {
    for (final r in XmlDocument.parse(
      relsText,
    ).findAllElements('Relationship')) {
      final target = r.getAttribute('Target')!;
      rels[r.getAttribute('Id')!] = target.startsWith('/')
          ? target.substring(1)
          : 'xl/$target';
    }
  }
  final shared = <String>[];
  final sharedText = text('xl/sharedStrings.xml');
  if (sharedText != null) {
    for (final si in XmlDocument.parse(sharedText).findAllElements('si')) {
      shared.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }
  // Formats de date : numéros 14 à 22, 45 à 47, et formats personnalisés
  // contenant j, d, m ou y hors texte entre guillemets.
  final dateStyles = <int>{};
  final stylesText = text('xl/styles.xml');
  if (stylesText != null) {
    final doc = XmlDocument.parse(stylesText);
    final custom = <int>{};
    for (final f in doc.findAllElements('numFmt')) {
      final code = (f.getAttribute('formatCode') ?? '')
          .replaceAll(RegExp(r'"[^"]*"|\[[^\]]*\]'), '')
          .toLowerCase();
      if (RegExp('[dmyj]').hasMatch(code) && !code.contains('h')) {
        custom.add(int.parse(f.getAttribute('numFmtId')!));
      }
    }
    final xfs = doc.findAllElements('cellXfs').firstOrNull;
    if (xfs != null) {
      for (final (i, xf) in xfs.findElements('xf').indexed) {
        final id = int.tryParse(xf.getAttribute('numFmtId') ?? '0') ?? 0;
        if ((id >= 14 && id <= 22) ||
            (id >= 45 && id <= 47) ||
            custom.contains(id)) {
          dateStyles.add(i);
        }
      }
    }
  }

  final out = <String, List<List<Object?>>>{};
  for (final s in XmlDocument.parse(workbook).findAllElements('sheet')) {
    final name = s.getAttribute('name')!;
    final rid =
        s.getAttribute(
          'id',
          namespaceUri: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
        ) ??
        s.getAttribute('r:id');
    final path = rels[rid];
    final xml = path == null ? null : text(path);
    if (xml == null) continue;
    final rows = <List<Object?>>[];
    for (final row in XmlDocument.parse(xml).findAllElements('row')) {
      final r =
          (int.tryParse(row.getAttribute('r') ?? '') ?? rows.length + 1) - 1;
      while (rows.length < r) {
        rows.add([]);
      }
      final cells = <Object?>[];
      for (final c in row.findElements('c')) {
        final ref = c.getAttribute('r');
        final idx = ref == null ? cells.length : _colIndex(ref);
        while (cells.length < idx) {
          cells.add(null);
        }
        final t = c.getAttribute('t');
        final v = c.findElements('v').firstOrNull?.innerText;
        Object? value;
        switch (t) {
          case 's':
            final i = int.tryParse(v ?? '');
            value = i != null && i < shared.length ? shared[i] : null;
          case 'inlineStr':
            value = c.findAllElements('t').map((e) => e.innerText).join();
          case 'str':
            value = v;
          case 'b':
            value = v == '1';
          case 'e':
            value = null;
          default:
            final n = v == null ? null : num.tryParse(v);
            final style = int.tryParse(c.getAttribute('s') ?? '');
            value = n != null && style != null && dateStyles.contains(style)
                ? XlsxDate.fromSerial(n)
                : n;
        }
        if (value is String && value.isEmpty) value = null;
        cells.add(value);
      }
      rows.add(cells);
    }
    out[name] = rows;
  }
  return out;
}
