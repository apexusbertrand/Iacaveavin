// Sortie de l'agent prix : seules les offres des pages lues pendant le job,
// sur un site autorisé et du millésime vérifié, entrent dans la médiane.
// @inclure schema.js
// @inclure normalisation.js
// @inclure metier.js
// @inclure modele.js
// @inclure prix.js
const e = $('Déclencheur prix').first().json;
const d = $('Décision prix').first().json;
const a = analyserSortiePrix($input.first().json, { requete: e.requete, jour: d.jour, domainesMarchands: d.domaines, schemaReponse: __SCHEMA_REPONSE__ });
return [{ json: { ...a, cle: d.cle, cache: false, lues: pagesLues($input.first().json), sortie: String($input.first().json.output || '').slice(0, 30000) } }];
