import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'backup_service.dart';
import 'providers.dart';

/// Répertoire privé de l'application (photos, sauvegardes locales).
final appDirProvider = Provider<Future<Directory> Function()>(
  (ref) => getApplicationDocumentsDirectory,
);

final tempDirProvider = Provider<Future<Directory> Function()>(
  (ref) => getTemporaryDirectory,
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    ref.watch(databaseProvider),
    appDir: ref.watch(appDirProvider),
    tempDir: ref.watch(tempDirProvider),
  ),
);

/// NFR-04 : espace occupé par les photos, affiché dans les Réglages.
final photoSpaceProvider = FutureProvider<int>((ref) async {
  final dir = Directory(
    p.join((await ref.watch(appDirProvider)()).path, 'photos'),
  );
  if (!dir.existsSync()) return 0;
  var total = 0;
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    total += f.lengthSync();
  }
  return total;
});

final autoBackupsProvider = FutureProvider<List<File>>(
  (ref) => ref.watch(backupServiceProvider).autoBackups(),
);
