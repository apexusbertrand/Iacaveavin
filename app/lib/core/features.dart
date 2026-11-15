/// Fonctions activables de l'app.
library;

/// PRX-08 (T144) : relevé automatique du prix marché suspendu, les relevés
/// ne remontaient pas. L'app ne le demande plus au flux, ni à
/// l'identification, ni sur une fiche, ni pour toute la cave. La saisie d'un
/// prix à la main (PRX-07) et l'historique déjà enregistré restent.
/// Remettre à vrai pour réactiver, sans autre changement.
const marketPriceLookup = false;
