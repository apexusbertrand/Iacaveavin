import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/db/app_database.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../domain/photo_frame.dart';

/// AJO-13 : retouche du cadre de l'étiquette sur la photo d'origine, ou
/// retour à la photo entière. Renvoie vrai si la photo a changé.
class PhotoCropScreen extends ConsumerStatefulWidget {
  const PhotoCropScreen({super.key, required this.photo});

  final Photo photo;

  @override
  ConsumerState<PhotoCropScreen> createState() => _PhotoCropScreenState();
}

class _PhotoCropScreenState extends ConsumerState<PhotoCropScreen> {
  late Future<({ui.Image image, Size size})> _source = _load();
  PhotoFrame? _frame;
  bool _saving = false;

  Future<({ui.Image image, Size size})> _load() async {
    final file = await ref.read(photoServiceProvider).originalOf(widget.photo);
    final image = await decodeImageFromList(await file.readAsBytes());
    return (
      image: image,
      size: Size(image.width.toDouble(), image.height.toDouble()),
    );
  }

  Future<void> _save(PhotoFrame? frame) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(photoServiceProvider).setFrame(widget.photo, frame);
      messenger.showSnackBar(SnackBar(content: Text(l.cropSaved)));
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.cropTitle),
        actions: [
          TextButton(
            key: const ValueKey('crop-whole'),
            onPressed: _saving ? null : () => _save(null),
            child: Text(l.cropWhole),
          ),
          IconButton(
            key: const ValueKey('crop-save'),
            tooltip: l.save,
            onPressed: _saving
                ? null
                : () => _save(_frame ?? PhotoFrame.decode(widget.photo.cadre)),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _source,
        builder: (context, snap) {
          if (snap.hasError) {
            return MessageStateView(
              icon: Icons.broken_image_outlined,
              isError: true,
              title: l.operationFailed('${snap.error}'),
              action: FilledButton(
                onPressed: () => setState(() => _source = _load()),
                child: Text(l.retry),
              ),
            );
          }
          final source = snap.data;
          if (source == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.l),
                child: Text(l.cropHint, style: theme.textTheme.bodyMedium),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.l),
                  child: FrameEditor(
                    image: source.image,
                    imageSize: source.size,
                    frame:
                        _frame ??
                        PhotoFrame.decode(widget.photo.cadre) ??
                        PhotoFrame.full,
                    onChanged: (f) => setState(() => _frame = f),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.l),
                child: Text(
                  l.cropOriginalNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cadre déplaçable (glisser au centre) et redimensionnable (glisser un
/// coin) sur l'image ajustée à la place disponible.
class FrameEditor extends StatelessWidget {
  const FrameEditor({
    super.key,
    required this.image,
    required this.imageSize,
    required this.frame,
    required this.onChanged,
  });

  final ui.Image image;
  final Size imageSize;
  final PhotoFrame frame;
  final ValueChanged<PhotoFrame> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = applyBoxFit(
          BoxFit.contain,
          imageSize,
          constraints.biggest,
        ).destination;
        final w = fitted.width, h = fitted.height;
        final rect = Rect.fromLTWH(
          frame.x * w,
          frame.y * h,
          frame.width * w,
          frame.height * h,
        );
        const handle = SpacingTokens.xxl;

        void move(DragUpdateDetails d) => onChanged(
          PhotoFrame(
            x: frame.x + d.delta.dx / w,
            y: frame.y + d.delta.dy / h,
            width: frame.width,
            height: frame.height,
          ).clamped(),
        );

        void resize(
          DragUpdateDetails d, {
          required bool left,
          required bool top,
        }) {
          final dx = d.delta.dx / w, dy = d.delta.dy / h;
          var x0 = frame.x, y0 = frame.y;
          var x1 = frame.x + frame.width, y1 = frame.y + frame.height;
          if (left) {
            x0 = (x0 + dx).clamp(0.0, x1 - minFrameSide);
          } else {
            x1 = (x1 + dx).clamp(x0 + minFrameSide, 1.0);
          }
          if (top) {
            y0 = (y0 + dy).clamp(0.0, y1 - minFrameSide);
          } else {
            y1 = (y1 + dy).clamp(y0 + minFrameSide, 1.0);
          }
          onChanged(PhotoFrame(x: x0, y: y0, width: x1 - x0, height: y1 - y0));
        }

        Widget corner({required bool left, required bool top}) => Positioned(
          left: (left ? rect.left : rect.right) - handle / 2,
          top: (top ? rect.top : rect.bottom) - handle / 2,
          child: GestureDetector(
            key: ValueKey('crop-corner-${top ? 't' : 'b'}${left ? 'l' : 'r'}'),
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => resize(d, left: left, top: top),
            child: SizedBox.square(
              dimension: handle,
              child: Center(
                child: Container(
                  width: handle / 2,
                  height: handle / 2,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.onPrimary, width: 2),
                  ),
                ),
              ),
            ),
          ),
        );

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: RawImage(image: image, fit: BoxFit.fill),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FramePainter(
                        rect: rect,
                        dim: scheme.scrim.withValues(alpha: 0.5),
                        stroke: scheme.primary,
                      ),
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: GestureDetector(
                    key: const ValueKey('crop-frame'),
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: move,
                  ),
                ),
                corner(left: true, top: true),
                corner(left: false, top: true),
                corner(left: true, top: false),
                corner(left: false, top: false),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({required this.rect, required this.dim, required this.stroke});

  final Rect rect;
  final Color dim;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(rect),
    );
    canvas.drawPath(outside, Paint()..color = dim);
    canvas.drawRect(
      rect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.rect != rect || old.dim != dim || old.stroke != stroke;
}
