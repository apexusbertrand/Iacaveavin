// GET /iacave/jobs/:job_id : état du job au contrat, délai de 4 min.
// @inclure securite.js
// @inclure schema.js
// @inclure jobs.js
const w = $('Webhook suivi').first().json;
const config = lireConfig($('Config suivi').all().map((i) => i.json));
const job = $('Job suivi').all().map((i) => i.json).find((r) => r.job_id) || null;
const ligneQuota = $('Quota suivi').all().map((i) => i.json).find((r) => r.mois) || null;
const r = reponseSuivi({
  entetes: w.headers || {}, jobId: (w.params && w.params.job_id) || '', config, job, ligneQuota,
  maintenant: Date.now(), schemaReponse: __SCHEMA_REPONSE__,
});
return [{ json: r }];
