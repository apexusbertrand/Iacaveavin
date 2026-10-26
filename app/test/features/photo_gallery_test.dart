import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iacaveavin/data/cellar_repository.dart';
import 'package:iacaveavin/data/files/photo_service.dart';
import 'package:iacaveavin/domain/wine_detail.dart';
import 'package:iacaveavin/features/add/capture_screen.dart';

import '../data/photo_test.dart' show sharpLabel;
import '../fakes.dart';

void main() {
  late Directory root;
  late Uint8List label;

  setUpAll(() => label = sharpLabel(w: 1200, h: 800));
  setUp(() => root = Directory.systemTemp.createTempSync('iacav-galerie-'));
  tearDown(() => root.deleteSync(recursive: true));

  testWidgets(
    'FIC-10 FIC-11 toutes les photos visibles, bibliothèque de la bouteille',
    (tester) async {
      late String wine;
      final db = await pumpRealApp(
        tester,
        appDir: root,
        extra: [
          imagePickerProvider.overrideWithValue(
            ({required bool camera}) async => label,
          ),
        ],
        seed: (db, cellar) async {
          wine = await CellarRepository(db).createWine(
            const WineDraft(
              producer: 'Château Bralmac',
              country: 'FR',
              color: 'rouge',
              vintage: '2015',
            ),
            cellarId: cellar,
          );
          final photos = PhotoService(db, appDir: () async => root);
          for (final type in ['etiquette', 'contre_etiquette']) {
            await photos.save(
              wineId: wine,
              cellarId: cellar,
              photo: processPhoto(label),
              type: type,
            );
          }
        },
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push('/fiche/$wine');
      await pumpUntil(
        tester,
        () =>
            find.byKey(const ValueKey('photo-carousel')).evaluate().isNotEmpty,
      );

      // FIC-10 : carrousel avec ses points, plein écran sur chaque photo.
      expect(find.byKey(const ValueKey('carousel-dots')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('photo-carousel')));
      await settle(tester);
      expect(find.text('1 / 2 · Étiquette'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('gallery-pages')),
        const Offset(-800, 0),
      );
      await settle(tester);
      expect(find.text('2 / 2 · Contre-étiquette'), findsOneWidget);
      await tester.tap(find.byTooltip('Fermer'));
      await settle(tester);

      // FIC-11 : bibliothèque vide, ajout d'une photo de repas.
      await tester.ensureVisible(find.text('Photos'));
      await settle(tester);
      await tester.tap(find.text('Photos'));
      await settle(tester);
      expect(
        find.text(
          'Aucune photo de dégustation ou de repas pour cette bouteille.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('library-add')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('library-type-repas')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('library-camera')));
      final added = find.byKey(const ValueKey('library-photo-0'));
      await pumpUntil(tester, () => added.evaluate().isNotEmpty);
      expect(added, findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      final rows = await tester.runAsync(() => db.select(db.photos).get());
      final repas = rows!.singleWhere((p) => p.typePhoto == 'repas');
      expect(repas.principale, isFalse);

      // Suppression demandée depuis le plein écran.
      await tester.tap(added);
      await settle(tester);
      expect(find.text('Repas'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('gallery-delete')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('confirm')));
      await pumpUntil(tester, () => added.evaluate().isEmpty);
      expect(added, findsNothing);
      final after = await tester.runAsync(() => db.select(db.photos).get());
      expect(
        after!.singleWhere((p) => p.typePhoto == 'repas').deletedAt,
        isNotNull,
      );
    },
  );
}
