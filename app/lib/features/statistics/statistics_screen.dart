import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/garde.dart';
import '../../domain/stats.dart';
import 'explorer_tab.dart';
import 'stat_chart.dart';
import 'stat_labels.dart';
import 'stats_providers.dart';
import 'stats_wines_screen.dart';

/// STA-04 : liste filtrée d'une part ou d'une barre.
void openStatWines(BuildContext context, String title, Set<String> ids) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatsWinesScreen(title: title, ids: ids),
      ),
    );

/// Contexte commun des onglets : faits, libellés, année et date du jour.
class StatContext {
  const StatContext({
    required this.facts,
    required this.labels,
    required this.year,
    required this.now,
  });

  final List<StatFact> facts;
  final StatLabels labels;
  final int year;
  final DateTime now;

  StatResult run(
    StatMeasure m,
    StatDimension d1, {
    StatDimension? d2,
    Map<StatDimension, Set<String>> filters = const {},
  }) => aggregate(
    facts,
    StatQuery(measure: m, dim1: d1, dim2: d2, filters: filters),
    year: year,
    now: now,
  );
}

/// STA-01 à STA-06 : tableaux prêts à l'emploi et explorateur.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final facts = ref.watch(statFactsProvider);
    final tabs = [
      l.statsTabGeneral,
      l.statsTabRegions,
      l.statsTabGarde,
      l.statsTabValue,
      l.statsTabBuying,
      l.statsTabExplorer,
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navStatistics),
          bottom: TabBar(
            isScrollable: true,
            labelColor: context.palette.onAppBar,
            unselectedLabelColor: context.palette.onAppBar,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [for (final t in tabs) Tab(text: t)],
          ),
        ),
        drawer: const AppDrawer(current: AppDestination.statistics),
        body: facts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => MessageStateView(
            icon: Icons.error_outline,
            isError: true,
            title: l.operationFailed('$e'),
            action: FilledButton(
              onPressed: () => ref.invalidate(statFactsProvider),
              child: Text(l.retry),
            ),
          ),
          data: (list) {
            if (!list.any((f) => f.bottles > 0 || f.openings.isNotEmpty)) {
              return MessageStateView(
                icon: Icons.pie_chart_outline,
                title: l.statsEmpty,
              );
            }
            final c = StatContext(
              facts: list,
              labels: StatLabels.of(
                context,
                labels: ref.watch(labelsProvider).value ?? const {},
                owners: ref.watch(ownersProvider).value ?? const [],
                locations: ref.watch(locationsProvider).value ?? const [],
                currency: ref.watch(settingsProvider.select((s) => s.currency)),
              ),
              year: ref.watch(currentYearProvider),
              now: DateTime.now(),
            );
            return TabBarView(
              children: [
                _GeneralTab(c),
                _RegionsTab(c),
                _GardeTab(c),
                _ValueTab(c),
                _BuyingTab(c),
                ExplorerTab(context: c),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StatSection extends StatelessWidget {
  const StatSection(this.title, this.child, {super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.l,
          SpacingTokens.xl,
          SpacingTokens.l,
          SpacingTokens.s,
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: context.palette.primaryText),
        ),
      ),
      child,
    ],
  );
}

/// Indicateur chiffré, ouvre la liste de ses fiches.
class StatKpi extends StatelessWidget {
  const StatKpi({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - SpacingTokens.l * 3) / 2,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: context.palette.primaryText,
                  ),
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _kpis(BuildContext context, List<Widget> children) => Padding(
  padding: const EdgeInsets.all(SpacingTokens.l),
  child: Wrap(
    spacing: SpacingTokens.s,
    runSpacing: SpacingTokens.s,
    children: children,
  ),
);

class _GeneralTab extends StatelessWidget {
  const _GeneralTab(this.c);

  final StatContext c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    StatKpi kpi(StatMeasure m) {
      final r = c.run(m, StatDimension.color);
      return StatKpi(
        key: ValueKey('kpi-${m.code}'),
        label: c.labels.measure(m),
        value: c.labels.value(m, r.total),
        onTap: () => openStatWines(context, c.labels.measure(m), r.wineIds),
      );
    }

