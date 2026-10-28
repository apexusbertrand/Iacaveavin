import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/backup_providers.dart';
import '../../data/backup_service.dart';
import '../../data/settings_store.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;

/// Sauvegarde et restauration (SAV-01 à SAV-05).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  String _backupError(AppLocalizations l, Object e) => switch (e) {
    BackupException(code: 'newer_schema') => l.backupErrorNewer,
    BackupException(code: 'corrupted') => l.backupErrorCorrupted,
    BackupException() => l.backupErrorArchive,
    _ => l.operationFailed('$e'),
  };

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_backupError(l, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// SAV-01, SAV-02 : archive envoyée vers la feuille de partage.
  Future<void> _export({required bool withPhotos}) => _run(() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final file = await ref
        .read(backupServiceProvider)
        .createArchive(withPhotos: withPhotos);
    messenger.showSnackBar(SnackBar(content: Text(l.backupShared)));
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: p.basename(file.path)),
    );
    if (result.status != ShareResultStatus.dismissed) {
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(lastExternalBackup: DateTime.now()));
    }
  });

  /// SAV-04 : restauration complète après confirmation.
  Future<void> _restore(File? archive) => _run(() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var file = archive;
    if (file == null) {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      final path = picked.isEmpty ? null : picked.single.path;
      if (path == null) return;
      file = File(path);
    }
    final service = ref.read(backupServiceProvider);
    final manifest = await service.inspect(file);
    if (!mounted) return;
    final date = DateFormat.yMMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(manifest.createdAt.toLocal());
    final ok = await confirm(
      context,
      title: l.backupRestoreTitle,
      body: l.backupRestoreBody(date, manifest.wines),
      action: l.backupRestore,
    );
    if (!ok) return;
    await service.restore(file);
    messenger.showSnackBar(SnackBar(content: Text(l.backupRestored)));
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final autos = ref.watch(autoBackupsProvider);
    final dateFormat = DateFormat.yMMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    Widget action(
      IconData icon,
      String title,
      String hint,
      VoidCallback onTap, {
      Key? key,
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
      appBar: AppBar(title: Text(l.navBackup)),
      drawer: const AppDrawer(current: AppDestination.backup),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.m),
        children: [
          // SAV-05 : ne pas compter sur la sauvegarde d'Android.
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.l),
            child: Text(l.backupIntro, style: theme.textTheme.bodyLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            child: Text(
              settings.lastExternalBackup == null
                  ? l.backupNeverExported
                  : l.backupLastExternal(
                      dateFormat.format(settings.lastExternalBackup!),
                    ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          action(
            Icons.ios_share,
            l.backupExport,
            l.backupExportHint,
            () => _export(withPhotos: false),
            key: const ValueKey('backup-light'),
          ),
          action(
            Icons.photo_library_outlined,
            l.backupExportFull,
            l.backupExportFullHint,
            () => _export(withPhotos: true),
          ),
          action(
            Icons.restore,
            l.backupRestore,
            l.backupRestoreHint,
            () => _restore(null),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.l,
              SpacingTokens.xl,
              SpacingTokens.l,
              SpacingTokens.xs,
            ),
            child: Text(
              l.backupAuto,
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.palette.primaryText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            child: Text(l.backupAutoHint, style: theme.textTheme.bodyMedium),
          ),
          ...autos.when(
            loading: () => const [LinearProgressIndicator()],
            error: (_, _) => [ListTile(title: Text(l.backupAutoNone))],
            data: (files) => files.isEmpty
                ? [ListTile(title: Text(l.backupAutoNone))]
                : [
                    for (final f in files)
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(
                          dateFormat.add_Hm().format(f.lastModifiedSync()),
                        ),
                        trailing: TextButton(
                          onPressed: _busy ? null : () => _restore(f),
                          child: Text(l.restoreFromAuto),
                        ),
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

/// SAV-03 : au démarrage, sauvegarde hebdomadaire si elle est due.
/// Silencieux en cas d'échec : la cave reste utilisable.
Future<void> runAutoBackupIfDue(WidgetRef ref) async {
  try {
    final settings = ref.read(settingsProvider);
    final file = await ref
        .read(backupServiceProvider)
        .autoBackupIfDue(settings.lastAutoBackup);
    if (file != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(lastAutoBackup: DateTime.now()));
      ref.invalidate(autoBackupsProvider);
    }
  } on Object {
    // Pas de répertoire disponible (tests) ou disque plein : on réessaiera.
  }
}
