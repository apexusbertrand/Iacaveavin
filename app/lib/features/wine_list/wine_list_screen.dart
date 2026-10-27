import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/app_settings.dart';
import '../../domain/stock_rules.dart';
import '../../domain/wine_list_item.dart';
import '../../domain/wine_query.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../add/add_menu.dart';
import '../backup/backup_screen.dart';
import 'list_filters_sheet.dart';
import '../to_drink/monthly_alert_banner.dart';
import 'list_state.dart';
import '../wine_detail/price_actions.dart';
import 'selection_actions.dart';
import 'wine_card.dart';

/// « Mes vins » (LST-01 à LST-10).
class WineListScreen extends ConsumerStatefulWidget {
  const WineListScreen({super.key});

  @override
  ConsumerState<WineListScreen> createState() => _WineListScreenState();
}

class _WineListScreenState extends ConsumerState<WineListScreen> {
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  bool _showBackToTop = false;
  bool _searching = false;
  final _collapsed = <String>{};
  final _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final settings = ref.read(settingsProvider.notifier);
      if (ref.read(settingsProvider).firstLaunch == null) {
        await settings.update((s) => s.copyWith(firstLaunch: DateTime.now()));
      }
      if (!mounted) return;
      // AJO-09 : les jobs en attente repartent au lancement.
      ref.read(enrichmentRunnerProvider.notifier).kick();
      await runAutoBackupIfDue(ref);
      // PRX-06 : rafraîchissement mensuel des prix, si l'option est active.
      if (mounted) await autoRefreshPricesIfDue(ref);
    });
  }

  /// SAV-03 : rappel si aucun export externe depuis 30 jours.
  bool _reminderDue(AppSettings s) {
    final since = s.lastExternalBackup ?? s.firstLaunch;
    return since != null &&
        DateTime.now().difference(since) >= const Duration(days: 30);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Bouton « Haut de la page » après deux écrans de défilement.
  void _onScroll() {
    final show =
        _scroll.hasClients &&
        _scroll.offset > 2 * _scroll.position.viewportDimension;
    if (show != _showBackToTop) setState(() => _showBackToTop = show);
  }

  void _updateQuery(WineQuery Function(WineQuery) change) => ref
      .read(settingsProvider.notifier)
      .update((s) => s.copyWith(listQuery: change(s.listQuery)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wines = ref.watch(visibleWinesProvider);
    final settings = ref.watch(settingsProvider);
    final query = settings.listQuery;
    final summary = wines.whenData(CellarSummary.of).value;
    final selecting = _selected.isNotEmpty;
    // AJO-09 : avis quand une identification se termine pendant l'usage.
    ref.listen(enrichmentRunnerProvider, (previous, next) {
      final visible = ModalRoute.of(context)?.isCurrent ?? true;
      if (next != null && next.finished > 0 && visible) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.enrichReady)));
      }
    });

    return PopScope(
      canPop: !selecting && !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          _selected.clear();
          _closeSearch();
        });
      },
      child: Scaffold(
        appBar: selecting
            ? _selectionBar(l)
            : _searching
            ? _searchBar(l)
            : _mainBar(l, summary, settings),
        drawer: selecting
            ? null
            : const AppDrawer(current: AppDestination.myWines),
        floatingActionButton: selecting ? null : _fabs(l),
        body: Column(
          children: [
            if (_reminderDue(settings) && !selecting)
              MaterialBanner(
                content: Text(l.externalBackupReminder),
                actions: [
                  TextButton(
                    onPressed: () => context.go('/sauvegarde'),
                    child: Text(l.exportNow),
                  ),
                ],
              ),
            _CriteriaBar(
              query: query,
              onSort: () => _openSort(query),
              onReset: () => _updateQuery(
                (q) => q.copyWith(filters: settings.defaultQuery.filters),
              ),
              onFilters: _openFilters,
              onChange: _updateQuery,
            ),
            Expanded(
              child: wines.when(
                loading: () => _LoadingList(label: l.wineListLoading),
                error: (error, _) => MessageStateView(
                  icon: Icons.error_outline,
                  isError: true,
                  title: l.wineListErrorTitle,
                  body: l.wineListErrorDetail('$error'),
                  action: FilledButton(
                    onPressed: () => ref.invalidate(bootstrapProvider),
                    child: Text(l.retry),
                  ),
                ),
                data: (items) => _body(l, items, query, settings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    AppLocalizations l,
    List<WineListItem> items,
    WineQuery query,
    AppSettings settings,
  ) {
    if (items.isEmpty) {
      final hasAny = (ref.read(wineListProvider).value ?? const []).isNotEmpty;
      if (hasAny) {
        return MessageStateView(
          icon: Icons.search_off,
          title: l.noResults,
          body: l.noResultsBody,
        );
      }
      return MessageStateView(
        icon: Icons.wine_bar_outlined,
        title: l.wineListEmptyTitle,
        body: l.wineListEmptyBody,
        action: FilledButton(
          onPressed: _loadDemo,
          child: Text(l.settingsDemoLoad),
        ),
      );
    }
    final labels = ref.watch(labelsProvider).value ?? const {};
    final entries = <_Entry>[];
    if (query.sort1.criterion.groupable) {
      for (final g in groupWines(
        items,
        query.sort1.criterion,
        colorLabel: (c) => labels['couleur:$c'] ?? c,
      )) {
        entries.add(_Entry.group(g));
        if (!_collapsed.contains(g.key)) {
          entries.addAll(g.items.map(_Entry.wine));
        }
      }
    } else {
      entries.addAll(items.map(_Entry.wine));
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = NumberFormat.simpleCurrency(
      locale: locale,
      name: settings.currency,
    );
    // CMP-02 : alerte du mois en tête de la liste.
    return Column(
      children: [
        const MonthlyAlertBanner(),
        Expanded(
          child: ListView.builder(
            key: const ValueKey('wine-list'),
            controller: _scroll,
            padding: const EdgeInsets.only(
              top: SpacingTokens.xs,
              bottom: SpacingTokens.xxl * 3,
            ),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              if (e.group != null) {
                final g = e.group!;
                return _GroupHeader(
                  group: g,
                  collapsed: _collapsed.contains(g.key),
                  onTap: () => setState(
                    () => _collapsed.contains(g.key)
                        ? _collapsed.remove(g.key)
                        : _collapsed.add(g.key),
                  ),
                );
              }
              final w = e.wine!;
              final selected = _selected.contains(w.id);
              void toggle() => setState(
                () => selected ? _selected.remove(w.id) : _selected.add(w.id),
              );
              final tile = settings.compactView
                  ? CompactWineRow(
                      item: w,
                      selected: selected,
                      onTap: _selected.isEmpty ? () => _openWine(w) : toggle,
                      onLongPress: toggle,
                    )
                  : WineCard(
                      item: w,
                      currency: currency,
                      showMarketPrice: settings.cardPrice == CardPrice.market,
                      selected: selected,
                      onTap: _selected.isEmpty ? () => _openWine(w) : toggle,
                      onLongPress: toggle,
                    );
              if (_selected.isNotEmpty || w.primaryLotId == null) return tile;
              // Glisser vers la gauche ouvre une bouteille, annulable 5 s.
              return Dismissible(
                key: ValueKey('swipe-${w.id}'),
                direction: DismissDirection.endToStart,
                background: _SwipeBackground(label: l.openOneBottle),
                confirmDismiss: (_) async {
                  await _openBottle(w);
                  return false;
                },
                child: tile,
              );
            },
          ),
        ),
      ],
    );
  }

  void _openWine(WineListItem w) => context.push('/fiche/${w.id}');

  Future<void> _openBottle(WineListItem w) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final stock = ref.read(stockServiceProvider);
    try {
      final action = await stock.open(w.primaryLotId!, 1);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(l.bottleOpened(w.displayName)),
            action: SnackBarAction(
              label: l.undo,
              onPressed: () => stock.undo(action),
            ),
          ),
        );
    } on StockRuleException {
      messenger.showSnackBar(SnackBar(content: Text(l.noStockToOpen)));
    }
  }

  PreferredSizeWidget _mainBar(
    AppLocalizations l,
    CellarSummary? summary,
    AppSettings settings,
  ) {
    final count = settings.listQuery.filters.activeCount;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.wineListTitle),
          if (summary != null)
            Text(
              l.wineListSummary(summary.wines, summary.bottles),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.palette.onAppBar),
            ),
        ],
      ),
      actions: [
        // NFR-03 : compteur des identifications en file d'attente.
        if ((ref.watch(pendingJobsProvider).value ?? 0) > 0)
          IconButton(
            key: const ValueKey('pending-jobs'),
            tooltip: l.pendingJobs(ref.watch(pendingJobsProvider).value!),
            icon: Badge(
              label: Text('${ref.watch(pendingJobsProvider).value}'),
              child: const Icon(Icons.cloud_upload_outlined),
            ),
            onPressed: () => ref.read(enrichmentRunnerProvider.notifier).kick(),
          ),
        IconButton(
          tooltip: l.search,
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _searching = true),
        ),
        IconButton(
          tooltip: l.filters,
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.filter_list),
          ),
          onPressed: _openFilters,
        ),
        IconButton(
          tooltip: settings.compactView ? l.cardView : l.compactView,
          icon: Icon(
            settings.compactView ? Icons.view_agenda_outlined : Icons.view_list,
          ),
          onPressed: () => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(compactView: !s.compactView)),
        ),
      ],
    );
  }

  void _closeSearch() {
    _searching = false;
    _searchController.clear();
    ref.read(searchProvider.notifier).set('');
  }

  PreferredSizeWidget _searchBar(AppLocalizations l) => AppBar(
    leading: IconButton(
      tooltip: l.closeSearch,
      icon: const Icon(Icons.arrow_back),
      onPressed: () => setState(_closeSearch),
    ),
    title: TextField(
      key: const ValueKey('search-field'),
      controller: _searchController,
      autofocus: true,
      style: TextStyle(color: context.palette.onAppBar),
      cursorColor: context.palette.onAppBar,
      decoration: InputDecoration(
        hintText: l.searchHint,
        hintStyle: TextStyle(color: context.palette.onAppBar),
        border: InputBorder.none,
      ),
      onChanged: ref.read(searchProvider.notifier).set,
    ),
  );

  PreferredSizeWidget _selectionBar(AppLocalizations l) => AppBar(
    leading: IconButton(
      tooltip: l.cancelSelection,
      icon: const Icon(Icons.close),
      onPressed: () => setState(_selected.clear),
    ),
    title: Text(l.selectionCount(_selected.length)),
    actions: [
      IconButton(
        tooltip: l.moveSelection,
        icon: const Icon(Icons.drive_file_move_outline),
        onPressed: () => _runSelection(SelectionAction.move),
      ),
      IconButton(
        tooltip: l.changeOwnerSelection,
        icon: const Icon(Icons.person_outline),
        onPressed: () => _runSelection(SelectionAction.owner),
      ),
      IconButton(
        key: const ValueKey('selection-prices'),
        tooltip: l.refreshPrice,
        icon: const Icon(Icons.euro),
        onPressed: () async {
          await refreshAllPrices(context, ref, wineIds: _selected.toList());
          if (mounted) setState(_selected.clear);
        },
      ),
      PopupMenuButton<void>(
        itemBuilder: (_) => [
          for (final label in [l.laterPdf, l.laterExcel, l.laterEnrich])
            PopupMenuItem<void>(enabled: false, child: Text(label)),
        ],
      ),
    ],
  );

  Future<void> _runSelection(SelectionAction action) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final done = await runSelectionAction(context, ref, action, _selected);
    if (done == null || !mounted) return;
    setState(_selected.clear);
    messenger.showSnackBar(SnackBar(content: Text(l.selectionDone(done))));
  }

  Widget _fabs(AppLocalizations l) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (_showBackToTop) ...[
        FloatingActionButton.small(
          heroTag: 'back-to-top',
          tooltip: l.backToTop,
          onPressed: () => _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
          child: const Icon(Icons.vertical_align_top),
        ),
        const SizedBox(height: SpacingTokens.m),
      ],
      FloatingActionButton(
        heroTag: 'add',
        tooltip: l.addBottle,
        onPressed: () => showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    ],
  );

  Future<void> _openSort(WineQuery query) async {
    final result = await showModalBottomSheet<WineQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SortSheet(query: query),
    );
    if (result != null) _updateQuery((_) => result);
  }

  Future<void> _openFilters() async {
    final current = ref.read(settingsProvider).listQuery;
    final result = await showModalBottomSheet<WineFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FiltersSheet(initial: current.filters),
    );
    if (result != null) _updateQuery((q) => q.copyWith(filters: result));
  }

  Future<void> _loadDemo() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(demoRepositoryProvider).load();
      ref.invalidate(demoCountProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    }
  }
}

