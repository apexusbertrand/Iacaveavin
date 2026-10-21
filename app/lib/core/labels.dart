import '../domain/garde.dart';
import '../domain/stock_rules.dart';
import '../domain/wine_query.dart';
import 'l10n/generated/app_localizations.dart';

/// Libellés traduits des énumérations du domaine (aucune clé technique à
/// l'écran, défaut « wine_0»).
extension DomainLabels on AppLocalizations {
  String sortLabel(SortCriterion c) => switch (c) {
    SortCriterion.vintage => sortVintage,
    SortCriterion.color => sortColor,
    SortCriterion.parkerScore => sortParkerScore,
    SortCriterion.bestScore => sortBestScore,
    SortCriterion.name => sortName,
    SortCriterion.producer => sortProducer,
    SortCriterion.country => sortCountry,
    SortCriterion.region => sortRegion,
    SortCriterion.appellation => sortAppellation,
    SortCriterion.owner => sortOwner,
    SortCriterion.location => sortLocation,
    SortCriterion.purchasePrice => sortPurchasePrice,
    SortCriterion.marketValue => sortMarketValue,
    SortCriterion.quantity => sortQuantity,
    SortCriterion.addedAt => sortAddedAt,
    SortCriterion.gardeStart => sortGardeStart,
    SortCriterion.gardeEnd => sortGardeEnd,
    SortCriterion.gardePeak => sortGardePeak,
    SortCriterion.cellarStatus => sortCellarStatus,
  };

  String sortChipLabel(int rank, SortSpec s) => sortChip(
    rank,
    sortLabel(s.criterion),
    s.ascending ? sortAscending : sortDescending,
  );

  String statusLabel(CellarStatus s) => switch (s) {
    CellarStatus.tooYoung => statusTooYoung,
    CellarStatus.toDrink => statusToDrink,
    CellarStatus.peak => statusPeak,
    CellarStatus.drinkSoon => statusDrinkSoon,
    CellarStatus.past => statusPast,
    CellarStatus.unknown => statusUnknown,
  };

  String stockLabel(StockFilter s) => switch (s) {
    StockFilter.inStock => stockInStock,
    StockFilter.empty => stockEmpty,
    StockFilter.all => stockAll,
  };

  String enrichmentLabel(String code) => switch (code) {
    'brouillon' => enrichBrouillon,
    'a_enrichir' => enrichAEnrichir,
    'en_cours' => enrichEnCours,
    'a_valider' => enrichAValider,
    'erreur' => enrichErreur,
    _ => enrichValide,
  };

  String movementLabel(String code) =>
      switch (MovementType.values.where((t) => t.code == code).firstOrNull) {
        MovementType.entry => mvtEntry,
        MovementType.opening => mvtOpening,
        MovementType.otherExit => mvtOtherExit,
        MovementType.adjustment => mvtAdjustment,
        MovementType.transferOut => mvtTransferOut,
        MovementType.transferIn => mvtTransferIn,
        null => mvtEntry,
      };
}
