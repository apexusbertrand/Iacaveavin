import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/navigation/app_drawer.dart';
import '../../core/navigation/destinations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.g.dart';
import '../../data/backup_providers.dart';
import '../../data/providers.dart';
import '../../data/settings_store.dart';
import '../../domain/app_settings.dart';
import '../wine_detail/price_actions.dart';
import 'connection_section.dart';

const _currencies = ['EUR', 'CHF', 'USD', 'GBP', 'CAD'];

/// Paramètres : réglages (PAR-05) et paramétrage (PRO-01, PAR-01, PAR-06).
/// Ni flux ni jeu de démonstration dans l'app publiée (T122).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _set(AppSettings Function(AppSettings) change) =>
      ref.read(settingsProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final owners = ref.watch(ownersProvider).value ?? const [];
    final locations = ref.watch(locationsProvider).value ?? const [];
    final photoSpace = ref.watch(photoSpaceProvider);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.l,
        SpacingTokens.xl,
        SpacingTokens.l,
        SpacingTokens.s,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: context.palette.primaryText,
        ),
      ),
    );

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.l,
        vertical: SpacingTokens.xs,
      ),
      child: child,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      drawer: const AppDrawer(current: AppDestination.settings),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.xxl),
        children: [
          header(l.settingsGeneral),
          padded(
            DropdownButtonFormField<String>(
              initialValue: s.currency,
              decoration: InputDecoration(labelText: l.settingsCurrency),
              items: [
                for (final c in {..._currencies, s.currency})
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => _set((x) => x.copyWith(currency: v)),
            ),
          ),
          padded(
            InputDecorator(
              decoration: InputDecoration(labelText: l.settingsLanguage),
              child: Text(l.languageFrench),
            ),
          ),
          padded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.settingsTheme, style: theme.textTheme.bodyLarge),
                const SizedBox(height: SpacingTokens.xs),
                SegmentedButton<AppThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      label: Text(l.themeSystem),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text(l.themeLight),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text(l.themeDark),
                    ),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) =>
                      _set((x) => x.copyWith(themeMode: v.first)),
                ),
              ],
            ),
          ),
          if (owners.isNotEmpty)
            padded(
              DropdownButtonFormField<String?>(
                initialValue: owners.any((o) => o.id == s.defaultOwnerId)
                    ? s.defaultOwnerId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.settingsDefaultOwner),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.none)),
                  for (final o in owners)
                    DropdownMenuItem(value: o.id, child: Text(o.name)),
                ],
                onChanged: (v) =>
                    _set((x) => x.copyWith(defaultOwnerId: () => v)),
              ),
            ),
          if (locations.isNotEmpty)
            padded(
              DropdownButtonFormField<String?>(
                initialValue: locations.any((o) => o.id == s.defaultLocationId)
                    ? s.defaultLocationId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l.settingsDefaultLocation,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.none)),
                  for (final loc in locations)
                    DropdownMenuItem(
                      value: loc.id,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: SpacingTokens.l * loc.depth,
                        ),
                        child: Text(loc.name),
                      ),
                    ),
                ],
                onChanged: (v) =>
                    _set((x) => x.copyWith(defaultLocationId: () => v)),
              ),
            ),
          ListTile(
            title: Text(l.settingsDefaultSort),
            subtitle: Text(l.settingsDefaultSortSet),
            trailing: const Icon(Icons.sort),
            onTap: () => _set((x) => x.copyWith(defaultQuery: x.listQuery)),
          ),
          padded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.settingsScale, style: theme.textTheme.bodyLarge),
                const SizedBox(height: SpacingTokens.xs),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 20, label: Text(l.scale20)),
                    ButtonSegment(value: 100, label: Text(l.scale100)),
                  ],
                  selected: {s.personalScale},
                  onSelectionChanged: (v) =>
                      _set((x) => x.copyWith(personalScale: v.first)),
                ),
                const SizedBox(height: SpacingTokens.m),
                Text(l.settingsCardPrice, style: theme.textTheme.bodyLarge),
                const SizedBox(height: SpacingTokens.xs),
                SegmentedButton<CardPrice>(
                  segments: [
                    ButtonSegment(
                      value: CardPrice.purchase,
                      label: Text(l.cardPricePurchase),
                    ),
                    ButtonSegment(
                      value: CardPrice.market,
                      label: Text(l.cardPriceMarket),
                    ),
                  ],
                  selected: {s.cardPrice},
                  onSelectionChanged: (v) =>
                      _set((x) => x.copyWith(cardPrice: v.first)),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsNotifications),
            subtitle: Text(l.settingsNotificationsHint),
            value: s.notifications,
            onChanged: (v) => _set((x) => x.copyWith(notifications: v)),
          ),
          SwitchListTile(
            key: const ValueKey('auto-prices'),
            title: Text(l.settingsAutoPrices),
            subtitle: Text(l.settingsAutoPricesHint),
            value: s.autoPriceRefresh,
            onChanged: (v) => _set((x) => x.copyWith(autoPriceRefresh: v)),
          ),
          ListTile(
            key: const ValueKey('prices-all'),
            leading: const Icon(Icons.euro),
            title: Text(l.pricesAllTitle),
            subtitle: Text(l.pricesAllHint),
            onTap: () => refreshAllPrices(context, ref),
          ),
          header(l.settingsConnection),
          const ConnectionSection(),
          ListTile(
            title: Text(l.settingsPhotoSpace),
            leading: const Icon(Icons.photo_outlined),
            trailing: Text(
              photoSpace.whenOrNull(data: formatBytes) ?? l.emptyValue,
            ),
          ),
          header(l.settingsReference),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l.settingsOwners),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/parametres/proprietaires'),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(l.settingsLists),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/parametres/listes'),
          ),
          ListTile(
            leading: const Icon(Icons.hourglass_bottom),
            title: Text(l.settingsGardeRules),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/parametres/garde'),
          ),
        ],
      ),
    );
  }
}

/// Taille lisible : « 0 o », « 350 Ko », « 2,4 Mo ».
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes o';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} Ko';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(1).replaceAll('.', ',')} Mo';
}
