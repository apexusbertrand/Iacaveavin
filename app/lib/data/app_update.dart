import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

/// NAV-03 (T146) : nouvelle version proposée par le store au lancement.
abstract interface class AppUpdateChecker {
  /// Vrai si le store propose une version plus récente que celle installée.
  /// Faux sans réseau, hors Play Store (APK installé à la main) ou sur une
  /// plateforme non prise en charge : rien n'est jamais bloquant.
  Future<bool> updateAvailable();

  /// Lance la mise à jour par l'écran du store. Vrai si elle a démarré.
  Future<bool> update();
}

/// Mise à jour par Google Play (in_app_update). Android seulement : sur
/// iPhone, rien n'est proposé tant que l'équivalent App Store n'existe pas
/// (lot 7, écart NFR-12 noté en T146).
class PlayAppUpdateChecker implements AppUpdateChecker {
  const PlayAppUpdateChecker();

  @override
  Future<bool> updateAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed;
    } on Object {
      // Hors Play Store, sans réseau, service indisponible : on n'insiste pas.
      return false;
    }
  }

  @override
  Future<bool> update() async {
    try {
      final r = await InAppUpdate.performImmediateUpdate();
      return r == AppUpdateResult.success;
    } on Object {
      return false;
    }
  }
}

final appUpdateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => const PlayAppUpdateChecker(),
);

/// Vérifiée une seule fois par lancement.
class AppUpdateOnce extends Notifier<bool> {
  @override
  bool build() => false;

  /// Vrai la première fois seulement.
  bool claim() {
    if (state) return false;
    state = true;
    return true;
  }
}

final appUpdateOnceProvider = NotifierProvider<AppUpdateOnce, bool>(
  AppUpdateOnce.new,
);
