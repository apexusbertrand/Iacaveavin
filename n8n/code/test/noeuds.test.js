// Chaque nœud Code assemblé tourne avec de fausses données n8n : une fonction
// oubliée dans les inclusions échoue ici, pas en production.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const a = require('../assembler.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (p) => JSON.parse(fs.readFileSync(path.join(racine, p), 'utf8'));
const termine = lire('specs/contrat-n8n/exemples/enrichissement-termine.json');
const requete = lire('specs/contrat-n8n/exemples/requete-enrichissement.json');

async function executer(script, noeuds, entree) {
  const $ = (nom) => {
    if (!(nom in noeuds)) throw new Error('nœud absent : ' + nom);
    const items = [].concat(noeuds[nom]).map((json) => ({ json }));
    return { first: () => items[0], all: () => items, isExecuted: true };
  };
  const ctx = vm.createContext({ $, $input: { first: () => ({ json: entree }), all: () => [{ json: entree }] }, TextEncoder, TextDecoder, Intl, URL, Buffer });
  // Objets du bac à sable ramenés dans ce contexte pour les comparaisons.
  return JSON.parse(JSON.stringify(await vm.runInContext(`(async function () {\n${a.noeud(script)}\n}).call({ helpers: {} })`, ctx)));
}

const config = [{ cle: 'cle_app', valeur: 'k' }, { cle: 'quota_enrichissements', valeur: '100' }, { cle: 'email_alerte', valeur: 'a@b.fr' }];
const envoi = { job_id: '9b1f6c2e-0d4a-4c51-9a77-1e2f3a4b5c6d', type: 'enrichissement', requete: { ...requete, champs_verrouilles: ['degre'], signalements: [] }, recu_le: Date.now() - 5000 };
const lectureModele = { content: '```json\n' + JSON.stringify({
  transcription: [{ index: 0, texte: "GUILLAUME L'ECHANSON" }],
  etiquette: { domaine: "Guillaume L'Echanson", appellation: "Bourgogne Côte d'Or", millesime: 2024 },
  // Cadres : un correct, un débordant (borné), un trop petit (null), un doublon (ignoré).
  cadrages: [{ index: 0, cadre: { x: 0.2, y: 0.1, largeur: 0.6, hauteur: 0.7 } }, { index: 1, cadre: { x: 0.5, y: 0.5, largeur: 0.9, hauteur: 0.9 } },
    { index: 2, cadre: { x: 0.1, y: 0.1, largeur: 0.05, hauteur: 0.5 } }, { index: 0, cadre: null }],
}) + '\n```' };

