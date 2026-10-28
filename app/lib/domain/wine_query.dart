/// Tri, filtres, groupes et recherche de la liste (LST-01 à LST-06).
///
/// Fonctions pures sur [WineListItem] : la liste complète tient en mémoire
/// (5 000 fiches = quelques Mo) et un tri complet prend quelques millisecondes.
library;

import 'garde.dart';
import 'wine_list_item.dart';

/// Ordre de la liste « couleur » du dictionnaire (LST-02).
const colorOrder = [
  'rouge',
  'blanc',
  'rose',
  'champagne',
  'effervescent',
  'liquoreux',
  'orange',
  'autre',
];

enum SortCriterion {
  vintage(groupable: true),
  color(groupable: true),
  parkerScore,
  bestScore,
  name,
  producer,
  country(groupable: true),
  region(groupable: true),
  appellation,
  owner(groupable: true),
  location(groupable: true),
  purchasePrice,
  marketValue,
  quantity,
  addedAt,
  gardeStart,
  gardeEnd,
  gardePeak(groupable: true),
  cellarStatus;

  const SortCriterion({this.groupable = false});

  /// LST-03 : un tri 1 groupable affiche des groupes repliables.
  final bool groupable;
}

class SortSpec {
  const SortSpec(this.criterion, {this.ascending = true});

  final SortCriterion criterion;
  final bool ascending;

  SortSpec toggled() => SortSpec(criterion, ascending: !ascending);

  Map<String, Object> toJson() => {'c': criterion.name, 'a': ascending};

  static SortSpec? fromJson(Object? json) {
    if (json is! Map) return null;
    final c = SortCriterion.values.where((v) => v.name == json['c']);
    if (c.isEmpty) return null;
    return SortSpec(c.first, ascending: json['a'] != false);
  }

  @override
  bool operator ==(Object other) =>
      other is SortSpec &&
      other.criterion == criterion &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(criterion, ascending);
}

enum StockFilter { inStock, empty, all }

/// Filtres combinables (LST-05). Un ensemble vide ou une borne nulle
/// signifie « pas de filtre ».
class WineFilters {
  const WineFilters({
    this.stock = StockFilter.inStock,
    this.colors = const {},
    this.types = const {},
    this.countries = const {},
    this.regions = const {},
    this.appellations = const {},
    this.vintageMin,
    this.vintageMax,
    this.owners = const {},
    this.location,
    this.statuses = const {},
    this.idealYearMin,
    this.idealYearMax,
    this.minScore,
    this.priceMin,
    this.priceMax,
    this.grapes = const {},
    this.enrichment = const {},
    this.favoritesOnly = false,
  });

  final StockFilter stock;
  final Set<String> colors;
  final Set<String> types;
  final Set<String> countries;
  final Set<String> regions;
  final Set<String> appellations;
  final int? vintageMin;
  final int? vintageMax;
  final Set<String> owners;

  /// Emplacement choisi : ses sous-emplacements sont inclus.
  final String? location;
  final Set<CellarStatus> statuses;
  final int? idealYearMin;
  final int? idealYearMax;

  /// Note minimale sur 100, toutes sources (NOT-R2).
  final double? minScore;
  final double? priceMin;
  final double? priceMax;
  final Set<String> grapes;
  final Set<String> enrichment;
  final bool favoritesOnly;

  /// Nombre de critères actifs, pour la pastille « 3 filtres actifs ».
  /// Le filtre de stock par défaut (en stock) ne compte pas.
  int get activeCount =>
      (stock != StockFilter.inStock ? 1 : 0) +
      (colors.isNotEmpty ? 1 : 0) +
      (types.isNotEmpty ? 1 : 0) +
      (countries.isNotEmpty ? 1 : 0) +
      (regions.isNotEmpty ? 1 : 0) +
      (appellations.isNotEmpty ? 1 : 0) +
      (vintageMin != null || vintageMax != null ? 1 : 0) +
      (owners.isNotEmpty ? 1 : 0) +
      (location != null ? 1 : 0) +
      (statuses.isNotEmpty ? 1 : 0) +
      (idealYearMin != null || idealYearMax != null ? 1 : 0) +
      (minScore != null ? 1 : 0) +
      (priceMin != null || priceMax != null ? 1 : 0) +
      (grapes.isNotEmpty ? 1 : 0) +
      (enrichment.isNotEmpty ? 1 : 0) +
      (favoritesOnly ? 1 : 0);

