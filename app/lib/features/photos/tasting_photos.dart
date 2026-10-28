import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/files/photo_service.dart';
import '../add/capture_screen.dart' show imagePickerProvider;
import 'photo_gallery.dart';

/// CMP-08 : au plus 6 photos par dégustation.
const maxTastingPhotos = 6;

/// CMP-08 : photos d'une dégustation, dans l'ordre de prise.
final tastingPhotosProvider = FutureProvider.family<List<GalleryPhoto>, String>(
  (ref, tastingId) async {
    final service = ref.watch(photoServiceProvider);
    return [
      for (final p in await service.tastingPhotosOf(tastingId))
        GalleryPhoto(
          photo: p,
          file: await service.fileOf(p),
          thumb: await service.thumbOf(p),
        ),
    ];
  },
);

/// CMP-08 : miniatures d'une dégustation ; un tap ouvre le plein écran.
class TastingPhotoStrip extends ConsumerWidget {
  const TastingPhotoStrip({super.key, required this.tastingId, this.onDelete});

  final String tastingId;

  /// Suppression depuis le plein écran ; absente, la galerie est en lecture.
  final Future<bool> Function(GalleryPhoto photo)? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final photos = ref.watch(tastingPhotosProvider(tastingId)).value;
    if (photos == null || photos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.s),
      child: SizedBox(
        height: SpacingTokens.xxl * 2,
        child: ListView.separated(
          key: ValueKey('tasting-photos-$tastingId'),
          scrollDirection: Axis.horizontal,
          itemCount: photos.length,
          separatorBuilder: (_, _) => const SizedBox(width: SpacingTokens.s),
          itemBuilder: (context, i) => Semantics(
            button: true,
            label: l.photoOpen(i + 1),
            child: InkWell(
              onTap: () => showPhotoGallery(
                context,
                photos,
                initialIndex: i,
                onDelete: onDelete,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.badge),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(photos[i].thumb, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CMP-08 : photos prises dans le formulaire de dégustation, gardées en
/// mémoire (déjà réduites) jusqu'à l'enregistrement.
class TastingPhotoPicker extends ConsumerStatefulWidget {
  const TastingPhotoPicker({super.key, required this.photos});

  /// Liste remplie par le formulaire, lue à l'enregistrement.
  final List<ProcessedPhoto> photos;

  @override
  ConsumerState<TastingPhotoPicker> createState() => _TastingPhotoPickerState();
}

class _TastingPhotoPickerState extends ConsumerState<TastingPhotoPicker> {
  bool _busy = false;

  Future<void> _add({required bool camera}) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await ref.read(imagePickerProvider)(camera: camera);
    if (bytes == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final photo = await ref
          .read(photoServiceProvider)
          .processForScreen(bytes);
      if (mounted) setState(() => widget.photos.add(photo));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final full = widget.photos.length >= maxTastingPhotos;
    final canAdd = !_busy && !full;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.m),
        Text(l.tastingPhotos, style: theme.textTheme.titleSmall),
        const SizedBox(height: SpacingTokens.s),
        if (widget.photos.isNotEmpty)
          Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.s,
            children: [
              for (final (i, p) in widget.photos.indexed)
                Stack(
                  key: ValueKey('tasting-new-photo-$i'),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(RadiusTokens.badge),
                      child: Image.memory(
                        p.thumb,
                        width: SpacingTokens.xxl * 2,
                        height: SpacingTokens.xxl * 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton.filledTonal(
                        key: ValueKey('tasting-photo-remove-$i'),
                        tooltip: l.tastingPhotoRemove,
                        visualDensity: VisualDensity.compact,
                        iconSize: SpacingTokens.l,
                        onPressed: () =>
                            setState(() => widget.photos.removeAt(i)),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        if (full)
          Text(
            l.tastingPhotosMax(maxTastingPhotos),
            style: theme.textTheme.bodySmall,
          ),
        Wrap(
          spacing: SpacingTokens.s,
          children: [
            TextButton.icon(
              key: const ValueKey('tasting-photo-camera'),
              onPressed: canAdd ? () => _add(camera: true) : null,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: SpacingTokens.l,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera_outlined),
              label: Text(l.takePhoto),
            ),
            TextButton.icon(
              key: const ValueKey('tasting-photo-gallery'),
              onPressed: canAdd ? () => _add(camera: false) : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l.fromGallery),
            ),
          ],
        ),
      ],
    );
  }
}
