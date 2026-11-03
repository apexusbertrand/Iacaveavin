import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// CPT-06 : formules d'abonnement proposées (V7, docs/decisions.md).
enum SubscriptionPlan { monthly, yearly }

enum SubscriptionOutcome { started, unavailable, failed }

/// Achat et gestion de l'abonnement. L'achat passera par Google Play Billing
/// (et les achats intégrés Apple sur iOS) une fois les produits créés dans la
/// Play Console et la vérification du reçu branchée côté flux (T131) ; d'ici
/// là, [StoreUnavailableSubscriptions] répond « indisponible ».
abstract interface class SubscriptionStore {
  Future<SubscriptionOutcome> subscribe(SubscriptionPlan plan);

  /// Désabonnement : géré par le store, qui seul peut l'arrêter.
  Future<bool> openManagement();
}

/// Page des abonnements Google Play de l'app.
final subscriptionsPage = Uri.parse(
  'https://play.google.com/store/account/subscriptions?package=fr.apexus.iacaveavin',
);

class StoreUnavailableSubscriptions implements SubscriptionStore {
  const StoreUnavailableSubscriptions();

  @override
  Future<SubscriptionOutcome> subscribe(SubscriptionPlan plan) async =>
      SubscriptionOutcome.unavailable;

  @override
  Future<bool> openManagement() =>
      launchUrl(subscriptionsPage, mode: LaunchMode.externalApplication);
}

final subscriptionStoreProvider = Provider<SubscriptionStore>(
  (ref) => const StoreUnavailableSubscriptions(),
);
