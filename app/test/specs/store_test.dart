import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Blocs de code d'une fiche Play, dans l'ordre : nom, description courte,
/// description longue, notes de version.
List<String> _blocks(String path) {
  final parts = File(path).readAsStringSync().split('```');
  return [for (var i = 1; i < parts.length; i += 2) parts[i].trim()];
}

void main() {
  test('LNG-05 fiche Play anglaise dans les limites de Google', () {
    final b = _blocks('../store/fiche-play-en.md');
    expect(b[0].length, lessThanOrEqualTo(30));
    expect(b[1].length, lessThanOrEqualTo(80));
    expect(b[2].length, lessThanOrEqualTo(4000));
    expect(b[3].length, lessThanOrEqualTo(500));
    expect(b[2], contains('Drink responsibly'));
  });

  test('LNG-05 cinq captures anglaises comme en français', () {
    List<String> names(String dir) =>
        (Directory(dir)
                .listSync()
                .whereType<File>()
                .map((f) => f.uri.pathSegments.last))
            .where((n) => n.endsWith('.png'))
            .toList()
          ..sort();
    expect(names('../store/captures-en'), names('../store/captures'));
    expect(names('../store/captures-en'), hasLength(5));
  });
}
