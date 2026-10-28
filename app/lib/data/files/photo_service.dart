import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/photo_frame.dart';
import '../db/app_database.dart';

/// Tailles de docs/02-architecture.md (§ Volumes et stockage).
const storedLongSide = 1600;
const sentLongSide = 1500;
const thumbLongSide = 320;
const jpegQuality = 80;

/// CMP-07 : photos de dégustation ramenées à un écran de smartphone (Full HD,
/// 1 080 × 1 920 au plus dans leur sens), environ 200 à 400 Ko.
const screenShortSide = 1080;
const screenLongSide = 1920;

/// AJO-02 : seuils de détection (variance du laplacien sur 400 px, part de
/// pixels quasi blancs). Heuristique courante, à recaler sur de vraies photos
/// pendant la recette : la détection invite à reprendre, sans bloquer.
const blurThreshold = 100.0;
const glareThreshold = 0.08;

class PhotoQuality {
  const PhotoQuality({required this.sharpness, required this.glareRatio});

  /// Variance du laplacien sur l'image réduite : plus c'est haut, plus net.
  final double sharpness;

  /// Part des pixels quasi blancs (reflet de flash ou de lumière).
  final double glareRatio;

  bool get blurry => sharpness < blurThreshold;
  bool get glare => glareRatio > glareThreshold;
  bool get acceptable => !blurry && !glare;
}

class ProcessedPhoto {
  const ProcessedPhoto({
    required this.stored,
    required this.thumb,
    required this.width,
    required this.height,
    required this.quality,
  });

  final Uint8List stored;
  final Uint8List thumb;
  final int width;
  final int height;
  final PhotoQuality quality;
}

img.Image _resize(img.Image src, int longSide) {
  if (src.width <= longSide && src.height <= longSide) return src;
  return src.width >= src.height
      ? img.copyResize(
          src,
          width: longSide,
          interpolation: img.Interpolation.average,
        )
      : img.copyResize(
          src,
          height: longSide,
          interpolation: img.Interpolation.average,
        );
}

/// Mesure de netteté et de reflet sur une version réduite (rapide).
PhotoQuality measureQuality(img.Image source) {
  final small = img.grayscale(_resize(source, 400));
  final w = small.width, h = small.height;
  final lum = List<double>.filled(w * h, 0);
  var bright = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final v = small.getPixel(x, y).r.toDouble();
      lum[y * w + x] = v;
      if (v >= 245) bright++;
    }
  }
  var sum = 0.0, sumSq = 0.0, n = 0;
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final c = lum[y * w + x];
      final lap =
          lum[(y - 1) * w + x] +
          lum[(y + 1) * w + x] +
          lum[y * w + x - 1] +
          lum[y * w + x + 1] -
          4 * c;
      sum += lap;
      sumSq += lap * lap;
      n++;
    }
  }
  final mean = n == 0 ? 0 : sum / n;
  final variance = n == 0 ? 0.0 : sumSq / n - mean * mean;
  return PhotoQuality(sharpness: variance, glareRatio: bright / (w * h));
}

/// AJO-03 : 1 600 px stockés, miniature 320 px, JPEG qualité 80.
ProcessedPhoto processPhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('image illisible');
  final oriented = img.bakeOrientation(decoded);
  final stored = _resize(oriented, storedLongSide);
  return ProcessedPhoto(
    stored: Uint8List.fromList(img.encodeJpg(stored, quality: jpegQuality)),
    thumb: Uint8List.fromList(
      img.encodeJpg(_resize(stored, thumbLongSide), quality: jpegQuality),
    ),
    width: stored.width,
    height: stored.height,
    quality: measureQuality(stored),
  );
}

/// Réduit [src] pour tenir dans un écran de smartphone, portrait ou paysage.
img.Image fitScreen(img.Image src) {
  final long = src.width >= src.height ? src.width : src.height;
  final short = src.width >= src.height ? src.height : src.width;
  final scale = [
    1.0,
    screenLongSide / long,
    screenShortSide / short,
  ].reduce((a, b) => a < b ? a : b);
  if (scale >= 1) return src;
  return img.copyResize(
    src,
    width: (src.width * scale).round(),
    height: (src.height * scale).round(),
    interpolation: img.Interpolation.average,
  );
}

/// CMP-07 : photo de dégustation à la taille d'un écran, miniature 320 px.
ProcessedPhoto processScreenPhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('image illisible');
  final stored = fitScreen(img.bakeOrientation(decoded));
  return ProcessedPhoto(
    stored: Uint8List.fromList(img.encodeJpg(stored, quality: jpegQuality)),
    thumb: Uint8List.fromList(
      img.encodeJpg(_resize(stored, thumbLongSide), quality: jpegQuality),
    ),
    width: stored.width,
    height: stored.height,
    quality: measureQuality(stored),
  );
}