test('NFR-07 parcours des nœuds du sous-flux avec données simulées', async () => {
  const [l] = await executer('lecture', {}, lectureModele);
  assert.equal(l.json.cle, "guillaume-l-echanson|bourgogne-cote-d-or||2024");
  assert.deepEqual(l.json.cadrages, [
    { index: 0, cadre: { x: 0.2, y: 0.1, largeur: 0.6, hauteur: 0.7 } },
    { index: 1, cadre: { x: 0.5, y: 0.5, largeur: 0.5, hauteur: 0.5 } },
    { index: 2, cadre: null },
  ]);
  const [p] = await executer('preparer_agent', {
    'Déclencheur enrichissement': envoi, 'Config enrichissement': config, 'Décision cache': { ...l.json, cache: false }, 'Photos en binaire': { types: 'photo 0 (etiquette)' },
  }, {});
  assert.match(p.json.systeme, /Date du jour : \d{4}-\d{2}-\d{2}/);
  assert.match(p.json.systeme, /recherche web intégrée, 4 recherches au plus/);
  assert.match(p.json.systeme, /\["degre"\]/);
  const r = JSON.parse(JSON.stringify(termine.resultat));
  r.prix = [];
  // Sortie brute du nœud Anthropic avec recherche intégrée (T85) : l'agent a
  // oublié sources_consultees, le flux la refait à partir des URL vues.
  r.sources_consultees = [];
  const message = (texte, urls) => ({
    content: [
      { type: 'server_tool_use', id: 's1', name: 'web_search', input: { query: 'x' } },
      { type: 'web_search_tool_result', tool_use_id: 's1', content: urls.map((url) => ({ type: 'web_search_result', title: 't', url })) },
      { type: 'text', text: '```json\n' + texte + '\n```' },
    ],
    usage: { input_tokens: 9000, output_tokens: 900, server_tool_use: { web_search_requests: 1 } },
  });
  const [c] = await executer('controles_agent', { 'Déclencheur enrichissement': envoi, 'Lecture étiquette': l.json },
    message(JSON.stringify(r), ['https://www.exemple-interprofession.fr/millesime-2024/']));
  assert.deepEqual(c.json.erreurs, []);
  assert.equal(c.json.resultat.sources_consultees[0].url, 'https://exemple-interprofession.fr/millesime-2024');
  assert.equal(c.json.cout.credits_recherche, 1);
  const [faux] = await executer('controles_agent', { 'Déclencheur enrichissement': envoi, 'Lecture étiquette': l.json },
    message(JSON.stringify(r), ['https://autre-site.fr/page']));
  // T108 : la valeur dont la page n'a pas été vue est retirée, la fiche passe.
  assert.equal(faux.json.ok, true, faux.json.erreurs.join(' | '));
  assert.equal(faux.json.resultat.fiche.commentaire_millesime.valeur, null);
  assert.equal(faux.json.resultat.fiche.commentaire_millesime.motif, 'page citée absente des résultats de recherche');
  assert.match(faux.json.resultat.alertes.map((a) => a.message).join(' | '),
    /valeur\(s\) retirée\(s\).*arrêt \?, 1 recherche\(s\), 1 résultat\(s\) vu\(s\)/);
  const [corr] = await executer('controles_correction', {
    'Déclencheur enrichissement': envoi, 'Lecture étiquette': l.json, 'Contrôles de sortie': faux.json,
    'Agent enrichissement': message('{}', ['https://exemple-interprofession.fr/millesime-2024']),
  }, { output: JSON.stringify(r) });
  assert.equal(corr.json.ok, true, 'la correction garde les URL vues au premier passage');
  assert.equal(corr.json.cout.credits_recherche, 1);
  assert.equal(c.json.ok, true);
  assert.equal(c.json.resultat.fiche.degre, undefined, 'champ verrouillé retiré');
  const [k] = await executer('cloture', {
    'Déclencheur enrichissement': envoi, 'Config enrichissement': config, 'Quota clôture': { mois: '2026-10', enrichissements: 79 },
    'Contrôles après correction': {}, 'Contrôles de sortie': c.json, 'Résultat du cache': {}, 'Lecture étiquette': l.json,
  }, {});
  assert.equal(k.json.statut, 'termine');
  assert.equal(k.json.quota.enrichissements, 80);
  assert.equal(k.json.alerte, true, 'alerte à 80 %');
  assert.equal(k.json.ecrire_cache, true);
  const res = JSON.parse(k.json.resultat);
  assert.equal(res.cout.credits_recherche, 1);
  assert.equal(res.cadrages.length, 3, 'requête en 1.1 : cadres renvoyés');
  assert.equal(JSON.parse(k.json.cache_ligne.resultat).cadrages, undefined, 'cadres hors du cache');
  const ancien = { ...envoi, requete: { ...envoi.requete, version_contrat: '1.0' } };
  const [k0] = await executer('cloture', {
    'Déclencheur enrichissement': ancien, 'Config enrichissement': config, 'Quota clôture': { mois: '2026-10', enrichissements: 1 },
    'Contrôles après correction': {}, 'Contrôles de sortie': JSON.parse(JSON.stringify({ ...c.json, resultat: { ...c.json.resultat, cadrages: undefined } })), 'Résultat du cache': {}, 'Lecture étiquette': l.json,
  }, {});
  assert.equal(JSON.parse(k0.json.resultat).cadrages, undefined, 'app en 1.0 : pas de cadres');
  const [rc] = await executer('resultat_cache', { 'Déclencheur enrichissement': envoi }, { ...l.json, cache_ligne: { resultat: k.json.cache_ligne.resultat, date_maj: '2026-10-01' } });
  assert.equal(rc.json.cache, true);
  assert.equal(rc.json.resultat.transcription[0].texte, "GUILLAUME L'ECHANSON");
  const [e] = await executer('echec', { 'Déclencheur enrichissement': envoi }, { erreurs: ['x'] });
  assert.equal(JSON.parse(e.json.erreur).code, 'interne');
});

