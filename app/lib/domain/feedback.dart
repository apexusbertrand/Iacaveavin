import 'dart:convert';
import 'dart:typed_data';

/// RET-01 : même motif que specs/contrat-n8n/requete-remontee.schema.json.
final _emailPattern = RegExp(
  r"^[A-Za-z0-9._%+'-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$",
);

/// Adresse de contact au bon format (une adresse, sans espace).
bool isValidEmail(String text) {
  final t = text.trim();
  return t.length <= 254 && _emailPattern.hasMatch(t);
}

/// Limites du contrat 1.3.
const feedbackTitleMax = 120;
const feedbackCommentMax = 5000;
const feedbackAttachmentMaxBytes = 5 * 1024 * 1024;

/// Extensions proposées au sélecteur de fichiers.
const feedbackAttachmentExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

/// Type réel d'un fichier d'après ses premiers octets : PDF ou image, sinon
/// null (l'extension ne suffit pas).
String? attachmentMime(Uint8List bytes) {
  bool starts(List<int> sig, [int at = 0]) =>
      bytes.length >= at + sig.length &&
      [for (var i = 0; i < sig.length; i++) bytes[at + i] == sig[i]]
          .every((x) => x);
  if (starts([0x25, 0x50, 0x44, 0x46, 0x2D])) return 'application/pdf';
  if (starts([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (starts([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (starts([0x52, 0x49, 0x46, 0x46]) && starts([0x57, 0x45, 0x42, 0x50], 8)) {
    return 'image/webp';
  }
  return null;
}

/// Une seule pièce jointe, PDF ou image.
class FeedbackAttachment {
  const FeedbackAttachment({
    required this.name,
    required this.mime,
    required this.bytes,
  });

  final String name;
  final String mime;
  final Uint8List bytes;

  bool get isImage => mime.startsWith('image/');
}

/// RET-01 : corps de POST /remontee (contrat 1.3).
class FeedbackRequest {
  const FeedbackRequest({
    required this.requestId,
    required this.title,
    required this.comment,
    required this.email,
    required this.clientDate,
    this.attachment,
    this.appVersion,
  });

  final String requestId;
  final String title;
  final String comment;
  final String email;
  final String clientDate;
  final FeedbackAttachment? attachment;
  final String? appVersion;

  Map<String, Object?> toJson() => {
    'version_contrat': '1.3',
    'request_id': requestId,
    'titre': title.trim(),
    'commentaire': comment.trim(),
    'email_contact': email.trim(),
    if (attachment != null)
      'piece_jointe': {
        'nom': attachment!.name.length > 120
            ? attachment!.name.substring(attachment!.name.length - 120)
            : attachment!.name,
        'mime': attachment!.mime,
        'base64': base64Encode(attachment!.bytes),
      },
    'version_app': ?appVersion,
    'date_client': clientDate,
  };
}

/// Réponse de POST /remontee, déjà validée contre le contrat.
class FeedbackResult {
  const FeedbackResult({
    required this.sent,
    this.remainingToday,
    this.errorCode,
    this.message,
    this.retryable = true,
  });

  factory FeedbackResult.fromJson(Map<String, dynamic> j) {
    final err = j['erreur'] as Map<String, dynamic>?;
    return FeedbackResult(
      sent: j['statut'] == 'envoye',
      remainingToday: (j['envoi_restants_jour'] as num?)?.toInt(),
      errorCode: err?['code'] as String?,
      message: err?['message'] as String?,
      retryable: err?['reessayable'] != false,
    );
  }

  final bool sent;
  final int? remainingToday;
  final String? errorCode;
  final String? message;
  final bool retryable;
}
