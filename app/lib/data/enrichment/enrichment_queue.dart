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
  });

  final int sent;
  final int finished;
  final int failed;

  /// Le flux était injoignable : les jobs restants repartiront plus tard.
  final bool offline;
  final int? enrichmentsLeft;
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
              typeJob: 'enrichissement',
              requestId: _uuid.v4(),
              statut: JobStatus.pending.code,
            ).copyWith(tentatives: const Value(0)),
          );
      await _setWineStatus(wineId, WineStatus.toEnrich);
    });
    return id;
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
            ..where((j) => j.ficheId.equals(wineId) & j.deletedAt.isNull())
            ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Stream<Job?> watchLatestJob(String wineId) =>
      (_db.select(_db.jobs)
            ..where((j) => j.ficheId.equals(wineId) & j.deletedAt.isNull())
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
    await _setWineStatus(job.ficheId, WineStatus.error);
  }

  /// Traite tous les jobs en attente. À appeler au retour du réseau et à
  /// intervalle régulier pendant qu'un job tourne ([pollDelay]).
  Future<QueueReport> process() async {
    var sent = 0, finished = 0, failed = 0;
    int? left;
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
          r = await gateway.requestEnrichment(await _request(job));
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
        if (await _apply(job, r)) finished++;
        if (r.status == JobStatus.error) failed++;
      } on OfflineException {
        // La fiche reste à enrichir ; on réessaiera au retour du réseau.
        return QueueReport(
          sent: sent,
          finished: finished,
          failed: failed,
          offline: true,
          enrichmentsLeft: left,
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