    const byColor = StatQuery(
      measure: StatMeasure.bottles,
      dim1: StatDimension.color,
    );
    const vintageColor = StatQuery(
      measure: StatMeasure.bottles,
      dim1: StatDimension.vintage,
      dim2: StatDimension.color,
    );
    void open(String t, Set<String> ids) => openStatWines(context, t, ids);
    return ListView(
      key: const ValueKey('stats-general'),
      children: [
        _kpis(context, [
          kpi(StatMeasure.bottles),
          kpi(StatMeasure.references),
          kpi(StatMeasure.purchaseValue),
          kpi(StatMeasure.marketValue),
        ]),
        StatSection(
          l.statByColor,
          StatView(
            result: c.run(byColor.measure, byColor.dim1),
            query: byColor,
            chart: StatChart.donut,
            labels: c.labels,
            onOpen: open,
          ),
        ),
        StatSection(
          l.statVintageColor,
          StatView(
            result: c.run(
              vintageColor.measure,
              vintageColor.dim1,
              d2: vintageColor.dim2,
            ),
            query: vintageColor,
            chart: StatChart.stacked,
            labels: c.labels,
            onOpen: open,
          ),
        ),
      ],
    );
  }
}

/// Bouteilles par pays, puis région, puis appellation (zoom au tap).
class _RegionsTab extends StatefulWidget {
  const _RegionsTab(this.c);

  final StatContext c;

  @override
  State<_RegionsTab> createState() => _RegionsTabState();
}

class _RegionsTabState extends State<_RegionsTab> {
  String? _country;
  String? _region;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.c;
    final dim = _region != null
        ? StatDimension.appellation
        : _country != null
        ? StatDimension.region
        : StatDimension.country;
    final filters = {
      if (_country != null) StatDimension.country: {_country!},
      if (_region != null) StatDimension.region: {_region!},
    };
    final query = StatQuery(
      measure: StatMeasure.bottles,
      dim1: dim,
      filters: filters,
    );
    final r = c.run(query.measure, dim, filters: filters);
    final path = [
      if (_country != null) c.labels.key(StatDimension.country, _country!),
      if (_region != null) c.labels.key(StatDimension.region, _region!),
    ];
    return ListView(
      key: const ValueKey('stats-regions'),
      children: [
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: Text(l.statDrillHint),
        ),
        if (path.isNotEmpty)
          ListTile(
            key: const ValueKey('drill-up'),
            leading: const Icon(Icons.arrow_upward),
            title: Text(path.join(' > ')),
            subtitle: Text(l.statDrillUp),
            onTap: () => setState(() {
              if (_region != null) {
                _region = null;
              } else {
                _country = null;
              }
            }),
          ),
        StatSection(
          l.statByOrigin,
          StatView(
            result: r,
            query: query,
            chart: StatChart.barsHorizontal,
            labels: c.labels,
            onOpen: (title, ids) {
              final key = r.keys1.firstWhere(
                (k) => c.labels.key(dim, k) == title,
                orElse: () => noneKey,
              );
              if (dim == StatDimension.appellation || key == noneKey) {
                openStatWines(context, title, ids);
              } else {
                setState(() {
                  if (dim == StatDimension.country) {
                    _country = key;
                  } else {
                    _region = key;
                  }
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: OutlinedButton(
            key: const ValueKey('regions-see-wines'),
            onPressed: () => openStatWines(
              context,
              path.isEmpty ? l.statByOrigin : path.join(' > '),
              r.wineIds,
            ),
            child: Text(l.statSeeWines(r.wineIds.length)),
          ),
        ),
      ],
    );
  }
}

class _GardeTab extends StatelessWidget {
  const _GardeTab(this.c);

  final StatContext c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = c.run(StatMeasure.bottles, StatDimension.gardeStatus);
    StatKpi kpi(String key, String label, Set<String> codes) {
      final cells = status.cells.where((x) => codes.contains(x.k1));
      return StatKpi(
        key: ValueKey(key),
        label: label,
        value: c.labels.value(
          StatMeasure.bottles,
          cells.fold(0.0, (s, x) => s + x.value),
        ),
        onTap: () => openStatWines(context, label, {
          for (final x in cells) ...x.wineIds,
        }),
      );
    }

    const byYear = StatQuery(
      measure: StatMeasure.bottles,
      dim1: StatDimension.gardeStart,
    );
    const byStatus = StatQuery(
      measure: StatMeasure.bottles,
      dim1: StatDimension.gardeStatus,
    );
    void open(String t, Set<String> ids) => openStatWines(context, t, ids);
    return ListView(
      key: const ValueKey('stats-garde'),
      children: [
        _kpis(context, [
          kpi('kpi-this-year', l.statToDrinkThisYear, {
            CellarStatus.toDrink.code,
            CellarStatus.peak.code,
            CellarStatus.drinkSoon.code,
          }),
          kpi('kpi-soon', l.statDrinkSoon, {CellarStatus.drinkSoon.code}),
          kpi('kpi-past', l.statPast, {CellarStatus.past.code}),
        ]),
        StatSection(
          l.statGardeByYear,
          StatView(
            result: c.run(byYear.measure, byYear.dim1),
            query: byYear,
            chart: StatChart.barsVertical,
            labels: c.labels,
            onOpen: open,
          ),
        ),
        StatSection(
          l.statDimGardeStatus,
          StatView(
            result: status,
            query: byStatus,
            chart: StatChart.donut,
            labels: c.labels,
            onOpen: open,
          ),
        ),
      ],
    );
  }
}

class _ValueTab extends StatelessWidget {
  const _ValueTab(this.c);

  final StatContext c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget paired(StatDimension d, {int max = 10}) {
      final purchase = c.run(StatMeasure.purchaseValue, d);
      final market = c.run(StatMeasure.marketValue, d);
      final keys = {...purchase.keys1, ...market.keys1}.take(max).toList();
      return PairedBars(
        keys: keys,
        label: (k) => c.labels.key(d, k),
        a: purchase.valueOf,
        b: market.valueOf,
        nameA: l.statSeriesPurchase,
        nameB: l.statSeriesMarket,
        format: (v) => c.labels.value(StatMeasure.purchaseValue, v),
        onTap: (k) => openStatWines(context, c.labels.key(d, k), {
          ...?purchase.cell(k)?.wineIds,
          ...?market.cell(k)?.wineIds,
        }),
      );
    }

    final history = marketValueHistory(c.facts, now: c.now);
    final historyResult = StatResult(
      cells: [
        for (final (month, v) in history) StatCell(month, null, v, const {}),
      ],
      keys1: [for (final (month, _) in history) month],
      keys2: const [],
      total: history.lastOrNull?.$2 ?? 0,
      wineIds: const {},
    );
    return ListView(
      key: const ValueKey('stats-value'),
      children: [
        StatSection(l.statPurchaseVsMarket, paired(StatDimension.color)),
        StatSection(l.statPurchaseVsMarketRegion, paired(StatDimension.region)),
        StatSection(
          l.statMarketHistory,
          history.every((h) => h.$2 == 0)
              ? Padding(
                  padding: const EdgeInsets.all(SpacingTokens.l),
                  child: Text(l.statNoData),
                )
              : StatView(
                  result: historyResult,
                  query: const StatQuery(
                    measure: StatMeasure.marketValue,
                    dim1: StatDimension.purchaseMonth,
                  ),
                  chart: StatChart.line,
                  labels: c.labels,
                  onOpen: (_, _) {},
                  showLegend: false,
                ),
        ),
      ],
    );
  }
}

class _BuyingTab extends StatelessWidget {
  const _BuyingTab(this.c);

