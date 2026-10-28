/// Drapeau emoji d'un code pays ISO 3166-1 alpha-2 (« FR » donne 🇫🇷).
/// Renvoie une chaîne vide pour un code invalide.
String flagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) return '';
  const base = 0x1F1E6 - 0x41;
  return String.fromCharCodes(code.codeUnits.map((c) => base + c));
}
