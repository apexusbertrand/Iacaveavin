// Contrôles de sortie de l'agent après correction (docs/06, étape 10) et validation
// contre le schéma. Une sortie refusée est renvoyée une fois à l'agent avec
// les erreurs, puis le job passe en erreur.
// @inclure schema.js
// @inclure normalisation.js
// @inclure metier.js
// @inclure modele.js
// @inclure agent.js
// @inclure recherche.js
const envoi = $('Déclencheur enrichissement').first().json;
const l = $('Lecture étiquette').first().json;
// L'agent de correction ne cherche pas : il garde les URL vues au premier passage.
const vues = urlsVues($('Agent enrichissement').first().json);
const texte = completerSources(texteDe($input.first().json), vues, jourParis(new Date()));
const a = analyserSortieAgent(texte, {
  schemaReponse: __SCHEMA_REPONSE__, transcription: l.transcription,
  anneeCourante: new Date().getFullYear(), champsVerrouilles: envoi.requete.champs_verrouilles || [],
  accordsPermis: __ACCORDS__, accordsObligatoires: false,
});
const avant = $('Contrôles de sortie').first().json;
a.cout = { appels_modele: a.cout.appels_modele + avant.cout.appels_modele, credits_recherche: a.cout.credits_recherche + avant.cout.credits_recherche };
return [{ json: { ...a, cache: false, cle: l.cle, avec_cle: l.avec_cle, erreurs_avant: avant.erreurs } }];
