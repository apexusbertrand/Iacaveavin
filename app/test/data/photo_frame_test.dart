import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/domain/enrichment.dart';
import 'package:iacaveavin/domain/photo_frame.dart';
import 'package:image/image.dart' as img;

import '../fixture.dart';
import 'contract_test.dart' show readExample;
import 'photo_test.dart' show sharpLabel;

void main() {
  test('AJO-13 cadre : bornes et pixels', () {
    const f = PhotoFrame(x: 0.2, y: 0.1, width: 0.6, height: 0.5);
    expect(f.isFull, isFalse);
    expect(PhotoFrame.full.isFull, isTrue);
    // Débordant : ramené dans l'image ; trop petit : 10 % au moins.
    expect(
      const PhotoFrame(x: 0.8, y: 0.9, width: 0.5, height: 0.5).clamped(),
      const PhotoFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5),
    );
    expect(
      const PhotoFrame(x: 0, y: 0, width: 0.01, height: 1).clamped().width,
      minFrameSide,
    );
    final px = f.toPixels(1000, 800);
    expect([px.left, px.top, px.width, px.height], [200, 80, 600, 400]);
    expect(PhotoFrame.decode(f.encode()), f);
    expect(PhotoFrame.decode(null), isNull);
  });

  test('AJO-13 contrat 1.1 : cadrages lus dans la réponse', () async {
    Future<Map<String, dynamic>> example() async =>
        jsonDecode(await readExample('enrichissement-termine.json'))
            as Map<String, dynamic>;
    expect(contractVersion, '1.2');
    final r = JobResponse.fromJson(await example());
    final frames = r.result!.frames;
    expect(frames, hasLength(2));
    expect(frames[0].index, 0);
    expect(
      frames[0].frame,
      const PhotoFrame(x: 0.18, y: 0.22, width: 0.64, height: 0.5),
    );
    expect(frames[1].frame, isNull, reason: 'aucune étiquette identifiable');
    final j = await example();
    j['version_contrat'] = '1.0';
    (j['resultat'] as Map).remove('cadrages');
    final ancien = JobResponse.fromJson(j);
    expect(ancien.result!.frames, isEmpty, reason: 'réponse 1.0 sans cadre');
  });

  group('service photo', () {
    late Fixture f;
    late Directory root;
    late PhotoService service;
    final now = DateTime.utc(2026, 10, 26, 9);

    setUp(() async {
      f = Fixture();
      await f.setUp();
      root = Directory.systemTemp.createTempSync('iacav-cadre-');
      service = PhotoService(f.db, appDir: () async => root, clock: () => now);
    });
    tearDown(() async {
      await f.db.close();
      root.deleteSync(recursive: true);
    });

    Future<void> label([String type = 'etiquette']) => service.save(
      wineId: f.wine,
      cellarId: f.cellar,
      photo: processPhoto(sharpLabel(w: 1200, h: 800)),
      type: type,
    );

    test('AJO-13 rognage : origine gardée, retour à la photo entière, purge à la validation', () async {
      await label();
      var ph = (await service.photosOf(f.wine)).single;
      final avant = ph.chemin;
      await service.setFrame(
        ph,
        const PhotoFrame(x: 0.25, y: 0.25, width: 0.5, height: 0.5),
      );
      ph = (await service.photosOf(f.wine)).single;
      expect((ph.largeur, ph.hauteur), (600, 400));
      expect(ph.chemin, isNot(avant), reason: 'nouveau fichier, pas de cache');
      expect(File('${root.path}/$avant').existsSync(), isFalse);
      expect(ph.cheminOriginal, isNotNull);
      final origine = File('${root.path}/${ph.cheminOriginal}');
      expect(img.decodeJpg(origine.readAsBytesSync())!.width, 1200);
      final rognee = img.decodeJpg(
        (await service.fileOf(ph)).readAsBytesSync(),
      );
      expect(rognee!.width, 600);
      expect((await service.thumbOf(ph)).existsSync(), isTrue);
      expect(PhotoFrame.decode(ph.cadre)!.width, 0.5);

      // Retour à la photo entière : l'origine reste jusqu'à la validation.
      await service.setFrame(ph, null);
      ph = (await service.photosOf(f.wine)).single;
      expect((ph.largeur, ph.hauteur), (1200, 800));
      expect(ph.cadre, isNull);
      expect(origine.existsSync(), isTrue);

      await service.setFrame(
        ph,
        const PhotoFrame(x: 0, y: 0, width: 0.5, height: 1),
      );
      await service.dropOriginals(f.wine);
      ph = (await service.photosOf(f.wine)).single;
      expect(origine.existsSync(), isFalse, reason: 'supprimée (T87)');
      expect(ph.cheminOriginal, isNull);
      expect(ph.cadre, isNull);
      expect((ph.largeur, ph.hauteur), (600, 800), reason: 'rognage gardé');
    });

    test('AJO-13 cadres du flux : photo entière sans étiquette, pas de second rognage', () async {
      await label();
      await label('contre_etiquette');
      await service.applyFrames(f.wine, const [
        LabelFrame(
          index: 0,
          frame: PhotoFrame(x: 0.5, y: 0, width: 0.5, height: 1),
        ),
        LabelFrame(index: 1),
        LabelFrame(
          index: 3,
          frame: PhotoFrame(x: 0, y: 0, width: 1, height: 1),
        ),
      ]);
      var photos = await service.photosOf(f.wine);
      expect((photos[0].largeur, photos[0].hauteur), (600, 800));
      expect(photos[1].cheminOriginal, isNull, reason: 'cadre null');
      expect((photos[1].largeur, photos[1].hauteur), (1200, 800));

      // Même réponse relue (reprise après arrêt) : pas de second rognage.
      await service.applyFrames(f.wine, const [
        LabelFrame(
          index: 0,
          frame: PhotoFrame(x: 0.5, y: 0, width: 0.5, height: 1),
        ),
      ]);
      photos = await service.photosOf(f.wine);
      expect((photos[0].largeur, photos[0].hauteur), (600, 800));
    });

    test('FIC-11 bibliothèque : ni envoyée au flux, ni photo principale, supprimable', () async {
      await label('degustation');
      await label();
      await label('repas');
      final all = await service.photosOf(f.wine);
      expect(all.where((p) => p.principale).single.typePhoto, 'etiquette');
      expect(await service.libraryOf(f.wine), hasLength(2));
      final sent = await service.forRequest(f.wine);
      expect(sent, hasLength(1));
      expect(sent.single.type, 'etiquette');
      final repas = (await service.libraryOf(f.wine)).last;
      final file = await service.fileOf(repas);
      await service.delete(repas);
      expect(file.existsSync(), isFalse);
      expect(await service.libraryOf(f.wine), hasLength(1));
      expect(isLibraryPhoto('degustation'), isTrue);
      expect(isLibraryPhoto('etiquette'), isFalse);
    });
  });
}
