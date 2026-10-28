import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';
import '../../domain/garde.dart';
import '../../domain/wine_list_item.dart';
import '../../domain/wine_query.dart';

/// Tri à deux niveaux (LST-01).
class SortSheet extends StatefulWidget {
  const SortSheet({super.key, required this.query});

  final WineQuery query;

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  late SortSpec _sort1 = widget.query.sort1;
  late SortSpec? _sort2 = widget.query.sort2;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.sort, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.m),
            _SortRow(
              key: const ValueKey('sort1'),
              label: l.sortFirst,
              value: _sort1,
              onChanged: (s) => setState(() => _sort1 = s!),
            ),
            const SizedBox(height: SpacingTokens.m),
            _SortRow(
              key: const ValueKey('sort2'),
              label: l.sortSecond,
              value: _sort2,
              allowNone: true,
              onChanged: (s) => setState(() => _sort2 = s),
            ),
            const SizedBox(height: SpacingTokens.l),
            FilledButton(
              key: const ValueKey('sort-apply'),
              onPressed: () => Navigator.of(
                context,
              ).pop(widget.query.copyWith(sort1: _sort1, sort2: () => _sort2)),
              child: Text(l.apply),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowNone = false,
  });

  final String label;
  final SortSpec? value;
  final bool allowNone;
  final ValueChanged<SortSpec?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<SortCriterion?>(
            initialValue: value?.criterion,
            isExpanded: true,
            decoration: InputDecoration(labelText: label),
            items: [
              if (allowNone)
                DropdownMenuItem(value: null, child: Text(l.sortNone)),
              for (final c in SortCriterion.values)
                DropdownMenuItem(value: c, child: Text(l.sortLabel(c))),
            ],
            onChanged: (c) => onChanged(
              c == null
                  ? null
                  : SortSpec(c, ascending: value?.ascending ?? true),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.s),
        IconButton(
          tooltip: l.sortDirection,
          isSelected: value != null && !value!.ascending,
          icon: const Icon(Icons.arrow_upward),
          selectedIcon: const Icon(Icons.arrow_downward),
          onPressed: value == null ? null : () => onChanged(value!.toggled()),
        ),
      ],
    );
  }
}

