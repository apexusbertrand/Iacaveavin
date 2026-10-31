// POST /iacave/enrichissement et POST /iacave/prix : contrôles d'entrée dans
// l'ordre de docs/06 (compte connecté, en-têtes, horodatage, signature avec la
// clé du compte, request_id déjà vu, quota du compte, schéma). Les deux
// webhooks partagent cette chaîne ; le type vient du webhook qui a reçu la
// requête.
// @inclure securite.js
// @inclure schema.js
// @inclure enveloppes.js
// @inclure entree.js
// @inclure comptes.js
const e = $('Empreinte enrichissement').first().json;
let prix = false;
try {
  prix = $('Webhook prix').isExecuted;
} catch (err) {
  // Requête d'enrichissement.
}
const type = prix ? 'prix' : 'enrichissement';
const config = lireConfig($('Config enrichissement').all().map((i) => i.json));
const compte = $('Compte enrichissement').all().map((i) => i.json).find((r) => r.compte_id) || null;
const existant = $('Job existant enrichissement').all().map((i) => i.json).find((r) => r.job_id) || null;
const ligneUsage = $('Quota enrichissement').all().map((i) => i.json).find((r) => r.compte_id) || null;
const maintenant = Date.now();
const d = entreeAvecCompte({
  compte, config, ligneUsage, maintenant, requestId: e.requestId, type,
  decider: (configCompte, usage) => decisionEntree({
    type, entetes: e.entetes, empreinte: e.empreinte, texteCorps: e.texteCorps, config: configCompte,
    jobExistant: existant && existant.compte_id === compte.compte_id ? existant : null, ligneQuota: usage, maintenant,
    schemaRequete: prix ? __SCHEMA_PRIX__ : __SCHEMA_ENRICHISSEMENT__, schemaReponse: __SCHEMA_REPONSE__,
  }),
});
return [{ json: d }];
