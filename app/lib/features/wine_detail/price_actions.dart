import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/enrichment_queue.dart';
import '../../data/settings_store.dart';

/// PRX-02, PRX-03 : relevé du prix d'une fiche. Un relevé de moins de
/// 24 heures demande de « forcer ».
Future<void> refreshWinePrice(
  BuildContext context,
  WidgetRef ref,
  String wineId,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final queue = await ref.read(enrichmentQueueProvider.future);
  var r = await queue.enqueuePrice(wineId);
  if (r == PriceEnqueue.tooRecent) {
    if (!context.mounted) return;
    final force = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.priceTooRecentTitle),
        content: Text(l.priceTooRecent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            key: const ValueKey('price-force'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.priceForce),
          ),
        ],
      ),
    );
    if (force != true) return;
    r = await queue.enqueuePrice(wineId, force: true);
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        r == PriceEnqueue.alreadyQueued
            ? l.priceAlreadyQueued
            : l.priceQueuedOne,
      ),
    ),
  );
  await ref.read(enrichmentRunnerProvider.notifier).kick();
}

/// PRX-02 « toute la cave » ou une sélection ([wineIds]) : nombre d'appels
/// et quota restant affichés avant confirmation.
Future<void> refreshAllPrices(
  BuildContext context,
  WidgetRef ref, {
  List<String>? wineIds,
}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final queue = await ref.read(enrichmentQueueProvider.future);
  final count = await queue.countPricesToRefresh(wineIds: wineIds);
  final left = await queue.lastKnownPricesLeft();
  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.pricesAllTitle),
      content: Text(
        '${l.pricesAllConfirm(count)}\n'
        '${left == null ? l.pricesQuotaUnknown : l.pricesQuotaLeft(left)}',
        key: const ValueKey('prices-all-summary'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l.cancel),
        ),
        if (count > 0)
          FilledButton(
            key: const ValueKey('prices-all-confirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.confirm),
          ),
      ],
    ),
  );
  if (ok != true) return;
  final queued = await queue.enqueueAllPrices(wineIds: wineIds);
  messenger.showSnackBar(SnackBar(content: Text(l.pricesQueued(queued))));
  await ref.read(enrichmentRunnerProvider.notifier).kick();
}

/// PRX-06 : au lancement, si l'option est active et que le dernier passage
/// date de plus de 30 jours, toutes les fiches sans relevé récent partent en
/// file.
Future<int> autoRefreshPricesIfDue(WidgetRef ref, {DateTime? now}) async {
  final settings = ref.read(settingsProvider);
  final t = now ?? DateTime.now();
  if (!autoPriceRefreshDue(
    enabled: settings.autoPriceRefresh,
    last: settings.lastAutoPriceRefresh,
    now: t,
  )) {
    return 0;
  }
  final queue = await ref.read(enrichmentQueueProvider.future);
  final n = await queue.enqueueAllPrices();
  await ref
      .read(settingsProvider.notifier)
      .update((s) => s.copyWith(lastAutoPriceRefresh: t));
  if (n > 0) await ref.read(enrichmentRunnerProvider.notifier).kick();
  return n;
}