  WineFilters copyWith({
    StockFilter? stock,
    Set<String>? colors,
    Set<String>? types,
    Set<String>? countries,
    Set<String>? regions,
    Set<String>? appellations,
    int? Function()? vintageMin,
    int? Function()? vintageMax,
    Set<String>? owners,
    String? Function()? location,
    Set<CellarStatus>? statuses,
    int? Function()? idealYearMin,
    int? Function()? idealYearMax,
    double? Function()? minScore,
    double? Function()? priceMin,
    double? Function()? priceMax,
    Set<String>? grapes,
    Set<String>? enrichment,
    bool? favoritesOnly,
  }) => WineFilters(
    stock: stock ?? this.stock,
    colors: colors ?? this.colors,
    types: types ?? this.types,
    countries: countries ?? this.countries,
    regions: regions ?? this.regions,
    appellations: appellations ?? this.appellations,
    vintageMin: vintageMin != null ? vintageMin() : this.vintageMin,
    vintageMax: vintageMax != null ? vintageMax() : this.vintageMax,
    owners: owners ?? this.owners,
    location: location != null ? location() : this.location,
    statuses: statuses ?? this.statuses,
    idealYearMin: idealYearMin != null ? idealYearMin() : this.idealYearMin,
    idealYearMax: idealYearMax != null ? idealYearMax() : this.idealYearMax,
    minScore: minScore != null ? minScore() : this.minScore,
    priceMin: priceMin != null ? priceMin() : this.priceMin,
    priceMax: priceMax != null ? priceMax() : this.priceMax,
    grapes: grapes ?? this.grapes,
    enrichment: enrichment ?? this.enrichment,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
  );

  /// LST-09 : filtres mémorisés d'une session à l'autre.
  Map<String, Object?> toJson() => {
    'stock': stock.name,
    'colors': colors.toList(),
    'types': types.toList(),
    'countries': countries.toList(),
    'regions': regions.toList(),
    'appellations': appellations.toList(),
    'vintageMin': vintageMin,
    'vintageMax': vintageMax,
    'owners': owners.toList(),
    'location': location,
    'statuses': statuses.map((s) => s.code).toList(),
    'idealYearMin': idealYearMin,
    'idealYearMax': idealYearMax,
    'minScore': minScore,
    'priceMin': priceMin,
    'priceMax': priceMax,
    'grapes': grapes.toList(),
    'enrichment': enrichment.toList(),
    'favoritesOnly': favoritesOnly,
  };

  static WineFilters fromJson(Object? json) {
    if (json is! Map) return const WineFilters();
    Set<String> set(String k) => {
      for (final v in (json[k] as List? ?? const [])) '$v',
    };
    int? i(String k) => (json[k] as num?)?.toInt();
    double? d(String k) => (json[k] as num?)?.toDouble();
    return WineFilters(
      stock: StockFilter.values.firstWhere(
        (s) => s.name == json['stock'],
        orElse: () => StockFilter.inStock,
      ),
      colors: set('colors'),
      types: set('types'),
      countries: set('countries'),
      regions: set('regions'),
      appellations: set('appellations'),
      vintageMin: i('vintageMin'),
      vintageMax: i('vintageMax'),
      owners: set('owners'),
      location: json['location'] as String?,
      statuses: {
        for (final c in set('statuses'))
          ...CellarStatus.values.where((s) => s.code == c),
      },
      idealYearMin: i('idealYearMin'),
      idealYearMax: i('idealYearMax'),
      minScore: d('minScore'),
      priceMin: d('priceMin'),
      priceMax: d('priceMax'),
      grapes: set('grapes'),
      enrichment: set('enrichment'),
      favoritesOnly: json['favoritesOnly'] == true,
    );
  }

