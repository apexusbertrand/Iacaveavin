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
}
