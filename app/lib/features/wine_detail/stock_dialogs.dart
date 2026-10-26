import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../data/stock_service.dart';
import '../../domain/stock_rules.dart';
import '../../domain/wine_detail.dart';
import '../../domain/wine_validation.dart';
import '../wine_list/selection_actions.dart';

/// Dernier lot utilisé par fiche, proposé en premier (STK-01).
final _lastLot = <String, String>{};

String stockErrorText(AppLocalizations l, Object e) => switch (e) {
  StockRuleException(code: 'negative') => l.stockErrorNegative,
  StockRuleException(code: 'reason_required') => l.stockErrorReason,
  StockRuleException(code: 'same_lot') => l.stockErrorSameLot,
  StockRuleException() => l.stockErrorOther,
  _ => l.operationFailed('$e'),
};

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const ValueKey('confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok == true;
}

/// STK-01 : avec plusieurs lots, l'app demande lequel et propose le dernier
/// utilisé en tête de liste.
Future<LotView?> chooseLot(
  BuildContext context,
  WineDetail wine, {
  bool inStockOnly = false,
}) async {
  final l = AppLocalizations.of(context);
  final lots = wine.lots
      .where((lot) => !inStockOnly || lot.bottles > 0)
      .toList();
  if (lots.isEmpty) return null;
  if (lots.length == 1) return lots.single;
  final last = _lastLot[wine.id];
  lots.sort((a, b) => (b.id == last ? 1 : 0) - (a.id == last ? 1 : 0));
  final id = await pickFromList(
    context,
    title: l.chooseLot,
    options: {
      for (final lot in lots)
        lot.id: [
          l.lotLine(lot.ownerName, _cl(lot.formatCl), lot.bottles),
          lot.locationPath ?? l.noLocation,
        ].join(' · '),
    },
  );
  return id == null ? null : lots.firstWhere((lot) => lot.id == id);
}

String _cl(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');

/// STK-07 : annulation pendant 5 secondes après toute action de stock.
void _undoSnack(
  BuildContext context,
  WidgetRef ref,
  String message,
  StockAction action,
) {
  final l = AppLocalizations.of(context);
  final stock = ref.read(stockServiceProvider);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(message),
        action: SnackBarAction(
          label: l.undo,
          onPressed: () => stock.undo(action),
        ),
      ),
    );
}

Future<bool> addBottles(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
  int count,
) async {
  final l = AppLocalizations.of(context);
  if (wine.lots.isEmpty) {
    return addLotDialog(context, ref, wine, quantity: count);
  }
  final lot = await chooseLot(context, wine);
  if (lot == null || !context.mounted) return false;
  try {
    final action = await ref.read(stockServiceProvider).add(lot.id, count);
    _lastLot[wine.id] = lot.id;
    if (context.mounted) _undoSnack(context, ref, l.stockAdded(count), action);
    return true;
  } catch (e) {
    if (context.mounted) _error(context, e);
    return false;
  }
}

/// STK-02 : ouvrir crée un mouvement `ouverture` et propose une note de
/// dégustation, jamais imposée (FIC-04).
Future<bool> openBottles(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
  int count,
) async {
  final l = AppLocalizations.of(context);
  final lot = await chooseLot(context, wine, inStockOnly: true);
  if (lot == null || !context.mounted) return false;
  try {
    final action = await ref.read(stockServiceProvider).open(lot.id, count);
    _lastLot[wine.id] = lot.id;
    if (!context.mounted) return true;
    _undoSnack(context, ref, l.stockOpened(count), action);
    final note = await confirm(
      context,
      title: l.tastingPrompt,
      body: [
        wine.draft.producer,
        wine.draft.cuvee,
        wine.draft.vintage,
      ].whereType<String>().join(' · '),
      action: l.addTasting,
    );
    if (note && context.mounted) {
      await tastingDialog(
        context,
        ref,
        wine,
        movementId: action.movementIds.single,
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) _error(context, e);
    return false;
  }
}

void _error(BuildContext context, Object e) {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(stockErrorText(l, e))));
}

