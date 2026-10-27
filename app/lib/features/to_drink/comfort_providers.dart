import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/comfort_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/comfort.dart';

final comfortRepositoryProvider = Provider<ComfortRepository>(
  (ref) => ComfortRepository(ref.watch(databaseProvider)),
);

/// CMP-03 : liste d'achats.
final shoppingProvider = StreamProvider<List<ShoppingItem>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(comfortRepositoryProvider).watchShopping();
});

/// CMP-05 : historique des dégustations.
final tastingsProvider = StreamProvider<List<TastingEntry>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(comfortRepositoryProvider).watchTastings();
});

/// CMP-02 : alerte du mois, null si elle n'est pas à montrer.
final monthlyAlertProvider = Provider<MonthlyAlert?>((ref) {
  final items = ref.watch(wineListProvider).value;
  if (items == null) return null;
  final settings = ref.watch(settingsProvider);
  final now = DateTime.now();
  final alert = monthlyAlert(items, ref.watch(currentYearProvider));
  return alertDue(
        enabled: settings.notifications,
        dismissedMonth: settings.alertSeenMonth,
        now: now,
        alert: alert,
      )
      ? alert
      : null;
});
