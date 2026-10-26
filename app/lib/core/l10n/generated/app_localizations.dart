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
  /// **'Aucun prix marché relevé pour l\'instant.'**
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
  /// **'Relever le prix'**
  String get refreshPrice;

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

  /// No description provided for @locationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun emplacement.'**
  String get locationsEmpty;

  /// No description provided for @locationsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez la cave, puis ses meubles, casiers et clayettes (4 niveaux).'**
  String get locationsEmptyBody;

  /// No description provided for @addLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un emplacement'**
  String get addLocation;

  /// No description provided for @addSubLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un sous-emplacement'**
  String get addSubLocation;

  /// No description provided for @editLocation.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'emplacement'**
  String get editLocation;

  /// No description provided for @deleteLocation.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'emplacement'**
  String get deleteLocation;

  /// No description provided for @locationName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get locationName;

  /// No description provided for @locationType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get locationType;

  /// No description provided for @locationRows.
  ///
  /// In fr, this message translates to:
  /// **'Lignes (1 à 26)'**
  String get locationRows;

  /// No description provided for @locationCols.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes (1 à 50)'**
  String get locationCols;

  /// No description provided for @locationCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Capacité (bouteilles)'**
  String get locationCapacity;

  /// No description provided for @locTypeCave.
  ///
  /// In fr, this message translates to:
  /// **'Cave'**
  String get locTypeCave;

  /// No description provided for @locTypeMeuble.
  ///
  /// In fr, this message translates to:
  /// **'Meuble'**
  String get locTypeMeuble;

  /// No description provided for @locTypeCasier.
  ///
  /// In fr, this message translates to:
  /// **'Casier'**
  String get locTypeCasier;

  /// No description provided for @locTypeClayette.
  ///
  /// In fr, this message translates to:
  /// **'Clayette'**
  String get locTypeClayette;

  /// No description provided for @locTypeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get locTypeAutre;

  /// No description provided for @locationFill.
  ///
  /// In fr, this message translates to:
  /// **'{bottles} / {capacity} · {percent} %'**
  String locationFill(int bottles, int capacity, int percent);

  /// No description provided for @locationBottles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Vide} =1{1 bouteille} other{{count} bouteilles}}'**
  String locationBottles(int count);

  /// No description provided for @overCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Au-delà de la capacité'**
  String get overCapacity;

  /// No description provided for @locationGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille {rows} × {cols}'**
  String locationGrid(int rows, int cols);

  /// No description provided for @errorDepth.
  ///
  /// In fr, this message translates to:
  /// **'4 niveaux au plus : cave, meuble, casier, clayette.'**
  String get errorDepth;

  /// No description provided for @errorGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille de 1 à 26 lignes et de 1 à 50 colonnes.'**
  String get errorGrid;

  /// No description provided for @errorNotEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Cet emplacement contient des bouteilles ou des sous-emplacements.'**
  String get errorNotEmpty;

  /// No description provided for @errorInUse.
  ///
  /// In fr, this message translates to:
  /// **'Valeur utilisée : suppression impossible.'**
  String get errorInUse;

  /// No description provided for @errorDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Cette valeur existe déjà.'**
  String get errorDuplicate;

  /// No description provided for @errorCsv.
  ///
  /// In fr, this message translates to:
  /// **'Fichier CSV invalide : rien n\'a été importé.'**
  String get errorCsv;

  /// No description provided for @locationWines.
  ///
  /// In fr, this message translates to:
  /// **'Vins rangés ici'**
  String get locationWines;

  /// No description provided for @highlightedPositions.
  ///
  /// In fr, this message translates to:
  /// **'Positions de ce vin : {positions}'**
  String highlightedPositions(String positions);

  /// No description provided for @inventory.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get inventory;

  /// No description provided for @inventoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire : {location}'**
  String inventoryTitle(String location);

  /// No description provided for @inventoryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get inventoryConfirm;

  /// No description provided for @inventoryCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get inventoryCorrect;

  /// No description provided for @inventoryNext.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement suivant'**
  String get inventoryNext;

  /// No description provided for @inventoryFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get inventoryFinish;

  /// No description provided for @inventoryReport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport d\'inventaire'**
  String get inventoryReport;

  /// No description provided for @inventoryReportLine.
  ///
  /// In fr, this message translates to:
  /// **'{wine} : {before} → {after}'**
  String inventoryReportLine(String wine, int before, int after);

  /// No description provided for @inventoryNoGap.
  ///
  /// In fr, this message translates to:
  /// **'Aucun écart : le stock est juste.'**
  String get inventoryNoGap;

  /// No description provided for @inventoryGaps.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 écart corrigé} other{{count} écarts corrigés}}'**
  String inventoryGaps(int count);

  /// No description provided for @inventoryProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} lots vérifiés'**
  String inventoryProgress(int done, int total);

  /// No description provided for @inventoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lot à vérifier ici.'**
  String get inventoryEmpty;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @settingsGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsGeneral;

  /// No description provided for @settingsCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get settingsCurrency;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Comme le téléphone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @settingsDefaultOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire par défaut'**
  String get settingsDefaultOwner;

  /// No description provided for @settingsDefaultLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement par défaut'**
  String get settingsDefaultLocation;

  /// No description provided for @settingsDefaultSort.
  ///
  /// In fr, this message translates to:
  /// **'Tri par défaut'**
  String get settingsDefaultSort;

  /// No description provided for @settingsDefaultSortSet.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser le tri actuel de la liste'**
  String get settingsDefaultSortSet;

  /// No description provided for @settingsScale.
  ///
  /// In fr, this message translates to:
  /// **'Échelle de mes notes'**
  String get settingsScale;

  /// No description provided for @scale20.
  ///
  /// In fr, this message translates to:
  /// **'Sur 20'**
  String get scale20;

  /// No description provided for @scale100.
  ///
  /// In fr, this message translates to:
  /// **'Sur 100'**
  String get scale100;

  /// No description provided for @settingsCardPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix affiché sur les cartes'**
  String get settingsCardPrice;

  /// No description provided for @cardPricePurchase.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get cardPricePurchase;

  /// No description provided for @cardPriceMarket.
  ///
  /// In fr, this message translates to:
  /// **'Valeur marché'**
  String get cardPriceMarket;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Apogée et fin d\'enrichissement (lots 2a et 4).'**
  String get settingsNotificationsHint;

  /// No description provided for @settingsAutoPrices.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchissement mensuel des prix'**
  String get settingsAutoPrices;

  /// No description provided for @settingsAutoPricesHint.
  ///
  /// In fr, this message translates to:
  /// **'Une fois par mois, les fiches sans relevé récent sont mises en file. Désactivé par défaut.'**
  String get settingsAutoPricesHint;

  /// No description provided for @settingsConnection.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au flux d\'enrichissement'**
  String get settingsConnection;

  /// No description provided for @settingsConnectionHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de l\'instance n8n et clé secrète partagée avec le flux.'**
  String get settingsConnectionHint;

  /// No description provided for @settingsPhotoSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace occupé par les photos'**
  String get settingsPhotoSpace;

  /// No description provided for @photoSpaceValue.
  ///
  /// In fr, this message translates to:
  /// **'{size}'**
  String photoSpaceValue(String size);

  /// No description provided for @settingsReference.
  ///
  /// In fr, this message translates to:
  /// **'Paramétrage'**
  String get settingsReference;

  /// No description provided for @settingsOwners.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaires'**
  String get settingsOwners;

  /// No description provided for @settingsLists.
  ///
  /// In fr, this message translates to:
  /// **'Listes de valeurs'**
  String get settingsLists;

  /// No description provided for @settingsGardeRules.
  ///
  /// In fr, this message translates to:
  /// **'Règles de garde'**
  String get settingsGardeRules;

  /// No description provided for @ownersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun propriétaire.'**
  String get ownersEmpty;

  /// No description provided for @addOwner.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un propriétaire'**
  String get addOwner;

  /// No description provided for @editOwner.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le propriétaire'**
  String get editOwner;

  /// No description provided for @ownerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get ownerName;

  /// No description provided for @ownerInitials.
  ///
  /// In fr, this message translates to:
  /// **'Initiales (2 à 3 lettres)'**
  String get ownerInitials;

  /// No description provided for @ownerDefault.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire par défaut'**
  String get ownerDefault;

  /// No description provided for @ownerBottles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune bouteille} =1{1 bouteille} other{{count} bouteilles}}'**
  String ownerBottles(int count);

  /// No description provided for @defaultBadge.
  ///
  /// In fr, this message translates to:
  /// **'par défaut'**
  String get defaultBadge;

  /// No description provided for @listCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 valeur} other{{count} valeurs}}'**
  String listCount(int count);

  /// No description provided for @listNameTypeVin.
  ///
  /// In fr, this message translates to:
  /// **'Types de vin'**
  String get listNameTypeVin;

  /// No description provided for @listNamePays.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get listNamePays;

  /// No description provided for @listNameRegion.
  ///
  /// In fr, this message translates to:
  /// **'Régions'**
  String get listNameRegion;

  /// No description provided for @listNameSousRegion.
  ///
  /// In fr, this message translates to:
  /// **'Sous-régions'**
  String get listNameSousRegion;

  /// No description provided for @listNameAppellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellations'**
  String get listNameAppellation;

  /// No description provided for @listNameSigneQualite.
  ///
  /// In fr, this message translates to:
  /// **'Signes de qualité'**
  String get listNameSigneQualite;

  /// No description provided for @listNameClassement.
  ///
  /// In fr, this message translates to:
  /// **'Classements'**
  String get listNameClassement;

  /// No description provided for @listNameCertification.
  ///
  /// In fr, this message translates to:
  /// **'Certifications'**
  String get listNameCertification;

  /// No description provided for @listNameCepage.
  ///
  /// In fr, this message translates to:
  /// **'Cépages'**
  String get listNameCepage;

  /// No description provided for @listNameFormat.
  ///
  /// In fr, this message translates to:
  /// **'Formats'**
  String get listNameFormat;

  /// No description provided for @listNameFournisseur.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get listNameFournisseur;

  /// No description provided for @listNameMotifMouvement.
  ///
  /// In fr, this message translates to:
  /// **'Motifs de mouvement'**
  String get listNameMotifMouvement;

  /// No description provided for @listNameAccordMets.
  ///
  /// In fr, this message translates to:
  /// **'Accords mets et vins'**
  String get listNameAccordMets;

  /// No description provided for @listNameCritique.
  ///
  /// In fr, this message translates to:
  /// **'Critiques'**
  String get listNameCritique;

  /// No description provided for @addValue.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une valeur'**
  String get addValue;

  /// No description provided for @renameValue.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get renameValue;

  /// No description provided for @deactivateValue.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get deactivateValue;

  /// No description provided for @activateValue.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get activateValue;

  /// No description provided for @mergeValue.
  ///
  /// In fr, this message translates to:
  /// **'Fusionner dans…'**
  String get mergeValue;

  /// No description provided for @mergeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fusionner « {from} » dans…'**
  String mergeTitle(String from);

  /// No description provided for @mergeDone.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs fusionnées, fiches re-pointées.'**
  String get mergeDone;

  /// No description provided for @deleteValue.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteValue;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'désactivée'**
  String get inactive;

  /// No description provided for @valueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get valueLabel;

  /// No description provided for @exportCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportCsv;

  /// No description provided for @importCsv.
  ///
  /// In fr, this message translates to:
  /// **'Importer un CSV'**
  String get importCsv;

  /// No description provided for @importDone.
  ///
  /// In fr, this message translates to:
  /// **'{created} créées, {updated} mises à jour'**
  String importDone(int created, int updated);

  /// No description provided for @gardeRulesPending.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs par défaut à valider'**
  String get gardeRulesPending;

  /// No description provided for @gardeRulesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Règles appliquées sur le téléphone quand aucune fenêtre n\'est fournie par un critique ou le domaine. Décalages en années après le millésime.'**
  String get gardeRulesIntro;

  /// No description provided for @gardeRuleLine.
  ///
  /// In fr, this message translates to:
  /// **'Début +{start} · apogée +{peak} · fin +{end}'**
  String gardeRuleLine(int start, int peak, int end);

  /// No description provided for @gardeRuleDefault.
  ///
  /// In fr, this message translates to:
  /// **'Règle par défaut'**
  String get gardeRuleDefault;

  /// No description provided for @backupIntro.
  ///
  /// In fr, this message translates to:
  /// **'La sauvegarde automatique d\'Android ne suffit pas pour les photos : exportez régulièrement une archive vers Drive, un mail ou un PC.'**
  String get backupIntro;

  /// No description provided for @backupExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter une archive sans photos'**
  String get backupExport;

  /// No description provided for @backupExportHint.
  ///
  /// In fr, this message translates to:
  /// **'Quelques Mo, à faire souvent.'**
  String get backupExportHint;

  /// No description provided for @backupExportFull.
  ///
  /// In fr, this message translates to:
  /// **'Exporter une archive complète'**
  String get backupExportFull;

  /// No description provided for @backupExportFullHint.
  ///
  /// In fr, this message translates to:
  /// **'Base et photos.'**
  String get backupExportFullHint;

  /// No description provided for @backupRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une archive'**
  String get backupRestore;

  /// No description provided for @backupRestoreHint.
  ///
  /// In fr, this message translates to:
  /// **'Remplace toute la cave par le contenu de l\'archive.'**
  String get backupRestoreHint;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette archive ?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreBody.
  ///
  /// In fr, this message translates to:
  /// **'Archive du {date}, {wines} fiches. La cave actuelle sera entièrement remplacée.'**
  String backupRestoreBody(String date, int wines);

  /// No description provided for @backupRestored.
  ///
  /// In fr, this message translates to:
  /// **'Archive restaurée.'**
  String get backupRestored;

  /// No description provided for @backupShared.
  ///
  /// In fr, this message translates to:
  /// **'Archive prête : choisissez où l\'envoyer.'**
  String get backupShared;

  /// No description provided for @backupAuto.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardes automatiques'**
  String get backupAuto;

  /// No description provided for @backupAutoHint.
  ///
  /// In fr, this message translates to:
  /// **'Une par semaine sur le téléphone, les 3 dernières conservées.'**
  String get backupAutoHint;

  /// No description provided for @backupAutoNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde automatique pour l\'instant.'**
  String get backupAutoNone;

  /// No description provided for @backupLastExternal.
  ///
  /// In fr, this message translates to:
  /// **'Dernier export : {date}'**
  String backupLastExternal(String date);

  /// No description provided for @backupNeverExported.
  ///
  /// In fr, this message translates to:
  /// **'Aucun export pour l\'instant.'**
  String get backupNeverExported;

  /// No description provided for @backupErrorArchive.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une archive IA cave à vin.'**
  String get backupErrorArchive;

  /// No description provided for @backupErrorNewer.
  ///
  /// In fr, this message translates to:
  /// **'Archive créée par une version plus récente de l\'application : mettez l\'application à jour.'**
  String get backupErrorNewer;

  /// No description provided for @backupErrorCorrupted.
  ///
  /// In fr, this message translates to:
  /// **'Archive endommagée : la cave n\'a pas été modifiée.'**
  String get backupErrorCorrupted;

  /// No description provided for @restoreFromAuto.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get restoreFromAuto;

  /// No description provided for @bottlesWithoutPrice.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille sans prix} other{{count} bouteilles sans prix}}'**
  String bottlesWithoutPrice(int count);

  /// No description provided for @addMenuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un vin'**
  String get addMenuTitle;

  /// No description provided for @addByPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photographier l\'étiquette'**
  String get addByPhoto;

  /// No description provided for @addByPhotoHint.
  ///
  /// In fr, this message translates to:
  /// **'1 à 4 photos, la fiche se remplit presque seule.'**
  String get addByPhotoHint;

  /// No description provided for @addByBarcode.
  ///
  /// In fr, this message translates to:
  /// **'Avec le code-barres'**
  String get addByBarcode;

  /// No description provided for @addByBarcodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Scanner l\'EAN puis photographier : il aide l\'identification.'**
  String get addByBarcodeHint;

  /// No description provided for @addManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle'**
  String get addManual;

  /// No description provided for @addManualHint.
  ///
  /// In fr, this message translates to:
  /// **'Remplir la fiche soi-même.'**
  String get addManualHint;

  /// No description provided for @addExcel.
  ///
  /// In fr, this message translates to:
  /// **'Import Excel'**
  String get addExcel;

  /// No description provided for @addExcelHint.
  ///
  /// In fr, this message translates to:
  /// **'Disponible au lot 3.'**
  String get addExcelHint;

  /// No description provided for @unidentifiedWine.
  ///
  /// In fr, this message translates to:
  /// **'Vin à identifier'**
  String get unidentifiedWine;

  /// No description provided for @captureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photos de la bouteille'**
  String get captureTitle;

  /// No description provided for @captureHint.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez l\'étiquette entière, bien droite, sans reflet. Ajoutez la contre-étiquette si elle porte le degré ou les cépages.'**
  String get captureHint;

  /// No description provided for @photoTypeEtiquette.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get photoTypeEtiquette;

  /// No description provided for @photoTypeContreEtiquette.
  ///
  /// In fr, this message translates to:
  /// **'Contre-étiquette'**
  String get photoTypeContreEtiquette;

  /// No description provided for @photoTypeCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Capsule'**
  String get photoTypeCapsule;

  /// No description provided for @photoTypeCollerette.
  ///
  /// In fr, this message translates to:
  /// **'Collerette'**
  String get photoTypeCollerette;

  /// No description provided for @photoTypeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get photoTypeAutre;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get fromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get removePhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get retakePhoto;

  /// No description provided for @keepPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Garder'**
  String get keepPhoto;

  /// No description provided for @photoBlurry.
  ///
  /// In fr, this message translates to:
  /// **'Photo floue : reprenez-la pour une meilleure lecture.'**
  String get photoBlurry;

  /// No description provided for @photoGlare.
  ///
  /// In fr, this message translates to:
  /// **'Reflet sur l\'étiquette : changez d\'angle ou évitez le flash.'**
  String get photoGlare;

  /// No description provided for @photoProcessing.
  ///
  /// In fr, this message translates to:
  /// **'Traitement de la photo…'**
  String get photoProcessing;

  /// No description provided for @photoUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Image illisible.'**
  String get photoUnreadable;

  /// No description provided for @eanField.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres EAN (facultatif)'**
  String get eanField;

  /// No description provided for @scanLive.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le code-barres'**
  String get scanLive;

  /// No description provided for @scanFromPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Lire le code-barres sur une photo'**
  String get scanFromPhoto;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez le code-barres de la contre-étiquette : il est lu tout seul.'**
  String get scanHint;

  /// No description provided for @scanFound.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres lu : {code}'**
  String scanFound(String code);

  /// No description provided for @scanNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun code-barres EAN lisible sur cette photo.'**
  String get scanNotFound;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès à l\'appareil photo refusé'**
  String get scanPermissionDenied;

  /// No description provided for @scanUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur de code-barres indisponible sur cet appareil'**
  String get scanUnavailable;

  /// No description provided for @scanUseField.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les 13 chiffres dans le champ.'**
  String get scanUseField;

  /// No description provided for @vintageHintField.
  ///
  /// In fr, this message translates to:
  /// **'Millésime si vous le connaissez (facultatif)'**
  String get vintageHintField;

  /// No description provided for @continueToEnrichment.
  ///
  /// In fr, this message translates to:
  /// **'Lancer l\'identification'**
  String get continueToEnrichment;

  /// No description provided for @needOnePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins une photo de l\'étiquette.'**
  String get needOnePhoto;

  /// No description provided for @consentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoi des photos'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In fr, this message translates to:
  /// **'Pour identifier le vin, les photos d\'étiquettes sont envoyées au flux d\'enrichissement d\'Apexus, lues, puis effacées après le traitement. Aucune autre donnée de votre cave n\'est envoyée.'**
  String get consentBody;

  /// No description provided for @consentAccept.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte'**
  String get consentAccept;

  /// No description provided for @consentRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get consentRefuse;

  /// No description provided for @consentRefused.
  ///
  /// In fr, this message translates to:
  /// **'Photos gardées sur le téléphone, fiche à compléter à la main.'**
  String get consentRefused;

  /// No description provided for @enrichTitle.
  ///
  /// In fr, this message translates to:
  /// **'Identification'**
  String get enrichTitle;

  /// No description provided for @enrichLotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pendant ce temps, le lot'**
  String get enrichLotTitle;

  /// No description provided for @saveLot.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le lot'**
  String get saveLot;

  /// No description provided for @lotSaved.
  ///
  /// In fr, this message translates to:
  /// **'Lot enregistré.'**
  String get lotSaved;

  /// No description provided for @stepWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get stepWaiting;

  /// No description provided for @stepLecture.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de l\'étiquette'**
  String get stepLecture;

  /// No description provided for @stepNormalisation.
  ///
  /// In fr, this message translates to:
  /// **'Mise en forme'**
  String get stepNormalisation;

  /// No description provided for @stepIdentification.
  ///
  /// In fr, this message translates to:
  /// **'Identification du vin'**
  String get stepIdentification;

  /// No description provided for @stepEnrichissement.
  ///
  /// In fr, this message translates to:
  /// **'Recherche des informations'**
  String get stepEnrichissement;

  /// No description provided for @stepNotes.
  ///
  /// In fr, this message translates to:
  /// **'Recherche des notes'**
  String get stepNotes;

  /// No description provided for @stepPrix.
  ///
  /// In fr, this message translates to:
  /// **'Recherche des prix'**
  String get stepPrix;

  /// No description provided for @stepControles.
  ///
  /// In fr, this message translates to:
  /// **'Contrôles'**
  String get stepControles;

  /// No description provided for @stepTermine.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get stepTermine;

  /// No description provided for @enrichOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : la fiche reste « à enrichir », l\'envoi partira au retour du réseau.'**
  String get enrichOffline;

  /// No description provided for @enrichReady.
  ///
  /// In fr, this message translates to:
  /// **'Propositions prêtes'**
  String get enrichReady;

  /// No description provided for @reviewProposals.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier les propositions'**
  String get reviewProposals;

  /// No description provided for @enrichFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'identification a échoué : {reason}'**
  String enrichFailed(String reason);

  /// No description provided for @enrichRetry.
  ///
  /// In fr, this message translates to:
  /// **'Relancer'**
  String get enrichRetry;

  /// No description provided for @enrichFinishedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Identification terminée : {name}'**
  String enrichFinishedSnack(String name);

  /// No description provided for @quotaLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Quota du mois épuisé} =1{Plus qu\'1 identification ce mois-ci} other{Plus que {count} identifications ce mois-ci}}'**
  String quotaLeft(int count);

  /// No description provided for @pendingJobs.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 identification en attente} other{{count} identifications en attente}}'**
  String pendingJobs(int count);

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'pas de réponse en 3 minutes'**
  String get errorTimeout;

  /// No description provided for @errorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'réponse non conforme du flux'**
  String get errorInvalid;

  /// No description provided for @validationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Propositions'**
  String get validationTitle;

  /// No description provided for @acceptAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout accepter et enregistrer'**
  String get acceptAll;

  /// No description provided for @saveValidation.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveValidation;

  /// No description provided for @accept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accept;

  /// No description provided for @modify.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get modify;

  /// No description provided for @reject.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get reject;

  /// No description provided for @accepted.
  ///
  /// In fr, this message translates to:
  /// **'Accepté'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get rejected;

  /// No description provided for @modified.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé : {value}'**
  String modified(String value);

  /// No description provided for @currentValue.
  ///
  /// In fr, this message translates to:
  /// **'Actuel : {value}'**
  String currentValue(String value);

  /// No description provided for @proposedValue.
  ///
  /// In fr, this message translates to:
  /// **'Proposé : {value}'**
  String proposedValue(String value);

  /// No description provided for @confidence.
  ///
  /// In fr, this message translates to:
  /// **'confiance {percent} %'**
  String confidence(int percent);

  /// No description provided for @lowConfidence.
  ///
  /// In fr, this message translates to:
  /// **'Confiance faible : vérifiez'**
  String get lowConfidence;

  /// No description provided for @notFound.
  ///
  /// In fr, this message translates to:
  /// **'Non trouvé : {reason}'**
  String notFound(String reason);

  /// No description provided for @lockedField.
  ///
  /// In fr, this message translates to:
  /// **'Saisi à la main : conservé'**
  String get lockedField;

  /// No description provided for @disagreement.
  ///
  /// In fr, this message translates to:
  /// **'Désaccord entre l\'étiquette et une source'**
  String get disagreement;

  /// No description provided for @duplicateFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce vin est déjà dans la cave.'**
  String get duplicateFound;

  /// No description provided for @duplicateMerge.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter ces bouteilles à la fiche existante'**
  String get duplicateMerge;

  /// No description provided for @scoresSection.
  ///
  /// In fr, this message translates to:
  /// **'Notes critiques'**
  String get scoresSection;

  /// No description provided for @pricesSection.
  ///
  /// In fr, this message translates to:
  /// **'Prix marché'**
  String get pricesSection;

  /// No description provided for @alertsSection.
  ///
  /// In fr, this message translates to:
  /// **'À savoir'**
  String get alertsSection;

  /// No description provided for @includePrices.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les prix relevés'**
  String get includePrices;

  /// No description provided for @keepScore.
  ///
  /// In fr, this message translates to:
  /// **'Garder cette note'**
  String get keepScore;

  /// No description provided for @priceFound.
  ///
  /// In fr, this message translates to:
  /// **'{price} · {offers} offres · {date}'**
  String priceFound(String price, int offers, String date);

  /// No description provided for @validationSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fiche validée.'**
  String get validationSaved;

  /// No description provided for @srcEtiquette.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get srcEtiquette;

  /// No description provided for @srcSiteOfficiel.
  ///
  /// In fr, this message translates to:
  /// **'Site officiel'**
  String get srcSiteOfficiel;

  /// No description provided for @srcOrganismeOfficiel.
  ///
  /// In fr, this message translates to:
  /// **'Organisme officiel'**
  String get srcOrganismeOfficiel;

  /// No description provided for @srcInterprofession.
  ///
  /// In fr, this message translates to:
  /// **'Interprofession'**
  String get srcInterprofession;

  /// No description provided for @srcCritique.
  ///
  /// In fr, this message translates to:
  /// **'Critique'**
  String get srcCritique;

  /// No description provided for @srcMarchand.
  ///
  /// In fr, this message translates to:
  /// **'Marchand'**
  String get srcMarchand;

  /// No description provided for @srcTiers.
  ///
  /// In fr, this message translates to:
  /// **'Autre site'**
  String get srcTiers;

  /// No description provided for @srcEstimation.
  ///
  /// In fr, this message translates to:
  /// **'Estimation'**
  String get srcEstimation;

  /// No description provided for @srcManuel.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle'**
  String get srcManuel;

  /// No description provided for @srcImport.
  ///
  /// In fr, this message translates to:
  /// **'Import'**
  String get srcImport;

  /// No description provided for @provenanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Provenance'**
  String get provenanceTitle;

  /// No description provided for @provenanceSource.
  ///
  /// In fr, this message translates to:
  /// **'Source : {source}'**
  String provenanceSource(String source);

  /// No description provided for @provenanceDate.
  ///
  /// In fr, this message translates to:
  /// **'Collecté le {date}'**
  String provenanceDate(String date);

  /// No description provided for @provenanceUrl.
  ///
  /// In fr, this message translates to:
  /// **'Lien : {url}'**
  String provenanceUrl(String url);

  /// No description provided for @copyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié.'**
  String get linkCopied;

  /// No description provided for @reportError.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une erreur'**
  String get reportError;

  /// No description provided for @reported.
  ///
  /// In fr, this message translates to:
  /// **'Signalé comme faux, à corriger'**
  String get reported;

  /// No description provided for @reportedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Erreur signalée : la valeur reste barrée jusqu\'à correction.'**
  String get reportedSnack;

  /// No description provided for @provenanceBadge.
  ///
  /// In fr, this message translates to:
  /// **'Voir la provenance'**
  String get provenanceBadge;

  /// No description provided for @aiWritten.
  ///
  /// In fr, this message translates to:
  /// **'Rédigé par IA à partir de {site}'**
  String aiWritten(String site);

  /// No description provided for @toValidateBanner.
  ///
  /// In fr, this message translates to:
  /// **'Propositions à valider'**
  String get toValidateBanner;

  /// No description provided for @enrichingBanner.
  ///
  /// In fr, this message translates to:
  /// **'Identification en cours'**
  String get enrichingBanner;

  /// No description provided for @toEnrichBanner.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'identification'**
  String get toEnrichBanner;

  /// No description provided for @errorBanner.
  ///
  /// In fr, this message translates to:
  /// **'Identification en échec'**
  String get errorBanner;

  /// No description provided for @duplicateVintage.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer pour un autre millésime'**
  String get duplicateVintage;

  /// No description provided for @duplicateVintageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau millésime'**
  String get duplicateVintageTitle;

  /// No description provided for @duplicateVintageDone.
  ///
  /// In fr, this message translates to:
  /// **'Fiche créée : seuls les champs du millésime sont à enrichir.'**
  String get duplicateVintageDone;

  /// No description provided for @reEnrich.
  ///
  /// In fr, this message translates to:
  /// **'Ré-enrichir'**
  String get reEnrich;

  /// No description provided for @reEnrichStarted.
  ///
  /// In fr, this message translates to:
  /// **'Ré-enrichissement lancé sur les champs non verrouillés.'**
  String get reEnrichStarted;

  /// No description provided for @reEnrichNoPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo sur cette fiche : ré-enrichissement impossible.'**
  String get reEnrichNoPhoto;

  /// No description provided for @unlockField.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller'**
  String get unlockField;

  /// No description provided for @unlocked.
  ///
  /// In fr, this message translates to:
  /// **'Champ déverrouillé : il pourra être proposé à nouveau.'**
  String get unlocked;

  /// No description provided for @settingsFakeFlux.
  ///
  /// In fr, this message translates to:
  /// **'Flux de démonstration'**
  String get settingsFakeFlux;

  /// No description provided for @settingsFakeFluxHint.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé tant qu\'aucune adresse de flux n\'est enregistrée : l\'app rejoue les exemples du contrat.'**
  String get settingsFakeFluxHint;

  /// No description provided for @fakeScenario.
  ///
  /// In fr, this message translates to:
  /// **'Scénario rejoué'**
  String get fakeScenario;

  /// No description provided for @scenarioDone.
  ///
  /// In fr, this message translates to:
  /// **'Identification complète'**
  String get scenarioDone;

  /// No description provided for @scenarioPartial.
  ///
  /// In fr, this message translates to:
  /// **'Résultat partiel avec désaccord'**
  String get scenarioPartial;

  /// No description provided for @scenarioCacheHit.
  ///
  /// In fr, this message translates to:
  /// **'Vin déjà connu (cache)'**
  String get scenarioCacheHit;

  /// No description provided for @scenarioQuota.
  ///
  /// In fr, this message translates to:
  /// **'Quota épuisé'**
  String get scenarioQuota;

  /// No description provided for @scenarioInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Réponse non conforme'**
  String get scenarioInvalid;

  /// No description provided for @scenarioNever.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réponse (délai)'**
  String get scenarioNever;

  /// No description provided for @simulateOffline.
  ///
  /// In fr, this message translates to:
  /// **'Simuler le mode avion'**
  String get simulateOffline;

  /// No description provided for @fluxUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du flux'**
  String get fluxUrl;

  /// No description provided for @fluxUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'https://votre-instance.app.n8n.cloud'**
  String get fluxUrlHint;

  /// No description provided for @fluxKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé secrète'**
  String get fluxKey;

  /// No description provided for @fluxKeyStored.
  ///
  /// In fr, this message translates to:
  /// **'Clé enregistrée dans le stockage sécurisé du téléphone'**
  String get fluxKeyStored;

  /// No description provided for @fluxKeyMissing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clé enregistrée'**
  String get fluxKeyMissing;

  /// No description provided for @fluxKeyReplace.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle clé (remplace l\'ancienne)'**
  String get fluxKeyReplace;

  /// No description provided for @fluxSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get fluxSave;

  /// No description provided for @fluxForget.
  ///
  /// In fr, this message translates to:
  /// **'Oublier la connexion'**
  String get fluxForget;

  /// No description provided for @fluxTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester la connexion'**
  String get fluxTest;

  /// No description provided for @fluxTesting.
  ///
  /// In fr, this message translates to:
  /// **'Test en cours…'**
  String get fluxTesting;

  /// No description provided for @fluxUsingReal.
  ///
  /// In fr, this message translates to:
  /// **'Vrai flux utilisé pour les enrichissements et les prix.'**
  String get fluxUsingReal;

  /// No description provided for @fluxUsingFake.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion enregistrée : le flux de démonstration est utilisé.'**
  String get fluxUsingFake;

  /// No description provided for @fluxTestOk.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie : flux joignable, clé acceptée (contrat {version}).'**
  String fluxTestOk(String version);

  /// No description provided for @fluxTestNotReady.
  ///
  /// In fr, this message translates to:
  /// **'Flux joignable, mais sa clé n\'est pas encore configurée côté n8n.'**
  String get fluxTestNotReady;

  /// No description provided for @fluxTestBadKey.
  ///
  /// In fr, this message translates to:
  /// **'Flux joignable, mais la clé est refusée : {message}'**
  String fluxTestBadKey(String message);

  /// No description provided for @fluxTestOffline.
  ///
  /// In fr, this message translates to:
  /// **'Flux injoignable : vérifiez l\'adresse et le réseau.'**
  String get fluxTestOffline;

  /// No description provided for @fluxTestInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Réponse inattendue du flux : vérifiez l\'adresse.'**
  String get fluxTestInvalid;

  /// No description provided for @fluxUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide : elle doit commencer par https://'**
  String get fluxUrlInvalid;

  /// No description provided for @fluxSaved.
  ///
  /// In fr, this message translates to:
  /// **'Connexion enregistrée.'**
  String get fluxSaved;

  /// No description provided for @fluxForgotten.
  ///
  /// In fr, this message translates to:
  /// **'Connexion oubliée : retour au flux de démonstration.'**
  String get fluxForgotten;

  /// No description provided for @pricesAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relever les prix de toute la cave'**
  String get pricesAllTitle;

  /// No description provided for @pricesAllHint.
  ///
  /// In fr, this message translates to:
  /// **'Fiches sans relevé depuis 24 heures.'**
  String get pricesAllHint;

  /// No description provided for @pricesAllConfirm.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune fiche à relever : toutes ont un relevé de moins de 24 heures.} =1{1 relevé sera envoyé au flux.} other{{count} relevés seront envoyés au flux.}}'**
  String pricesAllConfirm(int count);

  /// No description provided for @pricesQuotaLeft.
  ///
  /// In fr, this message translates to:
  /// **'Quota restant ce mois : {left} relevés.'**
  String pricesQuotaLeft(int left);

  /// No description provided for @pricesQuotaUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Quota restant inconnu : il s\'affichera après le premier relevé.'**
  String get pricesQuotaUnknown;

  /// No description provided for @pricesQueued.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun relevé ajouté.} =1{1 relevé mis en file.} other{{count} relevés mis en file.}}'**
  String pricesQueued(int count);

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @priceQueuedOne.
  ///
  /// In fr, this message translates to:
  /// **'Relevé du prix mis en file.'**
  String get priceQueuedOne;

  /// No description provided for @priceAlreadyQueued.
  ///
  /// In fr, this message translates to:
  /// **'Un relevé est déjà en cours pour cette fiche.'**
  String get priceAlreadyQueued;

  /// No description provided for @priceTooRecentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relevé récent'**
  String get priceTooRecentTitle;

  /// No description provided for @priceTooRecent.
  ///
  /// In fr, this message translates to:
  /// **'Le dernier relevé a moins de 24 heures. Forcer un nouveau relevé ?'**
  String get priceTooRecent;

  /// No description provided for @priceForce.
  ///
  /// In fr, this message translates to:
  /// **'Forcer'**
  String get priceForce;

  /// No description provided for @priceOffers.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune offre} =1{1 offre} other{{count} offres}}'**
  String priceOffers(int count);

  /// No description provided for @priceNatureMedian.
  ///
  /// In fr, this message translates to:
  /// **'médiane'**
  String get priceNatureMedian;

  /// No description provided for @priceNatureOffer.
  ///
  /// In fr, this message translates to:
  /// **'offre unique'**
  String get priceNatureOffer;

  /// No description provided for @priceTrendUp.
  ///
  /// In fr, this message translates to:
  /// **'En hausse de {percent} depuis le relevé précédent'**
  String priceTrendUp(String percent);

  /// No description provided for @priceTrendDown.
  ///
  /// In fr, this message translates to:
  /// **'En baisse de {percent} depuis le relevé précédent'**
  String priceTrendDown(String percent);

  /// No description provided for @priceTrendFlat.
  ///
  /// In fr, this message translates to:
  /// **'Stable depuis le relevé précédent'**
  String get priceTrendFlat;

  /// No description provided for @priceOpenOffer.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'offre sur {site}'**
  String priceOpenOffer(String site);

  /// No description provided for @priceChartLabel.
  ///
  /// In fr, this message translates to:
  /// **'Courbe des prix relevés'**
  String get priceChartLabel;

  /// No description provided for @priceHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des relevés'**
  String get priceHistory;

  /// No description provided for @photoTypeDegustation.
  ///
  /// In fr, this message translates to:
  /// **'Dégustation'**
  String get photoTypeDegustation;

  /// No description provided for @photoTypeRepas.
  ///
  /// In fr, this message translates to:
  /// **'Repas'**
  String get photoTypeRepas;

  /// No description provided for @photoTypeEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get photoTypeEvenement;

  /// No description provided for @tabPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get tabPhotos;

  /// No description provided for @libraryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo de dégustation ou de repas pour cette bouteille.'**
  String get libraryEmpty;

  /// No description provided for @libraryAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get libraryAdd;

  /// No description provided for @libraryTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type de photo'**
  String get libraryTypeTitle;

  /// No description provided for @libraryAdded.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée'**
  String get libraryAdded;

  /// No description provided for @photoDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get photoDelete;

  /// No description provided for @photoDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'La photo est effacée de l\'appareil.'**
  String get photoDeleteBody;

  /// No description provided for @photoDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Photo supprimée'**
  String get photoDeleted;

  /// No description provided for @photoCounter.
  ///
  /// In fr, this message translates to:
  /// **'{index} / {total}'**
  String photoCounter(int index, int total);

  /// No description provided for @photoOpen.
  ///
  /// In fr, this message translates to:
  /// **'Voir la photo {index}'**
  String photoOpen(int index);

  /// No description provided for @validationPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get validationPhotos;

  /// No description provided for @photoCroppedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Recadrée sur l\'étiquette'**
  String get photoCroppedLabel;

  /// No description provided for @photoWholeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo entière'**
  String get photoWholeLabel;

  /// No description provided for @cropAction.
  ///
  /// In fr, this message translates to:
  /// **'Recadrer'**
  String get cropAction;

  /// No description provided for @cropTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recadrer l\'étiquette'**
  String get cropTitle;

  /// No description provided for @cropHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser le cadre ou ses coins sur l\'étiquette.'**
  String get cropHint;

  /// No description provided for @cropWhole.
  ///
  /// In fr, this message translates to:
  /// **'Photo entière'**
  String get cropWhole;

  /// No description provided for @cropSaved.
  ///
  /// In fr, this message translates to:
  /// **'Cadre enregistré'**
  String get cropSaved;

  /// No description provided for @cropOriginalNote.
  ///
  /// In fr, this message translates to:
  /// **'La photo d\'origine est gardée jusqu\'à la validation de la fiche.'**
  String get cropOriginalNote;
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
