import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/demo_data_repository.dart';
import '../domain/wine_list_item.dart';
import 'cellar_repository.dart';
import 'db/app_database.dart';
import 'demo/drift_demo_repository.dart';
import 'reference_repository.dart';
import 'referentiels/referentiel_loader.dart';
import 'stock_service.dart';

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

final cellarRepositoryProvider = Provider<CellarRepository>(
  (ref) => CellarRepository(ref.watch(databaseProvider)),
);

final stockServiceProvider = Provider<StockService>(
  (ref) => StockService(ref.watch(databaseProvider)),
);

/// Toutes les fiches, non triées ; le tri et les filtres sont appliqués par
/// [visibleWinesProvider].
final wineListProvider = StreamProvider<List<WineListItem>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(cellarRepositoryProvider).watchWineItems();
});

/// CMP-07 : jeu de démonstration, pour les tests et les captures du store
/// seulement. Aucun écran de l'app publiée n'y donne accès (T122).
final demoRepositoryProvider = Provider<DemoDataRepository>(
  (ref) => DriftDemoRepository(ref.watch(databaseProvider)),
);

final demoCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(demoRepositoryProvider).demoWineCount();
});

final referenceRepositoryProvider = Provider<ReferenceRepository>(
  (ref) => ReferenceRepository(ref.watch(databaseProvider)),
);

final labelsProvider = StreamProvider<Map<String, String>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchLabels();
});

final ownersProvider = StreamProvider<List<OwnerView>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchOwners();
});

final locationsProvider = StreamProvider<List<LocationView>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchLocations();
});

final listValuesProvider = StreamProvider.family<List<ListValueView>, String>((
  ref,
  list,
) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchList(list);
});

/// Année en cours, pour les statuts de garde.
final currentYearProvider = Provider<int>((ref) => DateTime.now().year);
