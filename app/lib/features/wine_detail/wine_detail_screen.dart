import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/flag.dart';
import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/garde.dart';
import '../../domain/price_trend.dart';
import '../../domain/scores.dart';
import '../../domain/wine_detail.dart';
import '../photos/photo_gallery.dart';
import '../photos/photo_library_tab.dart';
import '../wine_list/wine_card.dart';
import 'pdf_actions.dart';
import 'price_actions.dart';
import 'price_chart.dart';
import 'provenance_sheet.dart';
import 'share_sheet.dart';
import 'stock_dialogs.dart';

final wineDetailProvider = StreamProvider.family<WineDetail?, String>((
  ref,
  id,
) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(cellarRepositoryProvider).watchWine(id);
});

/// Fiche vin (FIC-01 à FIC-05, STK-01 à STK-06, PRO-02, EMP-04).
class WineDetailScreen extends ConsumerWidget {
  const WineDetailScreen({super.key, required this.wineId});

  final String wineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(wineDetailProvider(wineId));
    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
          action: FilledButton(
            onPressed: () => ref.invalidate(wineDetailProvider(wineId)),
            child: Text(l.retry),
          ),
        ),
      ),
      data: (w) => w == null
          ? Scaffold(
              appBar: AppBar(),
              body: MessageStateView(
                icon: Icons.search_off,
                title: l.wineNotFound,
              ),
            )
          : _Detail(wine: w),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            wine.draft.producer.isNotEmpty
                ? wine.draft.producer
                : (wine.draft.cuvee ?? '').isNotEmpty
                ? wine.draft.cuvee!
                : AppLocalizations.of(context).unidentifiedWine,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              key: const ValueKey('favorite-toggle'),
              tooltip: wine.draft.favorite ? l.favoriteOff : l.favoriteOn,
              isSelected: wine.draft.favorite,
              icon: const Icon(Icons.star_border),
              selectedIcon: const Icon(Icons.star),
              onPressed: () => ref
                  .read(cellarRepositoryProvider)
                  .setFavorite(wine.id, !wine.draft.favorite),
            ),
            IconButton(
              tooltip: l.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/fiche/${wine.id}/modifier'),
            ),
            PopupMenuButton<String>(
              key: const ValueKey('wine-menu'),
              onSelected: (v) => _menu(context, ref, v),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'restock', child: Text(l.restock)),
                if (wine.lots.isNotEmpty) ...[
                  PopupMenuItem(value: 'adjust', child: Text(l.adjustStock)),
                  PopupMenuItem(value: 'transfer', child: Text(l.transfer)),
                ],
                PopupMenuItem(
                  value: 'duplicate',
                  child: Text(l.duplicateVintage),
                ),
                PopupMenuItem(value: 'reenrich', child: Text(l.reEnrich)),
                PopupMenuItem(value: 'pdf', child: Text(l.winePdf)),
                PopupMenuItem(value: 'share', child: Text(l.shareImage)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: context.palette.onAppBar,
            unselectedLabelColor: context.palette.onAppBar,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l.tabInfo),
              Tab(text: l.tabOperations),
              Tab(text: l.tabTastings),
              Tab(text: l.tabPrices),
              Tab(text: l.tabPhotos),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: StatusBanner(wine: wine)),
            SliverToBoxAdapter(child: _Header(wine: wine)),
          ],
          body: TabBarView(
            children: [
              _InfoTab(wine: wine),
              _OperationsTab(wine: wine),
              _TastingsTab(wine: wine),
              _PricesTab(wine: wine),
              PhotoLibraryTab(wineId: wine.id),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref, String action) async {
    final l = AppLocalizations.of(context);
    switch (action) {
      case 'restock':
        await addLotDialog(context, ref, wine);
      case 'adjust':
        await adjustDialog(context, ref, wine);
      case 'transfer':
        await transferDialog(context, ref, wine);
      case 'duplicate':
        await duplicateVintageDialog(context, ref, wine);
      case 'reenrich':
        await reEnrich(context, ref, wine);
      case 'pdf':
        await shareWinePdf(context, ref, wine.id);
      case 'share':
        await showShareSheet(context, ref, wine);
      case 'delete':
        final ok = await confirm(
          context,
          title: l.deleteWineTitle,
          body: l.deleteWineBody,
          action: l.delete,
        );
        if (!ok || !context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(cellarRepositoryProvider).deleteWine(wine.id);
        if (context.mounted) context.pop();
        messenger.showSnackBar(SnackBar(content: Text(l.wineDeleted)));
    }
  }
}

/// En-tête (capture 03) : identité, compteurs, deux grands boutons.
class _Header extends ConsumerStatefulWidget {
  const _Header({required this.wine});

  final WineDetail wine;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  int _add = 1;
  int _open = 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final w = widget.wine;
    final d = w.draft;
    final color = wineColor(d.color);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: ref.watch(settingsProvider.select((s) => s.currency)),
    );
    final formats = {for (final lot in w.lots) _cl(lot.formatCl)};
    final photos = ref.watch(bottlePhotosProvider(w.id)).value ?? const [];
    final prices = w.lots.map((l) => l.unitPrice).whereType<double>();
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.carte),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 4,
                  height: SpacingTokens.xxl * 4,
                  child: ColoredBox(
                    color: color.fill,
                    child: photos.isEmpty
                        ? Icon(
                            Icons.wine_bar,
                            color: color.onFill,
                            size: SpacingTokens.xxl * 1.5,
                          )
                        // FIC-10 : toutes les photos, un tap ouvre le plein
                        // écran (docs/03).
                        : PhotoCarousel(photos: photos),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        d.producer,
                        d.cuvee,
                      ].whereType<String>().join(' · ').toUpperCase(),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      d.vintage == 'NM' ? l.nonVintage : d.vintage,
                      style: theme.textTheme.displaySmall,
                    ),
                    if (formats.isNotEmpty)
                      Text(
                        formats.map((f) => l.formatCl(f)).join(' · '),
                        style: theme.textTheme.bodyMedium,
                      ),
                    const SizedBox(height: SpacingTokens.xs),
                    Wrap(
                      spacing: SpacingTokens.s,
                      runSpacing: SpacingTokens.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(
                          backgroundColor: color.fill,
                          label: Text(
                            w.label('couleur', d.color),
                            style: TextStyle(color: color.onFill),
                          ),
                        ),
                        if (prices.isNotEmpty)
                          Text(
                            currency.format(prices.last),
                            style: theme.textTheme.bodyLarge,
                          ),
                      ],
                    ),
                    Text(
                      '${l.remaining(w.bottles)} · ${l.consumed(w.consumed)}',
                      key: const ValueKey('counters'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.l),
          _CounterButton(
            key: const ValueKey('add-bottles'),
            label: l.addBottles(_add),
            count: _add,
            filled: false,
            onCount: (v) => setState(() => _add = v),
            onPressed: () async {
              final ok = await addBottles(context, ref, w, _add);
              if (ok && mounted) setState(() => _add = 1);
            },
          ),
          const SizedBox(height: SpacingTokens.s),
          _CounterButton(
            key: const ValueKey('open-bottles'),
            label: l.openBottles(_open),
            count: _open,
            max: w.bottles,
            filled: true,
            onCount: (v) => setState(() => _open = v),
            onPressed: w.bottles == 0
                ? null
                : () async {
                    final ok = await openBottles(context, ref, w, _open);
                    if (ok && mounted) setState(() => _open = 1);
                  },
          ),
        ],
      ),
    );
  }
}

