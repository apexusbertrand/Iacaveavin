import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enrichment.dart';
import '../db/app_database.dart';
import '../files/photo_service.dart';
import 'contract_validator.dart';
import 'enrichment_gateway.dart';

/// Délai maximal d'un job (docs/02 : 3 min au plus).
const jobTimeout = Duration(minutes: 3);

/// Rythme de suivi : toutes les 3 s pendant 30 s, puis toutes les 10 s.
Duration pollDelay(Duration sinceSent) =>
    sinceSent < const Duration(seconds: 30)
    ? const Duration(seconds: 3)
    : const Duration(seconds: 10);

/// PRX-03 : un relevé par fiche et par 24 heures, sauf « forcer ».
const priceMinInterval = Duration(hours: 24);

/// PRX-06 : rafraîchissement automatique mensuel.
const autoPriceInterval = Duration(days: 30);

/// PRX-06 : vrai si le rafraîchissement mensuel doit partir maintenant.
bool autoPriceRefreshDue({
  required bool enabled,
  required DateTime? last,
  required DateTime now,
}) => enabled && (last == null || now.difference(last) >= autoPriceInterval);

/// Types de job du dictionnaire (job.type_job).
abstract final class JobType {
  static const enrichment = 'enrichissement';
  static const price = 'prix';
}

/// Issue d'une demande de relevé de prix.
enum PriceEnqueue {
  queued,

  /// Relevé de moins de 24 heures : il faut « forcer » (PRX-03).
  tooRecent,

  /// Un relevé est déjà en file pour cette fiche.
  alreadyQueued,
}

/// Statuts de fiche du dictionnaire (statut_enrichissement).
abstract final class WineStatus {
  static const toEnrich = 'a_enrichir';
  static const running = 'en_cours';
  static const toValidate = 'a_valider';
  static const valid = 'valide';
  static const error = 'erreur';
}

class QueueReport {
  const QueueReport({
    required this.sent,
    required this.finished,
    required this.failed,
    required this.offline,
    this.enrichmentsLeft,
    this.pricesLeft,
  });

  final int sent;
  final int finished;
  final int failed;

  /// Le flux était injoignable : les jobs restants repartiront plus tard.
  final bool offline;
  final int? enrichmentsLeft;

  /// Quota de relevés de prix restant ce mois, d'après la dernière réponse.
  final int? pricesLeft;
}

