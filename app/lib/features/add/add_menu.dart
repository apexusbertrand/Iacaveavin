import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';

/// AJO-01 : le « + » propose photo (par défaut), code-barres, saisie manuelle
/// et import Excel.
Future<void> showAddMenu(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              l.addMenuTitle,
              style: Theme.of(sheet).textTheme.titleMedium,
            ),
          ),
          ListTile(
            key: const ValueKey('add-photo'),
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l.addByPhoto),
            subtitle: Text(l.addByPhotoHint),
            onTap: () {
              Navigator.of(sheet).pop();
              context.push('/ajout/photo');
            },
          ),
          ListTile(
            key: const ValueKey('add-barcode'),
            leading: const Icon(Icons.qr_code_scanner),
            title: Text(l.addByBarcode),
            subtitle: Text(l.addByBarcodeHint),
            onTap: () {
              Navigator.of(sheet).pop();
              context.push('/ajout/photo?ean=1');
            },
          ),
          ListTile(
            key: const ValueKey('add-manual'),
            leading: const Icon(Icons.edit_note),
            title: Text(l.addManual),
            subtitle: Text(l.addManualHint),
            onTap: () {
              Navigator.of(sheet).pop();
              context.push('/fiche/nouvelle');
            },
          ),
          ListTile(
            key: const ValueKey('add-excel'),
            leading: const Icon(Icons.table_view_outlined),
            title: Text(l.addExcel),
            subtitle: Text(l.addExcelHint),
            onTap: () {
              Navigator.of(sheet).pop();
              context.go('/import-export');
            },
          ),
        ],
      ),
    ),
  );
}
