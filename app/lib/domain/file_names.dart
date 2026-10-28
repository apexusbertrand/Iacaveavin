/// Nom de fichier lisible pour une fiche partagée (PDF ou image) : « Domaine
/// - Cuvée - 2015 ». Caractères interdits sur Android, iOS ou Windows
/// remplacés, espaces réduits, 80 caractères au plus.
String wineFileBase({
  required String producer,
  String? cuvee,
  String? vintage,
  String fallback = 'fiche',
}) {
  final parts = [
    producer,
    ?cuvee,
    ?vintage,
  ].map(_clean).where((p) => p.isNotEmpty);
  var name = parts.join(' - ');
  if (name.length > 80) name = name.substring(0, 80).trimRight();
  return name.isEmpty ? fallback : name;
}

String _clean(String s) => s
    .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .replaceAll(RegExp(r'^\.+|\.+$'), '');
