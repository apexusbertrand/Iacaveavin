// Cache des vins (docs/06, étape 3) : une entrée de moins de 180 jours
// évite les recherches web. La lecture d'étiquette a déjà eu lieu. Une entrée
// sans source web (recherche en panne ce jour-là) est ignorée, comme toute
// entrée quand la requête porte un signalement d'erreur (PRV-R4, docs/06).
const l = $('Lecture étiquette').first().json;
const signale = (($('Déclencheur enrichissement').first().json.requete || {}).signalements || []).length > 0;
const ligne = $input.all().map((i) => i.json).find((r) => r.cle && r.cle === l.cle) || null;
const age = ligne ? Date.now() - Date.parse(ligne.date_maj || ligne.updatedAt || 0) : Infinity;
let source = false;
try {
  const r = ligne && JSON.parse(ligne.resultat);
  source = !!r && Array.isArray(r.sources_consultees) && r.sources_consultees.length > 0;
} catch (e) {
  // Entrée illisible : relance de l'agent.
}
const frais = l.avec_cle && ligne && age < 180 * 86400000 && source && !signale;
return [{ json: { ...l, cache: !!frais, cache_ligne: ligne ? { id: ligne.id, utilisations: ligne.utilisations || 0, resultat: ligne.resultat, date_maj: ligne.date_maj } : null } }];
