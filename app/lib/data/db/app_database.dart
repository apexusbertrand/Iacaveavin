import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/wine_list_item.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Base locale de la cave. Version du schéma = numéro de migration.
///
/// Toute évolution du schéma : incrémenter [schemaVersion], lancer
/// `dart run drift_dev make-migrations`, écrire l'étape dans [migration]
/// et compléter le test généré dans test/drift/ (NFR-05).
@DriftDatabase(
  tables: [
    Cellars,
    Producers,
    Cuvees,
    Wines,
    CriticScores,
    StockLots,
    StockMovements,
    Tastings,
    MarketPrices,
    Photos,
    Provenances,
    StorageLocations,
    Owners,
    ListValues,
    Jobs,
    SavedStatViews,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base de l'application, ouverte dans un isolate dédié par drift_flutter.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'iacaveavin'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Les étapes numérotées arriveront ici (stepByStep généré par drift_dev).
      throw UnsupportedError('Migration $from -> $to non prévue');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Fiches non supprimées avec leur stock calculé depuis les mouvements.
  ///
  /// Tri provisoire du lot 0 : millésime décroissant puis domaine.
  /// Le tri et les filtres configurables arrivent au lot 1 (LST-01, LST-05).
  Stream<List<WineListItem>> watchWineList() {
    return customSelect(
      _wineListSql,
      readsFrom: {
        wines,
        cuvees,
        producers,
        stockLots,
        stockMovements,
        listValues,
      },
    ).watch().map((rows) => rows.map(_toItem).toList(growable: false));
  }

  Future<List<WineListItem>> wineList() async {
    final rows = await customSelect(_wineListSql).get();
    return rows.map(_toItem).toList(growable: false);
  }

  static WineListItem _toItem(QueryRow r) => WineListItem(
    id: r.read<String>('id'),
    producer: r.read<String>('domaine'),
    cuvee: r.readNullable<String>('cuvee'),
    vintage: r.read<String>('millesime'),
    colorCode: r.read<String>('couleur'),
    countryCode: r.read<String>('pays'),
    countryLabel: r.readNullable<String>('pays_libelle'),
    region: r.readNullable<String>('region_libelle'),
    subRegion: r.readNullable<String>('sous_region_libelle'),
    appellation: r.readNullable<String>('appellation_libelle'),
    bottles: r.read<int>('stock'),
    purchasePrice: r.readNullable<double>('prix'),
    enrichmentStatus:
        r.readNullable<String>('statut_enrichissement') ?? 'brouillon',
  );

  static String _label(String liste, String column) =>
      '(SELECT v.libelle FROM valeur_liste v '
      "WHERE v.liste = '$liste' AND v.code = $column AND v.deleted_at IS NULL "
      'LIMIT 1)';

  static final _wineListSql =
      '''
SELECT f.id, f.millesime, f.statut_enrichissement,
       d.nom AS domaine, c.nom AS cuvee, c.couleur, c.pays,
       ${_label('pays', 'c.pays')} AS pays_libelle,
       ${_label('region', 'c.region')} AS region_libelle,
       ${_label('sous_region', 'c.sous_region')} AS sous_region_libelle,
       ${_label('appellation', 'c.appellation')} AS appellation_libelle,
       COALESCE(s.stock, 0) AS stock,
       (SELECT l.prix_achat_unitaire FROM lot l
         WHERE l.fiche_id = f.id AND l.deleted_at IS NULL
           AND l.prix_achat_unitaire IS NOT NULL
         ORDER BY l.date_achat DESC LIMIT 1) AS prix
FROM fiche_vin f
JOIN cuvee c ON c.id = f.cuvee_id
JOIN domaine d ON d.id = c.domaine_id
LEFT JOIN (
  SELECT l.fiche_id, SUM(m.quantite) AS stock
  FROM lot l JOIN mouvement m ON m.lot_id = l.id
  WHERE l.deleted_at IS NULL AND m.deleted_at IS NULL
  GROUP BY l.fiche_id
) s ON s.fiche_id = f.id
WHERE f.deleted_at IS NULL
ORDER BY f.millesime DESC, d.nom, c.nom
''';
}
