// Décision d'entrée et suivi des jobs. Lancer : node --test n8n/code/test/*.test.js
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

// Dans le nœud Code, les fichiers de lib sont concaténés : on reproduit ici
// leurs fonctions globales.
Object.assign(globalThis, require('../lib/securite.js'), require('../lib/schema.js'), require('../lib/metier.js'));
const j = { ...require('../lib/entree.js'), ...require('../lib/suivi.js') };
const { signatureAttendue, sha256, toHex, utf8 } = require('../lib/securite.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (p) => JSON.parse(fs.readFileSync(path.join(racine, p), 'utf8'));
const schemaRequete = lire('specs/contrat-n8n/requete-enrichissement.schema.json');
const schemaReponse = lire('specs/contrat-n8n/reponse-job.schema.json');
const requete = lire('specs/contrat-n8n/exemples/requete-enrichissement.json');

const CLE = 'cle-de-developpement';
const MAINTENANT = Date.parse('2026-10-21T09:00:00Z');
const config = j.lireConfig([
  { cle: 'cle_app', valeur: CLE }, { cle: 'quota_enrichissements', valeur: '100' },
  { cle: 'quota_prix', valeur: '120' }, { cle: 'fenetre_secondes', valeur: '300' },
]);

function signer(texte, { methode = 'POST', chemin = '/webhook/iacave/enrichissement', ts = MAINTENANT / 1000, cle = CLE } = {}) {
  const empreinte = toHex(sha256(utf8(texte)));
  return {
    empreinte,
    entetes: {
      'x-iacav-installation': '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
      'x-iacav-horodatage': String(ts),
      'x-iacav-signature': signatureAttendue(cle, String(ts), methode, chemin, empreinte),
    },
  };
}

const entree = (corps, over = {}) => {
  const texteCorps = typeof corps === 'string' ? corps : JSON.stringify(corps);
  return j.decisionEntree({
    type: 'enrichissement', texteCorps, ...signer(texteCorps), config, jobExistant: null, ligneQuota: null,
    maintenant: MAINTENANT, schemaRequete, schemaReponse, ...over,
  });
};

test('AJO-12 nouveau job : 202, en_attente, photos retirées de la requête stockée', () => {
  const d = entree(requete);
  assert.equal(d.decision, 'nouveau');
  assert.equal(d.http, 202);
  assert.equal(d.reponse.statut, 'en_attente');
  assert.equal(d.reponse.quota.enrichissements_restants_mois, 100);
  assert.deepEqual(validateSchema(schemaReponse, d.reponse), []);
  assert.ok(j.estUuid(d.job.job_id));
  assert.ok(!d.job.requete.includes(requete.photos[0].base64));
  assert.equal(d.envoi.requete.photos[0].base64, requete.photos[0].base64);
});

test('AJO-09 idempotence : même request_id, job existant renvoyé', () => {
  const existant = { job_id: '9b1f6c2e-0d4a-4c51-9a77-1e2f3a4b5c6d', request_id: requete.request_id, type: 'enrichissement', statut: 'en_cours', etape: 'identification', fiche_id: '' };
  const d = entree(requete, { jobExistant: existant });
  assert.equal(d.decision, 'existant');
  assert.equal(d.http, 200);
  assert.equal(d.reponse.job_id, existant.job_id);
  assert.deepEqual(validateSchema(schemaReponse, d.reponse), []);
});

test('NFR-06 refus signés, datés et au contrat', () => {
  const texte = JSON.stringify(requete);
  const cas = {
    'auth_invalide': entree(requete, { entetes: {} }),
    'signature_expiree': entree(requete, signer(texte, { ts: MAINTENANT / 1000 - 400 })),
    'auth_invalide ': entree(requete, signer(texte, { cle: 'autre' })),
    'requete_invalide': entree({ ...requete, champ_inconnu: 1 }),
    'version_non_supportee': entree({ ...requete, version_contrat: '2.0' }),
    'quota_depasse': entree(requete, { ligneQuota: { enrichissements: 100 } }),
  };
  for (const [code, d] of Object.entries(cas)) {
    assert.equal(d.decision, 'refus', code);
    assert.equal(d.reponse.erreur.code, code.trim());
    assert.deepEqual(validateSchema(schemaReponse, d.reponse), [], code);
  }
  assert.equal(cas.quota_depasse.http, 429);
  assert.equal(cas.quota_depasse.reponse.erreur.reessayable, false);
  assert.equal(entree('pas du json').reponse.erreur.code, 'requete_invalide');
});

test('AJO-09 suivi : signature du GET, job inconnu, délai dépassé', () => {
  const jobId = '9b1f6c2e-0d4a-4c51-9a77-1e2f3a4b5c6d';
  const { entetes } = signer('', { methode: 'GET', chemin: '/webhook/iacave/jobs?job_id=' + jobId });
  const job = {
    job_id: jobId, request_id: requete.request_id, type: 'enrichissement', statut: 'termine', etape: 'termine', fiche_id: '',
    resultat: JSON.stringify(lire('specs/contrat-n8n/exemples/enrichissement-termine.json').resultat),
    createdAt: '2026-10-21T08:58:00Z',
  };
  const ok = j.reponseSuivi({ entetes, jobId, config, job, ligneQuota: { enrichissements: 14 }, maintenant: MAINTENANT, schemaReponse });
  assert.equal(ok.http, 200);
  assert.equal(ok.reponse.statut, 'termine');
  assert.equal(ok.reponse.quota.enrichissements_restants_mois, 86);
  const lent = j.reponseSuivi({ entetes, jobId, config, job: { ...job, statut: 'en_cours', resultat: '', createdAt: '2026-10-21T08:50:00Z' }, maintenant: MAINTENANT, schemaReponse });
  assert.equal(lent.reponse.erreur.code, 'delai_depasse');
  assert.equal(j.reponseSuivi({ entetes, jobId, config, job: null, maintenant: MAINTENANT, schemaReponse }).http, 404);
  assert.equal(j.reponseSuivi({ entetes: {}, jobId, config, job, maintenant: MAINTENANT, schemaReponse }).http, 401);
});

test('NFR-07 bibliothèque assemblée (sans commentaires) : même comportement', () => {
  const vm = require('node:vm');
  const a = require('../assembler.js');
  const code = a.noeud('controle_enrichissement').replace(/^const e = [\s\S]*$/m, '');
  const ctx = vm.createContext({ TextEncoder, TextDecoder, Intl, URL });
  vm.runInContext(code + '\n;globalThis.decisionEntree = decisionEntree;', ctx);
  const texteCorps = JSON.stringify(requete);
  const args = { type: 'enrichissement', texteCorps, ...signer(texteCorps), config, jobExistant: null, ligneQuota: { enrichissements: 3 }, maintenant: MAINTENANT, schemaRequete, schemaReponse, aleatoire: () => 0.5 };
  const attendu = j.decisionEntree(args);
  const obtenu = JSON.parse(JSON.stringify(ctx.decisionEntree(args)));
  attendu.job.version_flux = obtenu.job.version_flux;
  assert.deepEqual(obtenu, JSON.parse(JSON.stringify(attendu)));
  assert.equal(ctx.decisionEntree({ ...args, entetes: {} }).reponse.erreur.code, 'auth_invalide');
});
