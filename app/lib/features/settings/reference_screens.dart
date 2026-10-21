import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:yaml/yaml.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/backup_providers.dart';
import '../../data/providers.dart';
import '../../data/reference_repository.dart';
import '../locations/locations_screen.dart' show referenceErrorText;

Future<void> _guard(
  BuildContext context,
  Future<void> Function() action,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on ReferenceException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(referenceErrorText(l, e))));
  }
}

Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
  String? initial,
}) async {
  final l = AppLocalizations.of(context);
  final c = TextEditingController(text: initial);
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        key: const ValueKey('ask-text'),
        controller: c,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const ValueKey('ask-save'),
          onPressed: () => Navigator.of(context).pop(c.text.trim()),
          child: Text(l.save),
        ),
      ],
    ),
  );
  return value == null || value.isEmpty ? null : value;
}

/// Propriétaires (PRO-01) : liste, propriétaire par défaut, stock de chacun.
class OwnersScreen extends ConsumerWidget {
  const OwnersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final owners = ref.watch(ownersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsOwners)),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addOwner,
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.person_add_alt),
      ),
      body: owners.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
        ),
        data: (list) => list.isEmpty
            ? MessageStateView(
                icon: Icons.people_outline,
                title: l.ownersEmpty,
                action: FilledButton(
                  onPressed: () => _edit(context, ref),
                  child: Text(l.addOwner),
                ),
              )
            : ListView(
                children: [
                  for (final o in list)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                        child: Text(
                          o.initials ??
                              o.name.characters
                                  .take(2)
                                  .toString()
                                  .toUpperCase(),
                        ),
                      ),
                      title: Text(o.name),
                      subtitle: Text(
                        [
                          l.ownerBottles(o.bottles),
                          if (o.isDefault) l.defaultBadge,
                        ].join(' · '),
                      ),
                      onTap: () => _edit(context, ref, existing: o),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _guard(
                          context,
                          () => ref
                              .read(referenceRepositoryProvider)
                              .deleteOwner(o.id),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    OwnerView? existing,
  }) async {
    final l = AppLocalizations.of(context);
    final name = TextEditingController(text: existing?.name);
    final initials = TextEditingController(text: existing?.initials);
    var isDefault = existing?.isDefault ?? false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? l.addOwner : l.editOwner),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('owner-name'),
                controller: name,
                autofocus: true,
                decoration: InputDecoration(labelText: l.ownerName),
              ),
              TextField(
                controller: initials,
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l.ownerInitials),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.ownerDefault),
                value: isDefault,
                onChanged: (v) => setState(() => isDefault = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.cancel),
            ),
            TextButton(
              key: const ValueKey('owner-save'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      await ref
          .read(referenceRepositoryProvider)
          .saveOwner(
            id: existing?.id,
            cellarId: await ref.read(bootstrapProvider.future),
            name: name.text,
            initials: initials.text,
            isDefault: isDefault,
          );
    }
  }
}

/// PAR-01 : un écran par liste modifiable du dictionnaire.
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsLists)),
      body: ListView(
        children: [
          for (final list in editableLists)
            ListTile(
              key: ValueKey('list-$list'),
              title: Text(l.listName(list)),
              subtitle: Text(
                l.listCount(
                  ref.watch(listValuesProvider(list)).value?.length ?? 0,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/parametres/listes/$list'),
            ),
        ],
      ),
    );
  }
}

/// PAR-02, PAR-04 : ajouter, renommer, réordonner, désactiver, fusionner,
/// supprimer si inutilisée ; import et export CSV.
class ListValuesScreen extends ConsumerWidget {
  const ListValuesScreen({super.key, required this.list});

