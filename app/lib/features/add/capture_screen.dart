import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/files/photo_service.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/wine_validation.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;

/// Source d'images : appareil photo ou galerie. Remplacée dans les tests.
typedef ImageSourcePicker = Future<Uint8List?> Function({required bool camera});

final imagePickerProvider = Provider<ImageSourcePicker>((ref) {
  return ({required bool camera}) async {
    final file = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 95,
    );
    return file?.readAsBytes();
  };
});

const photoTypes = [
  'etiquette',
  'contre_etiquette',
  'capsule',
  'collerette',
  'autre',
];

class _Shot {
  _Shot(this.photo, this.type);

  final ProcessedPhoto photo;
  String type;
}

/// AJO-02, AJO-03, AJO-10 : 1 à 4 photos, contrôle de netteté et de reflet,
/// EAN en indice, puis fiche enregistrée « à enrichir ».
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key, this.focusEan = false});

  final bool focusEan;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _shots = <_Shot>[];
  final _ean = TextEditingController();
  final _vintage = TextEditingController();
  bool _processing = false;
  bool _saving = false;
  String? _eanError;

  @override
  void dispose() {
    _ean.dispose();
    _vintage.dispose();
    super.dispose();
  }

  Future<void> _add({required bool camera}) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await ref.read(imagePickerProvider)(camera: camera);
    if (bytes == null || !mounted) return;
    setState(() => _processing = true);
    try {
      final photo = await ref.read(photoServiceProvider).process(bytes);
      if (!mounted) return;
      // AJO-02 : flou ou reflet, invitation à reprendre (non bloquante).
      if (!photo.quality.acceptable) {
        final retake = await confirm(
          context,
          title: photo.quality.blurry ? l.photoBlurry : l.photoGlare,
          body: photo.quality.blurry && photo.quality.glare ? l.photoGlare : '',
          action: l.retakePhoto,
        );
        if (retake) {
          setState(() => _processing = false);
          return await _add(camera: camera);
        }
      }
      setState(
        () => _shots.add(
          _Shot(photo, _shots.isEmpty ? 'etiquette' : 'contre_etiquette'),
        ),
      );
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l.photoUnreadable)));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<bool> _consent() async {
    final settings = ref.read(settingsProvider);
    if (settings.photoConsent) return true;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l.consentTitle),
        content: Text(l.consentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.consentRefuse),
          ),
          TextButton(
            key: const ValueKey('consent-accept'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.consentAccept),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(photoConsent: true));
    }
    return ok == true;
  }

  Future<void> _continue() async {
    final l = AppLocalizations.of(context);
    final ean = _ean.text.trim();
    if (ean.isNotEmpty && !isValidEan13(ean)) {
      setState(() => _eanError = l.errorEan);
      return;
    }
    final vintage = _vintage.text.trim().toUpperCase();
    final consent = await _consent();
    if (!mounted) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cellarId = await ref.read(bootstrapProvider.future);
      final validation = await ref.read(validationServiceProvider.future);
      final wineId = await validation.createPhotoWine(
        cellarId: cellarId,
        vintageHint: RegExp(r'^\d{4}$').hasMatch(vintage) ? vintage : null,
        ean: ean.isEmpty ? null : ean,
      );
      final photos = ref.read(photoServiceProvider);
      for (final s in _shots) {
        await photos.save(
          wineId: wineId,
          cellarId: cellarId,
          photo: s.photo,
          type: s.type,
        );
      }
      if (consent) {
        await (await ref.read(enrichmentQueueProvider.future)).enqueue(wineId);
        ref.read(enrichmentRunnerProvider.notifier).kick();
      } else {
        // Sans consentement, rien ne part : la fiche reste en brouillon.
        await ref.read(cellarRepositoryProvider).markDraft(wineId);
        messenger.showSnackBar(SnackBar(content: Text(l.consentRefused)));
      }
      if (mounted) context.pushReplacement('/fiche/$wineId/identification');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.captureTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.l),
        children: [
          Text(l.captureHint, style: theme.textTheme.bodyLarge),
          const SizedBox(height: SpacingTokens.l),
          for (final (i, s) in _shots.indexed)
            Card(
              margin: const EdgeInsets.only(bottom: SpacingTokens.m),
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.s),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(RadiusTokens.badge),
                      child: Image.memory(
                        s.photo.thumb,
                        width: SpacingTokens.xxl * 3,
                        height: SpacingTokens.xxl * 3,
                        fit: BoxFit.cover,
                        semanticLabel: l.photoTypeLabel(s.type),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton<String>(
                            value: s.type,
                            isExpanded: true,
                            items: [
                              for (final t in photoTypes)
                                DropdownMenuItem(
                                  value: t,
                                  child: Text(l.photoTypeLabel(t)),
                                ),
                            ],
                            onChanged: (v) =>
                                setState(() => s.type = v ?? s.type),
                          ),
                          if (s.photo.quality.blurry)
                            Text(
                              l.photoBlurry,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          if (s.photo.quality.glare)
                            Text(
                              l.photoGlare,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.removePhoto,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _shots.removeAt(i)),
                    ),
                  ],
                ),
              ),
            ),
          if (_processing)
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.l),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: SpacingTokens.l),
                  Expanded(child: Text(l.photoProcessing)),
                ],
              ),
            ),
          // Boutons pleine largeur : rien ne déborde à 360 dp ni à 200 %.
          if (_shots.length < 4 && !_processing) ...[
            FilledButton.icon(
              key: const ValueKey('take-photo'),
              onPressed: () => _add(camera: true),
              icon: const Icon(Icons.photo_camera),
              label: Text(l.takePhoto),
            ),
            const SizedBox(height: SpacingTokens.s),
            OutlinedButton.icon(
              key: const ValueKey('from-gallery'),
              onPressed: () => _add(camera: false),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l.fromGallery),
            ),
          ],
          const SizedBox(height: SpacingTokens.xl),
          TextField(
            key: const ValueKey('capture-ean'),
            controller: _ean,
            autofocus: widget.focusEan,
            keyboardType: TextInputType.number,
            maxLength: 13,
            decoration: InputDecoration(
              labelText: l.eanField,
              errorText: _eanError,
            ),
            onChanged: (_) => setState(() => _eanError = null),
          ),
          TextField(
            controller: _vintage,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(labelText: l.vintageHintField),
          ),
          const SizedBox(height: SpacingTokens.l),
          if (_shots.isEmpty)
            Text(
              l.needOnePhoto,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          const SizedBox(height: SpacingTokens.s),
          FilledButton(
            key: const ValueKey('capture-continue'),
            onPressed: _shots.isEmpty || _saving || _processing
                ? null
                : _continue,
            child: Text(l.continueToEnrichment),
          ),
        ],
      ),
    );
  }
}
