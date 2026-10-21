import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/placeholder/placeholder_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/wine_list/wine_list_screen.dart';
import 'destinations.dart';

GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    for (final d in AppDestination.values)
      GoRoute(
        path: d.path,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: _screenFor(d)),
      ),
  ],
);

Widget _screenFor(AppDestination d) => switch (d) {
  AppDestination.myWines => const WineListScreen(),
  AppDestination.settings => const SettingsScreen(),
  AppDestination.about => const AboutScreen(),
  _ => PlaceholderScreen(destination: d),
};
