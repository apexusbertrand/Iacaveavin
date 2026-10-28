/// AJO-14 : millésime lu sur l'étiquette par la reconnaissance de texte du
/// téléphone. Règles pures, sans Flutter.
library;

/// Mots qui annoncent une date de fondation ou de copyright, pas un
/// millésime (« depuis 1919 », « fondé en 1880 », « © 2024 »).
const _notVintage = [
  'depuis',
  'since',
  'fond',
  'found',
  'est.',
  'estd',
  'etabli',
  'établi',
  'cree',
  'créé',
  'creat',
  '©',
  'copyright',
  'anno',
];

/// Années de 1900 à [currentYear] écrites seules dans [text], dans l'ordre
/// de lecture, sans celles précédées d'un mot de fondation.
List<int> vintageCandidates(String text, {required int currentYear}) {
  final out = <int>[];
  for (final m in RegExp(
    r'(?<![\d.,/])(19|20)\d{2}(?![\d.,/%])',
  ).allMatches(text)) {
    final year = int.parse(m.group(0)!);
    if (year < 1900 || year > currentYear) continue;
    final before = text
        .substring(m.start < 24 ? 0 : m.start - 24, m.start)
        .toLowerCase();
    if (_notVintage.any(before.contains)) continue;
    out.add(year);
  }
  return out;
}

/// Lecture d'une seule image (photo) : l'année si elle est la seule, ou si
/// elle revient plus souvent que toutes les autres ; sinon rien.
int? vintageFromText(String text, {required int currentYear}) {
  final counts = <int, int>{};
  for (final y in vintageCandidates(text, currentYear: currentYear)) {
    counts[y] = (counts[y] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (sorted.length > 1 && sorted[0].value == sorted[1].value) return null;
  return sorted.first.key;
}

/// Lecture à la volée : une année est retenue quand elle est la seule lue
/// sur [needed] images de suite. Évite de garder une lecture d'un instant.
class VintageVote {
  VintageVote({this.needed = 2});

  final int needed;
  int? _year;
  int _streak = 0;

  /// Dernière année vue seule, pour l'afficher pendant la visée.
  int? get current => _year;

  /// Ajoute la lecture d'une image ; renvoie l'année une fois confirmée.
  int? add(List<int> candidates) {
    final distinct = candidates.toSet();
    if (distinct.length != 1) {
      _streak = 0;
      return null;
    }
    final y = distinct.single;
    _streak = y == _year ? _streak + 1 : 1;
    _year = y;
    return _streak >= needed ? y : null;
  }
}
