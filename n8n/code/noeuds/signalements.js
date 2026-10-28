// PRV-R4 (contrat 1.2) : une ligne par valeur signalée fausse par
// l'utilisateur, gardée 24 mois (docs/06). Aucune ligne sans signalement.
// @inclure normalisation.js
const envoi = $('Déclencheur enrichissement').first().json;
const jour = jourParis(new Date());
return (envoi.requete.signalements || []).map((s) => ({
  json: { job_id: envoi.job_id, champ: s.champ, valeur: s.valeur, date_signalement: jour },
}));
