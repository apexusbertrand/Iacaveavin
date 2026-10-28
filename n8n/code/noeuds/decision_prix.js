// Avant l'agent prix : cache de 24 heures, sites marchands actifs.
// Sans ces conditions, aucun appel au modèle (prix non trouvé avec motif).
// @inclure normalisation.js
// @inclure enveloppes.js
// @inclure prix.js
const e = $('Déclencheur prix').first().json;
const config = lireConfig($('Config prix').all().map((i) => i.json));
const cle = $('Clé prix').first().json.cle;
const ligneCache = $input.all().map((i) => i.json).find((r) => r.cle && r.cle === cle) || null;
const domaines = (__SOURCES__.marchands || []);
const d = decisionPrix({ requete: e.requete, config, ligneCache, maintenant: Date.now(), domainesMarchands: domaines });
const m = d.agent ? messagesPrix({ prompt: __PROMPT_PRIX__, requete: e.requete, jour: d.jour, domainesMarchands: domaines }) : { systeme: '', message: '' };
return [{ json: { ...d, ok: !d.agent, cout: { appels_modele: 0, credits_recherche: 0 }, domaines, ...m } }];
