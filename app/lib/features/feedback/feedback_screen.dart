import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_info.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/contract_validator.dart';
import '../../data/enrichment/enrichment_gateway.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/n8n_gateway.dart' show AuthException;
import '../../data/export_providers.dart';
import '../../domain/feedback.dart';
import '../add/capture_screen.dart' show imagePickerProvider;

/// RET-01 : remontée d'information envoyée par mail à l'équipe, copie au
/// contact. Titre, commentaire, mail de contact contrôlé, une pièce jointe
/// PDF ou image au plus.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _comment = TextEditingController();
  final _email = TextEditingController();
  FeedbackAttachment? _attachment;
  bool _preparing = false;
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _comment.dispose();
    _email.dispose();
    super.dispose();
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  /// Pièce jointe : PDF de 5 Mo au plus, ou image ramenée à la taille d'un
  /// écran (CMP-08) pour rester légère.
  Future<void> _attach({required bool camera, required bool file}) async {
    final l = AppLocalizations.of(context);
    final String name;
    final List<int>? raw;
    if (file) {
      final picked = await ref.read(bytesPickerProvider)(
        feedbackAttachmentExtensions,
      );
      if (picked == null) return;
      name = picked.name;
      raw = picked.bytes;
    } else {
      final bytes = await ref.read(imagePickerProvider)(camera: camera);
      if (bytes == null) return;
      name = 'photo.jpg';
      raw = bytes;
    }
    if (!mounted) return;
    final bytes = Uint8List.fromList(raw);
    final mime = attachmentMime(bytes);
    if (mime == null) {
      _snack(l.feedbackAttachmentType);
      return;
    }
    setState(() => _preparing = true);
    try {
      FeedbackAttachment attachment;
      if (mime == 'application/pdf') {
        attachment = FeedbackAttachment(name: name, mime: mime, bytes: bytes);
      } else {
        final photo = await ref
            .read(photoServiceProvider)
            .processForScreen(bytes);
        final base = name.replaceFirst(RegExp(r'\.[A-Za-z0-9]+$'), '');
        attachment = FeedbackAttachment(
          name: '$base.jpg',
          mime: 'image/jpeg',
          bytes: photo.stored,
        );
      }
      if (attachment.bytes.length > feedbackAttachmentMaxBytes) {
        _snack(l.feedbackAttachmentTooBig);
        return;
      }
      if (mounted) setState(() => _attachment = attachment);
    } on FormatException {
      _snack(l.feedbackAttachmentType);
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final gateway = await ref.read(gatewayProvider.future);
      final r = await gateway.sendFeedback(
        FeedbackRequest(
          requestId: const Uuid().v4(),
          title: _title.text,
          comment: _comment.text,
          email: _email.text,
          clientDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          attachment: _attachment,
          appVersion: appVersion,
        ),
      );
      if (!mounted) return;
      if (r.sent) {
        _title.clear();
        _comment.clear();
        setState(() => _attachment = null);
        _snack(l.feedbackSent(_email.text.trim()));
      } else {
        _snack(
          r.errorCode == 'quota_depasse'
              ? l.feedbackQuota
              : l.feedbackRefused(r.message ?? ''),
        );
      }
    } on NotConnectedException {
      _snack(l.feedbackNotConnected);
    } on OfflineException {
      _snack(l.feedbackOffline);
    } on AuthException {
      _snack(l.feedbackAuth);
    } on ContractException {
      _snack(l.feedbackRefused(l.errorInvalid));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: context.palette.textSecondary,
    );
    final a = _attachment;
    final busy = _sending || _preparing;
    return Scaffold(
      appBar: AppBar(title: Text(l.navFeedback)),
      drawer: const AppDrawer(current: AppDestination.feedback),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(SpacingTokens.l),
          children: [
            Text(l.feedbackIntro, style: secondary),
            const SizedBox(height: SpacingTokens.l),
            TextFormField(
              key: const ValueKey('feedback-title'),
              controller: _title,
              maxLength: feedbackTitleMax,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.feedbackTitle),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l.feedbackRequired : null,
            ),
            TextFormField(
              key: const ValueKey('feedback-comment'),
              controller: _comment,
              maxLength: feedbackCommentMax,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(labelText: l.feedbackComment),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l.feedbackRequired : null,
            ),
            TextFormField(
              key: const ValueKey('feedback-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l.feedbackEmail,
                helperText: l.feedbackEmailHelp,
              ),
              validator: (v) => (v ?? '').trim().isEmpty
                  ? l.feedbackRequired
                  : isValidEmail(v!)
                  ? null
                  : l.feedbackEmailInvalid,
            ),
            const SizedBox(height: SpacingTokens.l),
            Text(l.feedbackAttachment, style: theme.textTheme.titleSmall),
            const SizedBox(height: SpacingTokens.xs),
            if (a != null)
              ListTile(
                key: const ValueKey('feedback-attachment'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  a.isImage
                      ? Icons.image_outlined
                      : Icons.picture_as_pdf_outlined,
                ),
                title: Text(a.name),
                subtitle: Text(
                  l.feedbackAttachmentSize(
                    (a.bytes.length / 1024).ceil().toString(),
                  ),
                ),
                trailing: IconButton(
                  key: const ValueKey('feedback-attachment-remove'),
                  tooltip: l.feedbackAttachmentRemove,
                  icon: const Icon(Icons.close),
                  onPressed: busy
                      ? null
                      : () => setState(() => _attachment = null),
                ),
              )
            else
              Text(l.feedbackAttachmentHelp, style: secondary),
            Wrap(
              spacing: SpacingTokens.s,
              children: [
                TextButton.icon(
                  key: const ValueKey('feedback-attach-file'),
                  onPressed: busy
                      ? null
                      : () => _attach(camera: false, file: true),
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    a == null ? l.feedbackAttachFile : l.feedbackReplaceFile,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('feedback-attach-photo'),
                  onPressed: busy
                      ? null
                      : () => _attach(camera: true, file: false),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l.takePhoto),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xl),
            FilledButton.icon(
              key: const ValueKey('feedback-send'),
              onPressed: busy ? null : _send,
              icon: _sending
                  ? const SizedBox.square(
                      dimension: SpacingTokens.l,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(l.feedbackSend),
            ),
            const SizedBox(height: SpacingTokens.s),
            Text(l.feedbackPrivacy, style: secondary),
          ],
        ),
      ),
    );
  }
}
