import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Signature des requêtes au flux (docs/02-architecture.md, sécurité des
/// appels) :
/// hex(HMAC-SHA256(clé, horodatage + "\n" + méthode + "\n" + chemin + "\n" +
/// sha256_hex(corps))). La clé est le texte UTF-8 saisi dans les Réglages
/// (T58), le chemin comprend la chaîne de requête.
String signRequest({
  required String key,
  required String timestamp,
  required String method,
  required String path,
  required List<int> body,
}) {
  final digest = sha256.convert(body).toString();
  final text = '$timestamp\n${method.toUpperCase()}\n$path\n$digest';
  return Hmac(sha256, utf8.encode(key)).convert(utf8.encode(text)).toString();
}

/// Les trois en-têtes de sécurité d'une requête.
Map<String, String> securityHeaders({
  required String key,
  required String installationId,
  required DateTime now,
  required String method,
  required String path,
  required List<int> body,
}) {
  final ts = (now.toUtc().millisecondsSinceEpoch ~/ 1000).toString();
  return {
    'X-IACAV-Installation': installationId,
    'X-IACAV-Horodatage': ts,
    'X-IACAV-Signature': signRequest(
      key: key,
      timestamp: ts,
      method: method,
      path: path,
      body: body,
    ),
  };
}