/// STK-03 : quantité réelle saisie, écart enregistré avec motif obligatoire.
Future<void> adjustDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine, {
  LotView? lot,
}) async {
  final l = AppLocalizations.of(context);
  final target = lot ?? await chooseLot(context, wine);
  if (target == null || !context.mounted) return;
  final controller = TextEditingController(text: '${target.bottles}');
  String? reason;
  final result = await showDialog<(int, String)>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l.adjustTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('adjust-quantity'),
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.fieldQuantity),
            ),
            const SizedBox(height: SpacingTokens.m),
            DropdownButtonFormField<String>(
              key: const ValueKey('adjust-reason'),
              initialValue: reason,
              decoration: InputDecoration(labelText: l.adjustReason),
              items: [
                for (final r in adjustmentReasons)
                  DropdownMenuItem(value: r, child: Text(_cap(r))),
              ],
              onChanged: (v) => setState(() => reason = v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('adjust-save'),
            onPressed: reason == null || int.tryParse(controller.text) == null
                ? null
                : () =>
                      Navigator.of(context)
                          .pop((int.parse(controller.text), reason!)),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
  if (result == null || !context.mounted) return;
  try {
    final action = await ref
        .read(stockServiceProvider)
        .adjust(target.id, result.$1, result.$2);
    if (!context.mounted) return;
    if (action == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.noDifference)));
    } else {
      _undoSnack(
        context,
        ref,
        l.adjustDone(result.$1 - target.bottles),
        action,
      );
    }
  } catch (e) {
    if (context.mounted) _error(context, e);
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// STK-05 : transfert d'emplacement ou de propriétaire, quantité partielle.
Future<void> transferDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final l = AppLocalizations.of(context);
  final lot = await chooseLot(context, wine, inStockOnly: true);
  if (lot == null || !context.mounted) return;
  final owners = await ref.read(referenceRepositoryProvider).owners();
  final locations = await ref.read(referenceRepositoryProvider).locations();
  if (!context.mounted) return;
  var qty = lot.bottles;
  String ownerId = lot.ownerId;
  String? locationId = lot.locationId;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l.transferTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l.decrease,
                    onPressed: qty > 1 ? () => setState(() => qty--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Text(
                      l.bottleCount(qty),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: l.increase,
                    onPressed: qty < lot.bottles
                        ? () => setState(() => qty++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                initialValue: ownerId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.fieldOwner),
                items: [
                  for (final o in owners)
                    DropdownMenuItem(value: o.id, child: Text(o.name)),
                ],
                onChanged: (v) => setState(() => ownerId = v ?? ownerId),
              ),
              DropdownButtonFormField<String?>(
                initialValue: locationId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.fieldLocation),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.noLocation)),
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
                onChanged: (v) => setState(() => locationId = v),
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
            key: const ValueKey('transfer-save'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.transfer),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final action = await ref
        .read(stockServiceProvider)
        .transfer(lot.id, qty, toOwnerId: ownerId, toLocationId: locationId);
    if (context.mounted) _undoSnack(context, ref, l.transferDone, action);
  } catch (e) {
    if (context.mounted) _error(context, e);
  }
}

/// STK-06 : réapprovisionner, c'est-à-dire créer un nouveau lot.
Future<bool> addLotDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine, {
  int quantity = 1,
}) async {
  final l = AppLocalizations.of(context);
  final cellarId = await ref.read(bootstrapProvider.future);
  final settings = ref.read(settingsProvider);
  final defaultOwner =
      settings.defaultOwnerId ??
      await ref.read(referenceRepositoryProvider).defaultOwner(cellarId);
  if (!context.mounted) return false;
  final draft = await showModalBottomSheet<LotDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: LotForm(
        title: l.newLot,
        scrollable: true,
        initial: LotDraft(
          ownerId: defaultOwner,
          quantity: quantity,
          locationId: settings.defaultLocationId,
        ),
        onSubmit: (d) => Navigator.of(context).pop(d),
      ),
    ),
  );
  if (draft == null) return false;
  await ref.read(cellarRepositoryProvider).addLot(wine.id, draft);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.stockAdded(draft.quantity))));
  }
  return true;
}

/// Saisie d'un lot : propriétaire, emplacement, positions, quantité, format,
/// prix d'achat unitaire TTC (PRX-01), date. Le fournisseur n'est plus saisi
/// ici (décision T79) ; celui d'un lot existant est conservé.
class LotForm extends ConsumerStatefulWidget {
  const LotForm({
    super.key,
    required this.initial,
    this.onSubmit,
    this.onChanged,
    this.title,
    this.scrollable = false,
  });

  final LotDraft initial;
  final String? title;

  /// Feuille modale : les champs défilent et « Enregistrer » reste visible en
  /// bas, au-dessus de la barre de navigation et du clavier.
  final bool scrollable;
  final ValueChanged<LotDraft>? onSubmit;

  /// Utilisé dans le formulaire de fiche : chaque modification remonte.
  final ValueChanged<LotDraft?>? onChanged;

  @override
  ConsumerState<LotForm> createState() => _LotFormState();
}

