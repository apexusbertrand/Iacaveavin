import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'db/app_database.dart';

/// Nom de l'application dans le manifeste, pour refuser une archive étrangère.
const backupAppId = 'iacaveavin';
const _dbEntry = 'base.sqlite';
const _manifestEntry = 'manifeste.json';
const _photosDir = 'photos';

class BackupException implements Exception {
  const BackupException(this.code);

  /// `not_an_archive`, `newer_schema`, `corrupted`.
  final String code;

  @override
  String toString() => 'BackupException($code)';
}

class BackupManifest {
  const BackupManifest({
    required this.schemaVersion,
    required this.createdAt,
    required this.withPhotos,
    required this.wines,
  });

  final int schemaVersion;
  final DateTime createdAt;
  final bool withPhotos;
  final int wines;

  Map<String, Object> toJson() => {
    'application': backupAppId,
    'version_schema': schemaVersion,
    'date': createdAt.toUtc().toIso8601String(),
    'avec_photos': withPhotos,
    'fiches': wines,
  };

  static BackupManifest fromJson(Map<String, dynamic> json) {
    if (json['application'] != backupAppId) {
      throw const BackupException('not_an_archive');
    }
    return BackupManifest(
      schemaVersion: (json['version_schema'] as num).toInt(),
      createdAt: DateTime.parse(json['date'] as String),
      withPhotos: json['avec_photos'] == true,
      wines: (json['fiches'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Sauvegarde et restauration (SAV-01 à SAV-05).
///
/// L'archive contient la base (copie cohérente par VACUUM INTO), le
/// manifeste et, en option, les photos. La clé du flux n8n n'y est jamais :
/// elle vit dans le stockage sécurisé, hors de la base.
class BackupService {
  BackupService(
    this._db, {
    required this.appDir,
    required this.tempDir,
    DateTime Function()? clock,
    this.openForMigration,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;

  /// Répertoire privé de l'application (photos, sauvegardes locales).
  final Future<Directory> Function() appDir;
  final Future<Directory> Function() tempDir;
  final DateTime Function() _clock;

  /// Ouvre une base restaurée pour la migrer (remplaçable dans les tests).
  final AppDatabase Function(File file)? openForMigration;

  static const autoBackupsKept = 3;
  static const autoBackupEvery = Duration(days: 7);
  static const externalReminderAfter = Duration(days: 30);

  String _stamp() => _clock()
      .toIso8601String()
      .substring(0, 16)
      .replaceAll(RegExp('[-:]'), '')
      .replaceAll('T', '-');

  /// SAV-01, SAV-02 : crée l'archive dans [into] (temporaire par défaut).
  Future<File> createArchive({
    required bool withPhotos,
    Directory? into,
    String? fileName,
  }) async {
    final work = await tempDir();
    final dbCopy = File(p.join(work.path, 'export-${_stamp()}.sqlite'));
    if (dbCopy.existsSync()) dbCopy.deleteSync();
    await _db.customStatement('VACUUM INTO ?', [dbCopy.path]);
    final count = _db.wines.id.count();
    final wines =
        await (_db.selectOnly(_db.wines)
              ..addColumns([count])
              ..where(_db.wines.deletedAt.isNull()))
            .map((r) => r.read(count) ?? 0)
            .getSingle();
    final manifest = BackupManifest(
      schemaVersion: _db.schemaVersion,
      createdAt: _clock(),
      withPhotos: withPhotos,
      wines: wines,
    );
    final photos = Directory(p.join((await appDir()).path, _photosDir));
    final target = File(
      p.join(
        (into ?? work).path,
        fileName ??
            'iacaveavin-${_stamp()}${withPhotos ? '' : '-sans-photos'}.zip',
      ),
    );
    // NFR-02 : compression hors du fil de l'interface.
    await Isolate.run(
      () => _writeZip(
        target.path,
        dbCopy.path,
        jsonEncode(manifest.toJson()),
        withPhotos && photos.existsSync() ? photos.path : null,
      ),
    );
    dbCopy.deleteSync();
    return target;
  }

  static void _writeZip(
    String target,
    String dbPath,
    String manifest,
    String? photosPath,
  ) {
    final archive = Archive()
      ..addFile(ArchiveFile.string(_manifestEntry, manifest))
      ..addFile(ArchiveFile.bytes(_dbEntry, File(dbPath).readAsBytesSync()));
    if (photosPath != null) {
      for (final f in Directory(photosPath).listSync(recursive: true)) {
        if (f is! File) continue;
        final rel = p.relative(f.path, from: p.dirname(photosPath));
        archive.addFile(
          ArchiveFile.bytes(p.posix.joinAll(p.split(rel)), f.readAsBytesSync()),
        );
      }
    }
    File(target).writeAsBytesSync(ZipEncoder().encode(archive));
  }

  /// Lit le manifeste sans rien modifier (écran de confirmation SAV-04).
  Future<BackupManifest> inspect(File archive) async {
    final zip = await _decode(archive);
    return _manifestOf(zip);
  }

  Future<Archive> _decode(File archive) async {
    try {
      final bytes = await archive.readAsBytes();
      return await Isolate.run(() => ZipDecoder().decodeBytes(bytes));
    } on Object {
      throw const BackupException('not_an_archive');
    }
  }

  BackupManifest _manifestOf(Archive zip) {
    final entry = zip.findFile(_manifestEntry);
    if (entry == null || zip.findFile(_dbEntry) == null) {
      throw const BackupException('not_an_archive');
    }
    final manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(entry.content)) as Map<String, dynamic>,
    );
    if (manifest.schemaVersion > _db.schemaVersion) {
      throw const BackupException('newer_schema');
    }
    return manifest;
  }

  /// SAV-04 : restauration complète. La base de l'archive est d'abord migrée
  /// vers le schéma courant, puis copiée table par table dans une seule
  /// transaction : en cas d'échec, la cave actuelle reste intacte.
  Future<BackupManifest> restore(File archive) async {
    final zip = await _decode(archive);
    final manifest = _manifestOf(zip);
    final work = await tempDir();
    final restored = File(p.join(work.path, 'restauration-${_stamp()}.sqlite'));
    restored.writeAsBytesSync(zip.findFile(_dbEntry)!.content);

    // Migration de l'archive si elle vient d'une version plus ancienne.
    final migrated = (openForMigration ?? _openFile)(restored);
    try {
      await migrated.customSelect('SELECT COUNT(*) FROM fiche_vin').get();
    } on Object {
      restored.deleteSync();
      throw const BackupException('corrupted');
    } finally {
      await migrated.close();
    }

    await _db.customStatement('ATTACH DATABASE ? AS archive', [restored.path]);
    try {
      await _db.transaction(() async {
        await _db.customStatement('PRAGMA defer_foreign_keys = ON');
        for (final table in _db.allTables.toList().reversed) {
          await _db.customStatement('DELETE FROM ${table.actualTableName}');
        }
        for (final table in _db.allTables) {
          final cols = table.$columns.map((c) => '"${c.name}"').join(', ');
          await _db.customStatement(
            'INSERT INTO ${table.actualTableName} ($cols) '
            'SELECT $cols FROM archive.${table.actualTableName}',
          );
        }
      });
    } finally {
      await _db.customStatement('DETACH DATABASE archive');
      restored.deleteSync();
    }
    _db.notifyUpdates({for (final t in _db.allTables) TableUpdate.onTable(t)});

    if (manifest.withPhotos) {
      final photos = Directory(p.join((await appDir()).path, _photosDir));
      if (photos.existsSync()) photos.deleteSync(recursive: true);
      for (final f in zip.files) {
        if (!f.isFile || !f.name.startsWith('$_photosDir/')) continue;
        final out = File(
          p.join((await appDir()).path, p.joinAll(f.name.split('/'))),
        );
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(f.content);
      }
    }
    return manifest;
  }

  static AppDatabase _openFile(File file) => AppDatabase(NativeDatabase(file));

  Future<Directory> _autoDir() async {
    final d = Directory(p.join((await appDir()).path, 'sauvegardes'));
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  /// SAV-03 : sauvegarde locale hebdomadaire (sans photos, elles sont déjà
  /// sur le téléphone), 3 dernières conservées. Renvoie l'archive créée, ou
  /// null si la dernière date de moins de 7 jours.
  Future<File?> autoBackupIfDue(DateTime? last) async {
    if (last != null && _clock().difference(last) < autoBackupEvery) {
      return null;
    }
    final dir = await _autoDir();
    final file = await createArchive(
      withPhotos: false,
      into: dir,
      fileName: 'auto-${_stamp()}.zip',
    );
    final archives = localBackups(dir);
    for (final old in archives.skip(autoBackupsKept)) {
      old.deleteSync();
    }
    return file;
  }

  /// Sauvegardes automatiques, de la plus récente à la plus ancienne.
  List<File> localBackups(Directory dir) =>
      dir
          .listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith('auto-'))
          .toList()
        ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));

  Future<List<File>> autoBackups() async => localBackups(await _autoDir());

  /// SAV-03 : rappel si aucun export externe depuis 30 jours.
  bool externalReminderDue(DateTime? lastExternal, DateTime? firstUse) {
    final since = lastExternal ?? firstUse;
    return since == null || _clock().difference(since) >= externalReminderAfter;
  }
}
