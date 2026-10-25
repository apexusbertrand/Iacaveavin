// Sortie corrigée de l'agent prix : mêmes contrôles, pages du premier passage.
// @inclure schema.js
// @inclure normalisation.js
// @inclure metier.js
// @inclure modele.js
// @inclure prix.js
const e = $('Déclencheur prix').first().json;
const d = $('Décision prix').first().json;
const avant = $('Contrôles prix').first().json;
const a = analyserSortiePrix($input.first().json, { requete: e.requete, jour: d.jour, domainesMarchands: d.domaines, schemaReponse: __SCHEMA_REPONSE__, dejaLues: avant.lues || [] });
a.cout = { appels_modele: a.cout.appels_modele + avant.cout.appels_modele, credits_recherche: a.cout.credits_recherche + avant.cout.credits_recherche };
return [{ json: { ...a, cle: d.cle, cache: false, erreurs_avant: avant.erreurs } }];
