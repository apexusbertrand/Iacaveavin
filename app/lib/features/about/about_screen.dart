import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyLarge?.copyWith(
      color: context.palette.textSecondary,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.navAbout)),
      drawer: const AppDrawer(current: AppDestination.about),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.l),
        children: [
          Text(l.appTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: SpacingTokens.xs),
          Text(l.aboutVersion(appVersion), style: secondary),
          const SizedBox(height: SpacingTokens.l),
          Text(l.aboutDescription, style: theme.textTheme.bodyLarge),
          const SizedBox(height: SpacingTokens.xl),
          // NFR-17 : mention sanitaire obligatoire.
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: Text(
                l.aboutHealthWarning,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeightTokens.gras,
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Text(l.aboutReferenceData, style: secondary),
          const SizedBox(height: SpacingTokens.s),
          Text(l.aboutDemoNotice, style: secondary),
        ],
      ),
    );
  }
}
