// Schéma SQLite, une table par entité de specs/dictionnaire-donnees.yaml.
//
// Les noms de colonnes sont les clés `cle` du dictionnaire (drift convertit
// les getters camelCase en snake_case). Les champs `calcule` ne sont pas
// stockés : ils sont calculés à la lecture (stock = somme des mouvements).
// Les champs `action` n'existent qu'à l'import Excel.
// Test d'alignement : test/specs/dictionnaire_test.dart.
//
// Les contraintes CHECK de drift référencent la colonne dans son propre getter.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';

/// Champs techniques communs (docs/04-modele-donnees.md) : id UUID v4,
/// horodatages UTC, suppression logique.
mixin TechnicalColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Champs techniques plus le rattachement à une cave (prépare le multi-caves).
mixin CellarScoped on Table {
  TextColumn get caveId => text().references(Cellars, #id)();
}

@DataClassName('Cellar')
class Cellars extends Table with TechnicalColumns {
  @override
  String get tableName => 'cave';

  TextColumn get nom => text()();
  TextColumn get devise => text().withDefault(const Constant('EUR'))();
}

@DataClassName('Producer')
@TableIndex(name: 'idx_domaine_nom', columns: {#nom})
class Producers extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'domaine';

  TextColumn get nom => text()();
  TextColumn get siteOfficiel => text().nullable()();
  TextColumn get commentaire => text().nullable()();
}

@DataClassName('Cuvee')
@TableIndex(name: 'idx_cuvee_domaine', columns: {#domaineId})
@TableIndex(name: 'idx_cuvee_nom', columns: {#nom})
@TableIndex(name: 'idx_cuvee_pays', columns: {#pays})
@TableIndex(name: 'idx_cuvee_region', columns: {#region})
@TableIndex(name: 'idx_cuvee_appellation', columns: {#appellation})
@TableIndex(name: 'idx_cuvee_couleur', columns: {#couleur})
@TableIndex(name: 'idx_cuvee_type_vin', columns: {#typeVin})
class Cuvees extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'cuvee';

  TextColumn get domaineId => text().references(Producers, #id)();
  TextColumn get nom => text().nullable()();
  TextColumn get pays => text()();
  TextColumn get region => text().nullable()();
  TextColumn get sousRegion => text().nullable()();
  TextColumn get appellation => text().nullable()();
  TextColumn get signeQualite => text().nullable()();
  TextColumn get classement => text().nullable()();
  TextColumn get lieuDit => text().nullable()();
  TextColumn get couleur => text()();
  TextColumn get typeVin => text().nullable()();
  TextColumn get certification => text().nullable()();
}

@DataClassName('Wine')
@TableIndex(name: 'idx_fiche_cuvee', columns: {#cuveeId})
@TableIndex(name: 'idx_fiche_millesime', columns: {#millesime})
@TableIndex(name: 'idx_fiche_garde_debut', columns: {#gardeDebut})
@TableIndex(name: 'idx_fiche_garde_fin', columns: {#gardeFin})
@TableIndex(name: 'idx_fiche_garde_apogee', columns: {#gardeApogee})
@TableIndex(name: 'idx_fiche_statut', columns: {#statutEnrichissement})
@TableIndex(name: 'idx_fiche_favori', columns: {#favori})
@TableIndex(name: 'idx_fiche_created', columns: {#createdAt})
class Wines extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'fiche_vin';

  TextColumn get cuveeId => text().references(Cuvees, #id)();

  /// Année sur 4 chiffres ou « NM » : l'ordre lexical suit l'ordre des années.
  TextColumn get millesime => text().check(
    millesime.equals('NM') |
        (millesime.like('____') & millesime.isBetweenValues('1900', '2999')),
  )();
  TextColumn get cepages => text().nullable()();
  RealColumn get degre => real().nullable()();
  TextColumn get commentaireMillesime => text().nullable()();
  IntColumn get gardeDebut => integer().nullable()();
  IntColumn get gardeApogee => integer().nullable()();
  IntColumn get gardeFin => integer().nullable()();
  TextColumn get gardeSource => text().nullable()();
  TextColumn get accords => text().nullable()();
  TextColumn get ean => text().nullable()();
  TextColumn get lwin => text().nullable()();
  TextColumn get commentairePerso => text().nullable()();
  BoolColumn get favori =>
      boolean().nullable().withDefault(const Constant(false))();
  TextColumn get statutEnrichissement =>
      text().nullable().withDefault(const Constant('brouillon'))();
}

@DataClassName('CriticScore')
@TableIndex(name: 'idx_note_fiche', columns: {#ficheId})
class CriticScores extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'note_critique';

  TextColumn get ficheId => text().references(Wines, #id)();
  TextColumn get critique => text()();
  RealColumn get note => real()();
  IntColumn get echelle => integer()();
  TextColumn get degustateur => text().nullable()();
  TextColumn get dateNote => text().nullable()();
  IntColumn get fenetreDebut => integer().nullable()();
  IntColumn get fenetreFin => integer().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get citeePar => text().nullable()();
}

@DataClassName('StockLot')
@TableIndex(name: 'idx_lot_fiche', columns: {#ficheId})
@TableIndex(name: 'idx_lot_proprietaire', columns: {#proprietaireId})
@TableIndex(name: 'idx_lot_emplacement', columns: {#emplacementId})
@TableIndex(name: 'idx_lot_prix', columns: {#prixAchatUnitaire})
class StockLots extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'lot';

  TextColumn get ficheId => text().references(Wines, #id)();
  RealColumn get formatCl => real().withDefault(const Constant(75))();
  TextColumn get proprietaireId => text().references(Owners, #id)();
  TextColumn get emplacementId =>
      text().nullable().references(StorageLocations, #id)();
  TextColumn get positions => text().nullable()();
  RealColumn get prixAchatUnitaire => real().nullable()();
  TextColumn get dateAchat => text().nullable()();
  TextColumn get fournisseur => text().nullable()();
}

@DataClassName('StockMovement')
@TableIndex(name: 'idx_mouvement_lot', columns: {#lotId})
@TableIndex(name: 'idx_mouvement_type', columns: {#typeMouvement})
class StockMovements extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'mouvement';

  TextColumn get lotId => text().references(StockLots, #id)();
  TextColumn get typeMouvement => text()();

  /// Signée, jamais 0 (STK-R1 à STK-R4).
  IntColumn get quantite => integer().check(quantite.equals(0).not())();
  TextColumn get dateMouvement => text()();
  TextColumn get motif => text().nullable()();
  TextColumn get commentaire => text().nullable()();
  TextColumn get lotLieId => text().nullable().references(StockLots, #id)();
}

@DataClassName('Tasting')
class Tastings extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'degustation';

  TextColumn get ficheId => text().references(Wines, #id)();
  TextColumn get dateDegustation => text()();
  RealColumn get notePerso => real().nullable()();
  TextColumn get commentaire => text().nullable()();
  TextColumn get plat => text().nullable()();
  TextColumn get mouvementId =>
      text().nullable().references(StockMovements, #id)();
}

@DataClassName('MarketPrice')
@TableIndex(name: 'idx_prix_fiche', columns: {#ficheId})
class MarketPrices extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'prix_marche';

  TextColumn get ficheId => text().references(Wines, #id)();
  RealColumn get formatCl => real()();
  TextColumn get dateReleve => text()();
  RealColumn get prix => real().nullable()();
  TextColumn get devise => text()();
  TextColumn get nature => text().nullable()();
  IntColumn get nbOffres => integer().nullable()();
  TextColumn get site => text().nullable()();
  TextColumn get url => text().nullable()();
  BoolColumn get trouve => boolean()();
}

@DataClassName('Photo')
@TableIndex(name: 'idx_photo_fiche', columns: {#ficheId})
class Photos extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'photo';

  TextColumn get ficheId => text().references(Wines, #id)();
  TextColumn get chemin => text()();
  TextColumn get typePhoto => text()();
  BoolColumn get principale => boolean()();
  IntColumn get largeur => integer().nullable()();
  IntColumn get hauteur => integer().nullable()();
  IntColumn get octets => integer().nullable()();
}

@DataClassName('Provenance')
@TableIndex(name: 'idx_provenance_entite', columns: {#entite, #entiteId})
class Provenances extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'provenance';

  TextColumn get entite => text()();
  TextColumn get entiteId => text()();
  TextColumn get champ => text()();
  TextColumn get valeur => text().nullable()();
  TextColumn get source => text()();
  TextColumn get url => text().nullable()();
  RealColumn get confiance => real().nullable()();
  TextColumn get dateCollecte => text()();
  TextColumn get statut => text()();
  BoolColumn get signale => boolean().nullable()();
}

@DataClassName('StorageLocation')
@TableIndex(name: 'idx_emplacement_parent', columns: {#parentId})
class StorageLocations extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'emplacement';

  TextColumn get parentId =>
      text().nullable().references(StorageLocations, #id)();
  TextColumn get nom => text()();
  TextColumn get typeEmplacement => text()();
  IntColumn get lignes => integer().nullable()();
  IntColumn get colonnes => integer().nullable()();
  IntColumn get capacite => integer().nullable()();
}

@DataClassName('Owner')
class Owners extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'proprietaire';

  TextColumn get nom => text()();
  TextColumn get initiales => text().nullable()();
  TextColumn get couleur => text().nullable()();
  BoolColumn get parDefaut => boolean().nullable()();
}

@DataClassName('ListValue')
@TableIndex(name: 'idx_valeur_liste', columns: {#liste, #code})
class ListValues extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'valeur_liste';

  TextColumn get liste => text()();
  TextColumn get code => text()();
  TextColumn get libelle => text()();
  TextColumn get parentCode => text().nullable()();
  IntColumn get ordre => integer().nullable()();
  BoolColumn get actif => boolean()();
}

@DataClassName('Job')
@TableIndex(name: 'idx_job_fiche', columns: {#ficheId})
@TableIndex(name: 'idx_job_statut', columns: {#statut})
class Jobs extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'job';

  TextColumn get ficheId => text().references(Wines, #id)();
  TextColumn get typeJob => text()();
  TextColumn get requestId => text().unique()();
  TextColumn get jobIdDistant => text().nullable()();
  TextColumn get statut => text()();
  IntColumn get tentatives => integer().nullable()();
  TextColumn get erreur => text().nullable()();
}

@DataClassName('SavedStatView')
class SavedStatViews extends Table with TechnicalColumns, CellarScoped {
  @override
  String get tableName => 'vue_statistique';

  TextColumn get nom => text()();
  TextColumn get mesure => text()();
  TextColumn get dimension1 => text().named('dimension_1')();
  TextColumn get dimension2 => text().named('dimension_2').nullable()();
  TextColumn get filtres => text().nullable()();
  TextColumn get graphique => text()();
}
