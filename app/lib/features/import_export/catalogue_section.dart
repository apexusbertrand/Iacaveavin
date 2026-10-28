import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/export_providers.dart';
import '../../data/providers.dart';
import '../../data/reference_repository.dart';
import '../../data/settings_store.dart';
import '../../domain/wine_query.dart';
import '../wine_list/list_filters_sheet.dart';

const pdfMime = 'application/pdf';

/// Date d'édition imprimée (« 27 octobre 2026 »).
String editionDate(BuildContext context) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
        .format(DateTime.now());

/// Montant dans la devise de la cave, pour les PDF.
String Function(double) moneyFormatter(BuildContext context, String currency) {
  final f = NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(context).toLanguageTag(),
    name: currency,
  );
  return f.format;
}

/// PDF-03 : filtres appliqués, en clair, pour la page de garde.
List<String> describeFilters(
  AppLocalizations l,
  WineFilters f, {
  required Map<String, String> labels,
  required List<OwnerView> owners,
  required List<LocationView> locations,
}) {
  String names(String list, Set<String> codes) =>
      [for (final c in codes) labels['$list:$c'] ?? c].join(', ');
  String range(num? a, num? b) =>
      l.pdfGardeRange(a == null ? '…' : '$a', b == null ? '…' : '$b');
  return [
    if (f.stock != StockFilter.all)
      l.filterLine(l.filterStock, l.stockLabel(f.stock)),
    if (f.colors.isNotEmpty)
      l.filterLine(l.filterColors, names('couleur', f.colors)),
    if (f.types.isNotEmpty)
      l.filterLine(l.filterTypes, names('type_vin', f.types)),
    if (f.countries.isNotEmpty)
      l.filterLine(l.filterCountries, names('pays', f.countries)),
    if (f.regions.isNotEmpty)
      l.filterLine(l.filterRegions, names('region', f.regions)),
    if (f.appellations.isNotEmpty)
      l.filterLine(l.filterAppellations, names('appellation', f.appellations)),
    if (f.vintageMin != null || f.vintageMax != null)
      l.filterLine(l.filterVintages, range(f.vintageMin, f.vintageMax)),
    if (f.idealYearMin != null || f.idealYearMax != null)
      l.filterLine(l.filterIdealYear, range(f.idealYearMin, f.idealYearMax)),
    if (f.owners.isNotEmpty)
      l.filterLine(
        l.filterOwners,
        [
          for (final o in owners)
            if (f.owners.contains(o.id)) o.name,
        ].join(', '),
      ),
    if (f.location != null)
      l.filterLine(
        l.filterLocation,
        locations.where((x) => x.id == f.location).firstOrNull?.name ?? '',
      ),
    if (f.statuses.isNotEmpty)
      l.filterLine(
        l.filterStatuses,
        [for (final s in f.statuses) l.statusLabel(s)].join(', '),
      ),
    if (f.minScore != null)
      l.filterLine(l.filterMinScore, '${f.minScore!.round()}'),
    if (f.priceMin != null || f.priceMax != null)
      l.filterLine(l.filterPrice, range(f.priceMin, f.priceMax)),
    if (f.grapes.isNotEmpty)
      l.filterLine(l.filterGrapes, names('cepage', f.grapes)),
    if (f.favoritesOnly) l.filterFavorites,
  ];
}

/// PDF-02 à PDF-05 : catalogue de 2 fiches par page, filtres et tri au
/// choix, page de garde, génération en arrière-plan avec progression.
class CatalogueSection extends ConsumerStatefulWidget {
  const CatalogueSection({super.key});

  @override
  ConsumerState<CatalogueSection> createState() => _CatalogueSectionState();
}

class _CatalogueSectionState extends ConsumerState<CatalogueSection> {
  late WineQuery _query = ref.read(settingsProvider).listQuery;
  bool _cover = true;
  double? _progress;

  Future<void> _filters() async {
    final result = await showModalBottomSheet<WineFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FiltersSheet(initial: _query.filters),
    );
    if (result != null) {
      setState(() => _query = _query.copyWith(filters: result));
    }
  }

  Future<void> _sort() async {
    final result = await showModalBottomSheet<WineQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SortSheet(query: _query),
    );
    if (result != null) setState(() => _query = result);
  }

  Future<void> _generate(List<String> ids) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final date = editionDate(context);
    final money = moneyFormatter(context, ref.read(settingsProvider).currency);
    final filters = describeFilters(
      l,
      _query.filters,
      labels: ref.read(labelsProvider).value ?? const {},
      owners: ref.read(ownersProvider).value ?? const [],
      locations: ref.read(locationsProvider).value ?? const [],
    );
    setState(() => _progress = 0);
    try {
      final bytes = await ref
          .read(pdfServiceProvider)
          .catalogue(
            ids,
            l,
            date: date,
            money: money,
            cover: _cover,
            filters: filters,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      messenger.showSnackBar(SnackBar(content: Text(l.ieReady)));
      await ref.read(fileSharerProvider)(
        bytes,
        'iacaveavin-catalogue.pdf',
        pdfMime,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = ref.watch(wineListProvider);
    final year = ref.watch(currentYearProvider);
    final ids = [
      for (final w in _query.apply(items.value ?? const [], year: year)) w.id,
    ];
    final active = _query.filters.activeCount;
    final busy = _progress != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.l,
            SpacingTokens.xl,
            SpacingTokens.l,
            SpacingTokens.xs,
          ),
          child: Text(
            l.catalogueSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.palette.primaryText,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
          child: Text(l.catalogueHint, style: theme.textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.s,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('catalogue-filters'),
                onPressed: busy ? null : _filters,
                icon: const Icon(Icons.filter_list),
                label: Text(
                  active == 0 ? l.filters : l.catalogueFilters(active),
                ),
              ),
              OutlinedButton.icon(
                key: const ValueKey('catalogue-sort'),
                onPressed: busy ? null : _sort,
                icon: const Icon(Icons.sort),
                label: Text(l.sortLabel(_query.sort1.criterion)),
              ),
            ],
          ),
        ),
        SwitchListTile(
          key: const ValueKey('catalogue-cover'),
          title: Text(l.catalogueCover),
          value: _cover,
          onChanged: busy ? null : (v) => setState(() => _cover = v),
        ),
        if (busy)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            child: LinearProgressIndicator(
              key: const ValueKey('catalogue-progress'),
              value: _progress,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: FilledButton.icon(
            key: const ValueKey('catalogue-generate'),
            onPressed: busy || ids.isEmpty ? null : () => _generate(ids),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(l.catalogueGenerate(ids.length)),
          ),
        ),
      ],
    );
  }
}
