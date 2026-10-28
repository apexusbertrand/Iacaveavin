import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/wine_list_item.dart';

/// Texte de recherche instantanée (LST-06), non mémorisé.
class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);

/// Fiches affichées : liste complète, tri, filtres et recherche appliqués.
final visibleWinesProvider = Provider<AsyncValue<List<WineListItem>>>((ref) {
  final all = ref.watch(wineListProvider);
  final query = ref.watch(settingsProvider.select((s) => s.listQuery));
  final search = ref.watch(searchProvider);
  final year = ref.watch(currentYearProvider);
  return all.whenData(
    (items) => query.copyWith(search: search).apply(items, year: year),
  );
});
