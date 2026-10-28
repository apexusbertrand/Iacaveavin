import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../domain/stats.dart';
import 'stat_labels.dart';

/// Hauteur des graphiques.
const chartHeight = 240.0;

/// STA-04 : ouvre la liste des fiches d'une part ou d'une barre.
typedef OpenWines = void Function(String title, Set<String> wineIds);

/// Un résultat d'agrégation dessiné dans le graphique choisi, avec sa
/// légende (chaque ligne de légende ouvre aussi la liste filtrée).
class StatView extends StatelessWidget {
  const StatView({
    super.key,
    required this.result,
    required this.query,
    required this.chart,
    required this.labels,
    required this.onOpen,
    this.showLegend = true,
  });

  /// Légende tappable sous le graphique.
  final bool showLegend;

  final StatResult result;
  final StatQuery query;
  final StatChart chart;
  final StatLabels labels;
  final OpenWines onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (result.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(SpacingTokens.l),
        child: Text(l.statNoData, style: theme.textTheme.bodyMedium),
      );
    }
    final m = query.measure;
    final r = chart == StatChart.donut ? topParts(result) : result;
    String key1(String k) => labels.key(query.dim1, k);
    String key2(String k) => labels.key(query.dim2!, k);

    Widget legend(List<String> keys, {StatDimension? colored}) => !showLegend
        ? const SizedBox.shrink()
        : Column(
            children: [
              for (final (i, k) in keys.indexed)
                ListTile(
                  key: ValueKey('stat-row-$k'),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: colored == null
                      ? null
                      : CircleAvatar(
                          radius: SpacingTokens.s / 1.5,
                          backgroundColor: seriesColor(context, colored, k, i),
                        ),
                  title: Text(key1(k)),
                  trailing: Text(
                    labels.value(
                      m,
                      r.cells
                          .where((c) => c.k1 == k)
                          .fold(
                            0.0,
                            (s, c) => m.average ? c.value : s + c.value,
                          ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () => onOpen(key1(k), {
                    for (final c in r.cells.where((c) => c.k1 == k))
                      ...c.wineIds,
                  }),
                ),
            ],
          );

    return switch (chart) {
      StatChart.kpi => InkWell(
        key: const ValueKey('stat-kpi'),
        onTap: () => onOpen(labels.measure(m), r.wineIds),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: Column(
            children: [
              Text(
                labels.value(m, r.total),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: context.palette.primaryText,
                ),
              ),
              Text(labels.measure(m), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      StatChart.donut => Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: chartHeight / 5,
                sectionsSpace: 1,
                sections: [
                  for (final (i, k) in r.keys1.indexed)
                    PieChartSectionData(
                      value: r.valueOf(k),
                      color: seriesColor(context, query.dim1, k, i),
                      radius: chartHeight / 4,
                      showTitle: false,
                    ),
                ],
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final i = response?.touchedSection?.touchedSectionIndex;
                    if (event is FlTapUpEvent && i != null && i >= 0) {
                      final k = r.keys1[i];
                      onOpen(key1(k), r.cell(k)?.wineIds ?? const {});
                    }
                  },
                ),
              ),
            ),
          ),
          legend(r.keys1, colored: query.dim1),
        ],
      ),
      StatChart.barsVertical || StatChart.barsHorizontal => Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: _bars(
              context,
              r,
              horizontal: chart == StatChart.barsHorizontal,
              rods: (k, i) => [
                BarChartRodData(
                  toY: r.valueOf(k),
                  color: seriesColor(context, query.dim1, k, i),
                  width: _barWidth(r.keys1.length),
                ),
              ],
              label: key1,
              onTap: (k) => onOpen(key1(k), r.cell(k)?.wineIds ?? const {}),
            ),
          ),
          legend(
            r.keys1,
            colored: query.dim1 == StatDimension.color ? query.dim1 : null,
          ),
        ],
      ),
      StatChart.stacked => Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: _bars(
              context,
              r,
              horizontal: false,
              rods: (k, _) {
                var y = 0.0;
                final stack = <BarChartRodStackItem>[];
                for (final (j, k2) in r.keys2.indexed) {
                  final v = r.valueOf(k, k2);
                  if (v == 0) continue;
                  stack.add(
                    BarChartRodStackItem(
                      y,
                      y + v,
                      seriesColor(context, query.dim2, k2, j),
                    ),
                  );
                  y += v;
                }
                return [
                  BarChartRodData(
                    toY: y,
                    rodStackItems: stack,
                    width: _barWidth(r.keys1.length),
                    color: Theme.of(context).colorScheme.surface
                        .withValues(alpha: 0),
                  ),
                ];
              },
              label: key1,
              onTap: (k) => onOpen(key1(k), {
                for (final c in r.cells.where((c) => c.k1 == k)) ...c.wineIds,
              }),
            ),
          ),
          Wrap(
            spacing: SpacingTokens.m,
            children: [
              for (final (j, k2) in r.keys2.indexed)
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: seriesColor(context, query.dim2, k2, j),
                  ),
                  label: Text(key2(k2)),
                ),
            ],
          ),
          legend(r.keys1),
        ],
      ),
      StatChart.line => Column(
        children: [
          SizedBox(height: chartHeight, child: _line(context, r, key1)),
          legend(r.keys1),
        ],
      ),
      StatChart.crossTable => _CrossTable(
        result: r,
        query: query,
        labels: labels,
        onOpen: onOpen,
      ),
    };
  }

  static double _barWidth(int n) => n <= 6 ? 22 : (n <= 15 ? 12 : 6);

  Widget _line(
    BuildContext context,
    StatResult r,
    String Function(String) label,
  ) {
    final keys = [
      for (final k in r.keys1)
        if (k != noneKey) k,
    ];
    final color = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final (i, k) in keys.indexed)
                FlSpot(i.toDouble(), r.valueOf(k)),
            ],
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: chartTitles(context, keys, label),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            final i = response?.lineBarSpots?.firstOrNull?.spotIndex;
            if (event is FlTapUpEvent && i != null) {
              onOpen(label(keys[i]), r.cell(keys[i])?.wineIds ?? const {});
            }
          },
        ),
      ),
    );
  }

  Widget _bars(
    BuildContext context,
    StatResult r, {
    required bool horizontal,
    required List<BarChartRodData> Function(String k, int i) rods,
    required String Function(String) label,
    required void Function(String k) onTap,
  }) {
    final keys = r.keys1;
    return BarChart(
      BarChartData(
        rotationQuarterTurns: horizontal ? 1 : 0,
        barGroups: [
          for (final (i, k) in keys.indexed)
            BarChartGroupData(x: i, barRods: rods(k, i)),
        ],
        titlesData: chartTitles(context, keys, label),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            final i = response?.spot?.touchedBarGroupIndex;
            if (event is FlTapUpEvent && i != null && i >= 0) onTap(keys[i]);
          },
        ),
      ),
    );
  }
}

