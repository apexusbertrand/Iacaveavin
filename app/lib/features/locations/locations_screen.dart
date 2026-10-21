import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/reference_repository.dart';
import '../../domain/wine_detail.dart';
import '../wine_detail/stock_dialogs.dart';
import '../wine_list/wine_card.dart';

/// Emplacements (EMP-01, EMP-02, EMP-05) : arbre sur 4 niveaux.
class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locations = ref.watch(locationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navLocations),
        actions: [
          IconButton(
            tooltip: l.inventory,
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => context.push('/inventaire'),
          ),
        ],
      ),
      drawer: const AppDrawer(current: AppDestination.locations),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addLocation,
        onPressed: () => editLocation(context, ref),
        child: const Icon(Icons.add),
      ),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
          action: FilledButton(
            onPressed: () => ref.invalidate(locationsProvider),
            child: Text(l.retry),
          ),
        ),
        data: (list) => list.isEmpty
            ? MessageStateView(
                icon: Icons.grid_view_outlined,
                title: l.locationsEmpty,
                body: l.locationsEmptyBody,
                action: FilledButton(
                  onPressed: () => editLocation(context, ref),
                  child: Text(l.addLocation),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xxl * 3),
                itemCount: list.length,
                itemBuilder: (context, i) => _LocationTile(location: list[i]),
              ),
      ),
    );
  }
}

class _LocationTile extends ConsumerWidget {
  const _LocationTile({required this.location});

  final LocationView location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loc = location;
    final fill = loc.fillRate;
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: SpacingTokens.l + SpacingTokens.xl * loc.depth,
        right: SpacingTokens.s,
      ),
      leading: Icon(_icon(loc.type)),
      title: Text(loc.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              l.locationTypeLabel(loc.type),
              if (loc.capacity != null)
                l.locationFill(
                  loc.bottles,
                  loc.capacity!,
                  ((fill ?? 0) * 100).round(),
                )
              else
                l.locationBottles(loc.bottles),
            ].join(' · '),
          ),
          if (fill != null)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.xs),
              child: LinearProgressIndicator(
                value: fill.clamp(0, 1),
                color: loc.overCapacity
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                backgroundColor: context.palette.separator,
              ),
            ),
          // EMP-05 : alerte non bloquante au-delà de la capacité.
          if (loc.overCapacity)
            Text(
              l.overCapacity,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
      onTap: () => context.push('/emplacements/${loc.id}'),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          switch (v) {
            case 'sub':
              await editLocation(context, ref, parentId: loc.id);
            case 'edit':
              await editLocation(context, ref, existing: loc);
            case 'delete':
              await _delete(context, ref, loc);
          }
        },
        itemBuilder: (_) => [
          if (loc.depth < 3)
            PopupMenuItem(value: 'sub', child: Text(l.addSubLocation)),
          PopupMenuItem(value: 'edit', child: Text(l.editLocation)),
          PopupMenuItem(value: 'delete', child: Text(l.deleteLocation)),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    LocationView loc,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(referenceRepositoryProvider).deleteLocation(loc.id);
    } on ReferenceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(referenceErrorText(l, e))));
    }
  }
}

IconData _icon(String type) => switch (type) {
  'cave' => Icons.house_outlined,
  'meuble' => Icons.kitchen_outlined,
  'casier' => Icons.grid_on,
  'clayette' => Icons.view_stream_outlined,
  _ => Icons.inventory_2_outlined,
};

String referenceErrorText(AppLocalizations l, ReferenceException e) =>
    switch (e.code) {
      'depth' => l.errorDepth,
      'grid' => l.errorGrid,
      'not_empty' => l.errorNotEmpty,
      'in_use' => l.errorInUse,
      'duplicate' => l.errorDuplicate,
      'csv' => l.errorCsv,
      _ => l.operationFailed(e.code),
    };

