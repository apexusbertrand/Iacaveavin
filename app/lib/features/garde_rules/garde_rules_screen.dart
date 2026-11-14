import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/garde_rules_store.dart';
import '../../data/providers.dart';
import '../../domain/garde_rules.dart';
import '../../domain/label_translator.dart';
import '../account/account_drawer.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;

/// PAR-06, PAR-07 : règles de garde, entrée du menu principal. Chaque règle
/// se modifie (couleur, régions, classements, décalages), on en ajoute,
/// on en supprime, on revient aux règles livrées. Les fiches dont la garde
/// est estimée sont recalculées à chaque enregistrement.
class GardeRulesScreen extends ConsumerWidget {
  const GardeRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labels = ref.watch(labelsProvider).value ?? const {};
    final store = ref.watch(gardeRulesStoreProvider);
    final customized = ref.read(gardeRulesStoreProvider.notifier).customized;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navGardeRules),
        actions: [
          PopupMenuButton<String>(
            key: const ValueKey('garde-menu'),
            onSelected: (_) => _reset(context, ref),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                enabled: customized,
                child: Text(l.gardeRulesReset),
              ),
            ],
          ),
          const AccountMenuButton(),
        ],
      ),
      drawer: const AppDrawer(current: AppDestination.gardeRules),
      endDrawer: const AccountDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('garde-add'),
        onPressed: store.hasValue
            ? () => _edit(context, ref, store.requireValue, null)
            : null,
        icon: const Icon(Icons.add),
        label: Text(l.gardeRuleAdd),
      ),
      body: store.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
        ),
        data: (rules) => ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.l,
            SpacingTokens.l,
            SpacingTokens.l,
            SpacingTokens.xxl * 2,
          ),
          children: [
            Text(l.gardeRulesIntro, style: theme.textTheme.bodyLarge),
            if (customized)
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.s),
                child: Text(
                  l.gardeRulesCustomized,
                  key: const ValueKey('garde-customized'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: context.palette.primaryText,
                  ),
                ),
              ),
            const SizedBox(height: SpacingTokens.s),
            for (final (i, r) in rules.indexed)
              ListTile(
                key: ValueKey('garde-rule-${r.id}'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  gardeConditionText(
                    l,
                    r,
                    labels,
                    ref.watch(labelTranslatorProvider),
                  ),
                ),
                subtitle: Text(l.gardeRuleLine(r.start, r.peak, r.end)),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _edit(context, ref, rules, i),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    List<GardeRule> rules,
    int? index,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<_EditResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            GardeRuleEditor(rule: index == null ? null : rules[index]),
      ),
    );
    if (result == null) return;
    final List<GardeRule> next;
    if (index == null) {
      next = insertGardeRule(rules, result.rule!);
    } else if (result.rule == null) {
      next = [...rules]..removeAt(index);
    } else {
      next = [...rules]..[index] = result.rule!;
    }
    final n = await ref.read(gardeRulesStoreProvider.notifier).save(next);
    messenger.showSnackBar(SnackBar(content: Text(l.gardeRulesSaved(n))));
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final yes = await confirm(
      context,
      title: l.gardeRulesResetTitle,
      body: l.gardeRulesResetBody,
      action: l.gardeRulesReset,
    );
    if (!yes) return;
    final n = await ref.read(gardeRulesStoreProvider.notifier).reset();
    messenger.showSnackBar(SnackBar(content: Text(l.gardeRulesSaved(n))));
  }
}

/// Condition lisible : couleur traduite par le référentiel. Régions,
/// appellations et classements sont des libellés livrés en français, gardés
/// tels quels dans la règle et traduits à l'affichage (LNG-03).
String gardeConditionText(
  AppLocalizations l,
  GardeRule r,
  Map<String, String> labels, [
  LabelTranslator tr = LabelTranslator.identity,
]) {
  if (r.isCatchAll) return l.gardeRuleDefault;
  return [
    for (final c in r.conditions.entries) _conditionValues(l, c, labels, tr),
  ].join(' · ');
}

