import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/photo_frame.dart';
import '../../domain/wine_detail.dart';
import '../add/capture_screen.dart' show imagePickerProvider;
import '../wine_detail/stock_dialogs.dart' show confirm, tastingDialog;
import 'photo_gallery.dart';
import 'tasting_photos.dart';

/// CMP-05, CMP-08, FIC-11 : un seul onglet pour les dégustations et les
/// photos de la bouteille. En haut, les dégustations avec leurs photos ; en
/// dessous, les photos prises hors dégustation (repas, événement...). Rien
/// n'est envoyé au flux.
class TastingsPhotosTab extends ConsumerStatefulWidget {
  const TastingsPhotosTab({super.key, required this.wine});

  final WineDetail wine;

  @override
  ConsumerState<TastingsPhotosTab> createState() => _TastingsPhotosTabState();
}

class _TastingsPhotosTabState extends ConsumerState<TastingsPhotosTab> {
  bool _busy = false;

  String get _wineId => widget.wine.id;

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
        wineId: _wineId,
        cellarId: await ref.read(bootstrapProvider.future),
        photo: photo,
        type: choice.type,
      );
      ref.invalidate(libraryPhotosProvider(_wineId));
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
    ref.invalidate(libraryPhotosProvider(_wineId));
    final tasting = photo.photo.degustationId;
    if (tasting != null) ref.invalidate(tastingPhotosProvider(tasting));
    messenger.showSnackBar(SnackBar(content: Text(l.photoDeleted)));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wine = widget.wine;
    final scale = ref.watch(settingsProvider.select((s) => s.personalScale));
    final async = ref.watch(libraryPhotosProvider(_wineId));
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: context.palette.textSecondary,
    );
    Widget title(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.l,
        SpacingTokens.l,
        SpacingTokens.l,
        SpacingTokens.xs,
      ),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    Widget empty(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
      child: Text(text, style: secondary),
    );
    final actions = Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.l,
        SpacingTokens.l,
        SpacingTokens.l,
        0,
      ),
      child: Wrap(
        spacing: SpacingTokens.s,
        runSpacing: SpacingTokens.s,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('tasting-add'),
            onPressed: () => tastingDialog(context, ref, wine),
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(l.addTasting),
          ),
          OutlinedButton.icon(
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
        ],
      ),
    );
    // Les photos d'une dégustation s'affichent sous elle, pas deux fois.
    final others = [
      for (final p in async.value ?? const <GalleryPhoto>[])
        if (p.photo.degustationId == null) p,
    ];
    return CustomScrollView(
      key: const ValueKey('tastings-photos'),
      slivers: [
        SliverToBoxAdapter(child: actions),
        SliverToBoxAdapter(child: title(l.tabTastings)),
        if (wine.tastings.isEmpty)
          SliverToBoxAdapter(child: empty(l.noTastings))
        else
          SliverList.builder(
            itemCount: wine.tastings.length,
            itemBuilder: (context, i) {
              final t = wine.tastings[i];
              return ListTile(
                title: Text(
                  [
                    t.date,
                    if (t.score != null) '${_num(t.score!)} / $scale',
                  ].join(' · '),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text([t.dish, t.comment].whereType<String>().join('\n')),
                    TastingPhotoStrip(tastingId: t.id, onDelete: _delete),
                  ],
                ),
              );
            },
          ),
        SliverToBoxAdapter(child: title(l.otherPhotos)),
        ...async.when(
          loading: () => [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(SpacingTokens.l),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (e, _) => [
            SliverToBoxAdapter(
              child: MessageStateView(
                icon: Icons.error_outline,
                isError: true,
                title: l.operationFailed('$e'),
              ),
            ),
          ],
          data: (_) => others.isEmpty
              ? [SliverToBoxAdapter(child: empty(l.libraryEmpty))]
              : [
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
                      itemCount: others.length,
                      itemBuilder: (context, i) => Semantics(
                        button: true,
                        label: l.photoOpen(i + 1),
                        child: InkWell(
                          key: ValueKey('library-photo-$i'),
                          onTap: () => showPhotoGallery(
                            context,
                            others,
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
                                Image.file(others[i].thumb, fit: BoxFit.cover),
                                Positioned(
                                  left: SpacingTokens.xs,
                                  bottom: SpacingTokens.xs,
                                  child: Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      l.photoTypeLabel(
                                        others[i].photo.typePhoto,
                                      ),
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
        const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl)),
      ],
    );
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');

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
