/// Mise en page PDF des fiches (PDF-01 à PDF-04), en Dart pur pour tourner
/// dans un isolate (NFR-02, PDF-05).
library;

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/pdf_content.dart';

/// Longueur des commentaires : fiche seule, ou demi-page du catalogue.
const unitCommentChars = 900;
const catalogueCommentChars = 260;

/// Champs affichés au plus sur une demi-page du catalogue.
const catalogueFieldRows = 14;

/// Document complet. [onPage] reçoit le nombre de fiches mises en page.
Future<Uint8List> buildPdf(PdfJob job, {void Function(int done)? onPage}) {
  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(ByteData.sublistView(job.regular)),
    bold: pw.Font.ttf(ByteData.sublistView(job.bold)),
  );
  final accent = PdfColor.fromInt(job.accent);
  final muted = PdfColor.fromInt(job.muted);
  final doc = pw.Document(theme: theme, title: job.texts.coverTitle);
  final pages =
      (job.cover ? 1 : 0) +
      (job.catalogue ? (job.wines.length + 1) ~/ 2 : job.wines.length);
  var page = 0;

  // Numéro calculé à l'ajout de la page, pas au dessin (plusieurs passes).
  pw.Widget footer(int n) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        job.texts.page.replaceAll('{n}', '$n').replaceAll('{total}', '$pages'),
        style: pw.TextStyle(fontSize: 8, color: muted),
      ),
    );
  }

  const margin = pw.EdgeInsets.fromLTRB(32, 28, 32, 20);
  if (job.cover) {
    final n = ++page;
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: margin,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Spacer(),
            pw.Text(
              job.texts.coverTitle,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              job.texts.editedOn,
              style: const pw.TextStyle(fontSize: 13),
            ),
            pw.Text(
              job.texts.coverCount,
              style: const pw.TextStyle(fontSize: 13),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              job.texts.coverFilters,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            if (job.filters.isEmpty)
              pw.Text(
                job.texts.coverNoFilter,
                style: const pw.TextStyle(fontSize: 11),
              )
            else
              for (final f in job.filters)
                pw.Bullet(text: f, style: const pw.TextStyle(fontSize: 11)),
            pw.Spacer(flex: 2),
            footer(n),
          ],
        ),
      ),
    );
  }

  pw.Widget block(PdfWine w, {required bool half}) {
    final size = half ? 8.0 : 10.0;
    final fields = half ? w.fields.take(catalogueFieldRows) : w.fields;
    final photoWidth = half ? 110.0 : 180.0;
    final photoHeight = half ? 150.0 : 250.0;
    final comments = [
      for (final (label, text) in w.comments)
        (
          label,
          truncateAtSentence(
            text,
            half ? catalogueCommentChars : unitCommentChars,
          ),
        ),
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: photoWidth,
              height: photoHeight,
              alignment: pw.Alignment.topCenter,
              child: w.photo == null
                  ? pw.SizedBox()
                  : pw.Image(pw.MemoryImage(w.photo!), fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 14),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    w.title.toUpperCase(),
                    maxLines: 2,
                    style: pw.TextStyle(
                      fontSize: half ? 12 : 16,
                      fontWeight: pw.FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  if (w.subtitle != null)
                    pw.Text(
                      w.subtitle!,
                      maxLines: 2,
                      style: pw.TextStyle(fontSize: size + 1),
                    ),
                  pw.Text(
                    w.vintage,
                    style: pw.TextStyle(
                      fontSize: half ? 16 : 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  for (final (label, value) in fields)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 1.5),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: half ? 80 : 110,
                            child: pw.Text(
                              label,
                              maxLines: 1,
                              style: pw.TextStyle(fontSize: size, color: muted),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              value,
                              maxLines: half ? 1 : 3,
                              style: pw.TextStyle(fontSize: size),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        for (final line in half ? w.lines.take(3) : w.lines)
          pw.Text(line, maxLines: 1, style: pw.TextStyle(fontSize: size)),
        for (final (label, text) in half ? comments.take(2) : comments)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.RichText(
              maxLines: half ? 4 : 14,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '$label  ',
                    style: pw.TextStyle(
                      fontSize: size,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.TextSpan(
                    text: text,
                    style: pw.TextStyle(fontSize: size),
                  ),
                ],
              ),
            ),
          ),
        pw.Spacer(),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Text(
                job.texts.editedOn,
                style: pw.TextStyle(fontSize: size - 1, color: muted),
              ),
            ),
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              drawText: false,
              data: wineDeepLink(w.id),
              width: half ? 46 : 64,
              height: half ? 46 : 64,
            ),
          ],
        ),
      ],
    );
  }

  var done = 0;
  if (job.catalogue) {
    for (var i = 0; i < job.wines.length; i += 2) {
      final pair = job.wines.skip(i).take(2).toList();
      final n = ++page;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: margin,
          build: (_) => pw.Column(
            children: [
              pw.Expanded(child: block(pair[0], half: true)),
              pw.Divider(color: muted, thickness: 0.5, height: 18),
              pw.Expanded(
                child: pair.length > 1
                    ? block(pair[1], half: true)
                    : pw.SizedBox(),
              ),
              footer(n),
            ],
          ),
        ),
      );
      done += pair.length;
      onPage?.call(done);
    }
  } else {
    for (final w in job.wines) {
      final n = ++page;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: margin,
          build: (_) => pw.Column(
            children: [
              pw.Expanded(child: block(w, half: false)),
              footer(n),
            ],
          ),
        ),
      );
      onPage?.call(++done);
    }
  }
  return doc.save();
}
