/// Contenu d'une fiche imprimée (PDF-04), sans Flutter ni format PDF : des
/// textes déjà mis en forme, prêts à envoyer dans un isolate.
library;

import 'dart:typed_data';

/// Lien profond qui ouvre la fiche dans l'app (NAV-02, QR code PDF-04).
String wineDeepLink(String wineId) => 'iacaveavin://fiche/$wineId';

/// PDF-04 : texte ramené à [max] caractères, coupé à la fin de la phrase
/// entière la plus proche ; à défaut de phrase, au dernier mot, avec « … ».
String truncateAtSentence(String text, int max) {
  final t = text.trim();
  if (t.length <= max) return t;
  final head = t.substring(0, max);
  var cut = -1;
  for (final m in RegExp(r'[.!?…](?=\s|$)').allMatches(head)) {
    cut = m.end;
  }
  if (cut > 0) return head.substring(0, cut).trim();
  final space = head.lastIndexOf(' ');
  return '${(space > 0 ? head.substring(0, space) : head).trim()}…';
}

/// Fiche à imprimer.
class PdfWine {
  const PdfWine({
    required this.id,
    required this.title,
    required this.vintage,
    this.subtitle,
    this.fields = const [],
    this.comments = const [],
    this.lines = const [],
    this.photo,
  });

  final String id;

  /// Domaine (ou cuvée si le domaine est inconnu).
  final String title;
  final String? subtitle;
  final String vintage;

  /// Champs `pdf: true` du dictionnaire : libellé et valeur.
  final List<(String, String)> fields;

  /// Commentaires (domaine, millésime, personnel), non tronqués.
  final List<(String, String)> comments;

  /// Notes critiques et lots, une ligne chacun.
  final List<String> lines;

  /// Photo d'étiquette en JPEG.
  final Uint8List? photo;
}

/// Textes du document, venus des fichiers ARB.
class PdfTexts {
  const PdfTexts({
    required this.editedOn,
    required this.coverTitle,
    required this.coverCount,
    required this.coverFilters,
    required this.coverNoFilter,
    required this.page,
  });

  /// « Édité le 27 octobre 2026 ».
  final String editedOn;
  final String coverTitle;

  /// « 200 fiches ».
  final String coverCount;
  final String coverFilters;
  final String coverNoFilter;

  /// Modèle « Page {n} / {total} » : `{n}` et `{total}` remplacés.
  final String page;
}

/// Document à produire.
class PdfJob {
  const PdfJob({
    required this.wines,
    required this.texts,
    required this.regular,
    required this.bold,
    required this.accent,
    required this.muted,
    this.catalogue = false,
    this.cover = false,
    this.filters = const [],
  });

  final List<PdfWine> wines;
  final PdfTexts texts;

  /// Polices TrueType (accents, « œ », « € »).
  final Uint8List regular;
  final Uint8List bold;

  /// Couleurs du thème clair (ARGB) : titres et textes secondaires.
  final int accent;
  final int muted;

  /// PDF-02 : 2 fiches par page ; sinon une fiche en A4 portrait (PDF-01).
  final bool catalogue;

  /// PDF-03 : page de garde avec date, filtres et nombre de fiches.
  final bool cover;
  final List<String> filters;
}
