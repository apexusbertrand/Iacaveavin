import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/validation_service.dart';
import '../../data/providers.dart';
import '../../domain/enrichment.dart';
import '../../domain/wine_detail.dart';
import '../photos/photo_crop_screen.dart';
import '../photos/photo_gallery.dart';
import 'enrichment_screen.dart' show winePhotosProvider;

/// Ordre d'affichage des champs proposés (docs/03, fiche).
const _fieldOrder = [
  'domaine',
  'cuvee',
  'millesime',
  'couleur',
  'type',
  'appellation',
  'pays',
  'region',
  'sous_region',
  'signe_qualite',
  'classement',
  'lieu_dit',
  'cepages',
  'degre',
  'garde',
  'accords',
  'certification',
  'lwin',
  'domaine_site_officiel',
  'commentaire_domaine',
  'commentaire_millesime',
];

class _ValidationData {
  const _ValidationData({
    required this.response,
    required this.wine,
    required this.locked,
    this.duplicate,
  });

  final JobResponse response;
  final WineDetail wine;
  final Set<String> locked;
  final String? duplicate;
}

final _validationDataProvider = FutureProvider.autoDispose
    .family<_ValidationData?, String>((ref, wineId) async {
      final queue = await ref.watch(enrichmentQueueProvider.future);
      final response = await queue.resultFor(wineId);
      final wine = await ref.watch(cellarRepositoryProvider).wine(wineId);
      if (response == null || wine == null) return null;
      final validation = await ref.watch(validationServiceProvider.future);
      return _ValidationData(
        response: response,
        wine: wine,
        locked: (await queue.lockedFields(wineId)).toSet(),
        duplicate: await validation.duplicateOf(wineId, response),
      );
    });

/// Valeur proposée au format lisible.
String formatProposed(Object? v) {
  if (v == null) return '';
  if (v is num) {
    return v == v.roundToDouble()
        ? v.toInt().toString()
        : '$v'.replaceAll('.', ',');
  }
  if (v is List) {
    return v
        .map(
          (e) => e is Map
              ? [
                  e['cepage'],
                  if (e['pourcentage'] != null) '${e['pourcentage']} %',
                ].join(' ')
              : '$e',
        )
        .join(', ');
  }
  if (v is Map) {
    return [
      v['debut'],
      if (v['apogee'] != null) v['apogee'],
      v['fin'],
    ].join(' → ');
  }
  return '$v';
}

/// Valeur saisie par l'utilisateur, ramenée au format du contrat.
Object? parseCorrection(String field, String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  switch (field) {
    case 'degre':
      return double.tryParse(t.replaceAll(',', '.'));
    case 'millesime':
      return t.toUpperCase() == 'NM' ? 'NM' : int.tryParse(t);
    case 'accords':
      return [
        for (final a in t.split(','))
          if (a.trim().isNotEmpty) a.trim(),
      ];
    case 'cepages':
      return [
        for (final part in t.split(','))
          if (part.trim().isNotEmpty)
            () {
              final m = RegExp(r'^(.*?)\s*(\d{1,3})\s*%?$')
                  .firstMatch(part.trim());
              return m == null
                  ? {'cepage': part.trim(), 'pourcentage': null}
                  : {'cepage': m[1]!.trim(), 'pourcentage': int.parse(m[2]!)};
            }(),
      ];
    case 'garde':
      final years = RegExp(r'\d{4}')
          .allMatches(t)
          .map((m) => int.parse(m[0]!))
          .toList();
      if (years.length < 2) return null;
      return {
        'debut': years.first,
        'apogee': years.length > 2 ? years[1] : null,
        'fin': years.last,
      };
    default:
      return t;
  }
}

/// AJO-06 : chaque champ proposé avec sa valeur, sa source et sa confiance.
/// AJO-07 : doublon proposé. AJO-08 : enregistrement complet.
class ValidationScreen extends ConsumerStatefulWidget {
  const ValidationScreen({super.key, required this.wineId});

  final String wineId;

