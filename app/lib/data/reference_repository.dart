import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';

/// Listes du dictionnaire modifiables dans le Paramétrage (PAR-01), dans
/// l'ordre du dictionnaire. « couleur » n'est pas modifiable.
const editableLists = [
  'type_vin',
  'pays',
  'region',
  'sous_region',
  'appellation',
  'signe_qualite',
  'classement',
  'certification',
  'cepage',
  'format',
  'fournisseur',
  'motif_mouvement',
  'accord_mets',
  'critique',
];

/// Liste parente d'une liste hiérarchique (dictionnaire, clé `hierarchie`).
const parentList = {
  'region': 'pays',
  'sous_region': 'region',
  'appellation': 'sous_region',
};

/// Erreur de paramétrage, code traduit à l'écran.
class ReferenceException implements Exception {
  const ReferenceException(this.code);

  /// `in_use`, `duplicate`, `depth`, `not_empty`, `csv`.
  final String code;

  @override
  String toString() => 'ReferenceException($code)';
}

class OwnerView {
  const OwnerView({
    required this.id,
    required this.name,
    required this.bottles,
    this.initials,
    this.color,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String? initials;
  final String? color;
  final bool isDefault;
  final int bottles;
}

class LocationView {
  const LocationView({
    required this.id,
    required this.name,
    required this.type,
    required this.depth,
    required this.bottles,
    this.parentId,
    this.rows,
    this.cols,
    this.capacity,
  });

  final String id;
  final String? parentId;
  final String name;

  /// Code de l'énumération `type_emplacement`.
  final String type;

  /// 0 pour la racine, 3 au plus (EMP-01 : 4 niveaux).
  final int depth;
  final int? rows;
  final int? cols;
  final int? capacity;

  /// Bouteilles rangées ici et dans les sous-emplacements.
  final int bottles;

  /// EMP-05 : taux de remplissage, null sans capacité.
  double? get fillRate =>
      capacity == null || capacity == 0 ? null : bottles / capacity!;

  bool get overCapacity => capacity != null && bottles > capacity!;
}

class ListValueView {
  const ListValueView({
    required this.id,
    required this.list,
    required this.code,
    required this.label,
    required this.active,
    required this.order,
    this.parentCode,
  });

  final String id;
  final String list;
  final String code;
  final String label;
  final String? parentCode;
  final bool active;
  final int order;
}

/// Propriétaires, emplacements et listes de valeurs.
class ReferenceRepository {
  ReferenceRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();

  Future<Map<String, int>> _stockByLot() async {
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

  Future<List<StockLot>> _liveLots() =>
      (_db.select(_db.stockLots)..where((l) => l.deletedAt.isNull())).get();

  Stream<T> _watch<T>(
    Future<T> Function() load,
    List<TableInfo<Table, dynamic>> tables,
  ) async* {
    yield await load();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables(tables),
    )) {
      yield await load();
    }
  }

  /// Libellés de toutes les listes, par « liste:code ».
  Stream<Map<String, String>> watchLabels() => _watch(() async {
    final out = <String, String>{};
    for (final v in await (_db.select(
      _db.listValues,
    )..where((v) => v.deletedAt.isNull())).get()) {
      out.putIfAbsent('${v.liste}:${v.code}', () => v.libelle);
    }
    return out;
  }, [_db.listValues]);

  // ------------------------------------------------------- Propriétaires

  Stream<List<OwnerView>> watchOwners() =>
      _watch(owners, [_db.owners, _db.stockLots, _db.stockMovements]);

  Future<List<OwnerView>> owners() async {
    final stocks = await _stockByLot();
    final perOwner = <String, int>{};
    for (final l in await _liveLots()) {
      perOwner.update(
        l.proprietaireId,
        (v) => v + (stocks[l.id] ?? 0),
        ifAbsent: () => stocks[l.id] ?? 0,
      );
    }
    final rows =
        await (_db.select(_db.owners)
              ..where((o) => o.deletedAt.isNull())
              ..orderBy([(o) => OrderingTerm.asc(o.nom)]))
            .get();
    return [
      for (final o in rows)
        OwnerView(
          id: o.id,
          name: o.nom,
          initials: o.initiales,
          color: o.couleur,
          isDefault: o.parDefaut ?? false,
          bottles: perOwner[o.id] ?? 0,
        ),
    ];
  }

  /// PRO-01 : un seul propriétaire par défaut.
  Future<String> saveOwner({
    String? id,
    required String cellarId,
    required String name,
    String? initials,
    String? color,
    bool isDefault = false,
  }) => _db.transaction(() async {
    if (isDefault) {
      await _db
          .update(_db.owners)
          .write(const OwnersCompanion(parDefaut: Value(false)));
    }
    final ownerId = id ?? _uuid.v4();
    final values = OwnersCompanion(
      updatedAt: Value(_now),
      nom: Value(name.trim()),
      initiales: Value(_blank(initials)),
      couleur: Value(_blank(color)),
      parDefaut: Value(isDefault),
    );
    if (id == null) {
      await _db
          .into(_db.owners)
          .insert(
            values.copyWith(
              id: Value(ownerId),
              caveId: Value(cellarId),
              createdAt: Value(_now),
            ),
          );
    } else {
      await (_db.update(
        _db.owners,
      )..where((o) => o.id.equals(id))).write(values);
    }
    return ownerId;
  });

  /// Un propriétaire qui possède des lots ne se supprime pas.
  Future<void> deleteOwner(String id) async {
    final used = await (_db.select(
      _db.stockLots,
    )..where((l) => l.proprietaireId.equals(id) & l.deletedAt.isNull())).get();
    if (used.isNotEmpty) throw const ReferenceException('in_use');
    await (_db.update(_db.owners)..where((o) => o.id.equals(id))).write(
      OwnersCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  /// Propriétaire par défaut, créé au besoin pour qu'un lot ait toujours un
  /// propriétaire (PRO-01).
  Future<String> defaultOwner(String cellarId, {String name = 'Moi'}) async {
    final all = await owners();
    final def = all.where((o) => o.isDefault);
    if (def.isNotEmpty) return def.first.id;
    if (all.isNotEmpty) return all.first.id;
    return saveOwner(cellarId: cellarId, name: name, isDefault: true);
  }

  // ------------------------------------------------------- Emplacements

  Stream<List<LocationView>> watchLocations() => _watch(locations, [
    _db.storageLocations,
    _db.stockLots,
    _db.stockMovements,
  ]);

  /// Arbre à plat, parents avant enfants, triés par nom à chaque niveau.
  Future<List<LocationView>> locations() async {
    final rows = await (_db.select(
      _db.storageLocations,
    )..where((l) => l.deletedAt.isNull())).get();
    final stocks = await _stockByLot();
    final direct = <String, int>{};
    for (final l in await _liveLots()) {
      if (l.emplacementId == null) continue;
      direct.update(
        l.emplacementId!,
        (v) => v + (stocks[l.id] ?? 0),
        ifAbsent: () => stocks[l.id] ?? 0,
      );
    }
    final children = <String?, List<StorageLocation>>{};
    for (final r in rows) {
      children.putIfAbsent(r.parentId, () => []).add(r);
    }
    for (final list in children.values) {
      list.sort((a, b) => a.nom.compareTo(b.nom));
    }
    int total(String id) =>
        (direct[id] ?? 0) +
        (children[id] ?? const []).fold(0, (s, c) => s + total(c.id));
    final out = <LocationView>[];
    void visit(String? parent, int depth) {
      for (final r in children[parent] ?? const <StorageLocation>[]) {
        out.add(
          LocationView(
            id: r.id,
            parentId: r.parentId,
            name: r.nom,
            type: r.typeEmplacement,
            depth: depth,
            rows: r.lignes,
            cols: r.colonnes,
            capacity: r.capacite ?? _gridCapacity(r.lignes, r.colonnes),
            bottles: total(r.id),
          ),
        );
        visit(r.id, depth + 1);
      }
    }

    visit(null, 0);
    return out;
  }

  static int? _gridCapacity(int? rows, int? cols) =>
      rows == null || cols == null ? null : rows * cols;

  /// EMP-01 : 4 niveaux au plus. EMP-02 : grille de 1 à 26 lignes et de 1 à
  /// 50 colonnes.
  Future<String> saveLocation({
    String? id,
    required String cellarId,
    required String name,
    required String type,
    String? parentId,
    int? rows,
    int? cols,
    int? capacity,
  }) async {
    if (parentId != null) {
      final all = await locations();
      final parent = all.firstWhere((l) => l.id == parentId);
      if (parent.depth >= 3) throw const ReferenceException('depth');
    }
    if ((rows != null && (rows < 1 || rows > 26)) ||
        (cols != null && (cols < 1 || cols > 50))) {
      throw const ReferenceException('grid');
    }
    final values = StorageLocationsCompanion(
      updatedAt: Value(_now),
      nom: Value(name.trim()),
      typeEmplacement: Value(type),
      parentId: Value(parentId),
      lignes: Value(rows),
      colonnes: Value(cols),
      capacite: Value(capacity),
    );
    if (id == null) {
      final newId = _uuid.v4();
      await _db
          .into(_db.storageLocations)
          .insert(
            values.copyWith(
              id: Value(newId),
              caveId: Value(cellarId),
              createdAt: Value(_now),
            ),
          );
      return newId;
    }
    await (_db.update(
      _db.storageLocations,
    )..where((l) => l.id.equals(id))).write(values);
    return id;
  }

  /// Un emplacement qui contient des bouteilles ou des sous-emplacements
  /// ne se supprime pas.
  Future<void> deleteLocation(String id) async {
    final all = await locations();
    final loc = all.firstWhere((l) => l.id == id);
    if (loc.bottles > 0 || all.any((l) => l.parentId == id)) {
      throw const ReferenceException('not_empty');
    }
    await (_db.update(
      _db.storageLocations,
    )..where((l) => l.id.equals(id))).write(
      StorageLocationsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  // ------------------------------------------------------- Listes (PAR)

  Stream<List<ListValueView>> watchList(String list) =>
      _watch(() => values(list), [_db.listValues]);

  Future<List<ListValueView>> values(
    String list, {
    bool activeOnly = false,
  }) async {
    final rows =
        await (_db.select(_db.listValues)
              ..where(
                (v) =>
                    v.liste.equals(list) &
                    v.deletedAt.isNull() &
                    (activeOnly ? v.actif.equals(true) : const Constant(true)),
              )
              ..orderBy([
                (v) => OrderingTerm.asc(v.ordre),
                (v) => OrderingTerm.asc(v.libelle),
              ]))
            .get();
    return [
      for (final r in rows)
        ListValueView(
          id: r.id,
          list: r.liste,
          code: r.code,
          label: r.libelle,
          parentCode: r.parentCode,
          active: r.actif,
          order: r.ordre ?? 0,
        ),
    ];
  }

  /// PAR-02, FIC-02 : ajoute une valeur. Le code est dérivé du libellé.
  Future<String> addValue({
    required String list,
    required String cellarId,
    required String label,
    String? parentCode,
  }) async {
    final existing = await values(list);
    final code = _slug(label, existing.map((v) => v.code).toSet());
    if (existing.any(
      (v) => v.label.toLowerCase() == label.trim().toLowerCase(),
    )) {
      throw const ReferenceException('duplicate');
    }
    await _db
        .into(_db.listValues)
        .insert(
          ListValuesCompanion.insert(
            id: _uuid.v4(),
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            liste: list,
            code: code,
            libelle: label.trim(),
            parentCode: Value(parentCode),
            ordre: Value(existing.length),
            actif: true,
          ),
        );
    return code;
  }

  Future<void> renameValue(String id, String label) =>
      (_db.update(_db.listValues)..where((v) => v.id.equals(id))).write(
        ListValuesCompanion(
          libelle: Value(label.trim()),
          updatedAt: Value(_now),
        ),
      );

  Future<void> setActive(String id, bool active) =>
      (_db.update(_db.listValues)..where((v) => v.id.equals(id))).write(
        ListValuesCompanion(actif: Value(active), updatedAt: Value(_now)),
      );

  /// PAR-02 : nouvel ordre d'affichage, dans l'ordre des [ids].
  Future<void> reorder(List<String> ids) => _db.transaction(() async {
    for (var i = 0; i < ids.length; i++) {
      await (_db.update(_db.listValues)..where((v) => v.id.equals(ids[i])))
          .write(ListValuesCompanion(ordre: Value(i), updatedAt: Value(_now)));
    }
  });

  /// Nombre de fiches, lots, notes ou valeurs enfants qui utilisent [code].
  Future<int> usage(String list, String code) async {
    Future<int> count(String sql) async {
      final row = await _db
          .customSelect(sql, variables: [Variable.withString(code)])
          .getSingle();
      return row.read<int>('n');
    }

    var n = 0;
    final cuveeColumn = _cuveeColumns[list];
    if (cuveeColumn != null) {
      n += await count(
        'SELECT COUNT(*) AS n FROM cuvee WHERE $cuveeColumn = ? '
        'AND deleted_at IS NULL',
      );
    }
    switch (list) {
      case 'cepage':
        n += await count(
          "SELECT COUNT(*) AS n FROM fiche_vin, json_each(fiche_vin.cepages) "
          "WHERE json_extract(json_each.value, '\$.cepage') = ? "
          'AND fiche_vin.deleted_at IS NULL',
        );
      case 'accord_mets':
        n += await count(
          'SELECT COUNT(*) AS n FROM fiche_vin, json_each(fiche_vin.accords) '
          'WHERE json_each.value = ? AND fiche_vin.deleted_at IS NULL',
        );
      case 'format':
        n += await count(
          "SELECT COUNT(*) AS n FROM lot WHERE printf('%g', format_cl) = ? "
          'AND deleted_at IS NULL',
        );
      case 'fournisseur':
        n += await count('SELECT COUNT(*) AS n FROM lot WHERE fournisseur = ?');
      case 'motif_mouvement':
        n += await count('SELECT COUNT(*) AS n FROM mouvement WHERE motif = ?');
      case 'critique':
        n += await count(
          'SELECT COUNT(*) AS n FROM note_critique WHERE critique = ?',
        );
    }
    final child = parentList.entries.where((e) => e.value == list);
    for (final c in child) {
      n += await count(
        "SELECT COUNT(*) AS n FROM valeur_liste WHERE liste = '${c.key}' "
        'AND parent_code = ? AND deleted_at IS NULL',
      );
    }
    return n;
  }

  static const _cuveeColumns = {
    'type_vin': 'type_vin',
    'pays': 'pays',
    'region': 'region',
    'sous_region': 'sous_region',
    'appellation': 'appellation',
    'signe_qualite': 'signe_qualite',
    'classement': 'classement',
    'certification': 'certification',
  };

  /// PAR-02 : suppression interdite pour une valeur utilisée.
  Future<void> deleteValue(String id) async {
    final v = await (_db.select(
      _db.listValues,
    )..where((x) => x.id.equals(id))).getSingle();
    if (await usage(v.liste, v.code) > 0) {
      throw const ReferenceException('in_use');
    }
    await (_db.update(_db.listValues)..where((x) => x.id.equals(id))).write(
      ListValuesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  /// PAR-02 : fusionne [fromId] dans [intoId]. Les fiches et les valeurs
  /// enfants sont re-pointées, puis la valeur fusionnée est supprimée.
  /// Les mouvements sont immuables : un motif utilisé ne se fusionne pas.
  Future<void> merge(String fromId, String intoId) => _db.transaction(() async {
    final from = await (_db.select(
      _db.listValues,
    )..where((x) => x.id.equals(fromId))).getSingle();
    final into = await (_db.select(
      _db.listValues,
    )..where((x) => x.id.equals(intoId))).getSingle();
    final list = from.liste;
    final a = from.code, b = into.code;
    Future<void> run(String sql) => _db.customUpdate(
      sql,
      variables: [Variable.withString(b), Variable.withString(a)],
      updates: {_db.cuvees, _db.wines, _db.stockLots, _db.criticScores},
    );

    if (list == 'motif_mouvement' && await usage(list, a) > 0) {
      throw const ReferenceException('in_use');
    }
    final cuveeColumn = _cuveeColumns[list];
    if (cuveeColumn != null) {
      await run('UPDATE cuvee SET $cuveeColumn = ? WHERE $cuveeColumn = ?');
    }
    switch (list) {
      case 'cepage' || 'accord_mets':
        final column = list == 'cepage' ? 'cepages' : 'accords';
        for (final w in await _db.select(_db.wines).get()) {
          final json = list == 'cepage' ? w.cepages : w.accords;
          if (json == null || !json.contains('"$a"')) continue;
          final decoded = jsonDecode(json) as List;
          final updated = list == 'cepage'
              ? [
                  for (final g in decoded.cast<Map<String, dynamic>>())
                    g['cepage'] == a ? {...g, 'cepage': b} : g,
                ]
              : {for (final c in decoded.cast<String>()) c == a ? b : c}
                    .toList();
          await _db.customUpdate(
            'UPDATE fiche_vin SET $column = ? WHERE id = ?',
            variables: [
              Variable.withString(jsonEncode(updated)),
              Variable.withString(w.id),
            ],
            updates: {_db.wines},
          );
        }
      case 'fournisseur':
        await run('UPDATE lot SET fournisseur = ? WHERE fournisseur = ?');
      case 'critique':
        await run('UPDATE note_critique SET critique = ? WHERE critique = ?');
    }
    final child = parentList.entries.where((e) => e.value == list);
    for (final c in child) {
      await _db.customUpdate(
        "UPDATE valeur_liste SET parent_code = ? WHERE liste = '${c.key}' "
        'AND parent_code = ?',
        variables: [Variable.withString(b), Variable.withString(a)],
        updates: {_db.listValues},
      );
    }
    await (_db.update(_db.listValues)..where((x) => x.id.equals(fromId))).write(
      ListValuesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  });

  // ------------------------------------------------------------ CSV

  /// PAR-04 : export CSV (séparateur point-virgule, comme Excel en français).
  Future<String> exportCsv(String list) async {
    final b = StringBuffer('code;libelle;parent;ordre;actif\n');
    for (final v in await values(list)) {
      b.writeln(
        [
          v.code,
          v.label,
          v.parentCode ?? '',
          '${v.order}',
          v.active ? '1' : '0',
        ].map(_csvCell).join(';'),
      );
    }
    return b.toString();
  }

  /// PAR-04 : import CSV. Une ligne au code connu met à jour la valeur, un
  /// code inconnu la crée. Tout ou rien : une ligne invalide annule l'import.
  /// Renvoie le nombre de lignes créées et mises à jour.
  Future<({int created, int updated})> importCsv(
    String list,
    String csv, {
    required String cellarId,
  }) => _db.transaction(() async {
    final lines = const LineSplitter()
        .convert(csv.replaceFirst('﻿', ''))
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty || !lines.first.toLowerCase().startsWith('code;')) {
      throw const ReferenceException('csv');
    }
    final existing = {for (final v in await values(list)) v.code: v};
    var created = 0, updated = 0;
    for (final line in lines.skip(1)) {
      final cells = _parseCsvLine(line);
      if (cells.length < 2 || cells[0].isEmpty || cells[1].isEmpty) {
        throw const ReferenceException('csv');
      }
      final order = cells.length > 3 ? int.tryParse(cells[3]) : null;
      final active = cells.length > 4 ? cells[4] != '0' : true;
      final parent = cells.length > 2 && cells[2].isNotEmpty ? cells[2] : null;
      final current = existing[cells[0]];
      if (current == null) {
        await _db
            .into(_db.listValues)
            .insert(
              ListValuesCompanion.insert(
                id: _uuid.v4(),
                caveId: cellarId,
                createdAt: _now,
                updatedAt: _now,
                liste: list,
                code: cells[0],
                libelle: cells[1],
                parentCode: Value(parent),
                ordre: Value(order ?? existing.length + created),
                actif: active,
              ),
            );
        created++;
      } else {
        await (_db.update(
          _db.listValues,
        )..where((v) => v.id.equals(current.id))).write(
          ListValuesCompanion(
            updatedAt: Value(_now),
            libelle: Value(cells[1]),
            parentCode: Value(parent),
            ordre: Value(order ?? current.order),
            actif: Value(active),
          ),
        );
        updated++;
      }
    }
    return (created: created, updated: updated);
  });

  static String _csvCell(String v) =>
      v.contains(RegExp('[;"\n]')) ? '"${v.replaceAll('"', '""')}"' : v;

  static List<String> _parseCsvLine(String line) {
    final cells = <String>[];
    final b = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (quoted) {
        if (ch == '"' && i + 1 < line.length && line[i + 1] == '"') {
          b.write('"');
          i++;
        } else if (ch == '"') {
          quoted = false;
        } else {
          b.write(ch);
        }
      } else if (ch == '"') {
        quoted = true;
      } else if (ch == ';') {
        cells.add(b.toString().trim());
        b.clear();
      } else {
        b.write(ch);
      }
    }
    cells.add(b.toString().trim());
    return cells;
  }

  static String? _blank(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  static String _slug(String label, Set<String> taken) {
    const accents = 'àâäáãåçéèêëîïíìôöóòõûüùúÿñ';
    const plain = 'aaaaaaceeeeiiiiooooouuuuyn';
    final b = StringBuffer();
    for (final ch in label.trim().toLowerCase().split('')) {
      final i = accents.indexOf(ch);
      b.write(i >= 0 ? plain[i] : ch);
    }
    final base = b
        .toString()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    var code = base.isEmpty ? 'valeur' : base;
    var n = 2;
    while (taken.contains(code)) {
      code = '$base-${n++}';
    }
    return code;
  }
}
