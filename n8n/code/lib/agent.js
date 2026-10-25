// Contrôles de la sortie de l'agent d'enrichissement. Dépend de modele.js,
// schema.js, normalisation.js et metier.js.
if (typeof require !== 'undefined' && typeof jsonDe === 'undefined') {
  Object.assign(globalThis, require('./modele.js'), require('./schema.js'), require('./metier.js'));
}

/**
 * Sortie de l'agent d'enrichissement → { ok, erreurs, resultat, cout }.
 * La transcription vient de la lecture d'étiquette (elle fait foi) ; les prix
 * sont l'affaire de l'agent prix. Toute propriété inconnue fait échouer la
 * validation (défense contre les contenus piégés).
 */
function analyserSortieAgent(sortie, { schemaReponse, transcription, anneeCourante, champsVerrouilles }) {
  const cout = coutAgent(sortie);
  let brut;
  try {
    brut = jsonDe(texteDe(sortie));
  } catch (e) {
    return { ok: false, erreurs: ['sortie non JSON : ' + e.message], resultat: null, cout };
  }
  if (brut && brut.resultat && !brut.fiche) brut = brut.resultat;
  brut.transcription = transcription;
  delete brut.prix;
  delete brut.cache;
  delete brut.cout;
  if (!Array.isArray(brut.notes_critiques)) brut.notes_critiques = [];
  if (!Array.isArray(brut.alertes)) brut.alertes = [];
  if (!Array.isArray(brut.sources_consultees)) brut.sources_consultees = [];
  const c = controlerEnrichissement(brut, { anneeCourante, champsVerrouilles, domainesMarchands: [] });
  const schema = schemaReponse.$defs.resultat_enrichissement;
  const erreurs = [...c.erreurs, ...validateSchema(schema, c.resultat, schemaReponse)];
  return { ok: erreurs.length === 0, erreurs, resultat: c.resultat, cout };
}

/** Champs principaux tous renseignés : termine, sinon partiel. */
function statutFinal(resultat) {
  const f = resultat.fiche || {};
  return ['domaine', 'appellation', 'millesime', 'couleur'].every((k) => f[k] && f[k].valeur != null) ? 'termine' : 'partiel';
}

if (typeof module !== 'undefined') module.exports = { ...require('./modele.js'), analyserSortieAgent, statutFinal };
