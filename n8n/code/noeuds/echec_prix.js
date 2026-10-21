// Sortie de l'agent prix refusée deux fois. En relevé seul, le job passe en
// erreur ; dans un enrichissement, la fiche reste valable sans prix.
const c = $input.first().json;
const e = $('Déclencheur prix').first().json;
const erreur = { code: 'interne', message: ('Réponse de l\'agent prix hors contrat : ' + c.erreurs.slice(0, 3).join(' ; ')).slice(0, 480), reessayable: true };
return [{ json: {
  mode: e.mode || 'job', job_id: e.job_id, erreur: JSON.stringify(erreur),
  journal: JSON.stringify({ erreurs: c.erreurs.slice(0, 20), erreurs_avant: c.erreurs_avant || [] }),
  retour: { ok: false, motif: erreur.message, cout: c.cout || { appels_modele: 0, credits_recherche: 0 } },
} }];
