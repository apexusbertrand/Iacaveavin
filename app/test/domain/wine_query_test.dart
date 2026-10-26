import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/garde.dart';
import 'package:iacaveavin/domain/wine_list_item.dart';
import 'package:iacaveavin/domain/wine_query.dart';

WineListItem w(
  String id, {
  String vintage = '2015',
  String color = 'rouge',
  double? parker,
  double? best,
  int bottles = 1,
  String producer = 'Domaine',
  List<OwnerShare> owners = const [],
  Set<String> locations = const {},
  String? region,
  int? start,
  int? peak,
  int? end,
  double? price,
  String search = '',
  List<String> grapes = const [],
  bool favorite = false,
  bool neverStocked = false,
}) => WineListItem(
  id: id,
  producer: producer,
  vintage: vintage,
  colorCode: color,
  countryCode: 'FR',
  bottles: bottles,
  parkerScore: parker,
  bestScore100: best,
  owners: owners,
  locationIds: locations,
  region: region,
  regionCode: region,
  gardeStart: start,
  gardePeak: peak,
  gardeEnd: end,
  purchasePrice: price,
  searchText: search,
  grapes: grapes,
  favorite: favorite,
  neverStocked: neverStocked,
);

List<String> ids(List<WineListItem> l) => l.map((e) => e.id).toList();