class _Entry {
  _Entry.group(WineGroup this.group) : wine = null;
  _Entry.wine(WineListItem this.wine) : group = null;

  final WineGroup? group;
  final WineListItem? wine;
}

/// Chips des critères actifs (capture 01) : tri, filtres supprimables,
/// pastille « N filtres actifs » avec réinitialisation.
class _CriteriaBar extends ConsumerWidget {
  const _CriteriaBar({
    required this.query,
    required this.onSort,
    required this.onReset,
    required this.onFilters,
    required this.onChange,
  });

  final WineQuery query;
  final VoidCallback onSort;
  final VoidCallback onReset;
  final VoidCallback onFilters;
  final void Function(WineQuery Function(WineQuery)) onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = query.filters;
    final labels = ref.watch(labelsProvider).value ?? const {};
    final chips = <Widget>[
      ActionChip(
        key: const ValueKey('sort-chip'),
        avatar: const Icon(Icons.sort),
        label: Text(l.sortChipLabel(1, query.sort1)),
        onPressed: onSort,
      ),
      if (query.sort2 != null)
        ActionChip(
          label: Text(l.sortChipLabel(2, query.sort2!)),
          onPressed: onSort,
        ),
      if (f.stock != StockFilter.inStock)
        _removable(
          l.stockLabel(f.stock),
          () => f.copyWith(stock: StockFilter.inStock),
        ),
      for (final c in f.colors)
        _removable(
          labels['couleur:$c'] ?? c,
          () => f.copyWith(colors: {...f.colors}..remove(c)),
        ),
      for (final s in f.statuses)
        _removable(
          l.statusLabel(s),
          () => f.copyWith(statuses: {...f.statuses}..remove(s)),
        ),
      if (f.favoritesOnly)
        _removable(l.favorite, () => f.copyWith(favoritesOnly: false)),
    ];
    final others =
        f.activeCount -
        (f.stock != StockFilter.inStock ? 1 : 0) -
        (f.colors.isNotEmpty ? 1 : 0) -
        (f.statuses.isNotEmpty ? 1 : 0) -
        (f.favoritesOnly ? 1 : 0);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (f.activeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: onFilters,
                      child: Text(l.activeFilters(f.activeCount)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('reset-filters'),
                    onPressed: onReset,
                    child: Text(l.resetFilters),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: minTouchTarget + SpacingTokens.s,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.m),
              children: [
                for (final c in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.s),
                    child: Center(child: c),
                  ),
                if (others > 0)
                  Center(
                    child: ActionChip(
                      label: Text(l.activeFilters(others)),
                      onPressed: onFilters,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _removable(String label, WineFilters Function() without) => InputChip(
    label: Text(label),
    onDeleted: () => onChange((q) => q.copyWith(filters: without())),
  );
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.group,
    required this.collapsed,
    required this.onTap,
  });

  final WineGroup group;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.l,
          SpacingTokens.m,
          SpacingTokens.l,
          SpacingTokens.xs,
        ),
        child: Row(
          children: [
            Icon(collapsed ? Icons.chevron_right : Icons.expand_more),
            const SizedBox(width: SpacingTokens.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label ?? l.groupUnknown,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: context.palette.primaryText,
                    ),
                  ),
                  Text(
                    l.groupSummary(group.items.length, group.bottles),
                    style: theme.textTheme.bodyMedium,
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

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primary,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: scheme.onPrimary)),
          const SizedBox(width: SpacingTokens.s),
          Icon(Icons.wine_bar, color: scheme.onPrimary),
        ],
      ),
    );
  }
}

/// Squelettes pendant le chargement, jamais d'écran blanc.
class _LoadingList extends StatelessWidget {
  const _LoadingList({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final block = context.palette.separator;
    return Semantics(
      label: label,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, _) => Card(
          child: SizedBox(
            height: SpacingTokens.xxl * 3,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width / 4,
                  child: ColoredBox(color: block),
                ),
                const SizedBox(width: SpacingTokens.m),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final f in const [0.7, 0.5, 0.4])
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.xs,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: f,
                            child: SizedBox(
                              height: SpacingTokens.m,
                              child: ColoredBox(color: block),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
