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
