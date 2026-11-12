import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

import '../domain/garde_rules.dart';
import 'providers.dart';
import 'settings_store.dart';

/// Règles livrées avec l'app (copie de specs/regles-garde.yaml).
final defaultGardeRulesProvider = FutureProvider<List<GardeRule>>((ref) async {
  final yaml = loadYaml(
    await rootBundle.loadString('assets/regles/regles-garde.yaml'),
  ) as YamlMap;
  return [
    for (final r in (yaml['regles'] as YamlList).cast<YamlMap>())
      GardeRule.fromJson(r),
  ];
});

/// PAR-07 : règles de garde appliquées, celles du fichier livré ou celles
/// modifiées par l'utilisateur. Les règles modifiées restent sur le
/// téléphone, dans les préférences, comme les autres réglages.
class GardeRulesController extends AsyncNotifier<List<GardeRule>> {
  static const prefsKey = 'iacave_regles_garde';

  @override
  Future<List<GardeRule>> build() async {
    final defaults = await ref.watch(defaultGardeRulesProvider.future);
    final raw = ref.watch(sharedPreferencesProvider).getString(prefsKey);
    if (raw == null) return defaults;
    try {
      final rules = [
        for (final r in jsonDecode(raw) as List)
          GardeRule.fromJson(r as Map<Object?, Object?>),
      ];
      // Sans règle par défaut en dernier, l'estimation pourrait ne rien
      // donner : on revient aux règles livrées.
      return rules.isNotEmpty && rules.last.isCatchAll ? rules : defaults;
    } on Object {
      return defaults;
    }
  }

  /// Vrai quand les règles diffèrent de celles livrées.
  bool get customized =>
      ref.read(sharedPreferencesProvider).containsKey(prefsKey);

  /// Enregistre les règles puis recalcule les fiches estimées. Renvoie le
  /// nombre de fiches modifiées.
  Future<int> save(List<GardeRule> rules) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(prefsKey, jsonEncode([for (final r in rules) r.toJson()]));
    state = AsyncData(rules);
    return _reestimate(rules);
  }

  /// Revient aux règles livrées avec l'app.
  Future<int> reset() async {
    await ref.read(sharedPreferencesProvider).remove(prefsKey);
    final defaults = await ref.read(defaultGardeRulesProvider.future);
    state = AsyncData(defaults);
    return _reestimate(defaults);
  }

  Future<int> _reestimate(List<GardeRule> rules) async {
    await ref.read(bootstrapProvider.future);
    final labels = await ref.read(labelsProvider.future);
    return ref.read(cellarRepositoryProvider).reestimateGarde(rules, labels);
  }
}

final gardeRulesStoreProvider =
    AsyncNotifierProvider<GardeRulesController, List<GardeRule>>(
      GardeRulesController.new,
    );
