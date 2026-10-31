import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Signature des requêtes au flux (docs/02-architecture.md, sécurité des
/// appels) :
/// hex(HMAC-SHA256(clé, horodatage + "\n" + méthode + "\n" + chemin + "\n" +
/// sha256_hex(corps))). Contrat 2.0 : la clé est la clé de session du compte
/// (texte UTF-8), le chemin comprend la chaîne de requête.
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

/// Les en-têtes de sécurité d'une requête. Contrat 2.0 : [accountId] annonce
/// le compte dont la clé signe la requête (X-IACAV-Compte).
Map<String, String> securityHeaders({
  required String key,
  required String installationId,
  String? accountId,
  required DateTime now,
  required String method,
  required String path,
  required List<int> body,
}) {
  final ts = (now.toUtc().millisecondsSinceEpoch ~/ 1000).toString();
  return {
    'X-IACAV-Installation': installationId,
    'X-IACAV-Compte': ?accountId,
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
