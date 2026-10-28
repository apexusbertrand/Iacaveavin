import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/vintage_reading.dart';

/// Résultat d'une lecture : millésime, rien de lisible, ou abandon.
class VintageResult {
  const VintageResult.found(int this.year) : cancelled = false;
  const VintageResult.notFound() : year = null, cancelled = false;
  const VintageResult.cancelled() : year = null, cancelled = true;

  final int? year;
  final bool cancelled;
}

/// AJO-14 : millésime lu en direct avec l'appareil photo ou sur une photo de
/// la galerie, comme le code-barres (AJO-10). Remplacé dans les tests.
abstract class VintageReader {
  Future<VintageResult> scanLive(BuildContext context);
  Future<VintageResult> fromPhoto();
}

final vintageReaderProvider = Provider<VintageReader>(
  (ref) => MlKitVintageReader(),
);

/// Reconnaissance de texte sur le téléphone (ML Kit, alphabet latin), sans
/// réseau ni envoi de l'image.
class MlKitVintageReader implements VintageReader {
  @override
  Future<VintageResult> scanLive(BuildContext context) async {
    final year = await Navigator.of(
      context,
    ).push<int>(MaterialPageRoute(builder: (_) => const VintageScanScreen()));
    return year == null
        ? const VintageResult.cancelled()
        : VintageResult.found(year);
  }

  @override
  Future<VintageResult> fromPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return const VintageResult.cancelled();
    final recognizer = TextRecognizer();
    try {
      final text = await recognizer.processImage(
        InputImage.fromFilePath(file.path),
      );
      final year = vintageFromText(text.text, currentYear: DateTime.now().year);
      return year == null
          ? const VintageResult.notFound()
          : VintageResult.found(year);
    } on Exception {
      return const VintageResult.notFound();
    } finally {
      await recognizer.close();
    }
  }
}

/// Viseur plein écran : lit le texte de l'image toutes les 400 ms et se
/// ferme dès qu'une même année est lue seule deux fois de suite.
class VintageScanScreen extends StatefulWidget {
  const VintageScanScreen({super.key});

  @override
  State<VintageScanScreen> createState() => _VintageScanScreenState();
}

class _VintageScanScreenState extends State<VintageScanScreen> {
  static const _interval = Duration(milliseconds: 400);
  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final _recognizer = TextRecognizer();
  final _vote = VintageVote();
  CameraController? _camera;
  bool _failed = false;
  bool _denied = false;
  bool _busy = false;
  bool _done = false;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final camera = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await camera.initialize();
      if (!mounted) {
        await camera.dispose();
        return;
      }
      setState(() => _camera = camera);
      await camera.startImageStream(_onFrame);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _failed = true;
          _denied = e.code.contains('Access') || e.code.contains('ermission');
        });
      }
    } on StateError {
      // Aucun appareil photo.
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    final now = DateTime.now();
    if (_busy || _done || now.difference(_last) < _interval) return;
    _busy = true;
    _last = now;
    try {
      final input = _inputImage(image);
      if (input == null) return;
      final text = await _recognizer.processImage(input);
      final year = _vote.add(
        vintageCandidates(text.text, currentYear: now.year),
      );
      if (!mounted) return;
      setState(() {});
      if (year != null && !_done) {
        _done = true;
        await _camera?.stopImageStream();
        if (mounted) Navigator.of(context).pop(year);
      }
    } on Exception {
      // Image illisible : on attend la suivante.
    } finally {
      _busy = false;
    }
  }

  /// Image de la caméra au format attendu par ML Kit : NV21 sur Android,
  /// BGRA sur iOS, avec la rotation de l'appareil.
  InputImage? _inputImage(CameraImage image) {
    final camera = _camera;
    if (camera == null) return null;
    final sensor = camera.description.sensorOrientation;
    final InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensor);
    } else {
      final device = _orientations[camera.value.deviceOrientation] ?? 0;
      rotation = InputImageRotationValue.fromRawValue(
        (sensor - device + 360) % 360,
      );
    }
    if (rotation == null) return null;
    final buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: Platform.isAndroid
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _done = true;
    final camera = _camera;
    if (camera != null) {
      if (camera.value.isStreamingImages) camera.stopImageStream();
      camera.dispose();
    }
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final camera = _camera;
    final seen = _vote.current;
    return Scaffold(
      appBar: AppBar(title: Text(l.vintageScanTitle)),
      body: _failed
          ? MessageStateView(
              icon: Icons.no_photography_outlined,
              title: _denied
                  ? l.scanPermissionDenied
                  : l.vintageScanUnavailable,
              body: l.vintageScanUseField,
              isError: true,
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                if (camera == null || !camera.value.isInitialized)
                  const Center(child: CircularProgressIndicator())
                else
                  Center(child: CameraPreview(camera)),
                Positioned(
                  left: SpacingTokens.l,
                  right: SpacingTokens.l,
                  bottom: SpacingTokens.xl,
                  child: SafeArea(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.m),
                        child: Text(
                          seen == null
                              ? l.vintageScanHint
                              : l.vintageScanSeen('$seen'),
                          key: const ValueKey('vintage-scan-hint'),
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
