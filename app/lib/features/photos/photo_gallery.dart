import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/db/app_database.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../add/enrichment_screen.dart' show latestJobProvider;

/// Photo affichable : fichier, miniature et ligne de la base.
class GalleryPhoto {
  const GalleryPhoto({
    required this.photo,
    required this.file,
    required this.thumb,
  });

  final Photo photo;
  final File file;
  final File thumb;

  /// AJO-13 : photo rognée sur l'étiquette, d'origine encore gardée.
  bool get cropped => photo.cadre != null;
}

/// FIC-10 : photos de la bouteille (étiquette, contre-étiquette…).
final bottlePhotosProvider = FutureProvider.family<List<GalleryPhoto>, String>((
  ref,
  wineId,
) async {
  // Les cadres arrivent avec la fin du job (AJO-13).
  ref.watch(latestJobProvider(wineId));
  final service = ref.watch(photoServiceProvider);
  return [
    for (final p in await service.bottlePhotosOf(wineId))
      GalleryPhoto(
        photo: p,
        file: await service.fileOf(p),
        thumb: await service.thumbOf(p),
      ),
  ];
});

/// FIC-11 : bibliothèque de la bouteille.
final libraryPhotosProvider = FutureProvider.family<List<GalleryPhoto>, String>(
  (ref, wineId) async {
    final service = ref.watch(photoServiceProvider);
    return [
      for (final p in await service.libraryOf(wineId))
        GalleryPhoto(
          photo: p,
          file: await service.fileOf(p),
          thumb: await service.thumbOf(p),
        ),
    ];
  },
);

/// FIC-10 : plein écran, zoom et balayage d'une photo à l'autre. Avec
/// [onDelete], un bouton supprime la photo affichée (FIC-11).
Future<void> showPhotoGallery(
  BuildContext context,
  List<GalleryPhoto> photos, {
  int initialIndex = 0,
  Future<bool> Function(GalleryPhoto photo)? onDelete,
}) {
  if (photos.isEmpty) return Future.value();
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: _Gallery(
        photos: photos,
        initialIndex: initialIndex.clamp(0, photos.length - 1),
        onDelete: onDelete,
      ),
    ),
  );
}

class _Gallery extends StatefulWidget {
  const _Gallery({
    required this.photos,
    required this.initialIndex,
    this.onDelete,
  });

  final List<GalleryPhoto> photos;
  final int initialIndex;
  final Future<bool> Function(GalleryPhoto photo)? onDelete;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final photo = widget.photos[_index];
    return Stack(
      children: [
        PageView(
          key: const ValueKey('gallery-pages'),
          controller: _pages,
          onPageChanged: (i) => setState(() => _index = i),
          children: [
            for (final p in widget.photos)
              InteractiveViewer(
                maxScale: 5,
                child: Center(child: Image.file(p.file)),
              ),
          ],
        ),
        Positioned(
          top: SpacingTokens.l,
          left: SpacingTokens.l,
          child: Chip(
            key: const ValueKey('gallery-counter'),
            label: Text(
              [
                if (widget.photos.length > 1)
                  l.photoCounter(_index + 1, widget.photos.length),
                l.photoTypeLabel(photo.photo.typePhoto),
              ].join(' · '),
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
        Positioned(
          top: SpacingTokens.l,
          right: SpacingTokens.l,
          child: Row(
            children: [
              if (widget.onDelete != null)
                IconButton.filled(
                  key: const ValueKey('gallery-delete'),
                  tooltip: l.photoDelete,
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    if (await widget.onDelete!(photo)) navigator.pop();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              const SizedBox(width: SpacingTokens.s),
              IconButton.filled(
                tooltip: l.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// FIC-10 : carrousel des photos de la bouteille, points de position quand
/// il y en a plusieurs ; un tap ouvre le plein écran sur la photo affichée.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({super.key, required this.photos});

  final List<GalleryPhoto> photos;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final photos = widget.photos;
    final index = _index.clamp(0, photos.length - 1);
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          key: const ValueKey('photo-carousel'),
          itemCount: photos.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => Semantics(
            button: true,
            label: l.photoOpen(i + 1),
            child: InkWell(
              onTap: () => showPhotoGallery(context, photos, initialIndex: i),
              child: Image.file(photos[i].thumb, fit: BoxFit.cover),
            ),
          ),
        ),
        if (photos.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: SpacingTokens.xs,
            child: IgnorePointer(
              child: Row(
                key: const ValueKey('carousel-dots'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Container(
                      width: SpacingTokens.s,
                      height: SpacingTokens.s,
                      margin: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == index ? scheme.primary : scheme.surface,
                        border: Border.all(color: scheme.outline),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
