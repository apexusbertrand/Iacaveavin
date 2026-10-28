import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/flag.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../domain/wine_list_item.dart';

/// Carte de la liste (docs/03-design-ergonomie.md, capture 01), en lecture.
class WineCard extends StatelessWidget {
  const WineCard({super.key, required this.item, required this.currency});

  final WineListItem item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final wine = wineColor(item.colorCode);
    final vintage = item.isNonVintage ? l.nonVintage : item.vintage;
    final bottles = l.bottleCount(item.bottles);
    final origin = [
      item.region,
      item.subRegion,
    ].whereType<String>().join(' · ');
    final country = [
      flagEmoji(item.countryCode),
      item.countryLabel,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    return Semantics(
      container: true,
      label: l.wineCardSemantics(item.displayName, vintage, bottles),
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vignette : la photo d'étiquette arrive au lot 2a.
                SizedBox(
                  width: MediaQuery.sizeOf(context).width / 4,
                  child: ColoredBox(
                    color: wine.fill,
                    child: Icon(
                      Icons.wine_bar,
                      color: wine.onFill,
                      size: SpacingTokens.xxl,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (origin.isNotEmpty)
                          Text(
                            origin,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.primaryText,
                            ),
                          ),
                        if (item.appellation != null)
                          Text(
                            item.appellation!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        if (country.isNotEmpty)
                          Text(country, style: theme.textTheme.bodySmall),
                        if (item.enrichmentStatus == 'a_valider') ...[
                          const SizedBox(height: SpacingTokens.xs),
                          _ToValidateMarker(label: l.toValidate),
                        ],
                      ],
                    ),
                  ),
                ),
                // Colonne de droite bornée : à 200 % de police, le millésime
                // et le prix se réduisent au lieu de déborder (NFR-10).
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.3,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ScaleDown(
                          Text(vintage, style: theme.textTheme.displaySmall),
                        ),
                        if (item.purchasePrice != null)
                          _ScaleDown(
                            Text(
                              currency.format(item.purchasePrice),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        _ScaleDown(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BottleIcon(fill: wine.fill),
                              const SizedBox(width: SpacingTokens.xs),
                              Text(
                                '${item.bottles}',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleDown extends StatelessWidget {
  const _ScaleDown(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerRight,
    child: child,
  );
}

/// Bouteille teintée de la couleur du vin, avec contour : le blanc et le rosé
/// seuls n'atteignent pas 3:1 sur une carte blanche (design-tokens.json).
class _BottleIcon extends StatelessWidget {
  const _BottleIcon({required this.fill});

  final Color fill;

  @override
  Widget build(BuildContext context) {
    const size = SpacingTokens.l + SpacingTokens.xs;
    return Stack(
      children: [
        Icon(Icons.wine_bar, color: fill, size: size),
        Icon(
          Icons.wine_bar_outlined,
          color: context.palette.textSecondary,
          size: size,
        ),
      ],
    );
  }
}

class _ToValidateMarker extends StatelessWidget {
  const _ToValidateMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(RadiusTokens.badge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.s,
          vertical: SpacingTokens.xs / 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: scheme.onPrimary),
        ),
      ),
    );
  }
}
