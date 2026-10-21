// Contrôles de sortie de l'agent (docs/06, étape 10) et validation
// contre le schéma. Une sortie refusée est renvoyée une fois à l'agent avec
// les erreurs, puis le job passe en erreur.
// @inclure schema.js
// @inclure normalisation.js
// @inclure metier.js
// @inclure modele.js
// @inclure agent.js
const envoi = $('Déclencheur enrichissement').first().json;
const l = $('Lecture étiquette').first().json;
const a = analyserSortieAgent($input.first().json, {
  schemaReponse: __SCHEMA_REPONSE__, transcription: l.transcription,
  anneeCourante: new Date().getFullYear(), champsVerrouilles: envoi.requete.champs_verrouilles || [],
});
return [{ json: { ...a, cache: false, cle: l.cle, avec_cle: l.avec_cle, sortie: String($input.first().json.output || '').slice(0, 60000) } }];