/// Axes : valeurs à gauche, libellés en bas (un sur deux au-delà de 8).
FlTitlesData chartTitles(
  BuildContext context,
  List<String> keys,
  String Function(String) label,
) {
  final style = Theme.of(context).textTheme.labelSmall;
  final step = math.max(1, (keys.length / 8).ceil());
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: SpacingTokens.xxl * 1.5,
        getTitlesWidget: (v, meta) => SideTitleWidget(
          meta: meta,
          child: Text(meta.formattedValue, style: style),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: SpacingTokens.xxl,
        getTitlesWidget: (v, meta) {
          final i = v.round();
          if (i < 0 || i >= keys.length || i % step != 0) {
            return const SizedBox.shrink();
          }
          final text = label(keys[i]);
          return SideTitleWidget(
            meta: meta,
            child: Text(
              text.length > 10 ? '${text.substring(0, 9)}…' : text,
              style: style,
            ),
          );
        },
      ),
    ),
  );
}

/// STA-02 : tableau croisé, une ligne par valeur de la première dimension.
class _CrossTable extends StatelessWidget {
  const _CrossTable({
    required this.result,
    required this.query,
    required this.labels,
    required this.onOpen,
  });

  final StatResult result;
  final StatQuery query;
  final StatLabels labels;
  final OpenWines onOpen;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final m = query.measure;
    return SingleChildScrollView(
      key: const ValueKey('stat-cross-table'),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: SpacingTokens.l,
        columns: [
          DataColumn(label: Text(labels.dimension(query.dim1))),
          for (final k2 in r.keys2)
            DataColumn(numeric: true, label: Text(labels.key(query.dim2!, k2))),
        ],
        rows: [
          for (final k1 in r.keys1)
            DataRow(
              cells: [
                DataCell(Text(labels.key(query.dim1, k1))),
                for (final k2 in r.keys2)
                  DataCell(
                    Text(
                      r.cell(k1, k2) == null
                          ? ''
                          : labels.value(m, r.valueOf(k1, k2)),
                    ),
                    onTap: r.cell(k1, k2) == null
                        ? null
                        : () => onOpen(
                            '${labels.key(query.dim1, k1)} · ${labels.key(query.dim2!, k2)}',
                            r.cell(k1, k2)!.wineIds,
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Deux séries par valeur (achat et marché, ouvertes et stock).
class PairedBars extends StatelessWidget {
  const PairedBars({
    super.key,
    required this.keys,
    required this.label,
    required this.a,
    required this.b,
    required this.nameA,
    required this.nameB,
    required this.format,
    this.onTap,
  });

  final List<String> keys;
  final String Function(String) label;
  final double Function(String) a;
  final double Function(String) b;
  final String nameA;
  final String nameB;
  final String Function(double) format;
  final void Function(String key)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ca = theme.colorScheme.secondary;
    final cb = theme.colorScheme.primary;
    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: BarChart(
            BarChartData(
              barGroups: [
                for (final (i, k) in keys.indexed)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(toY: a(k), color: ca, width: 10),
                      BarChartRodData(toY: b(k), color: cb, width: 10),
                    ],
                  ),
              ],
              titlesData: chartTitles(context, keys, label),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  final i = response?.spot?.touchedBarGroupIndex;
                  if (event is FlTapUpEvent && i != null && i >= 0) {
                    onTap?.call(keys[i]);
                  }
                },
              ),
            ),
          ),
        ),
        Wrap(
          spacing: SpacingTokens.m,
          children: [
            Chip(
              avatar: CircleAvatar(backgroundColor: ca),
              label: Text(nameA),
            ),
            Chip(
              avatar: CircleAvatar(backgroundColor: cb),
              label: Text(nameB),
            ),
          ],
        ),
        for (final k in keys)
          ListTile(
            key: ValueKey('paired-row-$k'),
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(label(k)),
            trailing: Text(
              '${format(a(k))} · ${format(b(k))}',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: onTap == null ? null : () => onTap!(k),
          ),
      ],
    );
  }
}
