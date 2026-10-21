import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/flag.dart';
import '../../core/labels.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/providers.dart';
import '../../domain/garde.dart';
import '../../domain/wine_list_item.dart';

/// Carte de la liste (docs/03-design-ergonomie.md, capture 01).
class WineCard extends ConsumerWidget {
  const WineCard({
    super.key,
    required this.item,
    required this.currency,
    this.showMarketPrice = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final WineListItem item;
  final NumberFormat currency;

  /// PAR-05 : prix affiché sur les cartes, achat ou marché.
  final bool showMarketPrice;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final wine = wineColor(item.colorCode);
    final year = ref.watch(currentYearProvider);
    final status = item.statusIn(year);
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
    final price = showMarketPrice
        ? (item.marketValue == null || item.bottles == 0
              ? null
              : item.marketValue! / item.bottles)
        : item.purchasePrice;

    return Semantics(
      container: true,
      selected: selected,
      label: l.wineCardSemantics(item.displayName, vintage, bottles),
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: selected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.carte),
                  side: BorderSide(color: theme.colorScheme.primary, width: 3),
                )
              : null,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
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
                        selected ? Icons.check_circle : Icons.wine_bar,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              if (item.favorite)
                                Icon(
                                  Icons.star,
                                  size: SpacingTokens.l,
                                  color: palette.primaryText,
                                ),
                            ],
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
                          const SizedBox(height: SpacingTokens.xs),
                          Wrap(
                            spacing: SpacingTokens.s,
                            runSpacing: SpacingTokens.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (status != CellarStatus.unknown)
                                _StatusDot(
                                  status: status,
                                  label: l.statusLabel(status),
                                ),
                              if (item.parkerScore != null)
                                ScoreBadge(
                                  score: item.parkerScore!,
                                  initial: l.parkerInitial,
                                ),
                              if (item.enrichmentStatus == 'a_valider')
                                _ToValidateMarker(label: l.toValidate),
                            ],
                          ),
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
                          if (price != null)
                            _ScaleDown(
                              Text(
                                currency.format(price),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          _ScaleDown(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BottleIcon(fill: wine.fill),
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
      ),
    );
  }
}

/// Vue compacte (LST-07) : pastille couleur, nom, millésime, quantité.
class CompactWineRow extends StatelessWidget {
  const CompactWineRow({
    super.key,
    required this.item,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final WineListItem item;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vintage = item.isNonVintage ? l.nonVintage : item.vintage;
    return Semantics(
      selected: selected,
      label: l.wineCardSemantics(
        item.displayName,
        vintage,
        l.bottleCount(item.bottles),
      ),
      child: ExcludeSemantics(
        child: ListTile(
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
          leading: selected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : BottleIcon(fill: wineColor(item.colorCode).fill),
          title: Text(
            item.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '$vintage   ${item.bottles}',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

/// Badge de note : couleur selon la note sur 100, initiale de la source.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.score,
    required this.initial,
    this.scale = 100,
  });

  final double score;
  final String initial;
  final int scale;

  @override
  Widget build(BuildContext context) {
    final c = scoreBadgeColors(scale == 20 ? score * 5 : score);
    final text = score == score.roundToDouble()
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(RadiusTokens.badge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.s,
          vertical: SpacingTokens.xs / 2,
        ),
        child: Text(
          '$text $initial',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: c.onFill, fontWeight: FontWeightTokens.gras),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, required this.label});

  final CellarStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SpacingTokens.m,
          height: SpacingTokens.m,
          decoration: BoxDecoration(
            color: cellarStatusColor(status.code),
            shape: BoxShape.circle,
            border: Border.all(color: context.palette.textSecondary),
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
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
class BottleIcon extends StatelessWidget {
  const BottleIcon({super.key, required this.fill});

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