/// Création ou modification d'un emplacement (EMP-01, EMP-02).
Future<void> editLocation(
  BuildContext context,
  WidgetRef ref, {
  LocationView? existing,
  String? parentId,
}) async {
  final l = AppLocalizations.of(context);
  final name = TextEditingController(text: existing?.name);
  final rows = TextEditingController(text: existing?.rows?.toString());
  final cols = TextEditingController(text: existing?.cols?.toString());
  final capacity = TextEditingController(text: existing?.capacity?.toString());
  var type = existing?.type ?? (parentId == null ? 'cave' : 'casier');
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? l.addLocation : l.editLocation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('location-name'),
                controller: name,
                autofocus: true,
                decoration: InputDecoration(labelText: l.locationName),
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: l.locationType),
                items: [
                  for (final t in const [
                    'cave',
                    'meuble',
                    'casier',
                    'clayette',
                    'autre',
                  ])
                    DropdownMenuItem(
                      value: t,
                      child: Text(l.locationTypeLabel(t)),
                    ),
                ],
                onChanged: (v) => setState(() => type = v ?? type),
              ),
              TextField(
                controller: rows,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.locationRows),
              ),
              TextField(
                controller: cols,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.locationCols),
              ),
              TextField(
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.locationCapacity),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('location-save'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
  if (ok == true && name.text.trim().isNotEmpty && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(referenceRepositoryProvider)
          .saveLocation(
            id: existing?.id,
            cellarId: await ref.read(bootstrapProvider.future),
            name: name.text,
            type: type,
            parentId: existing?.parentId ?? parentId,
            rows: int.tryParse(rows.text.trim()),
            cols: int.tryParse(cols.text.trim()),
            capacity: int.tryParse(capacity.text.trim()),
          );
    } on ReferenceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(referenceErrorText(l, e))));
    }
  }
}

/// Clé : identifiants d'emplacements triés, séparés par des virgules.
final _lotsInProvider = StreamProvider.family<List<LocationLot>, String>((
  ref,
  key,
) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref
      .watch(cellarRepositoryProvider)
      .watchLotsIn(key.split(',').toSet());
});

String _key(Iterable<String> ids) => (ids.toList()..sort()).join(',');

/// Détail d'un emplacement. EMP-04 « Où est-il ? » : ouvert depuis une
/// fiche, les lots et positions de ce vin sont mis en évidence.
class LocationDetailScreen extends ConsumerWidget {
  const LocationDetailScreen({
    super.key,
    required this.locationId,
    this.highlightWineId,
  });

