// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'IA cave à vin';

  @override
  String get navMyWines => 'Mes vins';

  @override
  String get navToDrink => 'À boire';

  @override
  String get navLocations => 'Emplacements';

  @override
  String get navStatistics => 'Statistiques';

  @override
  String get navShoppingList => 'Liste d\'achats';

  @override
  String get navImportExport => 'Import et export';

  @override
  String get navBackup => 'Sauvegarde';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navAbout => 'À propos';

  @override
  String get placeholderTitle => 'Bientôt disponible';

  @override
  String placeholderBody(String lot) {
    return 'Cet écran arrive avec le lot $lot.';
  }

  @override
  String get wineListTitle => 'Mes vins';

  @override
  String wineListSummary(int wines, int bottles) {
    String _temp0 = intl.Intl.pluralLogic(
      wines,
      locale: localeName,
      other: '$wines vins',
      one: '1 vin',
      zero: 'Aucun vin',
    );
    String _temp1 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bouteilles',
      one: '1 bouteille',
      zero: '0 bouteille',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get wineListEmptyTitle => 'Aucun vin.';

  @override
  String get wineListEmptyBody =>
      'Photographiez votre première étiquette, ou chargez le jeu de démonstration pour découvrir l\'application.';

  @override
  String get wineListLoading => 'Chargement de la cave';

  @override
  String get wineListErrorTitle => 'La cave n\'a pas pu être lue.';

  @override
  String wineListErrorDetail(String detail) {
    return 'Détail : $detail';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get addBottle => 'Ajouter une bouteille';

  @override
  String get addBottleLater =>
      'L\'ajout d\'une bouteille arrive au lot 1 (saisie) et au lot 2a (photo).';

  @override
  String get nonVintage => 'NM';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '1 bouteille',
      zero: 'Épuisé',
    );
    return '$_temp0';
  }

  @override
  String get toValidate => 'À valider';

  @override
  String wineCardSemantics(String name, String vintage, String bottles) {
    return '$name, millésime $vintage, $bottles';
  }

  @override
  String get backToTop => 'Haut de la page';

  @override
  String get settingsDemoSection => 'Jeu de démonstration';

  @override
  String get settingsDemoDescription =>
      '200 fiches fictives (domaines inventés) pour essayer l\'application et vérifier la fluidité. Vos propres vins ne sont jamais touchés.';

  @override
  String settingsDemoLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Démonstration chargée : $count fiches',
      one: 'Démonstration chargée : 1 fiche',
    );
    return '$_temp0';
  }

  @override
  String get settingsDemoNotLoaded => 'Démonstration non chargée';

  @override
  String get settingsDemoLoad => 'Charger la démonstration';

  @override
  String get settingsDemoErase => 'Effacer la démonstration';

  @override
  String get settingsDemoEraseTitle => 'Effacer la démonstration ?';

  @override
  String get settingsDemoEraseBody =>
      'Les fiches de démonstration, leurs lots et leurs mouvements seront supprimés. Vos propres vins ne sont pas touchés.';

  @override
  String get settingsDemoLoadedSnack => 'Démonstration chargée.';

  @override
  String get settingsDemoErasedSnack => 'Démonstration effacée.';

  @override
  String get settingsMoreLater =>
      'Les autres réglages (connexion au flux, devise, thème, listes) arrivent au lot 1.';

  @override
  String operationFailed(String detail) {
    return 'L\'opération a échoué : $detail';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get erase => 'Effacer';

  @override
  String get aboutDescription =>
      'Gestion de cave à vin aux couleurs d\'Apexus-BMT. Les données restent sur ce téléphone.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutHealthWarning =>
      'L\'abus d\'alcool est dangereux pour la santé, à consommer avec modération.';

  @override
  String get aboutReferenceData =>
      'Référentiels : pays selon ISO 3166-1. Appellations, régions et cépages : listes provisoires, à remplacer par les données ouvertes de l\'INAO.';

  @override
  String get aboutDemoNotice =>
      'Les domaines du jeu de démonstration sont inventés.';

  @override
  String get search => 'Rechercher';

  @override
  String get searchHint => 'Nom, domaine, appellation, cépage…';

  @override
  String get closeSearch => 'Fermer la recherche';

  @override
  String get sort => 'Trier';

  @override
  String get filters => 'Filtrer';

  @override
  String get cardView => 'Vue cartes';

  @override
  String get compactView => 'Vue compacte';

  @override
  String activeFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtres actifs',
      one: '1 filtre actif',
    );
    return '$_temp0';
  }

  @override
  String get resetFilters => 'Réinitialiser';

  @override
  String sortChip(int rank, String criterion, String direction) {
    return 'Tri $rank : $criterion ($direction)';
  }

  @override
  String get sortAscending => 'A-Z';

  @override
  String get sortDescending => 'Z-A';

  @override
  String get sortFirst => 'Tri 1';

  @override
  String get sortSecond => 'Tri 2';

  @override
  String get sortNone => 'Aucun';

  @override
  String get sortDirection => 'Ordre décroissant';

  @override
  String get apply => 'Appliquer';

  @override
  String get sortVintage => 'Millésime';

  @override
  String get sortColor => 'Couleur';

  @override
  String get sortParkerScore => 'Note Parker';

  @override
  String get sortBestScore => 'Meilleure note';

  @override
  String get sortName => 'Nom';

  @override
  String get sortProducer => 'Domaine';

  @override
  String get sortCountry => 'Pays';

  @override
  String get sortRegion => 'Région';

  @override
  String get sortAppellation => 'Appellation';

  @override
  String get sortOwner => 'Propriétaire';

  @override
  String get sortLocation => 'Emplacement';

  @override
  String get sortPurchasePrice => 'Prix d\'achat';

  @override
  String get sortMarketValue => 'Valeur marché';

  @override
  String get sortQuantity => 'Quantité';

  @override
  String get sortAddedAt => 'Date d\'ajout';

  @override
  String get sortGardeStart => 'Début de garde';

  @override
  String get sortGardeEnd => 'Fin de garde';

  @override
  String get sortGardePeak => 'Année d\'apogée';

  @override
  String get sortCellarStatus => 'Statut de garde';

  @override
  String get groupUnknown => 'Non renseigné';

  @override
  String groupSummary(int wines, int bottles) {
    String _temp0 = intl.Intl.pluralLogic(
      wines,
      locale: localeName,
      other: '$wines vins',
      one: '1 vin',
    );
    String _temp1 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bouteilles',
      one: '1 bouteille',
      zero: '0 bouteille',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get stockInStock => 'En stock';

  @override
  String get stockEmpty => 'Épuisé';

  @override
  String get stockAll => 'Tous';

  @override
  String get filterStock => 'Stock';

  @override
  String get filterColors => 'Couleur';

  @override
  String get filterTypes => 'Type';

  @override
  String get filterCountries => 'Pays';

  @override
  String get filterRegions => 'Région';

  @override
  String get filterAppellations => 'Appellation';

  @override
  String get filterVintages => 'Millésimes';

  @override
  String get filterOwners => 'Propriétaire';

  @override
  String get filterLocation => 'Emplacement (avec ses sous-emplacements)';

  @override
  String get filterStatuses => 'Statut de garde';

  @override
  String get filterIdealYear => 'Année de consommation idéale';

  @override
  String get filterMinScore => 'Note minimale (sur 100)';

  @override
  String get filterPrice => 'Prix d\'achat';

  @override
  String get filterGrapes => 'Cépage';

  @override
  String get filterEnrichment => 'Statut d\'enrichissement';

  @override
  String get filterFavorites => 'Favoris uniquement';

  @override
  String get rangeFrom => 'De';

  @override
  String get rangeTo => 'À';

  @override
  String get anyLocation => 'Tous les emplacements';

  @override
  String get statusTooYoung => 'Trop jeune';

  @override
  String get statusToDrink => 'À boire';

  @override
  String get statusPeak => 'Apogée';

  @override
  String get statusDrinkSoon => 'À boire vite';

  @override
  String get statusPast => 'Passé';

  @override
  String get statusUnknown => 'Garde inconnue';

  @override
  String get enrichBrouillon => 'Brouillon';

  @override
  String get enrichAEnrichir => 'À enrichir';

  @override
  String get enrichEnCours => 'Enrichissement en cours';

  @override
  String get enrichAValider => 'À valider';

  @override
  String get enrichValide => 'Validé';

  @override
  String get enrichErreur => 'Erreur d\'enrichissement';

  @override
  String get noResults => 'Aucun vin ne correspond.';

  @override
  String get noResultsBody => 'Modifiez la recherche ou les filtres.';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Annuler la sélection';

  @override
  String get moveSelection => 'Déplacer';

  @override
  String get changeOwnerSelection => 'Changer de propriétaire';

  @override
  String selectionDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fiches mises à jour',
      one: '1 fiche mise à jour',
    );
    return '$_temp0';
  }

  @override
  String get laterPdf => 'PDF (lot 3)';

  @override
  String get laterExcel => 'Export Excel (lot 3)';

  @override
  String get laterEnrich => 'Ré-enrichir (lot 2a)';

  @override
  String get openOneBottle => 'Ouvrir 1 bouteille';

  @override
  String bottleOpened(String name) {
    return '1 bouteille ouverte : $name';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get noStockToOpen => 'Plus aucune bouteille à ouvrir.';

  @override
  String get favorite => 'Favori';

  @override
  String get externalBackupReminder =>
      'Aucune sauvegarde exportée depuis 30 jours.';

  @override
  String get exportNow => 'Exporter';

  @override
  String get mvtEntry => 'Entrée';

  @override
  String get mvtOpening => 'Ouverture';

  @override
  String get mvtOtherExit => 'Sortie';

  @override
  String get mvtAdjustment => 'Ajustement';

  @override
  String get mvtTransferOut => 'Transfert sortant';

  @override
  String get mvtTransferIn => 'Transfert entrant';

  @override
  String get parkerInitial => 'P';

  @override
  String scoreSemantics(String score) {
    return 'note $score';
  }

  @override
  String get selected => 'sélectionné';

  @override
  String get wineNotFound => 'Cette fiche n\'existe plus.';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteWineTitle => 'Supprimer cette fiche ?';

  @override
  String get deleteWineBody =>
      'La fiche et ses lots quittent la liste. L\'historique des mouvements est conservé.';

  @override
  String get wineDeleted => 'Fiche supprimée.';

  @override
  String remaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count restantes',
      one: '1 restante',
      zero: '0 restante',
    );
    return '$_temp0';
  }

  @override
  String consumed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count consommées',
      one: '1 consommée',
      zero: '0 consommée',
    );
    return '$_temp0';
  }

  @override
  String formatCl(String format) {
    return '$format cl';
  }

  @override
  String addBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count bouteilles',
      one: 'Ajouter 1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String openBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ouvrir $count bouteilles',
      one: 'Ouvrir 1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String get decrease => 'Moins';

  @override
  String get increase => 'Plus';

  @override
  String get tabInfo => 'Informations';

  @override
  String get tabOperations => 'Opérations';

  @override
  String get tabTastings => 'Dégustations';

  @override
  String get tabPrices => 'Prix';

  @override
  String get sectionOrigin => 'Origine';

  @override
  String get sectionCellar => 'Cave';

  @override
  String get sectionWine => 'Vin';

  @override
  String get sectionComments => 'Commentaires';

  @override
  String get fieldCountry => 'Pays';

  @override
  String get fieldRegion => 'Région';

  @override
  String get fieldSubRegion => 'Sous-région';

  @override
  String get fieldAppellation => 'Appellation';

  @override
  String get fieldQualitySign => 'Signe de qualité';

  @override
  String get fieldClassification => 'Classement';

  @override
  String get fieldLieuDit => 'Lieu-dit';

  @override
  String get fieldProducer => 'Domaine';

  @override
  String get fieldCuvee => 'Cuvée';

  @override
  String get fieldColor => 'Couleur';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldCertification => 'Certification';

  @override
  String get fieldVintage => 'Millésime';

  @override
  String get fieldVintageHint => 'Année sur 4 chiffres, ou NM';

  @override
  String get fieldGrapes => 'Cépages';

  @override
  String get fieldAlcohol => 'Degré (%)';

  @override
  String get fieldGarde => 'Garde';

  @override
  String get fieldGardeStart => 'À boire à partir de';

  @override
  String get fieldGardePeak => 'Apogée';

  @override
  String get fieldGardeEnd => 'À boire avant';

  @override
  String get fieldPairings => 'Accords mets et vins';

  @override
  String get fieldScores => 'Notes critiques';

  @override
  String get fieldEan => 'Code-barres EAN';

  @override
  String get fieldLwin => 'LWIN';

  @override
  String get fieldProducerSite => 'Site officiel';

  @override
  String get fieldProducerComment => 'Le domaine';

  @override
  String get fieldVintageComment => 'Le millésime';

  @override
  String get fieldPersonalComment => 'Mon commentaire';

  @override
  String get fieldLocation => 'Emplacement';

  @override
  String get fieldPositions => 'Positions';

  @override
  String get fieldPositionsHint => 'Cases de la grille, ex. A3, B5';

  @override
  String get fieldOwners => 'Propriétaires';

  @override
  String get fieldOwner => 'Propriétaire';

  @override
  String get fieldQuantity => 'Quantité';

  @override
  String get fieldFormat => 'Format';

  @override
  String get fieldUnitPrice => 'Prix d\'achat unitaire TTC';

  @override
  String get fieldPurchaseDate => 'Date d\'achat';

  @override
  String get fieldFavorite => 'Favori';

  @override
  String gardeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get gardeEstimated => 'estimée';

  @override
  String ownerShare(String name, int count) {
    return '$name $count';
  }

  @override
  String get emptyValue => '-';

  @override
  String citedBy(String site) {
    return 'cité par $site';
  }

  @override
  String get noMovements => 'Aucun mouvement.';

  @override
  String movementLine(String type, String quantity) {
    return '$type · $quantity';
  }

  @override
  String movementDetail(String date, String lot) {
    return '$date · $lot';
  }

  @override
  String get noTastings => 'Aucune dégustation notée.';

  @override
  String get addTasting => 'Noter une dégustation';

  @override
  String get tastingTitle => 'Dégustation';

  @override
  String tastingScore(int scale) {
    return 'Ma note (sur $scale)';
  }

  @override
  String get tastingDish => 'Plat servi';

  @override
  String get tastingComment => 'Commentaire';

  @override
  String get tastingPhotos => 'Photos de la dégustation';

  @override
  String get tastingPhotoRemove => 'Retirer la photo';

  @override
  String tastingPhotosMax(int count) {
    return '$count photos au plus par dégustation.';
  }

  @override
  String get tastingPrompt => 'Noter cette dégustation ?';

  @override
  String get later => 'Plus tard';

  @override
  String get save => 'Enregistrer';

  @override
  String get tastingSaved => 'Dégustation enregistrée.';

  @override
  String get purchasePrices => 'Prix d\'achat par lot';

  @override
  String get marketPrices => 'Prix marché';

  @override
  String get noPurchasePrice => 'Prix d\'achat inconnu';

  @override
  String get noMarketPrice => 'Aucun prix marché relevé pour l\'instant.';

  @override
  String lastMarketPrice(String price, String date) {
    return 'Dernier prix : $price le $date';
  }

  @override
  String priceNotFound(String date) {
    return 'Non trouvé le $date';
  }

  @override
  String get refreshPrice => 'Relever le prix';

  @override
  String get lots => 'Lots';

  @override
  String lotLine(String owner, String format, int count) {
    return '$owner · $format cl · $count';
  }

  @override
  String get noLocation => 'Sans emplacement';

  @override
  String get chooseLot => 'Choisir le lot';

  @override
  String get adjustStock => 'Corriger le stock';

  @override
  String get adjustTitle => 'Quantité réelle du lot';

  @override
  String get adjustReason => 'Motif';

  @override
  String adjustDone(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: 'Écart corrigé : $delta',
      zero: 'Aucun écart',
    );
    return '$_temp0';
  }

  @override
  String get noDifference => 'Aucun écart, rien à corriger.';

  @override
  String get transfer => 'Transférer';

  @override
  String get transferTitle => 'Transférer des bouteilles';

  @override
  String get transferDone => 'Transfert enregistré.';

  @override
  String get newLot => 'Nouveau lot';

  @override
  String get restock => 'Réapprovisionner';

  @override
  String stockAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles ajoutées',
      one: '1 bouteille ajoutée',
    );
    return '$_temp0';
  }

  @override
  String stockOpened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles ouvertes',
      one: '1 bouteille ouverte',
    );
    return '$_temp0';
  }

  @override
  String get stockErrorNegative =>
      'Stock insuffisant : le lot deviendrait négatif.';

  @override
  String get stockErrorReason => 'Choisissez un motif.';

  @override
  String get stockErrorSameLot =>
      'Choisissez un autre emplacement ou propriétaire.';

  @override
  String get stockErrorOther => 'Opération refusée.';

  @override
  String get whereIsIt => 'Où est-il ?';

  @override
  String get newWineTitle => 'Nouveau vin';

  @override
  String get editWineTitle => 'Modifier la fiche';

  @override
  String get firstLot => 'Premier lot';

  @override
  String get errorRequired => 'Champ obligatoire';

  @override
  String get errorVintage => 'Millésime entre 1900 et l\'année en cours, ou NM';

  @override
  String get errorAlcohol => 'Degré entre 5 et 23';

  @override
  String get errorGardeOrder => 'Il faut millésime ≤ début ≤ apogée ≤ fin';

  @override
  String get errorEan => '13 chiffres avec une clé de contrôle valide';

  @override
  String get errorLwin => '7 ou 11 chiffres';

  @override
  String get errorGrapesTotal => 'Le total des pourcentages doit faire 100 %';

  @override
  String get errorPositions => 'Positions invalides pour cette grille';

  @override
  String get errorNumber => 'Nombre attendu';

  @override
  String get duplicateTitle => 'Ce vin existe déjà';

  @override
  String get duplicateBody =>
      'Une fiche porte déjà ce domaine, cette cuvée et ce millésime. L\'ouvrir pour ajouter des bouteilles ?';

  @override
  String get openExisting => 'Ouvrir la fiche';

  @override
  String get createAnyway => 'Créer quand même';

  @override
  String get wineSaved => 'Fiche enregistrée.';

  @override
  String get choose => 'Choisir';

  @override
  String get none => 'Aucun';

  @override
  String get searchList => 'Rechercher dans la liste';

  @override
  String addToList(String value) {
    return 'Ajouter « $value »';
  }

  @override
  String get addGrape => 'Ajouter un cépage';

  @override
  String get grapePercent => '%';

  @override
  String get removeGrape => 'Retirer';

  @override
  String get addPairing => 'Ajouter un accord';

  @override
  String selectedCount(int count) {
    return '$count choisis';
  }

  @override
  String get locationsEmpty => 'Aucun emplacement.';

  @override
  String get locationsEmptyBody =>
      'Créez la cave, puis ses meubles, casiers et clayettes (4 niveaux).';

  @override
  String get addLocation => 'Ajouter un emplacement';

  @override
  String get addSubLocation => 'Ajouter un sous-emplacement';

  @override
  String get editLocation => 'Modifier l\'emplacement';

  @override
  String get deleteLocation => 'Supprimer l\'emplacement';

  @override
  String get locationName => 'Nom';

  @override
  String get locationType => 'Type';

  @override
  String get locationRows => 'Lignes (1 à 26)';

  @override
  String get locationCols => 'Colonnes (1 à 50)';

  @override
  String get locationCapacity => 'Capacité (bouteilles)';

  @override
  String get locTypeCave => 'Cave';

  @override
  String get locTypeMeuble => 'Meuble';

  @override
  String get locTypeCasier => 'Casier';

  @override
  String get locTypeClayette => 'Clayette';

  @override
  String get locTypeAutre => 'Autre';

  @override
  String locationFill(int bottles, int capacity, int percent) {
    return '$bottles / $capacity · $percent %';
  }

  @override
  String locationBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '1 bouteille',
      zero: 'Vide',
    );
    return '$_temp0';
  }

  @override
  String get overCapacity => 'Au-delà de la capacité';

  @override
  String locationGrid(int rows, int cols) {
    return 'Grille $rows × $cols';
  }

  @override
  String get errorDepth =>
      '4 niveaux au plus : cave, meuble, casier, clayette.';

  @override
  String get errorGrid => 'Grille de 1 à 26 lignes et de 1 à 50 colonnes.';

  @override
  String get errorNotEmpty =>
      'Cet emplacement contient des bouteilles ou des sous-emplacements.';

  @override
  String get errorInUse => 'Valeur utilisée : suppression impossible.';

  @override
  String get errorDuplicate => 'Cette valeur existe déjà.';

  @override
  String get errorCsv => 'Fichier CSV invalide : rien n\'a été importé.';

  @override
  String get locationWines => 'Vins rangés ici';

  @override
  String highlightedPositions(String positions) {
    return 'Positions de ce vin : $positions';
  }

  @override
  String get inventory => 'Inventaire';

  @override
  String inventoryTitle(String location) {
    return 'Inventaire : $location';
  }

  @override
  String get inventoryConfirm => 'Confirmer';

  @override
  String get inventoryCorrect => 'Corriger';

  @override
  String get inventoryNext => 'Emplacement suivant';

  @override
  String get inventoryFinish => 'Terminer';

  @override
  String get inventoryReport => 'Rapport d\'inventaire';

  @override
  String inventoryReportLine(String wine, int before, int after) {
    return '$wine : $before → $after';
  }

  @override
  String get inventoryNoGap => 'Aucun écart : le stock est juste.';

  @override
  String inventoryGaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count écarts corrigés',
      one: '1 écart corrigé',
    );
    return '$_temp0';
  }

  @override
  String inventoryProgress(int done, int total) {
    return '$done / $total lots vérifiés';
  }

  @override
  String get inventoryEmpty => 'Aucun lot à vérifier ici.';

  @override
  String get close => 'Fermer';

  @override
  String get settingsGeneral => 'Réglages';

  @override
  String get settingsCurrency => 'Devise';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get settingsDefaultOwner => 'Propriétaire par défaut';

  @override
  String get settingsDefaultLocation => 'Emplacement par défaut';

  @override
  String get settingsDefaultSort => 'Tri par défaut';

  @override
  String get settingsDefaultSortSet => 'Utiliser le tri actuel de la liste';

  @override
  String get settingsScale => 'Échelle de mes notes';

  @override
  String get scale20 => 'Sur 20';

  @override
  String get scale100 => 'Sur 100';

  @override
  String get settingsCardPrice => 'Prix affiché sur les cartes';

  @override
  String get cardPricePurchase => 'Prix d\'achat';

  @override
  String get cardPriceMarket => 'Valeur marché';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsHint =>
      'Apogée et fin d\'enrichissement (lots 2a et 4).';

  @override
  String get settingsAutoPrices => 'Rafraîchissement mensuel des prix';

  @override
  String get settingsAutoPricesHint =>
      'Une fois par mois, les fiches sans relevé récent sont mises en file. Désactivé par défaut.';

  @override
  String get settingsConnection => 'Connexion au flux d\'enrichissement';

  @override
  String get settingsConnectionHint =>
      'Adresse de l\'instance n8n et clé secrète partagée avec le flux.';

  @override
  String get settingsPhotoSpace => 'Espace occupé par les photos';

  @override
  String photoSpaceValue(String size) {
    return '$size';
  }

  @override
  String get settingsReference => 'Paramétrage';

  @override
  String get settingsOwners => 'Propriétaires';

  @override
  String get settingsLists => 'Listes de valeurs';

  @override
  String get settingsGardeRules => 'Règles de garde';

  @override
  String get ownersEmpty => 'Aucun propriétaire.';

  @override
  String get addOwner => 'Ajouter un propriétaire';

  @override
  String get editOwner => 'Modifier le propriétaire';

  @override
  String get ownerName => 'Nom';

  @override
  String get ownerInitials => 'Initiales (2 à 3 lettres)';

  @override
  String get ownerDefault => 'Propriétaire par défaut';

  @override
  String ownerBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '1 bouteille',
      zero: 'Aucune bouteille',
    );
    return '$_temp0';
  }

  @override
  String get defaultBadge => 'par défaut';

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valeurs',
      one: '1 valeur',
    );
    return '$_temp0';
  }

  @override
  String get listNameTypeVin => 'Types de vin';

  @override
  String get listNamePays => 'Pays';

  @override
  String get listNameRegion => 'Régions';

  @override
  String get listNameSousRegion => 'Sous-régions';

  @override
  String get listNameAppellation => 'Appellations';

  @override
  String get listNameSigneQualite => 'Signes de qualité';

  @override
  String get listNameClassement => 'Classements';

  @override
  String get listNameCertification => 'Certifications';

  @override
  String get listNameCepage => 'Cépages';

  @override
  String get listNameFormat => 'Formats';

  @override
  String get listNameFournisseur => 'Fournisseurs';

  @override
  String get listNameMotifMouvement => 'Motifs de mouvement';

  @override
  String get listNameAccordMets => 'Accords mets et vins';

  @override
  String get listNameCritique => 'Critiques';

  @override
  String get addValue => 'Ajouter une valeur';

  @override
  String get renameValue => 'Renommer';

  @override
  String get deactivateValue => 'Désactiver';

  @override
  String get activateValue => 'Réactiver';

  @override
  String get mergeValue => 'Fusionner dans…';

  @override
  String mergeTitle(String from) {
    return 'Fusionner « $from » dans…';
  }

  @override
  String get mergeDone => 'Valeurs fusionnées, fiches re-pointées.';

  @override
  String get deleteValue => 'Supprimer';

  @override
  String get inactive => 'désactivée';

  @override
  String get valueLabel => 'Libellé';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get importCsv => 'Importer un CSV';

  @override
  String importDone(int created, int updated) {
    return '$created créées, $updated mises à jour';
  }

  @override
  String get gardeRulesPending => 'Valeurs par défaut à valider';

  @override
  String get gardeRulesIntro =>
      'Règles appliquées sur le téléphone quand aucune fenêtre n\'est fournie par un critique ou le domaine. Décalages en années après le millésime.';

  @override
  String gardeRuleLine(int start, int peak, int end) {
    return 'Début +$start · apogée +$peak · fin +$end';
  }

  @override
  String get gardeRuleDefault => 'Règle par défaut';

  @override
  String get backupIntro =>
      'La sauvegarde automatique d\'Android ne suffit pas pour les photos : exportez régulièrement une archive vers Drive, un mail ou un PC.';

  @override
  String get backupExport => 'Exporter une archive sans photos';

  @override
  String get backupExportHint => 'Quelques Mo, à faire souvent.';

  @override
  String get backupExportFull => 'Exporter une archive complète';

  @override
  String get backupExportFullHint => 'Base et photos.';

  @override
  String get backupRestore => 'Restaurer une archive';

  @override
  String get backupRestoreHint =>
      'Remplace toute la cave par le contenu de l\'archive.';

  @override
  String get backupRestoreTitle => 'Restaurer cette archive ?';

  @override
  String backupRestoreBody(String date, int wines) {
    return 'Archive du $date, $wines fiches. La cave actuelle sera entièrement remplacée.';
  }

  @override
  String get backupRestored => 'Archive restaurée.';

  @override
  String get backupShared => 'Archive prête : choisissez où l\'envoyer.';

  @override
  String get backupAuto => 'Sauvegardes automatiques';

  @override
  String get backupAutoHint =>
      'Une par semaine sur le téléphone, les 3 dernières conservées.';

  @override
  String get backupAutoNone => 'Aucune sauvegarde automatique pour l\'instant.';

  @override
  String backupLastExternal(String date) {
    return 'Dernier export : $date';
  }

  @override
  String get backupNeverExported => 'Aucun export pour l\'instant.';

  @override
  String get backupErrorArchive =>
      'Ce fichier n\'est pas une archive IA cave à vin.';

  @override
  String get backupErrorNewer =>
      'Archive créée par une version plus récente de l\'application : mettez l\'application à jour.';

  @override
  String get backupErrorCorrupted =>
      'Archive endommagée : la cave n\'a pas été modifiée.';

  @override
  String get restoreFromAuto => 'Restaurer';

  @override
  String bottlesWithoutPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles sans prix',
      one: '1 bouteille sans prix',
    );
    return '$_temp0';
  }

  @override
  String get addMenuTitle => 'Ajouter un vin';

  @override
  String get addByPhoto => 'Photographier l\'étiquette';

  @override
  String get addByPhotoHint =>
      '1 à 4 photos, la fiche se remplit presque seule.';

  @override
  String get addByBarcode => 'Avec le code-barres';

  @override
  String get addByBarcodeHint =>
      'Scanner l\'EAN puis photographier : il aide l\'identification.';

  @override
  String get addManual => 'Saisie manuelle';

  @override
  String get addManualHint => 'Remplir la fiche soi-même.';

  @override
  String get addExcel => 'Import Excel';

  @override
  String get addExcelHint => 'Classeur xlsx, avec simulation avant import.';

  @override
  String get unidentifiedWine => 'Vin à identifier';

  @override
  String get captureTitle => 'Photos de la bouteille';

  @override
  String get captureHint =>
      'Cadrez l\'étiquette entière, bien droite, sans reflet. Ajoutez la contre-étiquette si elle porte le degré ou les cépages.';

  @override
  String get photoTypeEtiquette => 'Étiquette';

  @override
  String get photoTypeContreEtiquette => 'Contre-étiquette';

  @override
  String get photoTypeCapsule => 'Capsule';

  @override
  String get photoTypeCollerette => 'Collerette';

  @override
  String get photoTypeAutre => 'Autre';

  @override
  String get takePhoto => 'Appareil photo';

  @override
  String get fromGallery => 'Galerie';

  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get retakePhoto => 'Reprendre';

  @override
  String get keepPhoto => 'Garder';

  @override
  String get photoBlurry =>
      'Photo floue : reprenez-la pour une meilleure lecture.';

  @override
  String get photoGlare =>
      'Reflet sur l\'étiquette : changez d\'angle ou évitez le flash.';

  @override
  String get photoProcessing => 'Traitement de la photo…';

  @override
  String get photoUnreadable => 'Image illisible.';

  @override
  String get eanField => 'Code-barres EAN (facultatif)';

  @override
  String get scanLive => 'Scanner le code-barres';

  @override
  String get scanFromPhoto => 'Lire le code-barres sur une photo';

  @override
  String get scanTitle => 'Code-barres';

  @override
  String get scanHint =>
      'Cadrez le code-barres de la contre-étiquette : il est lu tout seul.';

  @override
  String scanFound(String code) {
    return 'Code-barres lu : $code';
  }

  @override
  String get scanNotFound => 'Aucun code-barres EAN lisible sur cette photo.';

  @override
  String get scanPermissionDenied => 'Accès à l\'appareil photo refusé';

  @override
  String get scanUnavailable =>
      'Lecteur de code-barres indisponible sur cet appareil';

  @override
  String get scanUseField => 'Saisissez les 13 chiffres dans le champ.';

  @override
  String get vintageScanLive => 'Lire le millésime avec l\'appareil photo';

  @override
  String get vintageScanFromPhoto => 'Lire le millésime sur une photo';

  @override
  String get vintageScanTitle => 'Millésime';

  @override
  String get vintageScanHint =>
      'Cadrez l\'année inscrite sur l\'étiquette ou la collerette : elle est lue toute seule.';

  @override
  String vintageScanSeen(String year) {
    return 'Lu : $year, gardez la bouteille immobile…';
  }

  @override
  String vintageScanFound(String year) {
    return 'Millésime lu : $year';
  }

  @override
  String get vintageScanNotFound => 'Aucun millésime lisible sur cette photo.';

  @override
  String get vintageScanUnavailable =>
      'Lecture du millésime indisponible sur cet appareil';

  @override
  String get vintageScanUseField => 'Saisissez les 4 chiffres dans le champ.';

  @override
  String get vintageHintField => 'Millésime si vous le connaissez (facultatif)';

  @override
  String get continueToEnrichment => 'Lancer l\'identification';

  @override
  String get needOnePhoto => 'Ajoutez au moins une photo de l\'étiquette.';

  @override
  String get consentTitle => 'Envoi des photos';

  @override
  String get consentBody =>
      'Pour identifier le vin, les photos d\'étiquettes sont envoyées au flux d\'enrichissement sur le serveur, lues, puis effacées après le traitement. Aucune autre donnée de votre cave n\'est envoyée.';

  @override
  String get consentAccept => 'J\'accepte';

  @override
  String get consentRefuse => 'Refuser';

  @override
  String get consentRefused =>
      'Photos gardées sur le téléphone, fiche à compléter à la main.';

  @override
  String get enrichTitle => 'Identification';

  @override
  String get enrichLotTitle => 'Pendant ce temps, le lot';

  @override
  String get saveLot => 'Enregistrer le lot';

  @override
  String get lotSaved => 'Lot enregistré.';

  @override
  String get stepWaiting => 'En attente d\'envoi';

  @override
  String get stepLecture => 'Lecture de l\'étiquette';

  @override
  String get stepNormalisation => 'Mise en forme';

  @override
  String get stepIdentification => 'Identification du vin';

  @override
  String get stepEnrichissement => 'Recherche des informations';

  @override
  String get stepNotes => 'Recherche des notes';

  @override
  String get stepPrix => 'Recherche des prix';

  @override
  String get stepControles => 'Contrôles';

  @override
  String get stepTermine => 'Terminé';

  @override
  String get enrichOffline =>
      'Hors ligne : la fiche reste « à enrichir », l\'envoi partira au retour du réseau.';

  @override
  String get enrichReady => 'Propositions prêtes';

  @override
  String get labelPreviewTitle => 'Lu sur l\'étiquette, en attendant';

  @override
  String labelPreviewLine(String field, String value) {
    return '$field : $value';
  }

  @override
  String get reviewProposals => 'Vérifier les propositions';

  @override
  String enrichFailed(String reason) {
    return 'L\'identification a échoué : $reason';
  }

  @override
  String get enrichRetry => 'Relancer';

  @override
  String enrichFinishedSnack(String name) {
    return 'Identification terminée : $name';
  }

  @override
  String quotaLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus que $count identifications ce mois-ci',
      one: 'Plus qu\'1 identification ce mois-ci',
      zero: 'Quota du mois épuisé',
    );
    return '$_temp0';
  }

  @override
  String pendingJobs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count identifications en attente',
      one: '1 identification en attente',
    );
    return '$_temp0';
  }

  @override
  String get errorTimeout => 'pas de réponse en 3 minutes';

  @override
  String get errorInvalid => 'réponse non conforme du flux';

  @override
  String get validationTitle => 'Propositions';

  @override
  String get acceptAll => 'Tout accepter et enregistrer';

  @override
  String get saveValidation => 'Enregistrer';

  @override
  String get accept => 'Accepter';

  @override
  String get modify => 'Corriger';

  @override
  String get reject => 'Rejeter';

  @override
  String get accepted => 'Accepté';

  @override
  String get rejected => 'Rejeté';

  @override
  String modified(String value) {
    return 'Corrigé : $value';
  }

  @override
  String currentValue(String value) {
    return 'Actuel : $value';
  }

  @override
  String proposedValue(String value) {
    return 'Proposé : $value';
  }

  @override
  String confidence(int percent) {
    return 'confiance $percent %';
  }

  @override
  String get lowConfidence => 'Confiance faible : vérifiez';

  @override
  String notFound(String reason) {
    return 'Non trouvé : $reason';
  }

  @override
  String get lockedField => 'Saisi à la main : conservé';

  @override
  String get disagreement => 'Désaccord entre l\'étiquette et une source';

  @override
  String get duplicateFound => 'Ce vin est déjà dans la cave.';

  @override
  String get duplicateMerge => 'Ajouter ces bouteilles à la fiche existante';

  @override
  String get scoresSection => 'Notes critiques';

  @override
  String get pricesSection => 'Prix marché';

  @override
  String get alertsSection => 'À savoir';

  @override
  String get includePrices => 'Enregistrer les prix relevés';

  @override
  String get keepScore => 'Garder cette note';

  @override
  String priceFound(String price, int offers, String date) {
    return '$price · $offers offres · $date';
  }

  @override
  String get validationSaved => 'Fiche validée.';

  @override
  String get srcEtiquette => 'Étiquette';

  @override
  String get srcSiteOfficiel => 'Site officiel';

  @override
  String get srcOrganismeOfficiel => 'Organisme officiel';

  @override
  String get srcInterprofession => 'Interprofession';

  @override
  String get srcCritique => 'Critique';

  @override
  String get srcMarchand => 'Marchand';

  @override
  String get srcTiers => 'Autre site';

  @override
  String get srcEstimation => 'Estimation';

  @override
  String get srcManuel => 'Saisie manuelle';

  @override
  String get srcImport => 'Import';

  @override
  String get provenanceTitle => 'Provenance';

  @override
  String provenanceSource(String source) {
    return 'Source : $source';
  }

  @override
  String provenanceDate(String date) {
    return 'Collecté le $date';
  }

  @override
  String provenanceUrl(String url) {
    return 'Lien : $url';
  }

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Lien copié.';

  @override
  String get reportError => 'Signaler une erreur';

  @override
  String get reported => 'Signalé comme faux, à corriger';

  @override
  String get reportedSnack =>
      'Erreur signalée : la valeur reste barrée jusqu\'à correction, et le signalement part avec le prochain enrichissement de la fiche.';

  @override
  String get provenanceBadge => 'Voir la provenance';

  @override
  String aiWritten(String site) {
    return 'Rédigé par IA à partir de $site';
  }

  @override
  String get toValidateBanner => 'Propositions à valider';

  @override
  String get enrichingBanner => 'Identification en cours';

  @override
  String get toEnrichBanner => 'En attente d\'identification';

  @override
  String get errorBanner => 'Identification en échec';

  @override
  String get duplicateVintage => 'Dupliquer pour un autre millésime';

  @override
  String get duplicateVintageTitle => 'Nouveau millésime';

  @override
  String get duplicateVintageDone =>
      'Fiche créée : seuls les champs du millésime sont à enrichir.';

  @override
  String get reEnrich => 'Ré-enrichir';

  @override
  String get reEnrichStarted =>
      'Ré-enrichissement lancé sur les champs non verrouillés.';

  @override
  String get reEnrichNoPhoto =>
      'Aucune photo sur cette fiche : ré-enrichissement impossible.';

  @override
  String get unlockField => 'Déverrouiller';

  @override
  String get unlocked =>
      'Champ déverrouillé : il pourra être proposé à nouveau.';

  @override
  String get settingsFakeFlux => 'Flux de démonstration';

  @override
  String get settingsFakeFluxHint =>
      'Utilisé tant qu\'aucune adresse de flux n\'est enregistrée : l\'app rejoue les exemples du contrat.';

  @override
  String get fakeScenario => 'Scénario rejoué';

  @override
  String get scenarioDone => 'Identification complète';

  @override
  String get scenarioPartial => 'Résultat partiel avec désaccord';

  @override
  String get scenarioCacheHit => 'Vin déjà connu (cache)';

  @override
  String get scenarioQuota => 'Quota épuisé';

  @override
  String get scenarioInvalid => 'Réponse non conforme';

  @override
  String get scenarioNever => 'Pas de réponse (délai)';

  @override
  String get simulateOffline => 'Simuler le mode avion';

  @override
  String get fluxUrl => 'Adresse du flux';

  @override
  String get fluxUrlHint => 'https://votre-instance.app.n8n.cloud';

  @override
  String get fluxKey => 'Clé secrète';

  @override
  String get fluxKeyStored =>
      'Clé enregistrée dans le stockage sécurisé du téléphone';

  @override
  String get fluxKeyMissing => 'Aucune clé enregistrée';

  @override
  String get fluxKeyReplace => 'Nouvelle clé (remplace l\'ancienne)';

  @override
  String get fluxSave => 'Enregistrer';

  @override
  String get fluxForget => 'Oublier la connexion';

  @override
  String get fluxTest => 'Tester la connexion';

  @override
  String get fluxTesting => 'Test en cours…';

  @override
  String get fluxUsingReal =>
      'Vrai flux utilisé pour les enrichissements et les prix.';

  @override
  String get fluxUsingFake =>
      'Pas de connexion enregistrée : le flux de démonstration est utilisé.';

  @override
  String fluxTestOk(String version) {
    return 'Connexion réussie : flux joignable, clé acceptée (contrat $version).';
  }

  @override
  String get fluxTestNotReady =>
      'Flux joignable, mais sa clé n\'est pas encore configurée côté n8n.';

  @override
  String fluxTestBadKey(String message) {
    return 'Flux joignable, mais la clé est refusée : $message';
  }

  @override
  String get fluxTestOffline =>
      'Flux injoignable : vérifiez l\'adresse et le réseau.';

  @override
  String get fluxTestInvalid =>
      'Réponse inattendue du flux : vérifiez l\'adresse.';

  @override
  String get fluxUrlInvalid =>
      'Adresse invalide : elle doit commencer par https://';

  @override
  String get fluxSaved => 'Connexion enregistrée.';

  @override
  String get fluxForgotten =>
      'Connexion oubliée : retour au flux de démonstration.';

  @override
  String get pricesAllTitle => 'Relever les prix de toute la cave';

  @override
  String get pricesAllHint => 'Fiches sans relevé depuis 24 heures.';

  @override
  String pricesAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relevés seront envoyés au flux.',
      one: '1 relevé sera envoyé au flux.',
      zero: 'Aucune fiche à relever : toutes ont un relevé de moins de 24 heures.',
    );
    return '$_temp0';
  }

  @override
  String pricesQuotaLeft(int left) {
    return 'Quota restant ce mois : $left relevés.';
  }

  @override
  String get pricesQuotaUnknown =>
      'Quota restant inconnu : il s\'affichera après le premier relevé.';

  @override
  String pricesQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relevés mis en file.',
      one: '1 relevé mis en file.',
      zero: 'Aucun relevé ajouté.',
    );
    return '$_temp0';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get priceQueuedOne => 'Relevé du prix mis en file.';

  @override
  String get priceAlreadyQueued =>
      'Un relevé est déjà en cours pour cette fiche.';

  @override
  String get priceTooRecentTitle => 'Relevé récent';

  @override
  String get priceTooRecent =>
      'Le dernier relevé a moins de 24 heures. Forcer un nouveau relevé ?';

  @override
  String get priceForce => 'Forcer';

  @override
  String priceOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offres',
      one: '1 offre',
      zero: 'aucune offre',
    );
    return '$_temp0';
  }

  @override
  String get priceNatureMedian => 'médiane';

  @override
  String get priceNatureOffer => 'offre unique';

  @override
  String priceTrendUp(String percent) {
    return 'En hausse de $percent depuis le relevé précédent';
  }

  @override
  String priceTrendDown(String percent) {
    return 'En baisse de $percent depuis le relevé précédent';
  }

  @override
  String get priceTrendFlat => 'Stable depuis le relevé précédent';

  @override
  String priceOpenOffer(String site) {
    return 'Voir l\'offre sur $site';
  }

  @override
  String get priceChartLabel => 'Courbe des prix relevés';

  @override
  String get priceHistory => 'Historique des relevés';

  @override
  String get photoTypeDegustation => 'Dégustation';

  @override
  String get photoTypeRepas => 'Repas';

  @override
  String get photoTypeEvenement => 'Événement';

  @override
  String get tabPhotos => 'Photos';

  @override
  String get libraryEmpty =>
      'Aucune photo de dégustation ou de repas pour cette bouteille.';

  @override
  String get libraryAdd => 'Ajouter une photo';

  @override
  String get libraryTypeTitle => 'Type de photo';

  @override
  String get libraryAdded => 'Photo ajoutée';

  @override
  String get photoDelete => 'Supprimer la photo';

  @override
  String get photoDeleteBody => 'La photo est effacée de l\'appareil.';

  @override
  String get photoDeleted => 'Photo supprimée';

  @override
  String photoCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String photoOpen(int index) {
    return 'Voir la photo $index';
  }

  @override
  String get validationPhotos => 'Photos';

  @override
  String get photoCroppedLabel => 'Recadrée sur l\'étiquette';

  @override
  String get photoWholeLabel => 'Photo entière';

  @override
  String get cropAction => 'Recadrer';

  @override
  String get cropTitle => 'Recadrer l\'étiquette';

  @override
  String get cropHint =>
      'Faites glisser le cadre ou ses coins sur l\'étiquette.';

  @override
  String get cropWhole => 'Photo entière';

  @override
  String get cropSaved => 'Cadre enregistré';

  @override
  String get cropOriginalNote =>
      'La photo d\'origine est gardée jusqu\'à la validation de la fiche.';

  @override
  String get excelListName => 'Liste';

  @override
  String get excelListValue => 'Valeur autorisée';

  @override
  String get excelListParent => 'Rattachée à';

  @override
  String get excelNotice =>
      'Règles d\'import du classeur IA cave à vin\n\nOnglet Vins : une ligne par fiche (domaine, cuvée, millésime).\n- Colonne id remplie : la fiche existante est mise à jour. id vide : une fiche est créée.\n- Action = SUPPRIMER (avec l\'id) : la fiche est supprimée de la cave, ses mouvements restent dans l\'historique.\n- Domaine, Pays, Couleur et Millésime sont obligatoires. Millésime : une année ou NM pour un non millésimé.\n- Les listes (pays, région, appellation, cépages, accords…) prennent les valeurs de l\'onglet Listes. Plusieurs valeurs dans une cellule : séparées par un point-virgule.\n- Cépages : « Merlot 80 %; Cabernet Franc 20 % », total de 100 % au plus.\n- Les colonnes Origine garde, Statut garde, Statut enrichissement, Note Parker, Meilleure note, Stock total et Photo principale sont calculées : elles sont ignorées à l\'import.\n\nOnglet Lots : une ligne par lot (même fiche, format, propriétaire, emplacement, prix).\n- id lot rempli : mise à jour ; vide : création. Action = SUPPRIMER : suppression du lot.\n- id fiche : l\'id d\'une fiche de l\'onglet Vins, ou #numéro de ligne pour une fiche créée par le même import (exemple : #12).\n- Quantité : quantité cible. L\'app crée un mouvement d\'ajustement de l\'écart, motif « import Excel ». Cellule vide : stock inchangé.\n- Emplacement : chemin complet, par exemple « Cave > Armoire 1 > Casier A ».\n\nOnglet Mouvements : lecture seule, ignoré à l\'import.\n\nPhotos : joignez un zip de photos ; une photo dont le nom figure dans la colonne Photo principale est rattachée à la fiche.\n\nAvant tout import, l\'app simule et affiche un rapport. Une sauvegarde automatique est faite juste avant, et l\'import se fait en entier ou pas du tout.';

  @override
  String get ieExcelSection => 'Excel';

  @override
  String get ieExport => 'Exporter la cave';

  @override
  String get ieExportHint =>
      'Classeur xlsx : vins, lots, mouvements, listes autorisées et notice.';

  @override
  String get ieTemplate => 'Modèle vierge';

  @override
  String get ieTemplateHint =>
      'Même classeur sans données, pour saisir une cave sur ordinateur.';

  @override
  String get ieImport => 'Importer un classeur';

  @override
  String get ieImportHint => 'Simulation et rapport avant toute modification.';

  @override
  String get iePhotosTitle => 'Joindre des photos ?';

  @override
  String get iePhotosBody =>
      'Un zip de photos peut accompagner le classeur : chaque photo citée dans la colonne Photo principale est rattachée à sa fiche.';

  @override
  String get iePhotosPick => 'Choisir un zip';

  @override
  String get iePhotosSkip => 'Sans photos';

  @override
  String get ieReady => 'Fichier prêt';

  @override
  String get importReportTitle => 'Simulation de l\'import';

  @override
  String importWinesCreated(int n) {
    return 'Fiches créées : $n';
  }

  @override
  String importWinesUpdated(int n) {
    return 'Fiches mises à jour : $n';
  }

  @override
  String importWinesDeleted(int n) {
    return 'Fiches supprimées : $n';
  }

  @override
  String importLotsCreated(int n) {
    return 'Lots créés : $n';
  }

  @override
  String importLotsUpdated(int n) {
    return 'Lots mis à jour : $n';
  }

  @override
  String importLotsDeleted(int n) {
    return 'Lots supprimés : $n';
  }

  @override
  String importStockChanges(int n) {
    return 'Stocks ajustés : $n';
  }

  @override
  String importPhotos(int n) {
    return 'Photos rattachées : $n';
  }

  @override
  String get importNoChange => 'Aucune différence avec la cave.';

  @override
  String get importUnknownTitle => 'Valeurs absentes de l\'app';

  @override
  String get importCreateUnknown => 'Les créer pendant l\'import';

  @override
  String importIssuesTitle(int n) {
    return 'Erreurs à corriger ($n)';
  }

  @override
  String importIssueWhere(String sheet, int row, String column) {
    return '$sheet, ligne $row, colonne $column';
  }

  @override
  String get importApply => 'Importer';

  @override
  String get importBlocked =>
      'Corrigez le classeur puis relancez l\'import : rien n\'est modifié tant qu\'il reste une erreur.';

  @override
  String get importBackupNote =>
      'Une sauvegarde automatique est faite juste avant l\'import, qui se fait en entier ou pas du tout.';

  @override
  String get importEnrich => 'Enrichir les fiches créées';

  @override
  String importEnrichHint(int n, String left) {
    return '$n fiches créées avec une photo, soit $n appels au flux. Quota restant ce mois : $left.';
  }

  @override
  String get importEnrichUnknownQuota => 'inconnu';

  @override
  String importEnrichStarted(int n) {
    return '$n enrichissements en file d\'attente';
  }

  @override
  String get importOwnerList => 'Propriétaire';

  @override
  String get issueMissingSheet => 'onglet absent';

  @override
  String get issueMissingColumn => 'colonne absente';

  @override
  String get issueRequired => 'valeur obligatoire';

  @override
  String get issueUnknownId => 'identifiant inconnu';

  @override
  String get issueDuplicateId => 'identifiant présent deux fois';

  @override
  String get issueInvalidNumber => 'nombre attendu';

  @override
  String get issueInvalidVintage =>
      'millésime attendu : une année jusqu\'à l\'année en cours, ou NM';

  @override
  String get issueOutOfRange => 'valeur hors des bornes';

  @override
  String get issueGardeOrder =>
      'garde incohérente : début après le millésime, début avant l\'apogée, apogée avant la fin';

  @override
  String get issueInvalidEan =>
      'code-barres invalide : 13 chiffres et clé de contrôle';

  @override
  String get issueInvalidBoolean => 'oui ou non attendu';

  @override
  String get issueInvalidDate => 'date attendue';

  @override
  String get issueInvalidGrapes =>
      'cépages illisibles : « Merlot 80 %; Cabernet Franc 20 % »';

  @override
  String get issueInvalidAction =>
      'action inconnue : vide ou SUPPRIMER, avec l\'identifiant';

  @override
  String get issueUnknownValue => 'valeur absente de la liste';

  @override
  String get issueUnknownLocation => 'emplacement inconnu';

  @override
  String get issueUnknownWine => 'fiche inconnue';

  @override
  String get issueDeletedWine => 'fiche supprimée par ce même import';

  @override
  String get issueLotWineChange =>
      'un lot ne change pas de fiche : créez un nouveau lot';

  @override
  String get importFinished => 'Import terminé';

  @override
  String pdfGardeRange(String start, String end) {
    return 'de $start à $end';
  }

  @override
  String pdfGardePeak(String year) {
    return 'apogée $year';
  }

  @override
  String pdfAlcohol(String value) {
    return '$value %';
  }

  @override
  String get pdfGardeSource => 'Origine de la garde';

  @override
  String get pdfGardeStatus => 'Statut de garde';

  @override
  String get pdfParker => 'Note Parker';

  @override
  String get pdfStock => 'En stock';

  @override
  String pdfBottles(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bouteilles',
      one: '1 bouteille',
      zero: 'aucune bouteille',
    );
    return '$_temp0';
  }

  @override
  String pdfCitedBy(String site) {
    return 'citée par $site';
  }

  @override
  String pdfPrice(String price) {
    return '$price l\'unité';
  }

  @override
  String pdfEditedOn(String date) {
    return 'Édité le $date';
  }

  @override
  String get pdfCatalogueTitle => 'Catalogue de la cave';

  @override
  String pdfCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n fiches',
      one: '1 fiche',
    );
    return '$_temp0';
  }

  @override
  String get pdfFilters => 'Filtres appliqués';

  @override
  String get pdfNoFilter => 'Aucun filtre : toutes les fiches.';

  @override
  String pdfPage(String n, String total) {
    return 'Page $n / $total';
  }

  @override
  String issueWithValue(String reason, String value) {
    return '$reason : « $value »';
  }

  @override
  String filterLine(String label, String value) {
    return '$label : $value';
  }

  @override
  String get catalogueSection => 'Catalogue PDF';

  @override
  String get catalogueHint =>
      'Deux fiches par page A4. Les filtres et le tri de la liste sont repris ; vous pouvez les changer ici sans toucher à la liste.';

  @override
  String catalogueFilters(int n) {
    return 'Filtres ($n)';
  }

  @override
  String get catalogueCover =>
      'Page de garde (date, filtres, nombre de fiches)';

  @override
  String catalogueGenerate(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Générer le catalogue ($n fiches)',
      one: 'Générer le catalogue (1 fiche)',
      zero: 'Aucune fiche à imprimer',
    );
    return '$_temp0';
  }

  @override
  String get winePdf => 'Fiche PDF';

  @override
  String get pdfPreparing => 'Préparation du PDF…';

  @override
  String get statsTabGeneral => 'Général';

  @override
  String get statsTabRegions => 'Régions';

  @override
  String get statsTabGarde => 'Garde';

  @override
  String get statsTabValue => 'Valeur';

  @override
  String get statsTabBuying => 'Aide à l\'achat';

  @override
  String get statsTabExplorer => 'Explorateur';

  @override
  String get statsEmpty =>
      'Aucune bouteille en cave : ajoutez des vins pour voir les statistiques.';

  @override
  String get statNoData => 'Aucune donnée pour cette vue.';

  @override
  String get statMeasureBottles => 'Nombre de bouteilles';

  @override
  String get statMeasureReferences => 'Nombre de références';

  @override
  String get statMeasurePurchase => 'Valeur d\'achat';

  @override
  String get statMeasureMarket => 'Valeur marché';

  @override
  String get statMeasureGain => 'Plus-value latente';

  @override
  String get statMeasureAvgPrice => 'Prix moyen';

  @override
  String get statMeasureAvgScore => 'Note moyenne (/100)';

  @override
  String get statMeasureOpened => 'Bouteilles ouvertes (12 mois)';

  @override
  String get statMeasureYears => 'Années moyennes avant de boire';

  @override
  String get statDimColor => 'Couleur';

  @override
  String get statDimType => 'Type';

  @override
  String get statDimCountry => 'Pays';

  @override
  String get statDimRegion => 'Région';

  @override
  String get statDimSubRegion => 'Sous-région';

  @override
  String get statDimAppellation => 'Appellation';

  @override
  String get statDimProducer => 'Domaine';

  @override
  String get statDimVintage => 'Millésime';

  @override
  String get statDimVintageBand => 'Tranche de 5 millésimes';

  @override
  String get statDimGrape => 'Cépage principal';

  @override
  String get statDimOwner => 'Propriétaire';

  @override
  String get statDimLocation => 'Emplacement';

  @override
  String get statDimGardeStatus => 'Statut de garde';

  @override
  String get statDimGardeStart => 'Année de début de garde';

  @override
  String get statDimPeak => 'Année d\'apogée';

  @override
  String get statDimScoreBand => 'Tranche de note';

  @override
  String get statDimPriceBand => 'Tranche de prix';

  @override
  String get statDimSupplier => 'Fournisseur';

  @override
  String get statDimPurchaseMonth => 'Mois d\'achat';

  @override
  String get statDimOpeningMonth => 'Mois d\'ouverture';

  @override
  String get statChartDonut => 'Donut';

  @override
  String get statChartBarsV => 'Barres verticales';

  @override
  String get statChartBarsH => 'Barres horizontales';

  @override
  String get statChartStacked => 'Barres empilées';

  @override
  String get statChartLine => 'Courbe';

  @override
  String get statChartCross => 'Tableau croisé';

  @override
  String get statChartKpi => 'Indicateur seul';

  @override
  String get statNone => 'Non renseigné';

  @override
  String get statOther => 'Autres';

  @override
  String statBand(String from, String to) {
    return '$from à $to';
  }

  @override
  String statFrom(String from) {
    return '$from et plus';
  }

  @override
  String get statToDrinkThisYear => 'À boire cette année';

  @override
  String get statDrinkSoon => 'À boire vite';

  @override
  String get statPast => 'Passées';

  @override
  String get statGardeByYear =>
      'Bouteilles par année d\'entrée dans la fenêtre de garde';

  @override
  String get statByColor => 'Bouteilles par couleur';

  @override
  String get statVintageColor => 'Millésime et couleur';

  @override
  String get statByOrigin => 'Bouteilles par origine';

  @override
  String get statDrillHint =>
      'Touchez une barre pour descendre du pays à la région, puis à l\'appellation.';

  @override
  String get statDrillUp => 'Remonter';

  @override
  String get statPurchaseVsMarket => 'Achat et marché par couleur';

  @override
  String get statPurchaseVsMarketRegion => 'Achat et marché par région';

  @override
  String get statMarketHistory => 'Valeur marché du stock actuel, sur 24 mois';

  @override
  String get statOpenedVsStock =>
      'Ouvertures des 12 derniers mois et stock, par couleur';

  @override
  String get statMonthsLeft => 'Mois de stock restant au rythme des ouvertures';

  @override
  String statMonthsValue(String n) {
    return '$n mois';
  }

  @override
  String get statNoOpening => 'aucune ouverture en 12 mois';

  @override
  String get statSeriesPurchase => 'Achat';

  @override
  String get statSeriesMarket => 'Marché';

  @override
  String get statSeriesOpened => 'Ouvertes';

  @override
  String get statSeriesStock => 'En stock';

  @override
  String statSeeWines(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Voir les $n vins',
      one: 'Voir le vin',
    );
    return '$_temp0';
  }

  @override
  String get statWinesTitle => 'Vins de la sélection';

  @override
  String get statMeasure => 'Mesure';

  @override
  String get statDimension => 'Dimension';

  @override
  String get statDimension2 => 'Seconde dimension';

  @override
  String get statNoDimension2 => 'Aucune';

  @override
  String get statChartType => 'Graphique';

  @override
  String get statFilters => 'Filtres';

  @override
  String get statFilterAdd => 'Ajouter un filtre';

  @override
  String statFilterLine(String dimension, String values) {
    return '$dimension : $values';
  }

  @override
  String get statFavorites => 'Favoris';

  @override
  String get statNoFavorites => 'Aucune vue enregistrée.';

  @override
  String get statSave => 'Enregistrer en favori';

  @override
  String get statViewName => 'Nom de la vue';

  @override
  String get statSaved => 'Vue enregistrée';

  @override
  String get statDeleteView => 'Supprimer la vue';

  @override
  String get statExport => 'Exporter';

  @override
  String get statExportPng => 'Image PNG';

  @override
  String get statExportPdf => 'PDF';

  @override
  String get statExportCsv => 'Tableau CSV';

  @override
  String get statTotal => 'Total';

  @override
  String get statAverage => 'Moyenne';

  @override
  String get toDrinkTab => 'À boire';

  @override
  String get tastingsTab => 'Dégustations';

  @override
  String get toDrinkEmpty => 'Aucun vin dans sa fenêtre de garde en ce moment.';

  @override
  String get toDrinkHint =>
      'Vins dans leur fenêtre de garde, à boire vite en tête, puis par fin de fenêtre.';

  @override
  String get dishPick => 'Pour quel plat ?';

  @override
  String get dishAny => 'Tous les plats';

  @override
  String get dishNoWine => 'Aucun vin à boire ne s\'accorde avec ce plat.';

  @override
  String dishCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vins pour ce plat',
      one: '1 vin pour ce plat',
    );
    return '$_temp0';
  }

  @override
  String get tastingsEmpty =>
      'Aucune dégustation notée. Elles sont proposées à chaque ouverture de bouteille.';

  @override
  String get alertTitle => 'Ce mois-ci dans la cave';

  @override
  String alertBody(int peak, int ending) {
    String _temp0 = intl.Intl.pluralLogic(
      peak,
      locale: localeName,
      other: '$peak vins entrent en apogée. ',
      one: '1 vin entre en apogée. ',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ending,
      locale: localeName,
      other: '$ending vins arrivent en fin de fenêtre.',
      one: '1 vin arrive en fin de fenêtre.',
      zero: '',
    );
    return '$_temp0$_temp1';
  }

  @override
  String get alertSee => 'Voir les vins';

  @override
  String get alertDismiss => 'Fermer';

  @override
  String get alertWinesTitle => 'Apogée et fin de fenêtre';

  @override
  String get shoppingEmpty =>
      'Rien à acheter. Un vin qui n\'a plus de bouteille vous est proposé ici, et vous pouvez noter un vin repéré ailleurs.';

  @override
  String get shoppingAdd => 'Ajouter un vin repéré';

  @override
  String get shoppingLabel => 'Vin';

  @override
  String get shoppingQuantity => 'Quantité souhaitée';

  @override
  String get shoppingNote => 'Note (où l\'acheter, prix vu)';

  @override
  String get shoppingBought => 'Acheté';

  @override
  String get shoppingDelete => 'Retirer de la liste';

  @override
  String get shoppingAdded => 'Ajouté à la liste d\'achats';

  @override
  String get shoppingProposeTitle => 'Plus aucune bouteille';

  @override
  String shoppingProposeBody(String wine) {
    return '$wine : l\'ajouter à la liste d\'achats ?';
  }

  @override
  String get shoppingProposeAction => 'Ajouter à la liste';

  @override
  String shoppingQuantityValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bouteilles',
      one: '1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String get shareImage => 'Partager en image';

  @override
  String get sharePreviewTitle => 'Partager la fiche';

  @override
  String get shareAsImage => 'Image';

  @override
  String get shareAsPdf => 'PDF';

  @override
  String get favoriteOn => 'Ajouter aux favoris';

  @override
  String get favoriteOff => 'Retirer des favoris';

  @override
  String get gridTitle => 'Vue casier';

  @override
  String get gridHint =>
      'Un tap sur une case occupée ouvre la fiche. Un appui long sur une case vide y range une bouteille.';

  @override
  String gridCell(String cell) {
    return 'Case $cell';
  }

  @override
  String gridCellWine(String cell, String wine) {
    return 'Case $cell : $wine';
  }

  @override
  String gridPlaceTitle(String cell) {
    return 'Ranger en $cell';
  }

  @override
  String get gridHere => 'Déjà dans ce casier, sans case';

  @override
  String get gridElsewhere => 'Venant d\'un autre emplacement';

  @override
  String get gridNoCandidate => 'Aucune bouteille à ranger.';

  @override
  String gridPlaced(String cell) {
    return 'Bouteille rangée en $cell';
  }

  @override
  String gridUnplaced(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bouteilles sans case',
      one: '1 bouteille sans case',
    );
    return '$_temp0';
  }

  @override
  String tastingScoreValue(String score, int scale) {
    return '$score / $scale';
  }
}