void main() {
  const all = WineFilters(stock: StockFilter.all);

  test('LST-01 tri à deux niveaux, chacun dans son sens', () {
    final items = [
      w('a', vintage: '2015', producer: 'B'),
      w('b', vintage: '2018', producer: 'A'),
      w('c', vintage: '2015', producer: 'A'),
    ];
    final q = const WineQuery(
      sort1: SortSpec(SortCriterion.vintage),
      sort2: SortSpec(SortCriterion.producer, ascending: false),
      filters: all,
    );
    expect(ids(q.apply(items, year: 2026)), ['a', 'c', 'b']);
    final desc = q.copyWith(sort1: q.sort1.toggled());
    expect(ids(desc.apply(items, year: 2026)), ['b', 'a', 'c']);
  });

  test('LST-02 tri par couleur dans l\'ordre du dictionnaire', () {
    final items = [
      for (final c in [
        'autre',
        'blanc',
        'orange',
        'rouge',
        'champagne',
        'rose',
      ])
        w(c, color: c),
    ];
    const q = WineQuery(sort1: SortSpec(SortCriterion.color), filters: all);
    expect(ids(q.apply(items, year: 2026)), [
      'rouge',
      'blanc',
      'rose',
      'champagne',
      'orange',
      'autre',
    ]);
  });

  test(
    'LST-04 tri Parker : vins sans note en fin de liste, dans les deux sens',
    () {
      final items = [w('sans'), w('p90', parker: 90), w('p96', parker: 96)];
      const asc = WineQuery(
        sort1: SortSpec(SortCriterion.parkerScore),
        filters: all,
      );
      expect(ids(asc.apply(items, year: 2026)), ['p90', 'p96', 'sans']);
      final desc = asc.copyWith(sort1: asc.sort1.toggled());
      expect(ids(desc.apply(items, year: 2026)), ['p96', 'p90', 'sans']);
    },
  );

  test('LST-01 tri par statut de garde, inconnu en fin', () {
    final items = [
      w('inconnu'),
      w('passe', start: 2010, end: 2015),
      w('jeune', start: 2030, end: 2040),
    ];
    const q = WineQuery(
      sort1: SortSpec(SortCriterion.cellarStatus),
      filters: all,
    );
    expect(ids(q.apply(items, year: 2026)), ['jeune', 'passe', 'inconnu']);
  });

  test('LST-03 groupes consécutifs avec nombre de vins et de bouteilles', () {
    final items = [
      w('a', vintage: '2018', bottles: 3),
      w('b', vintage: '2015', bottles: 2),
      w('c', vintage: '2018', bottles: 1),
    ];
    const q = WineQuery(filters: all);
    final groups = groupWines(
      q.apply(items, year: 2026),
      SortCriterion.vintage,
    );
    expect(groups.map((g) => g.label), ['2018', '2015']);
    expect(groups.first.items, hasLength(2));
    expect(groups.first.bottles, 4);
    expect(SortCriterion.vintage.groupable, isTrue);
    expect(SortCriterion.parkerScore.groupable, isFalse);
  });

  group('LST-05 filtres combinables', () {
    final owner = [const OwnerShare(ownerId: 'o1', name: 'Alex', bottles: 2)];
    final items = [
      w('vide', bottles: 0),
      w('blanc', color: 'blanc', price: 12),
      w('alex', owners: owner, locations: {'cave', 'casier'}, price: 40),
      w('note', best: 93, grapes: ['merlot'], favorite: true),
      w('vieux', vintage: '2006', start: 2008, peak: 2012, end: 2016),
    ];
    List<String> run(WineFilters f) =>
        ids(WineQuery(filters: f).apply(items, year: 2026))..sort();

    test('LST-05 stock : en stock par défaut, épuisé, tous', () {
      expect(run(const WineFilters()), isNot(contains('vide')));
      expect(run(const WineFilters(stock: StockFilter.empty)), ['vide']);
      expect(run(all), hasLength(5));
    });
    test(
      'STK-06 fiche identifiée sans bouteille : visible en stock, pas épuisée',
      () {
        final l = [...items, w('nouveau', bottles: 0, neverStocked: true)];
        List<String> r(WineFilters f) =>
            ids(WineQuery(filters: f).apply(l, year: 2026));
        expect(r(const WineFilters()), contains('nouveau'));
        expect(r(const WineFilters(stock: StockFilter.empty)), ['vide']);
      },
    );
    test('LST-05 couleur, propriétaire, emplacement avec ses parents', () {
      expect(run(const WineFilters(colors: {'blanc'})), ['blanc']);
      expect(run(const WineFilters(owners: {'o1'})), ['alex']);
      expect(run(const WineFilters(location: 'cave')), ['alex']);
    });
    test('LST-05 millésimes, statut de garde, note, prix, cépage, favoris', () {
      expect(run(const WineFilters(vintageMax: 2010)), ['vieux']);
      expect(run(const WineFilters(statuses: {CellarStatus.past})), ['vieux']);
      expect(run(const WineFilters(idealYearMax: 2013)), ['vieux']);
      expect(run(const WineFilters(minScore: 90)), ['note']);
      expect(run(const WineFilters(priceMin: 20, priceMax: 50)), ['alex']);
      expect(run(const WineFilters(grapes: {'merlot'})), ['note']);
      expect(run(const WineFilters(favoritesOnly: true)), ['note']);
    });
    test('LST-05 filtres cumulés et compteur de filtres actifs', () {
      const f = WineFilters(colors: {'rouge'}, minScore: 90);
      expect(run(f), ['note']);
      expect(f.activeCount, 2);
      expect(const WineFilters().activeCount, 0);
    });
  });

  test('LST-06 recherche insensible aux accents et à la casse', () {
    final items = [
      w('a', search: buildSearchText(['Château Brémiac', 'Saint-Émilion'])),
      w(
        'b',
        search: buildSearchText(['Clos Lune', 'Pomerol', 'Cabernet franc']),
      ),
    ];
    List<String> find(String s) =>
        ids(WineQuery(filters: all, search: s).apply(items, year: 2026));
    expect(find('saint emilion'), ['a']);
    expect(find('BREMIAC'), ['a']);
    expect(find('cabernet pomerol'), ['b']);
    expect(find('chateau lune'), isEmpty);
    expect(normalizeSearch("L'Étoile  Œil"), 'l etoile oeil');
  });

  test('LST-09 tri sérialisable pour être mémorisé', () {
    const s = SortSpec(SortCriterion.parkerScore, ascending: false);
    expect(SortSpec.fromJson(s.toJson()), s);
    expect(SortSpec.fromJson({'c': 'inconnu'}), isNull);
  });

  test('AJO-08 étiquette sans domaine lisible : la cuvée sert de nom', () {
    const sansDomaine = WineListItem(
      id: 'h',
      producer: '',
      cuvee: 'Hortense',
      vintage: '2020',
      colorCode: 'blanc',
      countryCode: 'FR',
      bottles: 0,
    );
    expect(sansDomaine.isUnidentified, isFalse);
    expect(sansDomaine.displayName, 'Hortense');
    expect(w('x', producer: '').isUnidentified, isTrue);
  });
}