  bool matches(WineListItem w, int year) {
    switch (stock) {
      case StockFilter.inStock when w.bottles <= 0 && !w.neverStocked:
      case StockFilter.empty when w.bottles > 0 || w.neverStocked:
        return false;
      default:
    }
    if (colors.isNotEmpty && !colors.contains(w.colorCode)) return false;
    if (types.isNotEmpty && !types.contains(w.wineType)) return false;
    if (countries.isNotEmpty && !countries.contains(w.countryCode)) {
      return false;
    }
    if (regions.isNotEmpty && !regions.contains(w.regionCode)) return false;
    if (appellations.isNotEmpty && !appellations.contains(w.appellationCode)) {
      return false;
    }
    if (vintageMin != null || vintageMax != null) {
      final v = w.vintageYear;
      if (v == null) return false;
      if (vintageMin != null && v < vintageMin!) return false;
      if (vintageMax != null && v > vintageMax!) return false;
    }
    if (owners.isNotEmpty &&
        !w.owners.any((o) => o.bottles > 0 && owners.contains(o.ownerId))) {
      return false;
    }
    if (location != null && !w.locationIds.contains(location)) return false;
    if (statuses.isNotEmpty && !statuses.contains(w.statusIn(year))) {
      return false;
    }
    if (idealYearMin != null || idealYearMax != null) {
      final y = idealYear(
        start: w.gardeStart,
        peak: w.gardePeak,
        end: w.gardeEnd,
      );
      if (y == null) return false;
      if (idealYearMin != null && y < idealYearMin!) return false;
      if (idealYearMax != null && y > idealYearMax!) return false;
    }
    if (minScore != null &&
        (w.bestScore100 == null || w.bestScore100! < minScore!)) {
      return false;
    }
    if (priceMin != null || priceMax != null) {
      final p = w.purchasePrice;
      if (p == null) return false;
      if (priceMin != null && p < priceMin!) return false;
      if (priceMax != null && p > priceMax!) return false;
    }
    if (grapes.isNotEmpty && !w.grapes.any(grapes.contains)) return false;
    if (enrichment.isNotEmpty && !enrichment.contains(w.enrichmentStatus)) {
      return false;
    }
    if (favoritesOnly && !w.favorite) return false;
    return true;
  }
}

/// Valeur de tri d'une fiche pour un critère. Null = valeur absente,
/// toujours rangée en fin de liste (NOT-R4 pour la note Parker).
Comparable<Object>? sortKey(WineListItem w, SortCriterion c, int year) {
  return switch (c) {
    SortCriterion.vintage => w.vintageYear ?? (w.isNonVintage ? 9999 : null),
    SortCriterion.color =>
      colorOrder.indexOf(w.colorCode).let((i) => i < 0 ? colorOrder.length : i),
    SortCriterion.parkerScore => w.parkerScore,
    SortCriterion.bestScore => w.bestScore100,
    SortCriterion.name => normalizeSearch(w.displayName),
    SortCriterion.producer => normalizeSearch(w.producer),
    SortCriterion.country => w.countryLabel?.let(normalizeSearch),
    SortCriterion.region => w.region?.let(normalizeSearch),
    SortCriterion.appellation => w.appellation?.let(normalizeSearch),
    SortCriterion.owner => w.mainOwner?.let(normalizeSearch),
    SortCriterion.location => w.locationPath?.let(normalizeSearch),
    SortCriterion.purchasePrice => w.purchasePrice,
    SortCriterion.marketValue => w.marketValue,
    SortCriterion.quantity => w.bottles,
    SortCriterion.addedAt => w.createdAt?.millisecondsSinceEpoch,
    SortCriterion.gardeStart => w.gardeStart,
    SortCriterion.gardeEnd => w.gardeEnd,
    SortCriterion.gardePeak => w.gardePeak,
    SortCriterion.cellarStatus =>
      w.statusIn(year).let((s) => s == CellarStatus.unknown ? null : s.index),
  } as Comparable<Object>?;
}

int _compareKeys(
  Comparable<Object>? ka,
  Comparable<Object>? kb,
  bool ascending,
) {
  if (ka == null && kb == null) return 0;
  // Valeurs absentes en fin de liste, quel que soit le sens (NOT-R4).
  if (ka == null) return 1;
  if (kb == null) return -1;
  final c = ka.compareTo(kb);
  return ascending ? c : -c;
}

