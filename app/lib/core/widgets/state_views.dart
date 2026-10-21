import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.g.dart';

/// État vide ou informatif : icône sobre, titre, texte et action facultative.
class MessageStateView extends StatelessWidget {
  const MessageStateView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: SpacingTokens.xxl * 2,
              color: isError ? theme.colorScheme.error : palette.textSecondary,
            ),
            const SizedBox(height: SpacingTokens.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (body != null) ...[
              const SizedBox(height: SpacingTokens.s),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
