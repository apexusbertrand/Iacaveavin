import 'wine_detail.dart';

/// PRX-05 : évolution entre les deux derniers relevés trouvés, en fraction
/// (0,1 = +10 %). Null s'il y a moins de deux prix trouvés. Les relevés
/// « non trouvé » ne comptent pas : jamais d'estimation (PRX-04).
double? priceTrend(List<MarketPriceView> history) {
  final found = [
    for (final p in history)
      if (p.found && p.price != null && p.price! > 0) p.price!,
  ];
  if (found.length < 2) return null;
  final prev = found[found.length - 2];
  return (found.last - prev) / prev;
}

/// Points de la courbe : relevés trouvés seulement, du plus ancien au plus
/// récent.
List<double> priceSeries(List<MarketPriceView> history) => [
  for (final p in history)
    if (p.found && p.price != null) p.price!,
];