/// Filtres combinables (LST-05). Les valeurs proposées sont celles présentes
/// dans la cave.
class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key, required this.initial});

  final WineFilters initial;

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late WineFilters _f = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = ref.watch(wineListProvider).value ?? const <WineListItem>[];
    final labels = ref.watch(labelsProvider).value ?? const {};
    final owners = ref.watch(ownersProvider).value ?? const [];
    final locations = ref.watch(locationsProvider).value ?? const [];

    Map<String, String> present(
      String list,
      String? Function(WineListItem) code,
    ) {
      final out = <String, String>{};
      for (final w in items) {
        final c = code(w);
        if (c != null) out[c] = labels['$list:$c'] ?? c;
      }
      return Map.fromEntries(
        out.entries.toList()..sort((a, b) => a.value.compareTo(b.value)),
      );
    }

    final grapes = <String, String>{
      for (final w in items)
        for (final g in w.grapes) g: labels['cepage:$g'] ?? g,
    };

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.palette.primaryText,
            ),
          ),
          const SizedBox(height: SpacingTokens.s),
          child,
        ],
      ),
    );

    Widget chips(
      Map<String, String> options,
      Set<String> selected,
      ValueChanged<Set<String>> onChanged,
    ) => Wrap(
      spacing: SpacingTokens.s,
      runSpacing: SpacingTokens.xs,
      children: [
        for (final e in options.entries)
          FilterChip(
            label: Text(e.value),
            selected: selected.contains(e.key),
            onSelected: (on) => onChanged(
              on ? {...selected, e.key} : ({...selected}..remove(e.key)),
            ),
          ),
      ],
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.l,
              SpacingTokens.l,
              SpacingTokens.l,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.filters, style: theme.textTheme.titleLarge),
                ),
                TextButton(
                  onPressed: () => setState(() => _f = const WineFilters()),
                  child: Text(l.resetFilters),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(SpacingTokens.l),
              children: [
                section(
                  l.filterStock,
                  SegmentedButton<StockFilter>(
                    segments: [
                      for (final s in StockFilter.values)
                        ButtonSegment(value: s, label: Text(l.stockLabel(s))),
                    ],
                    selected: {_f.stock},
                    onSelectionChanged: (s) =>
                        setState(() => _f = _f.copyWith(stock: s.first)),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.filterFavorites),
                  value: _f.favoritesOnly,
                  onChanged: (v) =>
                      setState(() => _f = _f.copyWith(favoritesOnly: v)),
                ),
                section(
                  l.filterColors,
                  chips(
                    {for (final c in colorOrder) c: labels['couleur:$c'] ?? c},
                    _f.colors,
                    (v) => setState(() => _f = _f.copyWith(colors: v)),
                  ),
                ),
                section(
                  l.filterStatuses,
                  Wrap(
                    spacing: SpacingTokens.s,
                    runSpacing: SpacingTokens.xs,
                    children: [
                      for (final s in CellarStatus.values)
                        FilterChip(
                          label: Text(l.statusLabel(s)),
                          selected: _f.statuses.contains(s),
                          onSelected: (on) => setState(
                            () => _f = _f.copyWith(
                              statuses: on
                                  ? {..._f.statuses, s}
                                  : ({..._f.statuses}..remove(s)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (owners.isNotEmpty)
                  section(
                    l.filterOwners,
                    chips(
                      {for (final o in owners) o.id: o.name},
                      _f.owners,
                      (v) => setState(() => _f = _f.copyWith(owners: v)),
                    ),
                  ),
                if (locations.isNotEmpty)
                  section(
                    l.filterLocation,
                    DropdownButtonFormField<String?>(
                      initialValue: _f.location,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l.anyLocation),
                        ),
                        for (final loc in locations)
                          DropdownMenuItem(
                            value: loc.id,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: SpacingTokens.l * loc.depth,
                              ),
                              child: Text(loc.name),
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _f = _f.copyWith(location: () => v)),
                    ),
                  ),
                section(
                  l.filterVintages,
                  _RangeFields(
                    min: _f.vintageMin?.toDouble(),
                    max: _f.vintageMax?.toDouble(),
                    integer: true,
                    onChanged: (a, b) => setState(
                      () => _f = _f.copyWith(
                        vintageMin: () => a?.toInt(),
                        vintageMax: () => b?.toInt(),
                      ),
                    ),
                  ),
                ),
                section(
                  l.filterIdealYear,
                  _RangeFields(
                    min: _f.idealYearMin?.toDouble(),
                    max: _f.idealYearMax?.toDouble(),
                    integer: true,
                    onChanged: (a, b) => setState(
                      () => _f = _f.copyWith(
                        idealYearMin: () => a?.toInt(),
                        idealYearMax: () => b?.toInt(),
                      ),
                    ),
                  ),
                ),
                section(
                  l.filterPrice,
                  _RangeFields(
                    min: _f.priceMin,
                    max: _f.priceMax,
                    onChanged: (a, b) => setState(
                      () => _f = _f.copyWith(
                        priceMin: () => a,
                        priceMax: () => b,
                      ),
                    ),
                  ),
                ),
                section(
                  l.filterMinScore,
                  _RangeFields(
                    min: _f.minScore,
                    single: true,
                    onChanged: (a, _) =>
                        setState(() => _f = _f.copyWith(minScore: () => a)),
                  ),
                ),
                for (final (title, list, selected, apply, code)
                    in <
                      (
                        String,
                        String,
                        Set<String>,
                        WineFilters Function(Set<String>),
                        String? Function(WineListItem),
                      )
                    >[
                      (
                        l.filterCountries,
                        'pays',
                        _f.countries,
                        (v) => _f.copyWith(countries: v),
                        (w) => w.countryCode,
                      ),
                      (
                        l.filterRegions,
                        'region',
                        _f.regions,
                        (v) => _f.copyWith(regions: v),
                        (w) => w.regionCode,
                      ),
                      (
                        l.filterAppellations,
                        'appellation',
                        _f.appellations,
                        (v) => _f.copyWith(appellations: v),
                        (w) => w.appellationCode,
                      ),
                      (
                        l.filterTypes,
                        'type_vin',
                        _f.types,
                        (v) => _f.copyWith(types: v),
                        (w) => w.wineType,
                      ),
                    ])
                  if (present(list, code).isNotEmpty)
                    section(
                      title,
                      chips(
                        present(list, code),
                        selected,
                        (v) => setState(() => _f = apply(v)),
                      ),
                    ),
                if (grapes.isNotEmpty)
                  section(
                    l.filterGrapes,
                    chips(
                      Map.fromEntries(
                        grapes.entries.toList()
                          ..sort((a, b) => a.value.compareTo(b.value)),
                      ),
                      _f.grapes,
                      (v) => setState(() => _f = _f.copyWith(grapes: v)),
                    ),
                  ),
                section(
                  l.filterEnrichment,
                  chips(
                    {
                      for (final c in const [
                        'brouillon',
                        'a_enrichir',
                        'en_cours',
                        'a_valider',
                        'valide',
                        'erreur',
                      ])
                        c: l.enrichmentLabel(c),
                    },
                    _f.enrichment,
                    (v) => setState(() => _f = _f.copyWith(enrichment: v)),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('filters-apply'),
                  onPressed: () => Navigator.of(context).pop(_f),
                  child: Text(l.apply),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeFields extends StatefulWidget {
  const _RangeFields({
    required this.onChanged,
    this.min,
    this.max,
    this.integer = false,
    this.single = false,
  });

  final double? min;
  final double? max;
  final bool integer;
  final bool single;
  final void Function(double? min, double? max) onChanged;

  @override
  State<_RangeFields> createState() => _RangeFieldsState();
}

class _RangeFieldsState extends State<_RangeFields> {
  late final _a = TextEditingController(text: _fmt(widget.min));
  late final _b = TextEditingController(text: _fmt(widget.max));

  String _fmt(double? v) => v == null
      ? ''
      : widget.integer
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(_parse(_a.text), _parse(_b.text));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = TextInputType.numberWithOptions(decimal: !widget.integer);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _a,
            keyboardType: type,
            decoration: InputDecoration(labelText: l.rangeFrom),
            onChanged: (_) => _emit(),
          ),
        ),
        if (!widget.single) ...[
          const SizedBox(width: SpacingTokens.m),
          Expanded(
            child: TextField(
              controller: _b,
              keyboardType: type,
              decoration: InputDecoration(labelText: l.rangeTo),
              onChanged: (_) => _emit(),
            ),
          ),
        ],
      ],
    );
  }
}
