import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/flux_credentials.dart';
import 'account_section.dart';

/// CPT-07 : le compte a son propre menu, à droite, symétrique du menu de
/// navigation à gauche. L'icône de la barre du haut l'ouvre.
class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(signedInProvider);
    return IconButton(
      key: const ValueKey('account-menu'),
      tooltip: signedIn ? l.accountMenuSignedIn : l.accountMenu,
      icon: Icon(
        signedIn ? Icons.account_circle : Icons.account_circle_outlined,
      ),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}

/// CPT-07 : menu de compte (connexion, formule, quotas, abonnement,
/// déconnexion, suppression du compte).
class AccountDrawer extends StatelessWidget {
  const AccountDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Drawer(
      key: const ValueKey('account-drawer'),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.l),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.l,
                0,
                SpacingTokens.l,
                SpacingTokens.m,
              ),
              child: Text(l.accountTitle, style: theme.textTheme.titleLarge),
            ),
            AccountSection(onSignedIn: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }
}
