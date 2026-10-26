import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enrichment.dart';
import '../../domain/garde_rules.dart';
import '../../domain/wine_detail.dart';
import '../../domain/wine_query.dart' show normalizeSearch;
import '../cellar_repository.dart';
import '../db/app_database.dart';
import '../files/photo_service.dart';
import '../reference_repository.dart';
import 'enrichment_queue.dart';

/// Choix de l'utilisateur sur un champ proposé (AJO-06, PRV-R2).
enum DecisionKind { accept, modify, reject }

class FieldDecision {
  const FieldDecision.accept() : kind = DecisionKind.accept, value = null;
  const FieldDecision.reject() : kind = DecisionKind.reject, value = null;
  const FieldDecision.modify(this.value) : kind = DecisionKind.modify;

  final DecisionKind kind;

  /// Valeur corrigée, au format du contrat (texte, nombre, liste...).
  final Object? value;
}

/// Ce que la validation a produit.
class ValidationOutcome {
  const ValidationOutcome({required this.wineId, this.mergedInto});

  final String wineId;

  /// AJO-07 : fiche existante qui a reçu les lots, si l'utilisateur l'a choisi.
  final String? mergedInto;
}

/// Création des fiches « à enrichir » et application de la validation.
class ValidationService {
  ValidationService(
    this._db, {
    required this.cellar,
    required this.reference,
    required this.rules,
    this.photos,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final CellarRepository cellar;
  final ReferenceRepository reference;

  /// Règles de garde embarquées (T6).
  final List<GardeRule> rules;

  /// AJO-13 : purge des photos d'origine après validation.
  final PhotoService? photos;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();
  String get _today => _clock().toIso8601String().substring(0, 10);

  /// AJO-03 : la fiche est enregistrée tout de suite en `a_enrichir`, avant
  /// toute réponse du flux. Domaine vide et millésime « NM » tant que rien
  /// n'est identifié (l'écran affiche « Vin à identifier »).
  Future<String> createPhotoWine({
    required String cellarId,
    String? vintageHint,
    String? ean,
  }) => _db.transaction(() async {
    final producerId = _uuid.v4();
    final cuveeId = _uuid.v4();
    final wineId = _uuid.v4();
    await _db
        .into(_db.producers)
        .insert(
          ProducersCompanion.insert(
            id: producerId,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            nom: '',
          ),
        );
    await _db
        .into(_db.cuvees)
        .insert(
          CuveesCompanion.insert(
            id: cuveeId,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            domaineId: producerId,
            pays: '',
            couleur: 'autre',
          ),
        );
    await _db
        .into(_db.wines)
        .insert(
          WinesCompanion.insert(
            id: wineId,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            cuveeId: cuveeId,
            millesime: vintageHint ?? 'NM',
          ).copyWith(
            ean: Value(ean),
            statutEnrichissement: const Value(WineStatus.toEnrich),
          ),
        );
    return wineId;
  });

  /// Code d'une valeur de liste à partir du libellé proposé par l'agent.
  /// Une valeur absente est ajoutée à la liste (comme FIC-02).
  Future<String?> _code(
    String list,
    String? label,
    String cellarId, {
    String? parent,
  }) async {
    if (label == null || label.trim().isEmpty) return null;
    final values = await reference.values(list);
    final wanted = normalizeSearch(label);
    for (final v in values) {
      if (normalizeSearch(v.label) == wanted || v.code == label) return v.code;
    }
    return reference.addValue(
      list: list,
      cellarId: cellarId,
      label: label.trim(),
      parentCode: parent,
    );
  }

  /// AJO-06, AJO-08, PRV-R2 : applique les choix de l'utilisateur. Un champ
  /// sans décision est accepté (« tout accepter »). Un champ verrouillé
  /// (saisie manuelle) n'est jamais écrasé (règle 3).
  Future<ValidationOutcome> apply(
    String wineId,
    JobResponse response, {
    Map<String, FieldDecision> decisions = const {},
    Set<int> rejectedScores = const {},
    bool includePrices = true,
    String? mergeIntoWineId,
  }) async {
    final out = await _apply(
      wineId,
      response,
      decisions: decisions,
      rejectedScores: rejectedScores,
      includePrices: includePrices,
      mergeIntoWineId: mergeIntoWineId,
    );
    // AJO-13 : fiche validée, les photos d'origine des photos recadrées
    // sont supprimées (T87).
    await photos?.dropOriginals(out.mergedInto ?? out.wineId);
    return out;
  }

  Future<ValidationOutcome> _apply(
    String wineId,
    JobResponse response, {
    required Map<String, FieldDecision> decisions,
    required Set<int> rejectedScores,
    required bool includePrices,
    required String? mergeIntoWineId,
  }) async {
    final result = response.result ?? const EnrichmentResult(fields: {});
    final detail = (await cellar.wine(wineId))!;
    final wine = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(wineId))).getSingle();
    final cellarId = wine.caveId;
    final locked = await _locked(wineId);
    final d = detail.draft;

    // Verrouillé : valeur actuelle. Corrigé : valeur saisie. Rejeté : valeur
    // actuelle. Sinon : valeur proposée, ou valeur actuelle si rien n'est
    // proposé.
    Object? pick(String field) {
      final current = _current(d, field);
      if (locked.contains(field)) return current;
      final decision = decisions[field];
      if (decision?.kind == DecisionKind.modify) return decision!.value;
      if (decision?.kind == DecisionKind.reject) return current;
      return result.fields[field]?.value ?? current;
    }

    String? text(String field) {
      final v = pick(field);
      return v == null ? null : '$v';
    }

    // Origine : libellés du flux convertis en codes, du pays à l'appellation.
    final country = await _code('pays', text('pays'), cellarId) ?? d.country;
    final region = await _code(
      'region',
      text('region'),
      cellarId,
      parent: country,
    );
    final subRegion = await _code(
      'sous_region',
      text('sous_region'),
      cellarId,
      parent: region,
    );
    final appellation = await _code(
      'appellation',
      text('appellation'),
      cellarId,
      parent: subRegion ?? region,
    );
    final color = await _code('couleur', text('couleur'), cellarId) ?? d.color;

    final grapesValue = pick('cepages');
    final grapes = <GrapeShare>[];
    if (grapesValue is List) {
      for (final g in grapesValue) {
        if (g is GrapeShare) {
          grapes.add(g);
          continue;
        }
        if (g is String) {
          final code = await _code('cepage', g, cellarId);
          if (code != null) grapes.add(GrapeShare(code));
          continue;
        }
        final m = g as Map;
        final code = await _code('cepage', '${m['cepage']}', cellarId);
        if (code != null) {
          grapes.add(GrapeShare(code, (m['pourcentage'] as num?)?.toInt()));
        }
      }
    }
    final pairingsValue = pick('accords');
    final pairings = <String>[];
    if (pairingsValue is List) {
      for (final a in pairingsValue) {
        final code = await _code('accord_mets', '$a', cellarId);
        if (code != null && !pairings.contains(code)) pairings.add(code);
      }
    }

    final vintageValue = pick('millesime');
    final vintage = vintageValue == null ? d.vintage : '$vintageValue';

    // Garde : fenêtre d'un critique ou du domaine, sinon règles locales (T6).
    int? gStart = d.gardeStart, gPeak = d.gardePeak, gEnd = d.gardeEnd;
    String? gSource = detail.gardeSource;
    final garde = pick('garde');
    if (garde is Map && !locked.contains('garde')) {
      gStart = (garde['debut'] as num?)?.toInt();
      gPeak = (garde['apogee'] as num?)?.toInt();
      gEnd = (garde['fin'] as num?)?.toInt();
      gSource = decisions['garde']?.kind == DecisionKind.modify
          ? 'manuel'
          : result.fields['garde']?.source;
    }

    final labels = await reference.watchLabels().first;
    final draft = WineDraft(
      producer: text('domaine') ?? d.producer,
      producerWebsite: text('domaine_site_officiel'),
      producerComment: text('commentaire_domaine'),
      cuvee: text('cuvee'),
      country: country,
      region: region,
      subRegion: subRegion,
      appellation: appellation,
      qualitySign: await _code(
        'signe_qualite',
        text('signe_qualite'),
        cellarId,
      ),
      classification: await _code('classement', text('classement'), cellarId),
      lieuDit: text('lieu_dit'),
      color: color,
      wineType: await _code('type_vin', text('type'), cellarId),
      certification: await _code(
        'certification',
        text('certification'),
        cellarId,
      ),
      vintage: vintage,
      grapes: grapes,
      alcohol: (pick('degre') as num?)?.toDouble() ?? d.alcohol,
      vintageComment: text('commentaire_millesime'),
      gardeStart: gStart,
      gardePeak: gPeak,
      gardeEnd: gEnd,
      pairings: pairings,
      ean: d.ean,
      lwin: text('lwin'),
      personalComment: d.personalComment,
      favorite: d.favorite,
    );

    if (gStart == null || gEnd == null) {
      final purchase = detail.lots
          .map((l) => int.tryParse((l.purchaseDate ?? '').split('-').first))
          .whereType<int>()
          .firstOrNull;
      final estimate = estimateGarde(
        rules,
        GardeInput(
          color: draft.color,
          vintage: draft.vintage,
          classification: labels['classement:${draft.classification}'],
          region: labels['region:${draft.region}'],
          appellation: labels['appellation:${draft.appellation}'],
          purchaseYear: purchase ?? _clock().year,
        ),
      );
      if (estimate != null) {
        gStart = estimate.start;
        gPeak = estimate.peak;
        gEnd = estimate.end;
        gSource = 'estimation';
      }
    }
    final finalDraft = WineDraft(
      producer: draft.producer,
      producerWebsite: draft.producerWebsite,
      producerComment: draft.producerComment,
      cuvee: draft.cuvee,
      country: draft.country,
      region: draft.region,
      subRegion: draft.subRegion,
      appellation: draft.appellation,
      qualitySign: draft.qualitySign,
      classification: draft.classification,
      lieuDit: draft.lieuDit,
      color: draft.color,
      wineType: draft.wineType,
      certification: draft.certification,
      vintage: draft.vintage,
      grapes: draft.grapes,
      alcohol: draft.alcohol,
      vintageComment: draft.vintageComment,
      gardeStart: gStart,
      gardePeak: gPeak,
      gardeEnd: gEnd,
      pairings: draft.pairings,
      ean: draft.ean,
      lwin: draft.lwin,
      personalComment: draft.personalComment,
      favorite: draft.favorite,
    );

    return _db.transaction(() async {
      final oldProducer = detail.producerId;
      await cellar.updateWine(wineId, finalDraft);
      await (_db.update(_db.wines)..where((w) => w.id.equals(wineId))).write(
        WinesCompanion(
          gardeSource: Value(gSource),
          statutEnrichissement: const Value(WineStatus.valid),
          updatedAt: Value(_now),
        ),
      );
      await _cleanupPlaceholder(oldProducer);
      await _settleProvenances(wineId, decisions, locked);

      // Notes critiques acceptées (NOT-R3 : le site qui cite est conservé).
      for (final (i, s) in result.scores.indexed) {
        if (rejectedScores.contains(i)) continue;
        await _db
            .into(_db.criticScores)
            .insert(
              CriticScoresCompanion.insert(
                id: _uuid.v4(),
                caveId: cellarId,
                createdAt: _now,
                updatedAt: _now,
                ficheId: wineId,
                critique: s.critic,
                note: s.score,
                echelle: s.scale,
              ).copyWith(
                degustateur: Value(s.taster),
                dateNote: Value(s.date),
                fenetreDebut: Value(s.windowStart),
                fenetreFin: Value(s.windowEnd),
                url: Value(s.url),
                citeePar: Value(s.citedBy),
              ),
            );
      }
      // Prix : historique, jamais écrasé ; « non trouvé » enregistré aussi.
      if (includePrices) {
        for (final p in result.prices) {
          await _db
              .into(_db.marketPrices)
              .insert(
                MarketPricesCompanion.insert(
                  id: _uuid.v4(),
                  caveId: cellarId,
                  createdAt: _now,
                  updatedAt: _now,
                  ficheId: wineId,
                  formatCl: p.formatCl,
                  dateReleve: p.date,
                  devise: p.currency,
                  trouve: p.found,
                ).copyWith(
                  prix: Value(p.price),
                  nature: Value(p.nature),
                  nbOffres: Value(p.offerCount),
                  site: Value(p.site ?? p.offers.firstOrNull?.site),
                  url: Value(p.url ?? p.offers.firstOrNull?.url),
                ),
              );
        }
      }

      if (mergeIntoWineId != null && mergeIntoWineId != wineId) {
        await _mergeInto(wineId, mergeIntoWineId);
        return ValidationOutcome(wineId: wineId, mergedInto: mergeIntoWineId);
      }
      return ValidationOutcome(wineId: wineId);
    });
  }

