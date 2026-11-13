import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/enrichment_queue.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/wine_detail.dart';

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

/// PRX-07 : prix à date saisi à la main (prix vu chez un caviste, sur un
/// site, à un salon). Il entre dans l'historique et la valeur de la cave
/// comme un relevé, marqué « saisi à la main ».
Future<bool> manualPriceDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final l = AppLocalizations.of(context);
  final currency = ref.read(settingsProvider).currency;
  final formats = {75.0, for (final lot in wine.lots) lot.formatCl}.toList()
    ..sort();
  final price = TextEditingController();
  final where = TextEditingController();
  var day = DateTime.now();
  var format = wine.lots.firstOrNull?.formatCl ?? 75.0;
  String? error;
  String cl(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l.manualPriceTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('manual-price-value'),
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.manualPriceValue(currency),
                  errorText: error,
                ),
              ),
              ListTile(
                key: const ValueKey('manual-price-date'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l.manualPriceDate),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatMediumDate(day),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => day = picked);
                },
              ),
              DropdownButtonFormField<double>(
                key: const ValueKey('manual-price-format'),
                initialValue: format,
                decoration: InputDecoration(labelText: l.fieldFormat),
                items: [
                  for (final f in formats)
                    DropdownMenuItem(value: f, child: Text(l.formatCl(cl(f)))),
                ],
                onChanged: (v) => format = v ?? format,
              ),
              const SizedBox(height: SpacingTokens.s),
              TextField(
                key: const ValueKey('manual-price-where'),
                controller: where,
                decoration: InputDecoration(labelText: l.manualPriceWhere),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            key: const ValueKey('manual-price-save'),
            onPressed: () {
              final v = double.tryParse(
                price.text.trim().replaceAll(' ', '').replaceAll(',', '.'),
              );
              if (v == null || v <= 0) {
                setState(() => error = l.manualPriceInvalid);
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
  final value = double.tryParse(
    price.text.trim().replaceAll(' ', '').replaceAll(',', '.'),
  );
  final place = where.text;
  if (ok != true || value == null) return false;
  await ref
      .read(cellarRepositoryProvider)
      .addManualPrice(
        wine.id,
        date: day.toIso8601String().substring(0, 10),
        price: value,
        formatCl: format,
        where: place,
      );
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.manualPriceSaved)));
  }
  return true;
}
