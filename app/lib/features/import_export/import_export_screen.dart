import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/excel/excel_service.dart';
import '../../data/export_providers.dart';
import 'catalogue_section.dart';
import 'import_report_screen.dart';

const xlsxMime =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Import et export : classeur Excel (XLS-01 à XLS-10) et catalogue PDF
/// (PDF-02 à PDF-05).
class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _stamp() =>
      DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');

  /// XLS-01, XLS-03 : classeur complet ou modèle vierge vers le partage.
  Future<void> _export({required bool template}) => _run(() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await ref
        .read(excelServiceProvider)
        .export(l, template: template);
    messenger.showSnackBar(SnackBar(content: Text(l.ieReady)));
    await ref.read(fileSharerProvider)(
      bytes,
      template ? 'iacaveavin-modele.xlsx' : 'iacaveavin-${_stamp()}.xlsx',
      xlsxMime,
    );
  });

  /// XLS-07 : classeur choisi, zip de photos facultatif, puis simulation.
  Future<void> _import() => _run(() async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final pick = ref.read(bytesPickerProvider);
    final book = await pick(['xlsx']);
    if (book == null || !mounted) return;
    final withPhotos = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.iePhotosTitle),
        content: Text(l.iePhotosBody),
        actions: [
          TextButton(
            key: const ValueKey('import-no-photos'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.iePhotosSkip),
          ),
          TextButton(
            key: const ValueKey('import-photos'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.iePhotosPick),
          ),
        ],
      ),
    );
    if (withPhotos == null) return;
    Uint8List? zip;
    if (withPhotos) zip = (await pick(['zip']))?.bytes;
    final service = ref.read(excelServiceProvider);
    final plan = await service.simulate(book.bytes, photosZip: zip);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ImportReportScreen(
          plan: plan,
          resimulate: (createUnknown) => service.simulate(
            book.bytes,
            photosZip: zip,
            createUnknown: createUnknown,
          ),
        ),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.l,
        SpacingTokens.xl,
        SpacingTokens.l,
        SpacingTokens.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: context.palette.primaryText,
        ),
      ),
    );

    Widget action(
      IconData icon,
      String title,
      String hint,
      VoidCallback onTap, {
      required Key key,
    }) => Card(
      child: ListTile(
        key: key,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(hint),
        enabled: !_busy,
        onTap: onTap,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.navImportExport)),
      drawer: const AppDrawer(current: AppDestination.importExport),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.xxl),
        children: [
          if (_busy) const LinearProgressIndicator(),
          header(l.ieExcelSection),
          action(
            Icons.ios_share,
            l.ieExport,
            l.ieExportHint,
            () => _export(template: false),
            key: const ValueKey('excel-export'),
          ),
          action(
            Icons.grid_on_outlined,
            l.ieTemplate,
            l.ieTemplateHint,
            () => _export(template: true),
            key: const ValueKey('excel-template'),
          ),
          action(
            Icons.upload_file_outlined,
            l.ieImport,
            l.ieImportHint,
            _import,
            key: const ValueKey('excel-import'),
          ),
          const CatalogueSection(),
        ],
      ),
    );
  }
}

/// Texte d'un problème du rapport (XLS-07).
String issueText(AppLocalizations l, ImportIssue i) {
  final reason = switch (i.code) {
    IssueCode.missingSheet => l.issueMissingSheet,
    IssueCode.missingColumn => l.issueMissingColumn,
    IssueCode.required => l.issueRequired,
    IssueCode.unknownId => l.issueUnknownId,
    IssueCode.duplicateId => l.issueDuplicateId,
    IssueCode.invalidNumber => l.issueInvalidNumber,
    IssueCode.invalidVintage => l.issueInvalidVintage,
    IssueCode.outOfRange => l.issueOutOfRange,
    IssueCode.gardeOrder => l.issueGardeOrder,
    IssueCode.invalidEan => l.issueInvalidEan,
    IssueCode.invalidBoolean => l.issueInvalidBoolean,
    IssueCode.invalidDate => l.issueInvalidDate,
    IssueCode.invalidGrapes => l.issueInvalidGrapes,
    IssueCode.invalidAction => l.issueInvalidAction,
    IssueCode.unknownValue => l.issueUnknownValue,
    IssueCode.unknownLocation => l.issueUnknownLocation,
    IssueCode.unknownWine => l.issueUnknownWine,
    IssueCode.deletedWine => l.issueDeletedWine,
    IssueCode.lotWineChange => l.issueLotWineChange,
  };
  return i.value == null ? reason : l.issueWithValue(reason, i.value!);
}
