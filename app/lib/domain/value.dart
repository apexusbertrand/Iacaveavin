/// Valeur de la cave (docs/04-modele-donnees.md, § Valeur).
library;

class LotValueInput {
  const LotValueInput({
    required this.bottles,
    this.unitPrice,
    this.marketPrice,
  });

  final int bottles;
  final double? unitPrice;

  /// Dernier prix marché trouvé pour le même format (VAL-R2), sinon null.
  final double? marketPrice;
}

class CellarValue {
  const CellarValue({
    required this.purchase,
    required this.bottlesWithoutPrice,
    required this.market,
    required this.bottlesWithoutMarket,
    required this.latentGain,
  });

  /// VAL-R1 : somme quantité × prix d'achat des lots qui ont un prix.
  final double purchase;

  /// Bouteilles sans prix d'achat, comptées à part, jamais à zéro.
  final int bottlesWithoutPrice;
  final double market;
  final int bottlesWithoutMarket;

  /// VAL-R3 : uniquement sur les lots qui ont les deux prix.
  final double latentGain;
}

CellarValue cellarValue(Iterable<LotValueInput> lots) {
  var purchase = 0.0, market = 0.0, gain = 0.0;
  var noPrice = 0, noMarket = 0;
  for (final l in lots) {
    if (l.bottles <= 0) continue;
    if (l.unitPrice == null) {
      noPrice += l.bottles;
    } else {
      purchase += l.bottles * l.unitPrice!;
    }
    if (l.marketPrice == null) {
      noMarket += l.bottles;
    } else {
      market += l.bottles * l.marketPrice!;
    }
    if (l.unitPrice != null && l.marketPrice != null) {
      gain += l.bottles * (l.marketPrice! - l.unitPrice!);
    }
  }
  return CellarValue(
    purchase: purchase,
    bottlesWithoutPrice: noPrice,
    market: market,
    bottlesWithoutMarket: noMarket,
    latentGain: gain,
  );
}
