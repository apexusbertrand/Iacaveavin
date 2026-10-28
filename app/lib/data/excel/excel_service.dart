import 'dart:convert';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/enrichment.dart' show contractFieldMap;
import '../../domain/excel_layout.dart';
import '../../domain/garde.dart';
import '../../domain/scores.dart';
import '../../domain/wine_detail.dart';
import '../../domain/wine_query.dart' show normalizeSearch;
import '../backup_service.dart';
import '../cellar_repository.dart';
import '../db/app_database.dart';
import '../files/photo_service.dart';
import '../files/xlsx.dart';
import '../reference_repository.dart';
import '../stock_service.dart';

/// Motif des mouvements créés par l'import (XLS-05, liste motif_mouvement).
const importReason = 'import Excel';

/// Problème trouvé par la simulation (XLS-07) : feuille, ligne Excel
/// (l'en-tête est la ligne 1), colonne et motif.
enum IssueCode {
  missingSheet,
  missingColumn,
  required,
  unknownId,
  duplicateId,
  invalidNumber,
  invalidVintage,
  outOfRange,
  gardeOrder,
  invalidEan,
  invalidBoolean,
  invalidDate,
  invalidGrapes,
  invalidAction,
  unknownValue,
  unknownLocation,
  unknownWine,
  deletedWine,
  lotWineChange,
}

class ImportIssue {
  const ImportIssue(this.sheet, this.row, this.column, this.code, [this.value]);

  final String sheet;
  final int row;
  final String column;
  final IssueCode code;
  final String? value;

  @override
  String toString() => '$sheet!$row $column ${code.name} $value';
}

/// Valeur de liste absente de l'app (XLS-06) : erreur, ou création validée en
/// bloc. [list] vaut `proprietaire` pour un propriétaire.
class UnknownValue {
  const UnknownValue(this.list, this.label, [this.parent]);

  final String list;
  final String label;

  /// Code (ou valeur à créer) du parent dans la liste hiérarchique.
  final String? parent;

  String get key => '$list|${normalizeSearch(label)}';
}

/// XLS-07 : rapport de simulation. L'import n'est possible que sans erreur.
class ImportReport {
  ImportReport({
    required this.winesCreated,
    required this.winesUpdated,
    required this.winesDeleted,
    required this.lotsCreated,
    required this.lotsUpdated,
    required this.lotsDeleted,
    required this.stockChanges,
    required this.unknown,
    required this.issues,
    required this.photosFound,
    required this.enrichable,
  });

  final int winesCreated;
  final int winesUpdated;
  final int winesDeleted;
  final int lotsCreated;
  final int lotsUpdated;
  final int lotsDeleted;

  /// Lots dont la quantité cible diffère du stock (mouvement créé).
  final int stockChanges;
  final List<UnknownValue> unknown;
  final List<ImportIssue> issues;

  /// XLS-10 : photos du zip rattachées à une fiche.
  final int photosFound;

  /// XLS-09 : fiches créées avec une photo, donc enrichissables.
  final int enrichable;

  bool get hasChanges =>
      winesCreated +
          winesUpdated +
          winesDeleted +
          lotsCreated +
          lotsUpdated +
          lotsDeleted +
          stockChanges +
          photosFound >
      0;
}

class ImportResult {
  const ImportResult({required this.report, required this.createdWines});

  final ImportReport report;

  /// Fiches créées qui ont une photo (pour XLS-09).
  final List<String> createdWines;
}

class ImportException implements Exception {
  const ImportException(this.report);

  final ImportReport report;
}

/// Simulation prête à appliquer : opérations calculées sur l'état de la base
/// au moment de la simulation.
class ImportPlan {
  ImportPlan._(
    this.report,
    this._wines,
    this._lots,
    this._photos,
    this._unknown,
  );

  final ImportReport report;
  final List<_WineOp> _wines;
  final List<_LotOp> _lots;
  final Map<String, Uint8List> _photos;
  final List<UnknownValue> _unknown;
}

/// Marque d'une valeur à créer, remplacée par son code à l'application.
String _pending(UnknownValue u) => '\u0000${u.key}';

class _WineOp {
  _WineOp(this.row, this.id, this.draft, this.changed, {this.delete = false});

  final int row;
  final String? id;
  final WineDraft? draft;

  /// Champs du contrat modifiés (provenance manuelle, rule 3).
  final Set<String> changed;
  final bool delete;
  String? photo;
}

class _LotOp {
  _LotOp(
    this.row,
    this.id,
    this.wine,
    this.draft,
    this.target, {
    this.delete = false,
    this.descriptive = true,
  });

  final int row;
  final String? id;

  /// Fiche existante, ou `#<ligne>` d'une fiche créée par cet import.
  final String? wine;
  final LotDraft? draft;

  /// Quantité cible (XLS-05) ; null : stock inchangé.
  final int? target;
  final bool delete;

  /// Faux : seuls le stock change, pas les champs du lot.
  final bool descriptive;
}

class _Snapshot {
  _Snapshot({
    required this.producers,
    required this.cuvees,
    required this.wines,
    required this.lots,
    required this.stocks,
    required this.movements,
    required this.owners,
    required this.locations,
    required this.values,
    required this.scores,
    required this.photos,
  });

  final Map<String, Producer> producers;
  final Map<String, Cuvee> cuvees;
  final Map<String, Wine> wines;
  final Map<String, StockLot> lots;
  final Map<String, int> stocks;
  final List<StockMovement> movements;
  final Map<String, Owner> owners;
  final Map<String, StorageLocation> locations;

  /// Valeurs par liste.
  final Map<String, List<ListValue>> values;
  final Map<String, List<CriticScoreValue>> scores;

  /// Photo principale par fiche.
  final Map<String, Photo> photos;

  String? label(String list, String? code) {
    if (code == null) return null;
    for (final v in values[list] ?? const <ListValue>[]) {
      if (v.code == code) return v.libelle;
    }
    return code;
  }

