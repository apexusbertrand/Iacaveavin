import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/settings_store.dart';
import '../../domain/comfort.dart';
import '../statistics/stats_wines_screen.dart';
import 'comfort_providers.dart';

/// CMP-02 : bandeau du premier lancement du mois, vins qui entrent en
/// apogée ou arrivent en fin de fenêtre. Fermé, il revient le mois suivant.
class MonthlyAlertBanner extends ConsumerWidget {
  const MonthlyAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(monthlyAlertProvider);
    if (alert == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('monthly-alert'),
      margin: const EdgeInsets.all(SpacingTokens.m),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: context.palette.primaryText,
                ),
                const SizedBox(width: SpacingTokens.s),
                Expanded(
                  child: Text(l.alertTitle, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l.alertBody(alert.peak.length, alert.ending.length).trim(),
              style: theme.textTheme.bodyMedium,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: SpacingTokens.s,
                children: [
                  TextButton(
                    key: const ValueKey('alert-dismiss'),
                    onPressed: () => ref
                        .read(settingsProvider.notifier)
                        .update(
                          (s) => s.copyWith(
                            alertSeenMonth: alertMonth(DateTime.now()),
                          ),
                        ),
                    child: Text(l.alertDismiss),
                  ),
                  FilledButton(
                    key: const ValueKey('alert-see'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StatsWinesScreen(
                          title: l.alertWinesTitle,
                          ids: alert.ids,
                        ),
                      ),
                    ),
                    child: Text(l.alertSee),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
