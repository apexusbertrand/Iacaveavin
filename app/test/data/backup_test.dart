import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/backup_service.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/demo/drift_demo_repository.dart';

import '../fixture.dart';

void main() {
  final f = Fixture();
  late Directory root;
  late BackupService backup;
  DateTime clock = DateTime.utc(2026, 10, 21, 9);

  setUp(() async {
    await f.setUp();
    root = Directory.systemTemp.createTempSync('iacav-');
    Directory('${root.path}/app/photos/w1').createSync(recursive: true);
    File('${root.path}/app/photos/w1/p1.jpg').writeAsBytesSync([1, 2, 3]);
    Directory('${root.path}/tmp').createSync();
    backup = BackupService(
      f.db,
      appDir: () async => Directory('${root.path}/app'),
      tempDir: () async => Directory('${root.path}/tmp'),
      clock: () => clock,
    );
  });
  tearDown(() async {
    await f.db.close();
    root.deleteSync(recursive: true);
  });

  test('SAV-01 archive zip : base, photos et manifeste', () async {
    final zip = await backup.createArchive(withPhotos: true);
    final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
    final names = archive.files.map((e) => e.name).toSet();
    expect(
      names,
      containsAll(['base.sqlite', 'manifeste.json', 'photos/w1/p1.jpg']),
    );
    final m = await backup.inspect(zip);
    expect(m.schemaVersion, f.db.schemaVersion);
    expect(m.wines, 1);
    expect(m.withPhotos, isTrue);
  });

  test('SAV-02 variante sans photos', () async {
    final zip = await backup.createArchive(withPhotos: false);
    final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
    expect(archive.files.where((e) => e.name.startsWith('photos/')), isEmpty);
    expect(zip.path, endsWith('-sans-photos.zip'));
  });

  test('SAV-04 restauration complète sur une autre base, sans perte', () async {
    await DriftDemoRepository(f.db).load();
    await f.stock.open(f.lot, 2);
    final before = await CellarRepository(f.db).wineItems();
    final zip = await backup.createArchive(withPhotos: true);

    // « Autre téléphone » : base vide, photos absentes.
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    Directory('${root.path}/app/photos').deleteSync(recursive: true);
    final target = BackupService(
      other,
      appDir: () async => Directory('${root.path}/app'),
      tempDir: () async => Directory('${root.path}/tmp'),
      clock: () => clock,
    );
    final m = await target.restore(zip);
    expect(m.wines, 201);
    final after = await CellarRepository(other).wineItems();
    expect(after.length, before.length);
    int sum(List l) => l.fold<int>(0, (s, w) => s + (w.bottles as int));
    expect(sum(after), sum(before));
    final mine = after.firstWhere((w) => w.id == f.wine);
    expect(mine.bottles, 4);
    expect(File('${root.path}/app/photos/w1/p1.jpg').readAsBytesSync(), [
      1,
      2,
      3,
    ]);
  });

  test('SAV-04 une archive étrangère ou plus récente est refusée', () async {
    final bad = File('${root.path}/tmp/autre.zip')
      ..writeAsBytesSync(
        ZipEncoder().encode(
          Archive()..addFile(
            ArchiveFile.string('manifeste.json', '{"application":"x"}'),
          ),
        ),
      );
    await expectLater(backup.restore(bad), throwsA(isA<BackupException>()));
    final txt = File('${root.path}/tmp/texte.zip')
      ..writeAsStringSync('pas un zip');
    await expectLater(backup.inspect(txt), throwsA(isA<BackupException>()));
    // La cave n'a pas bougé.
    expect(await CellarRepository(f.db).wineItems(), hasLength(1));
  });

  test('SAV-03 sauvegarde hebdomadaire, 3 dernières conservées', () async {
    expect(await backup.autoBackupIfDue(null), isNotNull);
    expect(
      await backup.autoBackupIfDue(clock.subtract(const Duration(days: 2))),
      isNull,
    );
    for (var i = 1; i <= 4; i++) {
      clock = clock.add(const Duration(days: 8));
      await backup.autoBackupIfDue(clock.subtract(const Duration(days: 8)));
    }
    final kept = await backup.autoBackups();
    expect(kept, hasLength(3));
    expect(kept.first.path, contains('auto-20261122'));
  });

  test('SAV-03 rappel si aucun export externe depuis 30 jours', () {
    expect(backup.externalReminderDue(null, null), isTrue);
    expect(
      backup.externalReminderDue(
        clock.subtract(const Duration(days: 10)),
        null,
      ),
      isFalse,
    );
    expect(
      backup.externalReminderDue(
        clock.subtract(const Duration(days: 31)),
        null,
      ),
      isTrue,
    );
  });

  test('SAV-05 la sauvegarde automatique d\'Android est désactivée', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
  });
}
