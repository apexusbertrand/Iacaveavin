/// Jeu de démonstration (CMP-07) : 200 fiches fictives, activable et effaçable.
abstract interface class DemoDataRepository {
  /// Nombre de fiches de démonstration présentes (0 si non chargé).
  Future<int> demoWineCount();

  /// Charge le jeu complet. Sans effet s'il est déjà chargé.
  Future<void> load();

  /// Efface le jeu de démonstration, sans toucher aux autres caves.
  Future<void> erase();
}
