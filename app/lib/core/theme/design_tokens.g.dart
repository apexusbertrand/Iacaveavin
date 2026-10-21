// GÉNÉRÉ par tool/generate_theme_tokens.dart depuis
// specs/design-tokens.json (version 1).
// Ne pas modifier à la main.
// ignore_for_file: constant_identifier_names

import 'dart:ui';

abstract final class BrandTokens {
  static const Color orange = Color(0xFFF28C28);
  static const Color rougeOrange = Color(0xFFE2541B);
  static const Color anthracite = Color(0xFF1C1C1E);
  static const Color noir = Color(0xFF000000);
}

abstract final class LightTokens {
  static const Color appBar = Color(0xFF1C1C1E);
  static const Color onAppBar = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F3F0);
  static const Color carte = Color(0xFFFFFFFF);
  static const Color texte = Color(0xFF1C1C1E);
  static const Color texteSecondaire = Color(0xFF5A5A60);
  static const Color primary = Color(0xFFF28C28);
  static const Color onPrimary = Color(0xFF1C1C1E);
  static const Color primaryTexte = Color(0xFFB5520F);
  static const Color secondary = Color(0xFF2F5D7C);
  static const Color separateur = Color(0xFFE4DED8);
  static const Color erreur = Color(0xFFB3261E);
  static const Color succes = Color(0xFF1E7A3A);
}

abstract final class DarkTokens {
  static const Color appBar = Color(0xFF000000);
  static const Color onAppBar = Color(0xFFEDEDED);
  static const Color surface = Color(0xFF121212);
  static const Color carte = Color(0xFF1E1E1E);
  static const Color texte = Color(0xFFEDEDED);
  static const Color texteSecondaire = Color(0xFFA8A8AE);
  static const Color primary = Color(0xFFF28C28);
  static const Color onPrimary = Color(0xFF1C1C1E);
  static const Color primaryTexte = Color(0xFFF28C28);
  static const Color secondary = Color(0xFF8DB8D6);
  static const Color separateur = Color(0xFF2C2C2E);
  static const Color erreur = Color(0xFFF2B8B5);
  static const Color succes = Color(0xFF7CCB8F);
}

abstract final class WineColorTokens {
  static const Color rouge = Color(0xFF8E1B2C);
  static const Color blanc = Color(0xFFE9D98B);
  static const Color rose = Color(0xFFF1A7B5);
  static const Color champagne = Color(0xFFC9B26B);
  static const Color effervescent = Color(0xFF7FA7D9);
  static const Color liquoreux = Color(0xFFB8862B);
  static const Color orange = Color(0xFFA3501C);
  static const Color autre = Color(0xFF8C8C8C);
}

abstract final class OnWineColorTokens {
  static const Color rouge = Color(0xFFFFFFFF);
  static const Color blanc = Color(0xFF1C1C1E);
  static const Color rose = Color(0xFF1C1C1E);
  static const Color champagne = Color(0xFF1C1C1E);
  static const Color effervescent = Color(0xFF1C1C1E);
  static const Color liquoreux = Color(0xFF1C1C1E);
  static const Color orange = Color(0xFFFFFFFF);
  static const Color autre = Color(0xFF1C1C1E);
}

abstract final class CellarStatusTokens {
  static const Color trop_jeune = Color(0xFF7FA7D9);
  static const Color a_boire = Color(0xFF1E7A3A);
  static const Color apogee = Color(0xFFC9A227);
  static const Color a_boire_vite = Color(0xFFE2541B);
  static const Color passe = Color(0xFF8C8C8C);
  static const Color inconnu = Color(0xFFC8C8C8);
}

abstract final class FontSizeTokens {
  static const double titre = 22.0;
  static const double sousTitre = 17.0;
  static const double corps = 15.0;
  static const double secondaire = 13.0;
  static const double legende = 12.0;
  static const double millesimeCarte = 28.0;
}

abstract final class FontWeightTokens {
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight moyen = FontWeight.w500;
  static const FontWeight gras = FontWeight.w600;
}

abstract final class SpacingTokens {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

abstract final class RadiusTokens {
  static const double carte = 12.0;
  static const double chip = 20.0;
  static const double bouton = 12.0;
  static const double badge = 6.0;
}

abstract final class ScoreBadgeTokens {
  /// Seuils sur 100, du plus haut au plus bas.
  static const List<({int min, Color fond, Color texte})> seuils = [
    (min: 95, fond: Color(0xFFC9A227), texte: Color(0xFF1C1C1E)),
    (min: 90, fond: Color(0xFF1E7A3A), texte: Color(0xFFFFFFFF)),
    (min: 85, fond: Color(0xFF5E9B4F), texte: Color(0xFF1C1C1E)),
    (min: 0, fond: Color(0xFF8C8C8C), texte: Color(0xFF1C1C1E)),
  ];
}

const double minTouchTarget = 48.0;
