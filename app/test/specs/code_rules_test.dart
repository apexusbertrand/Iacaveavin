import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/core/navigation/destinations.dart';

import '../fakes.dart';

/// Fichiers Dart écrits à la main (hors code généré).
Iterable<File> _sources() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !f.path.contains('/generated/'));

void main() {
  test('règle 7 : aucune couleur en dur hors des jetons générés', () {
    final interdit = RegExp(
      r'Colors\.|Color\(0x|Color\.fromARGB|Color\.fromRGBO',
    );
    final fautes = [
      for (final f in _sources())
        for (final (i, line) in f.readAsLinesSync().indexed)
          if (interdit.hasMatch(line)) '${f.path}:${i + 1}: ${line.trim()}',
    ];
    expect(fautes, isEmpty);
  });

  test('règle 7 : aucun texte affiché en dur dans les écrans', () {
    // Littéral passé à Text(...) ou à un paramètre de libellé.
    final interdit = RegExp(
      r'''(Text\(\s*|tooltip:\s*|label:\s*|title:\s*|semanticsLabel:\s*)['"][^'"]*\p{L}''',
      unicode: true,
    );
    final fautes = [
      for (final f in _sources().where(
        (f) => f.path.contains('/features/') || f.path.contains('/core/'),
      ))
        for (final (i, line) in f.readAsLinesSync().indexed)
          if (interdit.hasMatch(line)) '${f.path}:${i + 1}: ${line.trim()}',
    ];
    expect(fautes, isEmpty);
  });

  group('NFR-11 aucun libellé technique à l\'écran (défaut « wine_0 »)', () {
    final cles = (jsonDecode(
      File('lib/core/l10n/app_fr.arb').readAsStringSync(),
    ) as Map<String, dynamic>).keys.where((k) => !k.startsWith('@')).toSet();
    final technique = RegExp(r'_\d|\b[a-z]+_[a-z_]+\b');

    for (final d in AppDestination.values) {
      testWidgets('NFR-11 écran ${d.name}', (tester) async {
        await pumpApp(tester, location: d.path);
        final textes = <String>[
          for (final w in tester.widgetList<Text>(find.byType(Text)))
            w.data ?? w.textSpan?.toPlainText() ?? '',
        ];
        for (final t in textes) {
          expect(technique.hasMatch(t), isFalse, reason: 'clé technique : $t');
          expect(cles.contains(t), isFalse, reason: 'clé non traduite : $t');
        }
        expect(textes.where((t) => t.trim().isNotEmpty), isNotEmpty);
      });
    }

    testWidgets('NFR-11 tiroir ouvert', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      for (final w in tester.widgetList<Text>(find.byType(Text))) {
        final t = w.data ?? '';
        expect(technique.hasMatch(t), isFalse, reason: t);
        expect(cles.contains(t), isFalse, reason: t);
      }
    });
  });
}
