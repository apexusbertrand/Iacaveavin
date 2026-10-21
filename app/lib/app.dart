import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/settings_store.dart';
import 'domain/app_settings.dart';

class IaCaveAVinApp extends ConsumerStatefulWidget {
  const IaCaveAVinApp({super.key, this.initialLocation = '/'});

  final String initialLocation;

  @override
  ConsumerState<IaCaveAVinApp> createState() => _IaCaveAVinAppState();
}

class _IaCaveAVinAppState extends ConsumerState<IaCaveAVinApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (ref.watch(
        settingsProvider.select((s) => s.themeMode),
      )) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
