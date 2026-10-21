import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/wine_detail.dart';
import '../../domain/wine_validation.dart';
import '../wine_detail/stock_dialogs.dart';
import '../wine_detail/wine_detail_screen.dart';
import 'list_picker.dart';

/// Création ou modification d'une fiche (FIC-01, FIC-02, PRX-01).
class WineEditScreen extends ConsumerWidget {
  const WineEditScreen({super.key, this.wineId});

  /// null : nouvelle fiche.
  final String? wineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (wineId == null) return const _EditForm(initial: null);
    return ref
        .watch(wineDetailProvider(wineId!))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(),
            body: MessageStateView(
              icon: Icons.error_outline,
              isError: true,
              title: l.operationFailed('$e'),
            ),
          ),
          data: (w) => w == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: MessageStateView(
                    icon: Icons.search_off,
                    title: l.wineNotFound,
                  ),
                )
              : _EditForm(initial: w),
        );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.initial});

  final WineDetail? initial;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final WineDraft? _d = widget.initial?.draft;
  late final _producer = TextEditingController(text: _d?.producer);
  late final _cuvee = TextEditingController(text: _d?.cuvee);
  late final _vintage = TextEditingController(text: _d?.vintage);
  late final _lieuDit = TextEditingController(text: _d?.lieuDit);
  late final _alcohol = TextEditingController(text: _fmt(_d?.alcohol));
  late final _start = TextEditingController(text: _int(_d?.gardeStart));
  late final _peak = TextEditingController(text: _int(_d?.gardePeak));
  late final _end = TextEditingController(text: _int(_d?.gardeEnd));
  late final _ean = TextEditingController(text: _d?.ean);
  late final _lwin = TextEditingController(text: _d?.lwin);
  late final _site = TextEditingController(text: _d?.producerWebsite);
  late final _producerComment = TextEditingController(
    text: _d?.producerComment,
  );
  late final _vintageComment = TextEditingController(text: _d?.vintageComment);
  late final _personal = TextEditingController(text: _d?.personalComment);

  late String _country = _d?.country ?? 'FR';
  late String? _region = _d?.region;
  late String? _subRegion = _d?.subRegion;
  late String? _appellation = _d?.appellation;
  late String? _sign = _d?.qualitySign;
  late String? _classification = _d?.classification;
  late String _color = _d?.color ?? 'rouge';
  late String? _type = _d?.wineType;
  late String? _certification = _d?.certification;
  late List<GrapeShare> _grapes = [...?_d?.grapes];
  late List<String> _pairings = [...?_d?.pairings];
  late bool _favorite = _d?.favorite ?? false;
  LotDraft? _lot;
  String? _defaultOwner;
  ValidationErrors _errors = const {};
  bool _saving = false;

  bool get _creating => widget.initial == null;

  static String _fmt(double? v) => v == null ? '' : '$v'.replaceAll('.', ',');
  static String _int(int? v) => v == null ? '' : '$v';

  @override
  void initState() {
    super.initState();
    if (_creating) _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final cellarId = await ref.read(bootstrapProvider.future);
    final settings = ref.read(settingsProvider);
    final owner =
        settings.defaultOwnerId ??
        await ref.read(referenceRepositoryProvider).defaultOwner(cellarId);
    if (mounted) setState(() => _defaultOwner = owner);
  }

  @override
  void dispose() {
    for (final c in [
      _producer,
      _cuvee,
      _vintage,
      _lieuDit,
      _alcohol,
      _start,
      _peak,
      _end,
      _ean,
      _lwin,
      _site,
      _producerComment,
      _vintageComment,
      _personal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  WineDraft _draft() => WineDraft(
    producer: _producer.text.trim(),
    cuvee: _t(_cuvee),
    country: _country,
    region: _region,
    subRegion: _subRegion,
    appellation: _appellation,
    qualitySign: _sign,
    classification: _classification,
    lieuDit: _t(_lieuDit),
    color: _color,
    wineType: _type,
    certification: _certification,
    vintage: _vintage.text.trim().toUpperCase(),
    grapes: _grapes,
    alcohol: double.tryParse(_alcohol.text.trim().replaceAll(',', '.')),
    vintageComment: _t(_vintageComment),
    gardeStart: int.tryParse(_start.text.trim()),
    gardePeak: int.tryParse(_peak.text.trim()),
    gardeEnd: int.tryParse(_end.text.trim()),
    pairings: _pairings,
    ean: _t(_ean),
    lwin: _t(_lwin),
    producerWebsite: _t(_site),
    producerComment: _t(_producerComment),
    personalComment: _t(_personal),
    favorite: _favorite,
  );

  String? _errorText(AppLocalizations l, String key) => switch (_errors[key]) {
    'required' => l.errorRequired,
    'vintage' => l.errorVintage,
    'alcohol' => l.errorAlcohol,
    'garde_order' => l.errorGardeOrder,
    'ean' => l.errorEan,
    'lwin' => l.errorLwin,
    'grapes_total' => l.errorGrapesTotal,
    _ => null,
  };

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final draft = _draft();
    final errors = validateWine(
      draft,
      currentYear: ref.read(currentYearProvider),
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty || (_creating && _lot == null)) return;
    final repo = ref.read(cellarRepositoryProvider);
    if (_creating) {
      final dup = await repo.findDuplicate(draft);
      if (dup != null && mounted) {
        final choice = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.duplicateTitle),
            content: Text(l.duplicateBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l.openExisting),
              ),
              TextButton(
                key: const ValueKey('create-anyway'),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.createAnyway),
              ),
            ],
          ),
        );
        if (choice == null || !mounted) return;
        if (choice) {
          context.pushReplacement('/fiche/$dup');
          return;
        }
      }
    }
    if (!mounted) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cellarId = await ref.read(bootstrapProvider.future);
      if (_creating) {
        final id = await repo.createWine(draft, cellarId: cellarId, lot: _lot);
        if (mounted) context.pushReplacement('/fiche/$id');
      } else {
        await repo.updateWine(widget.initial!.id, draft);
        if (mounted) context.pop();
      }
      messenger.showSnackBar(SnackBar(content: Text(l.wineSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.operationFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// FIC-02 : choisir l'appellation renseigne la sous-région, la région et
  /// le pays, en remontant les parents des listes.
  Future<void> _resolveHierarchy(String appellation) async {
    final repo = ref.read(referenceRepositoryProvider);
    final app = (await repo.values('appellation'))
        .where((v) => v.code == appellation)
        .firstOrNull;
    if (app?.parentCode == null) return;
    final subRegions = await repo.values('sous_region');
    final regions = await repo.values('region');
    var regionCode = app!.parentCode;
    final sub = subRegions.where((v) => v.code == app.parentCode).firstOrNull;
    setState(() => _subRegion = sub?.code);
    if (sub != null) regionCode = sub.parentCode;
    final region = regions.where((v) => v.code == regionCode).firstOrNull;
    if (region == null) return;
    setState(() {
      _region = region.code;
      if (region.parentCode != null) _country = region.parentCode!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = ref.watch(labelsProvider).value ?? const {};
    String? label(String list, String? code) =>
        code == null ? null : labels['$list:$code'] ?? code;

    Widget pick(
      String title,
      String list,
      String? value,
      ValueChanged<String?> onPicked, {
      String? parent,
      String? error,
      bool allowNone = true,
    }) => ListField(
      label: title,
      value: label(list, value),
      error: error,
      onTap: () async {
        final r = await pickListValue(
          context,
          ref,
          list: list,
          title: title,
          parentCode: parent,
          allowNone: allowNone,
        );
        if (r != null) onPicked(r.code);
      },
    );

    Widget text(
      TextEditingController c,
      String title, {
      String? error,
      String? hint,
      TextInputType? keyboard,
      int maxLines = 1,
      Key? key,
    }) => TextField(
      key: key,
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: title,
        hintText: hint,
        errorText: error,
      ),
    );

    const gap = SizedBox(height: SpacingTokens.s);
    final year = TextInputType.number;

    return Scaffold(
      appBar: AppBar(
        title: Text(_creating ? l.newWineTitle : l.editWineTitle),
        actions: [
          IconButton(
            key: const ValueKey('save-wine'),
            tooltip: l.save,
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.l),
        children: [
          text(
            _producer,
            l.fieldProducer,
            key: const ValueKey('field-producer'),
            error: _errorText(l, 'domaine'),
          ),
          gap,
          text(_cuvee, l.fieldCuvee, key: const ValueKey('field-cuvee')),
          gap,
          text(
            _vintage,
            l.fieldVintage,
            key: const ValueKey('field-vintage'),
            hint: l.fieldVintageHint,
            error: _errorText(l, 'millesime'),
          ),
          gap,
          pick(
            l.fieldColor,
            'couleur',
            _color,
            (v) => setState(() => _color = v ?? _color),
            allowNone: false,
          ),
          gap,
          pick(
            l.fieldType,
            'type_vin',
            _type,
            (v) => setState(() => _type = v),
          ),
          _section(l.sectionOrigin),
          pick(l.fieldAppellation, 'appellation', _appellation, (v) {
            setState(() => _appellation = v);
            if (v != null) _resolveHierarchy(v);
          }, parent: _subRegion ?? _region),
          gap,
          pick(
            l.fieldCountry,
            'pays',
            _country,
            (v) => setState(() => _country = v ?? _country),
            error: _errorText(l, 'pays'),
            allowNone: false,
          ),
          gap,
          pick(
            l.fieldRegion,
            'region',
            _region,
            (v) => setState(() => _region = v),
            parent: _country,
          ),
          gap,
          pick(
            l.fieldSubRegion,
            'sous_region',
            _subRegion,
            (v) => setState(() => _subRegion = v),
            parent: _region,
          ),
          gap,
          pick(
            l.fieldQualitySign,
            'signe_qualite',
            _sign,
            (v) => setState(() => _sign = v),
          ),
          gap,
          pick(
            l.fieldClassification,
            'classement',
            _classification,
            (v) => setState(() => _classification = v),
          ),
          gap,
          text(_lieuDit, l.fieldLieuDit),
          gap,
          pick(
            l.fieldCertification,
            'certification',
            _certification,
            (v) => setState(() => _certification = v),
          ),
          _section(l.sectionWine),
          _GrapesEditor(
            grapes: _grapes,
            labels: labels,
            error: _errorText(l, 'cepages'),
            onChanged: (g) => setState(() => _grapes = g),
          ),
          gap,
          text(
            _alcohol,
            l.fieldAlcohol,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            error: _errorText(l, 'degre'),
          ),
          gap,
          Row(
            children: [
              Expanded(
                child: text(
                  _start,
                  l.fieldGardeStart,
                  keyboard: year,
                  error: _errorText(l, 'garde_debut'),
                ),
              ),
              const SizedBox(width: SpacingTokens.s),
              Expanded(
                child: text(
                  _peak,
                  l.fieldGardePeak,
                  keyboard: year,
                  error: _errorText(l, 'garde_apogee'),
                ),
              ),
              const SizedBox(width: SpacingTokens.s),
              Expanded(
                child: text(
                  _end,
                  l.fieldGardeEnd,
                  keyboard: year,
                  error: _errorText(l, 'garde_fin'),
                ),
              ),
            ],
          ),
          gap,
          ListField(
            label: l.fieldPairings,
            value: _pairings.map((p) => label('accord_mets', p)).join(', '),
            onTap: () async {
              final r = await pickListValue(
                context,
                ref,
                list: 'accord_mets',
                title: l.addPairing,
                allowNone: false,
              );
              if (r?.code != null && !_pairings.contains(r!.code)) {
                setState(() => _pairings = [..._pairings, r.code!]);
              }
            },
          ),
          if (_pairings.isNotEmpty)
            Wrap(
              spacing: SpacingTokens.s,
              children: [
                for (final p in _pairings)
                  InputChip(
                    label: Text(label('accord_mets', p) ?? p),
                    onDeleted: () =>
                        setState(() => _pairings = [..._pairings]..remove(p)),
                  ),
              ],
            ),
          gap,
          text(
            _ean,
            l.fieldEan,
            keyboard: TextInputType.number,
            error: _errorText(l, 'ean'),
          ),
          gap,
          text(
            _lwin,
            l.fieldLwin,
            keyboard: TextInputType.number,
            error: _errorText(l, 'lwin'),
          ),
          gap,
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.fieldFavorite),
            value: _favorite,
            onChanged: (v) => setState(() => _favorite = v),
          ),
          _section(l.sectionComments),
          text(_site, l.fieldProducerSite, keyboard: TextInputType.url),
          gap,
          text(_producerComment, l.fieldProducerComment, maxLines: 4),
          gap,
          text(_vintageComment, l.fieldVintageComment, maxLines: 4),
          gap,
          text(_personal, l.fieldPersonalComment, maxLines: 4),
          if (_creating) ...[
            _section(l.firstLot),
            if (_defaultOwner == null)
              const Center(child: CircularProgressIndicator())
            else
              LotForm(
                initial: LotDraft(
                  ownerId: _defaultOwner!,
                  quantity: 1,
                  locationId: ref.read(settingsProvider).defaultLocationId,
                ),
                onChanged: (d) => _lot = d,
              ),
          ],
          const SizedBox(height: SpacingTokens.xl),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
          const SizedBox(height: SpacingTokens.xxl),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(
      top: SpacingTokens.xl,
      bottom: SpacingTokens.s,
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: context.palette.primaryText),
    ),
  );
}

/// Cépages avec pourcentage facultatif.
class _GrapesEditor extends ConsumerWidget {
  const _GrapesEditor({
    required this.grapes,
    required this.labels,
    required this.onChanged,
    this.error,
  });

  final List<GrapeShare> grapes;
  final Map<String, String> labels;
  final ValueChanged<List<GrapeShare>> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.fieldGrapes, style: theme.textTheme.bodyLarge),
        for (final (i, g) in grapes.indexed)
          Row(
            children: [
              Expanded(child: Text(labels['cepage:${g.code}'] ?? g.code)),
              SizedBox(
                width: SpacingTokens.xxl * 2.5,
                child: TextFormField(
                  initialValue: g.percent?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(suffixText: l.grapePercent),
                  onChanged: (v) {
                    final next = [...grapes];
                    next[i] = GrapeShare(g.code, int.tryParse(v));
                    onChanged(next);
                  },
                ),
              ),
              IconButton(
                tooltip: l.removeGrape,
                icon: const Icon(Icons.close),
                onPressed: () => onChanged([...grapes]..removeAt(i)),
              ),
            ],
          ),
        if (error != null)
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final r = await pickListValue(
                context,
                ref,
                list: 'cepage',
                title: l.addGrape,
                allowNone: false,
              );
              if (r?.code != null && grapes.every((g) => g.code != r!.code)) {
                onChanged([...grapes, GrapeShare(r!.code!)]);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l.addGrape),
          ),
        ),
      ],
    );
  }
}
