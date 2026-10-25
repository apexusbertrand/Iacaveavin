// Fin du mode interne : le résultat repart vers l'enrichissement appelant.
for (const n of ['Clôture prix', 'Échec prix']) {
  try {
    if ($(n).isExecuted) return [{ json: $(n).first().json.retour }];
  } catch (e) {
    // Nœud absent de cette exécution.
  }
}
throw new Error('aucun résultat de prix à renvoyer');
