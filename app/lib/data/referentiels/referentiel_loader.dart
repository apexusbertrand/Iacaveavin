import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../demo/demo_generator.dart';

/// Fichiers de app/assets/referentiels/ chargés au premier lancement.
const referentielAssets = [
  'assets/referentiels/listes-dictionnaire.json',
  'assets/referentiels/pays.json',
  'assets/referentiels/regions.json',
  'assets/referentiels/sous-regions.json',
  'assets/referentiels/appellations.json',
  'assets/referentiels/cepages.json',
  'assets/referentiels/accords-mets.json',
];

typedef AssetReader = Future<String> Function(String path);

/// Prépare la base au premier lancement : cave principale et listes de valeurs.
class CellarBootstrap {
  CellarBootstrap(this._db, this._readAsset, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final AssetReader _readAsset;
  final DateTime Function() _clock;

  /// Crée la cave principale si besoin, charge les listes si elles sont vides,
  /// et renvoie l'identifiant de la cave principale.
  Future<String> ensureInitialized() {
    return _db.transaction(() async {
      final cellarId = await _mainCellarId();
      final existing =
          await (_db.select(_db.listValues)
                ..where((v) => v.caveId.equals(cellarId))
                ..limit(1))
              .get();
      if (existing.isEmpty) await _loadLists(cellarId);
      return cellarId;
    });
  }

  Future<String> _mainCellarId() async {
    final cellars =
        await (_db.select(_db.cellars)
              ..where((c) => c.id.equals(demoCellarId).not())
              ..orderBy([(c) => OrderingTerm.asc(c.createdAt)])
              ..limit(1))
            .get();
    if (cellars.isNotEmpty) return cellars.first.id;
    final now = _clock().toUtc();
    final id = const Uuid().v4();
    await _db
        .into(_db.cellars)
        .insert(
          CellarsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            nom: 'Ma cave',
          ),
        );
    return id;
  }

  Future<void> _loadLists(String cellarId) async {
    final now = _clock().toUtc();
    const uuid = Uuid();
    final rows = <ListValuesCompanion>[];
    for (final path in referentielAssets) {
      final json = jsonDecode(await _readAsset(path)) as Map<String, dynamic>;
      final lists = json.containsKey('listes')
          ? (json['listes'] as List).cast<Map<String, dynamic>>()
          : [json];
      for (final list in lists) {
        final values = (list['valeurs'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < values.length; i++) {
          rows.add(
            ListValuesCompanion.insert(
              id: uuid.v4(),
              caveId: cellarId,
              createdAt: now,
              updatedAt: now,
              liste: list['liste'] as String,
              code: values[i]['code'] as String,
              libelle: values[i]['libelle'] as String,
              parentCode: Value(values[i]['parent_code'] as String?),
              ordre: Value(i),
              actif: true,
            ),
          );
        }
      }
    }
    await _db.batch((b) => b.insertAll(_db.listValues, rows));
  }
}