  final String list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final values = ref.watch(listValuesProvider(list));
    final repo = ref.read(referenceRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.listName(list)),
        actions: [
          IconButton(
            tooltip: l.exportCsv,
            icon: const Icon(Icons.upload_file),
            onPressed: () => _export(ref),
          ),
          IconButton(
            tooltip: l.importCsv,
            icon: const Icon(Icons.download),
            onPressed: () => _import(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addValue,
        onPressed: () async {
          final label = await _askText(
            context,
            title: l.addValue,
            label: l.valueLabel,
          );
          if (label == null || !context.mounted) return;
          final cellarId = await ref.read(bootstrapProvider.future);
          if (!context.mounted) return;
          await _guard(
            context,
            () => repo.addValue(list: list, cellarId: cellarId, label: label),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: values.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
        ),
        data: (items) => ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: SpacingTokens.xxl * 3),
          itemCount: items.length,
          onReorderItem: (from, to) {
            final ids = items.map((v) => v.id).toList();
            ids.insert(to, ids.removeAt(from));
            repo.reorder(ids);
          },
          itemBuilder: (context, i) {
            final v = items[i];
            return ListTile(
              key: ValueKey(v.id),
              title: Text(
                v.label,
                style: v.active
                    ? null
                    : theme.textTheme.bodyLarge?.copyWith(
                        color: context.palette.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
              ),
              subtitle: v.active ? null : Text(l.inactive),
              trailing: PopupMenuButton<String>(
                onSelected: (action) => _action(context, ref, v, items, action),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'rename', child: Text(l.renameValue)),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(v.active ? l.deactivateValue : l.activateValue),
                  ),
                  PopupMenuItem(value: 'merge', child: Text(l.mergeValue)),
                  PopupMenuItem(value: 'delete', child: Text(l.deleteValue)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _action(
    BuildContext context,
    WidgetRef ref,
    ListValueView v,
    List<ListValueView> all,
    String action,
  ) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(referenceRepositoryProvider);
    switch (action) {
      case 'rename':
        final label = await _askText(
          context,
          title: l.renameValue,
          label: l.valueLabel,
          initial: v.label,
        );
        if (label != null) await repo.renameValue(v.id, label);
      case 'toggle':
        await repo.setActive(v.id, !v.active);
      case 'merge':
        final target = await showModalBottomSheet<ListValueView>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.7,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(title: Text(l.mergeTitle(v.label))),
                  for (final other in all.where((x) => x.id != v.id))
                    ListTile(
                      title: Text(other.label),
                      onTap: () => Navigator.of(context).pop(other),
                    ),
                ],
              ),
            ),
          ),
        );
        if (target == null || !context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        await _guard(context, () async {
          await repo.merge(v.id, target.id);
          messenger.showSnackBar(SnackBar(content: Text(l.mergeDone)));
        });
      case 'delete':
        await _guard(context, () => repo.deleteValue(v.id));
    }
  }

  Future<void> _export(WidgetRef ref) async {
    final csv = await ref.read(referenceRepositoryProvider).exportCsv(list);
    final dir = await ref.read(tempDirProvider)();
    final file = File(p.join(dir.path, 'liste-$list.csv'))
      ..writeAsStringSync('﻿$csv');
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = picked.isEmpty ? null : picked.single.path;
    if (path == null || !context.mounted) return;
    await _guard(context, () async {
      final r = await ref
          .read(referenceRepositoryProvider)
          .importCsv(
            list,
            await File(path).readAsString(),
            cellarId: await ref.read(bootstrapProvider.future),
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l.importDone(r.created, r.updated))),
      );
    });
  }
}

/// Règles de garde embarquées (copie de specs/regles-garde.yaml).
final gardeRulesProvider = FutureProvider<YamlMap>((ref) async {
  final text = await rootBundle.loadString('assets/regles/regles-garde.yaml');
  return loadYaml(text) as YamlMap;
});

/// PAR-06 : règles de garde en lecture, « valeurs par défaut à valider »
/// tant que `a_valider` est vrai.
class GardeRulesScreen extends ConsumerWidget {
  const GardeRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labels = ref.watch(labelsProvider).value ?? const {};
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsGardeRules)),
      body: ref
          .watch(gardeRulesProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => MessageStateView(
              icon: Icons.error_outline,
              isError: true,
              title: l.operationFailed('$e'),
            ),
            data: (rules) => ListView(
              padding: const EdgeInsets.all(SpacingTokens.l),
              children: [
                if (rules['a_valider'] == true)
                  Card(
                    color: theme.colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.l),
                      child: Text(
                        l.gardeRulesPending,
                        key: const ValueKey('garde-pending'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.m,
                  ),
                  child: Text(
                    l.gardeRulesIntro,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                for (final r in (rules['regles'] as YamlList).cast<YamlMap>())
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_condition(l, r['si'] as YamlMap?, labels)),
                    subtitle: Text(
                      l.gardeRuleLine(
                        (r['decalage'] as YamlMap)['debut'] as int,
                        (r['decalage'] as YamlMap)['apogee'] as int,
                        (r['decalage'] as YamlMap)['fin'] as int,
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  /// Condition lisible : valeurs de listes traduites par le référentiel.
  static String _condition(
    AppLocalizations l,
    YamlMap? si,
    Map<String, String> labels,
  ) {
    if (si == null || si.isEmpty) return l.gardeRuleDefault;
    final parts = <String>[];
    si.forEach((key, value) {
      final values = value is YamlList ? value.toList() : [value];
      final list = switch (key) {
        'couleur' => 'couleur',
        'region' => 'region',
        'appellation' => 'appellation',
        'type' || 'type_vin' => 'type_vin',
        _ => null,
      };
      parts.add(
        values
            .map((v) => list == null ? '$v' : labels['$list:$v'] ?? '$v')
            .join(', '),
      );
    });
    return parts.join(' · ');
  }
}
