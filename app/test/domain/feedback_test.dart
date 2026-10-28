import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacaveavin/domain/feedback.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  final schema = JsonSchema.create(
    File('assets/contrat/requete-remontee.schema.json').readAsStringSync(),
  );
  List<String> errors(Object? json) => [
    for (final e in schema.validate(json, validateFormats: true).errors)
      '${e.instancePath} : ${e.message}',
  ];
  // Aller-retour JSON : le schéma voit ce que reçoit le flux.
  Object? wire(FeedbackRequest r) => jsonDecode(jsonEncode(r.toJson()));

  test('RET-01 contrôle du format de l\'adresse de contact', () {
    for (final ok in [
      'prenom.nom@exemple.fr',
      ' bertrand+cave@sous.domaine.com ',
      "o'neil@exemple.co.uk",
    ]) {
      expect(isValidEmail(ok), isTrue, reason: ok);
    }
    for (final ko in [
      '',
      'pas-un-mail',
      'a@b',
      'a@b.c',
      'a b@exemple.fr',
      'a@exemple.fr, b@exemple.fr',
      '@exemple.fr',
      'a@@exemple.fr',
    ]) {
      expect(isValidEmail(ko), isFalse, reason: ko);
    }
  });

  test('RET-01 type de pièce jointe lu dans les octets, pas l\'extension', () {
    Uint8List b(List<int> x) => Uint8List.fromList([...x, 0, 0, 0, 0, 0, 0]);
    expect(attachmentMime(b(ascii.encode('%PDF-1.7'))), 'application/pdf');
    expect(attachmentMime(b([0xFF, 0xD8, 0xFF, 0xE0])), 'image/jpeg');
    expect(
      attachmentMime(b([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])),
      'image/png',
    );
    expect(
      attachmentMime(
        b([...ascii.encode('RIFF'), 1, 2, 3, 4, ...ascii.encode('WEBP')]),
      ),
      'image/webp',
    );
    expect(attachmentMime(b(ascii.encode('PK\u0003\u0004'))), isNull);
    expect(attachmentMime(b(ascii.encode('<html>'))), isNull);
    expect(attachmentMime(Uint8List(0)), isNull);
  });

  test('RET-01 la requête respecte le contrat 1.3, avec ou sans pièce', () {
    final base = FeedbackRequest(
      requestId: '5f0c2a8e-3b1d-4c6e-9a7f-2d4b6c8e0a1b',
      title: '  Fiche fausse  ',
      comment: 'Le millésime lu est 2016, l\'étiquette dit 2018.',
      email: ' bertrand@exemple.fr ',
      clientDate: '2026-10-28',
      appVersion: '0.1.0',
    );
    final json = wire(base)! as Map<String, dynamic>;
    expect(errors(json), isEmpty);
    expect(json['version_contrat'], '1.3');
    expect(json['titre'], 'Fiche fausse');
    expect(json['email_contact'], 'bertrand@exemple.fr');
    expect(json.containsKey('piece_jointe'), isFalse);

    final pdf = Uint8List.fromList(ascii.encode('%PDF-1.4\n%%EOF\n'));
    final withPdf = FeedbackRequest(
      requestId: base.requestId,
      title: base.title,
      comment: base.comment,
      email: base.email,
      clientDate: base.clientDate,
      attachment: FeedbackAttachment(
        name: 'capture.pdf',
        mime: 'application/pdf',
        bytes: pdf,
      ),
    );
    final j2 = wire(withPdf)! as Map<String, dynamic>;
    expect(errors(j2), isEmpty);
    expect(j2['piece_jointe']['base64'], base64Encode(pdf));
    expect(j2.containsKey('version_app'), isFalse);
  });

  test('RET-01 adresse invalide refusée par le contrat aussi', () {
    final r = FeedbackRequest(
      requestId: '5f0c2a8e-3b1d-4c6e-9a7f-2d4b6c8e0a1b',
      title: 'Titre',
      comment: 'Texte',
      email: 'pas-un-mail',
      clientDate: '2026-10-28',
    );
    expect(errors(wire(r)), isNotEmpty);
  });

  test('RET-01 réponse d\'erreur lue : code, message, relance', () {
    final r = FeedbackResult.fromJson({
      'version_contrat': '1.3',
      'request_id': '5f0c2a8e-3b1d-4c6e-9a7f-2d4b6c8e0a1b',
      'statut': 'erreur',
      'envoi_restants_jour': 0,
      'erreur': {
        'code': 'quota_depasse',
        'message': '5 remontées par jour au plus.',
        'reessayable': false,
      },
    });
    expect(r.sent, isFalse);
    expect(r.errorCode, 'quota_depasse');
    expect(r.retryable, isFalse);
    expect(r.remainingToday, 0);
  });
}
