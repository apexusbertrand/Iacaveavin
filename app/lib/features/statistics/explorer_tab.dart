import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/export_providers.dart';
import '../../data/pdf/pdf_service.dart' show fontRegularAsset, fontBoldAsset;
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;
import 'stat_chart.dart';
import 'statistics_screen.dart';
import 'stats_providers.dart';

/// STA-02 à STA-05 : explorateur libre, favoris et exports.
class ExplorerTab extends ConsumerStatefulWidget {
  const ExplorerTab({super.key, required this.context});

  final StatContext context;

  @override
  ConsumerState<ExplorerTab> createState() => _ExplorerTabState();
}

class _ExplorerTabState extends ConsumerState<ExplorerTab> {
  StatQuery _query = const StatQuery(
    measure: StatMeasure.bottles,
    dim1: StatDimension.color,
  );
  StatChart _chart = StatChart.donut;
  final _boundary = GlobalKey();

  StatContext get c => widget.context;

  void _set(StatQuery q) {
    final allowed = compatibleCharts(q.measure, q.dim1, q.dim2);
    setState(() {
      _query = q;
      if (!allowed.contains(_chart)) _chart = allowed.first;
    });
  }

  String _title(AppLocalizations l) => [
    c.labels.measure(_query.measure),
    c.labels.dimension(_query.dim1),
    if (_query.dim2 != null) c.labels.dimension(_query.dim2!),
  ].join(' · ');

