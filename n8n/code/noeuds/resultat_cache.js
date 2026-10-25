// Résultat servi depuis le cache : la transcription du jour remplace celle
// du cache, les champs verrouillés restent retirés.
// @inclure normalisation.js
// @inclure metier.js
const d = $input.first().json;
const envoi = $('Déclencheur enrichissement').first().json;
const r = JSON.parse(d.cache_ligne.resultat);
r.transcription = d.transcription;
const c = controlerEnrichissement(r, { anneeCourante: new Date().getFullYear(), champsVerrouilles: envoi.requete.champs_verrouilles || [], domainesMarchands: [] });
return [{ json: { ok: true, erreurs: [], resultat: c.resultat, cout: { appels_modele: 1, credits_recherche: 0 }, cache: true, cle: d.cle, date_cache: d.cache_ligne.date_maj } }];
