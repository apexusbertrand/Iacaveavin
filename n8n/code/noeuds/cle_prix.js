// Clé du cache de prix (vin, format, devise), calculée avant la lecture du cache.
// @inclure normalisation.js
// @inclure prix.js
const r = $('Déclencheur prix').first().json.requete;
return [{ json: { cle: clePrix(r.identite, r.format_cl, r.devise) || 'aucune-cle' } }];
