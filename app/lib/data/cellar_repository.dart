import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/scores.dart';
import '../domain/stock_rules.dart';
import '../domain/wine_detail.dart';
import '../domain/wine_list_item.dart';
import '../domain/wine_query.dart';
import 'db/app_database.dart';

/// Accès à la cave : lecture assemblée des fiches et écritures en transaction.
///
/// Le stock n'existe que par les mouvements (STK-R1) : aucune écriture ne
/// modifie une quantité directement.
class CellarRepository {
  CellarRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();
  String get _today => _clock().toIso8601String().substring(0, 10);

  Iterable<TableInfo<Table, dynamic>> get _listTables => [
    _db.wines,
    _db.cuvees,
    _db.producers,
    _db.stockLots,
    _db.stockMovements,
    _db.owners,
    _db.storageLocations,
    _db.listValues,
    _db.criticScores,
    _db.marketPrices,
  ];

  /// Liste complète, rechargée à chaque modification d'une table utile.
  Stream<List<WineListItem>> watchWineItems() async* {
    yield await wineItems();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables(_listTables),
    )) {
      yield await wineItems();
    }
  }

  Future<_Context> _context() async {
    final labels = <String, String>{};
    for (final v in await (_db.select(
      _db.listValues,
    )..where((v) => v.deletedAt.isNull())).get()) {
      labels.putIfAbsent('${v.liste}:${v.code}', () => v.libelle);
    }
    final owners = {
      for (final o in await (_db.select(
        _db.owners,
      )..where((o) => o.deletedAt.isNull())).get())
        o.id: o,
    };
    final locations = {
      for (final l in await (_db.select(
        _db.storageLocations,
      )..where((l) => l.deletedAt.isNull())).get())
        l.id: l,
    };
    return _Context(labels, owners, locations);
  }

  Future<Map<String, int>> _lotStocks() async {
    final sum = _db.stockMovements.quantite.sum();
    final rows =
        await (_db.selectOnly(_db.stockMovements)
              ..addColumns([_db.stockMovements.lotId, sum])
              ..where(_db.stockMovements.deletedAt.isNull())
              ..groupBy([_db.stockMovements.lotId]))
            .get();
    return {
      for (final r in rows) r.read(_db.stockMovements.lotId)!: r.read(sum) ?? 0,
    };
  }

  Future<List<WineListItem>> wineItems() async {
    final ctx = await _context();
    final producers = {
      for (final p in await _db.select(_db.producers).get()) p.id: p,
    };
    final cuvees = {
      for (final c in await _db.select(_db.cuvees).get()) c.id: c,
    };
    final stocks = await _lotStocks();
    final lotsByWine = <String, List<StockLot>>{};
    for (final l in await (_db.select(
      _db.stockLots,
    )..where((l) => l.deletedAt.isNull())).get()) {
      lotsByWine.putIfAbsent(l.ficheId, () => []).add(l);
    }
    final scoresByWine = <String, List<CriticScoreValue>>{};
    for (final s in await (_db.select(
      _db.criticScores,
    )..where((s) => s.deletedAt.isNull())).get()) {
      scoresByWine.putIfAbsent(s.ficheId, () => []).add(_score(s));
    }
    // Dernier prix marché trouvé par fiche et par format (VAL-R2).
    final market = <(String, double), double>{};
    for (final p
        in await (_db.select(_db.marketPrices)
              ..where((p) => p.deletedAt.isNull() & p.trouve.equals(true))
              ..orderBy([(p) => OrderingTerm.asc(p.dateReleve)]))
            .get()) {
      if (p.prix != null) market[(p.ficheId, p.formatCl)] = p.prix!;
    }

    final thumbs = <String, String>{};
    for (final ph in await (_db.select(
      _db.photos,
    )..where((x) => x.deletedAt.isNull() & x.principale.equals(true))).get()) {
      thumbs[ph.ficheId] = ph.chemin.replaceFirst(
        RegExp(r'\.jpg$'),
        '_mini.jpg',
      );
    }
    final items = <WineListItem>[];
    for (final f in await (_db.select(
      _db.wines,
    )..where((w) => w.deletedAt.isNull())).get()) {
      final c = cuvees[f.cuveeId];
      final p = c == null ? null : producers[c.domaineId];
      if (c == null || p == null) continue;
      final lots = lotsByWine[f.id] ?? const <StockLot>[];
      var bottles = 0;
      double? marketValue;
      final perOwner = <String, int>{};
      final locIds = <String>{};
      String? mainLocation;
      var mainLocationBottles = -1;
      StockLot? lastPriced;
      String? primaryLot;
      var primaryLotBottles = 0;
      // Un lot sans aucun mouvement n'a pas de ligne dans [stocks].
      final neverStocked = !lots.any((l) => stocks.containsKey(l.id));
      for (final l in lots) {
        final q = stocks[l.id] ?? 0;
        bottles += q;
        if (q > primaryLotBottles) {
          primaryLot = l.id;
          primaryLotBottles = q;
        }
        perOwner.update(l.proprietaireId, (v) => v + q, ifAbsent: () => q);
        if (q > 0 && l.emplacementId != null) {
          locIds.addAll(ctx.ancestors(l.emplacementId!));
          if (q > mainLocationBottles) {
            mainLocation = l.emplacementId;
            mainLocationBottles = q;
          }
        }
        final mp = market[(f.id, l.formatCl)];
        if (mp != null && q > 0) marketValue = (marketValue ?? 0) + mp * q;
        if (l.prixAchatUnitaire != null &&
            (lastPriced == null ||
                (l.dateAchat ?? '').compareTo(lastPriced.dateAchat ?? '') >
                    0)) {
          lastPriced = l;
        }
      }
      final owners = [
        for (final e in perOwner.entries)
          OwnerShare(
            ownerId: e.key,
            name: ctx.owners[e.key]?.nom ?? '',
            bottles: e.value,
          ),
      ]..sort((a, b) => b.bottles.compareTo(a.bottles));
      final grapes = _grapes(f.cepages);
      final grapeLabels = [
        for (final g in grapes) ctx.labels['cepage:${g.code}'] ?? g.code,
      ];
      final scores = scoresByWine[f.id] ?? const [];
      final appellation = ctx.label('appellation', c.appellation);
      items.add(
        WineListItem(
          id: f.id,
          producer: p.nom,
          cuvee: c.nom,
          vintage: f.millesime,
          colorCode: c.couleur,
          countryCode: c.pays,
          countryLabel: ctx.label('pays', c.pays),
          region: ctx.label('region', c.region),
          subRegion: ctx.label('sous_region', c.sousRegion),
          appellation: appellation,
          bottles: bottles,
          purchasePrice: lastPriced?.prixAchatUnitaire,
          enrichmentStatus: f.statutEnrichissement ?? 'brouillon',
          wineType: c.typeVin,
          regionCode: c.region,
          appellationCode: c.appellation,
          lieuDit: c.lieuDit,
          owners: owners,
          locationIds: locIds,
          locationPath: mainLocation == null ? null : ctx.path(mainLocation),
          parkerScore: parkerScore(scores)?.score,
          bestScore100: bestScoreOn100(scores),
          marketValue: marketValue,
          createdAt: f.createdAt,
          gardeStart: f.gardeDebut,
          gardePeak: f.gardeApogee,
          gardeEnd: f.gardeFin,
          grapes: grapes.map((g) => g.code).toList(),
          favorite: f.favori ?? false,
          primaryLotId: primaryLot,
          thumbPath: thumbs[f.id],
          neverStocked: neverStocked,
          searchText: buildSearchText([
            p.nom,
            c.nom,
            appellation,
            c.lieuDit,
            ...grapeLabels,
            f.commentairePerso,
            f.commentaireMillesime,
            p.commentaire,
          ]),
        ),
      );
    }
    return items;
  }

  static List<GrapeShare> _grapes(String? json) {
    if (json == null || json.isEmpty) return const [];
    return (jsonDecode(json) as List)
        .cast<Map<String, dynamic>>()
        .map(GrapeShare.fromJson)
        .toList();
  }

  static CriticScoreValue _score(CriticScore s) => CriticScoreValue(
    critic: s.critique,
    score: s.note,
    scale: s.echelle,
    date: s.dateNote,
    citedBy: s.citeePar,
  );

  // ---------------------------------------------------------------- Détail

  Stream<WineDetail?> watchWine(String id) async* {
    yield await wine(id);
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([..._listTables, _db.tastings]),
    )) {
      yield await wine(id);
    }
  }

  Future<WineDetail?> wine(String id) async {
    final f = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(id) & w.deletedAt.isNull())).getSingleOrNull();
    if (f == null) return null;
    final c = await (_db.select(
      _db.cuvees,
    )..where((x) => x.id.equals(f.cuveeId))).getSingle();
    final p = await (_db.select(
      _db.producers,
    )..where((x) => x.id.equals(c.domaineId))).getSingle();
    final ctx = await _context();
    final stocks = await _lotStocks();
    final lots =
        await (_db.select(_db.stockLots)
              ..where((l) => l.ficheId.equals(id) & l.deletedAt.isNull())
              ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
            .get();
    final lotIds = lots.map((l) => l.id).toList();
    final movements = lotIds.isEmpty
        ? <StockMovement>[]
        : await (_db.select(_db.stockMovements)
                ..where((m) => m.lotId.isIn(lotIds) & m.deletedAt.isNull())
                ..orderBy([
                  (m) => OrderingTerm.desc(m.dateMouvement),
                  (m) => OrderingTerm.desc(m.createdAt),
                  (m) => OrderingTerm.desc(m.rowId),
                ]))
              .get();
    final tastings =
        await (_db.select(_db.tastings)
              ..where((t) => t.ficheId.equals(id) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.dateDegustation)]))
            .get();
    final scores = await (_db.select(
      _db.criticScores,
    )..where((s) => s.ficheId.equals(id) & s.deletedAt.isNull())).get();
    final prices =
        await (_db.select(_db.marketPrices)
              ..where((s) => s.ficheId.equals(id) & s.deletedAt.isNull())
              ..orderBy([(s) => OrderingTerm.asc(s.dateReleve)]))
            .get();
    final provenances = <String, ProvenanceView>{};
    for (final p
        in await (_db.select(_db.provenances)
              ..where(
                (p) =>
                    p.entite.equals('fiche_vin') &
                    p.entiteId.equals(id) &
                    p.deletedAt.isNull() &
                    p.statut.isIn(['valide', 'manuel', 'verrouille']),
              )
              ..orderBy([(p) => OrderingTerm.asc(p.updatedAt)]))
            .get()) {
      provenances[p.champ] = ProvenanceView(
        id: p.id,
        field: p.champ,
        source: p.source,
        date: p.dateCollecte,
        status: p.statut,
        url: p.url,
        confidence: p.confiance,
        reported: p.signale ?? false,
      );
    }
    final grapes = _grapes(f.cepages);
    final pairings = f.accords == null || f.accords!.isEmpty
        ? const <String>[]
        : (jsonDecode(f.accords!) as List).cast<String>();

    return WineDetail(
      id: f.id,
      cuveeId: c.id,
      producerId: p.id,
      enrichmentStatus: f.statutEnrichissement ?? 'brouillon',
      gardeSource: f.gardeSource,
      provenances: provenances,
      labels: ctx.labels,
      draft: WineDraft(
        producer: p.nom,
        producerWebsite: p.siteOfficiel,
        producerComment: p.commentaire,
        cuvee: c.nom,
        country: c.pays,
        region: c.region,
        subRegion: c.sousRegion,
        appellation: c.appellation,
        qualitySign: c.signeQualite,
        classification: c.classement,
        lieuDit: c.lieuDit,
        color: c.couleur,
        wineType: c.typeVin,
        certification: c.certification,
        vintage: f.millesime,
        grapes: grapes,
        alcohol: f.degre,
        vintageComment: f.commentaireMillesime,
        gardeStart: f.gardeDebut,
        gardePeak: f.gardeApogee,
        gardeEnd: f.gardeFin,
        pairings: pairings,
        ean: f.ean,
        lwin: f.lwin,
        personalComment: f.commentairePerso,
        favorite: f.favori ?? false,
      ),
      lots: [
        for (final l in lots)
          LotView(
            id: l.id,
            ownerId: l.proprietaireId,
            ownerName: ctx.owners[l.proprietaireId]?.nom ?? '',
            formatCl: l.formatCl,
            bottles: stocks[l.id] ?? 0,
            locationId: l.emplacementId,
            locationPath: l.emplacementId == null
                ? null
                : ctx.path(l.emplacementId!),
            positions: l.positions,
            unitPrice: l.prixAchatUnitaire,
            purchaseDate: l.dateAchat,
            supplier: l.fournisseur,
          ),
      ],
      movements: [
        for (final m in movements)
          MovementView(
            id: m.id,
            lotId: m.lotId,
            type: m.typeMouvement,
            quantity: m.quantite,
            date: m.dateMouvement,
            createdAt: m.createdAt,
            reason: m.motif,
            comment: m.commentaire,
          ),
      ],
      tastings: [
        for (final t in tastings)
          TastingView(
            id: t.id,
            date: t.dateDegustation,
            score: t.notePerso,
            comment: t.commentaire,
            dish: t.plat,
          ),
      ],
      scores: scores.map(_score).toList(),
      marketPrices: [
        for (final m in prices)
          MarketPriceView(
            date: m.dateReleve,
            formatCl: m.formatCl,
            found: m.trouve,
            price: m.prix,
            offers: m.nbOffres,
            site: m.site,
            url: m.url,
          ),
      ],
    );
  }

  /// Lots en stock rangés dans [locationIds], triés par nom de vin.
  Future<List<LocationLot>> lotsIn(Set<String> locationIds) async {
    if (locationIds.isEmpty) return const [];
    final ctx = await _context();
    final stocks = await _lotStocks();
    final lots =
        await (_db.select(_db.stockLots)..where(
              (l) => l.emplacementId.isIn(locationIds) & l.deletedAt.isNull(),
            ))
            .get();
    final items = {for (final w in await wineItems()) w.id: w};
    final out = <LocationLot>[];
    for (final l in lots) {
      final q = stocks[l.id] ?? 0;
      final w = items[l.ficheId];
      if (q <= 0 || w == null) continue;
      out.add(
        LocationLot(
          lotId: l.id,
          wineId: w.id,
          wineName: w.displayName,
          vintage: w.vintage,
          colorCode: w.colorCode,
          locationId: l.emplacementId!,
          ownerName: ctx.owners[l.proprietaireId]?.nom ?? '',
          bottles: q,
          positions: l.positions,
        ),
      );
    }
    out.sort((a, b) => a.wineName.compareTo(b.wineName));
    return out;
  }

  Stream<List<LocationLot>> watchLotsIn(Set<String> locationIds) async* {
    yield await lotsIn(locationIds);
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables(_listTables),
    )) {
      yield await lotsIn(locationIds);
    }
  }

  // ---------------------------------------------------------- Écritures

  /// Crée une fiche saisie à la main, avec son premier lot (FIC-01, PRX-01).
  /// Domaine et cuvée existants sont réutilisés (même nom, même origine).
  Future<String> createWine(
    WineDraft d, {
    required String cellarId,
    LotDraft? lot,
  }) {
    return _db.transaction(() async {
      final producerId = await _producerFor(d, cellarId);
      final cuveeId = await _cuveeFor(d, producerId, cellarId);
      final id = _uuid.v4();
      await _db
          .into(_db.wines)
          .insert(
            WinesCompanion.insert(
              id: id,
              caveId: cellarId,
              createdAt: _now,
              updatedAt: _now,
              cuveeId: cuveeId,
              millesime: d.vintage.trim(),
            ).copyWith(
              cepages: Value(_grapesJson(d.grapes)),
              degre: Value(d.alcohol),
              commentaireMillesime: Value(_blank(d.vintageComment)),
              gardeDebut: Value(d.gardeStart),
              gardeApogee: Value(d.gardePeak),
              gardeFin: Value(d.gardeEnd),
              gardeSource: Value(
                d.gardeStart == null && d.gardeEnd == null ? null : 'manuel',
              ),
              accords: Value(_pairingsJson(d.pairings)),
              ean: Value(_blank(d.ean)),
              lwin: Value(_blank(d.lwin)),
              commentairePerso: Value(_blank(d.personalComment)),
              favori: Value(d.favorite),
              statutEnrichissement: const Value('valide'),
            ),
          );
      if (lot != null) await _insertLot(id, lot, cellarId);
      return id;
    });
  }

  /// Met à jour une fiche (FIC-01). Changer le domaine rattache la cuvée au
  /// domaine de ce nom, créé au besoin.
  Future<void> updateWine(String id, WineDraft d) {
    return _db.transaction(() async {
      final f = await (_db.select(
        _db.wines,
      )..where((w) => w.id.equals(id))).getSingle();
      final c = await (_db.select(
        _db.cuvees,
      )..where((x) => x.id.equals(f.cuveeId))).getSingle();
      final producerId = await _producerFor(d, c.caveId);
      await (_db.update(
        _db.cuvees,
      )..where((x) => x.id.equals(c.id))).write(_cuveeCompanion(d, producerId));
      final gardeChanged =
          f.gardeDebut != d.gardeStart ||
          f.gardeApogee != d.gardePeak ||
          f.gardeFin != d.gardeEnd;
      await (_db.update(_db.wines)..where((w) => w.id.equals(id))).write(
        WinesCompanion(
          updatedAt: Value(_now),
          millesime: Value(d.vintage.trim()),
          cepages: Value(_grapesJson(d.grapes)),
          degre: Value(d.alcohol),
          commentaireMillesime: Value(_blank(d.vintageComment)),
          gardeDebut: Value(d.gardeStart),
          gardeApogee: Value(d.gardePeak),
          gardeFin: Value(d.gardeEnd),
          gardeSource: gardeChanged
              ? Value(
                  d.gardeStart == null && d.gardeEnd == null ? null : 'manuel',
                )
              : const Value.absent(),
          accords: Value(_pairingsJson(d.pairings)),
          ean: Value(_blank(d.ean)),
          lwin: Value(_blank(d.lwin)),
          commentairePerso: Value(_blank(d.personalComment)),
          favori: Value(d.favorite),
        ),
      );
    });
  }

  /// Fiche gardée en brouillon (photos sans envoi, consentement refusé).
  Future<void> markDraft(String id) =>
      (_db.update(_db.wines)..where((w) => w.id.equals(id))).write(
        WinesCompanion(
          statutEnrichissement: const Value('brouillon'),
          updatedAt: Value(_now),
        ),
      );

  /// PRV-R4 : la valeur reste affichée barrée, le signalement part avec le
  /// prochain enrichissement.
  Future<void> reportProvenance(String provenanceId) =>
      (_db.update(
        _db.provenances,
      )..where((p) => p.id.equals(provenanceId))).write(
        ProvenancesCompanion(
          signale: const Value(true),
          updatedAt: Value(_now),
        ),
      );

  /// PRV-R3 : déverrouiller un champ saisi à la main (appui long).
  Future<void> unlockField(String provenanceId) =>
      (_db.update(
        _db.provenances,
      )..where((p) => p.id.equals(provenanceId))).write(
        ProvenancesCompanion(
          statut: const Value('valide'),
          updatedAt: Value(_now),
        ),
      );

  /// FIC-08 : nouvelle fiche sur la même cuvée pour un autre millésime. Les
  /// photos sont reprises ; seuls les champs du millésime restent à enrichir.
  Future<String> duplicateForVintage(String id, String vintage) =>
      _db.transaction(() async {
        final f = await (_db.select(
          _db.wines,
        )..where((w) => w.id.equals(id))).getSingle();
        final newId = _uuid.v4();
        await _db
            .into(_db.wines)
            .insert(
              WinesCompanion.insert(
                id: newId,
                caveId: f.caveId,
                createdAt: _now,
                updatedAt: _now,
                cuveeId: f.cuveeId,
                millesime: vintage,
              ).copyWith(
                cepages: Value(f.cepages),
                accords: Value(f.accords),
                statutEnrichissement: const Value('a_enrichir'),
              ),
            );
        for (final ph in await (_db.select(
          _db.photos,
        )..where((p) => p.ficheId.equals(id) & p.deletedAt.isNull())).get()) {
          await _db
              .into(_db.photos)
              .insert(
                ph
                    .toCompanion(true)
                    .copyWith(
                      id: Value(_uuid.v4()),
                      ficheId: Value(newId),
                      createdAt: Value(_now),
                      updatedAt: Value(_now),
                    ),
              );
        }
        // Champs de la cuvée et millésime : saisis, donc verrouillés (PRV-R2).
        for (final field in const [
          'domaine',
          'cuvee',
          'pays',
          'region',
          'sous_region',
          'appellation',
          'couleur',
          'millesime',
        ]) {
          await _db
              .into(_db.provenances)
              .insert(
                ProvenancesCompanion.insert(
                  id: _uuid.v4(),
                  caveId: f.caveId,
                  createdAt: _now,
                  updatedAt: _now,
                  entite: 'fiche_vin',
                  entiteId: newId,
                  champ: field,
                  source: 'manuel',
                  dateCollecte: _today,
                  statut: 'verrouille',
                ),
              );
        }
        return newId;
      });

  Future<void> setFavorite(String id, bool favorite) =>
      (_db.update(_db.wines)..where((w) => w.id.equals(id))).write(
        WinesCompanion(favori: Value(favorite), updatedAt: Value(_now)),
      );

  /// Suppression logique de la fiche et de ses lots ; les mouvements restent.
  Future<void> deleteWine(String id) {
    return _db.transaction(() async {
      await (_db.update(_db.wines)..where((w) => w.id.equals(id))).write(
        WinesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
      );
      await (_db.update(
        _db.stockLots,
      )..where((l) => l.ficheId.equals(id))).write(
        StockLotsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
      );
    });
  }

  /// FIC-04 : note de dégustation, proposée à l'ouverture, jamais imposée.
  Future<void> addTasting({
    required String wineId,
    required String cellarId,
    double? score,
    String? comment,
    String? dish,
    String? movementId,
    String? date,
  }) => _db
      .into(_db.tastings)
      .insert(
        TastingsCompanion.insert(
          id: _uuid.v4(),
          caveId: cellarId,
          createdAt: _now,
          updatedAt: _now,
          ficheId: wineId,
          dateDegustation: date ?? _today,
          notePerso: Value(score),
          commentaire: Value(_blank(comment)),
          plat: Value(_blank(dish)),
          mouvementId: Value(movementId),
        ),
      );

  /// Nouveau lot sur une fiche existante (réapprovisionnement, STK-06).
  Future<String> addLot(String wineId, LotDraft lot) async {
    final f = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(wineId))).getSingle();
    return _db.transaction(() => _insertLot(wineId, lot, f.caveId));
  }

  Future<String> _insertLot(
    String wineId,
    LotDraft lot,
    String cellarId,
  ) async {
    final lotId = _uuid.v4();
    await _db
        .into(_db.stockLots)
        .insert(
          StockLotsCompanion.insert(
            id: lotId,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            ficheId: wineId,
            proprietaireId: lot.ownerId,
          ).copyWith(
            formatCl: Value(lot.formatCl),
            emplacementId: Value(lot.locationId),
            positions: Value(_blank(lot.positions)),
            prixAchatUnitaire: Value(lot.unitPrice),
            dateAchat: Value(lot.purchaseDate ?? _today),
            fournisseur: Value(_blank(lot.supplier)),
          ),
        );
    if (lot.quantity > 0) {
      await _db
          .into(_db.stockMovements)
          .insert(
            StockMovementsCompanion.insert(
              id: _uuid.v4(),
              caveId: cellarId,
              createdAt: _now,
              updatedAt: _now,
              lotId: lotId,
              typeMouvement: MovementType.entry.code,
              quantite: lot.quantity,
              dateMouvement: lot.purchaseDate ?? _today,
              motif: const Value('achat'),
            ),
          );
    }
    return lotId;
  }

  /// Met à jour les champs descriptifs d'un lot (prix, emplacement, positions).
  /// La quantité ne change jamais ici (STK-R1).
  Future<void> updateLot(String lotId, LotDraft lot) =>
      (_db.update(_db.stockLots)..where((l) => l.id.equals(lotId))).write(
        StockLotsCompanion(
          updatedAt: Value(_now),
          formatCl: Value(lot.formatCl),
          proprietaireId: Value(lot.ownerId),
          emplacementId: Value(lot.locationId),
          positions: Value(_blank(lot.positions)),
          prixAchatUnitaire: Value(lot.unitPrice),
          dateAchat: Value(lot.purchaseDate),
          fournisseur: Value(_blank(lot.supplier)),
        ),
      );

  Future<String> _producerFor(WineDraft d, String cellarId) async {
    final name = d.producer.trim();
    final existing =
        await (_db.select(_db.producers)
              ..where((p) => p.nom.equals(name) & p.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) {
      await (_db.update(
        _db.producers,
      )..where((p) => p.id.equals(existing.id))).write(
        ProducersCompanion(
          updatedAt: Value(_now),
          siteOfficiel: Value(_blank(d.producerWebsite)),
          commentaire: Value(_blank(d.producerComment)),
        ),
      );
      return existing.id;
    }
    final id = _uuid.v4();
    await _db
        .into(_db.producers)
        .insert(
          ProducersCompanion.insert(
            id: id,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            nom: name,
            siteOfficiel: Value(_blank(d.producerWebsite)),
            commentaire: Value(_blank(d.producerComment)),
          ),
        );
    return id;
  }

  Future<String> _cuveeFor(
    WineDraft d,
    String producerId,
    String cellarId,
  ) async {
    final name = _blank(d.cuvee);
    final candidates =
        await (_db.select(_db.cuvees)..where(
              (c) =>
                  c.domaineId.equals(producerId) &
                  c.couleur.equals(d.color) &
                  c.deletedAt.isNull(),
            ))
            .get();
    for (final c in candidates) {
      if (c.nom == name && c.appellation == d.appellation) return c.id;
    }
    final id = _uuid.v4();
    await _db
        .into(_db.cuvees)
        .insert(
          CuveesCompanion.insert(
            id: id,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            domaineId: producerId,
            pays: d.country,
            couleur: d.color,
          ).copyWith(
            nom: _cuveeCompanion(d, producerId).nom,
            region: Value(d.region),
            sousRegion: Value(d.subRegion),
            appellation: Value(d.appellation),
            signeQualite: Value(d.qualitySign),
            classement: Value(d.classification),
            lieuDit: Value(_blank(d.lieuDit)),
            typeVin: Value(d.wineType),
            certification: Value(d.certification),
          ),
        );
    return id;
  }

  CuveesCompanion _cuveeCompanion(WineDraft d, String producerId) =>
      CuveesCompanion(
        updatedAt: Value(_now),
        domaineId: Value(producerId),
        nom: Value(_blank(d.cuvee)),
        pays: Value(d.country),
        region: Value(d.region),
        sousRegion: Value(d.subRegion),
        appellation: Value(d.appellation),
        signeQualite: Value(d.qualitySign),
        classement: Value(d.classification),
        lieuDit: Value(_blank(d.lieuDit)),
        couleur: Value(d.color),
        typeVin: Value(d.wineType),
        certification: Value(d.certification),
      );

  /// Fiche existante avec le même domaine, la même cuvée et le même
  /// millésime (contrôle de doublon non bloquant du dictionnaire).
  Future<String?> findDuplicate(WineDraft d) async {
    for (final w in await wineItems()) {
      if (normalizeSearch(w.producer) == normalizeSearch(d.producer) &&
          normalizeSearch(w.cuvee ?? '') == normalizeSearch(d.cuvee ?? '') &&
          w.vintage == d.vintage.trim()) {
        return w.id;
      }
    }
    return null;
  }

  static String? _blank(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  static String? _grapesJson(List<GrapeShare> grapes) =>
      grapes.isEmpty ? null : jsonEncode([for (final g in grapes) g.toJson()]);

  static String? _pairingsJson(List<String> pairings) =>
      pairings.isEmpty ? null : jsonEncode(pairings);
}

class _Context {
  _Context(this.labels, this.owners, this.locations);

  final Map<String, String> labels;
  final Map<String, Owner> owners;
  final Map<String, StorageLocation> locations;

  String? label(String list, String? code) =>
      code == null ? null : labels['$list:$code'] ?? code;

  /// L'emplacement et tous ses parents (au plus 4 niveaux, EMP-01).
  Iterable<String> ancestors(String id) sync* {
    String? current = id;
    var guard = 0;
    while (current != null && guard++ < 8) {
      yield current;
      current = locations[current]?.parentId;
    }
  }

  String path(String id) =>
      ancestors(id)
          .map((i) => locations[i]?.nom ?? '')
          .toList()
          .reversed
          .join(' > ');
}
