import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

class IaCaveAVinApp extends StatefulWidget {
  const IaCaveAVinApp({super.key, this.initialLocation = '/'});

  final String initialLocation;

  @override
  State<IaCaveAVinApp> createState() => _IaCaveAVinAppState();
}

class _IaCaveAVinAppState extends State<IaCaveAVinApp> {
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
