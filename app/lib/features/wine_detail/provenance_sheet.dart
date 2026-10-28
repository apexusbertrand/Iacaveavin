import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/providers.dart';
import '../../domain/wine_detail.dart';
import 'stock_dialogs.dart' show confirm;

/// FIC-06 : pastille discrète à côté d'une valeur enrichie.
class ProvenanceBadge extends StatelessWidget {
  const ProvenanceBadge({super.key, required this.provenance});

  final ProvenanceView provenance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      tooltip: l.provenanceBadge,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        provenance.reported ? Icons.report_outlined : Icons.verified_outlined,
        size: SpacingTokens.l + SpacingTokens.xs,
        color: provenance.reported
            ? Theme.of(context).colorScheme.error
            : context.palette.textSecondary,
      ),
      onPressed: () => showProvenance(context, provenance),
    );
  }
}

/// Source, URL ouvrable, date, confiance et « Signaler une erreur » (PRV-R4).
Future<void> showProvenance(BuildContext context, ProvenanceView p) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => Consumer(
      builder: (sheet, ref, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.provenanceTitle,
                style: Theme.of(sheet).textTheme.titleMedium,
              ),
              const SizedBox(height: SpacingTokens.s),
              Text(l.provenanceSource(l.sourceLabel(p.source))),
              Text(l.provenanceDate(p.date)),
              if (p.confidence != null)
                Text(l.confidence((p.confidence! * 100).round())),
              if (p.url != null) ...[
                const SizedBox(height: SpacingTokens.s),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(p.url!),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    l.provenanceUrl(p.url!),
                    style: TextStyle(
                      color: Theme.of(sheet).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: p.url!));
                    if (sheet.mounted) {
                      ScaffoldMessenger.of(sheet)
                          .showSnackBar(SnackBar(content: Text(l.linkCopied)));
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l.copyLink),
                ),
              ],
              const SizedBox(height: SpacingTokens.m),
              if (p.reported)
                Text(l.reported)
              else
                OutlinedButton.icon(
                  key: const ValueKey('report-error'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(sheet);
                    await ref
                        .read(cellarRepositoryProvider)
                        .reportProvenance(p.id);
                    if (sheet.mounted) Navigator.of(sheet).pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.reportedSnack)),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(l.reportError),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// PRV-R3 : déverrouiller est une action explicite (appui long).
Future<void> unlockDialog(BuildContext context, ProvenanceView p) async {
  final l = AppLocalizations.of(context);
  final container = ProviderScope.containerOf(context);
  final ok = await confirm(
    context,
    title: l.unlockField,
    body: l.lockedField,
    action: l.unlockField,
  );
  if (!ok) return;
  await container.read(cellarRepositoryProvider).unlockField(p.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.unlocked)));
  }
}

/// Bandeau de statut tant que l'enrichissement n'est pas validé (docs/03).
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.wine});

  final WineDetail wine;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (String? text, String? route) = switch (wine.enrichmentStatus) {
      'a_valider' => (l.toValidateBanner, '/fiche/${wine.id}/validation'),
      'en_cours' => (l.enrichingBanner, '/fiche/${wine.id}/identification'),
      'a_enrichir' => (l.toEnrichBanner, '/fiche/${wine.id}/identification'),
      'erreur' => (l.errorBanner, '/fiche/${wine.id}/identification'),
      _ => (null, null),
    };
    if (text == null) return const SizedBox.shrink();
    return Material(
      color: theme.colorScheme.primary,
      child: ListTile(
        key: const ValueKey('status-banner'),
        textColor: theme.colorScheme.onPrimary,
        iconColor: theme.colorScheme.onPrimary,
        leading: const Icon(Icons.auto_awesome_outlined),
        title: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route!),
      ),
    );
  }
}

/// FIC-08 : nouvelle fiche sur la même cuvée, seuls les champs du millésime
/// sont à enrichir.
Future<void> duplicateVintageDialog(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final l = AppLocalizations.of(context);
  final c = TextEditingController();
  final vintage = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.duplicateVintageTitle),
      content: TextField(
        key: const ValueKey('duplicate-vintage'),
        controller: c,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: l.fieldVintage,
          hintText: l.fieldVintageHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const ValueKey('duplicate-save'),
          onPressed: () =>
              Navigator.of(context).pop(c.text.trim().toUpperCase()),
          child: Text(l.save),
        ),
      ],
    ),
  );
  if (vintage == null ||
      !(vintage == 'NM' || RegExp(r'^(19|20)\d{2}$').hasMatch(vintage)) ||
      !context.mounted) {
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final id = await ref
      .read(cellarRepositoryProvider)
      .duplicateForVintage(wine.id, vintage);
  final photos = await ref.read(photoServiceProvider).photosOf(id);
  if (photos.isNotEmpty) {
    await (await ref.read(enrichmentQueueProvider.future)).enqueue(id);
    ref.read(enrichmentRunnerProvider.notifier).kick();
  } else {
    await ref.read(cellarRepositoryProvider).markDraft(id);
  }
  messenger.showSnackBar(SnackBar(content: Text(l.duplicateVintageDone)));
  router.push('/fiche/$id');
}

/// FIC-09 : relance le flux sur les champs non verrouillés ; l'écran de
/// validation montre les différences avant de les appliquer.
Future<void> reEnrich(
  BuildContext context,
  WidgetRef ref,
  WineDetail wine,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final photos = await ref.read(photoServiceProvider).bottlePhotosOf(wine.id);
  if (photos.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l.reEnrichNoPhoto)));
    return;
  }
  await (await ref.read(enrichmentQueueProvider.future)).enqueue(wine.id);
  ref.read(enrichmentRunnerProvider.notifier).kick();
  messenger.showSnackBar(SnackBar(content: Text(l.reEnrichStarted)));
  router.push('/fiche/${wine.id}/identification');
}