String _conditionValues(
  AppLocalizations l,
  MapEntry<String, List<String>> c,
  Map<String, String> labels, [
  LabelTranslator tr = LabelTranslator.identity,
]) => c.value
    .map(
      (v) => switch (c.key) {
        'couleur' => labels['couleur:$v'] ?? v,
        'millesime' => v == 'NM' ? l.gardeRuleNonVintage : l.gardeRuleVintaged,
        'region' => tr.byFrench('region', v),
        _ => v,
      },
    )
    .join(', ');

class _EditResult {
  const _EditResult(this.rule);

  /// Null : règle supprimée.
  final GardeRule? rule;
}

/// PAR-07 : modification d'une règle. Couleur, régions et classements se
/// choisissent dans les listes ; les autres conditions (appellation,
/// millésimé ou non) sont conservées telles quelles.
class GardeRuleEditor extends ConsumerStatefulWidget {
  const GardeRuleEditor({super.key, this.rule});

  /// Null : nouvelle règle.
  final GardeRule? rule;

  @override
  ConsumerState<GardeRuleEditor> createState() => _GardeRuleEditorState();
}

class _GardeRuleEditorState extends ConsumerState<GardeRuleEditor> {
  late final GardeRule? _r = widget.rule;
  late String? _color = _r?.conditions['couleur']?.firstOrNull;
  late List<String> _regions = [...?_r?.conditions['region']];
  late List<String> _classes = [...?_r?.conditions['classement']];
  late final _start = TextEditingController(text: '${_r?.start ?? 0}');
  late final _peak = TextEditingController(text: '${_r?.peak ?? 2}');
  late final _end = TextEditingController(text: '${_r?.end ?? 4}');
  String? _error;

  bool get _catchAll => _r?.isCatchAll ?? false;

  /// Conditions que l'écran ne modifie pas, gardées telles quelles.
  Map<String, List<String>> get _others => {
    for (final c in (_r?.conditions ?? const <String, List<String>>{}).entries)
      if (!const {'couleur', 'region', 'classement'}.contains(c.key))
        c.key: c.value,
  };

