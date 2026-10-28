import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/labels.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/export_providers.dart';
import '../../domain/garde.dart';
import '../../domain/wine_detail.dart';
import 'pdf_actions.dart';

/// CMP-06 : la fiche en carte, partagée en image ou en PDF.
Future<void> showShareSheet(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final service = ref.read(photoServiceProvider);
  final photos = await service.bottlePhotosOf(wine.id);
  final main = photos.where((p) => p.principale).followedBy(photos).firstOrNull;
  final File? photo = main == null ? null : await service.fileOf(main);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _ShareDialog(wine: wine, photo: photo),
  );
}

class _ShareDialog extends ConsumerStatefulWidget {
  const _ShareDialog({required this.wine, this.photo});

  final WineDetail wine;
  final File? photo;

  @override
  ConsumerState<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<_ShareDialog> {
  final _card = GlobalKey();
  bool _busy = false;

  Future<void> _image() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final boundary =
          _card.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await ref.read(fileSharerProvider)(
        data!.buffer.asUint8List(),
        '${wineSharedName(widget.wine)}.png',
        'image/png',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.sharePreviewTitle),
      contentPadding: const EdgeInsets.all(SpacingTokens.m),
      content: SingleChildScrollView(
        child: RepaintBoundary(
          key: _card,
          child: WineShareCard(wine: widget.wine, photo: widget.photo),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('share-pdf'),
          onPressed: _busy
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  await shareWinePdf(context, ref, widget.wine);
                  navigator.pop();
                },
          child: Text(l.shareAsPdf),
        ),
        FilledButton.icon(
          key: const ValueKey('share-image'),
          onPressed: _busy ? null : _image,
          icon: const Icon(Icons.image_outlined),
          label: Text(l.shareAsImage),
        ),
      ],
    );
  }
}

/// Carte de la fiche : photo, identité, origine, garde et notes.
class WineShareCard extends ConsumerWidget {
  const WineShareCard({super.key, required this.wine, this.photo});

  final WineDetail wine;
  final File? photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final d = wine.draft;
    final color = wineColor(d.color);
    final origin = [
      wine.label('appellation', d.appellation),
      wine.label('region', d.region),
      wine.label('pays', d.country),
    ].where((s) => s.isNotEmpty).toList();
    final status = cellarStatus(
      year: DateTime.now().year,
      start: d.gardeStart,
      peak: d.gardePeak,
      end: d.gardeEnd,
    );
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(RadiusTokens.carte),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.carte),
              child: SizedBox(
                width: SpacingTokens.xxl * 2.5,
                height: SpacingTokens.xxl * 3.5,
                child: photo != null && photo!.existsSync()
                    ? Image.file(photo!, fit: BoxFit.cover)
                    : ColoredBox(
                        color: color.fill,
                        child: Icon(Icons.wine_bar, color: color.onFill),
                      ),
              ),
            ),
            const SizedBox(width: SpacingTokens.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.producer.isNotEmpty
                        ? d.producer.toUpperCase()
                        : (d.cuvee ?? '').toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: context.palette.primaryText,
                    ),
                  ),
                  if (d.producer.isNotEmpty && (d.cuvee ?? '').isNotEmpty)
                    Text(d.cuvee!, style: theme.textTheme.bodyMedium),
                  Text(
                    d.vintage == 'NM' ? l.nonVintage : d.vintage,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (origin.isNotEmpty)
                    Text(origin.join(' · '), style: theme.textTheme.bodySmall),
                  const SizedBox(height: SpacingTokens.xs),
                  Wrap(
                    spacing: SpacingTokens.xs,
                    runSpacing: SpacingTokens.xs,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: color.fill,
                        label: Text(
                          wine.label('couleur', d.color),
                          style: TextStyle(color: color.onFill),
                        ),
                      ),
                      if (status != CellarStatus.unknown)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(l.statusLabel(status)),
                        ),
                    ],
                  ),
                  if (d.gardeStart != null || d.gardeEnd != null)
                    Text(
                      l.pdfGardeRange(
                        '${d.gardeStart ?? '?'}',
                        '${d.gardeEnd ?? '?'}',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  for (final s in wine.scores.take(3))
                    Text(
                      '${s.critic} ${s.score.round()}/${s.scale}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
