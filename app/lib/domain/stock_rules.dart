/// Règles de stock (docs/04-modele-donnees.md, § Stock).
library;

/// Types de l'énumération `type_mouvement` du dictionnaire.
enum MovementType {
  entry('entree'),
  opening('ouverture'),
  otherExit('sortie_autre'),
  adjustment('ajustement'),
  transferOut('transfert_sortant'),
  transferIn('transfert_entrant');

  const MovementType(this.code);

  final String code;

  static MovementType fromCode(String code) =>
      values.firstWhere((t) => t.code == code);
}

/// Motifs exigés pour un ajustement (STK-03).
const adjustmentReasons = [
  'inventaire',
  'erreur de saisie',
  'casse',
  'offert',
  'autre',
];

class StockRuleException implements Exception {
  const StockRuleException(this.code);

  /// Code stable, traduit à l'écran : `negative`, `zero`, `reason_required`,
  /// `same_lot`, `too_many`.
  final String code;

  @override
  String toString() => 'StockRuleException($code)';
}

/// Signe attendu de la quantité selon le type de mouvement.
int signedQuantity(MovementType type, int bottles) => switch (type) {
  MovementType.entry || MovementType.transferIn => bottles.abs(),
  MovementType.opening ||
  MovementType.otherExit ||
  MovementType.transferOut => -bottles.abs(),
  MovementType.adjustment => bottles,
};

/// Valide un mouvement contre le stock actuel du lot.
/// STK-R1 : quantité jamais 0 ; STK-R2 : stock jamais négatif ;
/// motif obligatoire pour ajustement et sortie_autre.
void checkMovement({
  required int currentStock,
  required MovementType type,
  required int quantity,
  String? reason,
}) {
  if (quantity == 0) throw const StockRuleException('zero');
  if ((type == MovementType.adjustment || type == MovementType.otherExit) &&
      (reason == null || reason.trim().isEmpty)) {
    throw const StockRuleException('reason_required');
  }
  if (currentStock + quantity < 0) throw const StockRuleException('negative');
}

/// STK-03 : écart entre la quantité réelle saisie et le stock calculé.
/// Renvoie null si aucun ajustement n'est nécessaire.
int? adjustmentDelta({required int currentStock, required int actual}) {
  if (actual < 0) throw const StockRuleException('negative');
  final delta = actual - currentStock;
  return delta == 0 ? null : delta;
}
