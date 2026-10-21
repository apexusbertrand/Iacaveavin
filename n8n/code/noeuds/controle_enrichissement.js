// POST /iacave/enrichissement et POST /iacave/prix : contrôles d'entrée dans
// l'ordre de docs/06 (en-têtes, horodatage, signature, request_id déjà vu,
// quota, schéma). Les deux webhooks partagent cette chaîne ; le type vient du
// webhook qui a reçu la requête.
// @inclure securite.js
// @inclure schema.js
// @inclure enveloppes.js
// @inclure entree.js
const e = $('Empreinte enrichissement').first().json;
let prix = false;
try {
  prix = $('Webhook prix').isExecuted;
} catch (err) {
  // Requête d'enrichissement.
}
const config = lireConfig($('Config enrichissement').all().map((i) => i.json));
const existant = $('Job existant enrichissement').all().map((i) => i.json).find((r) => r.job_id) || null;
const ligneQuota = $('Quota enrichissement').all().map((i) => i.json).find((r) => r.mois) || null;
const d = decisionEntree({
  type: prix ? 'prix' : 'enrichissement', entetes: e.entetes, empreinte: e.empreinte, texteCorps: e.texteCorps, config,
  jobExistant: existant, ligneQuota, maintenant: Date.now(),
  schemaRequete: prix ? __SCHEMA_PRIX__ : __SCHEMA_ENRICHISSEMENT__, schemaReponse: __SCHEMA_REPONSE__,
});
return [{ json: d }];
