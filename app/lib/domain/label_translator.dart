/// LNG-03 : traduction à l'affichage des valeurs livrées des listes de
/// référence. La base garde codes et libellés français ; une valeur ajoutée
/// ou renommée par l'utilisateur s'affiche telle qu'il l'a saisie.
class LabelTranslator {
  const LabelTranslator(this._entries);

  /// Pas de traduction (français).
  static const identity = LabelTranslator({});

  /// `liste:code` vers (libellé livré en français, libellé traduit).
  final Map<String, (String, String)> _entries;

  /// [entries] : la clé `valeurs` de assets/referentiels/en.json.
  factory LabelTranslator.fromJson(Map<String, dynamic> valeurs) =>
      LabelTranslator({
        for (final e in valeurs.entries)
          e.key: (
            (e.value as Map)['fr'] as String,
            (e.value as Map)['en'] as String,
          ),
      });

  bool get isIdentity => _entries.isEmpty;

  /// Libellé affiché pour la valeur `liste:code` dont le libellé en base est
  /// [stored].
  String label(String key, String stored) {
    final e = _entries[key];
    return e != null && e.$1 == stored ? e.$2 : stored;
  }

  /// Toute une table `liste:code` vers libellé.
  Map<String, String> labels(Map<String, String> stored) => isIdentity
      ? stored
      : {for (final e in stored.entries) e.key: label(e.key, e.value)};

  /// Libellé traduit d'une valeur de [list] connue par son libellé livré en
  /// français (règles de garde, qui portent des libellés).
  String byFrench(String list, String french) {
    for (final e in _entries.entries) {
      if (e.value.$1 == french && e.key.startsWith('$list:')) return e.value.$2;
    }
    return french;
  }
}
