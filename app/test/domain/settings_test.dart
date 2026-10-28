import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/app_settings.dart';
import 'package:iacaveavin/domain/garde.dart';
import 'package:iacaveavin/domain/wine_query.dart';

void main() {
  test('LST-09 tri, filtres et vue mémorisés : aller-retour JSON', () {
    const s = AppSettings(
      themeMode: AppThemeMode.dark,
      personalScale: 100,
      cardPrice: CardPrice.market,
      compactView: true,
      listQuery: WineQuery(
        sort1: SortSpec(SortCriterion.parkerScore, ascending: false),
        sort2: null,
        filters: WineFilters(
          stock: StockFilter.all,
          colors: {'rouge', 'blanc'},
          vintageMin: 2010,
          location: 'cave',
          statuses: {CellarStatus.drinkSoon},
          minScore: 90,
          favoritesOnly: true,
        ),
      ),
    );
    final back = AppSettings.fromJson(s.toJson());
    expect(back.themeMode, AppThemeMode.dark);
    expect(back.personalScale, 100);
    expect(back.cardPrice, CardPrice.market);
    expect(back.compactView, isTrue);
    expect(back.listQuery.sort1, s.listQuery.sort1);
    expect(back.listQuery.sort2, isNull);
    final f = back.listQuery.filters;
    expect(f.stock, StockFilter.all);
    expect(f.colors, {'rouge', 'blanc'});
    expect(f.vintageMin, 2010);
    expect(f.location, 'cave');
    expect(f.statuses, {CellarStatus.drinkSoon});
    expect(f.minScore, 90);
    expect(f.favoritesOnly, isTrue);
  });

  test('PAR-05 valeurs par défaut et réglages corrompus ignorés', () {
    final d = AppSettings.fromJson(const {'themeMode': 'violet'});
    expect(d.currency, 'EUR');
    expect(d.themeMode, AppThemeMode.system);
    expect(d.personalScale, 20);
    expect(d.autoPriceRefresh, isFalse);
  });
}
