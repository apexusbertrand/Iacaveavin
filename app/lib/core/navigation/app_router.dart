import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/add/capture_screen.dart';
import '../../features/add/enrichment_screen.dart';
import '../../features/add/validation_screen.dart';
import '../../features/backup/backup_screen.dart';
import '../../features/locations/locations_screen.dart';
import '../../features/settings/reference_screens.dart';
import '../../features/placeholder/placeholder_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/wine_detail/wine_detail_screen.dart';
import '../../features/wine_edit/wine_edit_screen.dart';
import '../../features/wine_list/wine_list_screen.dart';
import 'destinations.dart';

/// NAV-02 : un lien `iacaveavin://fiche/<id>` arrive avec « fiche » en hôte ;
/// on le ramène au chemin `/fiche/<id>`.
String? deepLinkRedirect(Uri uri) {
  if (uri.scheme != 'iacaveavin') return null;
  final path = '/${uri.host}${uri.path}';
  return path == '/' ? '/' : path;
}

GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  redirect: (context, state) => deepLinkRedirect(state.uri),
  routes: [
    for (final d in AppDestination.values)
      GoRoute(
        path: d.path,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: _screenFor(d)),
      ),
    GoRoute(
      path: '/emplacements/:id',
      builder: (context, state) => LocationDetailScreen(
        locationId: state.pathParameters['id']!,
        highlightWineId: state.uri.queryParameters['fiche'],
      ),
    ),
    GoRoute(
      path: '/inventaire',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/parametres/proprietaires',
      builder: (context, state) => const OwnersScreen(),
    ),
    GoRoute(
      path: '/parametres/listes',
      builder: (context, state) => const ListsScreen(),
    ),
    GoRoute(
      path: '/parametres/listes/:list',
      builder: (context, state) =>
          ListValuesScreen(list: state.pathParameters['list']!),
    ),
    GoRoute(
      path: '/parametres/garde',
      builder: (context, state) => const GardeRulesScreen(),
    ),
    GoRoute(
      path: '/ajout/photo',
      builder: (context, state) =>
          CaptureScreen(focusEan: state.uri.queryParameters['ean'] == '1'),
    ),
    GoRoute(
      path: '/fiche/nouvelle',
      builder: (context, state) => const WineEditScreen(),
    ),
    // NAV-02 : iacaveavin://fiche/<id> arrive ici (lien profond).
    GoRoute(
      path: '/fiche/:id',
      builder: (context, state) =>
          WineDetailScreen(wineId: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'modifier',
          builder: (context, state) =>
              WineEditScreen(wineId: state.pathParameters['id']),
        ),
        GoRoute(
          path: 'identification',
          builder: (context, state) =>
              EnrichmentScreen(wineId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'validation',
          builder: (context, state) =>
              ValidationScreen(wineId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

Widget _screenFor(AppDestination d) => switch (d) {
  AppDestination.myWines => const WineListScreen(),
  AppDestination.settings => const SettingsScreen(),
  AppDestination.locations => const LocationsScreen(),
  AppDestination.backup => const BackupScreen(),
  AppDestination.about => const AboutScreen(),
  _ => PlaceholderScreen(destination: d),
};
