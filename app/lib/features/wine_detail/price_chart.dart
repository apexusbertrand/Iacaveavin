import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// PRX-05 : courbe des prix relevés (trouvés seulement), du plus ancien au
/// plus récent. Couleurs passées par le thème (règle des jetons).
class PriceChartPainter extends CustomPainter {
  PriceChartPainter(this.values, {required this.line, required this.axis});

  final List<double> values;
  final Color line;
  final Color axis;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    const pad = 8.0;
    final h = size.height - 2 * pad;
    final w = size.width - 2 * pad;
    Offset at(int i) => Offset(
      pad + w * i / (values.length - 1),
      pad + h - h * (values[i] - lo) / span,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(size.width - pad, size.height - pad),
      Paint()
        ..color = axis
        ..strokeWidth = 1,
    );
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final stroke = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, stroke);
    final dot = Paint()..color = line;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(at(i), 3, dot);
    }
  }

  @override
  bool shouldRepaint(PriceChartPainter old) =>
      old.values != values || old.line != line || old.axis != axis;
}

/// Ouvre le lien d'une offre dans le navigateur.
Future<void> openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}
