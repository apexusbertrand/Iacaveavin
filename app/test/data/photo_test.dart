import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:image/image.dart' as img;

import '../fixture.dart';

/// Étiquette nette : texte simulé par des traits fins contrastés.
Uint8List sharpLabel({int w = 3000, int h = 2000}) {
  final im = img.Image(width: w, height: h);
  img.fill(im, color: img.ColorRgb8(235, 225, 200));
  final r = Random(1);
  for (var i = 0; i < 4000; i++) {
    final x = r.nextInt(w - 40), y = r.nextInt(h - 10);
    img.fillRect(
      im,
      x1: x,
      y1: y,
      x2: x + 30,
      y2: y + 3,
      color: img.ColorRgb8(20, 20, 20),
    );
  }
  return Uint8List.fromList(img.encodeJpg(im, quality: 95));
}

void main() {
  test('AJO-03 compression : 1 600 px stockés, miniature 320 px', () {
    final p = processPhoto(sharpLabel());
    expect(max(p.width, p.height), storedLongSide);
    final thumb = img.decodeJpg(p.thumb)!;
    expect(max(thumb.width, thumb.height), thumbLongSide);
    expect(p.thumb.length, lessThan(p.stored.length));
    final sent = img.decodeJpg(base64Decode(encodeForFlux(p.stored)))!;
    expect(max(sent.width, sent.height), sentLongSide);
  });

  test('AJO-02 photo nette acceptée, photo floue signalée', () {
    final sharp = processPhoto(sharpLabel());
    expect(sharp.quality.blurry, isFalse, reason: '${sharp.quality.sharpness}');
    final blurred = img.gaussianBlur(img.decodeJpg(sharpLabel())!, radius: 40);
    final soft = processPhoto(Uint8List.fromList(img.encodeJpg(blurred)));
    expect(soft.quality.blurry, isTrue, reason: '${soft.quality.sharpness}');
  });

  test('AJO-02 reflet détecté', () {
    final im = img.decodeJpg(sharpLabel())!;
    img.fillCircle(
      im,
      x: 1500,
      y: 1000,
      radius: 450,
      color: img.ColorRgb8(255, 255, 255),
    );
    final shiny = processPhoto(Uint8List.fromList(img.encodeJpg(im)));
    expect(shiny.quality.glare, isTrue, reason: '${shiny.quality.glareRatio}');
    expect(processPhoto(sharpLabel()).quality.glare, isFalse);
  });

  test(
    'NFR-04 photos en répertoire privé, chemin relatif, principale',
    () async {
      final f = Fixture();
      await f.setUp();
      addTearDown(f.db.close);
      final root = Directory.systemTemp.createTempSync('iacav-photos-');
      addTearDown(() => root.deleteSync(recursive: true));
      final service = PhotoService(
        f.db,
        appDir: () async => root,
        clock: () => f.now,
      );
      final p = processPhoto(sharpLabel());
      await service.save(
        wineId: f.wine,
        cellarId: f.cellar,
        photo: p,
        type: 'etiquette',
      );
      await service.save(
        wineId: f.wine,
        cellarId: f.cellar,
        photo: p,
        type: 'contre_etiquette',
      );
      final photos = await service.photosOf(f.wine);
      expect(photos, hasLength(2));
      expect(photos.first.principale, isTrue);
      expect(photos.last.principale, isFalse);
      expect(photos.first.chemin, startsWith('photos/${f.wine}/'));
      expect((await service.thumbOf(photos.first)).existsSync(), isTrue);
      final request = await service.forRequest(f.wine);
      expect(request.map((r) => r.type), ['etiquette', 'contre_etiquette']);
      await service.deleteAllOf(f.wine);
      expect(await service.photosOf(f.wine), isEmpty);
      expect(Directory('${root.path}/photos/${f.wine}').existsSync(), isFalse);
    },
  );

  test('CMP-08 photo de dégustation ramenée à un écran de smartphone', () {
    // 4 000 × 3 000 (paysage) : tient dans 1 920 × 1 080.
    final landscape = processScreenPhoto(sharpLabel(w: 4000, h: 3000));
    expect([landscape.width, landscape.height], [1440, 1080]);
    // 3 000 × 4 000 (portrait) : tient dans 1 080 × 1 920.
    final portrait = processScreenPhoto(sharpLabel(w: 3000, h: 4000));
    expect([portrait.width, portrait.height], [1080, 1440]);
    // Panorama très large : borné par le grand côté.
    final wide = processScreenPhoto(sharpLabel(w: 4000, h: 1000));
    expect([wide.width, wide.height], [1920, 480]);
    // Déjà petite : gardée telle quelle.
    final small = processScreenPhoto(sharpLabel(w: 800, h: 600));
    expect([small.width, small.height], [800, 600]);
    expect(landscape.stored.length, lessThan(600 * 1024));
    expect(img.decodeJpg(landscape.thumb)!.width, thumbLongSide);
  });

  test(
    'CMP-08 photos rattachées à la dégustation et dans la bibliothèque',
    () async {
      final f = Fixture();
      await f.setUp();
      addTearDown(f.db.close);
      final root = Directory.systemTemp.createTempSync('iacav-photos-');
      addTearDown(() => root.deleteSync(recursive: true));
      final service = PhotoService(
        f.db,
        appDir: () async => root,
        clock: () => f.now,
      );
      final tasting = await f.repo.addTasting(
        wineId: f.wine,
        cellarId: f.cellar,
        comment: 'Superbe',
      );
      final other = await f.repo.addTasting(wineId: f.wine, cellarId: f.cellar);
      final p = processScreenPhoto(sharpLabel(w: 1200, h: 900));
      for (var i = 0; i < 2; i++) {
        await service.save(
          wineId: f.wine,
          cellarId: f.cellar,
          photo: p,
          type: 'degustation',
          tastingId: tasting,
        );
      }
      final photos = await service.tastingPhotosOf(tasting);
      expect(photos, hasLength(2));
      expect(photos.every((x) => x.degustationId == tasting), isTrue);
      expect(photos.every((x) => !x.principale), isTrue);
      expect(await service.tastingPhotosOf(other), isEmpty);
      expect(await service.libraryOf(f.wine), hasLength(2));
      expect(
        await service.forRequest(f.wine),
        isEmpty,
        reason: 'jamais au flux',
      );
      await service.delete(photos.first);
      expect(await service.tastingPhotosOf(tasting), hasLength(1));
    },
  );
}
