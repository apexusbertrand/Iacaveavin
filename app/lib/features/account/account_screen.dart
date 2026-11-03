import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.g.dart';
import 'account_section.dart';

/// CPT-01 : écran de connexion ouvert depuis l'identification ou la remontée
/// quand aucun compte n'est connecté. Il se referme dès la connexion. Même
/// contenu que le menu de compte (CPT-07).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.l),
        children: [
          AccountSection(
            onSignedIn: () {
              if (context.canPop()) context.pop();
            },
          ),
        ],
      ),
    );
  }
}
