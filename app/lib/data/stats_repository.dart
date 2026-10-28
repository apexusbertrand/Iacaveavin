import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/scores.dart';
import '../domain/stats.dart';
import 'db/app_database.dart';

/// Favori de l'explorateur (table vue_statistique, STA-05).
class SavedView {
  const SavedView({
    required this.id,
    required this.name,
    required this.query,
    required this.chart,
  });

  final String id;
  final String name;
  final StatQuery query;
  final StatChart chart;
}

/// Faits des statistiques (un par lot) et favoris de l'explorateur.
class StatsRepository {
  StatsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  /// STA-06 : lecture en quelques requêtes, sans jointure par fiche.
  Future<List<StatFact>> facts() async {
    final producers = {
      for (final p in await _db.select(_db.producers).get()) p.id: p,
    };
    final cuvees = {
      for (final c in await _db.select(_db.cuvees).get()) c.id: c,
    };
    final wines = {
      for (final w in await (_db.select(
        _db.wines,
      )..where((w) => w.deletedAt.isNull())).get())
        w.id: w,
    };
    final lots = await (_db.select(
      _db.stockLots,
    )..where((l) => l.deletedAt.isNull())).get();
    // Stock et ouvertures calculés par SQLite (STA-06).
    final stock = <String, int>{
      for (final r
          in await _db
              .customSelect(
                'SELECT lot_id, SUM(quantite) AS q FROM mouvement '
                'WHERE deleted_at IS NULL GROUP BY lot_id',
                readsFrom: {_db.stockMovements},
              )
              .get())
        r.read<String>('lot_id'): r.read<int>('q'),
    };
    final openings = <String, Map<String, int>>{};
    for (final r
        in await _db
            .customSelect(
              "SELECT lot_id, substr(date_mouvement, 1, 7) AS mois, "
              "-SUM(quantite) AS q FROM mouvement "
              "WHERE deleted_at IS NULL AND type_mouvement = 'ouverture' "
              'GROUP BY lot_id, mois',
              readsFrom: {_db.stockMovements},
            )
            .get()) {
      openings.putIfAbsent(r.read<String>('lot_id'), () => {})[r.read<String>(
        'mois',
      )] = r.read<int>(
        'q',
      );
    }
    final scores = <String, List<CriticScoreValue>>{};
    for (final s in await (_db.select(
      _db.criticScores,
    )..where((s) => s.deletedAt.isNull())).get()) {
      scores
          .putIfAbsent(s.ficheId, () => [])
          .add(
            CriticScoreValue(
              critic: s.critique,
              score: s.note,
              scale: s.echelle,
              date: s.dateNote,
              citedBy: s.citeePar,
            ),
          );
    }
    final history = <(String, double), List<(String, double)>>{};
    for (final p
        in await (_db.select(_db.marketPrices)
              ..where((p) => p.deletedAt.isNull() & p.trouve.equals(true))
              ..orderBy([(p) => OrderingTerm.asc(p.dateReleve)]))
            .get()) {
      if (p.prix == null) continue;
      history.putIfAbsent((p.ficheId, p.formatCl), () => []).add((
        p.dateReleve,
        p.prix!,
      ));
    }

    final out = <StatFact>[];
    for (final lot in lots) {
      final w = wines[lot.ficheId];
      final c = w == null ? null : cuvees[w.cuveeId];
      final p = c == null ? null : producers[c.domaineId];
      if (w == null || c == null || p == null) continue;
      final prices = history[(w.id, lot.formatCl)] ?? const [];
      out.add(
        StatFact(
          wineId: w.id,
          lotId: lot.id,
          bottles: stock[lot.id] ?? 0,
          keys: {
            StatDimension.color: c.couleur,
            StatDimension.type: ?c.typeVin,
            StatDimension.country: c.pays,
            StatDimension.region: ?c.region,
            StatDimension.subRegion: ?c.sousRegion,
            StatDimension.appellation: ?c.appellation,
            StatDimension.producer: p.nom,
            StatDimension.vintage: w.millesime,
            StatDimension.mainGrape: ?_mainGrape(w.cepages),
            StatDimension.owner: lot.proprietaireId,
            StatDimension.location: ?lot.emplacementId,
            StatDimension.supplier: ?lot.fournisseur,
            if ((lot.dateAchat ?? '').length >= 7)
              StatDimension.purchaseMonth: lot.dateAchat!.substring(0, 7),
          },
          unitPrice: lot.prixAchatUnitaire,
          marketPrice: prices.lastOrNull?.$2,
          score100: bestScoreOn100(scores[w.id] ?? const []),
          gardeStart: w.gardeDebut,
          gardePeak: w.gardeApogee,
          gardeEnd: w.gardeFin,
          openings: [
            for (final e in (openings[lot.id] ?? const {}).entries)
              (e.key, e.value),
          ],
          priceHistory: prices,
        ),
      );
    }
    return out;
  }

  static String? _mainGrape(String? json) {
    if (json == null || json.isEmpty) return null;
    final list = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return null;
    list.sort(
      (a, b) => ((b['pourcentage'] as num?) ?? 0).compareTo(
        (a['pourcentage'] as num?) ?? 0,
      ),
    );
    return list.first['cepage'] as String?;
  }

  // ------------------------------------------------------------ Favoris

  Stream<List<SavedView>> watchViews() =>
      (_db.select(_db.savedStatViews)
            ..where((v) => v.deletedAt.isNull())
            ..orderBy([(v) => OrderingTerm.asc(v.nom)]))
          .watch()
          .map((rows) => [for (final r in rows) ?_view(r)]);

  static SavedView? _view(SavedStatView r) {
    final measure = StatMeasure.fromCode(r.mesure);
    final dim1 = StatDimension.fromCode(r.dimension1);
    final chart = StatChart.fromCode(r.graphique);
    if (measure == null || dim1 == null || chart == null) return null;
    final filters = <StatDimension, Set<String>>{};
    if (r.filtres != null && r.filtres!.isNotEmpty) {
      for (final e
          in (jsonDecode(r.filtres!) as Map<String, dynamic>).entries) {
        final d = StatDimension.fromCode(e.key);
        if (d != null) filters[d] = (e.value as List).cast<String>().toSet();
      }
    }
    return SavedView(
      id: r.id,
      name: r.nom,
      chart: chart,
      query: StatQuery(
        measure: measure,
        dim1: dim1,
        dim2: StatDimension.fromCode(r.dimension2),
        filters: filters,
      ),
    );
  }

  /// STA-05 : enregistre la vue en favori.
  Future<String> saveView({
    required String cellarId,
    required String name,
    required StatQuery query,
    required StatChart chart,
  }) async {
    final id = _uuid.v4();
    final now = _clock().toUtc();
    await _db
        .into(_db.savedStatViews)
        .insert(
          SavedStatViewsCompanion.insert(
            id: id,
            caveId: cellarId,
            createdAt: now,
            updatedAt: now,
            nom: name.trim(),
            mesure: query.measure.code,
            dimension1: query.dim1.code,
            graphique: chart.code,
          ).copyWith(
            dimension2: Value(query.dim2?.code),
            filtres: Value(
              query.filters.values.every((s) => s.isEmpty)
                  ? null
                  : jsonEncode({
                      for (final e in query.filters.entries)
                        if (e.value.isNotEmpty) e.key.code: e.value.toList(),
                    }),
            ),
          ),
        );
    return id;
  }

  Future<void> deleteView(String id) =>
      (_db.update(_db.savedStatViews)..where((v) => v.id.equals(id))).write(
        SavedStatViewsCompanion(deletedAt: Value(_clock().toUtc())),
      );
}