String _cl(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    super.key,
    required this.label,
    required this.count,
    required this.onCount,
    required this.onPressed,
    required this.filled,
    this.max,
  });

  final String label;
  final int count;
  final int? max;
  final bool filled;
  final ValueChanged<int> onCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final button = filled
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton(onPressed: onPressed, child: Text(label));
    return Row(
      children: [
        IconButton(
          tooltip: l.decrease,
          onPressed: count > 1 ? () => onCount(count - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Expanded(child: button),
        IconButton(
          tooltip: l.increase,
          onPressed: max == null || count < max!
              ? () => onCount(count + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

/// Carte de libellés / valeurs (capture 02).
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.l,
                vertical: SpacingTokens.xs,
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.onTap, this.child, this.provenance});

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? child;

  /// FIC-06 : pastille de provenance d'une valeur enrichie.
  final ProvenanceView? provenance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = value == null || value!.isEmpty ? l.emptyValue : value!;
    final p = provenance;
    return InkWell(
      onTap: onTap,
      // PRV-R3 : appui long sur un champ verrouillé pour le déverrouiller.
      onLongPress: p != null && p.locked
          ? () => unlockDialog(context, p)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.l,
            vertical: SpacingTokens.s,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.palette.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.m),
              Expanded(
                flex: 3,
                child:
                    child ??
                    Text(
                      text,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        // PRV-R4 : valeur signalée affichée barrée.
                        decoration: p?.reported == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
              ),
              if (p != null && !p.locked) ProvenanceBadge(provenance: p),
              if (p != null && p.locked)
                Padding(
                  padding: const EdgeInsets.only(left: SpacingTokens.xs),
                  child: Icon(
                    Icons.lock_outline,
                    size: SpacingTokens.l,
                    color: context.palette.textSecondary,
                  ),
                ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  const _InfoTab({required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = wine.draft;
    final year = ref.watch(currentYearProvider);
    final status = cellarStatus(
      year: year,
      start: d.gardeStart,
      peak: d.gardePeak,
      end: d.gardeEnd,
    );
    final inStock = wine.lots.where((lot) => lot.bottles > 0).toList();
    final owners = <String, int>{};
    for (final lot in inStock) {
      owners.update(
        lot.ownerName,
        (v) => v + lot.bottles,
        ifAbsent: () => lot.bottles,
      );
    }
    final positions = inStock
        .map((lot) => lot.positions)
        .whereType<String>()
        .join(', ');
    final garde = d.gardeStart == null && d.gardeEnd == null
        ? null
        : [
            l.gardeRange('${d.gardeStart ?? '?'}', '${d.gardeEnd ?? '?'}'),
            l.statusLabel(status),
            if (wine.gardeSource == 'estimation') l.gardeEstimated,
          ].join(' · ');

    return ListView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xxl),
      children: [
        _InfoCard(
          title: l.sectionOrigin,
          rows: [
            _Row(
              l.fieldCountry,
              '${flagEmoji(d.country)} ${wine.label('pays', d.country)}'.trim(),
            ),
            _Row(
              l.fieldRegion,
              wine.label('region', d.region),
              provenance: wine.provenances['region'],
            ),
            _Row(
              l.fieldSubRegion,
              wine.label('sous_region', d.subRegion),
              provenance: wine.provenances['sous_region'],
            ),
            _Row(
              l.fieldAppellation,
              wine.label('appellation', d.appellation),
              provenance: wine.provenances['appellation'],
            ),
            _Row(
              l.fieldQualitySign,
              wine.label('signe_qualite', d.qualitySign),
            ),
            _Row(
              l.fieldClassification,
              wine.label('classement', d.classification),
            ),
            _Row(
              l.fieldLieuDit,
              d.lieuDit,
              provenance: wine.provenances['lieu_dit'],
            ),
            _Row(
              l.fieldProducer,
              d.producer,
              provenance: wine.provenances['domaine'],
            ),
          ],
        ),
        _InfoCard(
          title: l.sectionCellar,
          rows: [
            for (final lot in inStock)
              _Row(
                l.fieldLocation,
                lot.locationPath ?? l.noLocation,
                // EMP-04 : « Où est-il ? » ouvre l'emplacement.
                onTap: lot.locationId == null
                    ? null
                    : () => context.push(
                        '/emplacements/${lot.locationId}?fiche=${wine.id}',
                      ),
              ),
            if (inStock.isEmpty) _Row(l.fieldLocation, null),
            _Row(l.fieldPositions, positions),
            _Row(
              l.fieldOwners,
              owners.entries
                  .map((e) => l.ownerShare(e.key, e.value))
                  .join(', '),
            ),
            _Row(l.fieldGarde, garde, provenance: wine.provenances['garde']),
            _Row(
              l.fieldAlcohol,
              d.alcohol == null ? null : '${d.alcohol}'.replaceAll('.', ','),
              provenance: wine.provenances['degre'],
            ),
          ],
        ),
        _InfoCard(
          title: l.sectionWine,
          rows: [
            _Row(
              l.fieldGrapes,
              d.grapes.isEmpty ? null : '',
              child: d.grapes.isEmpty
                  ? null
                  : _GrapesBar(grapes: d.grapes, wine: wine),
            ),
            _Row(
              l.fieldPairings,
              d.pairings.map((p) => wine.label('accord_mets', p)).join(', '),
            ),
            _Row(
              l.fieldScores,
              wine.scores.isEmpty ? null : '',
              child: wine.scores.isEmpty
                  ? null
                  : Wrap(
                      alignment: WrapAlignment.end,
                      spacing: SpacingTokens.s,
                      runSpacing: SpacingTokens.xs,
                      children: [
                        for (final s in wine.scores) _ScoreChip(score: s),
                      ],
                    ),
            ),
            _Row(l.fieldType, wine.label('type_vin', d.wineType)),
            _Row(
              l.fieldCertification,
              wine.label('certification', d.certification),
            ),
          ],
        ),
        _InfoCard(
          title: l.sectionComments,
          rows: [
            _Row(
              l.fieldProducerComment,
              d.producerComment,
              provenance: wine.provenances['commentaire_domaine'],
              child: _CommentText(
                text: d.producerComment,
                provenance: wine.provenances['commentaire_domaine'],
              ),
            ),
            _Row(
              l.fieldVintageComment,
              d.vintageComment,
              provenance: wine.provenances['commentaire_millesime'],
              child: _CommentText(
                text: d.vintageComment,
                provenance: wine.provenances['commentaire_millesime'],
              ),
            ),
            _Row(l.fieldPersonalComment, d.personalComment),
          ],
        ),
      ],
    );
  }
}

/// FIC-07 : un commentaire rédigé par l'agent porte la mention du site.
class _CommentText extends StatelessWidget {
  const _CommentText({required this.text, this.provenance});

  final String? text;
  final ProvenanceView? provenance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = text == null || text!.isEmpty ? l.emptyValue : text!;
    final p = provenance;
    final host = p?.url == null ? null : Uri.tryParse(p!.url!)?.host;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          textAlign: TextAlign.end,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: p?.reported == true ? TextDecoration.lineThrough : null,
          ),
        ),
        if (p != null && p.aiWritten && host != null && host.isNotEmpty)
          Text(
            l.aiWritten(host),
            key: const ValueKey('ai-mention'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final CriticScoreValue score;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScoreBadge(
          score: score.score,
          scale: score.scale,
          initial: score.critic.substring(0, 1),
        ),
        Text(score.critic, style: Theme.of(context).textTheme.bodySmall),
        if (score.citedBy != null)
          Text(
            l.citedBy(score.citedBy!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Barre de proportion des cépages (capture 02).
class _GrapesBar extends StatelessWidget {
  const _GrapesBar({required this.grapes, required this.wine});

  final List<GrapeShare> grapes;
  final WineDetail wine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final known = grapes.every((g) => g.percent != null);
    final shades = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      context.palette.primaryText,
      context.palette.textSecondary,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final g in grapes)
          Text(
            g.percent == null
                ? wine.label('cepage', g.code)
                : '${wine.label('cepage', g.code)} ${g.percent} %',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyLarge,
          ),
        if (known) ...[
          const SizedBox(height: SpacingTokens.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.badge),
            child: SizedBox(
              height: SpacingTokens.s,
              child: Row(
                children: [
                  for (final (i, g) in grapes.indexed)
                    Expanded(
                      flex: g.percent!.clamp(1, 100),
                      child: ColoredBox(color: shades[i % shades.length]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OperationsTab extends StatelessWidget {
  const _OperationsTab({required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (wine.movements.isEmpty) {
      return MessageStateView(icon: Icons.history, title: l.noMovements);
    }
    final lots = {for (final lot in wine.lots) lot.id: lot};
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return ListView.separated(
      itemCount: wine.movements.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final m = wine.movements[i];
        final lot = lots[m.lotId];
        final qty = m.quantity > 0 ? '+${m.quantity}' : '${m.quantity}';
        final parsed = DateTime.tryParse(m.date);
        return ListTile(
          leading: Icon(
            m.quantity > 0
                ? Icons.add_circle_outline
                : Icons.remove_circle_outline,
          ),
          title: Text(l.movementLine(l.movementLabel(m.type), qty)),
          subtitle: Text(
            [
              l.movementDetail(
                parsed == null ? m.date : date.format(parsed),
                lot == null
                    ? ''
                    : l.lotLine(lot.ownerName, _cl(lot.formatCl), lot.bottles),
              ),
              if (m.reason != null) m.reason!,
              if (m.comment != null) m.comment!,
            ].join('\n'),
          ),
        );
      },
    );
  }
}

class _TastingsTab extends ConsumerWidget {
  const _TastingsTab({required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scale = ref.watch(settingsProvider.select((s) => s.personalScale));
    final add = Padding(
      padding: const EdgeInsets.all(SpacingTokens.l),
      child: OutlinedButton.icon(
        onPressed: () => tastingDialog(context, ref, wine),
        icon: const Icon(Icons.rate_review_outlined),
        label: Text(l.addTasting),
      ),
    );
    if (wine.tastings.isEmpty) {
      return MessageStateView(
        icon: Icons.rate_review_outlined,
        title: l.noTastings,
        action: add,
      );
    }
    return ListView(
      children: [
        add,
        for (final t in wine.tastings)
          ListTile(
            title: Text(
              [
                t.date,
                if (t.score != null) '${_num(t.score!)} / $scale',
              ].join(' · '),
            ),
            subtitle: Text([t.dish, t.comment].whereType<String>().join('\n')),
          ),
      ],
    );
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');

class _PricesTab extends ConsumerWidget {
  const _PricesTab({required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: ref.watch(settingsProvider.select((s) => s.currency)),
    );
    final last = wine.marketPrices.lastOrNull;
    final trend = priceTrend(wine.marketPrices);
    final series = priceSeries(wine.marketPrices);
    final percent = NumberFormat.percentPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xxl),
      children: [
        _InfoCard(
          title: l.purchasePrices,
          rows: [
            for (final lot in wine.lots)
              _Row(
                l.lotLine(lot.ownerName, _cl(lot.formatCl), lot.bottles),
                lot.unitPrice == null
                    ? l.noPurchasePrice
                    : currency.format(lot.unitPrice),
              ),
          ],
        ),
        _InfoCard(
          title: l.marketPrices,
          rows: [
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last == null
                        ? l.noMarketPrice
                        : last.found && last.price != null
                        ? l.lastMarketPrice(
                            currency.format(last.price),
                            last.date,
                          )
                        : l.priceNotFound(last.date),
                    key: const ValueKey('last-market-price'),
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (last != null && last.found)
                    Text(
                      l.priceOffers(last.offers ?? 0),
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (trend != null)
                    Text(
                      trend.abs() < 0.005
                          ? l.priceTrendFlat
                          : trend > 0
                          ? l.priceTrendUp(percent.format(trend.abs()))
                          : l.priceTrendDown(percent.format(trend.abs())),
                      key: const ValueKey('price-trend'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (last != null && last.found && last.url != null)
                    TextButton.icon(
                      onPressed: () => openLink(last.url!),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        l.priceOpenOffer(
                          last.site ?? Uri.parse(last.url!).host,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (series.length >= 2)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.l,
                ),
                child: Semantics(
                  label: l.priceChartLabel,
                  child: SizedBox(
                    height: 120,
                    child: CustomPaint(
                      key: const ValueKey('price-chart'),
                      painter: PriceChartPainter(
                        series,
                        line: context.palette.primaryText,
                        axis: context.palette.separator,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            for (final p in wine.marketPrices.reversed.skip(1))
              _Row(
                p.date,
                p.found && p.price != null
                    ? currency.format(p.price)
                    : l.priceNotFound(p.date),
              ),
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: OutlinedButton.icon(
                key: const ValueKey('refresh-price'),
                onPressed: () => refreshWinePrice(context, ref, wine.id),
                icon: const Icon(Icons.refresh),
                label: Text(l.refreshPrice),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
