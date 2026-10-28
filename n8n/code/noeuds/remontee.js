// POST /iacave/remontee (RET-01) : contrôles (signature, contrat, 5 envois
// par jour et par installation) puis mail à composer. La pièce jointe passe
// en binaire pour le nœud Gmail, sans rester dans le JSON.
// @inclure securite.js
// @inclure schema.js
// @inclure remontee.js
const e = $('Empreinte remontée').first().json;
const config = {};
for (const i of $('Config remontée').all()) {
  if (i.json.cle) config[i.json.cle] = i.json.valeur == null ? '' : String(i.json.valeur);
}
const d = decisionRemontee({
  entetes: e.entetes, empreinte: e.empreinte, texteCorps: e.texteCorps, config,
  envoisDuJour: $('Remontées du jour').all().map((i) => i.json),
  maintenant: Date.now(),
  schemaRequete: __SCHEMA_REMONTEE__, schemaReponse: __SCHEMA_REPONSE_REMONTEE__,
});
const item = { json: { ...d, avec_piece: !!d.piece } };
if (d.piece) {
  item.binary = {
    piece_jointe: await this.helpers.prepareBinaryData(Buffer.from(d.piece.base64, 'base64'), d.piece.nom, d.piece.mime),
  };
  item.json.piece = { nom: d.piece.nom, mime: d.piece.mime };
}
return [item];
