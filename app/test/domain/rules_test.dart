import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/garde.dart';
import 'package:iacaveavin/domain/scores.dart';
import 'package:iacaveavin/domain/stock_rules.dart';
import 'package:iacaveavin/domain/value.dart';

void main() {
  group('garde (docs/04, cas obligatoires)', () {
    const cas = [
      (2025, 2026, 2029, 2032, CellarStatus.tooYoung),
      (2026, 2026, 2029, 2032, CellarStatus.toDrink),
      (2027, 2026, 2029, 2032, CellarStatus.toDrink),
      (2028, 2026, 2029, 2032, CellarStatus.peak),
      (2030, 2026, 2029, 2032, CellarStatus.peak),
      (2031, 2026, 2029, 2032, CellarStatus.drinkSoon),
      (2032, 2026, 2029, 2032, CellarStatus.drinkSoon),
      (2033, 2026, 2029, 2032, CellarStatus.past),
      (2029, 2026, null, 2032, CellarStatus.toDrink),
      (2025, 2026, 2026, 2026, CellarStatus.tooYoung),
      (2026, 2026, 2026, 2026, CellarStatus.drinkSoon),
      (2027, 2026, 2026, 2026, CellarStatus.past),
      (2026, null, null, 2032, CellarStatus.unknown),
    ];
    for (final (annee, debut, apogee, fin, attendu) in cas) {
      test('garde $annee ($debut, $apogee, $fin) donne ${attendu.code}', () {
        expect(
          cellarStatus(year: annee, start: debut, peak: apogee, end: fin),
          attendu,
        );
      });
    }
    test('années avant de boire et année idéale', () {
      expect(yearsBeforeDrinking(year: 2024, start: 2026), 2);
      expect(yearsBeforeDrinking(year: 2030, start: 2026), 0);
      expect(idealYear(start: 2026, peak: 2029, end: 2032), 2029);
      expect(idealYear(start: 2026, end: 2031), 2028);
      expect(idealYear(start: 2026), isNull);
    });
  });

  group('notes', () {
    const p2019 = CriticScoreValue(
      critic: parkerCritic,
      score: 94,
      scale: 100,
      date: '2019-05-01',
    );
    const p2022 = CriticScoreValue(
      critic: parkerCritic,
      score: 92,
      scale: 100,
      date: '2022-03-10',
    );
    const rvf = CriticScoreValue(
      critic: 'La Revue du vin de France',
      score: 19,
      scale: 20,
    );
    test('NOT-R1 la note Parker est la plus récente', () {
      expect(parkerScore([p2019, p2022, rvf])!.score, 92);
      expect(parkerScore([rvf]), isNull);
    });
    test('NOT-R2 meilleure note ramenée sur 100, /20 multipliée par 5', () {
      expect(bestScoreOn100([p2019, rvf]), 95);
      expect(rvf.score, 19, reason: 'jamais convertie pour l\'affichage');
    });
  });

  group('stock', () {
    test('STK-R1 un mouvement de 0 bouteille est refusé', () {
      expect(
        () => checkMovement(
          currentStock: 3,
          type: MovementType.entry,
          quantity: 0,
        ),
        throwsA(isA<StockRuleException>()),
      );
    });
    test('STK-R2 un mouvement qui rendrait le stock négatif est refusé', () {
      expect(
        () => checkMovement(
          currentStock: 1,
          type: MovementType.opening,
          quantity: -2,
        ),
        throwsA(
          isA<StockRuleException>().having((e) => e.code, 'code', 'negative'),
        ),
      );
      checkMovement(currentStock: 2, type: MovementType.opening, quantity: -2);
    });
    test('STK-03 ajustement : motif obligatoire et écart calculé', () {
      expect(
        () => checkMovement(
          currentStock: 5,
          type: MovementType.adjustment,
          quantity: -1,
        ),
        throwsA(
          isA<StockRuleException>().having(
            (e) => e.code,
            'code',
            'reason_required',
          ),
        ),
      );
      expect(adjustmentDelta(currentStock: 5, actual: 3), -2);
      expect(adjustmentDelta(currentStock: 5, actual: 5), isNull);
      expect(adjustmentDelta(currentStock: 0, actual: 4), 4);
    });
    test('STK-R1 signe de la quantité selon le type', () {
      expect(signedQuantity(MovementType.entry, 3), 3);
      expect(signedQuantity(MovementType.opening, 1), -1);
      expect(signedQuantity(MovementType.transferOut, 2), -2);
      expect(signedQuantity(MovementType.transferIn, 2), 2);
      expect(MovementType.fromCode('sortie_autre'), MovementType.otherExit);
    });
  });

  group('valeur', () {
    test('VAL-R1 lots sans prix comptés à part, jamais à zéro', () {
      final v = cellarValue(const [
        LotValueInput(bottles: 6, unitPrice: 20),
        LotValueInput(bottles: 2),
        LotValueInput(bottles: 0, unitPrice: 100),
      ]);
      expect(v.purchase, 120);
      expect(v.bottlesWithoutPrice, 2);
    });
    test('VAL-R2 VAL-R3 valeur marché et plus-value sur les lots complets', () {
      final v = cellarValue(const [
        LotValueInput(bottles: 6, unitPrice: 20, marketPrice: 30),
        LotValueInput(bottles: 2, marketPrice: 50),
        LotValueInput(bottles: 1, unitPrice: 10),
      ]);
      expect(v.market, 280);
      expect(v.bottlesWithoutMarket, 1);
      expect(v.latentGain, 60);
    });
  });
}
