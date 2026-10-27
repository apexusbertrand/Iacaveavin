import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/excel/excel_service.dart';
import '../../data/export_providers.dart';
import '../../data/providers.dart';
import '../../domain/excel_layout.dart';
import 'import_export_screen.dart' show issueText;

/// XLS-06 à XLS-09 : rapport de simulation, création des valeurs inconnues,
/// enrichissement des fiches créées, puis import.
class ImportReportScreen extends ConsumerStatefulWidget {
  const ImportReportScreen({
    super.key,
    required this.plan,
    required this.resimulate,
  });

  final ImportPlan plan;

  /// Nouvelle simulation, avec ou sans création des valeurs inconnues.
  final Future<ImportPlan> Function(bool createUnknown) resimulate;

  @override
  ConsumerState<ImportReportScreen> createState() => _ImportReportScreenState();
}

class _ImportReportScreenState extends ConsumerState<ImportReportScreen> {
  late ImportPlan _plan = widget.plan;
  bool _createUnknown = false;
  bool _enrich = false;
  bool _busy = false;
  late final Future<int?> _quota = ref
      .read(enrichmentQueueProvider.future)
      .then((q) => q.lastKnownEnrichmentsLeft());

  /// Valeurs inconnues de la première simulation (sans création).
  late final List<UnknownValue> _unknown = _unknownOf(widget.plan);

  static List<UnknownValue> _unknownOf(ImportPlan plan) => [
    for (final i in plan.report.issues)
      if (i.code == IssueCode.unknownValue && i.value != null)
        UnknownValue(i.column, i.value!),
  ];

  Future<void> _toggleUnknown(bool value) async {
    setState(() {
      _busy = true;
      _createUnknown = value;
    });
    try {
      final plan = await widget.resimulate(value);
      if (mounted) setState(() => _plan = plan);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(excelServiceProvider)
          .apply(_plan, cellarId: await ref.read(bootstrapProvider.future));
      if (_enrich && result.createdWines.isNotEmpty) {
        final queue = await ref.read(enrichmentQueueProvider.future);
        for (final id in result.createdWines) {
          await queue.enqueue(id);
        }
        ref.read(enrichmentRunnerProvider.notifier).kick();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.importEnrichStarted(result.createdWines.length)),
          ),
        );
      }
      messenger.showSnackBar(SnackBar(content: Text(l.importFinished)));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = _plan.report;
    final counts = [
      (r.winesCreated, l.importWinesCreated),
      (r.winesUpdated, l.importWinesUpdated),
      (r.winesDeleted, l.importWinesDeleted),
      (r.lotsCreated, l.importLotsCreated),
      (r.lotsUpdated, l.importLotsUpdated),
      (r.lotsDeleted, l.importLotsDeleted),
      (r.stockChanges, l.importStockChanges),
      (r.photosFound, l.importPhotos),
    ];
    final canApply = r.issues.isEmpty && r.hasChanges && !_busy;

    Widget header(String text, {Color? color}) => Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.l,
        SpacingTokens.xl,
        SpacingTokens.l,
        SpacingTokens.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color ?? context.palette.primaryText,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.importReportTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.xxl * 3),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (!r.hasChanges && r.issues.isEmpty)
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l.importNoChange),
            ),
          for (final (n, text) in counts)
            if (n > 0)
              ListTile(
                dense: true,
                leading: const Icon(Icons.chevron_right),
                title: Text(text(n)),
              ),
          if (_unknown.isNotEmpty) ...[
            header(l.importUnknownTitle),
            SwitchListTile(
              key: const ValueKey('import-create-unknown'),
              title: Text(l.importCreateUnknown),
              value: _createUnknown,
              onChanged: _busy ? null : _toggleUnknown,
            ),
            for (final u in {for (final u in _unknown) u.key: u}.values)
              ListTile(
                dense: true,
                title: Text(u.label),
                subtitle: Text(u.list),
              ),
          ],
          if (r.enrichable > 0)
            FutureBuilder<int?>(
              future: _quota,
              builder: (context, snap) => SwitchListTile(
                key: const ValueKey('import-enrich'),
                title: Text(l.importEnrich),
                subtitle: Text(
                  l.importEnrichHint(
                    r.enrichable,
                    snap.data?.toString() ?? l.importEnrichUnknownQuota,
                  ),
                ),
                value: _enrich,
                onChanged: (v) => setState(() => _enrich = v),
              ),
            ),
          if (r.issues.isNotEmpty) ...[
            header(
              l.importIssuesTitle(r.issues.length),
              color: theme.colorScheme.error,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
              child: Text(l.importBlocked, style: theme.textTheme.bodyMedium),
            ),
            for (final i in r.issues.take(200))
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(issueText(l, i)),
                subtitle: Text(
                  l.importIssueWhere(
                    i.sheet,
                    i.row,
                    i.column.isEmpty ? sheetWines : i.column,
                  ),
                ),
              ),
          ],
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Text(l.importBackupNote, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('import-apply'),
        onPressed: canApply ? _apply : null,
        icon: const Icon(Icons.download_done),
        label: Text(l.importApply),
      ),
    );
  }
}
