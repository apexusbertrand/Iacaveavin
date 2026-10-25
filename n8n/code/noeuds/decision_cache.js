// Cache des vins (docs/06, étape 3) : une entrée de moins de 180 jours
// évite les recherches web. La lecture d'étiquette a déjà eu lieu.
const l = $('Lecture étiquette').first().json;
const ligne = $input.all().map((i) => i.json).find((r) => r.cle && r.cle === l.cle) || null;
const age = ligne ? Date.now() - Date.parse(ligne.date_maj || ligne.updatedAt || 0) : Infinity;
const frais = l.avec_cle && ligne && age < 180 * 86400000;
return [{ json: { ...l, cache: !!frais, cache_ligne: ligne ? { id: ligne.id, utilisations: ligne.utilisations || 0, resultat: ligne.resultat, date_maj: ligne.date_maj } : null } }];