  final StatContext c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final opened = c.run(StatMeasure.opened, StatDimension.color);
    final stock = c.run(StatMeasure.bottles, StatDimension.color);
    final keys = {...stock.keys1, ...opened.keys1}.toList();
    Widget months(StatDimension d) {
      final o = c.run(StatMeasure.opened, d);
      final s = c.run(StatMeasure.bottles, d);
      return Column(
        children: [
          for (final k in {...s.keys1, ...o.keys1}.take(15))
            ListTile(
              key: ValueKey('months-${d.code}-$k'),
              dense: true,
              title: Text(c.labels.key(d, k)),
              trailing: Text(switch (monthsOfStock(
                stock: s.valueOf(k),
                opened12: o.valueOf(k),
              )) {
                null => l.statNoOpening,
                final m => l.statMonthsValue(m.toStringAsFixed(0)),
              }),
              onTap: () => openStatWines(context, c.labels.key(d, k), {
                ...?s.cell(k)?.wineIds,
                ...?o.cell(k)?.wineIds,
              }),
            ),
        ],
      );
    }

    return ListView(
      key: const ValueKey('stats-buying'),
      children: [
        StatSection(
          l.statOpenedVsStock,
          PairedBars(
            keys: keys,
            label: (k) => c.labels.key(StatDimension.color, k),
            a: opened.valueOf,
            b: stock.valueOf,
            nameA: l.statSeriesOpened,
            nameB: l.statSeriesStock,
            format: (v) => c.labels.value(StatMeasure.bottles, v),
            onTap: (k) => openStatWines(
              context,
              c.labels.key(StatDimension.color, k),
              {...?stock.cell(k)?.wineIds, ...?opened.cell(k)?.wineIds},
            ),
          ),
        ),
        StatSection(
          '${l.statMonthsLeft} · ${l.statDimColor}',
          months(StatDimension.color),
        ),
        StatSection(
          '${l.statMonthsLeft} · ${l.statDimRegion}',
          months(StatDimension.region),
        ),
      ],
    );
  }
}
