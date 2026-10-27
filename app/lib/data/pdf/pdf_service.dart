import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/garde.dart';
import '../../domain/pdf_content.dart';
import '../../domain/scores.dart';
import '../cellar_repository.dart';
import '../files/photo_service.dart';
import 'pdf_builder.dart';

/// Polices embarquées (assets/fonts, licence Apache 2.0).
const fontRegularAsset = 'assets/fonts/Roboto-Regular.ttf';
const fontBoldAsset = 'assets/fonts/Roboto-Bold.ttf';

/// PDF-01 à PDF-05 : fiche unitaire et catalogue, hors ligne, en arrière-plan.
class PdfService {
  PdfService({
    required this.cellar,
    required this.photos,
    required this.readAsset,
    required this.year,
    required this.accent,
    required this.muted,
  });

  final CellarRepository cellar;
  final PhotoService? photos;

  /// Lecture d'un asset binaire (rootBundle dans l'app, disque en test).
  final Future<Uint8List> Function(String path) readAsset;
  final int year;
  final int accent;
  final int muted;

  /// Contenu imprimé d'une fiche (champs `pdf: true` du dictionnaire).
  Future<PdfWine?> content(
    String wineId,
    AppLocalizations l, {
    required String Function(double amount) money,
    bool fullPhoto = false,
  }) async {
    final w = await cellar.wine(wineId);
    if (w == null) return null;
    final d = w.draft;
    String? lab(String list, String? code) =>
        code == null || code.isEmpty ? null : w.label(list, code);
    final status = cellarStatus(
      year: year,
      start: d.gardeStart,
      peak: d.gardePeak,
      end: d.gardeEnd,
    );
    final garde = d.gardeStart == null && d.gardeEnd == null
        ? null
        : [
            l.pdfGardeRange('${d.gardeStart ?? '?'}', '${d.gardeEnd ?? '?'}'),
            if (d.gardePeak != null) l.pdfGardePeak('${d.gardePeak}'),
          ].join(' · ');
    final parker = parkerScore(w.scores);
    final fields = <(String, String?)>[
      (l.fieldCountry, lab('pays', d.country)),
      (l.fieldRegion, lab('region', d.region)),
      (l.fieldSubRegion, lab('sous_region', d.subRegion)),
      (l.fieldAppellation, lab('appellation', d.appellation)),
      (l.fieldQualitySign, lab('signe_qualite', d.qualitySign)),
      (l.fieldClassification, lab('classement', d.classification)),
      (l.fieldLieuDit, d.lieuDit),
      (l.fieldColor, lab('couleur', d.color)),
      (l.fieldType, lab('type_vin', d.wineType)),
      (l.fieldCertification, lab('certification', d.certification)),
      (
        l.fieldGrapes,
        d.grapes.isEmpty
            ? null
            : [
                for (final g in d.grapes)
                  g.percent == null
                      ? w.label('cepage', g.code)
                      : '${w.label('cepage', g.code)} ${g.percent} %',
              ].join(', '),
      ),
      (
        l.fieldAlcohol,
        d.alcohol == null
            ? null
            : l.pdfAlcohol('${d.alcohol}'.replaceAll('.', ',')),
      ),
      (l.fieldGarde, garde),
      (
        l.pdfGardeSource,
        w.gardeSource == null ? null : l.sourceLabel(w.gardeSource),
      ),
      (
        l.pdfGardeStatus,
        status == CellarStatus.unknown ? null : l.statusLabel(status),
      ),
      (
        l.fieldPairings,
        d.pairings.isEmpty
            ? null
            : [for (final a in d.pairings) w.label('accord_mets', a)]
                  .join(', '),
      ),
      (
        l.pdfParker,
        parker == null ? null : '${_n(parker.score)}/${parker.scale}',
      ),
      (l.pdfStock, l.pdfBottles(w.bottles)),
    ];
    final lines = <String>[
      for (final s in w.scores)
        [
          '${s.critic} ${_n(s.score)}/${s.scale}',
          if (s.citedBy != null) l.pdfCitedBy(s.citedBy!),
        ].join(' · '),
      for (final lot in w.lots)
        if (lot.bottles > 0)
          [
            l.formatCl(_n(lot.formatCl)),
            lot.ownerName,
            ?lot.locationPath,
            if (lot.positions != null) lot.positions!,
            l.pdfBottles(lot.bottles),
            if (lot.unitPrice != null) l.pdfPrice(money(lot.unitPrice!)),
          ].join(' · '),
    ];
    final comments = <(String, String)>[
      if ((d.producerComment ?? '').isNotEmpty)
        (l.fieldProducerComment, d.producerComment!),
      if ((d.vintageComment ?? '').isNotEmpty)
        (l.fieldVintageComment, d.vintageComment!),
      if ((d.personalComment ?? '').isNotEmpty)
        (l.fieldPersonalComment, d.personalComment!),
    ];
    Uint8List? photo;
    final service = photos;
    if (service != null) {
      final main = (await service.bottlePhotosOf(wineId))
          .where((p) => p.principale)
          .followedBy(await service.bottlePhotosOf(wineId))
          .firstOrNull;
      if (main != null) {
        final file = fullPhoto
            ? await service.fileOf(main)
            : await service.thumbOf(main);
        if (file.existsSync()) photo = await file.readAsBytes();
      }
    }
    final title = d.producer.isNotEmpty ? d.producer : (d.cuvee ?? '');
    return PdfWine(
      id: wineId,
      title: title,
      subtitle: [
        if (d.producer.isNotEmpty && (d.cuvee ?? '').isNotEmpty) d.cuvee!,
        ?lab('appellation', d.appellation),
      ].join(' · ').ifEmpty,
      vintage: d.vintage == 'NM' ? l.nonVintage : d.vintage,
      fields: [
        for (final (label, value) in fields)
          if (value != null && value.isNotEmpty) (label, value),
      ],
      comments: comments,
      lines: lines,
      photo: photo,
    );
  }