  String locationPath(String id) {
    final names = <String>[];
    String? current = id;
    var guard = 0;
    while (current != null && guard++ < 8) {
      names.add(locations[current]?.nom ?? '');
      current = locations[current]?.parentId;
    }
    return names.reversed.join(' > ');
  }

  String wineLabel(String wineId) {
    final f = wines[wineId];
    final c = f == null ? null : cuvees[f.cuveeId];
    final pr = c == null ? null : producers[c.domaineId];
    return [
      pr?.nom,
      c?.nom,
      f?.millesime,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
  }

  WineDraft draftOf(String wineId) {
    final f = wines[wineId]!;
    final c = cuvees[f.cuveeId]!;
    final pr = producers[c.domaineId]!;
    return WineDraft(
      producer: pr.nom,
      producerWebsite: pr.siteOfficiel,
      producerComment: pr.commentaire,
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
      grapes: f.cepages == null || f.cepages!.isEmpty
          ? const []
          : [
              for (final g in (jsonDecode(f.cepages!) as List))
                GrapeShare.fromJson(g as Map<String, dynamic>),
            ],
      alcohol: f.degre,
      vintageComment: f.commentaireMillesime,
      gardeStart: f.gardeDebut,
      gardePeak: f.gardeApogee,
      gardeEnd: f.gardeFin,
      pairings: f.accords == null || f.accords!.isEmpty
          ? const []
          : (jsonDecode(f.accords!) as List).cast<String>(),
      ean: f.ean,
      lwin: f.lwin,
      personalComment: f.commentairePerso,
      favorite: f.favori ?? false,
    );
  }
}

/// XLS-01 à XLS-10 : export, modèle vierge, simulation et import du classeur.
class ExcelService {
  ExcelService(
    this._db, {
    required this.cellar,
    required this.stock,
    required this.reference,
    required this.backup,
    required this.photos,
    required this.year,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final CellarRepository cellar;
  final StockService stock;
  final ReferenceRepository reference;
  final BackupService? backup;
  final PhotoService? photos;

  /// Année en cours (statut de garde, borne du millésime).
  final int year;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();

  Future<_Snapshot> _snapshot() async {
    final values = <String, List<ListValue>>{};
    for (final v
        in await (_db.select(_db.listValues)
              ..where((v) => v.deletedAt.isNull())
              ..orderBy([(v) => OrderingTerm.asc(v.ordre)]))
            .get()) {
      values.putIfAbsent(v.liste, () => []).add(v);
    }
    final sum = _db.stockMovements.quantite.sum();
    final stocks = {
      for (final r
          in await (_db.selectOnly(_db.stockMovements)
                ..addColumns([_db.stockMovements.lotId, sum])
                ..where(_db.stockMovements.deletedAt.isNull())
                ..groupBy([_db.stockMovements.lotId]))
              .get())
        r.read(_db.stockMovements.lotId)!: r.read(sum) ?? 0,
    };
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
    return _Snapshot(
      producers: {
        for (final x in await (_db.select(
          _db.producers,
        )..where((x) => x.deletedAt.isNull())).get())
          x.id: x,
      },
      cuvees: {
        for (final x in await (_db.select(
          _db.cuvees,
        )..where((x) => x.deletedAt.isNull())).get())
          x.id: x,
      },
      wines: {
        for (final x
            in await (_db.select(_db.wines)
                  ..where((x) => x.deletedAt.isNull())
                  ..orderBy([(x) => OrderingTerm.asc(x.createdAt)]))
                .get())
          x.id: x,
      },
      lots: {
        for (final x
            in await (_db.select(_db.stockLots)
                  ..where((x) => x.deletedAt.isNull())
                  ..orderBy([(x) => OrderingTerm.asc(x.createdAt)]))
                .get())
          x.id: x,
      },
      stocks: stocks,
      movements:
          await (_db.select(_db.stockMovements)
                ..where((m) => m.deletedAt.isNull())
                ..orderBy([
                  (m) => OrderingTerm.asc(m.dateMouvement),
                  (m) => OrderingTerm.asc(m.createdAt),
                ]))
              .get(),
      owners: {
        for (final x in await (_db.select(
          _db.owners,
        )..where((x) => x.deletedAt.isNull())).get())
          x.id: x,
      },
      locations: {
        for (final x in await (_db.select(
          _db.storageLocations,
        )..where((x) => x.deletedAt.isNull())).get())
          x.id: x,
      },
      values: values,
      scores: scores,
      photos: {
        for (final x
            in await (_db.select(_db.photos)..where(
                  (x) => x.deletedAt.isNull() & x.principale.equals(true),
                ))
                .get())
          x.ficheId: x,
      },
    );
  }

  // ------------------------------------------------------------- Export

  static Object? _vintageCell(String v) => int.tryParse(v) ?? v;

  List<Object?> _wineRow(_Snapshot s, String id, AppLocalizations l) {
    final f = s.wines[id]!;
    final c = s.cuvees[f.cuveeId]!;
    final pr = s.producers[c.domaineId]!;
    final d = s.draftOf(id);
    final scores = s.scores[id] ?? const <CriticScoreValue>[];
    final lots = s.lots.values.where((x) => x.ficheId == id);
    final photo = s.photos[id];
    final values = <String, Object?>{
      'domaine.nom': pr.nom,
      'domaine.site_officiel': pr.siteOfficiel,
      'domaine.commentaire': pr.commentaire,
      'cuvee.nom': c.nom,
      'fiche_vin.id': f.id,
      'fiche_vin.millesime': _vintageCell(f.millesime),
      'fiche_vin.cepages': formatGrapes([
        for (final g in d.grapes) (s.label('cepage', g.code)!, g.percent),
      ]),
      'fiche_vin.degre': f.degre,
      'fiche_vin.commentaire_millesime': f.commentaireMillesime,
      'fiche_vin.garde_debut': f.gardeDebut,
      'fiche_vin.garde_apogee': f.gardeApogee,
      'fiche_vin.garde_fin': f.gardeFin,
      'fiche_vin.garde_source': f.gardeSource == null
          ? null
          : l.sourceLabel(f.gardeSource),
      'fiche_vin.statut_garde': l.statusLabel(
        cellarStatus(
          year: year,
          start: f.gardeDebut,
          peak: f.gardeApogee,
          end: f.gardeFin,
        ),
      ),
      'fiche_vin.accords': [
        for (final a in d.pairings) s.label('accord_mets', a),
      ].join('; '),
      'fiche_vin.ean': f.ean,
      'fiche_vin.lwin': f.lwin,
      'fiche_vin.commentaire_perso': f.commentairePerso,
      'fiche_vin.favori': f.favori ?? false,
      'fiche_vin.statut_enrichissement': l.enrichmentLabel(
        f.statutEnrichissement ?? 'valide',
      ),
      'fiche_vin.note_parker': parkerScore(scores)?.score,
      'fiche_vin.meilleure_note': bestScoreOn100(scores),
      'fiche_vin.stock_total': lots.fold<int>(
        0,
        (n, x) => n + (s.stocks[x.id] ?? 0),
      ),
      'photo.chemin': photo == null ? null : p.posix.basename(photo.chemin),
    };
    return [
      for (final col in wineColumns)
        col.kind == ExcelKind.list && col.entity == 'cuvee'
            ? s.label(col.list!, _cuveeValue(c, col.key))
            : values['${col.entity}.${col.key}'],
    ];
  }

  static String? _cuveeValue(Cuvee c, String key) => switch (key) {
    'pays' => c.pays,
    'region' => c.region,
    'sous_region' => c.sousRegion,
    'appellation' => c.appellation,
    'signe_qualite' => c.signeQualite,
    'classement' => c.classement,
    'couleur' => c.couleur,
    'type_vin' => c.typeVin,
    'certification' => c.certification,
    _ => null,
  };

  List<Object?> _lotRow(_Snapshot s, StockLot x) => [
    x.id,
    x.ficheId,
    s.wineLabel(x.ficheId),
    x.formatCl,
    s.owners[x.proprietaireId]?.nom,
    x.emplacementId == null ? null : s.locationPath(x.emplacementId!),
    x.positions,
    s.stocks[x.id] ?? 0,
    x.prixAchatUnitaire,
    XlsxDate.tryParse(x.dateAchat),
    s.label('fournisseur', x.fournisseur),
    null,
  ];

  List<Object?> _movementRow(
    _Snapshot s,
    StockMovement m,
    AppLocalizations l,
  ) => [
    m.lotId,
    l.movementLabel(m.typeMouvement),
    m.quantite,
    XlsxDate.tryParse(m.dateMouvement),
    s.label('motif_mouvement', m.motif),
    m.commentaire,
  ];

  List<XlsxSheet> _referenceSheets(_Snapshot s, AppLocalizations l) {
    String header(String list) => [
      for (final c in allExcelColumns)
        if (c.list == list) c.header,
    ].first;
    final lists = <List<Object?>>[
      [l.excelListName, l.excelListValue, l.excelListParent],
      for (final list in excelLists)
        for (final v in s.values[list] ?? const <ListValue>[])
          if (v.actif)
            [
              header(list),
              v.libelle,
              v.parentCode == null
                  ? null
                  : s.label(_parentList(list)!, v.parentCode),
            ],
      for (final o in s.owners.values) [lotColumns[4].header, o.nom, null],
      for (final id in s.locations.keys)
        [lotColumns[5].header, s.locationPath(id), null],
    ];
    return [
      XlsxSheet(name: sheetLists, rows: lists, widths: const [18, 40, 30]),
      XlsxSheet(
        name: sheetNotice,
        header: false,
        widths: const [120],
        rows: [
          for (final line in l.excelNotice.split('\n')) [line],
        ],
      ),
    ];
  }

  static String? _parentList(String list) => switch (list) {
    'region' => 'pays',
    'sous_region' => 'region',
    'appellation' => 'sous_region',
    _ => null,
  };

  static List<double> _widths(List<ExcelColumn> cols) => [
    for (final c in cols)
      switch (c.kind) {
        ExcelKind.longText => 50,
        ExcelKind.text || ExcelKind.url || ExcelKind.reference => 24,
        ExcelKind.grapes || ExcelKind.listMulti => 30,
        ExcelKind.list || ExcelKind.enumValue || ExcelKind.computed => 18,
        _ => 12,
      },
  ];

  /// XLS-01, XLS-02 : classeur à 5 onglets ; XLS-03 avec [template], même
  /// format sans données.
  Future<Uint8List> export(AppLocalizations l, {bool template = false}) async {
    final s = await _snapshot();
    final sheets = [
      XlsxSheet(
        name: sheetWines,
        widths: _widths(wineColumns),
        rows: [
          [for (final c in wineColumns) c.header],
          if (!template)
            for (final id in s.wines.keys)
              if (s.cuvees.containsKey(s.wines[id]!.cuveeId))
                _wineRow(s, id, l),
        ],
      ),
      XlsxSheet(
        name: sheetLots,
        widths: _widths(lotColumns),
        rows: [
          [for (final c in lotColumns) c.header],
          if (!template)
            for (final x in s.lots.values)
              if (s.wines.containsKey(x.ficheId)) _lotRow(s, x),
        ],
      ),
      XlsxSheet(
        name: sheetMovements,
        widths: _widths(movementColumns),
        rows: [
          [for (final c in movementColumns) c.header],
          if (!template)
            for (final m in s.movements)
              if (s.lots.containsKey(m.lotId)) _movementRow(s, m, l),
        ],
      ),
      ..._referenceSheets(s, l),
    ];
    return Isolate.run(() => writeXlsx(sheets));
  }

  // ------------------------------------------------------------ Import

  /// XLS-07 : simulation sur le classeur [xlsx] et, en option, le zip de
  /// photos [photosZip] (XLS-10). Rien n'est écrit.
  Future<ImportPlan> simulate(
    Uint8List xlsx, {
    Uint8List? photosZip,
    bool createUnknown = false,
  }) async {
    final book = await Isolate.run(() => readXlsx(xlsx));
    final zipped = photosZip == null
        ? const <String, Uint8List>{}
        : await Isolate.run(() => _readPhotos(photosZip));
    final s = await _snapshot();
    return _Planner(s, year, createUnknown).plan(book, zipped);
  }

  static Map<String, Uint8List> _readPhotos(Uint8List bytes) {
    final out = <String, Uint8List>{};
    for (final f in ZipDecoder().decodeBytes(bytes).files) {
      if (!f.isFile) continue;
      final name = p.posix.basename(f.name).toLowerCase();
      if (!RegExp(r'\.(jpe?g|png|webp|heic)$').hasMatch(name)) continue;
      out[name] = Uint8List.fromList(f.content as List<int>);
    }
    return out;
  }

  /// XLS-04 à XLS-08 : sauvegarde automatique, puis import tout ou rien.
  /// Les photos du zip (XLS-10) sont rattachées après l'import des données.
  Future<ImportResult> apply(
    ImportPlan plan, {
    required String cellarId,
  }) async {
    if (plan.report.issues.isNotEmpty) throw ImportException(plan.report);
    await backup?.autoBackupIfDue(null);
    final created = <int, String>{};
    final photoTargets = <String, String>{};
    await _db.transaction(() async {
      final codes = await _createUnknown(plan._unknown, cellarId);
      String? code(String? v) =>
          v != null && v.startsWith('\u0000') ? codes[v.substring(1)] : v;
      WineDraft resolve(WineDraft d) => WineDraft(
        producer: d.producer,
        producerWebsite: d.producerWebsite,
        producerComment: d.producerComment,
        cuvee: d.cuvee,
        country: code(d.country)!,
        region: code(d.region),
        subRegion: code(d.subRegion),
        appellation: code(d.appellation),
        qualitySign: code(d.qualitySign),
        classification: code(d.classification),
        lieuDit: d.lieuDit,
        color: d.color,
        wineType: code(d.wineType),
        certification: code(d.certification),
        vintage: d.vintage,
        grapes: [
          for (final g in d.grapes) GrapeShare(code(g.code)!, g.percent),
        ],
        alcohol: d.alcohol,
        vintageComment: d.vintageComment,
        gardeStart: d.gardeStart,
        gardePeak: d.gardePeak,
        gardeEnd: d.gardeEnd,
        pairings: [for (final a in d.pairings) code(a)!],
        ean: d.ean,
        lwin: d.lwin,
        personalComment: d.personalComment,
        favorite: d.favorite,
      );
      for (final op in plan._wines) {
        if (op.delete) {
          await cellar.deleteWine(op.id!);
          continue;
        }
        final String id;
        if (op.id == null) {
          id = await cellar.createWine(resolve(op.draft!), cellarId: cellarId);
          created[op.row] = id;
        } else {
          id = op.id!;
          if (op.changed.isNotEmpty) {
            await cellar.updateWine(id, resolve(op.draft!));
          }
        }
        await _markManual(id, cellarId, op.changed);
        if (op.photo != null) photoTargets[id] = op.photo!;
      }
      for (final op in plan._lots) {
        if (op.delete) {
          await (_db.update(
            _db.stockLots,
          )..where((x) => x.id.equals(op.id!))).write(
            StockLotsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
          );
          continue;
        }
        final wine = op.wine!.startsWith('#')
            ? created[int.parse(op.wine!.substring(1))]!
            : op.wine!;
        final d = op.draft!;
        final draft = LotDraft(
          ownerId: code(d.ownerId)!,
          quantity: 0,
          formatCl: d.formatCl,
          locationId: d.locationId,
          positions: d.positions,
          unitPrice: d.unitPrice,
          purchaseDate: d.purchaseDate,
          supplier: code(d.supplier),
        );
        if (op.id == null) {
          final lotId = await cellar.addLot(wine, draft);
          if ((op.target ?? 0) > 0) {
            await stock.add(lotId, op.target!, reason: importReason);
          }
        } else {
          if (op.descriptive) await cellar.updateLot(op.id!, draft);
          if (op.target != null) {
            await stock.adjust(op.id!, op.target!, importReason);
          }
        }
      }
    });
    final withPhoto = <String>[];
    final service = photos;
    if (service != null) {
      for (final e in photoTargets.entries) {
        final bytes = plan._photos[e.value];
        if (bytes == null) continue;
        try {
          final processed = await service.process(bytes);
          await service.save(
            wineId: e.key,
            cellarId: cellarId,
            photo: processed,
            type: 'etiquette',
          );
          if (created.containsValue(e.key)) withPhoto.add(e.key);
        } on FormatException {
          // Image illisible : la fiche reste sans photo.
        }
      }
    }
    return ImportResult(report: plan.report, createdWines: withPhoto);
  }

  /// XLS-06 : création en bloc des valeurs inconnues, parents d'abord.
  Future<Map<String, String>> _createUnknown(
    List<UnknownValue> unknown,
    String cellarId,
  ) async {
    final codes = <String, String>{};
    const order = [
      'proprietaire',
      'pays',
      'region',
      'sous_region',
      'appellation',
    ];
    final sorted = [...unknown]
      ..sort((a, b) {
        int rank(String l) {
          final i = order.indexOf(l);
          return i < 0 ? order.length : i;
        }

        return rank(a.list).compareTo(rank(b.list));
      });
    for (final u in sorted) {
      if (u.list == 'proprietaire') {
        codes[u.key] = await reference.saveOwner(
          cellarId: cellarId,
          name: u.label,
        );
        continue;
      }
      final parent = u.parent != null && u.parent!.startsWith('\u0000')
          ? codes[u.parent!.substring(1)]
          : u.parent;
      codes[u.key] = await reference.addValue(
        list: u.list,
        cellarId: cellarId,
        label: u.label,
        parentCode: parent,
      );
    }
    return codes;
  }

  /// Règle 3 : une valeur venue de l'import est une saisie manuelle, jamais
  /// écrasée par un ré-enrichissement (PRV-R2).
  Future<void> _markManual(
    String wineId,
    String cellarId,
    Set<String> fields,
  ) async {
    final today = _clock().toIso8601String().substring(0, 10);
    for (final field in fields.where(contractFieldMap.containsKey)) {
      await (_db.update(_db.provenances)..where(
            (x) =>
                x.entite.equals('fiche_vin') &
                x.entiteId.equals(wineId) &
                x.champ.equals(field) &
                x.deletedAt.isNull(),
          ))
          .write(ProvenancesCompanion(deletedAt: Value(_now)));
      await _db
          .into(_db.provenances)
          .insert(
            ProvenancesCompanion.insert(
              id: _uuid.v4(),
              caveId: cellarId,
              createdAt: _now,
              updatedAt: _now,
              entite: 'fiche_vin',
              entiteId: wineId,
              champ: field,
              source: 'import',
              dateCollecte: today,
              statut: 'manuel',
            ),
          );
    }
  }
}

/// Lecture des lignes du classeur et calcul des opérations (sans écriture).
class _Planner {
  _Planner(this.s, this.year, this.createUnknown);

  final _Snapshot s;
  final int year;
  final bool createUnknown;
  final issues = <ImportIssue>[];
  final unknown = <String, UnknownValue>{};

  void _issue(String sheet, int row, String col, IssueCode code, [Object? v]) =>
      issues.add(ImportIssue(sheet, row, col, code, v?.toString()));

  static String? _text(Object? v) {
    if (v == null) return null;
    if (v is num) {
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }
    if (v is XlsxDate) return v.iso;
    final t = '$v'.trim();
    return t.isEmpty ? null : t;
  }

  static double? _decimal(Object? v) {
    if (v is num) return v.toDouble();
    final t = _text(v);
    return t == null
        ? null
        : double.tryParse(t.replaceAll(',', '.').replaceAll(' ', ''));
  }

  /// Code d'une valeur de liste à partir de son libellé (ou de son code). En
  /// cas d'homonymes, la valeur rattachée à [parent] l'emporte.
  String? _code(String list, String label, {String? parent}) {
    final n = normalizeSearch(label);
    ListValue? found;
    for (final v in s.values[list] ?? const <ListValue>[]) {
      if (normalizeSearch(v.libelle) == n || v.code == label) {
        if (found == null || (parent != null && v.parentCode == parent)) {
          found = v;
        }
      }
    }
    return found?.code;
  }

  /// Valeur de liste, valeur à créer, ou null avec une erreur.
  String? _listValue(
    String sheet,
    int row,
    ExcelColumn col,
    String label, {
    String? parent,
    String? list,
  }) {
    final name = list ?? col.list!;
    final code = _code(name, label, parent: parent);
    if (code != null) return code;
    // La couleur est une liste fermée (dictionnaire, modifiable: false).
    if (!createUnknown || name == 'couleur') {
      _issue(sheet, row, col.header, IssueCode.unknownValue, label);
      return null;
    }
    final u = UnknownValue(name, label, parent);
    unknown.putIfAbsent(u.key, () => u);
    return _pending(u);
  }

  Map<String, int>? _headers(
    String sheet,
    List<List<Object?>>? rows,
    List<ExcelColumn> cols,
  ) {
    if (rows == null || rows.isEmpty) {
      _issue(sheet, 1, '', IssueCode.missingSheet);
      return null;
    }
    final headers = <String, int>{
      for (final (i, h) in rows.first.indexed)
        if (_text(h) != null) _text(h)!: i,
    };
    var ok = true;
    for (final c in cols) {
      if (!c.readOnly && !headers.containsKey(c.header)) {
        _issue(sheet, 1, c.header, IssueCode.missingColumn);
        ok = false;
      }
    }
    return ok ? headers : null;
  }

  ImportPlan plan(
    Map<String, List<List<Object?>>> book,
    Map<String, Uint8List> zipped,
  ) {
    final wineOps = <_WineOp>[];
    final lotOps = <_LotOp>[];
    final newRows = <int>{};
    final deleted = <String>{};
    var photosFound = 0;
    var enrichable = 0;

    final wh = _headers(sheetWines, book[sheetWines], wineColumns);
    final lh = _headers(sheetLots, book[sheetLots], lotColumns);
    if (wh != null) {
      final seen = <String>{};
      final rows = book[sheetWines]!;
      for (var r = 1; r < rows.length; r++) {
        final cells = rows[r];
        Object? cell(ExcelColumn c) {
          final i = wh[c.header];
          return i == null || i >= cells.length ? null : cells[i];
        }

        final editable = wineColumns.where((c) => !c.readOnly);
        if (editable.every((c) => _text(cell(c)) == null)) continue;
        final line = r + 1;
        final op = _wineRow(line, cell, seen);
        if (op == null) continue;
        if (op.delete) {
          deleted.add(op.id!);
        } else {
          if (op.id == null) newRows.add(line);
          final photo = _text(cell(wineColumns.last))?.toLowerCase();
          if (photo != null &&
              zipped.containsKey(p.posix.basename(photo)) &&
              (op.id == null ||
                  s.photos[op.id]?.chemin.toLowerCase().endsWith(photo) !=
                      true)) {
            op.photo = p.posix.basename(photo);
            photosFound++;
            if (op.id == null) enrichable++;
          }
        }
        if (op.delete ||
            op.id == null ||
            op.changed.isNotEmpty ||
            op.photo != null) {
          wineOps.add(op);
        }
      }
    }
    if (lh != null) {
      final seen = <String>{};
      final rows = book[sheetLots]!;
      for (var r = 1; r < rows.length; r++) {
        final cells = rows[r];
        Object? cell(ExcelColumn c) {
          final i = lh[c.header];
          return i == null || i >= cells.length ? null : cells[i];
        }

        final editable = lotColumns.where((c) => !c.readOnly);
        if (editable.every((c) => _text(cell(c)) == null)) continue;
        final op = _lotRow(r + 1, cell, seen, newRows, deleted);
        if (op != null) lotOps.add(op);
      }
    }
    final report = ImportReport(
      winesCreated: wineOps.where((o) => o.id == null).length,
      winesUpdated: wineOps
          .where((o) => o.id != null && !o.delete && o.changed.isNotEmpty)
          .length,
      winesDeleted: wineOps.where((o) => o.delete).length,
      lotsCreated: lotOps.where((o) => o.id == null).length,
      lotsUpdated: lotOps
          .where((o) => o.id != null && !o.delete && o.descriptive)
          .length,
      lotsDeleted: lotOps.where((o) => o.delete).length,
      stockChanges: lotOps
          .where(
            (o) =>
                !o.delete &&
                o.target != null &&
                (o.id == null
                    ? o.target! > 0
                    : o.target != (s.stocks[o.id] ?? 0)),
          )
          .length,
      unknown: unknown.values.toList(),
      issues: issues,
      photosFound: photosFound,
      enrichable: enrichable,
    );
    return ImportPlan._(
      report,
      issues.isEmpty ? wineOps : const [],
      issues.isEmpty ? lotOps : const [],
      zipped,
      unknown.values.toList(),
    );
  }

  _WineOp? _wineRow(
    int line,
    Object? Function(ExcelColumn) cell,
    Set<String> seen,
  ) {
    final before = issues.length;
    ExcelColumn col(String entity, String key) =>
        wineColumns.firstWhere((c) => c.entity == entity && c.key == key);
    String? text(String entity, String key) => _text(cell(col(entity, key)));

    final id = text('fiche_vin', 'id');
    final action = text('fiche_vin', 'action');
    if (id != null) {
      if (!s.wines.containsKey(id)) {
        _issue(sheetWines, line, 'id', IssueCode.unknownId, id);
        return null;
      }
      if (!seen.add(id)) {
        _issue(sheetWines, line, 'id', IssueCode.duplicateId, id);
        return null;
      }
    }
    if (action != null) {
      if (action.toUpperCase() != deleteAction || id == null) {
        _issue(sheetWines, line, 'Action', IssueCode.invalidAction, action);
        return null;
      }
      return _WineOp(line, id, null, const {}, delete: true);
    }

    String? required(String entity, String key) {
      final v = text(entity, key);
      if (v == null) {
        _issue(sheetWines, line, col(entity, key).header, IssueCode.required);
      }
      return v;
    }

    String? list(String key, {String? parent}) {
      final v = text('cuvee', key);
      return v == null
          ? null
          : _listValue(sheetWines, line, col('cuvee', key), v, parent: parent);
    }

    int? yearOf(String key) {
      final c = col('fiche_vin', key);
      final v = cell(c);
      if (_text(v) == null) return null;
      final n = v is num ? v.toInt() : int.tryParse(_text(v)!);
      if (n == null || n < 1900 || n > 2200) {
        _issue(sheetWines, line, c.header, IssueCode.invalidNumber, _text(v));
        return null;
      }
      return n;
    }

    final producer = required('domaine', 'nom');
    final countryLabel = required('cuvee', 'pays');
    final country = countryLabel == null
        ? null
        : _listValue(sheetWines, line, col('cuvee', 'pays'), countryLabel);
    final colorLabel = required('cuvee', 'couleur');
    final color = colorLabel == null
        ? null
        : _listValue(sheetWines, line, col('cuvee', 'couleur'), colorLabel);
    final region = list('region', parent: country);
    final subRegion = list('sous_region', parent: region);
    final appellation = list('appellation', parent: subRegion ?? region);

    final vintageCol = col('fiche_vin', 'millesime');
    final rawVintage = _text(cell(vintageCol));
    String? vintage;
    if (rawVintage == null) {
      _issue(sheetWines, line, vintageCol.header, IssueCode.required);
    } else if (rawVintage.toUpperCase() == 'NM') {
      vintage = 'NM';
    } else {
      final y = int.tryParse(rawVintage);
      if (y == null || y < 1900 || y > year) {
        _issue(
          sheetWines,
          line,
          vintageCol.header,
          IssueCode.invalidVintage,
          rawVintage,
        );
      } else {
        vintage = '$y';
      }
    }

    final alcoholCol = col('fiche_vin', 'degre');
    final alcohol = _decimal(cell(alcoholCol));
    if (_text(cell(alcoholCol)) != null &&
        (alcohol == null || alcohol < 5 || alcohol > 23)) {
      _issue(
        sheetWines,
        line,
        alcoholCol.header,
        IssueCode.outOfRange,
        _text(cell(alcoholCol)),
      );
    }

    final start = yearOf('garde_debut');
    final peak = yearOf('garde_apogee');
    final end = yearOf('garde_fin');
    final vy = int.tryParse(vintage ?? '');
    if ((start != null && vy != null && start < vy) ||
        (start != null && peak != null && peak < start) ||
        (peak != null && end != null && end < peak) ||
        (start != null && end != null && end < start)) {
      _issue(
        sheetWines,
        line,
        col('fiche_vin', 'garde_debut').header,
        IssueCode.gardeOrder,
      );
    }

    final grapesCol = col('fiche_vin', 'cepages');
    final grapes = <GrapeShare>[];
    final rawGrapes = _text(cell(grapesCol));
    if (rawGrapes != null) {
      final parsed = parseGrapes(rawGrapes);
      if (parsed == null ||
          parsed.where((g) => g.$2 != null).fold<int>(0, (n, g) => n + g.$2!) >
              100) {
        _issue(
          sheetWines,
          line,
          grapesCol.header,
          IssueCode.invalidGrapes,
          rawGrapes,
        );
      } else {
        for (final (name, pct) in parsed) {
          final code = _listValue(sheetWines, line, grapesCol, name);
          if (code != null) grapes.add(GrapeShare(code, pct));
        }
      }
    }

    final pairCol = col('fiche_vin', 'accords');
    final pairings = <String>[
      for (final a in splitMulti(_text(cell(pairCol)) ?? ''))
        ?_listValue(sheetWines, line, pairCol, a),
    ];

    final eanCol = col('fiche_vin', 'ean');
    final ean = _text(cell(eanCol));
    if (ean != null && !_validEan(ean)) {
      _issue(sheetWines, line, eanCol.header, IssueCode.invalidEan, ean);
    }

    final favCol = col('fiche_vin', 'favori');
    final favRaw = cell(favCol);
    bool favorite = false;
    if (_text(favRaw) != null) {
      final b = _bool(favRaw);
      if (b == null) {
        _issue(
          sheetWines,
          line,
          favCol.header,
          IssueCode.invalidBoolean,
          _text(favRaw),
        );
      } else {
        favorite = b;
      }
    }

    if (issues.length > before) return null;
    final draft = WineDraft(
      producer: producer!,
      producerWebsite: text('domaine', 'site_officiel'),
      producerComment: text('domaine', 'commentaire'),
      cuvee: text('cuvee', 'nom'),
      country: country!,
      region: region,
      subRegion: subRegion,
      appellation: appellation,
      qualitySign: list('signe_qualite'),
      classification: list('classement'),
      lieuDit: text('cuvee', 'lieu_dit'),
      color: color!,
      wineType: list('type_vin'),
      certification: list('certification'),
      vintage: vintage!,
      grapes: grapes,
      alcohol: alcohol,
      vintageComment: text('fiche_vin', 'commentaire_millesime'),
      gardeStart: start,
      gardePeak: peak,
      gardeEnd: end,
      pairings: pairings,
      ean: ean,
      lwin: text('fiche_vin', 'lwin'),
      personalComment: text('fiche_vin', 'commentaire_perso'),
      favorite: favorite,
    );
    if (issues.length > before) return null;
    final changed = id == null ? _filled(draft) : _diff(s.draftOf(id), draft);
    return _WineOp(line, id, draft, changed);
  }

  /// Champs renseignés (fiche créée).
  static Set<String> _filled(WineDraft d) => _diff(
    const WineDraft(producer: '', country: '', color: '', vintage: ''),
    d,
  );

  /// Champs qui changent, noms du contrat ; `ean`, `commentaire_perso` et
  /// `favori` n'ont pas de provenance.
  static Set<String> _diff(WineDraft a, WineDraft b) {
    String grapes(WineDraft d) =>
        [for (final g in d.grapes) '${g.code}:${g.percent}'].join(',');
    final pairs = <String, (Object?, Object?)>{
      'domaine': (a.producer, b.producer),
      'domaine_site_officiel': (a.producerWebsite, b.producerWebsite),
      'commentaire_domaine': (a.producerComment, b.producerComment),
      'cuvee': (a.cuvee, b.cuvee),
      'pays': (a.country, b.country),
      'region': (a.region, b.region),
      'sous_region': (a.subRegion, b.subRegion),
      'appellation': (a.appellation, b.appellation),
      'signe_qualite': (a.qualitySign, b.qualitySign),
      'classement': (a.classification, b.classification),
      'lieu_dit': (a.lieuDit, b.lieuDit),
      'couleur': (a.color, b.color),
      'type': (a.wineType, b.wineType),
      'certification': (a.certification, b.certification),
      'millesime': (a.vintage, b.vintage),
      'cepages': (grapes(a), grapes(b)),
      'degre': (a.alcohol, b.alcohol),
      'commentaire_millesime': (a.vintageComment, b.vintageComment),
      'garde': (
        '${a.gardeStart}-${a.gardePeak}-${a.gardeEnd}',
        '${b.gardeStart}-${b.gardePeak}-${b.gardeEnd}',
      ),
      'accords': (a.pairings.join(','), b.pairings.join(',')),
      'lwin': (a.lwin, b.lwin),
      'ean': (a.ean, b.ean),
      'commentaire_perso': (a.personalComment, b.personalComment),
      'favori': (a.favorite, b.favorite),
    };
    String? norm(Object? v) {
      final t = v?.toString().trim();
      return t == null || t.isEmpty || t == '' ? null : t;
    }

    return {
      for (final e in pairs.entries)
        if (norm(e.value.$1) != norm(e.value.$2)) e.key,
    };
  }

  static bool _validEan(String ean) {
    if (!RegExp(r'^\d{13}$').hasMatch(ean)) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(ean[i]) * (i.isEven ? 1 : 3);
    }
    return (10 - sum % 10) % 10 == int.parse(ean[12]);
  }

  static bool? _bool(Object? v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    return switch (normalizeSearch('$v')) {
      'oui' || 'vrai' || 'true' || 'x' || 'o' || 'yes' || '1' => true,
      'non' || 'faux' || 'false' || 'n' || 'no' || '0' => false,
      _ => null,
    };
  }

  String? _location(String path) {
    final n = path
        .split('>')
        .map((x) => normalizeSearch(x))
        .where((x) => x.isNotEmpty)
        .join('>');
    String? leaf;
    var leaves = 0;
    for (final id in s.locations.keys) {
      final full = s
          .locationPath(id)
          .split('>')
          .map((x) => normalizeSearch(x))
          .join('>');
      if (full == n) return id;
      if (normalizeSearch(s.locations[id]!.nom) == n) {
        leaf = id;
        leaves++;
      }
    }
    return leaves == 1 ? leaf : null;
  }

  _LotOp? _lotRow(
    int line,
    Object? Function(ExcelColumn) cell,
    Set<String> seen,
    Set<int> newRows,
    Set<String> deletedWines,
  ) {
    final before = issues.length;
    ExcelColumn col(String key) => lotColumns.firstWhere((c) => c.key == key);
    String? text(String key) => _text(cell(col(key)));

    final id = text('id');
    StockLot? existing;
    if (id != null) {
      existing = s.lots[id];
      if (existing == null) {
        _issue(sheetLots, line, col('id').header, IssueCode.unknownId, id);
        return null;
      }
      if (!seen.add(id)) {
        _issue(sheetLots, line, col('id').header, IssueCode.duplicateId, id);
        return null;
      }
    }
    final action = text('action');
    if (action != null) {
      if (action.toUpperCase() != deleteAction || id == null) {
        _issue(sheetLots, line, 'Action', IssueCode.invalidAction, action);
        return null;
      }
      return _LotOp(line, id, null, null, null, delete: true);
    }

    final wineRef = text('fiche_id');
    String? wine;
    if (wineRef == null) {
      _issue(sheetLots, line, col('fiche_id').header, IssueCode.required);
    } else if (wineRef.startsWith('#')) {
      final n = int.tryParse(wineRef.substring(1));
      if (n == null || !newRows.contains(n)) {
        _issue(
          sheetLots,
          line,
          col('fiche_id').header,
          IssueCode.unknownWine,
          wineRef,
        );
      } else {
        wine = wineRef;
      }
    } else if (deletedWines.contains(wineRef)) {
      _issue(
        sheetLots,
        line,
        col('fiche_id').header,
        IssueCode.deletedWine,
        wineRef,
      );
    } else if (!s.wines.containsKey(wineRef)) {
      _issue(
        sheetLots,
        line,
        col('fiche_id').header,
        IssueCode.unknownWine,
        wineRef,
      );
    } else {
      wine = wineRef;
    }

    final formatCol = col('format_cl');
    final format = _decimal(cell(formatCol));
    if (format == null || format <= 0) {
      _issue(
        sheetLots,
        line,
        formatCol.header,
        _text(cell(formatCol)) == null
            ? IssueCode.required
            : IssueCode.invalidNumber,
        _text(cell(formatCol)),
      );
    }

    final ownerCol = col('proprietaire_id');
    final ownerName = text('proprietaire_id');
    String? owner;
    if (ownerName == null) {
      _issue(sheetLots, line, ownerCol.header, IssueCode.required);
    } else {
      final n = normalizeSearch(ownerName);
      owner = s.owners.values
          .where((o) => normalizeSearch(o.nom) == n)
          .firstOrNull
          ?.id;
      if (owner == null) {
        if (createUnknown) {
          final u = UnknownValue('proprietaire', ownerName);
          unknown.putIfAbsent(u.key, () => u);
          owner = _pending(u);
        } else {
          _issue(
            sheetLots,
            line,
            ownerCol.header,
            IssueCode.unknownValue,
            ownerName,
          );
        }
      }
    }

    final locCol = col('emplacement_id');
    final locText = text('emplacement_id');
    String? location;
    if (locText != null) {
      location = _location(locText);
      if (location == null) {
        _issue(
          sheetLots,
          line,
          locCol.header,
          IssueCode.unknownLocation,
          locText,
        );
      }
    }

    final qtyCol = col('quantite');
    final qtyRaw = cell(qtyCol);
    int? target;
    if (_text(qtyRaw) != null) {
      final q = qtyRaw is num ? qtyRaw : num.tryParse(_text(qtyRaw)!);
      if (q == null || q < 0 || q != q.roundToDouble()) {
        _issue(
          sheetLots,
          line,
          qtyCol.header,
          IssueCode.invalidNumber,
          _text(qtyRaw),
        );
      } else {
        target = q.toInt();
      }
    }

    final priceCol = col('prix_achat_unitaire');
    final price = _decimal(cell(priceCol));
    if (_text(cell(priceCol)) != null && (price == null || price < 0)) {
      _issue(
        sheetLots,
        line,
        priceCol.header,
        IssueCode.invalidNumber,
        _text(cell(priceCol)),
      );
    }

    final dateCol = col('date_achat');
    final dateRaw = cell(dateCol);
    String? date;
    if (_text(dateRaw) != null) {
      date = switch (dateRaw) {
        final XlsxDate d => d.iso,
        _ => _parseDate(_text(dateRaw)!),
      };
      if (date == null) {
        _issue(
          sheetLots,
          line,
          dateCol.header,
          IssueCode.invalidDate,
          _text(dateRaw),
        );
      }
    }

    final supplierText = text('fournisseur');
    final supplier = supplierText == null
        ? null
        : _listValue(sheetLots, line, col('fournisseur'), supplierText);

    if (issues.length > before) return null;
    final draft = LotDraft(
      ownerId: owner!,
      quantity: 0,
      formatCl: format!,
      locationId: location,
      positions: text('positions'),
      unitPrice: price,
      purchaseDate: date,
      supplier: supplier,
    );
    if (existing == null) return _LotOp(line, null, wine, draft, target ?? 0);
    if (existing.ficheId != wine) {
      _issue(
        sheetLots,
        line,
        col('fiche_id').header,
        IssueCode.lotWineChange,
        wineRef,
      );
      return null;
    }
    final descriptive =
        existing.formatCl != draft.formatCl ||
        existing.proprietaireId != draft.ownerId ||
        existing.emplacementId != draft.locationId ||
        (existing.positions ?? '') != (draft.positions ?? '') ||
        existing.prixAchatUnitaire != draft.unitPrice ||
        (existing.dateAchat ?? '') != (draft.purchaseDate ?? '') ||
        (existing.fournisseur ?? '') != (draft.supplier ?? '');
    final stockChange =
        target != null && target != (s.stocks[existing.id] ?? 0);
    if (!descriptive && !stockChange) return null;
    return _LotOp(
      line,
      id,
      wine,
      draft,
      stockChange ? target : null,
      descriptive: descriptive,
    );
  }

  static String? _parseDate(String t) {
    final iso = XlsxDate.tryParse(t);
    if (iso != null) return iso.iso;
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t);
    if (m == null) return null;
    return XlsxDate.tryParse(
      '${m[3]}-${m[2]!.padLeft(2, '0')}-${m[1]!.padLeft(2, '0')}',
    )?.iso;
  }
}
