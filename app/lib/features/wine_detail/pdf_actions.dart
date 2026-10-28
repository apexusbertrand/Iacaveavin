import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/export_providers.dart';
import '../../data/settings_store.dart';
import '../../domain/file_names.dart';
import '../../domain/wine_detail.dart';
import '../import_export/catalogue_section.dart';

/// Nom du fichier partagé : celui du vin, pas son identifiant.
String wineSharedName(WineDetail wine) => wineFileBase(
  producer: wine.draft.producer,
  cuvee: wine.draft.cuvee,
  vintage: wine.draft.vintage,
);

/// PDF-01, PDF-05 : fiche unitaire A4, générée hors ligne puis partagée,
/// sous le nom du vin.
Future<void> shareWinePdf(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final date = editionDate(context);
  final money = moneyFormatter(context, ref.read(settingsProvider).currency);
  messenger.showSnackBar(SnackBar(content: Text(l.pdfPreparing)));
  try {
    final bytes = await ref
        .read(pdfServiceProvider)
        .wineSheet(wine.id, l, date: date, money: money);
    await ref.read(fileSharerProvider)(
      bytes,
      '${wineSharedName(wine)}.pdf',
      pdfMime,
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
  }
}
