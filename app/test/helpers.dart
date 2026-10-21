import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:iacaveavin/data/db/app_database.dart';

/// Base SQLite en mémoire pour les tests.
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Lit un asset depuis le disque (les tests tournent dans app/).
Future<String> readAssetFromDisk(String path) => File(path).readAsString();
