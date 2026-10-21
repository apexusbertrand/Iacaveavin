import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';

enum SelectionAction { move, owner }

/// LST-08 : déplacer ou changer de propriétaire pour une sélection. Chaque
/// lot en stock est transféré en entier (STK-05, STK-R5) : le stock ne change
/// que par des mouvements. Renvoie le nombre de fiches traitées, ou null si
/// l'utilisateur annule.
Future<int?> runSelectionAction(
  BuildContext context,
  WidgetRef ref,
  SelectionAction action,
  Set<String> wineIds,
) async {
  final l = AppLocalizations.of(context);
  final String? target;
  if (action == SelectionAction.move) {
    final locations = await ref.read(referenceRepositoryProvider).locations();
    if (!context.mounted) return null;
    target = await pickFromList(
      context,
      title: l.moveSelection,
      options: {for (final loc in locations) loc.id: loc.name},
      indent: {for (final loc in locations) loc.id: loc.depth},
    );
  } else {
    final owners = await ref.read(referenceRepositoryProvider).owners();
    if (!context.mounted) return null;
    target = await pickFromList(
      context,
      title: l.changeOwnerSelection,
      options: {for (final o in owners) o.id: o.name},
    );
  }
  if (target == null) return null;
  final repo = ref.read(cellarRepositoryProvider);
  final stock = ref.read(stockServiceProvider);
  var done = 0;
  for (final id in wineIds) {
    final wine = await repo.wine(id);
    if (wine == null) continue;
    var changed = false;
    for (final lot in wine.lots.where((l) => l.bottles > 0)) {
      final sameTarget = action == SelectionAction.move
          ? lot.locationId == target
          : lot.ownerId == target;
      if (sameTarget) continue;
      await stock.transfer(
        lot.id,
        lot.bottles,
        toOwnerId: action == SelectionAction.owner ? target : lot.ownerId,
        toLocationId: action == SelectionAction.move ? target : lot.locationId,
        toPositions: action == SelectionAction.move ? null : lot.positions,
      );
      changed = true;
    }
    if (changed) done++;
  }
  return done;
}

/// Choix simple dans une liste (emplacement, propriétaire, lot).
Future<String?> pickFromList(
  BuildContext context, {
  required String title,
  required Map<String, String> options,
  Map<String, int> indent = const {},
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  builder: (context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final e in options.entries)
                  ListTile(
                    contentPadding: EdgeInsets.only(
                      left:
                          SpacingTokens.l +
                          SpacingTokens.l * (indent[e.key] ?? 0),
                      right: SpacingTokens.l,
                    ),
                    title: Text(e.value),
                    onTap: () => Navigator.of(context).pop(e.key),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
