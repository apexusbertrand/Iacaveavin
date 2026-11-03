// Comptes (CPT-01 à CPT-03) : une décision pour les trois chemins du flux.
// POST /compte/code : code par mail. POST /compte/session : code vérifié,
// compte et clé. GET /compte, POST /compte/deconnexion et /compte/suppression :
// signés avec la clé
// du compte.
// @inclure securite.js
// @inclure schema.js
// @inclure enveloppes.js
// @inclure comptes.js
// @inclure compte_etat.js
const execute = (n) => {
  try {
    return $(n).isExecuted;
  } catch (e) {
    return false;
  }
};
const lignes = (n) => $(n).all().map((i) => i.json);
const maintenant = Date.now();
const schemaReponse = __SCHEMA_REPONSE_COMPTE__;
let d;
if (execute('Webhook code')) {
  d = decisionCode({
    texteCorps: $('Webhook code').first().json.body, config: lireConfig(lignes('Config code')),
    ligneCode: lignes('Code en cours').find((r) => r.email) || null, maintenant,
    schemaRequete: __SCHEMA_COMPTE_CODE__, schemaReponse,
  });
  d.action = 'code';
} else if (execute('Webhook session')) {
  d = decisionSession({
    texteCorps: $('Webhook session').first().json.body, config: lireConfig(lignes('Config session')),
    ligneCode: lignes('Code de session').find((r) => r.email) || null,
    compte: lignes('Compte de session').find((r) => r.compte_id) || null,
    ligneUsage: lignes('Usage de session').find((r) => r.compte_id) || null, maintenant,
    schemaRequete: __SCHEMA_COMPTE_SESSION__, schemaReponse,
  });
  d.action = 'session';
} else {
  const e = $('Empreinte compte').first().json;
  d = decisionCompteSigne({
    action: execute('Webhook suppression') ? 'suppression' : execute('Webhook déconnexion') ? 'deconnexion' : 'etat',
    entetes: e.entetes, empreinte: e.empreinte,
    config: lireConfig(lignes('Config compte')), compte: lignes('Compte signé').find((r) => r.compte_id) || null,
    ligneUsage: lignes('Usage du compte').find((r) => r.compte_id) || null, maintenant, schemaReponse,
  });
  d.action = 'etat';
}
return [{ json: d }];
