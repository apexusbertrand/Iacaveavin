import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';
import '../../data/reference_repository.dart';

/// Résultat d'un choix dans une liste : un code existant, ou null pour vider.
class PickResult {
  const PickResult(this.code);

  final String? code;
}

/// Liste déroulante avec recherche dès 10 valeurs (docs/03), et ajout d'une
/// valeur absente depuis le formulaire (FIC-02).
Future<PickResult?> pickListValue(
  BuildContext context,
  WidgetRef ref, {
  required String list,
  required String title,
  String? parentCode,
  Set<String> parentCodes = const {},
  bool allowAdd = true,
  bool allowNone = true,
}) => showModalBottomSheet<PickResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _PickerSheet(
    list: list,
    title: title,
    parentCodes: {?parentCode, ...parentCodes},
    allowAdd: allowAdd,
    allowNone: allowNone,
  ),
);

class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet({
    required this.list,
    required this.title,
    required this.parentCodes,
    required this.allowAdd,
    required this.allowNone,
  });

  final String list;
  final String title;

  /// Valeurs parentes acceptées : la liste est filtrée sur elles si non vide.
  final Set<String> parentCodes;
  final bool allowAdd;
  final bool allowNone;

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ûüù]'), 'u')
      .replaceAll('ç', 'c');

  Future<void> _add(String label) async {
    final cellarId = await ref.read(bootstrapProvider.future);
    try {
      final code = await ref
          .read(referenceRepositoryProvider)
          .addValue(
            list: widget.list,
            cellarId: cellarId,
            label: label,
            parentCode: widget.parentCodes.length == 1
                ? widget.parentCodes.single
                : null,
          );
      if (mounted) Navigator.of(context).pop(PickResult(code));
    } on ReferenceException {
      // Doublon : la valeur existe déjà, la recherche la montre.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all =
        ref.watch(listValuesProvider(widget.list)).value ??
        const <ListValueView>[];
    final active = all.where((v) => v.active).toList();
    final scoped = widget.parentCodes.isEmpty
        ? active
        : active
              .where((v) => widget.parentCodes.contains(v.parentCode))
              .toList();
    final values = scoped.isEmpty ? active : scoped;
    final q = _norm(_search.text.trim());
    final shown = q.isEmpty
        ? values
        : values.where((v) => _norm(v.label).contains(q)).toList();
    final exact = values.any((v) => _norm(v.label) == q);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (values.length >= 10 || widget.allowAdd)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
              child: TextField(
                key: const ValueKey('picker-search'),
                controller: _search,
                autofocus: values.length >= 10,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: l.searchList,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          Expanded(
            child: ListView(
              controller: controller,
              children: [
                if (widget.allowAdd && q.isNotEmpty && !exact)
                  ListTile(
                    key: const ValueKey('picker-add'),
                    leading: const Icon(Icons.add),
                    title: Text(l.addToList(_search.text.trim())),
                    onTap: () => _add(_search.text.trim()),
                  ),
                if (widget.allowNone && q.isEmpty)
                  ListTile(
                    title: Text(l.none),
                    onTap: () =>
                        Navigator.of(context).pop(const PickResult(null)),
                  ),
                for (final v in shown)
                  ListTile(
                    title: Text(v.label),
                    onTap: () => Navigator.of(context).pop(PickResult(v.code)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ de formulaire qui affiche le libellé et ouvre le choix.
class ListField extends StatelessWidget {
  const ListField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        isEmpty: value == null || value!.isEmpty,
        child: Text(value ?? ''),
      ),
    );
  }
}
