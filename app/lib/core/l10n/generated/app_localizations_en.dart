// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IA cave à vin';

  @override
  String get navMyWines => 'My wines';

  @override
  String get navToDrink => 'To drink';

  @override
  String get navLocations => 'Locations';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navGardeRules => 'Ageing rules';

  @override
  String get navShoppingList => 'Shopping list';

  @override
  String get navImportExport => 'Import and export';

  @override
  String get navBackup => 'Backup';

  @override
  String get navSettings => 'Settings';

  @override
  String get navFeedback => 'Send feedback';

  @override
  String get navAbout => 'About';

  @override
  String get wineListTitle => 'My wines';

  @override
  String wineListSummary(int wines, int bottles) {
    String _temp0 = intl.Intl.pluralLogic(
      wines,
      locale: localeName,
      other: '$wines wines',
      one: '1 wine',
      zero: 'No wines',
    );
    String _temp1 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bottles',
      one: '1 bottle',
      zero: '0 bottles',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get wineListEmptyTitle => 'No wines yet.';

  @override
  String get wineListEmptyBody =>
      'Photograph your first label with the + button, or enter a bottle by hand.';

  @override
  String get wineListLoading => 'Loading the cellar';

  @override
  String get wineListErrorTitle => 'The cellar could not be read.';

  @override
  String wineListErrorDetail(String detail) {
    return 'Details: $detail';
  }

  @override
  String get retry => 'Try again';

  @override
  String get addBottle => 'Add a bottle';

  @override
  String get nonVintage => 'NV';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
      zero: 'Out of stock',
    );
    return '$_temp0';
  }

  @override
  String get toValidate => 'To review';

  @override
  String wineCardSemantics(String name, String vintage, String bottles) {
    return '$name, vintage $vintage, $bottles';
  }

  @override
  String get backToTop => 'Back to top';

  @override
  String operationFailed(String detail) {
    return 'The operation failed: $detail';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get erase => 'Clear';

  @override
  String get aboutDescription =>
      'Wine cellar management in Apexus-BMT colours. Your data stays on this phone.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutHealthWarning =>
      'Alcohol abuse is dangerous for your health. Drink responsibly.';

  @override
  String get aboutReferenceData =>
      'Reference data: countries per ISO 3166-1. Appellations, regions and grape varieties: provisional lists, to be replaced by INAO open data.';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Name, producer, appellation, grape…';

  @override
  String get closeSearch => 'Close search';

  @override
  String get sort => 'Sort';

  @override
  String get filters => 'Filter';

  @override
  String get cardView => 'Card view';

  @override
  String get compactView => 'Compact view';

  @override
  String activeFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active filters',
      one: '1 active filter',
    );
    return '$_temp0';
  }

  @override
  String get resetFilters => 'Reset';

  @override
  String sortChip(int rank, String criterion, String direction) {
    return 'Sort $rank: $criterion ($direction)';
  }

  @override
  String get sortAscending => 'A-Z';

  @override
  String get sortDescending => 'Z-A';

  @override
  String get sortFirst => 'Sort 1';

  @override
  String get sortSecond => 'Sort 2';

  @override
  String get sortNone => 'None';

  @override
  String get sortDirection => 'Descending order';

  @override
  String get apply => 'Apply';

  @override
  String get sortVintage => 'Vintage';

  @override
  String get sortColor => 'Colour';

  @override
  String get sortParkerScore => 'Parker score';

  @override
  String get sortBestScore => 'Best score';

  @override
  String get sortName => 'Name';

  @override
  String get sortProducer => 'Producer';

  @override
  String get sortCountry => 'Country';

  @override
  String get sortRegion => 'Region';

  @override
  String get sortAppellation => 'Appellation';

  @override
  String get sortOwner => 'Owner';

  @override
  String get sortLocation => 'Location';

  @override
  String get sortPurchasePrice => 'Purchase price';

  @override
  String get sortMarketValue => 'Market value';

  @override
  String get sortQuantity => 'Quantity';

  @override
  String get sortAddedAt => 'Date added';

  @override
  String get sortGardeStart => 'Drinking window start';

  @override
  String get sortGardeEnd => 'Drinking window end';

  @override
  String get sortGardePeak => 'Peak year';

  @override
  String get sortCellarStatus => 'Ageing status';

  @override
  String get groupUnknown => 'Not set';

  @override
  String groupSummary(int wines, int bottles) {
    String _temp0 = intl.Intl.pluralLogic(
      wines,
      locale: localeName,
      other: '$wines wines',
      one: '1 wine',
    );
    String _temp1 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bottles',
      one: '1 bottle',
      zero: '0 bottles',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get stockInStock => 'In stock';

  @override
  String get stockEmpty => 'Out of stock';

  @override
  String get stockAll => 'All';

  @override
  String get filterStock => 'Stock';

  @override
  String get filterColors => 'Colour';

  @override
  String get filterTypes => 'Type';

  @override
  String get filterCountries => 'Country';

  @override
  String get filterRegions => 'Region';

  @override
  String get filterAppellations => 'Appellation';

  @override
  String get filterVintages => 'Vintages';

  @override
  String get filterOwners => 'Owner';

  @override
  String get filterLocation => 'Location (with its sub-locations)';

  @override
  String get filterStatuses => 'Ageing status';

  @override
  String get filterIdealYear => 'Ideal drinking year';

  @override
  String get filterMinScore => 'Minimum score (out of 100)';

  @override
  String get filterPrice => 'Purchase price';

  @override
  String get filterGrapes => 'Grape variety';

  @override
  String get filterEnrichment => 'Enrichment status';

  @override
  String get filterFavorites => 'Favourites only';

  @override
  String get rangeFrom => 'From';

  @override
  String get rangeTo => 'To';

  @override
  String get anyLocation => 'All locations';

  @override
  String get statusTooYoung => 'Too young';

  @override
  String get statusToDrink => 'Ready to drink';

  @override
  String get statusPeak => 'At peak';

  @override
  String get statusDrinkSoon => 'Drink soon';

  @override
  String get statusPast => 'Past its best';

  @override
  String get statusUnknown => 'Ageing unknown';

  @override
  String get enrichBrouillon => 'Draft';

  @override
  String get enrichAEnrichir => 'To enrich';

  @override
  String get enrichEnCours => 'Enrichment in progress';

  @override
  String get enrichAValider => 'To review';

  @override
  String get enrichValide => 'Validated';

  @override
  String get enrichErreur => 'Enrichment error';

  @override
  String get noResults => 'No wine matches.';

  @override
  String get noResultsBody => 'Change the search or the filters.';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String get moveSelection => 'Move';

  @override
  String get changeOwnerSelection => 'Change owner';

  @override
  String selectionDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wines updated',
      one: '1 wine updated',
    );
    return '$_temp0';
  }

  @override
  String get openOneBottle => 'Open 1 bottle';

  @override
  String bottleOpened(String name) {
    return '1 bottle opened: $name';
  }

  @override
  String get undo => 'Undo';

  @override
  String get noStockToOpen => 'No bottles left to open.';

  @override
  String get favorite => 'Favourite';

  @override
  String get externalBackupReminder =>
      'No backup exported in the last 30 days.';

  @override
  String get exportNow => 'Export';

  @override
  String get mvtEntry => 'In';

  @override
  String get mvtOpening => 'Opened';

  @override
  String get mvtOtherExit => 'Out';

  @override
  String get mvtAdjustment => 'Adjustment';

  @override
  String get mvtTransferOut => 'Transfer out';

  @override
  String get mvtTransferIn => 'Transfer in';

  @override
  String get parkerInitial => 'P';

  @override
  String scoreSemantics(String score) {
    return 'score $score';
  }

  @override
  String get selected => 'selected';

  @override
  String get wineNotFound => 'This wine no longer exists.';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteWineTitle => 'Delete this wine?';

  @override
  String get deleteWineBody =>
      'The wine and its lots leave the list. The movement history is kept.';

  @override
  String get wineDeleted => 'Wine deleted.';

  @override
  String remaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
      zero: '0 left',
    );
    return '$_temp0';
  }

  @override
  String consumed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drunk',
      one: '1 drunk',
      zero: '0 drunk',
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
      other: 'Add $count bottles',
      one: 'Add 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String openBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Open $count bottles',
      one: 'Open 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get decrease => 'Less';

  @override
  String get increase => 'More';

  @override
  String get tabInfo => 'Details';

  @override
  String get tabOperations => 'Operations';

  @override
  String get tabTastings => 'Tastings';

  @override
  String get tabPrices => 'Prices';

  @override
  String get sectionOrigin => 'Origin';

  @override
  String get sectionCellar => 'Cellar';

  @override
  String get sectionWine => 'Wine';

  @override
  String get sectionComments => 'Comments';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldRegion => 'Region';

  @override
  String get fieldSubRegion => 'Sub-region';

  @override
  String get fieldAppellation => 'Appellation';

  @override
  String get fieldQualitySign => 'Quality label';

  @override
  String get fieldClassification => 'Classification';

  @override
  String get fieldLieuDit => 'Lieu-dit';

  @override
  String get fieldProducer => 'Producer';

  @override
  String get fieldCuvee => 'Cuvée';

  @override
  String get fieldColor => 'Colour';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldCertification => 'Certification';

  @override
  String get fieldVintage => 'Vintage';

  @override
  String get fieldVintageHint => '4-digit year, or NV';

  @override
  String get fieldGrapes => 'Grape varieties';

  @override
  String get fieldAlcohol => 'Alcohol (%)';

  @override
  String get fieldGarde => 'Drinking window';

  @override
  String get fieldGardeStart => 'Drink from';

  @override
  String get fieldGardePeak => 'Peak';

  @override
  String get fieldGardeEnd => 'Drink before';

  @override
  String get fieldPairings => 'Food pairings';

  @override
  String get fieldScores => 'Critic scores';

  @override
  String get fieldEan => 'EAN barcode';

  @override
  String get fieldLwin => 'LWIN';

  @override
  String get fieldProducerSite => 'Official website';

  @override
  String get fieldProducerComment => 'The producer';

  @override
  String get fieldVintageComment => 'The vintage';

  @override
  String get fieldPersonalComment => 'My comment';

  @override
  String get fieldLocation => 'Location';

  @override
  String get fieldPositions => 'Positions';

  @override
  String get fieldPositionsHint => 'Grid cells, e.g. A3, B5';

  @override
  String get fieldOwners => 'Owners';

  @override
  String get fieldOwner => 'Owner';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldFormat => 'Size';

  @override
  String get fieldUnitPrice => 'Unit purchase price incl. tax';

  @override
  String get fieldPurchaseDate => 'Purchase date';

  @override
  String get fieldFavorite => 'Favourite';

  @override
  String gardeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get gardeEstimated => 'estimated';

  @override
  String ownerShare(String name, int count) {
    return '$name $count';
  }

  @override
  String get emptyValue => '-';

  @override
  String citedBy(String site) {
    return 'cited by $site';
  }

  @override
  String get noMovements => 'No movements.';

  @override
  String movementLine(String type, String quantity) {
    return '$type · $quantity';
  }

  @override
  String movementDetail(String date, String lot) {
    return '$date · $lot';
  }

  @override
  String get noTastings => 'No tastings recorded.';

  @override
  String get addTasting => 'Record a tasting';

  @override
  String get tastingTitle => 'Tasting';

  @override
  String tastingScore(int scale) {
    return 'My score (out of $scale)';
  }

  @override
  String get tastingDish => 'Dish served';

  @override
  String get tastingComment => 'Comment';

  @override
  String get tastingPhotos => 'Tasting photos';

  @override
  String get tastingPhotoRemove => 'Remove the photo';

  @override
  String tastingPhotosMax(int count) {
    return '$count photos at most per tasting.';
  }

  @override
  String get tastingPrompt => 'Record this tasting?';

  @override
  String get later => 'Later';

  @override
  String get save => 'Save';

  @override
  String get tastingSaved => 'Tasting saved.';

  @override
  String get purchasePrices => 'Purchase price per lot';

  @override
  String get marketPrices => 'Market price';

  @override
  String get noPurchasePrice => 'Purchase price unknown';

  @override
  String get noMarketPrice => 'No market price found yet.';

  @override
  String lastMarketPrice(String price, String date) {
    return 'Latest price: $price on $date';
  }

  @override
  String priceNotFound(String date) {
    return 'Not found on $date';
  }

  @override
  String get refreshPrice => 'Check the price';

  @override
  String get manualPrice => 'Enter a price';

  @override
  String get manualPriceTitle => 'Dated price';

  @override
  String manualPriceValue(String currency) {
    return 'Unit price incl. tax ($currency)';
  }

  @override
  String get manualPriceDate => 'Price date';

  @override
  String get manualPriceWhere => 'Where (wine shop, website, fair…), optional';

  @override
  String get manualPriceInvalid => 'Enter a price above 0.';

  @override
  String get manualPriceSaved => 'Price saved';

  @override
  String get priceManual => 'Entered by hand';

  @override
  String priceManualRow(String date) {
    return '$date · entered by hand';
  }

  @override
  String get lots => 'Lots';

  @override
  String lotLine(String owner, String format, int count) {
    return '$owner · $format cl · $count';
  }

  @override
  String get noLocation => 'No location';

  @override
  String get chooseLot => 'Choose the lot';

  @override
  String get adjustStock => 'Correct the stock';

  @override
  String get adjustTitle => 'Actual quantity in the lot';

  @override
  String get adjustReason => 'Reason';

  @override
  String adjustDone(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: 'Difference corrected: $delta',
      zero: 'No difference',
    );
    return '$_temp0';
  }

  @override
  String get noDifference => 'No difference, nothing to correct.';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferTitle => 'Transfer bottles';

  @override
  String get transferDone => 'Transfer saved.';

  @override
  String get newLot => 'New lot';

  @override
  String get restock => 'Restock';

  @override
  String stockAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles added',
      one: '1 bottle added',
    );
    return '$_temp0';
  }

  @override
  String stockOpened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles opened',
      one: '1 bottle opened',
    );
    return '$_temp0';
  }

  @override
  String get stockErrorNegative =>
      'Not enough stock: the lot would go negative.';

  @override
  String get stockErrorReason => 'Choose a reason.';

  @override
  String get stockErrorSameLot => 'Choose another location or owner.';

  @override
  String get stockErrorOther => 'Operation refused.';

  @override
  String get whereIsIt => 'Where is it?';

  @override
  String get newWineTitle => 'New wine';

  @override
  String get editWineTitle => 'Edit the wine';

  @override
  String get firstLot => 'First lot';

  @override
  String get errorRequired => 'Required field';

  @override
  String get errorVintage => 'Vintage between 1900 and the current year, or NV';

  @override
  String get errorAlcohol => 'Alcohol between 5 and 23';

  @override
  String get errorGardeOrder => 'Must be vintage ≤ start ≤ peak ≤ end';

  @override
  String get errorEan => '13 digits with a valid check digit';

  @override
  String get errorLwin => '7 or 11 digits';

  @override
  String get errorGrapesTotal => 'Percentages must add up to 100%';

  @override
  String get errorPositions => 'Invalid positions for this grid';

  @override
  String get errorNumber => 'Number expected';

  @override
  String get duplicateTitle => 'This wine already exists';

  @override
  String get duplicateBody =>
      'A wine with this producer, cuvée and vintage already exists. Open it to add bottles?';

  @override
  String get openExisting => 'Open the wine';

  @override
  String get createAnyway => 'Create anyway';

  @override
  String get wineSaved => 'Wine saved.';

  @override
  String get choose => 'Choose';

  @override
  String get none => 'None';

  @override
  String get searchList => 'Search the list';

  @override
  String addToList(String value) {
    return 'Add “$value”';
  }

  @override
  String get addGrape => 'Add a grape variety';

  @override
  String get grapePercent => '%';

  @override
  String get removeGrape => 'Remove';

  @override
  String get addPairing => 'Add a pairing';

  @override
  String selectedCount(int count) {
    return '$count chosen';
  }

  @override
  String get locationsEmpty => 'No locations.';

  @override
  String get locationsEmptyBody =>
      'Create the cellar, then its cabinets, racks and shelves (4 levels).';

  @override
  String get addLocation => 'Add a location';

  @override
  String get addSubLocation => 'Add a sub-location';

  @override
  String get editLocation => 'Edit the location';

  @override
  String get deleteLocation => 'Delete the location';

  @override
  String get locationName => 'Name';

  @override
  String get locationType => 'Type';

  @override
  String get locationRows => 'Rows (1 to 26)';

  @override
  String get locationCols => 'Columns (1 to 50)';

  @override
  String get locationCapacity => 'Capacity (bottles)';

  @override
  String get locTypeCave => 'Cellar';

  @override
  String get locTypeMeuble => 'Cabinet';

  @override
  String get locTypeCasier => 'Rack';

  @override
  String get locTypeClayette => 'Shelf';

  @override
  String get locTypeAutre => 'Other';

  @override
  String locationFill(int bottles, int capacity, int percent) {
    return '$bottles / $capacity · $percent%';
  }

  @override
  String locationBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get overCapacity => 'Over capacity';

  @override
  String locationGrid(int rows, int cols) {
    return '$rows × $cols grid';
  }

  @override
  String get errorDepth => '4 levels at most: cellar, cabinet, rack, shelf.';

  @override
  String get errorGrid => 'Grid of 1 to 26 rows and 1 to 50 columns.';

  @override
  String get errorNotEmpty => 'This location holds bottles or sub-locations.';

  @override
  String get errorInUse => 'Value in use: it cannot be deleted.';

  @override
  String get errorDuplicate => 'This value already exists.';

  @override
  String get errorCsv => 'Invalid CSV file: nothing was imported.';

  @override
  String get locationWines => 'Wines stored here';

  @override
  String highlightedPositions(String positions) {
    return 'Positions of this wine: $positions';
  }

  @override
  String get inventory => 'Inventory';

  @override
  String inventoryTitle(String location) {
    return 'Inventory: $location';
  }

  @override
  String get inventoryConfirm => 'Confirm';

  @override
  String get inventoryCorrect => 'Correct';

  @override
  String get inventoryNext => 'Next location';

  @override
  String get inventoryFinish => 'Finish';

  @override
  String get inventoryReport => 'Inventory report';

  @override
  String inventoryReportLine(String wine, int before, int after) {
    return '$wine: $before → $after';
  }

  @override
  String get inventoryNoGap => 'No difference: the stock is right.';

  @override
  String inventoryGaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count differences corrected',
      one: '1 difference corrected',
    );
    return '$_temp0';
  }

  @override
  String inventoryProgress(int done, int total) {
    return '$done / $total lots checked';
  }

  @override
  String get inventoryEmpty => 'No lots to check here.';

  @override
  String get close => 'Close';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get settingsDefaultOwner => 'Default owner';

  @override
  String get settingsDefaultLocation => 'Default location';

  @override
  String get settingsDefaultSort => 'Default sort';

  @override
  String get settingsDefaultSortSet => 'Use the list\'s current sort';

  @override
  String get settingsScale => 'My score scale';

  @override
  String get scale20 => 'Out of 20';

  @override
  String get scale100 => 'Out of 100';

  @override
  String get settingsCardPrice => 'Price shown on cards';

  @override
  String get cardPricePurchase => 'Purchase price';

  @override
  String get cardPriceMarket => 'Market value';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsHint => 'Peak and end of enrichment.';

  @override
  String get settingsAutoPrices => 'Monthly price refresh';

  @override
  String get settingsAutoPricesHint =>
      'Once a month, wines without a recent price check are queued. Off by default.';

  @override
  String get settingsPhotoSpace => 'Space used by photos';

  @override
  String photoSpaceValue(String size) {
    return '$size';
  }

  @override
  String get settingsReference => 'Setup';

  @override
  String get settingsOwners => 'Owners';

  @override
  String get settingsLists => 'Value lists';

  @override
  String get settingsGardeRules => 'Ageing rules';

  @override
  String get ownersEmpty => 'No owners.';

  @override
  String get addOwner => 'Add an owner';

  @override
  String get editOwner => 'Edit the owner';

  @override
  String get ownerName => 'Name';

  @override
  String get ownerInitials => 'Initials (2 to 3 letters)';

  @override
  String get ownerDefault => 'Default owner';

  @override
  String ownerBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
      zero: 'No bottles',
    );
    return '$_temp0';
  }

  @override
  String get defaultBadge => 'default';

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values',
      one: '1 value',
    );
    return '$_temp0';
  }

  @override
  String get listNameTypeVin => 'Wine types';

  @override
  String get listNamePays => 'Countries';

  @override
  String get listNameRegion => 'Regions';

  @override
  String get listNameSousRegion => 'Sub-regions';

  @override
  String get listNameAppellation => 'Appellations';

  @override
  String get listNameSigneQualite => 'Quality labels';

  @override
  String get listNameClassement => 'Classifications';

  @override
  String get listNameCertification => 'Certifications';

  @override
  String get listNameCepage => 'Grape varieties';

  @override
  String get listNameFormat => 'Bottle sizes';

  @override
  String get listNameFournisseur => 'Suppliers';

  @override
  String get listNameMotifMouvement => 'Movement reasons';

  @override
  String get listNameAccordMets => 'Food pairings';

  @override
  String get listNameCritique => 'Critics';

  @override
  String get addValue => 'Add a value';

  @override
  String get renameValue => 'Rename';

  @override
  String get deactivateValue => 'Deactivate';

  @override
  String get activateValue => 'Reactivate';

  @override
  String get mergeValue => 'Merge into…';

  @override
  String mergeTitle(String from) {
    return 'Merge “$from” into…';
  }

  @override
  String get mergeDone => 'Values merged, wines updated.';

  @override
  String get deleteValue => 'Delete';

  @override
  String get inactive => 'deactivated';

  @override
  String get valueLabel => 'Label';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get importCsv => 'Import a CSV';

  @override
  String importDone(int created, int updated) {
    return '$created created, $updated updated';
  }

  @override
  String get gardeRulesPending => 'Default values to be confirmed';

  @override
  String get gardeRulesIntro =>
      'Rules applied on the phone when no drinking window comes from a critic or the producer. Offsets in years after the vintage. The first rule that matches the wine applies. Tap a rule to edit it.';

  @override
  String gardeRuleLine(int start, int peak, int end) {
    return 'Start +$start · peak +$peak · end +$end';
  }

  @override
  String get gardeRuleDefault => 'Default rule';

  @override
  String get gardeRulesCustomized => 'Rules changed on this phone';

  @override
  String get gardeRuleAdd => 'Add a rule';

  @override
  String get gardeRuleEdit => 'Edit the rule';

  @override
  String get gardeRuleNew => 'New rule';

  @override
  String get gardeRulesReset => 'Restore default values';

  @override
  String get gardeRulesResetTitle => 'Restore the built-in rules?';

  @override
  String get gardeRulesResetBody =>
      'Your changes will be lost. Wines with an estimated drinking window are recalculated.';

  @override
  String get gardeRuleDelete => 'Delete the rule';

  @override
  String get gardeRuleColor => 'Colour';

  @override
  String get gardeRuleRegions => 'Regions';

  @override
  String get gardeRuleClassifications => 'Classifications';

  @override
  String get gardeRuleAny => 'All';

  @override
  String gardeRuleOther(String conditions) {
    return 'Other conditions kept: $conditions';
  }

  @override
  String get gardeRuleStart => 'Start (years)';

  @override
  String get gardeRulePeak => 'Peak (years)';

  @override
  String get gardeRuleEnd => 'End (years)';

  @override
  String get gardeRuleOffsetsInvalid =>
      'Between 0 and 100, with start ≤ peak ≤ end.';

  @override
  String get gardeRuleNeedsCondition =>
      'Choose at least a colour, a region or a classification.';

  @override
  String get gardeRuleVintaged => 'Vintage';

  @override
  String get gardeRuleNonVintage => 'Non-vintage';

  @override
  String get gardeRuleSearch => 'Search';

  @override
  String gardeRulesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rules saved, $count wines recalculated',
      one: 'Rules saved, 1 wine recalculated',
      zero: 'Rules saved, no wine to recalculate',
    );
    return '$_temp0';
  }

  @override
  String get backupIntro =>
      'Android\'s automatic backup is not enough for photos: regularly export an archive to Drive, an email or a computer.';

  @override
  String get backupExport => 'Export an archive without photos';

  @override
  String get backupExportHint => 'A few MB, do it often.';

  @override
  String get backupExportFull => 'Export a full archive';

  @override
  String get backupExportFullHint => 'Database and photos.';

  @override
  String get backupRestore => 'Restore an archive';

  @override
  String get backupRestoreHint =>
      'Replaces the whole cellar with the archive\'s content.';

  @override
  String get backupRestoreTitle => 'Restore this archive?';

  @override
  String backupRestoreBody(String date, int wines) {
    return 'Archive from $date, $wines wines. The current cellar will be entirely replaced.';
  }

  @override
  String get backupRestored => 'Archive restored.';

  @override
  String get backupShared => 'Archive ready: choose where to send it.';

  @override
  String get backupAuto => 'Automatic backups';

  @override
  String get backupAutoHint => 'One a week on the phone, the last 3 are kept.';

  @override
  String get backupAutoNone => 'No automatic backup yet.';

  @override
  String backupLastExternal(String date) {
    return 'Last export: $date';
  }

  @override
  String get backupNeverExported => 'No export yet.';

  @override
  String get backupErrorArchive => 'This file is not an IA cave à vin archive.';

  @override
  String get backupErrorNewer =>
      'Archive created by a newer version of the app: update the app.';

  @override
  String get backupErrorCorrupted =>
      'Damaged archive: the cellar was not changed.';

  @override
  String get restoreFromAuto => 'Restore';

  @override
  String bottlesWithoutPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles without a price',
      one: '1 bottle without a price',
    );
    return '$_temp0';
  }

  @override
  String get addMenuTitle => 'Add a wine';

  @override
  String get addByPhoto => 'Photograph the label';

  @override
  String get addByPhotoHint =>
      '1 to 4 photos, the record almost fills itself in.';

  @override
  String get addByBarcode => 'With the barcode';

  @override
  String get addByBarcodeHint =>
      'Scan the EAN, then take photos: it helps identification.';

  @override
  String get addManual => 'Manual entry';

  @override
  String get addManualHint => 'Fill in the record yourself.';

  @override
  String get addExcel => 'Excel import';

  @override
  String get addExcelHint => 'xlsx workbook, with a dry run before import.';

  @override
  String get unidentifiedWine => 'Wine to identify';

  @override
  String get captureTitle => 'Bottle photos';

  @override
  String get captureHint =>
      'Frame the whole label, straight, without glare. Add the back label if it shows the alcohol or the grapes.';

  @override
  String get photoTypeEtiquette => 'Label';

  @override
  String get photoTypeContreEtiquette => 'Back label';

  @override
  String get photoTypeCapsule => 'Capsule';

  @override
  String get photoTypeCollerette => 'Neck label';

  @override
  String get photoTypeAutre => 'Other';

  @override
  String get takePhoto => 'Camera';

  @override
  String get fromGallery => 'Gallery';

  @override
  String get removePhoto => 'Remove the photo';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get keepPhoto => 'Keep';

  @override
  String get photoBlurry => 'Blurry photo: retake it for a better reading.';

  @override
  String get photoGlare =>
      'Glare on the label: change the angle or avoid the flash.';

  @override
  String get photoProcessing => 'Processing the photo…';

  @override
  String get photoUnreadable => 'Unreadable image.';

  @override
  String get eanField => 'EAN barcode (optional)';

  @override
  String get scanLive => 'Scan the barcode';

  @override
  String get scanFromPhoto => 'Read the barcode from a photo';

  @override
  String get scanTitle => 'Barcode';

  @override
  String get scanHint =>
      'Frame the barcode on the back label: it is read automatically.';

  @override
  String scanFound(String code) {
    return 'Barcode read: $code';
  }

  @override
  String get scanNotFound => 'No readable EAN barcode on this photo.';

  @override
  String get scanPermissionDenied => 'Camera access denied';

  @override
  String get scanUnavailable => 'Barcode reader unavailable on this device';

  @override
  String get scanUseField => 'Type the 13 digits in the field.';

  @override
  String get vintageScanLive => 'Read the vintage with the camera';

  @override
  String get vintageScanFromPhoto => 'Read the vintage from a photo';

  @override
  String get vintageScanTitle => 'Vintage';

  @override
  String get vintageScanHint =>
      'Frame the year printed on the label or the neck label: it is read automatically.';

  @override
  String vintageScanSeen(String year) {
    return 'Read: $year, hold the bottle still…';
  }

  @override
  String vintageScanFound(String year) {
    return 'Vintage read: $year';
  }

  @override
  String get vintageScanNotFound => 'No readable vintage on this photo.';

  @override
  String get vintageScanUnavailable =>
      'Vintage reading unavailable on this device';

  @override
  String get vintageScanUseField => 'Type the 4 digits in the field.';

  @override
  String get vintageHintField => 'Vintage if you know it (optional)';

  @override
  String get continueToEnrichment => 'Start identification';

  @override
  String get needOnePhoto => 'Add at least one photo of the label.';

  @override
  String get consentTitle => 'Sending photos';

  @override
  String get consentBody =>
      'To identify the wine, label photos are sent to the enrichment service on the server, read, then deleted after processing. No other data from your cellar is sent.';

  @override
  String get consentAccept => 'I agree';

  @override
  String get consentRefuse => 'Decline';

  @override
  String get consentRefused =>
      'Photos kept on the phone, record to be completed by hand.';

  @override
  String get enrichTitle => 'Identification';

  @override
  String get enrichLotTitle => 'Meanwhile, the lot';

  @override
  String get saveLot => 'Save the lot';

  @override
  String get lotSaved => 'Lot saved.';

  @override
  String get stepWaiting => 'Waiting to send';

  @override
  String get stepLecture => 'Reading the label';

  @override
  String get stepNormalisation => 'Formatting';

  @override
  String get stepIdentification => 'Identifying the wine';

  @override
  String get stepEnrichissement => 'Searching for information';

  @override
  String get stepNotes => 'Searching for scores';

  @override
  String get stepPrix => 'Searching for prices';

  @override
  String get stepControles => 'Checks';

  @override
  String get stepTermine => 'Done';

  @override
  String get enrichOffline =>
      'Offline: the record stays “to enrich”, it will be sent when the network is back.';

  @override
  String get enrichNotConnected =>
      'No account signed in: the record stays “to enrich”. Sign in to start identification, it will be sent then.';

  @override
  String get enrichReady => 'Suggestions ready';

  @override
  String get labelPreviewTitle => 'Read on the label, meanwhile';

  @override
  String labelPreviewLine(String field, String value) {
    return '$field: $value';
  }

  @override
  String get reviewProposals => 'Review the suggestions';

  @override
  String get validationPendingBody =>
      'Read on the label so far. More information is added as soon as the server finds it; you can already make corrections.';

  @override
  String get validationWaiting => 'Validation possible once the search is over';

  @override
  String get validationSearchFailed => 'The information search failed';

  @override
  String get validationSearchFailedBody =>
      'What was read on the label is still shown. Restart the search or complete the record by hand.';

  @override
  String enrichFailed(String reason) {
    return 'Identification failed: $reason';
  }

  @override
  String get enrichRetry => 'Retry';

  @override
  String enrichFinishedSnack(String name) {
    return 'Identification done: $name';
  }

  @override
  String quotaLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count identifications left this month',
      one: 'Only 1 identification left this month',
      zero: 'Monthly quota used up',
    );
    return '$_temp0';
  }

  @override
  String pendingJobs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count identifications pending',
      one: '1 identification pending',
    );
    return '$_temp0';
  }

  @override
  String get errorTimeout => 'no answer within 3 minutes';

  @override
  String get errorInvalid => 'invalid response from the service';

  @override
  String get validationTitle => 'Suggestions';

  @override
  String get acceptAll => 'Accept all and save';

  @override
  String get saveValidation => 'Save';

  @override
  String get accept => 'Accept';

  @override
  String get modify => 'Correct';

  @override
  String get reject => 'Reject';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String modified(String value) {
    return 'Corrected: $value';
  }

  @override
  String currentValue(String value) {
    return 'Current: $value';
  }

  @override
  String proposedValue(String value) {
    return 'Suggested: $value';
  }

  @override
  String confidence(int percent) {
    return 'confidence $percent%';
  }

  @override
  String get lowConfidence => 'Low confidence: check it';

  @override
  String notFound(String reason) {
    return 'Not found: $reason';
  }

  @override
  String get lockedField => 'Entered by hand: kept';

  @override
  String get disagreement => 'The label and a source disagree';

  @override
  String get duplicateFound => 'This wine is already in the cellar.';

  @override
  String get duplicateMerge => 'Add these bottles to the existing record';

  @override
  String get scoresSection => 'Critic scores';

  @override
  String get pricesSection => 'Market price';

  @override
  String get alertsSection => 'Good to know';

  @override
  String get includePrices => 'Save the prices found';

  @override
  String get keepScore => 'Keep this score';

  @override
  String priceFound(String price, int offers, String date) {
    return '$price · $offers offers · $date';
  }

  @override
  String get validationSaved => 'Record validated.';

  @override
  String get srcEtiquette => 'Label';

  @override
  String get srcSiteOfficiel => 'Official website';

  @override
  String get srcOrganismeOfficiel => 'Official body';

  @override
  String get srcInterprofession => 'Trade association';

  @override
  String get srcCritique => 'Critic';

  @override
  String get srcMarchand => 'Merchant';

  @override
  String get srcTiers => 'Other website';

  @override
  String get srcEstimation => 'Estimate';

  @override
  String get srcManuel => 'Manual entry';

  @override
  String get srcImport => 'Import';

  @override
  String get provenanceTitle => 'Source';

  @override
  String provenanceSource(String source) {
    return 'Source: $source';
  }

  @override
  String provenanceDate(String date) {
    return 'Collected on $date';
  }

  @override
  String provenanceUrl(String url) {
    return 'Link: $url';
  }

  @override
  String get copyLink => 'Copy the link';

  @override
  String get linkCopied => 'Link copied.';

  @override
  String get reportError => 'Report an error';

  @override
  String get reported => 'Reported as wrong, to be corrected';

  @override
  String get reportedSnack =>
      'Error reported: the value stays struck through until corrected, and the report goes with the record\'s next enrichment.';

  @override
  String get provenanceBadge => 'See the source';

  @override
  String aiWritten(String site) {
    return 'Written by AI from $site';
  }

  @override
  String get toValidateBanner => 'Suggestions to review';

  @override
  String get enrichingBanner => 'Identification in progress';

  @override
  String get toEnrichBanner => 'Waiting for identification';

  @override
  String get errorBanner => 'Identification failed';

  @override
  String get duplicateVintage => 'Duplicate for another vintage';

  @override
  String get duplicateVintageTitle => 'New vintage';

  @override
  String get duplicateVintageDone =>
      'Record created: only the vintage fields remain to be enriched.';

  @override
  String get reEnrich => 'Enrich again';

  @override
  String get reEnrichStarted => 'New enrichment started on unlocked fields.';

  @override
  String get reEnrichNoPhoto =>
      'No photo on this record: it cannot be enriched again.';

  @override
  String get unlockField => 'Unlock';

  @override
  String get unlocked => 'Field unlocked: it can be suggested again.';

  @override
  String get pricesAllTitle => 'Check prices for the whole cellar';

  @override
  String get pricesAllHint =>
      'Wines without a price check in the last 24 hours.';

  @override
  String pricesAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count price checks will be sent to the service.',
      one: '1 price check will be sent to the service.',
      zero: 'No wines to check: all were checked less than 24 hours ago.',
    );
    return '$_temp0';
  }

  @override
  String pricesQuotaLeft(int left) {
    return 'Quota left this month: $left price checks.';
  }

  @override
  String get pricesQuotaUnknown =>
      'Remaining quota unknown: it will show after the first price check.';

  @override
  String pricesQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count price checks queued.',
      one: '1 price check queued.',
      zero: 'No price check added.',
    );
    return '$_temp0';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get priceQueuedOne => 'Price check queued.';

  @override
  String get priceAlreadyQueued =>
      'A price check is already under way for this wine.';

  @override
  String get priceTooRecentTitle => 'Recent price check';

  @override
  String get priceTooRecent =>
      'The last price check is less than 24 hours old. Force a new check?';

  @override
  String get priceForce => 'Force';

  @override
  String priceOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
      zero: 'no offers',
    );
    return '$_temp0';
  }

  @override
  String get priceNatureMedian => 'median';

  @override
  String get priceNatureOffer => 'single offer';

  @override
  String priceTrendUp(String percent) {
    return 'Up $percent since the previous check';
  }

  @override
  String priceTrendDown(String percent) {
    return 'Down $percent since the previous check';
  }

  @override
  String get priceTrendFlat => 'Stable since the previous check';

  @override
  String priceOpenOffer(String site) {
    return 'See the offer on $site';
  }

  @override
  String get priceChartLabel => 'Chart of recorded prices';

  @override
  String get priceHistory => 'Price history';

  @override
  String get photoTypeDegustation => 'Tasting';

  @override
  String get photoTypeRepas => 'Meal';

  @override
  String get photoTypeEvenement => 'Event';

  @override
  String get tabTastingsPhotos => 'Tastings and photos';

  @override
  String get otherPhotos => 'Other photos';

  @override
  String get libraryEmpty => 'No other photos for this bottle (meal, event).';

  @override
  String get libraryAdd => 'Add a photo';

  @override
  String get libraryTypeTitle => 'Photo type';

  @override
  String get libraryAdded => 'Photo added';

  @override
  String get photoDelete => 'Delete the photo';

  @override
  String get photoDeleteBody => 'The photo is erased from the device.';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String photoCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String photoOpen(int index) {
    return 'View photo $index';
  }

  @override
  String get validationPhotos => 'Photos';

  @override
  String get photoCroppedLabel => 'Cropped to the label';

  @override
  String get photoWholeLabel => 'Whole photo';

  @override
  String get cropAction => 'Crop';

  @override
  String get cropTitle => 'Crop the label';

  @override
  String get cropHint => 'Drag the frame or its corners over the label.';

  @override
  String get cropWhole => 'Whole photo';

  @override
  String get cropSaved => 'Frame saved';

  @override
  String get cropOriginalNote =>
      'The original photo is kept until the record is validated.';

  @override
  String get excelListName => 'List';

  @override
  String get excelListValue => 'Allowed value';

  @override
  String get excelListParent => 'Belongs to';

  @override
  String get excelNotice =>
      'Import rules for the IA cave à vin workbook\n\nSheet and column names stay in French, so a workbook works whatever the app language.\n\nSheet “Vins”: one row per wine (producer, cuvée, vintage).\n- Column id filled in: the existing wine is updated. Empty id: a wine is created.\n- Action = SUPPRIMER (with the id): the wine is removed from the cellar, its movements stay in the history.\n- Domaine, Pays, Couleur and Millésime are required. Millésime: a year, or NM for a non-vintage wine.\n- Lists (country, region, appellation, grapes, pairings…) take the values of the “Listes” sheet. Several values in one cell: separated by a semicolon.\n- Grapes: “Merlot 80 %; Cabernet Franc 20 %”, 100% in total at most.\n- The columns Origine garde, Statut garde, Statut enrichissement, Note Parker, Meilleure note, Stock total and Photo principale are calculated: they are ignored on import.\n\nSheet “Lots”: one row per lot (same wine, size, owner, location, price).\n- Lot id filled in: update; empty: creation. Action = SUPPRIMER: the lot is deleted.\n- Wine id: the id of a wine in the “Vins” sheet, or #row number for a wine created by the same import (example: #12).\n- Quantité: target quantity. The app creates an adjustment movement for the difference, reason “import Excel”. Empty cell: stock unchanged.\n- Emplacement: full path, for example “Cave > Armoire 1 > Casier A”.\n\nSheet “Mouvements”: read-only, ignored on import.\n\nPhotos: attach a zip of photos; a photo whose name appears in the Photo principale column is linked to the wine.\n\nBefore any import, the app runs a dry run and shows a report. An automatic backup is made just before, and the import is applied in full or not at all.';

  @override
  String get ieExcelSection => 'Excel';

  @override
  String get ieExport => 'Export the cellar';

  @override
  String get ieExportHint =>
      'xlsx workbook: wines, lots, movements, allowed lists and instructions.';

  @override
  String get ieTemplate => 'Blank template';

  @override
  String get ieTemplateHint =>
      'The same workbook without data, to enter a cellar on a computer.';

  @override
  String get ieImport => 'Import a workbook';

  @override
  String get ieImportHint => 'Dry run and report before any change.';

  @override
  String get iePhotosTitle => 'Attach photos?';

  @override
  String get iePhotosBody =>
      'A zip of photos can come with the workbook: each photo named in the Photo principale column is linked to its wine.';

  @override
  String get iePhotosPick => 'Choose a zip';

  @override
  String get iePhotosSkip => 'Without photos';

  @override
  String get ieReady => 'File ready';

  @override
  String get importReportTitle => 'Import dry run';

  @override
  String importWinesCreated(int n) {
    return 'Wines created: $n';
  }

  @override
  String importWinesUpdated(int n) {
    return 'Wines updated: $n';
  }

  @override
  String importWinesDeleted(int n) {
    return 'Wines deleted: $n';
  }

  @override
  String importLotsCreated(int n) {
    return 'Lots created: $n';
  }

  @override
  String importLotsUpdated(int n) {
    return 'Lots updated: $n';
  }

  @override
  String importLotsDeleted(int n) {
    return 'Lots deleted: $n';
  }

  @override
  String importStockChanges(int n) {
    return 'Stock adjusted: $n';
  }

  @override
  String importPhotos(int n) {
    return 'Photos linked: $n';
  }

  @override
  String get importNoChange => 'No difference with the cellar.';

  @override
  String get importUnknownTitle => 'Values not in the app';

  @override
  String get importCreateUnknown => 'Create them during the import';

  @override
  String importIssuesTitle(int n) {
    return 'Errors to fix ($n)';
  }

  @override
  String importIssueWhere(String sheet, int row, String column) {
    return '$sheet, row $row, column $column';
  }

  @override
  String get importApply => 'Import';

  @override
  String get importBlocked =>
      'Fix the workbook, then start the import again: nothing changes while an error remains.';

  @override
  String get importBackupNote =>
      'An automatic backup is made just before the import, which is applied in full or not at all.';

  @override
  String get importEnrich => 'Enrich the wines created';

  @override
  String importEnrichHint(int n, String left) {
    return '$n wines created with a photo, so $n calls to the service. Quota left this month: $left.';
  }

  @override
  String get importEnrichUnknownQuota => 'unknown';

  @override
  String importEnrichStarted(int n) {
    return '$n enrichments queued';
  }

  @override
  String get importOwnerList => 'Owner';

  @override
  String get issueMissingSheet => 'missing sheet';

  @override
  String get issueMissingColumn => 'missing column';

  @override
  String get issueRequired => 'required value';

  @override
  String get issueUnknownId => 'unknown id';

  @override
  String get issueDuplicateId => 'id present twice';

  @override
  String get issueInvalidNumber => 'number expected';

  @override
  String get issueInvalidVintage =>
      'vintage expected: a year up to the current year, or NM';

  @override
  String get issueOutOfRange => 'value out of range';

  @override
  String get issueGardeOrder =>
      'inconsistent drinking window: start after the vintage, start before the peak, peak before the end';

  @override
  String get issueInvalidEan => 'invalid barcode: 13 digits and a check digit';

  @override
  String get issueInvalidBoolean => 'yes or no expected';

  @override
  String get issueInvalidDate => 'date expected';

  @override
  String get issueInvalidGrapes =>
      'unreadable grapes: “Merlot 80 %; Cabernet Franc 20 %”';

  @override
  String get issueInvalidAction =>
      'unknown action: empty or SUPPRIMER, with the id';

  @override
  String get issueUnknownValue => 'value not in the list';

  @override
  String get issueUnknownLocation => 'unknown location';

  @override
  String get issueUnknownWine => 'unknown wine';

  @override
  String get issueDeletedWine => 'wine deleted by this same import';

  @override
  String get issueLotWineChange =>
      'a lot cannot move to another wine: create a new lot';

  @override
  String get importFinished => 'Import complete';

  @override
  String pdfGardeRange(String start, String end) {
    return 'from $start to $end';
  }

  @override
  String pdfGardePeak(String year) {
    return 'peak $year';
  }

  @override
  String pdfAlcohol(String value) {
    return '$value%';
  }

  @override
  String get pdfGardeSource => 'Drinking window source';

  @override
  String get pdfGardeStatus => 'Ageing status';

  @override
  String get pdfParker => 'Parker score';

  @override
  String get pdfStock => 'In stock';

  @override
  String pdfBottles(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bottles',
      one: '1 bottle',
      zero: 'no bottles',
    );
    return '$_temp0';
  }

  @override
  String pdfCitedBy(String site) {
    return 'cited by $site';
  }

  @override
  String pdfPrice(String price) {
    return '$price each';
  }

  @override
  String pdfEditedOn(String date) {
    return 'Printed on $date';
  }

  @override
  String get pdfCatalogueTitle => 'Cellar catalogue';

  @override
  String pdfCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n wines',
      one: '1 wine',
    );
    return '$_temp0';
  }

  @override
  String get pdfFilters => 'Filters applied';

  @override
  String get pdfNoFilter => 'No filter: all wines.';

  @override
  String pdfPage(String n, String total) {
    return 'Page $n / $total';
  }

  @override
  String issueWithValue(String reason, String value) {
    return '$reason: “$value”';
  }

  @override
  String filterLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get catalogueSection => 'PDF catalogue';

  @override
  String get catalogueHint =>
      'Two wines per A4 page. The list\'s filters and sort are used; you can change them here without touching the list.';

  @override
  String catalogueFilters(int n) {
    return 'Filters ($n)';
  }

  @override
  String get catalogueCover => 'Cover page (date, filters, number of wines)';

  @override
  String catalogueGenerate(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Generate the catalogue ($n wines)',
      one: 'Generate the catalogue (1 wine)',
      zero: 'No wines to print',
    );
    return '$_temp0';
  }

  @override
  String get winePdf => 'PDF record';

  @override
  String get pdfPreparing => 'Preparing the PDF…';

  @override
  String get statsTabGeneral => 'General';

  @override
  String get statsTabRegions => 'Regions';

  @override
  String get statsTabGarde => 'Ageing';

  @override
  String get statsTabValue => 'Value';

  @override
  String get statsTabBuying => 'Buying guide';

  @override
  String get statsTabExplorer => 'Explorer';

  @override
  String get statsEmpty =>
      'No bottles in the cellar: add wines to see statistics.';

  @override
  String get statNoData => 'No data for this view.';

  @override
  String get statMeasureBottles => 'Number of bottles';

  @override
  String get statMeasureReferences => 'Number of wines';

  @override
  String get statMeasurePurchase => 'Purchase value';

  @override
  String get statMeasureMarket => 'Market value';

  @override
  String get statMeasureGain => 'Unrealised gain';

  @override
  String get statMeasureAvgPrice => 'Average price';

  @override
  String get statMeasureAvgScore => 'Average score (/100)';

  @override
  String get statMeasureOpened => 'Bottles opened (12 months)';

  @override
  String get statMeasureYears => 'Average years before drinking';

  @override
  String get statDimColor => 'Colour';

  @override
  String get statDimType => 'Type';

  @override
  String get statDimCountry => 'Country';

  @override
  String get statDimRegion => 'Region';

  @override
  String get statDimSubRegion => 'Sub-region';

  @override
  String get statDimAppellation => 'Appellation';

  @override
  String get statDimProducer => 'Producer';

  @override
  String get statDimVintage => 'Vintage';

  @override
  String get statDimVintageBand => '5-vintage band';

  @override
  String get statDimGrape => 'Main grape';

  @override
  String get statDimOwner => 'Owner';

  @override
  String get statDimLocation => 'Location';

  @override
  String get statDimGardeStatus => 'Ageing status';

  @override
  String get statDimGardeStart => 'Drinking window start year';

  @override
  String get statDimPeak => 'Peak year';

  @override
  String get statDimScoreBand => 'Score band';

  @override
  String get statDimPriceBand => 'Price band';

  @override
  String get statDimSupplier => 'Supplier';

  @override
  String get statDimPurchaseMonth => 'Purchase month';

  @override
  String get statDimOpeningMonth => 'Opening month';

  @override
  String get statChartDonut => 'Donut';

  @override
  String get statChartBarsV => 'Vertical bars';

  @override
  String get statChartBarsH => 'Horizontal bars';

  @override
  String get statChartStacked => 'Stacked bars';

  @override
  String get statChartLine => 'Line';

  @override
  String get statChartCross => 'Cross table';

  @override
  String get statChartKpi => 'Single figure';

  @override
  String get statNone => 'Not set';

  @override
  String get statOther => 'Other';

  @override
  String statBand(String from, String to) {
    return '$from to $to';
  }

  @override
  String statFrom(String from) {
    return '$from and over';
  }

  @override
  String get statToDrinkThisYear => 'To drink this year';

  @override
  String get statDrinkSoon => 'Drink soon';

  @override
  String get statPast => 'Past their best';

  @override
  String get statGardeByYear =>
      'Bottles by year they enter their drinking window';

  @override
  String get statByColor => 'Bottles by colour';

  @override
  String get statVintageColor => 'Vintage and colour';

  @override
  String get statByOrigin => 'Bottles by origin';

  @override
  String get statDrillHint =>
      'Tap a bar to drill down from country to region, then to appellation.';

  @override
  String get statDrillUp => 'Go back up';

  @override
  String get statPurchaseVsMarket => 'Purchase and market value by colour';

  @override
  String get statPurchaseVsMarketRegion =>
      'Purchase and market value by region';

  @override
  String get statMarketHistory =>
      'Market value of the current stock, over 24 months';

  @override
  String get statOpenedVsStock =>
      'Bottles opened in the last 12 months and stock, by colour';

  @override
  String get statMonthsLeft =>
      'Months of stock left at the current opening rate';

  @override
  String statMonthsValue(String n) {
    return '$n months';
  }

  @override
  String get statNoOpening => 'no bottle opened in 12 months';

  @override
  String get statSeriesPurchase => 'Purchase';

  @override
  String get statSeriesMarket => 'Market';

  @override
  String get statSeriesOpened => 'Opened';

  @override
  String get statSeriesStock => 'In stock';

  @override
  String statSeeWines(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'See the $n wines',
      one: 'See the wine',
    );
    return '$_temp0';
  }

  @override
  String get statWinesTitle => 'Wines in the selection';

  @override
  String get statMeasure => 'Measure';

  @override
  String get statDimension => 'Dimension';

  @override
  String get statDimension2 => 'Second dimension';

  @override
  String get statNoDimension2 => 'None';

  @override
  String get statChartType => 'Chart';

  @override
  String get statFilters => 'Filters';

  @override
  String get statFilterAdd => 'Add a filter';

  @override
  String statFilterLine(String dimension, String values) {
    return '$dimension: $values';
  }

  @override
  String get statFavorites => 'Favourites';

  @override
  String get statNoFavorites => 'No saved views.';

  @override
  String get statSave => 'Save as favourite';

  @override
  String get statViewName => 'View name';

  @override
  String get statSaved => 'View saved';

  @override
  String get statDeleteView => 'Delete the view';

  @override
  String get statExport => 'Export';

  @override
  String get statExportPng => 'PNG image';

  @override
  String get statExportPdf => 'PDF';

  @override
  String get statExportCsv => 'CSV table';

  @override
  String get statTotal => 'Total';

  @override
  String get statAverage => 'Average';

  @override
  String get toDrinkTab => 'To drink';

  @override
  String get pastTab => 'Past';

  @override
  String get pastEmpty => 'No wine in stock is past its drinking window.';

  @override
  String pastHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count wines are past their drinking window: drink them without delay or taste them before serving.',
      one: '1 wine is past its drinking window: drink it without delay or taste it before serving.',
    );
    return '$_temp0';
  }

  @override
  String get tastingsTab => 'Tastings';

  @override
  String get toDrinkEmpty => 'No wine is in its drinking window right now.';

  @override
  String get toDrinkHint =>
      'Wines in their drinking window, the ones to drink soon first, then by end of window.';

  @override
  String get dishPick => 'For which dish?';

  @override
  String get dishAny => 'All dishes';

  @override
  String get dishNoWine => 'No wine ready to drink goes with this dish.';

  @override
  String dishCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n wines for this dish',
      one: '1 wine for this dish',
    );
    return '$_temp0';
  }

  @override
  String get tastingsEmpty =>
      'No tastings recorded. You are offered one each time a bottle is opened.';

  @override
  String get alertTitle => 'This month in the cellar';

  @override
  String alertBody(int peak, int ending) {
    String _temp0 = intl.Intl.pluralLogic(
      peak,
      locale: localeName,
      other: '$peak wines reach their peak. ',
      one: '1 wine reaches its peak. ',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ending,
      locale: localeName,
      other: '$ending wines reach the end of their window.',
      one: '1 wine reaches the end of its window.',
      zero: '',
    );
    return '$_temp0$_temp1';
  }

  @override
  String get alertSee => 'See the wines';

  @override
  String get alertDismiss => 'Close';

  @override
  String get alertWinesTitle => 'Peak and end of window';

  @override
  String get shoppingEmpty =>
      'Nothing to buy. A wine with no bottles left is suggested here, and you can note a wine spotted elsewhere.';

  @override
  String get shoppingAdd => 'Add a wine you spotted';

  @override
  String get shoppingLabel => 'Wine';

  @override
  String get shoppingQuantity => 'Quantity wanted';

  @override
  String get shoppingNote => 'Note (where to buy it, price seen)';

  @override
  String get shoppingBought => 'Bought';

  @override
  String get shoppingDelete => 'Remove from the list';

  @override
  String get shoppingAdded => 'Added to the shopping list';

  @override
  String get shoppingProposeTitle => 'No bottles left';

  @override
  String shoppingProposeBody(String wine) {
    return '$wine: add it to the shopping list?';
  }

  @override
  String get shoppingProposeAction => 'Add to the list';

  @override
  String shoppingQuantityValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bottles',
      one: '1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get shareImage => 'Share as an image';

  @override
  String get sharePreviewTitle => 'Share the record';

  @override
  String get shareAsImage => 'Image';

  @override
  String get shareAsPdf => 'PDF';

  @override
  String get favoriteOn => 'Add to favourites';

  @override
  String get favoriteOff => 'Remove from favourites';

  @override
  String get gridTitle => 'Rack view';

  @override
  String get gridHint =>
      'Tap an occupied cell to open the wine. Long-press an empty cell to store a bottle there.';

  @override
  String gridCell(String cell) {
    return 'Cell $cell';
  }

  @override
  String gridCellWine(String cell, String wine) {
    return 'Cell $cell: $wine';
  }

  @override
  String gridPlaceTitle(String cell) {
    return 'Store in $cell';
  }

  @override
  String get gridHere => 'Already in this rack, without a cell';

  @override
  String get gridElsewhere => 'From another location';

  @override
  String get gridNoCandidate => 'No bottles to store.';

  @override
  String gridPlaced(String cell) {
    return 'Bottle stored in $cell';
  }

  @override
  String gridUnplaced(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bottles without a cell',
      one: '1 bottle without a cell',
    );
    return '$_temp0';
  }

  @override
  String tastingScoreValue(String score, int scale) {
    return '$score / $scale';
  }

  @override
  String get feedbackIntro =>
      'A bug, an idea, a wrong record? Write to us. The message is emailed to the team, with a copy to your address.';

  @override
  String get feedbackTitle => 'Title';

  @override
  String get feedbackComment => 'Comment';

  @override
  String get feedbackEmail => 'Your email address';

  @override
  String get feedbackEmailHelp => 'Receives the copy and the reply.';

  @override
  String get feedbackEmailInvalid =>
      'Invalid email address (example: first.last@example.com).';

  @override
  String get feedbackRequired => 'Required field.';

  @override
  String get feedbackAttachment => 'Attachment (optional)';

  @override
  String get feedbackAttachmentHelp =>
      'Only one: a PDF or an image, 5 MB at most.';

  @override
  String get feedbackAttachFile => 'Attach a file';

  @override
  String get feedbackReplaceFile => 'Replace the file';

  @override
  String get feedbackAttachmentRemove => 'Remove the attachment';

  @override
  String feedbackAttachmentSize(String size) {
    return '$size KB';
  }

  @override
  String get feedbackAttachmentType => 'Only PDFs and images are accepted.';

  @override
  String get feedbackAttachmentTooBig => 'File too large: 5 MB at most.';

  @override
  String get feedbackSend => 'Send';

  @override
  String feedbackSent(String email) {
    return 'Message sent. A copy goes to $email.';
  }

  @override
  String get feedbackQuota =>
      'Limit of 5 messages a day reached. Try again tomorrow.';

  @override
  String feedbackRefused(String detail) {
    return 'Sending refused: $detail';
  }

  @override
  String get feedbackOffline =>
      'No network. Your message stays here, try again once connected.';

  @override
  String get feedbackNotConnected =>
      'No account signed in: the message was not sent. Sign in, then send it again.';

  @override
  String get feedbackAuth =>
      'Your session has expired: sign in again from the Account menu (icon at the top right), then send the message again.';

  @override
  String get feedbackPrivacy =>
      'Your address is only used to reply to you. It goes with the message; the app keeps it only for your account.';

  @override
  String get settingsAccount => 'Account';

  @override
  String get accountTitle => 'Sign in';

  @override
  String get accountHint =>
      'Photo identification, prices and feedback need an account. Enter your address: you will receive a six-digit code by email. The cellar works without an account.';

  @override
  String get accountEmail => 'Email address';

  @override
  String get accountEmailInvalid =>
      'Invalid email address (example: first.last@example.com).';

  @override
  String get accountRequestCode => 'Get a code';

  @override
  String accountCodeSent(String email) {
    return 'Code sent to $email. It is valid for 10 minutes.';
  }

  @override
  String get accountCode => 'Code received by email';

  @override
  String get accountCodeHelp =>
      'Six digits. Remember to check your spam folder.';

  @override
  String get accountCodeInvalid => 'The code has six digits.';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountSignInAction => 'Sign me in';

  @override
  String get accountChangeEmail => 'Change address';

  @override
  String accountSignedInAs(String email) {
    return 'Signed in: $email';
  }

  @override
  String accountStatusLine(String status) {
    return 'Plan: $status';
  }

  @override
  String get accountStatusFree => 'free';

  @override
  String get accountStatusSubscriber => 'subscription';

  @override
  String get accountStatusBlocked => 'account suspended';

  @override
  String accountQuotaLine(int enrichments, int prices) {
    String _temp0 = intl.Intl.pluralLogic(
      enrichments,
      locale: localeName,
      other: '$enrichments identifications',
      one: '1 identification',
      zero: 'no identifications',
    );
    String _temp1 = intl.Intl.pluralLogic(
      prices,
      locale: localeName,
      other: '$prices price checks',
      one: '1 price check',
      zero: 'no price checks',
    );
    return 'This month: $_temp0 and $_temp1 left.';
  }

  @override
  String get accountRefresh => 'Refresh';

  @override
  String get accountRefreshed => 'Account up to date.';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignedOut =>
      'Signed out: photo identification waits for a new sign-in.';

  @override
  String get accountOffline => 'No network: try again once connected.';

  @override
  String get accountInvalid =>
      'Unexpected response from the service: try again later.';

  @override
  String get feedbackSignInNeeded =>
      'Sign in to your account to send feedback.';

  @override
  String get accountMenu => 'Account: sign in';

  @override
  String get accountMenuSignedIn => 'My account';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionOffer =>
      'Free plan. A subscription raises the quotas to 500 identifications and 500 price checks a month.';

  @override
  String get subscriptionMonthly => 'Monthly subscription';

  @override
  String get subscriptionYearly => 'Yearly subscription';

  @override
  String get subscriptionActive =>
      'Subscription active. You unsubscribe in Google Play; the subscription stays active until the end of the paid period.';

  @override
  String get subscriptionManage => 'Manage or cancel in Google Play';

  @override
  String get subscriptionStarted =>
      'Subscription requested from Google Play: it starts as soon as the payment is confirmed.';

  @override
  String get subscriptionUnavailable =>
      'Subscriptions will open when the app is published on Google Play. Meanwhile, the free plan stays active.';

  @override
  String get subscriptionFailed =>
      'The subscription could not start: try again later.';

  @override
  String get subscriptionManageFailed =>
      'Cannot open Google Play on this phone.';

  @override
  String get accountDelete => 'Delete my account';

  @override
  String get accountDeleteTitle => 'Delete the account?';

  @override
  String get accountDeleteBody =>
      'Your address and sign-in key are erased from the service. The cellar stays on the phone. An active subscription is cancelled in Google Play. This deletion is permanent.';

  @override
  String get accountDeleteConfirm => 'Delete';

  @override
  String get accountDeleted =>
      'Account deleted. You can create a new one with the same address.';

  @override
  String get tastingEdit => 'Edit the tasting';

  @override
  String get tastingEditTitle => 'Edit the tasting';

  @override
  String get tastingUpdated => 'Tasting updated.';

  @override
  String get sortDrinkPriority => 'Drinking priority (past, to drink, to keep)';

  @override
  String get peakThisYear => 'peak this year';

  @override
  String peakInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'peak in $count years',
      one: 'peak in 1 year',
    );
    return '$_temp0';
  }

  @override
  String peakPassedYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'peak passed $count years ago',
      one: 'peak passed 1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get statDimDrinkPriority => 'Drinking priority';

  @override
  String get priorityPast => 'Past';

  @override
  String get priorityToDrink => 'To drink';

  @override
  String priorityKeepLittle(int years) {
    return 'Keep a little ($years years at most)';
  }

  @override
  String priorityKeepLong(int years) {
    return 'Keep long (over $years years)';
  }
}
