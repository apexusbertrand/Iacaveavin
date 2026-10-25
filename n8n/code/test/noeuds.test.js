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

const config = [{ cle: 'cle_app', valeur: 'k' }, { cle: 'tavily_cle', valeur: '' }, { cle: 'quota_enrichissements', valeur: '100' }, { cle: 'email_alerte', valeur: 'a@b.fr' }];
const envoi = { job_id: '9b1f6c2e-0d4a-4c51-9a77-1e2f3a4b5c6d', type: 'enrichissement', requete: { ...requete, champs_verrouilles: ['degre'] }, recu_le: Date.now() - 5000 };
const lectureModele = { content: '```json\n' + JSON.stringify({ transcription: [{ index: 0, texte: "GUILLAUME L'ECHANSON" }], etiquette: { domaine: "Guillaume L'Echanson", appellation: "Bourgogne Côte d'Or", millesime: 2024 } }) + '\n```' };

test('NFR-07 parcours des nœuds du sous-flux avec données simulées', async () => {
  const [l] = await executer('lecture', {}, lectureModele);
  assert.equal(l.json.cle, "guillaume-l-echanson|bourgogne-cote-d-or||2024");
  const [p] = await executer('preparer_agent', {
    'Déclencheur enrichissement': envoi, 'Config enrichissement': config, 'Décision cache': { ...l.json, cache: false }, 'Photos en binaire': { types: 'photo 0 (etiquette)' },
  }, {});
  assert.match(p.json.systeme, /Date du jour : \d{4}-\d{2}-\d{2}/);
  assert.match(p.json.systeme, /recherche web n'est pas configurée/);
  assert.match(p.json.systeme, /\["degre"\]/);
  const r = JSON.parse(JSON.stringify(termine.resultat));
  r.prix = [];
  r.sources_consultees = [{ url: 'https://exemple-interprofession.fr/millesime-2024', consultee_le: '2026-10-20', utilisee: true }];
  const [c] = await executer('controles_agent', { 'Déclencheur enrichissement': envoi, 'Lecture étiquette': l.json }, { output: JSON.stringify(r), intermediateSteps: [{ action: { tool: 'recherche_web' } }] });
  assert.deepEqual(c.json.erreurs, []);
  assert.equal(c.json.ok, true);
  assert.equal(c.json.resultat.fiche.degre, undefined, 'champ verrouillé retiré');
  const [k] = await executer('cloture', {
    'Déclencheur enrichissement': envoi, 'Config enrichissement': config, 'Quota clôture': { mois: '2026-10', enrichissements: 79 },
    'Contrôles après correction': {}, 'Contrôles de sortie': c.json, 'Résultat du cache': {},
  }, {});
  assert.equal(k.json.statut, 'termine');
  assert.equal(k.json.quota.enrichissements, 80);
  assert.equal(k.json.alerte, true, 'alerte à 80 %');
  assert.equal(k.json.ecrire_cache, true);
  const res = JSON.parse(k.json.resultat);
  assert.equal(res.cout.credits_recherche, 1);
  const [rc] = await executer('resultat_cache', { 'Déclencheur enrichissement': envoi }, { ...l.json, cache_ligne: { resultat: k.json.cache_ligne.resultat, date_maj: '2026-10-01' } });
  assert.equal(rc.json.cache, true);
  assert.equal(rc.json.resultat.transcription[0].texte, "GUILLAUME L'ECHANSON");
  const [e] = await executer('echec', { 'Déclencheur enrichissement': envoi }, { erreurs: ['x'] });
  assert.equal(JSON.parse(e.json.erreur).code, 'interne');
});

test('NFR-06 nœud santé : autotest de signature dans le bac à sable', async () => {
  const [s] = await executer('sante', { 'Config santé': config }, {});
  assert.deepEqual(s.json, { version_flux: a.VERSION_FLUX, version_contrat: '1.0', ok: true });
});
