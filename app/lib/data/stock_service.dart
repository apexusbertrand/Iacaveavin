import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/stock_rules.dart';
import 'db/app_database.dart';

/// Résultat d'une action de stock : les mouvements créés, pour l'annulation
/// de 5 secondes (STK-07).
class StockAction {
  const StockAction(this.movementIds, {this.createdLotId});

  final List<String> movementIds;

  /// Lot cible créé par un transfert (STK-R5), supprimé avec l'annulation.
  final String? createdLotId;
}

/// Seul point d'écriture des mouvements. Chaque action relit le stock du lot
/// dans la transaction et applique STK-R1 à STK-R5.
class StockService {
  StockService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime get _now => _clock().toUtc();
  String get _today => _clock().toIso8601String().substring(0, 10);

  Future<int> lotStock(String lotId) async {
    final sum = _db.stockMovements.quantite.sum();
    final row =
        await (_db.selectOnly(_db.stockMovements)
              ..addColumns([sum])
              ..where(
                _db.stockMovements.lotId.equals(lotId) &
                    _db.stockMovements.deletedAt.isNull(),
              ))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  Future<String> _move(
    StockLot lot,
    MovementType type,
    int quantity, {
    String? reason,
    String? comment,
    String? linkedLot,
    String? date,
  }) async {
    checkMovement(
      currentStock: await lotStock(lot.id),
      type: type,
      quantity: quantity,
      reason: reason,
    );
    final id = _uuid.v4();
    await _db
        .into(_db.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            id: id,
            caveId: lot.caveId,
            createdAt: _now,
            updatedAt: _now,
            lotId: lot.id,
            typeMouvement: type.code,
            quantite: quantity,
            dateMouvement: date ?? _today,
            motif: Value(reason),
            commentaire: Value(comment),
            lotLieId: Value(linkedLot),
          ),
        );
    return id;
  }

  Future<StockLot> _lot(String id) =>
      (_db.select(_db.stockLots)..where((l) => l.id.equals(id))).getSingle();

  /// STK-01 : ajoute des bouteilles à un lot.
  Future<StockAction> add(String lotId, int bottles, {String? reason}) =>
      _db.transaction(() async {
        final lot = await _lot(lotId);
        return StockAction([
          await _move(
            lot,
            MovementType.entry,
            signedQuantity(MovementType.entry, bottles),
            reason: reason ?? 'achat',
          ),
        ]);
      });

  /// STK-01, STK-02 : ouvre des bouteilles.
  Future<StockAction> open(String lotId, int bottles) =>
      _db.transaction(() async {
        final lot = await _lot(lotId);
        return StockAction([
          await _move(
            lot,
            MovementType.opening,
            signedQuantity(MovementType.opening, bottles),
            reason: 'ouverture',
          ),
        ]);
      });

  /// Sortie autre qu'une ouverture (offert, casse...), motif obligatoire.
  Future<StockAction> exit(String lotId, int bottles, String reason) =>
      _db.transaction(() async {
        final lot = await _lot(lotId);
        return StockAction([
          await _move(
            lot,
            MovementType.otherExit,
            signedQuantity(MovementType.otherExit, bottles),
            reason: reason,
          ),
        ]);
      });

  /// STK-03 : l'utilisateur saisit la quantité réelle ; l'écart devient un
  /// mouvement `ajustement` avec motif. Renvoie null si aucun écart.
  Future<StockAction?> adjust(
    String lotId,
    int actual,
    String reason, {
    String? comment,
  }) => _db.transaction(() async {
    final lot = await _lot(lotId);
    final delta = adjustmentDelta(
      currentStock: await lotStock(lotId),
      actual: actual,
    );
    if (delta == null) return null;
    return StockAction([
      await _move(
        lot,
        MovementType.adjustment,
        delta,
        reason: reason,
        comment: comment,
      ),
    ]);
  });

  /// STK-05, STK-R5 : transfère [bottles] bouteilles vers un autre
  /// emplacement ou propriétaire. Crée le lot cible et deux mouvements liés.
  Future<StockAction> transfer(
    String lotId,
    int bottles, {
    String? toOwnerId,
    String? toLocationId,
    String? toPositions,
  }) => _db.transaction(() async {
    final source = await _lot(lotId);
    if (toOwnerId == source.proprietaireId &&
        toLocationId == source.emplacementId) {
      throw const StockRuleException('same_lot');
    }
    final targetId = _uuid.v4();
    await _db
        .into(_db.stockLots)
        .insert(
          StockLotsCompanion.insert(
            id: targetId,
            caveId: source.caveId,
            createdAt: _now,
            updatedAt: _now,
            ficheId: source.ficheId,
            proprietaireId: toOwnerId ?? source.proprietaireId,
          ).copyWith(
            formatCl: Value(source.formatCl),
            emplacementId: Value(toLocationId),
            positions: Value(toPositions),
            prixAchatUnitaire: Value(source.prixAchatUnitaire),
            dateAchat: Value(source.dateAchat),
            fournisseur: Value(source.fournisseur),
          ),
        );
    final target = await _lot(targetId);
    final out = await _move(
      source,
      MovementType.transferOut,
      -bottles.abs(),
      reason: 'transfert',
      linkedLot: targetId,
    );
    final into = await _move(
      target,
      MovementType.transferIn,
      bottles.abs(),
      reason: 'transfert',
      linkedLot: lotId,
    );
    return StockAction([out, into], createdLotId: targetId);
  });

  /// STK-07, STK-R4 : annulation dans les 5 secondes. Les mouvements non
  /// confirmés sont supprimés, ainsi que le lot cible d'un transfert.
  Future<void> undo(StockAction action) => _db.transaction(() async {
    await (_db.delete(
      _db.stockMovements,
    )..where((m) => m.id.isIn(action.movementIds))).go();
    if (action.createdLotId != null) {
      await (_db.delete(
        _db.stockLots,
      )..where((l) => l.id.equals(action.createdLotId!))).go();
    }
  });
}
