import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/wine_validation.dart';

/// Formats lus : ceux des bouteilles vendues en Europe et en Amérique du Nord.
const _formats = [BarcodeFormat.ean13, BarcodeFormat.upcA];

/// Résultat d'une lecture : code EAN-13 valide, rien de lisible, ou abandon.
class BarcodeResult {
  const BarcodeResult.found(String this.code) : cancelled = false;
  const BarcodeResult.notFound() : code = null, cancelled = false;
  const BarcodeResult.cancelled() : code = null, cancelled = true;

  final String? code;
  final bool cancelled;
}

/// AJO-10 : lecture du code-barres, en direct avec l'appareil photo ou sur
/// une photo de la galerie. Remplacée dans les tests.
abstract class BarcodeReader {
  Future<BarcodeResult> scanLive(BuildContext context);
  Future<BarcodeResult> fromPhoto();
}

final barcodeReaderProvider = Provider<BarcodeReader>(
  (ref) => MobileScannerReader(),
);

/// Lecture sur l'appareil (ML Kit sur Android, Vision sur iOS), sans réseau.
class MobileScannerReader implements BarcodeReader {
  @override
  Future<BarcodeResult> scanLive(BuildContext context) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    return code == null
        ? const BarcodeResult.cancelled()
        : BarcodeResult.found(code);
  }

  @override
  Future<BarcodeResult> fromPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return const BarcodeResult.cancelled();
    final controller = MobileScannerController(
      autoStart: false,
      formats: _formats,
    );
    try {
      final capture = await controller.analyzeImage(
        file.path,
        formats: _formats,
      );
      final code = eanFromScan(
        capture?.barcodes.map((b) => b.rawValue) ?? const [],
      );
      return code == null
          ? const BarcodeResult.notFound()
          : BarcodeResult.found(code);
    } on MobileScannerException {
      return const BarcodeResult.notFound();
    } finally {
      await controller.dispose();
    }
  }
}

/// Viseur plein écran : se ferme sur le premier EAN valide.
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _controller = MobileScannerController(formats: _formats);
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final code = eanFromScan(capture.barcodes.map((b) => b.rawValue));
    if (code == null) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.scanTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, e) => ColoredBox(
              color: theme.colorScheme.surface,
              child: MessageStateView(
                icon: Icons.no_photography_outlined,
                title: e.errorCode == MobileScannerErrorCode.permissionDenied
                    ? l.scanPermissionDenied
                    : l.scanUnavailable,
                body: l.scanUseField,
                isError: true,
              ),
            ),
          ),
          Positioned(
            left: SpacingTokens.l,
            right: SpacingTokens.l,
            bottom: SpacingTokens.xl,
            child: SafeArea(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.m),
                  child: Text(
                    l.scanHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.palette.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
