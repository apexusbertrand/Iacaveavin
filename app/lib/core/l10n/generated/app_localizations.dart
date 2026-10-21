import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'IA cave à vin'**
  String get appTitle;

  /// No description provided for @navMyWines.
  ///
  /// In fr, this message translates to:
  /// **'Mes vins'**
  String get navMyWines;

  /// No description provided for @navToDrink.
  ///
  /// In fr, this message translates to:
  /// **'À boire'**
  String get navToDrink;

  /// No description provided for @navLocations.
  ///
  /// In fr, this message translates to:
  /// **'Emplacements'**
  String get navLocations;

  /// No description provided for @navStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get navStatistics;

  /// No description provided for @navShoppingList.
  ///
  /// In fr, this message translates to:
  /// **'Liste d\'achats'**
  String get navShoppingList;

  /// No description provided for @navImportExport.
  ///
  /// In fr, this message translates to:
  /// **'Import et export'**
  String get navImportExport;

  /// No description provided for @navBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get navBackup;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get navAbout;

  /// No description provided for @placeholderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get placeholderTitle;

  /// No description provided for @placeholderBody.
  ///
  /// In fr, this message translates to:
  /// **'Cet écran arrive avec le lot {lot}.'**
  String placeholderBody(String lot);

  /// No description provided for @wineListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes vins'**
  String get wineListTitle;

  /// No description provided for @wineListSummary.
  ///
  /// In fr, this message translates to:
  /// **'{wines, plural, =0{Aucun vin} =1{1 vin} other{{wines} vins}} · {bottles, plural, =0{0 bouteille} =1{1 bouteille} other{{bottles} bouteilles}}'**
  String wineListSummary(int wines, int bottles);

  /// No description provided for @wineListEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vin.'**
  String get wineListEmptyTitle;

  /// No description provided for @wineListEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez votre première étiquette, ou chargez le jeu de démonstration pour découvrir l\'application.'**
  String get wineListEmptyBody;

  /// No description provided for @wineListLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de la cave'**
  String get wineListLoading;

  /// No description provided for @wineListErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'La cave n\'a pas pu être lue.'**
  String get wineListErrorTitle;

  /// No description provided for @wineListErrorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail : {detail}'**
  String wineListErrorDetail(String detail);

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @addBottle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une bouteille'**
  String get addBottle;

  /// No description provided for @addBottleLater.
  ///
  /// In fr, this message translates to:
  /// **'L\'ajout d\'une bouteille arrive au lot 1 (saisie) et au lot 2a (photo).'**
  String get addBottleLater;

  /// No description provided for @nonVintage.
  ///
  /// In fr, this message translates to:
  /// **'NM'**
  String get nonVintage;

  /// No description provided for @bottleCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Épuisé} =1{1 bouteille} other{{count} bouteilles}}'**
  String bottleCount(int count);

  /// No description provided for @toValidate.
  ///
  /// In fr, this message translates to:
  /// **'À valider'**
  String get toValidate;

  /// No description provided for @wineCardSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{name}, millésime {vintage}, {bottles}'**
  String wineCardSemantics(String name, String vintage, String bottles);

  /// No description provided for @backToTop.
  ///
  /// In fr, this message translates to:
  /// **'Haut de la page'**
  String get backToTop;

  /// No description provided for @settingsDemoSection.
  ///
  /// In fr, this message translates to:
  /// **'Jeu de démonstration'**
  String get settingsDemoSection;

  /// No description provided for @settingsDemoDescription.
  ///
  /// In fr, this message translates to:
  /// **'200 fiches fictives (domaines inventés) pour essayer l\'application et vérifier la fluidité. Vos propres vins ne sont jamais touchés.'**
  String get settingsDemoDescription;

  /// No description provided for @settingsDemoLoaded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Démonstration chargée : 1 fiche} other{Démonstration chargée : {count} fiches}}'**
  String settingsDemoLoaded(int count);

  /// No description provided for @settingsDemoNotLoaded.
  ///
  /// In fr, this message translates to:
  /// **'Démonstration non chargée'**
  String get settingsDemoNotLoaded;

  /// No description provided for @settingsDemoLoad.
  ///
  /// In fr, this message translates to:
  /// **'Charger la démonstration'**
  String get settingsDemoLoad;

  /// No description provided for @settingsDemoErase.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la démonstration'**
  String get settingsDemoErase;

  /// No description provided for @settingsDemoEraseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la démonstration ?'**
  String get settingsDemoEraseTitle;

  /// No description provided for @settingsDemoEraseBody.
  ///
  /// In fr, this message translates to:
  /// **'Les fiches de démonstration, leurs lots et leurs mouvements seront supprimés. Vos propres vins ne sont pas touchés.'**
  String get settingsDemoEraseBody;

  /// No description provided for @settingsDemoLoadedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Démonstration chargée.'**
  String get settingsDemoLoadedSnack;

  /// No description provided for @settingsDemoErasedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Démonstration effacée.'**
  String get settingsDemoErasedSnack;

  /// No description provided for @settingsMoreLater.
  ///
  /// In fr, this message translates to:
  /// **'Les autres réglages (connexion au flux, devise, thème, listes) arrivent au lot 1.'**
  String get settingsMoreLater;

  /// No description provided for @operationFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'opération a échoué : {detail}'**
  String operationFailed(String detail);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @erase.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get erase;

  /// No description provided for @aboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de cave à vin aux couleurs d\'Apexus-BMT. Les données restent sur ce téléphone.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutHealthWarning.
  ///
  /// In fr, this message translates to:
  /// **'L\'abus d\'alcool est dangereux pour la santé, à consommer avec modération.'**
  String get aboutHealthWarning;

  /// No description provided for @aboutReferenceData.
  ///
  /// In fr, this message translates to:
  /// **'Référentiels : pays selon ISO 3166-1. Appellations, régions et cépages : listes provisoires, à remplacer par les données ouvertes de l\'INAO.'**
  String get aboutReferenceData;

  /// No description provided for @aboutDemoNotice.
  ///
  /// In fr, this message translates to:
  /// **'Les domaines du jeu de démonstration sont inventés.'**
  String get aboutDemoNotice;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, domaine, appellation, cépage…'**
  String get searchHint;

  /// No description provided for @closeSearch.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la recherche'**
  String get closeSearch;

  /// No description provided for @sort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sort;

  /// No description provided for @filters.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filters;

  /// No description provided for @cardView.
  ///
  /// In fr, this message translates to:
  /// **'Vue cartes'**
  String get cardView;

  /// No description provided for @compactView.
  ///
  /// In fr, this message translates to:
  /// **'Vue compacte'**
  String get compactView;

  /// No description provided for @activeFilters.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 filtre actif} other{{count} filtres actifs}}'**
  String activeFilters(int count);

  /// No description provided for @resetFilters.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get resetFilters;

  /// No description provided for @sortChip.
  ///
  /// In fr, this message translates to:
  /// **'Tri {rank} : {criterion} ({direction})'**
  String sortChip(int rank, String criterion, String direction);

  /// No description provided for @sortAscending.
  ///
  /// In fr, this message translates to:
  /// **'A-Z'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In fr, this message translates to:
  /// **'Z-A'**
  String get sortDescending;

  /// No description provided for @sortFirst.
  ///
  /// In fr, this message translates to:
  /// **'Tri 1'**
  String get sortFirst;

  /// No description provided for @sortSecond.
  ///
  /// In fr, this message translates to:
  /// **'Tri 2'**
  String get sortSecond;

  /// No description provided for @sortNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get sortNone;

  /// No description provided for @sortDirection.
  ///
  /// In fr, this message translates to:
  /// **'Ordre décroissant'**
  String get sortDirection;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @sortVintage.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get sortVintage;

  /// No description provided for @sortColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get sortColor;

  /// No description provided for @sortParkerScore.
  ///
  /// In fr, this message translates to:
  /// **'Note Parker'**
  String get sortParkerScore;

  /// No description provided for @sortBestScore.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure note'**
  String get sortBestScore;

  /// No description provided for @sortName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get sortName;

  /// No description provided for @sortProducer.
  ///
  /// In fr, this message translates to:
  /// **'Domaine'**
  String get sortProducer;

  /// No description provided for @sortCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get sortCountry;

  /// No description provided for @sortRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get sortRegion;

  /// No description provided for @sortAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get sortAppellation;

  /// No description provided for @sortOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get sortOwner;

  /// No description provided for @sortLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get sortLocation;

  /// No description provided for @sortPurchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get sortPurchasePrice;

  /// No description provided for @sortMarketValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur marché'**
  String get sortMarketValue;

  /// No description provided for @sortQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get sortQuantity;

  /// No description provided for @sortAddedAt.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'ajout'**
  String get sortAddedAt;

  /// No description provided for @sortGardeStart.
  ///
  /// In fr, this message translates to:
  /// **'Début de garde'**
  String get sortGardeStart;

  /// No description provided for @sortGardeEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de garde'**
  String get sortGardeEnd;

  /// No description provided for @sortGardePeak.
  ///
  /// In fr, this message translates to:
  /// **'Année d\'apogée'**
  String get sortGardePeak;

  /// No description provided for @sortCellarStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut de garde'**
  String get sortCellarStatus;

  /// No description provided for @groupUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get groupUnknown;

  /// No description provided for @groupSummary.
  ///
  /// In fr, this message translates to:
  /// **'{wines, plural, =1{1 vin} other{{wines} vins}} · {bottles, plural, =0{0 bouteille} =1{1 bouteille} other{{bottles} bouteilles}}'**
  String groupSummary(int wines, int bottles);

  /// No description provided for @stockInStock.
  ///
  /// In fr, this message translates to:
  /// **'En stock'**
  String get stockInStock;

  /// No description provided for @stockEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Épuisé'**
  String get stockEmpty;

  /// No description provided for @stockAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get stockAll;

  /// No description provided for @filterStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get filterStock;

  /// No description provided for @filterColors.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get filterColors;

  /// No description provided for @filterTypes.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get filterTypes;

  /// No description provided for @filterCountries.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get filterCountries;

  /// No description provided for @filterRegions.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get filterRegions;

  /// No description provided for @filterAppellations.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get filterAppellations;

  /// No description provided for @filterVintages.
  ///
  /// In fr, this message translates to:
  /// **'Millésimes'**
  String get filterVintages;

  /// No description provided for @filterOwners.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get filterOwners;

  /// No description provided for @filterLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement (avec ses sous-emplacements)'**
  String get filterLocation;

  /// No description provided for @filterStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Statut de garde'**
  String get filterStatuses;

  /// No description provided for @filterIdealYear.
  ///
  /// In fr, this message translates to:
  /// **'Année de consommation idéale'**
  String get filterIdealYear;

  /// No description provided for @filterMinScore.
  ///
  /// In fr, this message translates to:
  /// **'Note minimale (sur 100)'**
  String get filterMinScore;

  /// No description provided for @filterPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get filterPrice;

  /// No description provided for @filterGrapes.
  ///
  /// In fr, this message translates to:
  /// **'Cépage'**
  String get filterGrapes;

  /// No description provided for @filterEnrichment.
  ///
  /// In fr, this message translates to:
  /// **'Statut d\'enrichissement'**
  String get filterEnrichment;

  /// No description provided for @filterFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris uniquement'**
  String get filterFavorites;

  /// No description provided for @rangeFrom.
  ///
  /// In fr, this message translates to:
  /// **'De'**
  String get rangeFrom;

  /// No description provided for @rangeTo.
  ///
  /// In fr, this message translates to:
  /// **'À'**
  String get rangeTo;

  /// No description provided for @anyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Tous les emplacements'**
  String get anyLocation;

  /// No description provided for @statusTooYoung.
  ///
  /// In fr, this message translates to:
  /// **'Trop jeune'**
  String get statusTooYoung;

  /// No description provided for @statusToDrink.
  ///
  /// In fr, this message translates to:
  /// **'À boire'**
  String get statusToDrink;

  /// No description provided for @statusPeak.
  ///
  /// In fr, this message translates to:
  /// **'Apogée'**
  String get statusPeak;

  /// No description provided for @statusDrinkSoon.
  ///
  /// In fr, this message translates to:
  /// **'À boire vite'**
  String get statusDrinkSoon;

  /// No description provided for @statusPast.
  ///
  /// In fr, this message translates to:
  /// **'Passé'**
  String get statusPast;

  /// No description provided for @statusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Garde inconnue'**
  String get statusUnknown;

  /// No description provided for @enrichBrouillon.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get enrichBrouillon;

  /// No description provided for @enrichAEnrichir.
  ///
  /// In fr, this message translates to:
  /// **'À enrichir'**
  String get enrichAEnrichir;

  /// No description provided for @enrichEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Enrichissement en cours'**
  String get enrichEnCours;

  /// No description provided for @enrichAValider.
  ///
  /// In fr, this message translates to:
  /// **'À valider'**
  String get enrichAValider;

  /// No description provided for @enrichValide.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get enrichValide;

  /// No description provided for @enrichErreur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'enrichissement'**
  String get enrichErreur;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vin ne correspond.'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In fr, this message translates to:
  /// **'Modifiez la recherche ou les filtres.'**
  String get noResultsBody;

  /// No description provided for @selectionCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 sélectionné} other{{count} sélectionnés}}'**
  String selectionCount(int count);

  /// No description provided for @cancelSelection.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la sélection'**
  String get cancelSelection;

  /// No description provided for @moveSelection.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer'**
  String get moveSelection;

  /// No description provided for @changeOwnerSelection.
  ///
  /// In fr, this message translates to:
  /// **'Changer de propriétaire'**
  String get changeOwnerSelection;

  /// No description provided for @selectionDone.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fiche mise à jour} other{{count} fiches mises à jour}}'**
  String selectionDone(int count);

  /// No description provided for @laterPdf.
  ///
  /// In fr, this message translates to:
  /// **'PDF (lot 3)'**
  String get laterPdf;

  /// No description provided for @laterExcel.
  ///
  /// In fr, this message translates to:
  /// **'Export Excel (lot 3)'**
  String get laterExcel;

  /// No description provided for @laterEnrich.
  ///
  /// In fr, this message translates to:
  /// **'Ré-enrichir (lot 2a)'**
  String get laterEnrich;

  /// No description provided for @laterPrices.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir les prix (lot 2c)'**
  String get laterPrices;

  /// No description provided for @openOneBottle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir 1 bouteille'**
  String get openOneBottle;

  /// No description provided for @bottleOpened.
  ///
  /// In fr, this message translates to:
  /// **'1 bouteille ouverte : {name}'**
  String bottleOpened(String name);

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get undo;

  /// No description provided for @noStockToOpen.
  ///
  /// In fr, this message translates to:
  /// **'Plus aucune bouteille à ouvrir.'**
  String get noStockToOpen;

  /// No description provided for @favorite.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get favorite;

  /// No description provided for @externalBackupReminder.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde exportée depuis 30 jours.'**
  String get externalBackupReminder;

  /// No description provided for @exportNow.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exportNow;

  /// No description provided for @mvtEntry.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get mvtEntry;

  /// No description provided for @mvtOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get mvtOpening;

  /// No description provided for @mvtOtherExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get mvtOtherExit;

  /// No description provided for @mvtAdjustment.
  ///
  /// In fr, this message translates to:
  /// **'Ajustement'**
  String get mvtAdjustment;

  /// No description provided for @mvtTransferOut.
  ///
  /// In fr, this message translates to:
  /// **'Transfert sortant'**
  String get mvtTransferOut;

  /// No description provided for @mvtTransferIn.
  ///
  /// In fr, this message translates to:
  /// **'Transfert entrant'**
  String get mvtTransferIn;

  /// No description provided for @parkerInitial.
  ///
  /// In fr, this message translates to:
  /// **'P'**
  String get parkerInitial;

  /// No description provided for @scoreSemantics.
  ///
  /// In fr, this message translates to:
  /// **'note {score}'**
  String scoreSemantics(String score);

  /// No description provided for @selected.
  ///
  /// In fr, this message translates to:
  /// **'sélectionné'**
  String get selected;

  /// No description provided for @wineNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette fiche n\'existe plus.'**
  String get wineNotFound;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @deleteWineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette fiche ?'**
  String get deleteWineTitle;

  /// No description provided for @deleteWineBody.
  ///
  /// In fr, this message translates to:
  /// **'La fiche et ses lots quittent la liste. L\'historique des mouvements est conservé.'**
  String get deleteWineBody;

  /// No description provided for @wineDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Fiche supprimée.'**
  String get wineDeleted;

  /// No description provided for @remaining.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 restante} =1{1 restante} other{{count} restantes}}'**
  String remaining(int count);

  /// No description provided for @consumed.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 consommée} =1{1 consommée} other{{count} consommées}}'**
  String consumed(int count);

  /// No description provided for @formatCl.
  ///
  /// In fr, this message translates to:
  /// **'{format} cl'**
  String formatCl(String format);

  /// No description provided for @addBottles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Ajouter 1 bouteille} other{Ajouter {count} bouteilles}}'**
  String addBottles(int count);

  /// No description provided for @openBottles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Ouvrir 1 bouteille} other{Ouvrir {count} bouteilles}}'**
  String openBottles(int count);

  /// No description provided for @decrease.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get increase;

  /// No description provided for @tabInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get tabInfo;

  /// No description provided for @tabOperations.
  ///
  /// In fr, this message translates to:
  /// **'Opérations'**
  String get tabOperations;

  /// No description provided for @tabTastings.
  ///
  /// In fr, this message translates to:
  /// **'Dégustations'**
  String get tabTastings;

  /// No description provided for @tabPrices.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get tabPrices;

  /// No description provided for @sectionOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Origine'**
  String get sectionOrigin;

  /// No description provided for @sectionCellar.
  ///
  /// In fr, this message translates to:
  /// **'Cave'**
  String get sectionCellar;

  /// No description provided for @sectionWine.
  ///
  /// In fr, this message translates to:
  /// **'Vin'**
  String get sectionWine;

  /// No description provided for @sectionComments.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get sectionComments;

  /// No description provided for @fieldCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get fieldCountry;

  /// No description provided for @fieldRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get fieldRegion;

  /// No description provided for @fieldSubRegion.
  ///
  /// In fr, this message translates to:
  /// **'Sous-région'**
  String get fieldSubRegion;

  /// No description provided for @fieldAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get fieldAppellation;

  /// No description provided for @fieldQualitySign.
  ///
  /// In fr, this message translates to:
  /// **'Signe de qualité'**
  String get fieldQualitySign;

  /// No description provided for @fieldClassification.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get fieldClassification;

  /// No description provided for @fieldLieuDit.
  ///
  /// In fr, this message translates to:
  /// **'Lieu-dit'**
  String get fieldLieuDit;

  /// No description provided for @fieldProducer.
  ///
  /// In fr, this message translates to:
  /// **'Domaine'**
  String get fieldProducer;

  /// No description provided for @fieldCuvee.
  ///
  /// In fr, this message translates to:
  /// **'Cuvée'**
  String get fieldCuvee;

  /// No description provided for @fieldColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get fieldColor;

  /// No description provided for @fieldType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldCertification.
  ///
  /// In fr, this message translates to:
  /// **'Certification'**
  String get fieldCertification;

  /// No description provided for @fieldVintage.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get fieldVintage;

  /// No description provided for @fieldVintageHint.
  ///
  /// In fr, this message translates to:
  /// **'Année sur 4 chiffres, ou NM'**
  String get fieldVintageHint;

  /// No description provided for @fieldGrapes.
  ///
  /// In fr, this message translates to:
  /// **'Cépages'**
  String get fieldGrapes;

  /// No description provided for @fieldAlcohol.
  ///
  /// In fr, this message translates to:
  /// **'Degré (%)'**
  String get fieldAlcohol;

  /// No description provided for @fieldGarde.
  ///
  /// In fr, this message translates to:
  /// **'Garde'**
  String get fieldGarde;

  /// No description provided for @fieldGardeStart.
  ///
  /// In fr, this message translates to:
  /// **'À boire à partir de'**
  String get fieldGardeStart;

  /// No description provided for @fieldGardePeak.
  ///
  /// In fr, this message translates to:
  /// **'Apogée'**
  String get fieldGardePeak;

  /// No description provided for @fieldGardeEnd.
  ///
  /// In fr, this message translates to:
  /// **'À boire avant'**
  String get fieldGardeEnd;

  /// No description provided for @fieldPairings.
  ///
  /// In fr, this message translates to:
  /// **'Accords mets et vins'**
  String get fieldPairings;

  /// No description provided for @fieldScores.
  ///
  /// In fr, this message translates to:
  /// **'Notes critiques'**
  String get fieldScores;

  /// No description provided for @fieldEan.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres EAN'**
  String get fieldEan;

  /// No description provided for @fieldLwin.
  ///
  /// In fr, this message translates to:
  /// **'LWIN'**
  String get fieldLwin;

  /// No description provided for @fieldProducerSite.
  ///
  /// In fr, this message translates to:
  /// **'Site officiel'**
  String get fieldProducerSite;

  /// No description provided for @fieldProducerComment.
  ///
  /// In fr, this message translates to:
  /// **'Le domaine'**
  String get fieldProducerComment;

  /// No description provided for @fieldVintageComment.
  ///
  /// In fr, this message translates to:
  /// **'Le millésime'**
  String get fieldVintageComment;

  /// No description provided for @fieldPersonalComment.
  ///
  /// In fr, this message translates to:
  /// **'Mon commentaire'**
  String get fieldPersonalComment;

  /// No description provided for @fieldLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get fieldLocation;

  /// No description provided for @fieldPositions.
  ///
  /// In fr, this message translates to:
  /// **'Positions'**
  String get fieldPositions;

  /// No description provided for @fieldPositionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Cases de la grille, ex. A3, B5'**
  String get fieldPositionsHint;

  /// No description provided for @fieldOwners.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaires'**
  String get fieldOwners;

  /// No description provided for @fieldOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get fieldOwner;

  /// No description provided for @fieldQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get fieldQuantity;

  /// No description provided for @fieldFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get fieldFormat;

  /// No description provided for @fieldUnitPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat unitaire TTC'**
  String get fieldUnitPrice;

  /// No description provided for @fieldPurchaseDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'achat'**
  String get fieldPurchaseDate;

  /// No description provided for @fieldSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get fieldSupplier;

  /// No description provided for @fieldFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get fieldFavorite;

  /// No description provided for @gardeRange.
  ///
  /// In fr, this message translates to:
  /// **'{start} → {end}'**
  String gardeRange(String start, String end);

  /// No description provided for @gardeEstimated.
  ///
  /// In fr, this message translates to:
  /// **'estimée'**
  String get gardeEstimated;

  /// No description provided for @ownerShare.
  ///
  /// In fr, this message translates to:
  /// **'{name} {count}'**
  String ownerShare(String name, int count);

  /// No description provided for @emptyValue.
  ///
  /// In fr, this message translates to:
  /// **'-'**
  String get emptyValue;

  /// No description provided for @citedBy.
  ///
  /// In fr, this message translates to:
  /// **'cité par {site}'**
  String citedBy(String site);

  /// No description provided for @noMovements.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get noMovements;

  /// No description provided for @movementLine.
  ///
  /// In fr, this message translates to:
  /// **'{type} · {quantity}'**
  String movementLine(String type, String quantity);

  /// No description provided for @movementDetail.
  ///
  /// In fr, this message translates to:
  /// **'{date} · {lot}'**
  String movementDetail(String date, String lot);

  /// No description provided for @noTastings.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dégustation notée.'**
  String get noTastings;

  /// No description provided for @addTasting.
  ///
  /// In fr, this message translates to:
  /// **'Noter une dégustation'**
  String get addTasting;

  /// No description provided for @tastingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dégustation'**
  String get tastingTitle;

  /// No description provided for @tastingScore.
  ///
  /// In fr, this message translates to:
  /// **'Ma note (sur {scale})'**
  String tastingScore(int scale);

  /// No description provided for @tastingDish.
  ///
  /// In fr, this message translates to:
  /// **'Plat servi'**
  String get tastingDish;

  /// No description provided for @tastingComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get tastingComment;

  /// No description provided for @tastingPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Noter cette dégustation ?'**
  String get tastingPrompt;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @tastingSaved.
  ///
  /// In fr, this message translates to:
  /// **'Dégustation enregistrée.'**
  String get tastingSaved;

  /// No description provided for @purchasePrices.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat par lot'**
  String get purchasePrices;

  /// No description provided for @marketPrices.
  ///
  /// In fr, this message translates to:
  /// **'Prix marché'**
  String get marketPrices;

  /// No description provided for @noPurchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat inconnu'**
  String get noPurchasePrice;

  /// No description provided for @noMarketPrice.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prix marché relevé. Le relevé automatique arrive au lot 2c.'**
  String get noMarketPrice;

  /// No description provided for @lastMarketPrice.
  ///
  /// In fr, this message translates to:
  /// **'Dernier prix : {price} le {date}'**
  String lastMarketPrice(String price, String date);

  /// No description provided for @priceNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Non trouvé le {date}'**
  String priceNotFound(String date);

  /// No description provided for @refreshPrice.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get refreshPrice;

  /// No description provided for @refreshPriceLater.
  ///
  /// In fr, this message translates to:
  /// **'Le relevé des prix marché arrive au lot 2c.'**
  String get refreshPriceLater;

  /// No description provided for @lots.
  ///
  /// In fr, this message translates to:
  /// **'Lots'**
  String get lots;

  /// No description provided for @lotLine.
  ///
  /// In fr, this message translates to:
  /// **'{owner} · {format} cl · {count}'**
  String lotLine(String owner, String format, int count);

  /// No description provided for @noLocation.
  ///
  /// In fr, this message translates to:
  /// **'Sans emplacement'**
  String get noLocation;

  /// No description provided for @chooseLot.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le lot'**
  String get chooseLot;

  /// No description provided for @adjustStock.
  ///
  /// In fr, this message translates to:
  /// **'Corriger le stock'**
  String get adjustStock;

  /// No description provided for @adjustTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quantité réelle du lot'**
  String get adjustTitle;

  /// No description provided for @adjustReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get adjustReason;

  /// No description provided for @adjustDone.
  ///
  /// In fr, this message translates to:
  /// **'{delta, plural, =0{Aucun écart} other{Écart corrigé : {delta}}}'**
  String adjustDone(int delta);

  /// No description provided for @noDifference.
  ///
  /// In fr, this message translates to:
  /// **'Aucun écart, rien à corriger.'**
  String get noDifference;

  /// No description provided for @transfer.
  ///
  /// In fr, this message translates to:
  /// **'Transférer'**
  String get transfer;

  /// No description provided for @transferTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transférer des bouteilles'**
  String get transferTitle;

  /// No description provided for @transferDone.
  ///
  /// In fr, this message translates to:
  /// **'Transfert enregistré.'**
  String get transferDone;

  /// No description provided for @newLot.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau lot'**
  String get newLot;

  /// No description provided for @restock.
  ///
  /// In fr, this message translates to:
  /// **'Réapprovisionner'**
  String get restock;

  /// No description provided for @stockAdded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille ajoutée} other{{count} bouteilles ajoutées}}'**
  String stockAdded(int count);

  /// No description provided for @stockOpened.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille ouverte} other{{count} bouteilles ouvertes}}'**
  String stockOpened(int count);

  /// No description provided for @stockErrorNegative.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant : le lot deviendrait négatif.'**
  String get stockErrorNegative;

  /// No description provided for @stockErrorReason.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un motif.'**
  String get stockErrorReason;

  /// No description provided for @stockErrorSameLot.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un autre emplacement ou propriétaire.'**
  String get stockErrorSameLot;

  /// No description provided for @stockErrorOther.
  ///
  /// In fr, this message translates to:
  /// **'Opération refusée.'**
  String get stockErrorOther;

  /// No description provided for @whereIsIt.
  ///
  /// In fr, this message translates to:
  /// **'Où est-il ?'**
  String get whereIsIt;

  /// No description provided for @newWineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau vin'**
  String get newWineTitle;

  /// No description provided for @editWineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get editWineTitle;

  /// No description provided for @firstLot.
  ///
  /// In fr, this message translates to:
  /// **'Premier lot'**
  String get firstLot;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get errorRequired;

  /// No description provided for @errorVintage.
  ///
  /// In fr, this message translates to:
  /// **'Millésime entre 1900 et l\'année en cours, ou NM'**
  String get errorVintage;

  /// No description provided for @errorAlcohol.
  ///
  /// In fr, this message translates to:
  /// **'Degré entre 5 et 23'**
  String get errorAlcohol;

  /// No description provided for @errorGardeOrder.
  ///
  /// In fr, this message translates to:
  /// **'Il faut millésime ≤ début ≤ apogée ≤ fin'**
  String get errorGardeOrder;

  /// No description provided for @errorEan.
  ///
  /// In fr, this message translates to:
  /// **'13 chiffres avec une clé de contrôle valide'**
  String get errorEan;

  /// No description provided for @errorLwin.
  ///
  /// In fr, this message translates to:
  /// **'7 ou 11 chiffres'**
  String get errorLwin;

  /// No description provided for @errorGrapesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Le total des pourcentages doit faire 100 %'**
  String get errorGrapesTotal;

  /// No description provided for @errorPositions.
  ///
  /// In fr, this message translates to:
  /// **'Positions invalides pour cette grille'**
  String get errorPositions;

  /// No description provided for @errorNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre attendu'**
  String get errorNumber;

  /// No description provided for @duplicateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce vin existe déjà'**
  String get duplicateTitle;

  /// No description provided for @duplicateBody.
  ///
  /// In fr, this message translates to:
  /// **'Une fiche porte déjà ce domaine, cette cuvée et ce millésime. L\'ouvrir pour ajouter des bouteilles ?'**
  String get duplicateBody;

  /// No description provided for @openExisting.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la fiche'**
  String get openExisting;

  /// No description provided for @createAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Créer quand même'**
  String get createAnyway;

  /// No description provided for @wineSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fiche enregistrée.'**
  String get wineSaved;

  /// No description provided for @choose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get choose;

  /// No description provided for @none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get none;

  /// No description provided for @searchList.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans la liste'**
  String get searchList;

  /// No description provided for @addToList.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter « {value} »'**
  String addToList(String value);

  /// No description provided for @addGrape.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un cépage'**
  String get addGrape;

  /// No description provided for @grapePercent.
  ///
  /// In fr, this message translates to:
  /// **'%'**
  String get grapePercent;

  /// No description provided for @removeGrape.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeGrape;

  /// No description provided for @addPairing.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un accord'**
  String get addPairing;

  /// No description provided for @selectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} choisis'**
  String selectedCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
