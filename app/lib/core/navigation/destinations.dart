import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Entrées du tiroir latéral (NAV-01), dans l'ordre des captures.
/// [lot] : lot qui livre l'écran ; null quand il est déjà disponible.
enum AppDestination {
  myWines('/', Icons.wine_bar_outlined),
  toDrink('/a-boire', Icons.event_available_outlined),
  locations('/emplacements', Icons.grid_view_outlined),
  statistics('/statistiques', Icons.pie_chart_outline),
  shoppingList('/liste-achats', Icons.shopping_cart_outlined),
  importExport('/import-export', Icons.import_export),
  backup('/sauvegarde', Icons.backup_outlined),
  settings('/parametres', Icons.settings_outlined),
  feedback('/remontee', Icons.feedback_outlined),
  about('/a-propos', Icons.info_outline);

  const AppDestination(this.path, this.icon);

  final String path;
  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    myWines => l.navMyWines,
    toDrink => l.navToDrink,
    locations => l.navLocations,
    statistics => l.navStatistics,
    shoppingList => l.navShoppingList,
    importExport => l.navImportExport,
    backup => l.navBackup,
    settings => l.navSettings,
    feedback => l.navFeedback,
    about => l.navAbout,
  };
}
