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
      await tester.ensureVisible(find.text('Dégustations et photos'));
      await settle(tester);
      await tester.tap(find.text('Dégustations et photos'));
      await settle(tester);
      expect(
        find.text(
          'Aucune autre photo pour cette bouteille (repas, événement).',
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

      // Suppression demandée depuis le plein écran (photo remontée au-dessus
      // du message de confirmation d'ajout).
      await tester.drag(
        find.byKey(const ValueKey('tastings-photos')),
        const Offset(0, -400),
      );
      await settle(tester);
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

  testWidgets(
    'CMP-05 CMP-08 FIC-11 dégustations et photos dans un seul onglet',
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
        },
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push('/fiche/$wine');
      await settle(tester);
      await tester.ensureVisible(find.text('Dégustations et photos'));
      await settle(tester);
      await tester.tap(find.text('Dégustations et photos'));
      await settle(tester);
      expect(find.text('Aucune dégustation notée.'), findsOneWidget);
      expect(find.text('Autres photos'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tasting-add')));
      await settle(tester);
      expect(find.text('Photos de la dégustation'), findsOneWidget);
      for (final source in ['tasting-photo-camera', 'tasting-photo-gallery']) {
        await tester.tap(find.byKey(ValueKey(source)));
        await pumpUntil(
          tester,
          () =>
              find
                  .byKey(const ValueKey('tasting-photo-camera'))
                  .hitTestable()
                  .evaluate()
                  .isNotEmpty &&
              tester
                      .widget<TextButton>(
                        find.byKey(const ValueKey('tasting-photo-camera')),
                      )
                      .onPressed !=
                  null,
        );
      }
      expect(find.byKey(const ValueKey('tasting-new-photo-1')), findsOneWidget);
      // Une photo retirée avant l'enregistrement n'est pas gardée.
      await tester.tap(find.byKey(const ValueKey('tasting-photo-remove-1')));
      await settle(tester);
      expect(find.byKey(const ValueKey('tasting-new-photo-1')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('tasting-save')));
      await pumpUntil(
        tester,
        () => find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith(
                    'tasting-photos-',
                  ),
            )
            .evaluate()
            .isNotEmpty,
      );
      final tasting = await tester.runAsync(
        () => db.select(db.tastings).getSingle(),
      );
      final photos = await tester.runAsync(() => db.select(db.photos).get());
      expect(photos, hasLength(1));
      expect(photos!.single.degustationId, tasting!.id);
      expect(photos.single.typePhoto, 'degustation');
      expect(photos.single.largeur, 1200, reason: 'déjà sous la taille écran');
      final strip = find.byKey(ValueKey('tasting-photos-${tasting.id}'));
      expect(strip, findsOneWidget);
      // La photo de la dégustation n'apparaît pas une 2e fois en dessous.
      expect(find.byKey(const ValueKey('library-photo-0')), findsNothing);

      // Supprimée depuis le plein écran ouvert sous la dégustation.
      await tester.tap(
        find.descendant(of: strip, matching: find.byType(InkWell)).first,
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('gallery-delete')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('confirm')));
      await pumpUntil(tester, () => strip.evaluate().isEmpty);
      expect(strip, findsNothing);
      final after = await tester.runAsync(() => db.select(db.photos).get());
      expect(after!.single.deletedAt, isNotNull);
    },
  );
}