  @override
  ConsumerState<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends ConsumerState<ValidationScreen> {
  final _decisions = <String, FieldDecision>{};
  final _rejectedScores = <int>{};
  bool _includePrices = true;
  bool? _merge;
  bool _saving = false;

  Future<void> _save(_ValidationData data) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final service = await ref.read(validationServiceProvider.future);
      final merge = (_merge ?? true) ? data.duplicate : null;
      final out = await service.apply(
        widget.wineId,
        data.response,
        decisions: _decisions,
        rejectedScores: _rejectedScores,
        includePrices: _includePrices,
        mergeIntoWineId: merge,
      );
      messenger.showSnackBar(SnackBar(content: Text(l.validationSaved)));
      if (mounted) {
        context.pushReplacement('/fiche/${out.mergedInto ?? out.wineId}');
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _correct(String field, ProposedValue? p) async {
    final l = AppLocalizations.of(context);
    final current = _decisions[field];
    final c = TextEditingController(
      text: formatProposed(
        current?.kind == DecisionKind.modify ? current!.value : p?.value,
      ),
    );
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.contractFieldLabel(field)),
        content: TextField(
          key: const ValueKey('correction'),
          controller: c,
          autofocus: true,
          maxLines: field.startsWith('commentaire') ? 5 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('correction-save'),
            onPressed: () => Navigator.of(context).pop(c.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (text == null) return;
    final value = parseCorrection(field, text);
    setState(
      () => _decisions[field] = value == null
          ? const FieldDecision.reject()
          : FieldDecision.modify(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(_validationDataProvider(widget.wineId));
    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l.validationTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l.validationTitle)),
        body: MessageStateView(
          icon: Icons.error_outline,
          isError: true,
          title: l.operationFailed('$e'),
        ),
      ),
      data: (data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l.validationTitle)),
            body: MessageStateView(
              icon: Icons.search_off,
              title: l.wineNotFound,
            ),
          );
        }
        final result = data.response.result!;
        final disagreements = result.disagreements;
        final currency = NumberFormat.simpleCurrency(
          locale: Localizations.localeOf(context).toLanguageTag(),
          name: 'EUR',
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(l.validationTitle),
            actions: [
              IconButton(
                key: const ValueKey('validation-save'),
                tooltip: l.saveValidation,
                onPressed: _saving ? null : () => _save(data),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xxl * 2),
            children: [
              if (data.duplicate != null)
                Card(
                  color: theme.colorScheme.primary,
                  child: SwitchListTile(
                    key: const ValueKey('merge-switch'),
                    title: Text(
                      l.duplicateFound,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    subtitle: Text(
                      l.duplicateMerge,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    value: _merge ?? true,
                    onChanged: (v) => setState(() => _merge = v),
                  ),
                ),
              if (result.alerts.isNotEmpty) ...[
                _Header(l.alertsSection),
                for (final a in result.alerts)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(a.message),
                  ),
              ],
              _PhotosSection(wineId: widget.wineId),
              _Header(l.validationTitle),
              for (final field in _fieldOrder)
                if (result.fields.containsKey(field))
                  _FieldTile(
                    field: field,
                    proposed: result.fields[field]!,
                    current: _currentText(data.wine, field),
                    locked: data.locked.contains(field),
                    disagreement: disagreements.contains(field),
                    decision: _decisions[field],
                    onAccept: () => setState(() => _decisions.remove(field)),
                    onReject: () => setState(
                      () => _decisions[field] = const FieldDecision.reject(),
                    ),
                    onModify: () => _correct(field, result.fields[field]),
                  ),
              if (result.scores.isNotEmpty) ...[
                _Header(l.scoresSection),
                for (final (i, s) in result.scores.indexed)
                  CheckboxListTile(
                    value: !_rejectedScores.contains(i),
                    onChanged: (v) => setState(
                      () => v == true
                          ? _rejectedScores.remove(i)
                          : _rejectedScores.add(i),
                    ),
                    title: Text(
                      '${s.critic} · ${formatProposed(s.score)}/${s.scale}',
                    ),
                    subtitle: Text(
                      [
                        if (s.citedBy != null) l.citedBy(s.citedBy!),
                        l.confidence((s.confidence * 100).round()),
                        s.url,
                      ].join(' · '),
                    ),
                  ),
              ],
              if (result.prices.isNotEmpty) ...[
                _Header(l.pricesSection),
                for (final p in result.prices)
                  ListTile(
                    leading: const Icon(Icons.euro),
                    title: Text(
                      p.found && p.price != null
                          ? l.priceFound(
                              currency.format(p.price),
                              p.offerCount ?? p.offers.length,
                              p.date,
                            )
                          : l.priceNotFound(p.date),
                    ),
                  ),
                SwitchListTile(
                  title: Text(l.includePrices),
                  value: _includePrices,
                  onChanged: (v) => setState(() => _includePrices = v),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.l),
                child: FilledButton(
                  key: const ValueKey('accept-all'),
                  onPressed: _saving ? null : () => _save(data),
                  child: Text(l.acceptAll),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _currentText(WineDetail w, String field) {
    final d = w.draft;
    final v = switch (field) {
      'domaine' => d.producer,
      'cuvee' => d.cuvee,
      'millesime' => d.vintage == 'NM' ? null : d.vintage,
      'couleur' =>
        w.enrichmentStatus == 'a_valider' && d.color == 'autre'
            ? null
            : w.label('couleur', d.color),
      'pays' => d.country.isEmpty ? null : w.label('pays', d.country),
      'region' => w.label('region', d.region),
      'sous_region' => w.label('sous_region', d.subRegion),
      'appellation' => w.label('appellation', d.appellation),
      'degre' => d.alcohol == null ? null : formatProposed(d.alcohol),
      'lieu_dit' => d.lieuDit,
      _ => null,
    };
    return v == null || v.isEmpty ? null : v;
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.l,
      SpacingTokens.xl,
      SpacingTokens.l,
      SpacingTokens.xs,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: context.palette.primaryText),
    ),
  );
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.field,
    required this.proposed,
    required this.current,
    required this.locked,
    required this.disagreement,
    required this.decision,
    required this.onAccept,
    required this.onReject,
    required this.onModify,
  });

  final String field;
  final ProposedValue proposed;
  final String? current;
  final bool locked;
  final bool disagreement;
  final FieldDecision? decision;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onModify;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final label = l.contractFieldLabel(field);
    if (proposed.isEmpty) {
      return ListTile(
        dense: true,
        title: Text(label),
        subtitle: Text(l.notFound(proposed.reason ?? '')),
      );
    }
    final low = proposed.lowConfidence;
    final value = formatProposed(proposed.value);
    final kind = decision?.kind ?? DecisionKind.accept;
    return Container(
      key: ValueKey('field-$field'),
      color: low || disagreement
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.l,
        vertical: SpacingTokens.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.primaryText,
            ),
          ),
          // Désaccord étiquette / source : valeur actuelle et proposée côte à côte.
          if (current != null && current != value)
            Text(l.currentValue(current!), style: theme.textTheme.bodyMedium),
          Text(
            kind == DecisionKind.modify
                ? l.modified(formatProposed(decision!.value))
                : value,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: kind == DecisionKind.reject || locked
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          Text(
            [
              l.sourceLabel(proposed.source),
              if (proposed.confidence != null)
                l.confidence((proposed.confidence! * 100).round()),
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
          if (low)
            Text(
              l.lowConfidence,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          if (disagreement)
            Text(
              l.disagreement,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          if (locked)
            Text(l.lockedField, style: theme.textTheme.bodySmall)
          else
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.xs),
              child: Wrap(
                spacing: SpacingTokens.s,
                runSpacing: SpacingTokens.xs,
                children: [
                  for (final (k, text, action) in [
                    (DecisionKind.accept, l.accept, onAccept),
                    (DecisionKind.modify, l.modify, onModify),
                    (DecisionKind.reject, l.reject, onReject),
                  ])
                    ChoiceChip(
                      key: ValueKey('$field-${k.name}'),
                      label: Text(text),
                      selected: kind == k,
                      onSelected: (_) => action(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// AJO-13 : photos recadrées sur l'étiquette à la réception du résultat,
/// retouche du cadre ou retour à la photo entière avant validation.
class _PhotosSection extends ConsumerWidget {
  const _PhotosSection({required this.wineId});

  final String wineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final photos = ref.watch(bottlePhotosProvider(wineId)).value ?? const [];
    if (photos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(l.validationPhotos),
        SizedBox(
          height: SpacingTokens.xxl * 5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
            itemCount: photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: SpacingTokens.m),
            itemBuilder: (context, i) {
              final p = photos[i];
              return Column(
                key: ValueKey('validation-photo-$i'),
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: l.photoOpen(i + 1),
                      child: InkWell(
                        onTap: () =>
                            showPhotoGallery(context, photos, initialIndex: i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.carte,
                          ),
                          child: Image.file(p.thumb, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    p.cropped ? l.photoCroppedLabel : l.photoWholeLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    key: ValueKey('crop-photo-$i'),
                    onPressed: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => PhotoCropScreen(photo: p.photo),
                        ),
                      );
                      if (changed == true) {
                        ref.invalidate(bottlePhotosProvider(wineId));
                        ref.invalidate(winePhotosProvider(wineId));
                      }
                    },
                    icon: const Icon(Icons.crop),
                    label: Text(l.cropAction),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
