import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.g.dart';
import 'destinations.dart';

/// Tiroir latéral commun à tous les écrans de premier niveau (NAV-01).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.current});

  final AppDestination current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = context.palette;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: palette.appBar),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                l.appTitle,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: palette.onAppBar),
              ),
            ),
          ),
          for (final d in AppDestination.values)
            ListTile(
              key: ValueKey('drawer-${d.name}'),
              leading: Icon(d.icon),
              title: Text(d.label(l)),
              selected: d == current,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.l,
              ),
              onTap: () {
                Navigator.of(context).pop();
                if (d != current) context.go(d.path);
              },
            ),
        ],
      ),
    );
  }
}