/// Requête complète de la liste : tri à deux niveaux, filtres, recherche.
class WineQuery {
  const WineQuery({
    this.sort1 = const SortSpec(SortCriterion.vintage, ascending: false),
    this.sort2 = const SortSpec(SortCriterion.name),
    this.filters = const WineFilters(),
    this.search = '',
  });

  final SortSpec sort1;
  final SortSpec? sort2;
  final WineFilters filters;
  final String search;

  WineQuery copyWith({
    SortSpec? sort1,
    SortSpec? Function()? sort2,
    WineFilters? filters,
    String? search,
  }) => WineQuery(
    sort1: sort1 ?? this.sort1,
    sort2: sort2 != null ? sort2() : this.sort2,
    filters: filters ?? this.filters,
    search: search ?? this.search,
  );

  List<WineListItem> apply(Iterable<WineListItem> items, {required int year}) {
    final terms = normalizeSearch(search)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    final result = [
      for (final w in items)
        if (filters.matches(w, year) && terms.every(w.searchText.contains)) w,
    ];
    // Clés calculées une fois par fiche : un tri de 5 000 fiches reste
    // sous la dizaine de millisecondes (NFR-01).
    final keys = {
      for (final w in result)
        w.id: (
          sortKey(w, sort1.criterion, year),
          sort2 == null ? null : sortKey(w, sort2!.criterion, year),
          normalizeSearch(w.displayName),
        ),
    };
    result.sort((a, b) {
      final ka = keys[a.id]!, kb = keys[b.id]!;
      var c = _compareKeys(ka.$1, kb.$1, sort1.ascending);
      if (c == 0 && sort2 != null) {
        c = _compareKeys(ka.$2, kb.$2, sort2!.ascending);
      }
      if (c == 0) c = ka.$3.compareTo(kb.$3);
      return c;
    });
    return result;
  }
}

/// Groupe de la liste (LST-03).
class WineGroup {
  const WineGroup({
    required this.key,
    required this.label,
    required this.items,
  });

  /// Clé stable du groupe (pour mémoriser les groupes repliés).
  final String key;

  /// Valeur affichée ; null = « non renseigné » (traduit par l'écran).
  final String? label;
  final List<WineListItem> items;

  int get bottles => items.fold(0, (s, w) => s + w.bottles);
}

/// Découpe une liste déjà triée par [criterion] en groupes consécutifs.
List<WineGroup> groupWines(
  List<WineListItem> sorted,
  SortCriterion criterion, {
  String Function(String colorCode)? colorLabel,
}) {
  String? label(WineListItem w) => switch (criterion) {
    SortCriterion.vintage => w.vintage,
    SortCriterion.color => colorLabel?.call(w.colorCode) ?? w.colorCode,
    SortCriterion.country => w.countryLabel,
    SortCriterion.region => w.region,
    SortCriterion.owner => w.mainOwner,
    SortCriterion.location => w.locationPath,
    SortCriterion.gardePeak => w.gardePeak?.toString(),
    _ => null,
  };
  final groups = <WineGroup>[];
  for (final w in sorted) {
    final l = label(w);
    if (groups.isEmpty || groups.last.label != l) {
      groups.add(WineGroup(key: '${criterion.name}:$l', label: l, items: []));
    }
    groups.last.items.add(w);
  }
  return groups;
}

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ì': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'ò': 'o',
  'õ': 'o',
  'û': 'u',
  'ü': 'u',
  'ù': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'oe',
  'æ': 'ae',
};

/// Minuscules, sans accents, ponctuation réduite à des espaces (LST-06).
String normalizeSearch(String text) {
  final b = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    final mapped = _accents[ch] ?? ch;
    b.write(RegExp(r'[a-z0-9 ]').hasMatch(mapped) ? mapped : ' ');
  }
  return b.toString().replaceAll(RegExp(r' +'), ' ').trim();
}

/// Texte de recherche d'une fiche : nom, domaine, appellation, lieu-dit,
/// cépages et commentaires.
String buildSearchText(Iterable<String?> parts) =>
    normalizeSearch(parts.whereType<String>().join(' '));

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
