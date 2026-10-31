// GET /iacave/jobs?job_id=… : état du job au contrat, délai de 4 min. Signé
// avec la clé du compte ; un compte ne suit que ses propres jobs.
// @inclure securite.js
// @inclure schema.js
// @inclure enveloppes.js
// @inclure suivi.js
// @inclure comptes.js
const w = $('Webhook suivi').first().json;
const config = lireConfig($('Config suivi').all().map((i) => i.json));
const compte = $('Compte suivi').all().map((i) => i.json).find((r) => r.compte_id) || null;
const trouve = $('Job suivi').all().map((i) => i.json).find((r) => r.job_id) || null;
const ligneUsage = $('Quota suivi').all().map((i) => i.json).find((r) => r.compte_id) || null;
const maintenant = Date.now();
const jobId = String((w.query && w.query.job_id) || '');
let r;
if (!compteActif(compte, maintenant)) {
  r = { http: 401, reponse: enveloppeErreur('auth_invalide', 'Connectez-vous à votre compte.', { jobId, reessayable: false }) };
} else {
  r = reponseSuivi({
    entetes: w.headers || {}, jobId, config: configPourCompte(config, compte, maintenant),
    job: trouve && trouve.compte_id === compte.compte_id ? trouve : null,
    ligneQuota: ligneUsage && ligneUsage.compte_id === compte.compte_id ? ligneUsage : null,
    maintenant, schemaReponse: __SCHEMA_REPONSE__,
  });
}
return [{ json: r }];
