// GET /iacave/sante : version du flux et du contrat. ok vaut vrai si
// l'autotest de signature passe et si la clé de l'app est configurée.
// @inclure securite.js
const v = __VECTEUR__;
const config = {};
for (const i of $('Config santé').all()) config[i.json.cle] = i.json.valeur;
const autotest = signatureAttendue(v.cle, v.horodatage, v.methode, v.chemin, utf8(v.corps)) === v.signature;
return [{ json: { version_flux: '__VERSION_FLUX__', version_contrat: '1.3', ok: autotest && !!config.cle_app } }];
