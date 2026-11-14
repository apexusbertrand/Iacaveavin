import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_store.dart';
import '../domain/app_settings.dart';

/// Langues de l'app (LNG-01). Le français reste la langue de référence.
const appLanguageCodes = ['fr', 'en'];

/// LNG-01, LNG-02 : langue effective. « Langue du téléphone » donne
/// l'anglais pour un téléphone en anglais, le français sinon.
String effectiveLanguage(AppLanguage choice, Locale device) => switch (choice) {
  AppLanguage.fr => 'fr',
  AppLanguage.en => 'en',
  AppLanguage.system => device.languageCode == 'en' ? 'en' : 'fr',
};

/// Langue du téléphone, remplaçable en test.
final deviceLocaleProvider = Provider<Locale>(
  (ref) => PlatformDispatcher.instance.locale,
);

/// Code de la langue affichée : fr ou en.
final appLanguageProvider = Provider<String>(
  (ref) => effectiveLanguage(
    ref.watch(settingsProvider.select((s) => s.language)),
    ref.watch(deviceLocaleProvider),
  ),
);
