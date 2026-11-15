import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/app_update.dart';

/// NAV-03 : au lancement, si le store propose une version plus récente,
/// l'app le dit et propose de mettre à jour. « Plus tard » ferme sans rien
/// changer ; la question revient au prochain lancement.
Future<void> offerAppUpdate(BuildContext context, WidgetRef ref) async {
  if (!ref.read(appUpdateOnceProvider.notifier).claim()) return;
  final checker = ref.read(appUpdateCheckerProvider);
  if (!await checker.updateAvailable() || !context.mounted) return;
  final l = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.updateTitle),
      content: Text(l.updateBody),
      actions: [
        TextButton(
          key: const ValueKey('update-later'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.later),
        ),
        FilledButton(
          key: const ValueKey('update-now'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.updateNow),
        ),
      ],
    ),
  );
  if (yes == true) await checker.update();
}
