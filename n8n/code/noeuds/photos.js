// Photos du job (base64 de la requête) en données binaires pour le modèle
// vision. Les photos ne sont écrites dans aucune table (décision T60).
const envoi = $('Déclencheur enrichissement').first().json;
const binary = {};
const noms = [];
for (const p of envoi.requete.photos) {
  const nom = 'photo_' + p.index;
  const ext = p.mime === 'image/webp' ? '.webp' : '.jpg';
  binary[nom] = await this.helpers.prepareBinaryData(Buffer.from(p.base64, 'base64'), nom + ext, p.mime);
  noms.push(nom);
}
const types = envoi.requete.photos.map((p) => `photo ${p.index} (${p.type_photo})`).join(', ');
return [{ json: { noms: noms.join(','), types }, binary }];
