// Juste après le webhook : empreinte SHA-256 des octets exacts reçus (pour la
// signature) et lecture du corps. Les données épinglées d'un test n'ont pas
// de corps brut : le corps analysé est alors réencodé.
// @inclure securite.js
const item = $input.first();
let octets;
if (item.binary && item.binary.data) {
  octets = new Uint8Array(await this.helpers.getBinaryDataBuffer(0, 'data'));
} else {
  const b = item.json.body;
  octets = utf8(b && typeof b === 'object' && Object.keys(b).length ? JSON.stringify(b) : typeof b === 'string' ? b : '');
}
const texteCorps = new TextDecoder().decode(octets);
let requestId = 'aucun';
try {
  const c = JSON.parse(texteCorps);
  if (c && typeof c.request_id === 'string') requestId = c.request_id;
} catch (e) {
  // Corps illisible : le refus est décidé aux contrôles d'entrée.
}
return [{ json: { empreinte: toHex(sha256(octets)), texteCorps, requestId, entetes: item.json.headers || {}, params: item.json.params || {} } }];