  Future<Set<String>> _locked(String wineId) async {
    final rows =
        await (_db.select(_db.provenances)..where(
              (p) =>
                  p.entite.equals('fiche_vin') &
                  p.entiteId.equals(wineId) &
                  p.statut.isIn(['manuel', 'verrouille']) &
                  p.deletedAt.isNull(),
            ))
            .get();
    return {for (final r in rows) r.champ};
  }

  /// PRV-R2 : accepté → `valide`, corrigé → `manuel` (verrouillé pour les
  /// ré-enrichissements), rejeté → `rejete`.
  Future<void> _settleProvenances(
    String wineId,
    Map<String, FieldDecision> decisions,
    Set<String> locked,
  ) async {
    final open =
        await (_db.select(_db.provenances)..where(
              (p) =>
                  p.entite.equals('fiche_vin') &
                  p.entiteId.equals(wineId) &
                  p.statut.equals('propose') &
                  p.deletedAt.isNull(),
            ))
            .get();
    for (final p in open) {
      final status = locked.contains(p.champ)
          ? 'rejete'
          : switch (decisions[p.champ]?.kind ?? DecisionKind.accept) {
              DecisionKind.accept => 'valide',
              DecisionKind.modify => 'manuel',
              DecisionKind.reject => 'rejete',
            };
      await (_db.update(
        _db.provenances,
      )..where((x) => x.id.equals(p.id))).write(
        ProvenancesCompanion(statut: Value(status), updatedAt: Value(_now)),
      );
    }
    // Un champ corrigé sans proposition reste tracé comme saisie manuelle.
    for (final e in decisions.entries) {
      if (e.value.kind != DecisionKind.modify) continue;
      if (open.any((p) => p.champ == e.key)) {
        await (_db.update(_db.provenances)..where(
              (p) =>
                  p.entiteId.equals(wineId) &
                  p.champ.equals(e.key) &
                  p.statut.equals('manuel'),
            ))
            .write(
              ProvenancesCompanion(valeur: Value(jsonEncode(e.value.value))),
            );
        continue;
      }
      await _db
          .into(_db.provenances)
          .insert(
            ProvenancesCompanion.insert(
              id: _uuid.v4(),
              caveId: (await (_db.select(
                _db.wines,
              )..where((w) => w.id.equals(wineId))).getSingle()).caveId,
              createdAt: _now,
              updatedAt: _now,
              entite: 'fiche_vin',
              entiteId: wineId,
              champ: e.key,
              source: 'manuel',
              dateCollecte: _today,
              statut: 'manuel',
            ).copyWith(valeur: Value(jsonEncode(e.value.value))),
          );
    }
  }

