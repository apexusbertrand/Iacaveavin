import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/app.dart';
import 'package:iacaveavin/data/backup_providers.dart';
import 'package:iacaveavin/data/db/app_database.dart';
import 'package:iacaveavin/data/referentiels/referentiel_loader.dart';
import 'package:iacaveavin/data/providers.dart';
import 'package:iacaveavin/data/settings_store.dart';
import 'package:iacaveavin/domain/demo_data_repository.dart';
import 'package:iacaveavin/domain/wine_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class FakeDemoRepository implements DemoDataRepository {
  FakeDemoRepository({this.count = 0, this.failWith});

  int count;
  final Object? failWith;
  int loads = 0;
  int erases = 0;

  @override
  Future<int> demoWineCount() async => count;

  @override
  Future<void> load() async {
    loads++;
    if (failWith != null) throw failWith!;
    count = 200;
  }

  @override
  Future<void> erase() async {
    erases++;
    count = 0;
  }
}

const sampleWines = [
  WineListItem(
    id: 'w1',
    producer: 'Château Bralmac',
    cuvee: 'Les Terrasses',
    vintage: '2019',
    colorCode: 'rouge',
    countryCode: 'FR',
    countryLabel: 'France',
    region: 'Bordeaux',
    subRegion: 'Médoc',
    appellation: 'Pauillac',
    bottles: 6,
    purchasePrice: 42.5,
  ),
  WineListItem(
    id: 'w2',
    producer: 'Domaine Corvizac',
    vintage: '2022',
    colorCode: 'blanc',
    countryCode: 'FR',
    countryLabel: 'France',
    region: 'Bourgogne',
    appellation: 'Chablis',
    bottles: 2,
    enrichmentStatus: 'a_valider',
  ),
  WineListItem(
    id: 'w3',
    producer: 'Maison Talvombe',
    vintage: 'NM',
    colorCode: 'champagne',
    countryCode: 'FR',
    countryLabel: 'France',
    region: 'Champagne',
    appellation: 'Champagne',
    bottles: 12,
  ),
];

/// Lance l'application avec des données factices (aucune base réelle).
Future<FakeDemoRepository> pumpApp(
  WidgetTester tester, {
  String location = '/',
  Stream<List<WineListItem>>? wines,
  FakeDemoRepository? demo,
  Brightness? brightness,
  Map<String, Object> prefs = const {},
}) async {
  // Téléphone de 360 x 780 dp.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  if (brightness != null) {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
  }
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final repo = demo ?? FakeDemoRepository();
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final db = memoryDatabase();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(db),
        currentYearProvider.overrideWithValue(2026),
        ...noFileSystem,
        bootstrapProvider.overrideWith((ref) async => 'cave-test'),
        wineListProvider.overrideWith(
          (ref) => wines ?? Stream.value(sampleWines),
        ),
        demoRepositoryProvider.overrideWithValue(repo),
      ],
      child: IaCaveAVinApp(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Lance l'application sur une vraie base SQLite en mémoire, référentiels
/// chargés depuis le disque. Renvoie la base pour préparer ou vérifier.
Future<AppDatabase> pumpRealApp(
  WidgetTester tester, {
  String location = '/',
  Map<String, Object> prefs = const {},
  Future<void> Function(AppDatabase db, String cellarId)? seed,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final db = memoryDatabase();
  addTearDown(db.close);
  if (seed != null) {
    await tester.runAsync(() async {
      final id = await CellarBootstrap(
        db,
        readAssetFromDisk,
      ).ensureInitialized();
      await seed(db, id);
    });
  }
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(db),
        assetReaderProvider.overrideWithValue(readAssetFromDisk),
        currentYearProvider.overrideWithValue(2026),
        ...noFileSystem,
      ],
      child: IaCaveAVinApp(initialLocation: location),
    ),
  );
  await settle(tester);
  return db;
}

/// Laisse la base répondre (vraies entrées-sorties) puis stabilise l'écran.
/// Borné : une animation infinie (indicateur de chargement) ne bloque pas.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (i > 3 && !tester.binding.hasScheduledFrame) break;
  }
}

/// Pas de répertoire d'application en test : sauvegardes et photos vides.
final noFileSystem = [
  autoBackupsProvider.overrideWith((ref) async => const []),
  photoSpaceProvider.overrideWith((ref) async => 0),
];
