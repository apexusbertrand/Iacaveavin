// Relevé de prix : bibliothèque et nœuds du sous-flux IA_CAVE_Prix, avec de
// fausses données n8n.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const a = require('../assembler.js');
const p = require('../lib/prix.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (f) => JSON.parse(fs.readFileSync(path.join(racine, f), 'utf8'));
const schemaReponse = lire('specs/contrat-n8n/reponse-job.schema.json');
const requetePrix = lire('specs/contrat-n8n/exemples/requete-prix.json');

async function executer(script, noeuds, entree) {
  const $ = (nom) => {
    if (!(nom in noeuds)) return { isExecuted: false, first: () => { throw new Error('nœud non exécuté : ' + nom); }, all: () => [] };
    const items = [].concat(noeuds[nom]).map((json) => ({ json }));
    return { first: () => items[0], all: () => items, isExecuted: true };
  };
  const ctx = vm.createContext({ $, $input: { first: () => ({ json: entree }), all: () => [].concat(entree).map((json) => ({ json })) }, TextEncoder, TextDecoder, Intl, URL, Buffer });
  return JSON.parse(JSON.stringify(await vm.runInContext(`(async function () {\n${a.noeud(script)}\n}).call({ helpers: {} })`, ctx)));
}

const MARCHANDS = ['vinatis.com', 'millesima.fr'];
const jour = '2026-11-20';
const page = (url) => ({ action: { tool: 'lire_page', toolInput: { url } }, observation: '...' });
const sortieAgent = (offres, etapes) => ({ output: '```json\n' + JSON.stringify({ offres, alertes: [] }) + '\n```', intermediateSteps: etapes });

test('docs/06 prix : clé de cache par vin, format et devise', () => {
  assert.equal(p.clePrix(requetePrix.identite, 75, 'EUR'), "guillaume-l-echanson|bourgogne-cote-d-or||2024|75|EUR");
  assert.equal(p.clePrix({ domaine: 'X' }, 75, 'EUR'), null, 'sans millésime, pas de cache');
});

test('docs/06 prix : cache de 24 heures, sauf forcer', () => {
  const maintenant = Date.parse('2026-11-20T10:00:00Z');
  const ligne = { cle: 'k', resultat: JSON.stringify({ prix: [], alertes: [], sources_consultees: [] }), date_maj: '2026-11-19T12:00:00Z' };
  const base = { requete: requetePrix, config: { tavily_cle: 't' }, maintenant, domainesMarchands: MARCHANDS };
  assert.equal(p.decisionPrix({ ...base, ligneCache: ligne }).cache, true);
  assert.equal(p.decisionPrix({ ...base, ligneCache: { ...ligne, date_maj: '2026-11-19T09:00:00Z' } }).agent, true, 'cache de plus de 24 h');
  assert.equal(p.decisionPrix({ ...base, requete: { ...requetePrix, forcer: true }, ligneCache: ligne }).agent, true, 'forcer');
});

test('docs/06 prix : sans site actif ni clé de recherche, aucun appel au modèle et jamais de prix estimé', () => {
  const maintenant = Date.parse('2026-11-20T10:00:00Z');
  for (const [config, domaines, motif] of [[{ tavily_cle: 't' }, [], /site marchand/], [{ tavily_cle: '' }, MARCHANDS, /Recherche web/]]) {
    const d = p.decisionPrix({ requete: requetePrix, config, ligneCache: null, maintenant, domainesMarchands: domaines });
    assert.equal(d.agent, false);
    assert.equal(d.resultat.prix[0].trouve, false);
    assert.equal(d.resultat.prix[0].prix, null);
    assert.match(d.resultat.prix[0].motif, motif);
    assert.deepEqual(p.analyserSortiePrix({ output: '{}' }, { requete: requetePrix, jour, domainesMarchands: MARCHANDS, schemaReponse }).erreurs, []);
  }
});

test('docs/06 prix : seules les pages lues, autorisées et du bon millésime comptent', () => {
  const offres = [
    { site: 'vinatis.com', url: 'https://www.vinatis.com/a', prix: 24.5, millesime_verifie: true },
    { site: 'millesima.fr', url: 'https://millesima.fr/b', prix: '25,5', millesime_verifie: true },
    { site: 'millesima.fr', url: 'https://millesima.fr/inventee', prix: 12, millesime_verifie: true },
    { site: 'autre.fr', url: 'https://autre.fr/c', prix: 20, millesime_verifie: true },
    { site: 'vinatis.com', url: 'https://www.vinatis.com/d', prix: 19, millesime_verifie: false },
  ];
  const etapes = [page('https://www.vinatis.com/a'), page('https://millesima.fr/b'), page('https://autre.fr/c'), page('https://www.vinatis.com/d'), { action: { tool: 'recherche_web', toolInput: { requete: 'x' } } }];
  const r = p.analyserSortiePrix(sortieAgent(offres, etapes), { requete: requetePrix, jour, domainesMarchands: MARCHANDS, schemaReponse });
  assert.deepEqual(r.erreurs, []);
  const prix = r.resultat.prix[0];
  assert.equal(prix.trouve, true);
  assert.equal(prix.nature, 'mediane');
  assert.equal(prix.prix, 25);
  assert.deepEqual(prix.offres.map((o) => o.url), ['https://www.vinatis.com/a', 'https://millesima.fr/b']);
  assert.deepEqual(r.ecartees.map((e) => e.motif), ['page non lue', 'site non autorisé', 'millésime non vérifié']);
  assert.equal(r.resultat.sources_consultees.length, 4, 'les pages réellement lues');
  assert.equal(r.resultat.sources_consultees.filter((s) => s.utilisee).length, 2);
  assert.equal(r.cout.credits_recherche, 5);
});

test('docs/06 prix : sortie illisible refusée, la correction reprend les pages lues', () => {
  assert.equal(p.analyserSortiePrix({ output: 'pas de JSON' }, { requete: requetePrix, jour, domainesMarchands: MARCHANDS, schemaReponse }).ok, false);
  const corr = p.analyserSortiePrix(sortieAgent([{ site: 'vinatis.com', url: 'https://www.vinatis.com/a', prix: 30, millesime_verifie: true }], []), {
    requete: requetePrix, jour, domainesMarchands: MARCHANDS, schemaReponse, dejaLues: ['https://www.vinatis.com/a'],
  });
  assert.equal(corr.resultat.prix[0].nature, 'offre');
  assert.equal(corr.resultat.prix[0].prix, 30);
});

const configPrix = [{ cle: 'tavily_cle', valeur: 't' }, { cle: 'quota_prix', valeur: '120' }, { cle: 'email_alerte', valeur: 'a@b.fr' }];
const envoiJob = { job_id: 'e5f4d3c2-b1a0-4f9e-8d7c-6b5a4f3e2d1c', type: 'prix', mode: 'job', requete: requetePrix, recu_le: Date.now() - 3000 };

test('docs/06 nœuds prix : décision, contrôles, clôture en mode job', async () => {
  const [k] = await executer('cle_prix', { 'Déclencheur prix': envoiJob }, {});
  assert.match(k.json.cle, /\|75\|EUR$/);
  const [d] = await executer('decision_prix', { 'Déclencheur prix': envoiJob, 'Config prix': configPrix, 'Clé prix': k.json }, [{}]);
  // Aucun site marchand actif dans n8n/sources-autorisees.yaml pour l'instant.
  assert.equal(d.json.agent, false);
  assert.equal(d.json.ok, true);
  const decision = { ...d.json, agent: true, ok: false, domaines: MARCHANDS };
  const sortie = sortieAgent([{ site: 'vinatis.com', url: 'https://www.vinatis.com/a', prix: 24.5, millesime_verifie: true }], [page('https://www.vinatis.com/a')]);
  const [c] = await executer('controles_prix_agent', { 'Déclencheur prix': envoiJob, 'Décision prix': decision }, sortie);
  assert.equal(c.json.ok, true);
  const [f] = await executer('cloture_prix', {
    'Déclencheur prix': envoiJob, 'Config prix': configPrix, 'Quota prix': { mois: '2026-11', prix: 95 }, 'Contrôles prix': c.json, 'Décision prix': decision,
  }, {});
  assert.equal(f.json.statut, 'termine');
  assert.equal(f.json.quota.prix, 96);
  assert.equal(f.json.alerte, true, 'alerte à 80 % de 120');
  assert.equal(f.json.ecrire_cache, true);
  const res = JSON.parse(f.json.resultat);
  assert.equal(res.prix[0].prix, 24.5);
  assert.equal(res.cache.hit, false);
  assert.equal(JSON.parse(f.json.cache_ligne.resultat).cout, undefined);
  const [r] = await executer('retour_prix', { 'Clôture prix': f.json }, {});
  assert.equal(r.json.ok, true);
});

test('docs/06 nœuds prix : prix non trouvé jamais mis en cache, échec rendu à l\'enrichissement', async () => {
  const envoiInterne = { ...envoiJob, mode: 'interne' };
  const [k] = await executer('cle_prix', { 'Déclencheur prix': envoiInterne }, {});
  const [d] = await executer('decision_prix', { 'Déclencheur prix': envoiInterne, 'Config prix': configPrix, 'Clé prix': k.json }, [{}]);
  const [f] = await executer('cloture_prix', { 'Déclencheur prix': envoiInterne, 'Config prix': configPrix, 'Quota prix': { mois: '2026-11', prix: 3 }, 'Décision prix': d.json }, {});
  assert.equal(f.json.ecrire_cache, false);
  assert.equal(f.json.quota.prix, 3, 'compté par l\'enrichissement');
  const [e] = await executer('echec_prix', { 'Déclencheur prix': envoiInterne }, { erreurs: ['sortie non JSON'], cout: { appels_modele: 2, credits_recherche: 1 } });
  const [r] = await executer('retour_prix', { 'Échec prix': e.json }, {});
  assert.equal(r.json.ok, false);
});

test('docs/06 inclure_prix : requête de relevé tirée de la fiche, prix fusionnés à la clôture', async () => {
  const termine = lire('specs/contrat-n8n/exemples/enrichissement-termine.json');
  const requete = lire('specs/contrat-n8n/exemples/requete-enrichissement.json');
  const envoi = { job_id: '9b1f6c2e-0d4a-4c51-9a77-1e2f3a4b5c6d', type: 'enrichissement', requete: { ...requete, inclure_prix: true }, recu_le: Date.now() - 5000 };
  const r = JSON.parse(JSON.stringify(termine.resultat));
  delete r.prix;
  r.sources_consultees = [];
  for (const n of r.notes_critiques) r.sources_consultees.push({ url: n.url, consultee_le: jour });
  for (const ch of Object.values(r.fiche)) if (ch.url) r.sources_consultees.push({ url: ch.url, consultee_le: jour });
  const controles = { ok: true, resultat: r, cout: { appels_modele: 3, credits_recherche: 2 }, cle: 'k', avec_cle: true };
  const [ch] = await executer('charge_prix', { 'Déclencheur enrichissement': envoi, 'Contrôles de sortie': controles }, {});
  assert.equal(ch.json.mode, 'interne');
  assert.equal(ch.json.requete.identite.millesime, 2024);
  assert.equal(ch.json.requete.format_cl, 75);
  const releve = {
    ok: true,
    prix: [{ format_cl: 75, trouve: true, prix: 24.5, devise: 'EUR', nature: 'offre', nb_offres: 1, offres: [{ site: 'vinatis.com', url: 'https://www.vinatis.com/a', prix: 24.5, millesime_verifie: true }], site: 'vinatis.com', url: 'https://www.vinatis.com/a', date: jour }],
    alertes: [],
    sources_consultees: [{ url: 'https://www.vinatis.com/a', consultee_le: jour, utilisee: true }],
    cout: { appels_modele: 2, credits_recherche: 3 },
  };
  const [k] = await executer('cloture', {
    'Déclencheur enrichissement': envoi, 'Config enrichissement': [{ cle: 'quota_enrichissements', valeur: '100' }], 'Quota clôture': { mois: '2026-11', enrichissements: 1, prix: 0 },
    'Contrôles de sortie': controles, 'Relevé de prix': releve,
  }, {});
  const res = JSON.parse(k.json.resultat);
  assert.equal(res.prix[0].prix, 24.5);
  assert.equal(res.cout.credits_recherche, 5);
  assert.equal(k.json.quota.prix, 1);
  assert.equal(JSON.parse(k.json.cache_ligne.resultat).prix, undefined, 'les prix ne vont pas dans le cache du vin');
});

test('docs/06 POST /prix : même chaîne d\'entrée, type prix, signature sur /webhook/iacave/prix, quota de prix', async () => {
  const { signatureAttendue, sha256, toHex, utf8 } = require('../lib/securite.js');
  const cle = 'cle-de-developpement';
  const texteCorps = JSON.stringify(requetePrix);
  const empreinte = toHex(sha256(utf8(texteCorps)));
  const ts = String(Math.floor(Date.now() / 1000));
  const entetes = (chemin) => ({
    'x-iacav-installation': '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
    'x-iacav-horodatage': ts,
    'x-iacav-signature': signatureAttendue(cle, ts, 'POST', chemin, empreinte),
  });
  const config = [{ cle: 'cle_app', valeur: cle }, { cle: 'quota_prix', valeur: '120' }];
  const noeuds = (chemin, quota) => ({
    'Empreinte enrichissement': { empreinte, texteCorps, entetes: entetes(chemin) },
    'Webhook prix': {}, 'Config enrichissement': config, 'Job existant enrichissement': {}, 'Quota enrichissement': quota,
  });
  const [ok] = await executer('controle_enrichissement', noeuds('/webhook/iacave/prix', { mois: '2026-11', prix: 3 }), {});
  assert.equal(ok.json.decision, 'nouveau');
  assert.equal(ok.json.envoi.type, 'prix');
  assert.equal(ok.json.reponse.etape, 'prix');
  const [faux] = await executer('controle_enrichissement', noeuds('/webhook/iacave/enrichissement', {}), {});
  assert.equal(faux.json.reponse.erreur.code, 'auth_invalide', 'signature d\'une autre route');
  const [plein] = await executer('controle_enrichissement', noeuds('/webhook/iacave/prix', { mois: '2026-11', prix: 120 }), {});
  assert.equal(plein.json.reponse.erreur.code, 'quota_depasse');
});
