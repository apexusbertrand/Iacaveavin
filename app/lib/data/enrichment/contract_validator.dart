import 'dart:convert';

import 'package:json_schema/json_schema.dart';

/// Validation des messages du flux contre le contrat (AJO-12, NFR-07).
///
/// Les schémas sont la copie embarquée de specs/contrat-n8n/ (un test
/// vérifie qu'elle est identique).
class ContractValidator {
  ContractValidator({
    required String responseSchema,
    String? requestSchema,
    String? feedbackResponseSchema,
  }) : _response = JsonSchema.create(responseSchema),
       _request = requestSchema == null
           ? null
           : JsonSchema.create(requestSchema),
       _feedback = feedbackResponseSchema == null
           ? null
           : JsonSchema.create(feedbackResponseSchema);

  static const responseAsset = 'assets/contrat/reponse-job.schema.json';
  static const requestAsset =
      'assets/contrat/requete-enrichissement.schema.json';
  static const feedbackResponseAsset =
      'assets/contrat/reponse-remontee.schema.json';

  final JsonSchema _response;
  final JsonSchema? _request;
  final JsonSchema? _feedback;

  /// Erreurs de validation d'une réponse (vide si elle est conforme).
  List<String> responseErrors(Object? json) => _errors(_response, json);

  List<String> requestErrors(Object? json) =>
      _request == null ? const [] : _errors(_request, json);

  static List<String> _errors(JsonSchema schema, Object? json) {
    final results = schema.validate(json, validateFormats: true);
    return [for (final e in results.errors) '${e.instancePath} : ${e.message}'];
  }

  /// Décode et valide une réponse brute. Lève [ContractException] si le texte
  /// n'est pas du JSON ou ne respecte pas le schéma.
  Map<String, dynamic> checkResponse(String body) {
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw const ContractException(['réponse non JSON']);
    }
    final errors = responseErrors(json);
    if (errors.isNotEmpty) throw ContractException(errors);
    return json! as Map<String, dynamic>;
  }
}

extension FeedbackContract on ContractValidator {
  /// RET-01 : réponse de POST /remontee décodée et validée. Sans schéma
  /// chargé, aucune réponse n'est acceptée.
  Map<String, dynamic> checkFeedbackResponse(String body) {
    final schema = _feedback;
    if (schema == null) {
      throw const ContractException(['schéma de remontée absent']);
    }
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw const ContractException(['réponse non JSON']);
    }
    final errors = ContractValidator._errors(schema, json);
    if (errors.isNotEmpty) throw ContractException(errors);
    return json! as Map<String, dynamic>;
  }
}

class ContractException implements Exception {
  const ContractException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'ContractException(${errors.take(3).join(' ; ')})';
}