  final String locationId;
  final String? highlightWineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(locationsProvider).value;
    if (all == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final loc = all.where((x) => x.id == locationId).firstOrNull;
    if (loc == null) {
      return Scaffold(
        appBar: AppBar(),
        body: MessageStateView(icon: Icons.search_off, title: l.noLocation),
      );
    }
    final subtree = _subtree(all, locationId);
    final lots = ref.watch(_lotsInProvider(_key(subtree))).value ?? const [];
    final mine = lots.where((x) => x.wineId == highlightWineId).toList();
    final positions = mine
        .map((x) => x.positions)
        .whereType<String>()
        .join(', ');
    return Scaffold(
      appBar: AppBar(title: Text(loc.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _path(all, locationId),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.palette.primaryText,
                  ),
                ),
                Text(
                  [
                    l.locationTypeLabel(loc.type),
                    if (loc.rows != null && loc.cols != null)
                      l.locationGrid(loc.rows!, loc.cols!),
                    if (loc.capacity != null)
                      l.locationFill(
                        loc.bottles,
                        loc.capacity!,
                        ((loc.fillRate ?? 0) * 100).round(),
                      )
                    else
                      l.locationBottles(loc.bottles),
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium,
                ),
                if (highlightWineId != null && positions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.m),
                    child: Chip(
                      backgroundColor: theme.colorScheme.primary,
                      label: Text(
                        l.highlightedPositions(positions),
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            child: Text(l.locationWines, style: theme.textTheme.titleMedium),
          ),
          for (final lot in lots)
            ListTile(
              selected: lot.wineId == highlightWineId,
              selectedTileColor: theme.colorScheme.primary.withValues(
                alpha: 0.15,
              ),
              leading: BottleIcon(fill: wineColor(lot.colorCode).fill),
              title: Text('${lot.wineName} · ${lot.vintage}'),
              subtitle: Text(
                [
                  lot.ownerName,
                  if (lot.positions != null) lot.positions!,
                  if (lot.locationId != locationId) _path(all, lot.locationId),
                ].join(' · '),
              ),
              trailing: Text(
                '${lot.bottles}',
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => context.push('/fiche/${lot.wineId}'),
            ),
          if (lots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: Text(l.locationBottles(0)),
            ),
        ],
      ),
    );
  }
}

Set<String> _subtree(List<LocationView> all, String root) {
  final ids = {root};
  var grew = true;
  while (grew) {
    grew = false;
    for (final x in all) {
      if (x.parentId != null && ids.contains(x.parentId) && ids.add(x.id)) {
        grew = true;
      }
    }
  }
  return ids;
}

String _path(List<LocationView> all, String id) {
  final byId = {for (final x in all) x.id: x};
  final names = <String>[];
  String? current = id;
  while (current != null && names.length < 8) {
    final x = byId[current];
    if (x == null) break;
    names.insert(0, x.name);
    current = x.parentId;
  }
  return names.join(' > ');
}

/// STK-04 : inventaire emplacement par emplacement, chaque lot confirmé ou
/// corrigé, rapport final des écarts.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _index = 0;
  final _checked = <String>{};
  final _gaps = <(String, int, int)>[];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(locationsProvider).value;
    if (all == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.inventory)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final steps = all.where((x) => x.directBottles > 0).toList();
    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.inventory)),
        body: MessageStateView(
          icon: Icons.fact_check_outlined,
          title: l.inventoryEmpty,
        ),
      );
    }
    final loc = steps[_index.clamp(0, steps.length - 1)];
    final lots = (ref.watch(_lotsInProvider(loc.id)).value ?? const [])
        .toList();
    final done = lots.where((x) => _checked.contains(x.lotId)).length;
    final last = _index >= steps.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(l.inventoryTitle(_path(all, loc.id)))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Text(
              l.inventoryProgress(done, lots.length),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final lot in lots)
                  ListTile(
                    leading: Icon(
                      _checked.contains(lot.lotId)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text('${lot.wineName} · ${lot.vintage}'),
                    subtitle: Text(
                      [
                        lot.ownerName,
                        if (lot.positions != null) lot.positions!,
                      ].join(' · '),
                    ),
                    trailing: Wrap(
                      spacing: SpacingTokens.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${lot.bottles}',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          tooltip: l.inventoryConfirm,
                          icon: const Icon(Icons.check),
                          onPressed: () =>
                              setState(() => _checked.add(lot.lotId)),
                        ),
                        IconButton(
                          tooltip: l.inventoryCorrect,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _correct(lot),
                        ),
                      ],
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
                  key: const ValueKey('inventory-next'),
                  onPressed: last
                      ? () => _report(context)
                      : () => setState(() => _index++),
                  child: Text(last ? l.inventoryFinish : l.inventoryNext),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _correct(LocationLot lot) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${lot.bottles}');
    final actual = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.adjustTitle),
        content: TextField(
          key: const ValueKey('inventory-quantity'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.fieldQuantity),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('inventory-save'),
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (actual == null || !mounted) return;
    try {
      final action = await ref
          .read(stockServiceProvider)
          .adjust(lot.lotId, actual, 'inventaire');
      setState(() {
        _checked.add(lot.lotId);
        if (action != null) {
          _gaps.add(('${lot.wineName} · ${lot.vintage}', lot.bottles, actual));
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(stockErrorText(l, e))));
      }
    }
  }

  Future<void> _report(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.inventoryReport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _gaps.isEmpty ? l.inventoryNoGap : l.inventoryGaps(_gaps.length),
            ),
            for (final (wine, before, after) in _gaps)
              Text(l.inventoryReportLine(wine, before, after)),
          ],
        ),
        actions: [
          TextButton(
            key: const ValueKey('inventory-close'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
    if (context.mounted) context.pop();
  }
}
