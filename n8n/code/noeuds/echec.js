// Sortie refusée deux fois : job en erreur, rien n'est enregistré dans la
// fiche (AJO-12). Aucun quota décompté.
const c = $input.first().json;
const erreur = { code: 'interne', message: ('Réponse de l\'agent hors contrat : ' + c.erreurs.slice(0, 3).join(' ; ')).slice(0, 480), reessayable: true };
return [{ json: { job_id: $('Déclencheur enrichissement').first().json.job_id, erreur: JSON.stringify(erreur), journal: JSON.stringify({ erreurs: c.erreurs.slice(0, 20), erreurs_avant: c.erreurs_avant || [] }) } }];
