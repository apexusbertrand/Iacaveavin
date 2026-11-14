import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/flux_credentials.dart';
import '../../data/subscription_store.dart';
import '../../domain/account.dart';
import '../wine_detail/stock_dialogs.dart' show confirm;

/// CPT-01 à CPT-04 : connexion par code reçu par mail, puis état du compte
/// (adresse, statut, quotas du mois) et déconnexion. Sert dans les
/// Paramètres et sur l'écran /compte.
class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key, this.onSignedIn});

  /// Appelé après une connexion réussie (l'écran /compte se referme).
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _show(String? text, {bool error = true}) => setState(() {
    _message = text;
    _messageIsError = error;
  });

  String _outcomeText(AppLocalizations l, AccountOutcome o) => switch (o) {
    AccountOffline() => l.accountOffline,
    AccountInvalid() => l.accountInvalid,
    AccountAnswered(:final reply) => reply.errorMessage ?? l.accountInvalid,
  };

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestCode() async {
    final l = AppLocalizations.of(context);
    if (!isValidAccountEmail(_email.text)) {
      _show(l.accountEmailInvalid);
      return;
    }
    await _run(() async {
      final o = await ref
          .read(accountProvider.notifier)
          .requestCode(_email.text);
      if (!mounted) return;
      if (o case AccountAnswered(:final reply) when !reply.isError) {
        setState(() => _codeSent = true);
        _show(l.accountCodeSent(normalizeEmail(_email.text)), error: false);
      } else {
        _show(_outcomeText(l, o));
      }
    });
  }

  Future<void> _signIn() async {
    final l = AppLocalizations.of(context);
    if (!isValidLoginCode(_code.text)) {
      _show(l.accountCodeInvalid);
      return;
    }
    await _run(() async {
      final o = await ref
          .read(accountProvider.notifier)
          .signIn(_email.text, _code.text);
      if (!mounted) return;
      if (o case AccountAnswered(:final reply) when reply.session != null) {
        _code.clear();
        setState(() => _codeSent = false);
        _show(null);
        widget.onSignedIn?.call();
      } else {
        if (o case AccountAnswered(:final reply)
            when reply.errorCode == 'code_expire') {
          setState(() => _codeSent = false);
        }
        _show(_outcomeText(l, o));
      }
    });
  }

  Future<void> _refresh() async {
    final l = AppLocalizations.of(context);
    await _run(() async {
      final o = await ref.read(accountProvider.notifier).refresh();
      if (!mounted) return;
      if (o case AccountAnswered(:final reply) when !reply.isError) {
        _show(l.accountRefreshed, error: false);
      } else {
        _show(_outcomeText(l, o));
      }
    });
  }

  Future<void> _signOut() async {
    final l = AppLocalizations.of(context);
    await _run(() => ref.read(accountProvider.notifier).signOut());
    if (mounted) _show(l.accountSignedOut, error: false);
  }

  String _status(AppLocalizations l, AccountStatus s) => switch (s) {
    AccountStatus.free => l.accountStatusFree,
    AccountStatus.subscriber => l.accountStatusSubscriber,
    AccountStatus.blocked => l.accountStatusBlocked,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(accountProvider).value;
    final signedIn = ref.watch(signedInProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (session != null && signedIn)
            ..._signedIn(l, theme, session)
          else
            ..._signedOut(l, theme),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.m),
              child: Text(
                _message!,
                key: const ValueKey('account-message'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _messageIsError
                      ? theme.colorScheme.error
                      : context.palette.text,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _signedIn(
    AppLocalizations l,
    ThemeData theme,
    AccountSession session,
  ) {
    final a = session.account;
    return [
      Text(
        l.accountSignedInAs(a.email),
        key: const ValueKey('account-email'),
        style: theme.textTheme.titleSmall,
      ),
      const SizedBox(height: SpacingTokens.xs),
      Text(
        l.accountStatusLine(_status(l, a.status)),
        key: const ValueKey('account-status'),
        style: theme.textTheme.bodyMedium,
      ),
      Text(
        l.accountQuotaLine(a.quota.enrichmentsLeft, a.quota.pricesLeft),
        key: const ValueKey('account-quota'),
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: SpacingTokens.m),
      Wrap(
        spacing: SpacingTokens.s,
        runSpacing: SpacingTokens.s,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('account-refresh'),
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
            label: Text(l.accountRefresh),
          ),
          TextButton(
            key: const ValueKey('account-signout'),
            onPressed: _busy ? null : _signOut,
            child: Text(l.accountSignOut),
          ),
        ],
      ),
      // CPT-06 : abonnement mensuel ou annuel, désabonnement par le store.
      // CPT-08 : masqué tant que l'achat n'est pas branché, sauf pour gérer
      // un abonnement existant.
      if (ref.watch(subscriptionStoreProvider).available ||
          a.status == AccountStatus.subscriber) ...[
        const Divider(height: SpacingTokens.xxl),
        Text(l.subscriptionTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: SpacingTokens.xs),
        if (a.status == AccountStatus.subscriber) ...[
          Text(l.subscriptionActive, style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.s),
          OutlinedButton.icon(
            key: const ValueKey('subscription-manage'),
            onPressed: _busy ? null : _manageSubscription,
            icon: const Icon(Icons.open_in_new),
            label: Text(l.subscriptionManage),
          ),
        ] else ...[
          Text(l.subscriptionOffer, style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.s),
          Wrap(
            spacing: SpacingTokens.s,
            runSpacing: SpacingTokens.s,
            children: [
              FilledButton.tonal(
                key: const ValueKey('subscribe-monthly'),
                onPressed: _busy
                    ? null
                    : () => _subscribe(SubscriptionPlan.monthly),
                child: Text(l.subscriptionMonthly),
              ),
              FilledButton.tonal(
                key: const ValueKey('subscribe-yearly'),
                onPressed: _busy
                    ? null
                    : () => _subscribe(SubscriptionPlan.yearly),
                child: Text(l.subscriptionYearly),
              ),
            ],
          ),
        ],
      ],
      const Divider(height: SpacingTokens.xxl),
      // CPT-05 : suppression du compte, confirmée avant l'envoi.
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const ValueKey('account-delete'),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          onPressed: _busy ? null : _delete,
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(l.accountDelete),
        ),
      ),
    ];
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    final l = AppLocalizations.of(context);
    final r = await ref.read(subscriptionStoreProvider).subscribe(plan);
    if (!mounted) return;
    switch (r) {
      case SubscriptionOutcome.started:
        _show(l.subscriptionStarted, error: false);
      case SubscriptionOutcome.unavailable:
        _show(l.subscriptionUnavailable, error: false);
      case SubscriptionOutcome.failed:
        _show(l.subscriptionFailed);
    }
  }

  Future<void> _manageSubscription() async {
    final l = AppLocalizations.of(context);
    final ok = await ref.read(subscriptionStoreProvider).openManagement();
    if (!ok && mounted) _show(l.subscriptionManageFailed);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final yes = await confirm(
      context,
      title: l.accountDeleteTitle,
      body: l.accountDeleteBody,
      action: l.accountDeleteConfirm,
    );
    if (!yes || !mounted) return;
    await _run(() async {
      final o = await ref.read(accountProvider.notifier).deleteAccount();
      if (!mounted) return;
      if (o case AccountAnswered(:final reply)
          when reply.status == 'supprime') {
        _show(l.accountDeleted, error: false);
      } else {
        _show(_outcomeText(l, o));
      }
    });
  }

  List<Widget> _signedOut(AppLocalizations l, ThemeData theme) => [
    Text(l.accountHint, style: theme.textTheme.bodyMedium),
    const SizedBox(height: SpacingTokens.m),
    TextField(
      key: const ValueKey('account-email-field'),
      controller: _email,
      enabled: !_codeSent,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(labelText: l.accountEmail),
    ),
    if (_codeSent) ...[
      const SizedBox(height: SpacingTokens.m),
      TextField(
        key: const ValueKey('account-code-field'),
        controller: _code,
        keyboardType: TextInputType.number,
        autocorrect: false,
        enableSuggestions: false,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: l.accountCode,
          helperText: l.accountCodeHelp,
        ),
      ),
    ],
    const SizedBox(height: SpacingTokens.m),
    Wrap(
      spacing: SpacingTokens.s,
      runSpacing: SpacingTokens.s,
      children: [
        if (!_codeSent)
          FilledButton(
            key: const ValueKey('account-request-code'),
            onPressed: _busy ? null : _requestCode,
            child: Text(l.accountRequestCode),
          )
        else ...[
          FilledButton(
            key: const ValueKey('account-signin'),
            onPressed: _busy ? null : _signIn,
            child: Text(l.accountSignIn),
          ),
          TextButton(
            key: const ValueKey('account-change-email'),
            onPressed: _busy
                ? null
                : () {
                    _code.clear();
                    setState(() => _codeSent = false);
                    _show(null);
                  },
            child: Text(l.accountChangeEmail),
          ),
        ],
      ],
    ),
  ];
}
