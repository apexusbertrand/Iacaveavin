// Réponse du suivi GET /jobs?job_id=…. Dépend de securite.js, schema.js et
// enveloppes.js.
if (typeof require !== 'undefined' && typeof enveloppeJob === 'undefined') Object.assign(globalThis, require('./enveloppes.js'));

/**
 * Réponse de GET /jobs?job_id=… (signature d'un corps vide, chemin signé
 * avec sa requête : /webhook/iacave/jobs?job_id=<id>, décision T63).
 */
function reponseSuivi({ entetes, jobId, config, job, ligneQuota, maintenant, schemaReponse }) {
  const quota = quotaRestant(config, ligneQuota);
  const auth = verifierRequete({
    entetes, methode: 'GET', chemin: '/webhook/iacave/jobs?job_id=' + jobId, corps: new Uint8Array(),
    cle: config.cle_app, maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return { http: HTTP[auth.code], reponse: enveloppeErreur(auth.code, auth.message, { jobId }) };
  if (!job || !job.job_id) {
    return { http: 404, reponse: enveloppeErreur('requete_invalide', 'Job inconnu ou expiré.', { jobId, reessayable: false }) };
  }
  let reponse = enveloppeJob(job, quota);
  const age = maintenant - Date.parse(job.createdAt || job.updatedAt || 0);
  if (['en_attente', 'en_cours'].includes(job.statut) && age > DELAI_JOB_MS) {
    reponse = enveloppeErreur('delai_depasse', 'Le flux n\'a pas terminé dans le délai : relancez l\'enrichissement.', {
      jobId: job.job_id, requestId: job.request_id, type: job.type, quota, ficheId: job.fiche_id,
    });
  }
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) {
    reponse = enveloppeErreur('interne', 'Réponse enregistrée hors contrat.', { jobId: job.job_id, requestId: job.request_id, type: job.type });
    return { http: 500, reponse, erreurs: verif };
  }
  return { http: 200, reponse };
}

if (typeof module !== 'undefined') {
  module.exports = { ...require('./enveloppes.js'), reponseSuivi };
}
