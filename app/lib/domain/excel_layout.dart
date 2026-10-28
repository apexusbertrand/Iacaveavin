/// XLS-01 : colonnes du classeur, reprises de la clé `excel` de
/// specs/dictionnaire-donnees.yaml dans l'ordre du dictionnaire. Un test
/// (test/specs/dictionnaire_test.dart) vérifie l'alignement. Les en-têtes
/// servent de clés à l'import : ils ne se traduisent pas.
library;

enum ExcelKind {
  text,
  longText,
  url,
  integer,
  decimal,
  money,
  boolean,
  date,
  year,
  vintage,
  list,
  listMulti,
  grapes,
  reference,
  computed,
  enumValue,
  action,
}

class ExcelColumn {
  const ExcelColumn(
    this.entity,
    this.key,
    this.sheet,
    this.header,
    this.kind, {
    this.list,
    this.readOnly = false,
    this.required = false,
  });

  /// Entité et clé du dictionnaire.
  final String entity;
  final String key;
  final String sheet;
  final String header;
  final ExcelKind kind;

  /// Liste (ou énumération) de valeurs.
  final String? list;

  /// `RO:` : exporté, ignoré à l'import.
  final bool readOnly;
  final bool required;

  /// Forme de la clé `excel` du dictionnaire.
  String get dictionaryKey => '${readOnly ? 'RO:' : ''}$sheet/$header';
}

const sheetWines = 'Vins';
const sheetLots = 'Lots';
const sheetMovements = 'Mouvements';
const sheetLists = 'Listes';
const sheetNotice = 'Notice';

/// Valeur de la colonne Action qui supprime la ligne (XLS-04).
const deleteAction = 'SUPPRIMER';

const wineColumns = [
  ExcelColumn(
    'domaine',
    'nom',
    sheetWines,
    'Domaine',
    ExcelKind.text,
    required: true,
  ),
  ExcelColumn(
    'domaine',
    'site_officiel',
    sheetWines,
    'Site officiel',
    ExcelKind.url,
  ),
  ExcelColumn(
    'domaine',
    'commentaire',
    sheetWines,
    'Commentaire domaine',
    ExcelKind.longText,
  ),
  ExcelColumn('cuvee', 'nom', sheetWines, 'Cuvée', ExcelKind.text),
  ExcelColumn(
    'cuvee',
    'pays',
    sheetWines,
    'Pays',
    ExcelKind.list,
    list: 'pays',
    required: true,
  ),
  ExcelColumn(
    'cuvee',
    'region',
    sheetWines,
    'Région',
    ExcelKind.list,
    list: 'region',
  ),
  ExcelColumn(
    'cuvee',
    'sous_region',
    sheetWines,
    'Sous-région',
    ExcelKind.list,
    list: 'sous_region',
  ),
  ExcelColumn(
    'cuvee',
    'appellation',
    sheetWines,
    'Appellation',
    ExcelKind.list,
    list: 'appellation',
  ),
  ExcelColumn(
    'cuvee',
    'signe_qualite',
    sheetWines,
    'Signe de qualité',
    ExcelKind.list,
    list: 'signe_qualite',
  ),
  ExcelColumn(
    'cuvee',
    'classement',
    sheetWines,
    'Classement',
    ExcelKind.list,
    list: 'classement',
  ),
  ExcelColumn('cuvee', 'lieu_dit', sheetWines, 'Lieu-dit', ExcelKind.text),
  ExcelColumn(
    'cuvee',
    'couleur',
    sheetWines,
    'Couleur',
    ExcelKind.list,
    list: 'couleur',
    required: true,
  ),
  ExcelColumn(
    'cuvee',
    'type_vin',
    sheetWines,
    'Type',
    ExcelKind.list,
    list: 'type_vin',
  ),
  ExcelColumn(
    'cuvee',
    'certification',
    sheetWines,
    'Certification',
    ExcelKind.list,
    list: 'certification',
  ),
  ExcelColumn('fiche_vin', 'id', sheetWines, 'id', ExcelKind.text),
  ExcelColumn(
    'fiche_vin',
    'millesime',
    sheetWines,
    'Millésime',
    ExcelKind.vintage,
    required: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'cepages',
    sheetWines,
    'Cépages',
    ExcelKind.grapes,
    list: 'cepage',
  ),
  ExcelColumn('fiche_vin', 'degre', sheetWines, 'Degré (%)', ExcelKind.decimal),
  ExcelColumn(
    'fiche_vin',
    'commentaire_millesime',
    sheetWines,
    'Commentaire millésime',
    ExcelKind.longText,
  ),
  ExcelColumn(
    'fiche_vin',
    'garde_debut',
    sheetWines,
    'Garde début',
    ExcelKind.year,
  ),
  ExcelColumn(
    'fiche_vin',
    'garde_apogee',
    sheetWines,
    'Apogée',
    ExcelKind.year,
  ),
  ExcelColumn(
    'fiche_vin',
    'garde_fin',
    sheetWines,
    'Garde fin',
    ExcelKind.year,
  ),
  ExcelColumn(
    'fiche_vin',
    'garde_source',
    sheetWines,
    'Origine garde',
    ExcelKind.enumValue,
    list: 'source_provenance',
    readOnly: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'statut_garde',
    sheetWines,
    'Statut garde',
    ExcelKind.computed,
    readOnly: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'accords',
    sheetWines,
    'Accords',
    ExcelKind.listMulti,
    list: 'accord_mets',
  ),
  ExcelColumn('fiche_vin', 'ean', sheetWines, 'EAN', ExcelKind.text),
  ExcelColumn('fiche_vin', 'lwin', sheetWines, 'LWIN', ExcelKind.text),
  ExcelColumn(
    'fiche_vin',
    'commentaire_perso',
    sheetWines,
    'Mon commentaire',
    ExcelKind.longText,
  ),
  ExcelColumn('fiche_vin', 'favori', sheetWines, 'Favori', ExcelKind.boolean),
  ExcelColumn(
    'fiche_vin',
    'statut_enrichissement',
    sheetWines,
    'Statut enrichissement',
    ExcelKind.enumValue,
    list: 'statut_enrichissement',
    readOnly: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'note_parker',
    sheetWines,
    'Note Parker',
    ExcelKind.computed,
    readOnly: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'meilleure_note',
    sheetWines,
    'Meilleure note (/100)',
    ExcelKind.computed,
    readOnly: true,
  ),
  ExcelColumn(
    'fiche_vin',
    'stock_total',
    sheetWines,
    'Stock total',
    ExcelKind.computed,
    readOnly: true,
  ),
  ExcelColumn('fiche_vin', 'action', sheetWines, 'Action', ExcelKind.action),
  ExcelColumn(
    'photo',
    'chemin',
    sheetWines,
    'Photo principale',
    ExcelKind.text,
    readOnly: true,
  ),
];

