// Contrôles de sortie de l'agent (docs/06, étape 10) et validation
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
// Recherche intégrée (T85) : sources refaites à partir des URL vues.
const sortie = $input.first().json;
const texte = completerSources(texteDe(sortie), urlsVues(sortie), jourParis(new Date()));
const a = analyserSortieAgent(texte, {
  schemaReponse: __SCHEMA_REPONSE__, transcription: l.transcription,
  anneeCourante: new Date().getFullYear(), champsVerrouilles: envoi.requete.champs_verrouilles || [],
  accordsPermis: __ACCORDS__,
});
a.cout = coutRecherche(sortie);
return [{ json: { ...a, cache: false, cle: l.cle, avec_cle: l.avec_cle, sortie: texteDe(sortie).slice(0, 60000) } }];
