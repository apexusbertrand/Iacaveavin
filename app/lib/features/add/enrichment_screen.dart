import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/db/app_database.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/enrichment_queue.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/enrichment.dart';
import '../../domain/wine_detail.dart';
import '../wine_detail/stock_dialogs.dart';
import '../wine_detail/wine_detail_screen.dart';
import 'validation_screen.dart';

final latestJobProvider = StreamProvider.family<Job?, String>((
  ref,
  wineId,
) async* {
  final queue = await ref.watch(enrichmentQueueProvider.future);
  yield* queue.watchLatestJob(wineId);
});

/// Photos d'une fiche (miniatures), pour les écrans d'ajout et la fiche.
final winePhotosProvider = FutureProvider.family<List<File>, String>((
  ref,
  wineId,
) async {
  ref.watch(latestJobProvider(wineId));
  final service = ref.watch(photoServiceProvider);
  return [
    for (final p in await service.bottlePhotosOf(wineId))
      await service.thumbOf(p),
  ];
});

/// AJO-04, AJO-05, AJO-09, AJO-11 : pendant que l'agent travaille,
/// l'utilisateur renseigne le lot ; l'avancement s'affiche en clair.
class EnrichmentScreen extends ConsumerWidget {
  const EnrichmentScreen({super.key, required this.wineId});

  final String wineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wine = ref.watch(wineDetailProvider(wineId));
    final job = ref.watch(latestJobProvider(wineId)).value;
    final report = ref.watch(enrichmentRunnerProvider);
    final photos = ref.watch(winePhotosProvider(wineId)).value ?? const [];
    final last = EnrichmentQueue.lastResponse(job);
    final w = wine.value;
    if (w == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.enrichTitle)),
        body: wine.isLoading
            ? const Center(child: CircularProgressIndicator())
            : MessageStateView(icon: Icons.search_off, title: l.wineNotFound),
      );
    }
    final status = w.enrichmentStatus;
    final left = last?.enrichmentsLeft;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.enrichTitle),
        actions: [
          IconButton(
            tooltip: l.close,
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(SpacingTokens.l),
          children: [
            if (photos.isNotEmpty)
              SizedBox(
                height: SpacingTokens.xxl * 3,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in photos)
                      Padding(
                        padding: const EdgeInsets.only(right: SpacingTokens.s),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.badge,
                          ),
                          child: Image.file(f, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: SpacingTokens.l),
            _Progress(
              status: status,
              job: job,
              last: last,
              offline: report?.offline == true,
            ),
            if (status == WineStatus.running && last?.result != null)
              _LabelPreview(result: last!.result!),
            if (quotaLow(left, monthlyEnrichmentQuota))
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.s),
                child: Text(
                  l.quotaLeft(left!),
                  key: const ValueKey('quota'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: SpacingTokens.m),
            if (status == WineStatus.toValidate)
              FilledButton.icon(
                key: const ValueKey('review-proposals'),
                onPressed: () =>
                    context.pushReplacement('/fiche/$wineId/validation'),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l.reviewProposals),
              ),
            if (status == WineStatus.error)
              OutlinedButton.icon(
                key: const ValueKey('enrich-retry'),
                onPressed: () async {
                  await (await ref.read(enrichmentQueueProvider.future))
                      .retry(wineId);
                  ref.read(enrichmentRunnerProvider.notifier).kick();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l.enrichRetry),
              ),
            const SizedBox(height: SpacingTokens.xl),
            Text(
              l.enrichLotTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.palette.primaryText,
              ),
            ),
            const SizedBox(height: SpacingTokens.s),
            if (w.lots.isEmpty)
              _LotEditor(wine: w)
            else
              for (final lot in w.lots)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    l.lotLine(
                      lot.ownerName,
                      '${lot.formatCl.round()}',
                      lot.bottles,
                    ),
                  ),
                  subtitle: Text(lot.locationPath ?? l.noLocation),
                ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.status,
    required this.job,
    required this.last,
    required this.offline,
  });

  final String status;
  final Job? job;
  final JobResponse? last;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String text;
    Widget? leading;
    switch (status) {
      case WineStatus.toValidate:
        text = l.enrichReady;
        leading = Icon(Icons.check_circle, color: context.palette.success);
      case WineStatus.error:
        final reason = switch (job?.erreur) {
          'delai_depasse' => l.errorTimeout,
          final e? when e.startsWith('reponse_invalide') => l.errorInvalid,
          final e? => e,
          null => '',
        };
        text = l.enrichFailed(reason);
        leading = Icon(Icons.error_outline, color: theme.colorScheme.error);
      case 'brouillon':
        text = l.consentRefused;
      default:
        text = offline && job?.jobIdDistant == null
            ? l.enrichOffline
            : l.stepLabel(job?.jobIdDistant == null ? null : last?.step);
        leading = offline
            ? const Icon(Icons.cloud_off_outlined)
            : const SizedBox.square(
                dimension: SpacingTokens.xl,
                child: CircularProgressIndicator(strokeWidth: 3),
              );
    }
    return Row(
      children: [
        ?leading,
        const SizedBox(width: SpacingTokens.m),
        Expanded(
          child: Text(
            text,
            key: const ValueKey('enrich-progress'),
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

/// AJO-05, T111 : ce que la lecture a trouvé sur l'étiquette, affiché pendant
/// que l'agent cherche. Rien n'est enregistré : les valeurs arrivent avec le
/// résultat final, à valider.
class _LabelPreview extends StatelessWidget {
  const _LabelPreview({required this.result});

  static const fields = [
    'domaine',
    'cuvee',
    'appellation',
    'millesime',
    'couleur',
    'degre',
    'volume_cl',
  ];

  final EnrichmentResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final read = [
      for (final f in fields)
        if (result.fields[f] case final v? when !v.isEmpty)
          (f, formatProposed(v.value)),
    ];
    if (read.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('label-preview'),
      padding: const EdgeInsets.only(top: SpacingTokens.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.labelPreviewTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: context.palette.primaryText,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          for (final (f, v) in read)
            Text(
              l.labelPreviewLine(l.contractFieldLabel(f), v),
              key: ValueKey('label-preview-$f'),
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

/// AJO-04 : lot pré-rempli avec les valeurs par défaut.
class _LotEditor extends ConsumerStatefulWidget {
  const _LotEditor({required this.wine});

  final WineDetail wine;

  @override
  ConsumerState<_LotEditor> createState() => _LotEditorState();
}

class _LotEditorState extends ConsumerState<_LotEditor> {
  String? _owner;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final cellarId = await ref.read(bootstrapProvider.future);
      final settings = ref.read(settingsProvider);
      final owner =
          settings.defaultOwnerId ??
          await ref.read(referenceRepositoryProvider).defaultOwner(cellarId);
      if (mounted) setState(() => _owner = owner);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_owner == null) return const Center(child: CircularProgressIndicator());
    return LotForm(
      initial: LotDraft(
        ownerId: _owner!,
        quantity: 1,
        locationId: ref.read(settingsProvider).defaultLocationId,
      ),
      onSubmit: (d) async {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(cellarRepositoryProvider).addLot(widget.wine.id, d);
        messenger.showSnackBar(SnackBar(content: Text(l.lotSaved)));
      },
    );
  }
}
