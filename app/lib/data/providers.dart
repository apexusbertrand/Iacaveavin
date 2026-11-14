import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_language.dart';
import '../domain/label_translator.dart';

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

/// LNG-03 : traduction des valeurs livrées, chargée quand l'app est en
/// anglais. En français, ou tant qu'elle se charge, rien n'est traduit.
final referenceTranslatorProvider = FutureProvider<LabelTranslator>((
  ref,
) async {
  if (ref.watch(appLanguageProvider) == 'fr') return LabelTranslator.identity;
  final raw = await ref.watch(assetReaderProvider)(referenceTranslationAsset);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return LabelTranslator.fromJson(json['valeurs'] as Map<String, dynamic>);
});

const referenceTranslationAsset = 'assets/referentiels/en.json';

/// Traduction prête, sinon aucune.
final labelTranslatorProvider = Provider<LabelTranslator>(
  (ref) =>
      ref.watch(referenceTranslatorProvider).value ?? LabelTranslator.identity,
);

final cellarRepositoryProvider = Provider<CellarRepository>(
  (ref) => CellarRepository(
    ref.watch(databaseProvider),
    translator: ref.watch(labelTranslatorProvider),
  ),
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

/// Libellés tels qu'en base (français ou renommés) : règles de garde,
/// gestion des listes.
final rawLabelsProvider = StreamProvider<Map<String, String>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchLabels();
});

/// Libellés affichés, traduits si l'app est en anglais (LNG-03).
final labelsProvider = StreamProvider<Map<String, String>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  final tr = ref.watch(labelTranslatorProvider);
  yield* ref.watch(referenceRepositoryProvider).watchLabels().map(tr.labels);
});

final ownersProvider = StreamProvider<List<OwnerView>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchOwners();
});

final locationsProvider = StreamProvider<List<LocationView>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(referenceRepositoryProvider).watchLocations();
});

/// Valeurs d'une liste telles qu'en base : écran de gestion des listes,
/// règles de garde.
final rawListValuesProvider =
    StreamProvider.family<List<ListValueView>, String>((ref, list) async* {
      await ref.watch(bootstrapProvider.future);
      yield* ref.watch(referenceRepositoryProvider).watchList(list);
    });

/// Valeurs d'une liste pour les choix à l'écran, libellés traduits (LNG-03).
final listValuesProvider = StreamProvider.family<List<ListValueView>, String>((
  ref,
  list,
) async* {
  await ref.watch(bootstrapProvider.future);
  final tr = ref.watch(labelTranslatorProvider);
  yield* ref
      .watch(referenceRepositoryProvider)
      .watchList(list)
      .map(
        (values) => tr.isIdentity
            ? values
            : [
                for (final v in values)
                  ListValueView(
                    id: v.id,
                    list: v.list,
                    code: v.code,
                    label: tr.label('${v.list}:${v.code}', v.label),
                    active: v.active,
                    order: v.order,
                    parentCode: v.parentCode,
                  ),
              ],
      );
});

/// Année en cours, pour les statuts de garde.
final currentYearProvider = Provider<int>((ref) => DateTime.now().year);
