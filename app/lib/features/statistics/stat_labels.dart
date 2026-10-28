import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/reference_repository.dart';
import '../../domain/garde.dart';
import '../../domain/stats.dart';

/// STA-06 : libellés en clair des mesures, dimensions et valeurs ; aucune
/// clé technique à l'écran.
class StatLabels {
  StatLabels({
    required this.l,
    required this.labels,
    required this.owners,
    required this.locations,
    required this.locale,
    required this.currency,
  }) : _money = NumberFormat.simpleCurrency(locale: locale, name: currency),
       _number = NumberFormat.decimalPattern(locale),
       _month = DateFormat.yMMM(locale);

  final AppLocalizations l;

  /// Libellés des listes (`liste:code`).
  final Map<String, String> labels;
  final Map<String, String> owners;
  final Map<String, String> locations;
  final String locale;
  final String currency;
  final NumberFormat _money;
  final NumberFormat _number;
  final DateFormat _month;

  factory StatLabels.of(
    BuildContext context, {
    required Map<String, String> labels,
    required List<OwnerView> owners,
    required List<LocationView> locations,
    required String currency,
  }) {
    final byId = {for (final x in locations) x.id: x};
    String path(LocationView x) {
      final names = <String>[];
      LocationView? cur = x;
      var guard = 0;
      while (cur != null && guard++ < 8) {
        names.add(cur.name);
        cur = cur.parentId == null ? null : byId[cur.parentId];
      }
      return names.reversed.join(' > ');
    }

    return StatLabels(
      l: AppLocalizations.of(context),
      labels: labels,
      owners: {for (final o in owners) o.id: o.name},
      locations: {for (final x in locations) x.id: path(x)},
      locale: Localizations.localeOf(context).toLanguageTag(),
      currency: currency,
    );
  }

  String measure(StatMeasure m) => switch (m) {
    StatMeasure.bottles => l.statMeasureBottles,
    StatMeasure.references => l.statMeasureReferences,
    StatMeasure.purchaseValue => l.statMeasurePurchase,
    StatMeasure.marketValue => l.statMeasureMarket,
    StatMeasure.gain => l.statMeasureGain,
    StatMeasure.averagePrice => l.statMeasureAvgPrice,
    StatMeasure.averageScore => l.statMeasureAvgScore,
    StatMeasure.opened => l.statMeasureOpened,
    StatMeasure.yearsBefore => l.statMeasureYears,
  };

  String dimension(StatDimension d) => switch (d) {
    StatDimension.color => l.statDimColor,
    StatDimension.type => l.statDimType,
    StatDimension.country => l.statDimCountry,
    StatDimension.region => l.statDimRegion,
    StatDimension.subRegion => l.statDimSubRegion,
    StatDimension.appellation => l.statDimAppellation,
    StatDimension.producer => l.statDimProducer,
    StatDimension.vintage => l.statDimVintage,
    StatDimension.vintageBand => l.statDimVintageBand,
    StatDimension.mainGrape => l.statDimGrape,
    StatDimension.owner => l.statDimOwner,
    StatDimension.location => l.statDimLocation,
    StatDimension.gardeStatus => l.statDimGardeStatus,
    StatDimension.gardeStart => l.statDimGardeStart,
    StatDimension.peakYear => l.statDimPeak,
    StatDimension.scoreBand => l.statDimScoreBand,
    StatDimension.priceBand => l.statDimPriceBand,
    StatDimension.supplier => l.statDimSupplier,
    StatDimension.purchaseMonth => l.statDimPurchaseMonth,
    StatDimension.openingMonth => l.statDimOpeningMonth,
  };

  String chart(StatChart c) => switch (c) {
    StatChart.donut => l.statChartDonut,
    StatChart.barsVertical => l.statChartBarsV,
    StatChart.barsHorizontal => l.statChartBarsH,
    StatChart.stacked => l.statChartStacked,
    StatChart.line => l.statChartLine,
    StatChart.crossTable => l.statChartCross,
    StatChart.kpi => l.statChartKpi,
  };

  String _list(String list, String code) => labels['$list:$code'] ?? code;

  /// Libellé d'une valeur de dimension.
  String key(StatDimension d, String k) {
    if (k == otherKey) return l.statOther;
    if (k == noneKey) return l.statNone;
    return switch (d) {
      StatDimension.color => _list('couleur', k),
      StatDimension.type => _list('type_vin', k),
      StatDimension.country => _list('pays', k),
      StatDimension.region => _list('region', k),
      StatDimension.subRegion => _list('sous_region', k),
      StatDimension.appellation => _list('appellation', k),
      StatDimension.mainGrape => _list('cepage', k),
      StatDimension.supplier => _list('fournisseur', k),
      StatDimension.owner => owners[k] ?? k,
      StatDimension.location => locations[k] ?? k,
      StatDimension.vintage => k == 'NM' ? l.nonVintage : k,
      StatDimension.vintageBand => l.statBand(k, '${int.parse(k) + 4}'),
      StatDimension.scoreBand => l.statBand(k, '${int.parse(k) + 4}'),
      StatDimension.priceBand => () {
        final from = int.parse(k);
        final i = priceBands.indexOf(from);
        return i + 1 < priceBands.length
            ? l.statBand(_money.format(from), _money.format(priceBands[i + 1]))
            : l.statFrom(_money.format(from));
      }(),
      StatDimension.gardeStatus => l.statusLabel(
        CellarStatus.values.firstWhere(
          (s) => s.code == k,
          orElse: () => CellarStatus.unknown,
        ),
      ),
      StatDimension.purchaseMonth ||
      StatDimension.openingMonth => _month.format(
        DateTime(int.parse(k.substring(0, 4)), int.parse(k.substring(5, 7))),
      ),
      _ => k,
    };
  }

  /// Valeur d'une mesure, avec son unité.
  String value(StatMeasure m, double v) {
    if (m.money) return _money.format(v);
    if (m == StatMeasure.averageScore || m == StatMeasure.yearsBefore) {
      return NumberFormat('0.0', locale).format(v);
    }
    return _number.format(v.round());
  }

  /// Valeur sans unité, pour un tableau CSV.
  String raw(StatMeasure m, double v) => m.money || m.average
      ? v.toStringAsFixed(2).replaceAll('.', ',')
      : '${v.round()}';
}

/// Couleur d'une série : couleur du vin, statut de garde, sinon une palette
/// prise dans les jetons du thème.
Color seriesColor(BuildContext context, StatDimension? d, String key, int i) {
  if (d == StatDimension.color && key != otherKey) return wineColor(key).fill;
  if (d == StatDimension.gardeStatus) {
    return switch (key) {
      'trop_jeune' => CellarStatusTokens.trop_jeune,
      'a_boire' => CellarStatusTokens.a_boire,
      'apogee' => CellarStatusTokens.apogee,
      'a_boire_vite' => CellarStatusTokens.a_boire_vite,
      'passe' => CellarStatusTokens.passe,
      _ => CellarStatusTokens.inconnu,
    };
  }
  final scheme = Theme.of(context).colorScheme;
  final palette = [
    scheme.primary,
    scheme.secondary,
    BrandTokens.rougeOrange,
    WineColorTokens.rouge,
    WineColorTokens.champagne,
    WineColorTokens.rose,
    WineColorTokens.liquoreux,
    context.palette.textSecondary,
  ];
  return palette[i % palette.length];
}
