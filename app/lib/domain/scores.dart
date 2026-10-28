/// Notes critiques (docs/04-modele-donnees.md, § Notes).
library;

const parkerCritic = 'Robert Parker Wine Advocate';

class CriticScoreValue {
  const CriticScoreValue({
    required this.critic,
    required this.score,
    required this.scale,
    this.date,
    this.citedBy,
  });

  final String critic;
  final double score;

  /// 20 ou 100.
  final int scale;

  /// Date ISO (AAAA-MM-JJ) de la note, si connue.
  final String? date;
  final String? citedBy;

  /// Note ramenée sur 100, pour comparer uniquement (jamais pour afficher).
  double get on100 => scale == 20 ? score * 5 : score;
}

/// NOT-R1 : la note Parker affichée est la plus récente des notes Parker.
/// Une note sans date passe après les notes datées.
CriticScoreValue? parkerScore(Iterable<CriticScoreValue> scores) {
  CriticScoreValue? best;
  for (final s in scores.where((s) => s.critic == parkerCritic)) {
    if (best == null) {
      best = s;
    } else if (s.date != null &&
        (best.date == null || s.date!.compareTo(best.date!) > 0)) {
      best = s;
    }
  }
  return best;
}

/// NOT-R2 : meilleure note toutes sources, ramenée sur 100.
double? bestScoreOn100(Iterable<CriticScoreValue> scores) {
  double? best;
  for (final s in scores) {
    if (best == null || s.on100 > best) best = s.on100;
  }
  return best;
}