/// File d'attente des enrichissements (AJO-09, NFR-03).
///
/// Un job naît `en_attente` quand les photos sont prises, même hors ligne.
/// [process] l'envoie dès que le flux répond, suit son avancement, valide
/// chaque réponse (AJO-12) et range le résultat pour l'écran de validation.
class EnrichmentQueue {
  EnrichmentQueue(
    this._db, {
    required this.gateway,
    required this.photos,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final EnrichmentGateway gateway;
  final PhotoService photos;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();

  /// Crée le job d'une fiche. Le request_id sert à l'idempotence.
  Future<String> enqueue(String wineId) async {
    final wine = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(wineId))).getSingle();
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.jobs)
          .insert(
            JobsCompanion.insert(
              id: id,
              caveId: wine.caveId,
              createdAt: _now,
              updatedAt: _now,
              ficheId: wineId,
              typeJob: JobType.enrichment,
              requestId: _uuid.v4(),
              statut: JobStatus.pending.code,
            ).copyWith(tentatives: const Value(0)),
          );
      await _setWineStatus(wineId, WineStatus.toEnrich);
    });
    return id;
  }

  /// PRX-02, PRX-03 : met en file le relevé du prix marché d'une fiche.
  Future<PriceEnqueue> enqueuePrice(String wineId, {bool force = false}) async {
    final pending =
        await (_db.select(_db.jobs)..where(
              (j) =>
                  j.ficheId.equals(wineId) &
                  j.typeJob.equals(JobType.price) &
                  j.statut.isIn([
                    JobStatus.pending.code,
                    JobStatus.running.code,
                  ]) &
                  j.deletedAt.isNull(),
            ))
            .get();
    if (pending.isNotEmpty) return PriceEnqueue.alreadyQueued;
    if (!force && await priceIsRecent(wineId)) return PriceEnqueue.tooRecent;
    final wine = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(wineId))).getSingle();
    await _db
        .into(_db.jobs)
        .insert(
          JobsCompanion.insert(
            id: _uuid.v4(),
            caveId: wine.caveId,
            createdAt: _now,
            updatedAt: _now,
            ficheId: wineId,
            typeJob: JobType.price,
            requestId: _uuid.v4(),
            statut: JobStatus.pending.code,
          ).copyWith(tentatives: const Value(0)),
        );
    return PriceEnqueue.queued;
  }

  /// Vrai si la fiche a un relevé de moins de 24 heures (PRX-03).
  Future<bool> priceIsRecent(String wineId) async {
    final last =
        await (_db.select(_db.marketPrices)
              ..where((p) => p.ficheId.equals(wineId) & p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return last != null && _now.difference(last.createdAt) < priceMinInterval;
  }

  /// Fiches dont le prix peut être relevé (avec domaine et millésime).
  Future<List<String>> priceableWines() async {
    final rows = await (_db.select(
      _db.wines,
    )..where((w) => w.deletedAt.isNull())).get();
    return [for (final w in rows) w.id];
  }

  /// PRX-02 « toute la cave » et PRX-06 : met en file toutes les fiches sans
  /// relevé récent. Renvoie le nombre de relevés ajoutés.
  Future<int> enqueueAllPrices({List<String>? wineIds}) async {
    var n = 0;
    for (final id in wineIds ?? await priceableWines()) {
      if (await enqueuePrice(id) == PriceEnqueue.queued) n++;
    }
    return n;
  }

  /// Nombre de relevés qu'un « toute la cave » enverrait (PRX-02).
  Future<int> countPricesToRefresh({List<String>? wineIds}) async {
    var n = 0;
    for (final id in wineIds ?? await priceableWines()) {
      if (!await priceIsRecent(id)) n++;
    }
    return n;
  }

  Future<void> _setWineStatus(String wineId, String status) =>
      (_db.update(_db.wines)..where((w) => w.id.equals(wineId))).write(
        WinesCompanion(
          statutEnrichissement: Value(status),
          updatedAt: Value(_now),
        ),
      );

  /// Jobs pas encore terminés (compteur visible, NFR-03).
  Stream<int> watchPendingCount() {
    final count = _db.jobs.id.count();
    final query = _db.selectOnly(_db.jobs)
      ..addColumns([count])
      ..where(
        _db.jobs.statut.isIn([JobStatus.pending.code, JobStatus.running.code]) &
            _db.jobs.deletedAt.isNull(),
      );
    return query.map((r) => r.read(count) ?? 0).watchSingle();
  }

  Future<List<Job>> pendingJobs() =>
      (_db.select(_db.jobs)
            ..where(
              (j) =>
                  j.statut.isIn([
                    JobStatus.pending.code,
                    JobStatus.running.code,
                  ]) &
                  j.deletedAt.isNull(),
            )
            ..orderBy([(j) => OrderingTerm.asc(j.createdAt)]))
          .get();

  Future<Job?> latestJobFor(String wineId) =>
      (_db.select(_db.jobs)
            ..where(
              (j) =>
                  j.ficheId.equals(wineId) &
                  j.typeJob.equals(JobType.enrichment) &
                  j.deletedAt.isNull(),
            )
            ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Stream<Job?> watchLatestJob(String wineId) =>
      (_db.select(_db.jobs)
            ..where(
              (j) =>
                  j.ficheId.equals(wineId) &
                  j.typeJob.equals(JobType.enrichment) &
                  j.deletedAt.isNull(),
            )
            ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
            ..limit(1))
          .watchSingleOrNull();

  /// PRV-R2 : champs saisis à la main, transmis comme verrouillés (noms du
  /// contrat).
  Future<List<String>> lockedFields(String wineId) async {
    final rows =
        await (_db.select(_db.provenances)..where(
              (p) =>
                  p.statut.isIn(['manuel', 'verrouille']) &
                  p.deletedAt.isNull() &
                  p.entite.equals('fiche_vin') &
                  p.entiteId.equals(wineId),
            ))
            .get();
    return {for (final r in rows) r.champ}.toList();
  }

  Future<EnrichmentRequest> _request(Job job) async {
    final wine = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(job.ficheId))).getSingle();
    final lot =
        await (_db.select(_db.stockLots)
              ..where((l) => l.ficheId.equals(job.ficheId))
              ..limit(1))
            .getSingleOrNull();
    final year = int.tryParse(wine.millesime);
    return EnrichmentRequest(
      requestId: job.requestId,
      wineId: job.ficheId,
      photos: [
        for (final ph in await photos.forRequest(job.ficheId))
          RequestPhoto(index: ph.index, type: ph.type, base64: ph.base64),
      ],
      ean: wine.ean,
      vintageHint: year ?? (wine.millesime == 'NM' ? null : wine.millesime),
      formatCl: lot?.formatCl,
      lockedFields: await lockedFields(job.ficheId),
      clientDate: _clock().toIso8601String().substring(0, 10),
    );
  }

  static const _colours = {
    'rouge',
    'blanc',
    'rose',
    'champagne',
    'effervescent',
    'liquoreux',
    'orange',
    'autre',
  };

  Future<PriceRequest> _priceRequest(Job job, String currency) async {
    final wine = await (_db.select(
      _db.wines,
    )..where((w) => w.id.equals(job.ficheId))).getSingle();
    final cuvee = await (_db.select(
      _db.cuvees,
    )..where((c) => c.id.equals(wine.cuveeId))).getSingle();
    final producer = await (_db.select(
      _db.producers,
    )..where((d) => d.id.equals(cuvee.domaineId))).getSingle();
    final lot =
        await (_db.select(_db.stockLots)
              ..where((l) => l.ficheId.equals(job.ficheId))
              ..limit(1))
            .getSingleOrNull();
    // Un relevé en file alors qu'un autre a moins de 24 h a été forcé.
    final forced = await priceIsRecent(job.ficheId);
    // L'appellation est rangée en code de liste : le flux attend le libellé.
    final appellation = cuvee.appellation == null
        ? null
        : (await (_db.select(_db.listValues)
                        ..where(
                          (v) =>
                              v.liste.equals('appellation') &
                              v.code.equals(cuvee.appellation!) &
                              v.deletedAt.isNull(),
                        )
                        ..limit(1))
                      .getSingleOrNull())
                  ?.libelle ??
              cuvee.appellation;
    return PriceRequest(
      requestId: job.requestId,
      wineId: job.ficheId,
      domain: producer.nom,
      cuvee: cuvee.nom,
      appellation: appellation,
      vintage: int.tryParse(wine.millesime) ?? 'NM',
      colour: _colours.contains(cuvee.couleur) ? cuvee.couleur : 'autre',
      formatCl: lot?.formatCl ?? 75,
      currency: currency,
      lwin: wine.lwin,
      ean: wine.ean,
      force: forced,
      clientDate: _clock().toIso8601String().substring(0, 10),
    );
  }

  Future<void> _update(Job job, JobsCompanion values) =>
      (_db.update(_db.jobs)..where((j) => j.id.equals(job.id))).write(
        values.copyWith(updatedAt: Value(_now)),
      );

  Future<void> _fail(Job job, String message) async {
    await _update(
      job,
      JobsCompanion(
        statut: Value(JobStatus.error.code),
        erreur: Value(message),
      ),
    );
    if (job.typeJob != JobType.price) {
      await _setWineStatus(job.ficheId, WineStatus.error);
    }
  }

  /// Traite tous les jobs en attente. À appeler au retour du réseau et à
  /// intervalle régulier pendant qu'un job tourne ([pollDelay]).
  Future<QueueReport> process({String currency = 'EUR'}) async {
    var sent = 0, finished = 0, failed = 0;
    int? left, pricesLeft;
    for (final job in await pendingJobs()) {
      // AJO-09 : sans réponse finale en 3 minutes, le job passe en erreur.
      final sentAt = job.envoyeLe == null
          ? null
          : DateTime.parse(job.envoyeLe!);
      if (sentAt != null && _now.difference(sentAt) > jobTimeout) {
        await _fail(job, 'delai_depasse');
        failed++;
        continue;
      }
      try {
        final JobResponse r;
        if (job.jobIdDistant == null) {
          r = job.typeJob == JobType.price
              ? await gateway.requestPrice(await _priceRequest(job, currency))
              : await gateway.requestEnrichment(await _request(job));
          sent++;
          await _update(
            job,
            JobsCompanion(
              jobIdDistant: Value(r.jobId),
              envoyeLe: Value(_now.toIso8601String()),
              tentatives: Value((job.tentatives ?? 0) + 1),
            ),
          );
        } else {
          r = await gateway.followJob(job.jobIdDistant!);
        }
        left = r.enrichmentsLeft ?? left;
        pricesLeft = r.pricesLeft ?? pricesLeft;
        if (job.typeJob == JobType.price
            ? await _applyPrice(job, r)
            : await _apply(job, r)) {
          finished++;
        }
        if (r.status == JobStatus.error) failed++;
      } on OfflineException {
        // La fiche reste à enrichir ; on réessaiera au retour du réseau.
        return QueueReport(
          sent: sent,
          finished: finished,
          failed: failed,
          offline: true,
          enrichmentsLeft: left,
          pricesLeft: pricesLeft,
        );
      } on ContractException catch (e) {
        // AJO-12 : réponse hors contrat = erreur journalisée, fiche éditable.
        await _fail(job, 'reponse_invalide : ${e.errors.take(3).join(' ; ')}');
        failed++;
      }
    }
    return QueueReport(
      sent: sent,
      finished: finished,
      failed: failed,
      offline: false,
      enrichmentsLeft: left,
      pricesLeft: pricesLeft,
    );
  }

  /// Range une réponse validée. Renvoie vrai si le résultat est prêt à être
  /// validé par l'utilisateur.
  Future<bool> _apply(Job job, JobResponse r) async {
    switch (r.status) {
      case JobStatus.pending || JobStatus.running:
        // La dernière réponse garde l'étape en cours (AJO-05) et le quota.
        await _update(
          job,
          JobsCompanion(
            statut: Value(JobStatus.running.code),
            reponse: Value(jsonEncode(r.raw)),
          ),
        );
        await _setWineStatus(job.ficheId, WineStatus.running);
        return false;
      case JobStatus.error:
        await _fail(job, r.error?.message ?? 'erreur');
        return false;
      case JobStatus.done || JobStatus.partial:
        // AJO-13 : rognage sur l'étiquette avant d'annoncer le résultat, pour
        // que l'écran de validation montre déjà les photos rognées. Un échec
        // laisse la photo entière sans bloquer la validation.
        try {
          await photos.applyFrames(job.ficheId, r.result?.frames ?? const []);
        } on Object {
          // Photo illisible ou absente : rien à rogner.
        }
        await _db.transaction(() async {
          await _update(
            job,
            JobsCompanion(
              statut: Value(r.status.code),
              reponse: Value(jsonEncode(r.raw)),
            ),
          );
          await _propose(job, r.result);
          await _setWineStatus(job.ficheId, WineStatus.toValidate);
        });
        return true;
    }
  }

  /// PRX-03, PRX-04 : un relevé terminé ajoute une ligne d'historique par
  /// format, « non trouvé » compris ; rien n'est écrasé ni estimé.
  Future<bool> _applyPrice(Job job, JobResponse r) async {
    switch (r.status) {
      case JobStatus.pending || JobStatus.running:
        await _update(
          job,
          JobsCompanion(
            statut: Value(JobStatus.running.code),
            reponse: Value(jsonEncode(r.raw)),
          ),
        );
        return false;
      case JobStatus.error:
        await _fail(job, r.error?.message ?? 'erreur');
        return false;
      case JobStatus.done || JobStatus.partial:
        // AJO-13 : rognage sur l'étiquette avant d'annoncer le résultat, pour
        // que l'écran de validation montre déjà les photos rognées. Un échec
        // laisse la photo entière sans bloquer la validation.
        try {
          await photos.applyFrames(job.ficheId, r.result?.frames ?? const []);
        } on Object {
          // Photo illisible ou absente : rien à rogner.
        }
        await _db.transaction(() async {
          await _update(
            job,
            JobsCompanion(
              statut: Value(r.status.code),
              reponse: Value(jsonEncode(r.raw)),
            ),
          );
          for (final p in r.prices) {
            await _db
                .into(_db.marketPrices)
                .insert(
                  MarketPricesCompanion.insert(
                    id: _uuid.v4(),
                    caveId: job.caveId,
                    createdAt: _now,
                    updatedAt: _now,
                    ficheId: job.ficheId,
                    formatCl: p.formatCl,
                    dateReleve: p.date,
                    devise: p.currency,
                    trouve: p.found && p.price != null,
                  ).copyWith(
                    prix: Value(p.found ? p.price : null),
                    nature: Value(p.found ? p.nature : null),
                    nbOffres: Value(p.found ? p.offerCount : 0),
                    site: Value(p.site ?? p.offers.firstOrNull?.site),
                    url: Value(p.url ?? p.offers.firstOrNull?.url),
                  ),
                );
          }
        });
        return true;
    }
  }

  /// XLS-09 : dernier quota d'enrichissements connu.
  Future<int?> lastKnownEnrichmentsLeft() async {
    final rows =
        await (_db.select(_db.jobs)
              ..where(
                (j) =>
                    j.reponse.isNotNull() &
                    j.typeJob.equals(JobType.enrichment),
              )
              ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : lastResponse(rows.first)?.enrichmentsLeft;
  }

  /// Dernier quota de prix connu, d'après la réponse la plus récente.
  Future<int?> lastKnownPricesLeft() async {
    final rows =
        await (_db.select(_db.jobs)
              ..where((j) => j.reponse.isNotNull())
              ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : lastResponse(rows.first)?.pricesLeft;
  }

  /// PRV-R1 : toute valeur proposée par l'agent crée une ligne de provenance
  /// au statut `propose`. Les propositions précédentes encore ouvertes sont
  /// remplacées.
  Future<void> _propose(Job job, EnrichmentResult? result) async {
    if (result == null) return;
    await (_db.update(_db.provenances)..where(
          (p) =>
              p.entite.equals('fiche_vin') &
              p.entiteId.equals(job.ficheId) &
              p.statut.equals('propose'),
        ))
        .write(ProvenancesCompanion(deletedAt: Value(_now)));
    final today = _clock().toIso8601String().substring(0, 10);
    for (final e in result.fields.entries) {
      final v = e.value;
      if (v.isEmpty || v.source == null) continue;
      await _db
          .into(_db.provenances)
          .insert(
            ProvenancesCompanion.insert(
              id: _uuid.v4(),
              caveId: job.caveId,
              createdAt: _now,
              updatedAt: _now,
              entite: 'fiche_vin',
              entiteId: job.ficheId,
              champ: e.key,
              source: v.source!,
              dateCollecte: today,
              statut: 'propose',
            ).copyWith(
              valeur: Value(jsonEncode(v.value)),
              url: Value(v.url),
              confiance: Value(v.confidence),
            ),
          );
    }
  }

  /// Relance d'un job en erreur (AJO-09) : nouveau request_id, le flux
  /// traite la demande comme neuve.
  Future<void> retry(String wineId) async {
    final last = await latestJobFor(wineId);
    if (last != null) {
      await _update(last, JobsCompanion(deletedAt: Value(_now)));
    }
    await enqueue(wineId);
  }

  /// Dernière réponse validée d'une fiche, si elle attend la validation.
  Future<JobResponse?> resultFor(String wineId) async {
    final r = lastResponse(await latestJobFor(wineId));
    return r != null &&
            (r.status == JobStatus.done || r.status == JobStatus.partial)
        ? r
        : null;
  }

  /// Dernière réponse enregistrée d'un job (en cours ou finale).
  static JobResponse? lastResponse(Job? job) {
    if (job?.reponse == null) return null;
    return JobResponse.fromJson(
      jsonDecode(job!.reponse!) as Map<String, dynamic>,
    );
  }
}