  Future<void> _addFilter() async {
    final l = AppLocalizations.of(context);
    final dim = await showDialog<StatDimension>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.statFilterAdd),
        children: [
          for (final d in StatDimension.values)
            SimpleDialogOption(
              key: ValueKey('filter-dim-${d.code}'),
              onPressed: () => Navigator.of(context).pop(d),
              child: Text(c.labels.dimension(d)),
            ),
        ],
      ),
    );
    if (dim == null || !mounted) return;
    final keys = aggregate(
      c.facts,
      StatQuery(measure: StatMeasure.bottles, dim1: dim),
      year: c.year,
      now: c.now,
    ).keys1;
    final chosen = {...?_query.filters[dim]};
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(c.labels.dimension(dim)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final k in keys)
                  CheckboxListTile(
                    key: ValueKey('filter-value-$k'),
                    value: chosen.contains(k),
                    title: Text(c.labels.key(dim, k)),
                    onChanged: (v) => setLocal(
                      () => v == true ? chosen.add(k) : chosen.remove(k),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel),
            ),
            TextButton(
              key: const ValueKey('filter-ok'),
              onPressed: () => Navigator.of(context).pop(chosen),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    _set(_query.copyWith(filters: {..._query.filters, dim: result}));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = TextEditingController(text: _title(l));
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.statSave),
        content: TextField(
          key: const ValueKey('view-name'),
          controller: name,
          autofocus: true,
          decoration: InputDecoration(labelText: l.statViewName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('view-save'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    await ref
        .read(statsRepositoryProvider)
        .saveView(
          cellarId: await ref.read(bootstrapProvider.future),
          name: name.text,
          query: _query,
          chart: _chart,
        );
    messenger.showSnackBar(SnackBar(content: Text(l.statSaved)));
  }

  Future<Uint8List> _png() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  /// STA-05 : export de la vue en PNG, PDF ou CSV.
  Future<void> _export(String format, StatResult r) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final share = ref.read(fileSharerProvider);
    final title = _title(l);
    try {
      switch (format) {
        case 'png':
          await share(await _png(), 'statistique.png', 'image/png');
        case 'pdf':
          final png = await _png();
          final read = ref.read(binaryAssetReaderProvider);
          final doc = pw.Document(
            theme: pw.ThemeData.withFont(
              base: pw.Font.ttf(
                ByteData.sublistView(await read(fontRegularAsset)),
              ),
              bold: pw.Font.ttf(
                ByteData.sublistView(await read(fontBoldAsset)),
              ),
            ),
          );
          doc.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
                ],
              ),
            ),
          );
          await share(await doc.save(), 'statistique.pdf', 'application/pdf');
        case 'csv':
          await share(
            Uint8List.fromList(utf8.encode(_csv(r))),
            'statistique.csv',
            'text/csv',
          );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    }
  }

  String _csv(StatResult r) {
    final m = _query.measure;
    String cell(String s) => '"${s.replaceAll('"', '""')}"';
    final lines = <String>[
      [
        c.labels.dimension(_query.dim1),
        if (_query.dim2 != null) c.labels.dimension(_query.dim2!),
        c.labels.measure(m),
      ].map(cell).join(';'),
      for (final k1 in r.keys1)
        if (_query.dim2 == null)
          [
            cell(c.labels.key(_query.dim1, k1)),
            c.labels.raw(m, r.valueOf(k1)),
          ].join(';')
        else
          for (final k2 in r.keys2)
            if (r.cell(k1, k2) != null)
              [
                cell(c.labels.key(_query.dim1, k1)),
                cell(c.labels.key(_query.dim2!, k2)),
                c.labels.raw(m, r.valueOf(k1, k2)),
              ].join(';'),
    ];
    // BOM : accents corrects à l'ouverture dans Excel.
    return '﻿${lines.join('\r\n')}\r\n';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = c.labels;
    final r = c.run(
      _query.measure,
      _query.dim1,
      d2: _query.dim2,
      filters: _query.filters,
    );
    final charts = compatibleCharts(_query.measure, _query.dim1, _query.dim2);
    final views = ref.watch(savedViewsProvider).value ?? const [];

    Widget picker<T>(
      String key,
      String label,
      T value,
      List<T> options,
      String Function(T) text,
      ValueChanged<T> onChanged,
    ) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.l,
        vertical: SpacingTokens.xs,
      ),
      child: DropdownButtonFormField<T>(
        key: ValueKey(key),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final o in options)
            DropdownMenuItem(value: o, child: Text(text(o))),
        ],
        onChanged: (v) => onChanged(v as T),
      ),
    );

    return ListView(
      key: const ValueKey('stats-explorer'),
      children: [
        if (views.isNotEmpty)
          StatSection(
            l.statFavorites,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
              child: Wrap(
                spacing: SpacingTokens.s,
                children: [
                  for (final v in views)
                    InputChip(
                      key: ValueKey('view-${v.name}'),
                      label: Text(v.name),
                      onPressed: () => setState(() {
                        _query = v.query;
                        _chart = v.chart;
                      }),
                      onDeleted: () async {
                        final ok = await confirm(
                          context,
                          title: l.statDeleteView,
                          body: v.name,
                          action: l.delete,
                        );
                        if (ok) {
                          await ref
                              .read(statsRepositoryProvider)
                              .deleteView(v.id);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        picker<StatMeasure>(
          'pick-measure',
          l.statMeasure,
          _query.measure,
          StatMeasure.values,
          labels.measure,
          (m) => _set(_query.copyWith(measure: m)),
        ),
        picker<StatDimension>(
          'pick-dim1',
          l.statDimension,
          _query.dim1,
          StatDimension.values,
          labels.dimension,
          (d) => _set(
            _query.copyWith(
              dim1: d,
              dim2: () => _query.dim2 == d ? null : _query.dim2,
            ),
          ),
        ),
        picker<StatDimension?>(
          'pick-dim2',
          l.statDimension2,
          _query.dim2,
          [null, ...StatDimension.values.where((d) => d != _query.dim1)],
          (d) => d == null ? l.statNoDimension2 : labels.dimension(d),
          (d) => _set(_query.copyWith(dim2: () => d)),
        ),
        picker<StatChart>(
          'pick-chart',
          l.statChartType,
          _chart,
          charts,
          labels.chart,
          (ch) => setState(() => _chart = ch),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
          child: Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final e in _query.filters.entries)
                if (e.value.isNotEmpty)
                  InputChip(
                    label: Text(
                      l.statFilterLine(
                        labels.dimension(e.key),
                        [for (final k in e.value) labels.key(e.key, k)]
                            .join(', '),
                      ),
                    ),
                    onDeleted: () => _set(
                      _query.copyWith(
                        filters: {..._query.filters}..remove(e.key),
                      ),
                    ),
                  ),
              ActionChip(
                key: const ValueKey('add-filter'),
                avatar: const Icon(Icons.filter_list),
                label: Text(l.statFilterAdd),
                onPressed: _addFilter,
              ),
            ],
          ),
        ),
        RepaintBoundary(
          key: _boundary,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: StatSection(
              _title(l),
              StatView(
                key: ValueKey('explorer-view-${_chart.code}'),
                result: r,
                query: _query,
                chart: _chart,
                labels: labels,
                onOpen: (t, ids) => openStatWines(context, t, ids),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.s,
            children: [
              FilledButton.icon(
                key: const ValueKey('save-view'),
                onPressed: _save,
                icon: const Icon(Icons.star_outline),
                label: Text(l.statSave),
              ),
              for (final (f, label, icon) in [
                ('png', l.statExportPng, Icons.image_outlined),
                ('pdf', l.statExportPdf, Icons.picture_as_pdf_outlined),
                ('csv', l.statExportCsv, Icons.table_chart_outlined),
              ])
                OutlinedButton.icon(
                  key: ValueKey('export-$f'),
                  onPressed: r.isEmpty ? null : () => _export(f, r),
                  icon: Icon(icon),
                  label: Text(label),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
