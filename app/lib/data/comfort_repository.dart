import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';

/// CMP-05 : une dégustation, avec le vin dégusté.
class TastingEntry {
  const TastingEntry({
    required this.id,
    required this.wineId,
    required this.wineName,
    required this.vintage,
    required this.colorCode,
    required this.date,
    this.score,
    this.dish,
    this.comment,
  });

  final String id;
  final String wineId;
  final String wineName;
  final String vintage;
  final String colorCode;
  final String date;
  final double? score;
  final String? dish;
  final String? comment;
}

/// Lot 4 : liste d'achats (CMP-03) et historique des dégustations (CMP-05).
class ComfortRepository {
  ComfortRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();

  /// Vins à acheter d'abord, puis achetés ; les plus récents en tête.
  Stream<List<ShoppingItem>> watchShopping() =>
      (_db.select(_db.shoppingItems)
            ..where((x) => x.deletedAt.isNull())
            ..orderBy([
              (x) => OrderingTerm.asc(x.achete),
              (x) => OrderingTerm.desc(x.createdAt),
            ]))
          .watch();

  /// Ajoute un vin à la liste. Un vin de la cave déjà présent et pas encore
  /// acheté n'est pas ajouté deux fois : renvoie sa ligne.
  Future<String> addShopping({
    required String cellarId,
    required String label,
    String? wineId,
    int? quantity,
    String? note,
  }) async {
    if (wineId != null) {
      final existing =
          await (_db.select(_db.shoppingItems)..where(
                (x) =>
                    x.ficheId.equals(wineId) &
                    x.achete.equals(false) &
                    x.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (existing != null) return existing.id;
    }
    final id = _uuid.v4();
    await _db
        .into(_db.shoppingItems)
        .insert(
          ShoppingItemsCompanion.insert(
            id: id,
            caveId: cellarId,
            createdAt: _now,
            updatedAt: _now,
            libelle: label.trim(),
            achete: false,
          ).copyWith(
            ficheId: Value(wineId),
            quantite: Value(quantity),
            note: Value(
              note == null || note.trim().isEmpty ? null : note.trim(),
            ),
          ),
        );
    return id;
  }

  Future<void> setBought(String id, bool bought) =>
      (_db.update(_db.shoppingItems)..where((x) => x.id.equals(id))).write(
        ShoppingItemsCompanion(achete: Value(bought), updatedAt: Value(_now)),
      );

  /// Suppression logique (règle de suppression du dictionnaire).
  Future<void> deleteShopping(String id) =>
      (_db.update(_db.shoppingItems)..where((x) => x.id.equals(id))).write(
        ShoppingItemsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
      );

  /// CMP-05 : toutes les dégustations, de la plus récente à la plus ancienne.
  Stream<List<TastingEntry>> watchTastings() {
    final query =
        _db.select(_db.tastings).join([
            innerJoin(_db.wines, _db.wines.id.equalsExp(_db.tastings.ficheId)),
            innerJoin(_db.cuvees, _db.cuvees.id.equalsExp(_db.wines.cuveeId)),
            innerJoin(
              _db.producers,
              _db.producers.id.equalsExp(_db.cuvees.domaineId),
            ),
          ])
          ..where(
            _db.tastings.deletedAt.isNull() & _db.wines.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.desc(_db.tastings.dateDegustation),
            OrderingTerm.desc(_db.tastings.createdAt),
          ]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          () {
            final t = r.readTable(_db.tastings);
            final w = r.readTable(_db.wines);
            final c = r.readTable(_db.cuvees);
            final p = r.readTable(_db.producers);
            return TastingEntry(
              id: t.id,
              wineId: w.id,
              wineName: [
                p.nom,
                c.nom,
              ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
              vintage: w.millesime,
              colorCode: c.couleur,
              date: t.dateDegustation,
              score: t.notePerso,
              dish: t.plat,
              comment: t.commentaire,
            );
          }(),
      ],
    );
  }
}