/// AJO-13 : photo rognée sur le cadre de l'étiquette, mêmes tailles que
/// [processPhoto].
ProcessedPhoto cropPhoto(Uint8List bytes, PhotoFrame frame) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('image illisible');
  final oriented = img.bakeOrientation(decoded);
  final r = frame.toPixels(oriented.width, oriented.height);
  final cropped = img.copyCrop(
    oriented,
    x: r.left,
    y: r.top,
    width: r.width,
    height: r.height,
  );
  final stored = _resize(cropped, storedLongSide);
  return ProcessedPhoto(
    stored: Uint8List.fromList(img.encodeJpg(stored, quality: jpegQuality)),
    thumb: Uint8List.fromList(
      img.encodeJpg(_resize(stored, thumbLongSide), quality: jpegQuality),
    ),
    width: stored.width,
    height: stored.height,
    quality: measureQuality(stored),
  );
}

/// Version envoyée au flux : 1 500 px, qualité 80, en base64.
String encodeForFlux(Uint8List stored) {
  final decoded = img.decodeImage(stored)!;
  return base64Encode(
    img.encodeJpg(_resize(decoded, sentLongSide), quality: jpegQuality),
  );
}

/// Stockage des photos dans le répertoire privé de l'app (NFR-04) : chemins
/// relatifs en base, miniature à côté, suppression en cascade avec la fiche.
class PhotoService {
  PhotoService(this._db, {required this.appDir, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Future<Directory> Function() appDir;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  /// NFR-02 : traitement dans un isolate.
  Future<ProcessedPhoto> process(Uint8List bytes) =>
      Isolate.run(() => processPhoto(bytes));

  /// CMP-07 : photo de dégustation, traitée dans un isolate.
  Future<ProcessedPhoto> processForScreen(Uint8List bytes) =>
      Isolate.run(() => processScreenPhoto(bytes));

  Future<String> _abs(String relative) async =>
      p.join((await appDir()).path, relative);

  static String thumbPathFor(String relative) =>
      relative.replaceFirst(RegExp(r'\.jpg$'), '_mini.jpg');

  /// Enregistre une photo traitée pour une fiche. La première photo de la
  /// bouteille devient la photo principale ; une photo de la bibliothèque
  /// (FIC-11) ne l'est jamais.
  Future<String> save({
    required String wineId,
    required String cellarId,
    required ProcessedPhoto photo,
    required String type,
    String? tastingId,
  }) async {
    final id = _uuid.v4();
    final relative = p.posix.join('photos', wineId, '$id.jpg');
    final file = File(await _abs(relative));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(photo.stored);
    await File(await _abs(thumbPathFor(relative))).writeAsBytes(photo.thumb);
    final existing = await bottlePhotosOf(wineId);
    final now = _clock().toUtc();
    await _db
        .into(_db.photos)
        .insert(
          PhotosCompanion.insert(
            id: id,
            caveId: cellarId,
            createdAt: now,
            updatedAt: now,
            ficheId: wineId,
            chemin: relative,
            typePhoto: type,
            principale: existing.isEmpty && !isLibraryPhoto(type),
          ).copyWith(
            largeur: Value(photo.width),
            hauteur: Value(photo.height),
            octets: Value(photo.stored.length),
            degustationId: Value(tastingId),
          ),
        );
    return id;
  }

  Future<List<Photo>> photosOf(String wineId) =>
      (_db.select(_db.photos)
            ..where((x) => x.ficheId.equals(wineId) & x.deletedAt.isNull())
            ..orderBy([(x) => OrderingTerm.asc(x.createdAt)]))
          .get();

  /// Photos de la bouteille (étiquette, contre-étiquette…), dans l'ordre de
  /// prise : celles envoyées au flux.
  Future<List<Photo>> bottlePhotosOf(String wineId) async => [
    for (final ph in await photosOf(wineId))
      if (!isLibraryPhoto(ph.typePhoto)) ph,
  ];

  /// FIC-11 : bibliothèque de la bouteille (dégustation, repas, événement).
  Future<List<Photo>> libraryOf(String wineId) async => [
    for (final ph in await photosOf(wineId))
      if (isLibraryPhoto(ph.typePhoto)) ph,
  ];

  /// CMP-07 : photos prises en notant une dégustation, dans l'ordre de prise.
  Future<List<Photo>> tastingPhotosOf(String tastingId) =>
      (_db.select(_db.photos)
            ..where(
              (x) => x.degustationId.equals(tastingId) & x.deletedAt.isNull(),
            )
            ..orderBy([(x) => OrderingTerm.asc(x.createdAt)]))
          .get();

  Future<File> fileOf(Photo photo) async => File(await _abs(photo.chemin));

  /// AJO-13 : photo entière, tant que la fiche n'est pas validée.
  Future<File> originalOf(Photo photo) async =>
      File(await _abs(photo.cheminOriginal ?? photo.chemin));

  Future<File> thumbOf(Photo photo) async =>
      File(await _abs(thumbPathFor(photo.chemin)));

  /// Photos prêtes pour la requête au flux (1 à 4, dans l'ordre de prise).
  Future<List<({int index, String type, String base64})>> forRequest(
    String wineId,
  ) async {
    final out = <({int index, String type, String base64})>[];
    for (final (i, ph) in (await bottlePhotosOf(wineId)).take(4).indexed) {
      final bytes = await (await fileOf(ph)).readAsBytes();
      out.add((
        index: i,
        type: ph.typePhoto,
        base64: await Isolate.run(() => encodeForFlux(bytes)),
      ));
    }
    return out;
  }

  /// AJO-13 : applique les cadres renvoyés par le flux. L'index suit
  /// l'ordre de [forRequest] ; un cadre absent laisse la photo entière. Une
  /// photo déjà recadrée (cadre du flux ou retouche) n'est pas rognée une
  /// seconde fois : relire la même réponse ne change rien.
  Future<void> applyFrames(String wineId, List<LabelFrame> frames) async {
    final photos = (await bottlePhotosOf(wineId)).take(4).toList();
    for (final f in frames) {
      final frame = f.frame;
      if (frame == null || frame.isFull) continue;
      if (f.index < 0 || f.index >= photos.length) continue;
      final ph = photos[f.index];
      if (ph.cheminOriginal != null) continue;
      await setFrame(ph, frame);
    }
  }

  /// AJO-13 : rogne la photo sur [frame] (en fractions de la photo
  /// d'origine), ou la remet entière si [frame] est null. La photo d'origine
  /// est gardée à part jusqu'à la validation de la fiche.
  Future<void> setFrame(Photo photo, PhotoFrame? frame) async {
    final whole = frame == null || frame.isFull;
    if (whole && photo.cheminOriginal == null) return;
    var original = photo.cheminOriginal;
    if (original == null) {
      original = photo.chemin.replaceFirst(RegExp(r'\.jpg$'), '_origine.jpg');
      await File(await _abs(photo.chemin)).rename(await _abs(original));
      final thumb = File(await _abs(thumbPathFor(photo.chemin)));
      if (thumb.existsSync()) await thumb.delete();
    }
    final bytes = await File(await _abs(original)).readAsBytes();
    final processed = whole
        ? await process(bytes)
        : await Isolate.run(() => cropPhoto(bytes, frame));
    // Nouveau nom à chaque recadrage : l'écran ne garde pas l'ancienne image
    // en cache.
    final relative = p.posix.join(
      p.posix.dirname(photo.chemin),
      '${photo.id}-${_clock().microsecondsSinceEpoch}.jpg',
    );
    await File(await _abs(relative)).writeAsBytes(processed.stored);
    await File(await _abs(thumbPathFor(relative)))
        .writeAsBytes(processed.thumb);
    if (photo.cheminOriginal != null) await _deleteWithThumb(photo.chemin);
    await (_db.update(_db.photos)..where((x) => x.id.equals(photo.id))).write(
      PhotosCompanion(
        chemin: Value(relative),
        cheminOriginal: Value(original),
        cadre: Value(whole ? null : frame.encode()),
        largeur: Value(processed.width),
        hauteur: Value(processed.height),
        octets: Value(processed.stored.length),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  /// AJO-13 : à la validation de la fiche, les photos d'origine des photos
  /// recadrées sont supprimées (décision de Bertrand du 2026-10-26, T87).
  Future<void> dropOriginals(String wineId) async {
    for (final ph in await photosOf(wineId)) {
      final original = ph.cheminOriginal;
      if (original == null) continue;
      final file = File(await _abs(original));
      if (file.existsSync()) await file.delete();
      await (_db.update(_db.photos)..where((x) => x.id.equals(ph.id))).write(
        PhotosCompanion(
          cheminOriginal: const Value(null),
          cadre: const Value(null),
          updatedAt: Value(_clock().toUtc()),
        ),
      );
    }
  }

  /// FIC-11 : suppression d'une photo demandée par l'utilisateur (fichier,
  /// miniature et photo d'origine).
  Future<void> delete(Photo photo) async {
    await _deleteWithThumb(photo.chemin);
    if (photo.cheminOriginal != null) {
      final file = File(await _abs(photo.cheminOriginal!));
      if (file.existsSync()) await file.delete();
    }
    await (_db.update(_db.photos)..where((x) => x.id.equals(photo.id))).write(
      PhotosCompanion(deletedAt: Value(_clock().toUtc())),
    );
  }

  Future<void> _deleteWithThumb(String relative) async {
    for (final path in [relative, thumbPathFor(relative)]) {
      final file = File(await _abs(path));
      if (file.existsSync()) await file.delete();
    }
  }

  /// Suppression en cascade des photos d'une fiche (purge explicite).
  Future<void> deleteAllOf(String wineId) async {
    final dir = Directory(await _abs(p.join('photos', wineId)));
    if (dir.existsSync()) await dir.delete(recursive: true);
    await (_db.update(_db.photos)..where((x) => x.ficheId.equals(wineId)))
        .write(PhotosCompanion(deletedAt: Value(_clock().toUtc())));
  }
}
