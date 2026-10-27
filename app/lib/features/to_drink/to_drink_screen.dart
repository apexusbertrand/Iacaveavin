import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/app_settings.dart';
import '../../domain/comfort.dart';
import '../wine_list/wine_card.dart';
import 'comfort_providers.dart';
import 'monthly_alert_banner.dart';

/// CMP-01, CMP-02, CMP-04, CMP-05 : vins à boire, alerte du mois, accords
/// inversés et historique des dégustations.
class ToDrinkScreen extends StatelessWidget {
  const ToDrinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navToDrink),
          bottom: TabBar(
            labelColor: context.palette.onAppBar,
            unselectedLabelColor: context.palette.onAppBar,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l.toDrinkTab),
              Tab(text: l.tastingsTab),
            ],
          ),
        ),
        drawer: const AppDrawer(current: AppDestination.toDrink),
        body: const TabBarView(children: [_ToDrinkTab(), _TastingsTab()]),
      ),
    );
  }
}

class _ToDrinkTab extends ConsumerStatefulWidget {
  const _ToDrinkTab();

  @override
  ConsumerState<_ToDrinkTab> createState() => _ToDrinkTabState();
}

class _ToDrinkTabState extends ConsumerState<_ToDrinkTab> {
  String? _dish;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = ref.watch(wineListProvider);
    final year = ref.watch(currentYearProvider);
    final labels = ref.watch(labelsProvider).value ?? const {};
    final settings = ref.watch(settingsProvider);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: settings.currency,
    );
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => MessageStateView(
        icon: Icons.error_outline,
        isError: true,
        title: l.operationFailed('$e'),
      ),
      data: (all) {
        final dishes = dishesAvailable(all, year).toList()
          ..sort(
            (a, b) => (labels['accord_mets:$a'] ?? a).compareTo(
              labels['accord_mets:$b'] ?? b,
            ),
          );
        final dish = dishes.contains(_dish) ? _dish : null;
        final wines = dish == null
            ? toDrinkList(all, year)
            : winesForDish(all, dish, year);
        return ListView.builder(
          key: const ValueKey('to-drink-list'),
          itemCount: wines.length + 1,
          itemBuilder: (context, i) {
            if (i > 0) {
              final w = wines[i - 1];
              return WineCard(
                item: w,
                currency: currency,
                showMarketPrice: settings.cardPrice == CardPrice.market,
                onTap: () => context.push('/fiche/${w.id}'),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MonthlyAlertBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.l,
                    SpacingTokens.m,
                    SpacingTokens.l,
                    0,
                  ),
                  child: Text(l.toDrinkHint, style: theme.textTheme.bodyMedium),
                ),
                if (dishes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.l),
                    child: DropdownButtonFormField<String?>(
                      key: const ValueKey('dish-pick'),
                      initialValue: dish,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.dishPick),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l.dishAny)),
                        for (final d in dishes)
                          DropdownMenuItem(
                            value: d,
                            child: Text(labels['accord_mets:$d'] ?? d),
                          ),
                      ],
                      onChanged: (v) => setState(() => _dish = v),
                    ),
                  ),
                if (dish != null && wines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.l,
                    ),
                    child: Text(
                      l.dishCount(wines.length),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                if (wines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.xl),
                    child: MessageStateView(
                      icon: Icons.event_available_outlined,
                      title: dish == null ? l.toDrinkEmpty : l.dishNoWine,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TastingsTab extends ConsumerWidget {
  const _TastingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scale = ref.watch(settingsProvider.select((s) => s.personalScale));
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return ref
        .watch(tastingsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => MessageStateView(
            icon: Icons.error_outline,
            isError: true,
            title: l.operationFailed('$e'),
          ),
          data: (list) => list.isEmpty
              ? MessageStateView(
                  icon: Icons.rate_review_outlined,
                  title: l.tastingsEmpty,
                )
              : ListView.separated(
                  key: const ValueKey('tastings-list'),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = list[i];
                    final day = DateTime.tryParse(t.date);
                    return ListTile(
                      leading: BottleIcon(fill: wineColor(t.colorCode).fill),
                      title: Text(
                        [
                          t.wineName,
                          t.vintage == 'NM' ? l.nonVintage : t.vintage,
                        ].join(' · '),
                      ),
                      subtitle: Text(
                        [
                          [
                            day == null ? t.date : date.format(day),
                            ?t.dish,
                            if (t.score != null)
                              l.tastingScoreValue(_n(t.score!), scale),
                          ].join(' · '),
                          ?t.comment,
                        ].join('\n'),
                      ),
                      isThreeLine: t.comment != null,
                      onTap: () => context.push('/fiche/${t.wineId}'),
                    );
                  },
                ),
        );
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');
}