  /// Le domaine provisoire (nom vide) disparaît s'il n'est plus utilisé.
  Future<void> _cleanupPlaceholder(String producerId) async {
    final p = await (_db.select(
      _db.producers,
    )..where((x) => x.id.equals(producerId))).getSingleOrNull();
    if (p == null || p.nom.isNotEmpty) return;
    final used =
        await (_db.select(_db.cuvees)..where(
              (c) => c.domaineId.equals(producerId) & c.deletedAt.isNull(),
            ))
            .get();
    if (used.isEmpty) {
      await (_db.update(_db.producers)..where((x) => x.id.equals(producerId)))
          .write(ProducersCompanion(deletedAt: Value(_now)));
    }
  }

  /// AJO-07 : la bouteille photographiée rejoint la fiche existante. Les lots
  /// (et leurs mouvements) et les photos changent de fiche ; la fiche
  /// photographiée est supprimée logiquement.
  Future<void> _mergeInto(String fromWineId, String intoWineId) async {
    await (_db.update(
      _db.stockLots,
    )..where((l) => l.ficheId.equals(fromWineId))).write(
      StockLotsCompanion(ficheId: Value(intoWineId), updatedAt: Value(_now)),
    );
    await (_db.update(
      _db.photos,
    )..where((p) => p.ficheId.equals(fromWineId))).write(
      PhotosCompanion(
        ficheId: Value(intoWineId),
        principale: const Value(false),
        updatedAt: Value(_now),
      ),
    );
    await (_db.update(_db.wines)..where((w) => w.id.equals(fromWineId))).write(
      WinesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  /// AJO-07 : fiche existante au même domaine, cuvée et millésime que la
  /// proposition (hors la fiche photographiée elle-même).
  Future<String?> duplicateOf(String wineId, JobResponse response) async {
    final f = response.result?.fields ?? const {};
    final producer = f['domaine']?.value;
    if (producer == null) return null;
    for (final w in await cellar.wineItems()) {
      if (w.id == wineId) continue;
      if (normalizeSearch(w.producer) == normalizeSearch('$producer') &&
          normalizeSearch(w.cuvee ?? '') ==
              normalizeSearch('${f['cuvee']?.value ?? ''}') &&
          w.vintage == '${f['millesime']?.value ?? ''}') {
        return w.id;
      }
    }
    return null;
  }

  static Object? _current(WineDraft d, String field) => switch (field) {
    'domaine' => d.producer.isEmpty ? null : d.producer,
    'domaine_site_officiel' => d.producerWebsite,
    'commentaire_domaine' => d.producerComment,
    'cuvee' => d.cuvee,
    'lieu_dit' => d.lieuDit,
    'millesime' => d.vintage == 'NM' ? null : d.vintage,
    'degre' => d.alcohol,
    'commentaire_millesime' => d.vintageComment,
    'lwin' => d.lwin,
    'cepages' => d.grapes.isEmpty ? null : d.grapes,
    'accords' => d.pairings.isEmpty ? null : d.pairings,
    // Champs de listes : le code actuel, reconnu tel quel par _code.
    'pays' => d.country.isEmpty ? null : d.country,
    'region' => d.region,
    'sous_region' => d.subRegion,
    'appellation' => d.appellation,
    'signe_qualite' => d.qualitySign,
    'classement' => d.classification,
    'certification' => d.certification,
    'type' => d.wineType,
    'couleur' => d.color,
    _ => null,
  };
}
