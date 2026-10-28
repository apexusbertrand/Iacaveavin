import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/widgets/state_views.dart';

/// Écran d'une entrée du tiroir livrée par un lot ultérieur.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(destination.label(l))),
      drawer: AppDrawer(current: destination),
      body: MessageStateView(
        icon: destination.icon,
        title: l.placeholderTitle,
        body: l.placeholderBody(destination.lot ?? ''),
      ),
    );
  }
}
