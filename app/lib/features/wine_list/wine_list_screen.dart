import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../domain/wine_list_item.dart';
import 'wine_card.dart';

/// « Mes vins », en lecture au lot 0. Tri, filtres et groupes : lot 1.
class WineListScreen extends ConsumerStatefulWidget {
  const WineListScreen({super.key});

  @override
  ConsumerState<WineListScreen> createState() => _WineListScreenState();
}

class _WineListScreenState extends ConsumerState<WineListScreen> {
  final _scroll = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Bouton « Haut de la page » après deux écrans de défilement.
  void _onScroll() {
    final show =
        _scroll.hasClients &&
        _scroll.offset > 2 * _scroll.position.viewportDimension;
    if (show != _showBackToTop) setState(() => _showBackToTop = show);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wines = ref.watch(wineListProvider);
    final summary = wines.whenData(CellarSummary.of).value;

    return Scaffold(
      appBar: AppBar(
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
      ),
      drawer: const AppDrawer(current: AppDestination.myWines),
      floatingActionButton: Column(
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
            onPressed: () =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.addBottleLater))),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: wines.when(
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
        data: (items) => items.isEmpty
            ? MessageStateView(
                icon: Icons.wine_bar_outlined,
                title: l.wineListEmptyTitle,
                body: l.wineListEmptyBody,
                action: FilledButton(
                  onPressed: _loadDemo,
                  child: Text(l.settingsDemoLoad),
                ),
              )
            : _WineList(items: items, controller: _scroll),
      ),
    );
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

class _WineList extends StatelessWidget {
  const _WineList({required this.items, required this.controller});

  final List<WineListItem> items;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = NumberFormat.simpleCurrency(locale: locale, name: 'EUR');
    return ListView.builder(
      key: const ValueKey('wine-list'),
      controller: controller,
      padding: const EdgeInsets.only(
        top: SpacingTokens.s,
        bottom: SpacingTokens.xxl * 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          WineCard(item: items[index], currency: currency),
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
