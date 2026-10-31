// GET /iacave/sante : version du flux et du contrat. ok vaut vrai si
// l'autotest de signature passe (la clé est celle de chaque compte).
// @inclure securite.js
const v = __VECTEUR__;
const config = {};
for (const i of $('Config santé').all()) config[i.json.cle] = i.json.valeur;
const autotest = signatureAttendue(v.cle, v.horodatage, v.methode, v.chemin, utf8(v.corps)) === v.signature;
return [{ json: { version_flux: '__VERSION_FLUX__', version_contrat: '2.0', ok: autotest } }];
