import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/demo_data_repository.dart';
import '../domain/wine_list_item.dart';
import 'db/app_database.dart';
import 'demo/drift_demo_repository.dart';
import 'referentiels/referentiel_loader.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final assetReaderProvider = Provider<AssetReader>(
  (ref) => rootBundle.loadString,
);

/// Premier lancement : cave principale et référentiels. Renvoie l'id de la cave.
final bootstrapProvider = FutureProvider<String>((ref) {
  return CellarBootstrap(
    ref.watch(databaseProvider),
    ref.watch(assetReaderProvider),
  ).ensureInitialized();
});

final wineListProvider = StreamProvider<List<WineListItem>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(databaseProvider).watchWineList();
});

final demoRepositoryProvider = Provider<DemoDataRepository>(
  (ref) => DriftDemoRepository(ref.watch(databaseProvider)),
);

final demoCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(demoRepositoryProvider).demoWineCount();
});
