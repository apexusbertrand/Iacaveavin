import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/providers.dart';
import '../../domain/photo_frame.dart';
import '../add/capture_screen.dart' show imagePickerProvider;
import '../wine_detail/stock_dialogs.dart' show confirm;
import 'photo_gallery.dart';

/// FIC-11 : bibliothèque de photos de la bouteille (dégustation, repas,
/// événement), ajoutées à tout moment, jamais envoyées au flux.
class PhotoLibraryTab extends ConsumerStatefulWidget {
  const PhotoLibraryTab({super.key, required this.wineId});

  final String wineId;

  @override
  ConsumerState<PhotoLibraryTab> createState() => _PhotoLibraryTabState();
}

class _PhotoLibraryTabState extends ConsumerState<PhotoLibraryTab> {
  bool _busy = false;

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showModalBottomSheet<({String type, bool camera})>(
      context: context,
      builder: (context) => const _AddSheet(),
    );
    if (choice == null || !mounted) return;
    final bytes = await ref.read(imagePickerProvider)(camera: choice.camera);
    if (bytes == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(photoServiceProvider);
      final photo = await service.process(bytes);
      await service.save(
        wineId: widget.wineId,
        cellarId: await ref.read(bootstrapProvider.future),
        photo: photo,
        type: choice.type,
      );
      ref.invalidate(libraryPhotosProvider(widget.wineId));
      messenger.showSnackBar(SnackBar(content: Text(l.libraryAdded)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _delete(GalleryPhoto photo) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirm(
      context,
      title: l.photoDelete,
      body: l.photoDeleteBody,
      action: l.delete,
    );
    if (!ok) return false;
    await ref.read(photoServiceProvider).delete(photo.photo);
    ref.invalidate(libraryPhotosProvider(widget.wineId));
    messenger.showSnackBar(SnackBar(content: Text(l.photoDeleted)));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(libraryPhotosProvider(widget.wineId));
    final add = Padding(
      padding: const EdgeInsets.all(SpacingTokens.l),
      child: OutlinedButton.icon(
        key: const ValueKey('library-add'),
        onPressed: _busy ? null : _add,
        icon: _busy
            ? const SizedBox.square(
                dimension: SpacingTokens.l,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(l.libraryAdd),
      ),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => MessageStateView(
        icon: Icons.error_outline,
        isError: true,
        title: l.operationFailed('$e'),
      ),
      data: (photos) => photos.isEmpty
          ? MessageStateView(
              icon: Icons.photo_library_outlined,
              title: l.libraryEmpty,
              action: add,
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: add),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.l,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: SpacingTokens.s,
                          crossAxisSpacing: SpacingTokens.s,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, i) => Semantics(
                      button: true,
                      label: l.photoOpen(i + 1),
                      child: InkWell(
                        key: ValueKey('library-photo-$i'),
                        onTap: () => showPhotoGallery(
                          context,
                          photos,
                          initialIndex: i,
                          onDelete: _delete,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.carte,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(photos[i].thumb, fit: BoxFit.cover),
                              Positioned(
                                left: SpacingTokens.xs,
                                bottom: SpacingTokens.xs,
                                child: Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    l.photoTypeLabel(photos[i].photo.typePhoto),
                                  ),
                                ),
                              ),
                            ],
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

/// Type de la photo et source (appareil photo ou galerie).
class _AddSheet extends StatefulWidget {
  const _AddSheet();

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  String _type = libraryPhotoTypes.first;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.libraryTypeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.s),
            Wrap(
              spacing: SpacingTokens.s,
              children: [
                for (final t in libraryPhotoTypes)
                  ChoiceChip(
                    key: ValueKey('library-type-$t'),
                    label: Text(l.photoTypeLabel(t)),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.l),
            FilledButton.icon(
              key: const ValueKey('library-camera'),
              onPressed: () =>
                  Navigator.of(context).pop((type: _type, camera: true)),
              icon: const Icon(Icons.photo_camera),
              label: Text(l.takePhoto),
            ),
            const SizedBox(height: SpacingTokens.s),
            OutlinedButton.icon(
              key: const ValueKey('library-gallery'),
              onPressed: () =>
                  Navigator.of(context).pop((type: _type, camera: false)),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l.fromGallery),
            ),
          ],
        ),
      ),
    );
  }
}