  @override
  void dispose() {
    for (final c in [_start, _peak, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    final s = int.tryParse(_start.text.trim());
    final p = int.tryParse(_peak.text.trim());
    final e = int.tryParse(_end.text.trim());
    if (s == null || p == null || e == null || !validGardeOffsets(s, p, e)) {
      setState(() => _error = l.gardeRuleOffsetsInvalid);
      return;
    }
    final conditions = <String, List<String>>{
      if (_color != null) 'couleur': [_color!],
      if (_regions.isNotEmpty) 'region': _regions,
      if (_classes.isNotEmpty) 'classement': _classes,
      ..._others,
    };
    if (!_catchAll && conditions.isEmpty) {
      setState(() => _error = l.gardeRuleNeedsCondition);
      return;
    }
    final rule =
        _r?.copyWith(conditions: conditions, start: s, peak: p, end: e) ??
        GardeRule(
          id: 'perso_${DateTime.now().microsecondsSinceEpoch}',
          conditions: conditions,
          start: s,
          peak: p,
          end: e,
        );
    Navigator.of(context).pop(_EditResult(rule));
  }

  Future<void> _pick(
    String list,
    String title,
    List<String> current,
    void Function(List<String>) apply,
  ) async {
    // Listes chargées dès l'ouverture de l'éditeur (voir build). Les règles
    // portent les libellés en base ; l'affichage est traduit (LNG-03).
    final values = ref.read(rawListValuesProvider(list)).value ?? const [];
    final tr = ref.read(labelTranslatorProvider);
    final options = {
      for (final v in values)
        if (v.active) v.label,
    }.toList()..sort();
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MultiPick(
        title: title,
        options: options,
        selected: current,
        display: (v) => tr.byFrench(list, v),
      ),
    );
    if (picked != null) setState(() => apply(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = ref.watch(listValuesProvider('couleur')).value ?? const [];
    final labels = ref.watch(labelsProvider).value ?? const {};
    ref
      ..watch(rawListValuesProvider('region'))
      ..watch(rawListValuesProvider('classement'));
    final tr = ref.watch(labelTranslatorProvider);
    final others = _others;
    Widget offset(TextEditingController c, String label, String key) =>
        Expanded(
          child: TextField(
            key: ValueKey(key),
            controller: c,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: label),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(_r == null ? l.gardeRuleNew : l.gardeRuleEdit),
        actions: [
          if (_r != null && !_catchAll)
            IconButton(
              key: const ValueKey('garde-rule-delete'),
              tooltip: l.gardeRuleDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  Navigator.of(context).pop(const _EditResult(null)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.l),
        children: [
          if (_catchAll)
            Text(l.gardeRuleDefault, style: theme.textTheme.titleMedium)
          else ...[
            DropdownButtonFormField<String?>(
              key: const ValueKey('garde-rule-color'),
              initialValue: _color,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.gardeRuleColor),
              items: [
                DropdownMenuItem(value: null, child: Text(l.gardeRuleAny)),
                for (final c in colors)
                  if (c.active || c.code == _color)
                    DropdownMenuItem(value: c.code, child: Text(c.label)),
                // Liste pas encore chargée : la couleur de la règle reste
                // choisie, avec son libellé connu.
                if (_color != null && !colors.any((c) => c.code == _color))
                  DropdownMenuItem(
                    value: _color,
                    child: Text(labels['couleur:$_color'] ?? _color!),
                  ),
              ],
              onChanged: (v) => setState(() => _color = v),
            ),
            ListTile(
              key: const ValueKey('garde-rule-regions'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.gardeRuleRegions),
              subtitle: Text(
                _regions.isEmpty
                    ? l.gardeRuleAny
                    : _regions.map((r) => tr.byFrench('region', r)).join(', '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pick(
                'region',
                l.gardeRuleRegions,
                _regions,
                (v) => _regions = v,
              ),
            ),
            ListTile(
              key: const ValueKey('garde-rule-classes'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.gardeRuleClassifications),
              subtitle: Text(
                _classes.isEmpty ? l.gardeRuleAny : _classes.join(', '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pick(
                'classement',
                l.gardeRuleClassifications,
                _classes,
                (v) => _classes = v,
              ),
            ),
            if (others.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.s),
                child: Text(
                  l.gardeRuleOther(
                    [
                      for (final c in others.entries)
                        _conditionValues(l, c, const {}),
                    ].join(' · '),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
          const SizedBox(height: SpacingTokens.l),
          Row(
            children: [
              offset(_start, l.gardeRuleStart, 'garde-rule-start'),
              const SizedBox(width: SpacingTokens.s),
              offset(_peak, l.gardeRulePeak, 'garde-rule-peak'),
              const SizedBox(width: SpacingTokens.s),
              offset(_end, l.gardeRuleEnd, 'garde-rule-end'),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.m),
              child: Text(
                _error!,
                key: const ValueKey('garde-rule-error'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: SpacingTokens.xl),
          FilledButton(
            key: const ValueKey('garde-rule-save'),
            onPressed: _save,
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}

/// Choix multiple dans une liste, avec recherche (les régions sont
/// nombreuses).
class _MultiPick extends StatefulWidget {
  const _MultiPick({
    required this.title,
    required this.options,
    required this.selected,
    required this.display,
  });

  final String title;
  final List<String> options;
  final List<String> selected;

  /// Libellé affiché d'une valeur (traduction, LNG-03).
  final String Function(String) display;

  @override
  State<_MultiPick> createState() => _MultiPickState();
}

class _MultiPickState extends State<_MultiPick> {
  late final Set<String> _sel = {...widget.selected};
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = _q.toLowerCase();
    // Les valeurs déjà retenues restent visibles même hors de la liste.
    final all = {...widget.selected, ...widget.options}.toList();
    final shown = [
      for (final o in all)
        if (q.isEmpty ||
            o.toLowerCase().contains(q) ||
            widget.display(o).toLowerCase().contains(q))
          o,
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: TextField(
              key: const ValueKey('garde-pick-search'),
              decoration: InputDecoration(
                labelText: widget.title,
                hintText: l.gardeRuleSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _q = v.trim()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shown.length,
              itemBuilder: (context, i) => CheckboxListTile(
                key: ValueKey('garde-pick-${shown[i]}'),
                value: _sel.contains(shown[i]),
                title: Text(widget.display(shown[i])),
                onChanged: (v) => setState(
                  () => v == true ? _sel.add(shown[i]) : _sel.remove(shown[i]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('garde-pick-ok'),
                onPressed: () => Navigator.of(context).pop([
                  for (final o in all)
                    if (_sel.contains(o)) o,
                ]),
                child: Text(l.save),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