test('AJO-13 cache des vins : une entrée sans source web n\'est pas resservie', async () => {
  const [l] = await executer('lecture', {}, lectureModele);
  const r = JSON.parse(JSON.stringify(termine.resultat));
  const ligne = (res) => ({ cle: l.json.cle, resultat: JSON.stringify(res), utilisations: 1, date_maj: new Date().toISOString().slice(0, 10), id: 1 });
  const d = { 'Lecture étiquette': l.json, 'Déclencheur enrichissement': envoi };
  const [bon] = await executer('decision_cache', d, ligne(r));
  assert.equal(bon.json.cache, true, 'entrée sourcée et fraîche : resservie');
  // Entrée écrite le 2026-10-26, recherche web en panne (erreur d'authentification).
  const [panne] = await executer('decision_cache', d, ligne({ ...r, sources_consultees: [] }));
  assert.equal(panne.json.cache, false, 'entrée sans source : agent relancé');
  const [illisible] = await executer('decision_cache', d, { ...ligne(r), resultat: '{' });
  assert.equal(illisible.json.cache, false);
});

test('PRV-R4 signalements (contrat 1.2) : enregistrés, cache contourné, rappelés à l\'agent', async () => {
  const [l] = await executer('lecture', {}, lectureModele);
  const signalements = [{ champ: 'cepages', valeur: 'Pinot noir 100 %' }, { champ: 'region', valeur: 'Alsace' }];
  const signale = { ...envoi, requete: { ...envoi.requete, signalements } };
  const ligne = { cle: l.json.cle, resultat: JSON.stringify(termine.resultat), utilisations: 1, date_maj: new Date().toISOString().slice(0, 10), id: 1 };
  const [c] = await executer('decision_cache', { 'Lecture étiquette': l.json, 'Déclencheur enrichissement': signale }, ligne);
  assert.equal(c.json.cache, false, 'entrée fraîche et sourcée, mais signalée : agent relancé');
  const lignes = await executer('signalements', { 'Déclencheur enrichissement': signale }, {});
  assert.deepEqual(lignes.map((x) => [x.json.job_id, x.json.champ, x.json.valeur]), [
    [envoi.job_id, 'cepages', 'Pinot noir 100 %'], [envoi.job_id, 'region', 'Alsace'],
  ]);
  assert.match(lignes[0].json.date_signalement, /^\d{4}-\d{2}-\d{2}$/);
  assert.deepEqual(await executer('signalements', { 'Déclencheur enrichissement': envoi }, {}), [], 'aucune ligne sans signalement');
  const noeuds = (e) => ({ 'Déclencheur enrichissement': e, 'Config enrichissement': config, 'Décision cache': { ...l.json, cache: false }, 'Photos en binaire': { types: 'photo 0 (etiquette)' } });
  const [p] = await executer('preparer_agent', noeuds(signale), {});
  assert.match(p.json.systeme, /signalées fausses.*Pinot noir 100 %/);
  const [p0] = await executer('preparer_agent', noeuds(envoi), {});
  assert.doesNotMatch(p0.json.systeme, /signalées fausses/);

});

test('NFR-06 nœud santé : autotest de signature dans le bac à sable', async () => {
  const [s] = await executer('sante', { 'Config santé': config }, {});
  assert.deepEqual(s.json, { version_flux: a.VERSION_FLUX, version_contrat: '1.2', ok: true });
});
