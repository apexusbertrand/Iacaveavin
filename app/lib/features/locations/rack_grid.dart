import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';
import '../../data/reference_repository.dart';
import '../../domain/comfort.dart';
import '../../domain/wine_detail.dart';
import '../wine_detail/stock_dialogs.dart' show stockErrorText;
import '../wine_list/wine_card.dart';

/// EMP-03 : vue casier. Cases occupées à la couleur du vin, cases vides en
/// gris. Un tap ouvre la fiche, un appui long sur une case vide y range une
/// bouteille.
class RackGrid extends ConsumerWidget {
  const RackGrid({super.key, required this.location, required this.lots});

  final LocationView location;

  /// Lots du sous-arbre : seuls ceux rangés dans ce casier sont dessinés.
  final List<LocationLot> lots;

  static const _cell = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final here = lots.where((x) => x.locationId == location.id).toList();
    final byCell = <String, LocationLot>{};
    for (final lot in here) {
      for (final c in parsePositions(lot.positions)) {
        byCell.putIfAbsent(c, () => lot);
      }
    }
    final unplaced = unplacedBottles(here);
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.gridTitle, style: theme.textTheme.titleMedium),
          Text(l.gridHint, style: theme.textTheme.bodySmall),
          if (unplaced > 0)
            Text(l.gridUnplaced(unplaced), style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.s),
          SingleChildScrollView(
            key: const ValueKey('rack-grid'),
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var r = 0; r < location.rows!; r++)
                  Row(
                    children: [
                      for (var c = 0; c < location.cols!; c++)
                        _Cell(
                          name: cellName(r, c),
                          lot: byCell[cellName(r, c)],
                          size: _cell,
                          onPlace: () => _place(context, ref, cellName(r, c)),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _place(BuildContext context, WidgetRef ref, String cell) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(cellarRepositoryProvider);
    final all = await repo.stockedLots();
    final c = placementCandidates(all, location.id);
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<LocationLot>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PlaceSheet(cell: cell, candidates: c),
    );
    if (picked == null) return;
    try {
      if (picked.locationId == location.id) {
        final current = (picked.positions ?? '').trim();
        await repo.setLotPositions(
          picked.lotId,
          current.isEmpty ? cell : '$current, $cell',
        );
      } else {
        await ref
            .read(stockServiceProvider)
            .transfer(
              picked.lotId,
              1,
              toOwnerId: picked.ownerId,
              toLocationId: location.id,
              toPositions: cell,
            );
      }
      messenger.showSnackBar(SnackBar(content: Text(l.gridPlaced(cell))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(stockErrorText(l, e))));
    }
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.name,
    required this.lot,
    required this.size,
    required this.onPlace,
  });

  final String name;
  final LocationLot? lot;
  final double size;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final occupied = lot != null;
    final color = occupied ? wineColor(lot!.colorCode) : null;
    return Semantics(
      label: occupied ? l.gridCellWine(name, lot!.wineName) : l.gridCell(name),
      button: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          key: ValueKey('cell-$name'),
          color: color?.fill ?? scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RadiusTokens.badge),
          child: InkWell(
            borderRadius: BorderRadius.circular(RadiusTokens.badge),
            onTap: occupied
                ? () => context.push('/fiche/${lot!.wineId}')
                : null,
            onLongPress: occupied ? null : onPlace,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color?.onFill ?? scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceSheet extends StatelessWidget {
  const _PlaceSheet({required this.cell, required this.candidates});

  final String cell;
  final ({List<LocationLot> here, List<LocationLot> elsewhere}) candidates;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget tile(LocationLot lot) => ListTile(
      key: ValueKey('place-${lot.lotId}'),
      leading: BottleIcon(fill: wineColor(lot.colorCode).fill),
      title: Text('${lot.wineName} · ${lot.vintage}'),
      subtitle: Text(
        [lot.ownerName, ?lot.positions].where((s) => s.isNotEmpty).join(' · '),
      ),
      trailing: Text('${lot.bottles}', style: theme.textTheme.titleMedium),
      onTap: () => Navigator.of(context).pop(lot),
    );
    final empty = candidates.here.isEmpty && candidates.elsewhere.isEmpty;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            child: Text(
              l.gridPlaceTitle(cell),
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (empty)
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: Text(l.gridNoCandidate),
            ),
          if (candidates.here.isNotEmpty) ...[
            _Section(l.gridHere),
            for (final lot in candidates.here) tile(lot),
          ],
          if (candidates.elsewhere.isNotEmpty) ...[
            _Section(l.gridElsewhere),
            for (final lot in candidates.elsewhere) tile(lot),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.l,
      SpacingTokens.l,
      SpacingTokens.l,
      SpacingTokens.xs,
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: context.palette.primaryText),
    ),
  );
}
