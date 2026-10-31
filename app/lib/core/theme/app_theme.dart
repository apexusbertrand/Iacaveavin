import 'package:flutter/material.dart';

import 'design_tokens.g.dart';

/// Couleurs du thème qui n'ont pas d'équivalent direct dans [ColorScheme].
///
/// Les widgets lisent toujours leurs couleurs ici ou dans le [ColorScheme],
/// jamais en dur (règle 7 de CLAUDE.md).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.appBar,
    required this.onAppBar,
    required this.card,
    required this.text,
    required this.textSecondary,
    required this.primaryText,
    required this.separator,
    required this.success,
  });

  final Color appBar;
  final Color onAppBar;
  final Color card;
  final Color text;
  final Color textSecondary;

  /// Orange lisible comme texte sur fond clair (jamais `primary`).
  final Color primaryText;
  final Color separator;
  final Color success;

  static const light = AppPalette(
    appBar: LightTokens.appBar,
    onAppBar: LightTokens.onAppBar,
    card: LightTokens.carte,
    text: LightTokens.texte,
    textSecondary: LightTokens.texteSecondaire,
    primaryText: LightTokens.primaryTexte,
    separator: LightTokens.separateur,
    success: LightTokens.succes,
  );

  static const dark = AppPalette(
    appBar: DarkTokens.appBar,
    onAppBar: DarkTokens.onAppBar,
    card: DarkTokens.carte,
    text: DarkTokens.texte,
    textSecondary: DarkTokens.texteSecondaire,
    primaryText: DarkTokens.primaryTexte,
    separator: DarkTokens.separateur,
    success: DarkTokens.succes,
  );

  @override
  AppPalette copyWith({
    Color? appBar,
    Color? onAppBar,
    Color? card,
    Color? text,
    Color? textSecondary,
    Color? primaryText,
    Color? separator,
    Color? success,
  }) {
    return AppPalette(
      appBar: appBar ?? this.appBar,
      onAppBar: onAppBar ?? this.onAppBar,
      card: card ?? this.card,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      primaryText: primaryText ?? this.primaryText,
      separator: separator ?? this.separator,
      success: success ?? this.success,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      appBar: Color.lerp(appBar, other.appBar, t)!,
      onAppBar: Color.lerp(onAppBar, other.onAppBar, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Couleur sémantique d'un vin et couleur du texte posé dessus.
///
/// [code] est une valeur de la liste « couleur » du dictionnaire.
({Color fill, Color onFill}) wineColor(String code) {
  return switch (code) {
    'rouge' => (fill: WineColorTokens.rouge, onFill: OnWineColorTokens.rouge),
    'blanc' => (fill: WineColorTokens.blanc, onFill: OnWineColorTokens.blanc),
    'rose' => (fill: WineColorTokens.rose, onFill: OnWineColorTokens.rose),
    'champagne' => (
      fill: WineColorTokens.champagne,
      onFill: OnWineColorTokens.champagne,
    ),
    'effervescent' => (
      fill: WineColorTokens.effervescent,
      onFill: OnWineColorTokens.effervescent,
    ),
    'liquoreux' => (
      fill: WineColorTokens.liquoreux,
      onFill: OnWineColorTokens.liquoreux,
    ),
    'orange' => (
      fill: WineColorTokens.orange,
      onFill: OnWineColorTokens.orange,
    ),
    _ => (fill: WineColorTokens.autre, onFill: OnWineColorTokens.autre),
  };
}

/// Polices emoji de secours (Android, iOS) pour les drapeaux.
const emojiFallback = [
  'Noto Color Emoji',
  'NotoColorEmoji',
  'Apple Color Emoji',
];

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    palette: AppPalette.light,
    surface: LightTokens.surface,
    primary: LightTokens.primary,
    onPrimary: LightTokens.onPrimary,
    secondary: LightTokens.secondary,
    error: LightTokens.erreur,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    palette: AppPalette.dark,
    surface: DarkTokens.surface,
    primary: DarkTokens.primary,
    onPrimary: DarkTokens.onPrimary,
    secondary: DarkTokens.secondary,
    error: DarkTokens.erreur,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color error,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: palette.card,
      error: error,
      onError: palette.card,
      surface: surface,
      onSurface: palette.text,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerLowest: palette.card,
      surfaceContainerLow: palette.card,
      surfaceContainer: palette.card,
      outline: palette.textSecondary,
      outlineVariant: palette.separator,
    );

    final textStyles = TextTheme(
      titleLarge: TextStyle(
        fontSize: FontSizeTokens.titre,
        fontWeight: FontWeightTokens.gras,
        color: palette.text,
      ),
      titleMedium: TextStyle(
        fontSize: FontSizeTokens.sousTitre,
        fontWeight: FontWeightTokens.gras,
        color: palette.text,
      ),
      bodyLarge: TextStyle(
        fontSize: FontSizeTokens.corps,
        fontWeight: FontWeightTokens.normal,
        color: palette.text,
      ),
      bodyMedium: TextStyle(
        fontSize: FontSizeTokens.secondaire,
        fontWeight: FontWeightTokens.normal,
        color: palette.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: FontSizeTokens.legende,
        fontWeight: FontWeightTokens.normal,
        color: palette.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: FontSizeTokens.corps,
        fontWeight: FontWeightTokens.moyen,
      ),
      displaySmall: TextStyle(
        fontSize: FontSizeTokens.millesimeCarte,
        fontWeight: FontWeightTokens.gras,
        color: palette.text,
      ),
    );
    // Drapeaux des pays (emoji) : police de secours nommée, la police système
    // reste celle du téléphone.
    final textTheme = textStyles.apply(fontFamilyFallback: emojiFallback);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.bouton),
    );
    const minSize = Size(minTouchTarget, minTouchTarget);

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.appBar,
        foregroundColor: palette.onAppBar,
        iconTheme: IconThemeData(color: palette.onAppBar),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        surfaceTintColor: palette.card,
        margin: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.m,
          vertical: SpacingTokens.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.carte),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.separator),
      drawerTheme: DrawerThemeData(backgroundColor: palette.card),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: minSize,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primaryText,
          minimumSize: minSize,
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primaryText,
          minimumSize: minSize,
          shape: buttonShape,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.text,
        selectedColor: palette.primaryText,
        minTileHeight: minTouchTarget,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.appBar,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: palette.onAppBar,
        ),
      ),
    );
    // Titre de la barre : style du thème complet (police comprise), pas le
    // style brut qui n'a pas de police nommée.
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: palette.onAppBar,
        ),
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Couleur de la pastille de statut de garde.
Color cellarStatusColor(String code) => switch (code) {
  'trop_jeune' => CellarStatusTokens.trop_jeune,
  'a_boire' => CellarStatusTokens.a_boire,
  'apogee' => CellarStatusTokens.apogee,
  'a_boire_vite' => CellarStatusTokens.a_boire_vite,
  'passe' => CellarStatusTokens.passe,
  _ => CellarStatusTokens.inconnu,
};

/// Couleurs du badge de note selon la note sur 100 (design-tokens.json).
({Color fill, Color onFill}) scoreBadgeColors(double scoreOn100) {
  for (final s in ScoreBadgeTokens.seuils) {
    if (scoreOn100 >= s.min) return (fill: s.fond, onFill: s.texte);
  }
  final last = ScoreBadgeTokens.seuils.last;
  return (fill: last.fond, onFill: last.texte);
}
