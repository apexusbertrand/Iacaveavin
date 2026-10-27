import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/export_providers.dart';
import '../../data/settings_store.dart';
import '../import_export/catalogue_section.dart';

/// PDF-01, PDF-05 : fiche unitaire A4, générée hors ligne puis partagée.
Future<void> shareWinePdf(
  BuildContext context,
  WidgetRef ref,
  String wineId,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final date = editionDate(context);
  final money = moneyFormatter(context, ref.read(settingsProvider).currency);
  messenger.showSnackBar(SnackBar(content: Text(l.pdfPreparing)));
  try {
    final bytes = await ref
        .read(pdfServiceProvider)
        .wineSheet(wineId, l, date: date, money: money);
    await ref.read(fileSharerProvider)(bytes, 'fiche-$wineId.pdf', pdfMime);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
  }
}
