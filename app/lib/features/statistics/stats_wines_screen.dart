import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../wine_list/wine_card.dart';

/// STA-04 : fiches d'une part ou d'une barre, dans l'ordre de la liste.
class StatsWinesScreen extends ConsumerWidget {
  const StatsWinesScreen({super.key, required this.title, required this.ids});

  final String title;
  final Set<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: settings.currency,
    );
    final all = ref.watch(wineListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
        ),
        data: (items) {
          final wines = items.where((w) => ids.contains(w.id)).toList();
          if (wines.isEmpty) {
            return MessageStateView(
              icon: Icons.search_off,
              title: l.statNoData,
            );
          }
          return ListView.builder(
            key: const ValueKey('stats-wines'),
            itemCount: wines.length,
            itemBuilder: (context, i) => WineCard(
              item: wines[i],
              currency: currency,
              onTap: () => context.push('/fiche/${wines[i].id}'),
            ),
          );
        },
      ),
    );
  }
}
