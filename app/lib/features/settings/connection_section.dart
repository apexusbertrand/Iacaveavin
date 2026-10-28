import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/enrichment/contract_validator.dart';
import '../../data/enrichment/enrichment_gateway.dart';
import '../../data/enrichment/enrichment_providers.dart';
import '../../data/enrichment/n8n_gateway.dart';
import '../../data/flux_credentials.dart';
import '../../data/settings_store.dart';

/// PAR-05 : adresse du flux n8n, clé secrète (stockage sécurisé, jamais
/// réaffichée) et test de connexion (`/sante` puis un appel signé).
class ConnectionSection extends ConsumerStatefulWidget {
  const ConnectionSection({super.key});

  @override
  ConsumerState<ConnectionSection> createState() => _ConnectionSectionState();
}

class _ConnectionSectionState extends ConsumerState<ConnectionSection> {
  late final TextEditingController _url;
  final _key = TextEditingController();
  String? _result;
  bool _resultOk = false;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: ref.read(settingsProvider).fluxUrl);
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  bool _validUrl(String v) {
    final u = Uri.tryParse(v.trim());
    return u != null && u.scheme == 'https' && u.host.isNotEmpty;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_validUrl(_url.text)) {
      setState(() {
        _result = l.fluxUrlInvalid;
        _resultOk = false;
      });
      return;
    }
    final store = ref.read(secretStoreProvider);
    if (_key.text.trim().isNotEmpty) await store.write(_key.text.trim());
    _key.clear();
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            fluxUrl: _url.text.trim(),
            installationId: s.installationId ?? const Uuid().v4(),
          ),
        );
    ref.invalidate(fluxKeyPresentProvider);
    messenger.showSnackBar(SnackBar(content: Text(l.fluxSaved)));
  }

  Future<void> _forget() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(secretStoreProvider).delete();
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(fluxUrl: ''));
    _url.clear();
    ref.invalidate(fluxKeyPresentProvider);
    setState(() => _result = null);
    messenger.showSnackBar(SnackBar(content: Text(l.fluxForgotten)));
  }

  Future<void> _test() async {
    final l = AppLocalizations.of(context);
    if (!_validUrl(_url.text)) {
      setState(() {
        _result = l.fluxUrlInvalid;
        _resultOk = false;
      });
      return;
    }
    setState(() => _testing = true);
    final typed = _key.text.trim();
    final key = typed.isNotEmpty
        ? typed
        : await ref.read(secretStoreProvider).read() ?? '';
    final gateway = N8nGateway(
      baseUrl: _url.text.trim(),
      key: key,
      installationId:
          ref.read(settingsProvider).installationId ?? const Uuid().v4(),
      validator: await ref.read(contractValidatorProvider.future),
    );
    String result;
    var ok = false;
    try {
      final c = await gateway.check();
      switch (c.status) {
        case ConnectionStatus.ok:
          result = l.fluxTestOk(c.version ?? '?');
          ok = true;
        case ConnectionStatus.notReady:
          result = l.fluxTestNotReady;
        case ConnectionStatus.badKey:
          result = l.fluxTestBadKey(c.message ?? '');
      }
    } on OfflineException {
      result = l.fluxTestOffline;
    } on ContractException {
      result = l.fluxTestInvalid;
    } finally {
      gateway.close();
    }
    if (!mounted) return;
    setState(() {
      _testing = false;
      _result = result;
      _resultOk = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final real = ref.watch(settingsProvider.select((s) => s.usesRealFlux));
    final hasKey = ref.watch(fluxKeyPresentProvider).value ?? false;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.settingsConnectionHint, style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.m),
          TextField(
            key: const ValueKey('flux-url'),
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l.fluxUrl,
              hintText: l.fluxUrlHint,
            ),
          ),
          const SizedBox(height: SpacingTokens.m),
          TextField(
            key: const ValueKey('flux-key'),
            controller: _key,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: hasKey ? l.fluxKeyReplace : l.fluxKey,
              helperText: hasKey ? l.fluxKeyStored : l.fluxKeyMissing,
            ),
          ),
          const SizedBox(height: SpacingTokens.m),
          Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.s,
            children: [
              FilledButton(
                key: const ValueKey('flux-save'),
                onPressed: _save,
                child: Text(l.fluxSave),
              ),
              OutlinedButton.icon(
                key: const ValueKey('flux-test'),
                onPressed: _testing ? null : _test,
                icon: const Icon(Icons.wifi_tethering),
                label: Text(_testing ? l.fluxTesting : l.fluxTest),
              ),
              if (real || hasKey)
                TextButton(onPressed: _forget, child: Text(l.fluxForget)),
            ],
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.m),
              child: Text(
                _result!,
                key: const ValueKey('flux-result'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _resultOk ? palette.text : theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: SpacingTokens.s),
          Text(
            real && hasKey ? l.fluxUsingReal : l.fluxUsingFake,
            key: const ValueKey('flux-mode'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