const lotColumns = [
  ExcelColumn('lot', 'id', sheetLots, 'id lot', ExcelKind.text),
  ExcelColumn(
    'lot',
    'fiche_id',
    sheetLots,
    'id fiche',
    ExcelKind.reference,
    required: true,
  ),
  ExcelColumn(
    'lot',
    'libelle_vin',
    sheetLots,
    'Vin',
    ExcelKind.computed,
    readOnly: true,
  ),
  ExcelColumn(
    'lot',
    'format_cl',
    sheetLots,
    'Format (cl)',
    ExcelKind.decimal,
    list: 'format',
    required: true,
  ),
  ExcelColumn(
    'lot',
    'proprietaire_id',
    sheetLots,
    'Propriétaire',
    ExcelKind.reference,
    required: true,
  ),
  ExcelColumn(
    'lot',
    'emplacement_id',
    sheetLots,
    'Emplacement',
    ExcelKind.reference,
  ),
  ExcelColumn('lot', 'positions', sheetLots, 'Positions', ExcelKind.text),
  ExcelColumn('lot', 'quantite', sheetLots, 'Quantité', ExcelKind.integer),
  ExcelColumn(
    'lot',
    'prix_achat_unitaire',
    sheetLots,
    "Prix d'achat unitaire",
    ExcelKind.money,
  ),
  ExcelColumn('lot', 'date_achat', sheetLots, "Date d'achat", ExcelKind.date),
  ExcelColumn(
    'lot',
    'fournisseur',
    sheetLots,
    'Fournisseur',
    ExcelKind.list,
    list: 'fournisseur',
  ),
  ExcelColumn('lot', 'action', sheetLots, 'Action', ExcelKind.action),
];

const movementColumns = [
  ExcelColumn(
    'mouvement',
    'lot_id',
    sheetMovements,
    'id lot',
    ExcelKind.reference,
    readOnly: true,
    required: true,
  ),
  ExcelColumn(
    'mouvement',
    'type_mouvement',
    sheetMovements,
    'Type',
    ExcelKind.enumValue,
    list: 'type_mouvement',
    readOnly: true,
    required: true,
  ),
  ExcelColumn(
    'mouvement',
    'quantite',
    sheetMovements,
    'Quantité',
    ExcelKind.integer,
    readOnly: true,
    required: true,
  ),
  ExcelColumn(
    'mouvement',
    'date_mouvement',
    sheetMovements,
    'Date',
    ExcelKind.date,
    readOnly: true,
    required: true,
  ),
  ExcelColumn(
    'mouvement',
    'motif',
    sheetMovements,
    'Motif',
    ExcelKind.list,
    list: 'motif_mouvement',
    readOnly: true,
  ),
  ExcelColumn(
    'mouvement',
    'commentaire',
    sheetMovements,
    'Commentaire',
    ExcelKind.text,
    readOnly: true,
  ),
];

/// Toutes les colonnes, dans l'ordre du dictionnaire.
const allExcelColumns = [...wineColumns, ...lotColumns, ...movementColumns];

/// Listes décrites dans l'onglet Listes (valeurs autorisées).
const excelLists = [
  'couleur',
  'type_vin',
  'pays',
  'region',
  'sous_region',
  'appellation',
  'signe_qualite',
  'classement',
  'certification',
  'cepage',
  'accord_mets',
  'fournisseur',
];

/// Cépages en une cellule : « Merlot 80 %; Cabernet Franc 20 % ».
String formatGrapes(List<(String, int?)> grapes) =>
    [for (final (name, pct) in grapes) pct == null ? name : '$name $pct %']
        .join('; ');

/// Inverse de [formatGrapes] ; null si un pourcentage est illisible.
List<(String, int?)>? parseGrapes(String text) {
  final out = <(String, int?)>[];
  for (final part in text.split(RegExp(r'[;\n]'))) {
    final t = part.trim();
    if (t.isEmpty) continue;
    final m = RegExp(r'^(.*?)\s*(\d{1,3})\s*%$').firstMatch(t);
    if (m != null) {
      final pct = int.parse(m[2]!);
      if (pct > 100) return null;
      out.add((m[1]!.trim(), pct));
    } else if (t.contains('%')) {
      return null;
    } else {
      out.add((t, null));
    }
  }
  return out;
}

/// Plusieurs valeurs de liste en une cellule, séparées par « ; ».
List<String> splitMulti(String text) => [
  for (final p in text.split(RegExp(r'[;\n]')))
    if (p.trim().isNotEmpty) p.trim(),
];