class _LotFormState extends ConsumerState<LotForm> {
  late String _owner = widget.initial.ownerId;
  late String? _location = widget.initial.locationId;
  late double _format = widget.initial.formatCl;
  late final _qty = TextEditingController(text: '${widget.initial.quantity}');
  late final _price = TextEditingController(
    text: widget.initial.unitPrice == null
        ? ''
        : '${widget.initial.unitPrice}'.replaceAll('.', ','),
  );
  late final _positions = TextEditingController(text: widget.initial.positions);
  late final _date = TextEditingController(
    text:
        widget.initial.purchaseDate ??
        DateTime.now().toIso8601String().substring(0, 10),
  );
  String? _positionsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    for (final c in [_qty, _price, _positions, _date]) {
      c.dispose();
    }
    super.dispose();
  }

  LotDraft? _draft() {
    final q = int.tryParse(_qty.text.trim());
    if (q == null || q < 0) return null;
    final p = _price.text.trim().isEmpty
        ? null
        : double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (_price.text.trim().isNotEmpty && p == null) return null;
    final locations = ref.read(locationsProvider).value ?? const [];
    final loc = locations.where((x) => x.id == _location).firstOrNull;
    final cells = parsePositions(
      _positions.text,
      rows: loc?.rows,
      cols: loc?.cols,
    );
    _positionsError = cells == null
        ? AppLocalizations.of(context).errorPositions
        : null;
    if (cells == null) return null;
    return LotDraft(
      ownerId: _owner,
      quantity: q,
      formatCl: _format,
      locationId: _location,
      positions: cells.isEmpty ? null : cells.join(', '),
      unitPrice: p,
      purchaseDate: _date.text.trim().isEmpty ? null : _date.text.trim(),
      supplier: widget.initial.supplier,
    );
  }

  void _emit() {
    if (!mounted) return;
    final d = _draft();
    setState(() {});
    widget.onChanged?.call(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owners = ref.watch(ownersProvider).value ?? const [];
    final locations = ref.watch(locationsProvider).value ?? const [];
    final formats = ref.watch(listValuesProvider('format')).value ?? const [];
    final ownerIds = owners.map((o) => o.id).toSet();
    final save = FilledButton(
      key: const ValueKey('lot-save'),
      onPressed: _draft() == null ? null : () => widget.onSubmit!(_draft()!),
      child: Text(l.save),
    );
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.m),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        TextField(
          key: const ValueKey('lot-quantity'),
          controller: _qty,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.fieldQuantity),
          onChanged: (_) => _emit(),
        ),
        DropdownButtonFormField<String>(
          initialValue: ownerIds.contains(_owner) ? _owner : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.fieldOwner),
          items: [
            for (final o in owners)
              DropdownMenuItem(value: o.id, child: Text(o.name)),
          ],
          onChanged: (v) {
            _owner = v ?? _owner;
            _emit();
          },
        ),
        DropdownButtonFormField<String?>(
          initialValue: _location,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.fieldLocation),
          items: [
            DropdownMenuItem(value: null, child: Text(l.noLocation)),
            for (final loc in locations)
              DropdownMenuItem(
                value: loc.id,
                child: Padding(
                  padding: EdgeInsets.only(left: SpacingTokens.l * loc.depth),
                  child: Text(loc.name),
                ),
              ),
          ],
          onChanged: (v) {
            _location = v;
            _emit();
          },
        ),
        TextField(
          controller: _positions,
          decoration: InputDecoration(
            labelText: l.fieldPositions,
            hintText: l.fieldPositionsHint,
            errorText: _positionsError,
          ),
          onChanged: (_) => _emit(),
        ),
        DropdownButtonFormField<double>(
          initialValue: _format,
          decoration: InputDecoration(labelText: l.fieldFormat),
          items: [
            for (final f in formats.where((f) => f.active))
              if (double.tryParse(f.code) != null)
                DropdownMenuItem(
                  value: double.parse(f.code),
                  child: Text(f.label),
                ),
            if (!formats.any((f) => double.tryParse(f.code) == _format))
              DropdownMenuItem(
                value: _format,
                child: Text(l.formatCl(_cl(_format))),
              ),
          ],
          onChanged: (v) {
            _format = v ?? _format;
            _emit();
          },
        ),
        TextField(
          key: const ValueKey('lot-price'),
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.fieldUnitPrice),
          onChanged: (_) => _emit(),
        ),
        TextField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: l.fieldPurchaseDate),
          onChanged: (_) => _emit(),
        ),
        if (widget.onSubmit != null && !widget.scrollable) ...[
          const SizedBox(height: SpacingTokens.l),
          save,
        ],
      ],
    );
    if (!widget.scrollable) return fields;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.l,
              SpacingTokens.l,
              SpacingTokens.l,
              0,
            ),
            child: fields,
          ),
        ),
        if (widget.onSubmit != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: save,
            ),
          ),
      ],
    );
  }
}

/// FIC-04 : note personnelle, sur l'échelle des réglages (20 ou 100).
Future<void> tastingDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine, {
  String? movementId,
}) async {
  final l = AppLocalizations.of(context);
  final scale = ref.read(settingsProvider).personalScale;
  final score = TextEditingController();
  final dish = TextEditingController();
  final comment = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.tastingTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('tasting-score'),
              controller: score,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l.tastingScore(scale)),
            ),
            TextField(
              controller: dish,
              decoration: InputDecoration(labelText: l.tastingDish),
            ),
            TextField(
              controller: comment,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.tastingComment),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.later),
        ),
        TextButton(
          key: const ValueKey('tasting-save'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.save),
        ),
      ],
    ),
  );
  if (ok == true) {
    final value = double.tryParse(score.text.trim().replaceAll(',', '.'));
    final cellarId = await ref.read(bootstrapProvider.future);
    await ref
        .read(cellarRepositoryProvider)
        .addTasting(
          wineId: wine.id,
          cellarId: cellarId,
          score: value?.clamp(0, scale).toDouble(),
          dish: dish.text,
          comment: comment.text,
          movementId: movementId,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.tastingSaved)));
    }
  }
}
