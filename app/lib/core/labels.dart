import '../domain/garde.dart';
import '../domain/stock_rules.dart';
import '../domain/wine_query.dart';
import 'l10n/generated/app_localizations.dart';

/// Libellés traduits des énumérations du domaine (aucune clé technique à
/// l'écran, défaut « wine_0»).
extension DomainLabels on AppLocalizations {
  String sortLabel(SortCriterion c) => switch (c) {
    SortCriterion.vintage => sortVintage,
    SortCriterion.color => sortColor,
    SortCriterion.parkerScore => sortParkerScore,
    SortCriterion.bestScore => sortBestScore,
    SortCriterion.name => sortName,
    SortCriterion.producer => sortProducer,
    SortCriterion.country => sortCountry,
    SortCriterion.region => sortRegion,
    SortCriterion.appellation => sortAppellation,
    SortCriterion.owner => sortOwner,
    SortCriterion.location => sortLocation,
    SortCriterion.purchasePrice => sortPurchasePrice,
    SortCriterion.marketValue => sortMarketValue,
    SortCriterion.quantity => sortQuantity,
    SortCriterion.addedAt => sortAddedAt,
    SortCriterion.gardeStart => sortGardeStart,
    SortCriterion.gardeEnd => sortGardeEnd,
    SortCriterion.gardePeak => sortGardePeak,
    SortCriterion.cellarStatus => sortCellarStatus,
  };

  String sortChipLabel(int rank, SortSpec s) => sortChip(
    rank,
    sortLabel(s.criterion),
    s.ascending ? sortAscending : sortDescending,
  );

  String statusLabel(CellarStatus s) => switch (s) {
    CellarStatus.tooYoung => statusTooYoung,
    CellarStatus.toDrink => statusToDrink,
    CellarStatus.peak => statusPeak,
    CellarStatus.drinkSoon => statusDrinkSoon,
    CellarStatus.past => statusPast,
    CellarStatus.unknown => statusUnknown,
  };

  String stockLabel(StockFilter s) => switch (s) {
    StockFilter.inStock => stockInStock,
    StockFilter.empty => stockEmpty,
    StockFilter.all => stockAll,
  };

  String enrichmentLabel(String code) => switch (code) {
    'brouillon' => enrichBrouillon,
    'a_enrichir' => enrichAEnrichir,
    'en_cours' => enrichEnCours,
    'a_valider' => enrichAValider,
    'erreur' => enrichErreur,
    _ => enrichValide,
  };

  String movementLabel(String code) =>
      switch (MovementType.values.where((t) => t.code == code).firstOrNull) {
        MovementType.entry => mvtEntry,
        MovementType.opening => mvtOpening,
        MovementType.otherExit => mvtOtherExit,
        MovementType.adjustment => mvtAdjustment,
        MovementType.transferOut => mvtTransferOut,
        MovementType.transferIn => mvtTransferIn,
        null => mvtEntry,
      };

  /// Nom d'une liste du dictionnaire dans le Paramétrage (PAR-01).
  String listName(String list) => switch (list) {
    'type_vin' => listNameTypeVin,
    'pays' => listNamePays,
    'region' => listNameRegion,
    'sous_region' => listNameSousRegion,
    'appellation' => listNameAppellation,
    'signe_qualite' => listNameSigneQualite,
    'classement' => listNameClassement,
    'certification' => listNameCertification,
    'cepage' => listNameCepage,
    'format' => listNameFormat,
    'fournisseur' => listNameFournisseur,
    'motif_mouvement' => listNameMotifMouvement,
    'accord_mets' => listNameAccordMets,
    'critique' => listNameCritique,
    _ => list,
  };

  String locationTypeLabel(String type) => switch (type) {
    'cave' => locTypeCave,
    'meuble' => locTypeMeuble,
    'casier' => locTypeCasier,
    'clayette' => locTypeClayette,
    _ => locTypeAutre,
  };

  /// Source d'une valeur (énumération `source_provenance`).
  String sourceLabel(String? code) => switch (code) {
    'etiquette' => srcEtiquette,
    'site_officiel' => srcSiteOfficiel,
    'organisme_officiel' => srcOrganismeOfficiel,
    'interprofession' => srcInterprofession,
    'critique' => srcCritique,
    'marchand' => srcMarchand,
    'estimation' => srcEstimation,
    'manuel' => srcManuel,
    'import' => srcImport,
    _ => srcTiers,
  };

  /// AJO-05 : étape du job, en clair.
  String stepLabel(String? step) => switch (step) {
    'lecture_etiquette' => stepLecture,
    'normalisation' => stepNormalisation,
    'identification' => stepIdentification,
    'enrichissement' => stepEnrichissement,
    'notes' => stepNotes,
    'prix' => stepPrix,
    'controles' => stepControles,
    'termine' => stepTermine,
    _ => stepWaiting,
  };

  String photoTypeLabel(String type) => switch (type) {
    'etiquette' => photoTypeEtiquette,
    'contre_etiquette' => photoTypeContreEtiquette,
    'capsule' => photoTypeCapsule,
    'collerette' => photoTypeCollerette,
    'degustation' => photoTypeDegustation,
    'repas' => photoTypeRepas,
    'evenement' => photoTypeEvenement,
    _ => photoTypeAutre,
  };

  /// Libellé d'un champ du contrat pour l'écran de validation.
  String contractFieldLabel(String field) => switch (field) {
    'domaine' => fieldProducer,
    'domaine_site_officiel' => fieldProducerSite,
    'commentaire_domaine' => fieldProducerComment,
    'cuvee' => fieldCuvee,
    'pays' => fieldCountry,
    'region' => fieldRegion,
    'sous_region' => fieldSubRegion,
    'appellation' => fieldAppellation,
    'signe_qualite' => fieldQualitySign,
    'classement' => fieldClassification,
    'lieu_dit' => fieldLieuDit,
    'couleur' => fieldColor,
    'type' => fieldType,
    'certification' => fieldCertification,
    'millesime' => fieldVintage,
    'cepages' => fieldGrapes,
    'degre' => fieldAlcohol,
    'volume_cl' => fieldFormat,
    'commentaire_millesime' => fieldVintageComment,
    'garde' => fieldGarde,
    'accords' => fieldPairings,
    'lwin' => fieldLwin,
    _ => field,
  };
}
