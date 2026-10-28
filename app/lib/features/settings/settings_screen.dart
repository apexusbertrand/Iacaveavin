import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';

/// Paramètres, réduits au lot 0 au jeu de démonstration (CMP-07).
/// Les réglages complets (PAR-05) arrivent au lot 1.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final count = ref.watch(demoCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      drawer: const AppDrawer(current: AppDestination.settings),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.l),
        children: [
          Text(
            l.settingsDemoSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.palette.primaryText,
            ),
          ),
          const SizedBox(height: SpacingTokens.s),
          Text(l.settingsDemoDescription, style: theme.textTheme.bodyLarge),
          const SizedBox(height: SpacingTokens.l),
          count.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => MessageStateView(
              icon: Icons.error_outline,
              isError: true,
              title: l.operationFailed('$e'),
              action: FilledButton(
                onPressed: () => ref.invalidate(demoCountProvider),
                child: Text(l.retry),
              ),
            ),
            data: (n) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  n > 0 ? l.settingsDemoLoaded(n) : l.settingsDemoNotLoaded,
                  key: const ValueKey('demo-status'),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: SpacingTokens.m),
                if (_busy)
                  const Center(child: CircularProgressIndicator())
                else if (n == 0)
                  FilledButton.icon(
                    key: const ValueKey('demo-load'),
                    onPressed: _load,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l.settingsDemoLoad),
                  )
                else
                  OutlinedButton.icon(
                    key: const ValueKey('demo-erase'),
                    onPressed: _erase,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.settingsDemoErase),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          const Divider(),
          const SizedBox(height: SpacingTokens.s),
          Text(l.settingsMoreLater, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Future<void> _load() => _run(
    () => ref.read(demoRepositoryProvider).load(),
    AppLocalizations.of(context).settingsDemoLoadedSnack,
  );

  Future<void> _erase() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsDemoEraseTitle),
        content: Text(l.settingsDemoEraseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('demo-erase-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.erase),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      () => ref.read(demoRepositoryProvider).erase(),
      l.settingsDemoErasedSnack,
    );
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      ref.invalidate(demoCountProvider);
      if (mounted) setState(() => _busy = false);
    }
  }
}
