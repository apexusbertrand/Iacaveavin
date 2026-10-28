import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/stats_repository.dart';
import '../../domain/stats.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(databaseProvider)),
);

/// Faits recalculés à chaque changement de la cave (la liste des vins suit
/// déjà fiches, lots, mouvements et prix).
final statFactsProvider = FutureProvider<List<StatFact>>((ref) async {
  await ref.watch(bootstrapProvider.future);
  await ref.watch(wineListProvider.future);
  return ref.watch(statsRepositoryProvider).facts();
});

/// STA-05 : favoris de l'explorateur.
final savedViewsProvider = StreamProvider<List<SavedView>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(statsRepositoryProvider).watchViews();
});
