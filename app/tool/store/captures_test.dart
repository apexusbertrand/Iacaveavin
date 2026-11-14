// Captures d'écran de la fiche Google Play (docs/09, T124), faites sur les
// vrais écrans avec le jeu de démonstration (domaines inventés).
//   flutter test --update-goldens tool/store/captures_test.dart
// Sortie : store/captures/ (français) et store/captures-en/ (anglais,
// LNG-05) à la racine du dépôt, 1080 × 1920 px.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iacaveavin/data/demo/drift_demo_repository.dart';

import '../../test/fakes.dart';

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(File(f).readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    final polices = '$sdk/bin/cache/artifacts/material_fonts';
    await _font('Roboto', [
      'assets/fonts/Roboto-Regular.ttf',
      'assets/fonts/Roboto-Bold.ttf',
      '$polices/Roboto-Medium.ttf',
      '$polices/Roboto-Light.ttf',
    ]);
    await _font('MaterialIcons', ['$polices/MaterialIcons-Regular.otf']);
    await _font('Noto Color Emoji', [
      '$sdk/engine/src/flutter/txt/third_party/fonts/NotoColorEmoji.ttf',
    ]);
    // Pas de cadre de focus clavier : rendu tactile, comme sur le téléphone.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
  });

  Future<String> demo(
    WidgetTester tester,
    String location,
    Locale device,
  ) async {
    // Vraies ombres : le moteur de test les remplace par un trait noir.
    // Remis à vrai après la capture (contrôle de fin de test).
    debugDisableShadows = false;
    late String vin;
    await pumpRealApp(
      tester,
      location: location,
      device: device,
      prefs: {'reglages_v1': '{"photoConsent":true}'},
      seed: (db, cellar) async {
        await DriftDemoRepository(db).load();
        final w = await db
            .customSelect(
              "SELECT f.id FROM fiche_vin f WHERE f.garde_debut IS NOT NULL "
              "AND f.cepages IS NOT NULL ORDER BY f.id LIMIT 1",
            )
            .getSingle();
        vin = w.read<String>('id');
      },
    );
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    await settle(tester);
    return vin;
  }

  Future<void> capture(WidgetTester tester, String sortie, String nom) async {
    await settle(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../store/$sortie/$nom.png'),
    );
    debugDisableShadows = true;
  }

  for (final (device, sortie, garde) in [
    (const Locale('fr'), 'captures', 'Garde'),
    (const Locale('en'), 'captures-en', 'Ageing'),
  ]) {
    final lang = device.languageCode;

    testWidgets('captures store $lang : liste', (tester) async {
      await demo(tester, '/', device);
      await capture(tester, sortie, '01-mes-vins');
    });

    testWidgets('captures store $lang : fiche', (tester) async {
      final vin = await demo(tester, '/', device);
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push('/fiche/$vin');
      await capture(tester, sortie, '02-fiche-vin');
    });

    testWidgets('captures store $lang : à boire', (tester) async {
      await demo(tester, '/a-boire', device);
      await capture(tester, sortie, '03-a-boire');
    });

    testWidgets('captures store $lang : statistiques', (tester) async {
      await demo(tester, '/statistiques', device);
      await capture(tester, sortie, '04-statistiques');
    });

    // Onglet Régions écarté : libellés de l'axe coupés à cette largeur.
    testWidgets('captures store $lang : statistiques Garde', (tester) async {
      await demo(tester, '/statistiques', device);
      await tester.tap(find.text(garde));
      await settle(tester);
      await capture(tester, sortie, '05-statistiques-garde');
    });
  }
}
