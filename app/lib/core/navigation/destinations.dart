import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Entrées du tiroir latéral (NAV-01), dans l'ordre des captures.
/// [lot] : lot qui livre l'écran ; null quand il est déjà disponible.
enum AppDestination {
  myWines('/', Icons.wine_bar_outlined, null),
  toDrink('/a-boire', Icons.event_available_outlined, '4'),
  locations('/emplacements', Icons.grid_view_outlined, '1'),
  statistics('/statistiques', Icons.pie_chart_outline, '3'),
  shoppingList('/liste-achats', Icons.shopping_cart_outlined, '4'),
  importExport('/import-export', Icons.import_export, '3'),
  backup('/sauvegarde', Icons.backup_outlined, '1'),
  settings('/parametres', Icons.settings_outlined, null),
  about('/a-propos', Icons.info_outline, null);

  const AppDestination(this.path, this.icon, this.lot);

  final String path;
  final IconData icon;
  final String? lot;

  String label(AppLocalizations l) => switch (this) {
    myWines => l.navMyWines,
    toDrink => l.navToDrink,
    locations => l.navLocations,
    statistics => l.navStatistics,
    shoppingList => l.navShoppingList,
    importExport => l.navImportExport,
    backup => l.navBackup,
    settings => l.navSettings,
    about => l.navAbout,
  };
}
