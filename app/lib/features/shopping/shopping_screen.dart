import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../to_drink/comfort_providers.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;

/// CMP-03 : vins à racheter ou repérés ailleurs.
class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final label = TextEditingController();
    final qty = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.shoppingAdd),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('shopping-label'),
                controller: label,
                autofocus: true,
                decoration: InputDecoration(labelText: l.shoppingLabel),
              ),
              TextField(
                key: const ValueKey('shopping-qty'),
                controller: qty,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.shoppingQuantity),
              ),
              TextField(
                key: const ValueKey('shopping-note'),
                controller: note,
                decoration: InputDecoration(labelText: l.shoppingNote),
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
            key: const ValueKey('shopping-save'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok != true || label.text.trim().isEmpty) return;
    await ref
        .read(comfortRepositoryProvider)
        .addShopping(
          cellarId: await ref.read(bootstrapProvider.future),
          label: label.text,
          quantity: int.tryParse(qty.text),
          note: note.text,
        );
    messenger.showSnackBar(SnackBar(content: Text(l.shoppingAdded)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(comfortRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.navShoppingList)),
      drawer: const AppDrawer(current: AppDestination.shoppingList),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('shopping-add'),
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.shoppingAdd),
      ),
      body: ref
          .watch(shoppingProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => MessageStateView(
              icon: Icons.error_outline,
              isError: true,
              title: l.operationFailed('$e'),
            ),
            data: (items) => items.isEmpty
                ? MessageStateView(
                    icon: Icons.shopping_cart_outlined,
                    title: l.shoppingEmpty,
                  )
                : ListView.builder(
                    key: const ValueKey('shopping-list'),
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final x = items[i];
                      final details = [
                        if (x.quantite != null)
                          l.shoppingQuantityValue(x.quantite!),
                        ?x.note,
                      ];
                      return ListTile(
                        key: ValueKey('shopping-${x.libelle}'),
                        leading: Checkbox(
                          value: x.achete,
                          semanticLabel: l.shoppingBought,
                          onChanged: (v) => repo.setBought(x.id, v ?? false),
                        ),
                        title: Text(
                          x.libelle,
                          style: x.achete
                              ? theme.textTheme.bodyLarge?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        subtitle: details.isEmpty
                            ? null
                            : Text(details.join(' · ')),
                        onTap: x.ficheId == null
                            ? null
                            : () => context.push('/fiche/${x.ficheId}'),
                        trailing: IconButton(
                          tooltip: l.shoppingDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await confirm(
                              context,
                              title: l.shoppingDelete,
                              body: x.libelle,
                              action: l.delete,
                            );
                            if (ok) await repo.deleteShopping(x.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
    );
  }
}
