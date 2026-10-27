import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import 'backup_providers.dart';
import 'enrichment/enrichment_providers.dart' show photoServiceProvider;
import '../core/theme/design_tokens.g.dart';
import 'excel/excel_service.dart';
import 'pdf/pdf_service.dart';
import 'providers.dart';

/// Fichier généré à proposer à la feuille de partage du système (PDF-05,
/// XLS-01). Remplacé dans les tests.
typedef FileSharer = Future<void> Function(
  Uint8List bytes,
  String fileName,
  String mimeType,
);

final fileSharerProvider = Provider<FileSharer>((ref) {
  final tempDir = ref.watch(tempDirProvider);
  return (bytes, fileName, mimeType) async {
    final file = File(p.join((await tempDir()).path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: fileName,
      ),
    );
  };
});

/// Fichier choisi par l'utilisateur : nom et contenu, ou null si annulé.
typedef BytesPicker = Future<({String name, Uint8List bytes})?> Function(
  List<String> extensions,
);

final bytesPickerProvider = Provider<BytesPicker>((ref) {
  return (extensions) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (picked.isEmpty) return null;
    final path = picked.single.path;
    if (path == null) return null;
    return (name: p.basename(path), bytes: await File(path).readAsBytes());
  };
});

final excelServiceProvider = Provider<ExcelService>(
  (ref) => ExcelService(
    ref.watch(databaseProvider),
    cellar: ref.watch(cellarRepositoryProvider),
    stock: ref.watch(stockServiceProvider),
    reference: ref.watch(referenceRepositoryProvider),
    backup: ref.watch(backupServiceProvider),
    photos: ref.watch(photoServiceProvider),
    year: ref.watch(currentYearProvider),
  ),
);

/// Lecture d'un asset binaire (polices du PDF). Disque dans les tests.
final binaryAssetReaderProvider = Provider<Future<Uint8List> Function(String)>(
  (ref) =>
      (path) async => (await rootBundle.load(path)).buffer.asUint8List(),
);

final pdfServiceProvider = Provider<PdfService>(
  (ref) => PdfService(
    cellar: ref.watch(cellarRepositoryProvider),
    photos: ref.watch(photoServiceProvider),
    readAsset: ref.watch(binaryAssetReaderProvider),
    year: ref.watch(currentYearProvider),
    // Le papier est blanc : couleurs du thème clair.
    accent: LightTokens.primaryTexte.toARGB32(),
    muted: LightTokens.texteSecondaire.toARGB32(),
  ),
);
