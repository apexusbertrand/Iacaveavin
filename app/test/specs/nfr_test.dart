import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('NFR-02 PDF, Excel, photos et archives hors du fil de l\'interface', () {
    for (final f in [
      'lib/data/pdf/pdf_service.dart',
      'lib/data/excel/excel_service.dart',
      'lib/data/files/photo_service.dart',
      'lib/data/backup_service.dart',
    ]) {
      expect(
        RegExp(r'Isolate\.(run|spawn)').hasMatch(_read(f)),
        isTrue,
        reason: '$f : traitement lourd attendu dans un isolate',
      );
    }
  });

  test('NFR-09 aucune mesure d\'audience, aucun SDK publicitaire', () {
    final lock = _read('pubspec.lock');
    for (final banned in [
      'firebase_analytics',
      'firebase_crashlytics',
      'google_mobile_ads',
      'sentry',
      'amplitude',
      'mixpanel',
      'appsflyer',
      'facebook_app_events',
    ]) {
      expect(lock.contains(banned), isFalse, reason: banned);
    }
  });

  test(
    'NFR-13 tests unitaires sur stock, garde, notes, valeurs, Excel, stats',
    () {
      for (final f in [
        'test/data/stock_test.dart',
        'test/domain/garde_rules_test.dart',
        'test/domain/rules_test.dart',
        'test/data/excel_test.dart',
        'test/data/stats_repository_test.dart',
        'test/domain/stats_test.dart',
      ]) {
        expect(File(f).existsSync(), isTrue, reason: f);
      }
    },
  );
}