  static String _n(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v'.replaceAll('.', ',');

  PdfTexts _texts(AppLocalizations l, String date, int count) => PdfTexts(
    editedOn: l.pdfEditedOn(date),
    coverTitle: l.pdfCatalogueTitle,
    coverCount: l.pdfCount(count),
    coverFilters: l.pdfFilters,
    coverNoFilter: l.pdfNoFilter,
    page: l.pdfPage('{n}', '{total}'),
  );

  Future<PdfJob> _job(
    List<PdfWine> wines,
    AppLocalizations l,
    String date, {
    bool catalogue = false,
    bool cover = false,
    List<String> filters = const [],
  }) async => PdfJob(
    wines: wines,
    texts: _texts(l, date, wines.length),
    regular: await readAsset(fontRegularAsset),
    bold: await readAsset(fontBoldAsset),
    accent: accent,
    muted: muted,
    catalogue: catalogue,
    cover: cover,
    filters: filters,
  );

  /// PDF-01 : fiche unitaire, A4 portrait.
  Future<Uint8List> wineSheet(
    String wineId,
    AppLocalizations l, {
    required String date,
    required String Function(double amount) money,
  }) async {
    final w = await content(wineId, l, money: money, fullPhoto: true);
    if (w == null) throw StateError('fiche introuvable');
    return render(await _job([w], l, date));
  }

  /// PDF-02, PDF-03, PDF-05 : catalogue des fiches [wineIds], dans l'ordre
  /// donné. [onProgress] reçoit l'avancement de 0 à 1.
  Future<Uint8List> catalogue(
    List<String> wineIds,
    AppLocalizations l, {
    required String date,
    required String Function(double amount) money,
    bool cover = true,
    List<String> filters = const [],
    void Function(double progress)? onProgress,
  }) async {
    final wines = <PdfWine>[];
    for (final (i, id) in wineIds.indexed) {
      final w = await content(id, l, money: money);
      if (w != null) wines.add(w);
      onProgress?.call((i + 1) / wineIds.length / 2);
    }
    final job = await _job(
      wines,
      l,
      date,
      catalogue: true,
      cover: cover,
      filters: filters,
    );
    return render(
      job,
      onPage: (done) => onProgress?.call(0.5 + done / wines.length / 2),
    );
  }

  /// Mise en page dans un isolate, avancement renvoyé fiche par fiche.
  static Future<Uint8List> render(
    PdfJob job, {
    void Function(int done)? onPage,
  }) async {
    final port = ReceivePort();
    await Isolate.spawn(_entry, (job, port.sendPort));
    final out = Completer<Uint8List>();
    port.listen((m) {
      if (m is int) {
        onPage?.call(m);
      } else if (m is TransferableTypedData) {
        out.complete(m.materialize().asUint8List());
        port.close();
      } else {
        out.completeError(StateError('$m'));
        port.close();
      }
    });
    return out.future;
  }

  static Future<void> _entry((PdfJob, SendPort) args) async {
    final (job, send) = args;
    try {
      final bytes = await buildPdf(job, onPage: send.send);
      send.send(TransferableTypedData.fromList([bytes]));
    } catch (e) {
      send.send('$e');
    }
  }
}

extension on String {
  String? get ifEmpty => isEmpty ? null : this;
}
