// CPT-01 à CPT-04 : comptes, code par mail, clé de session, quotas par statut.
// Lancer : node --test n8n/code/test/*.test.js
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

Object.assign(globalThis, require('../lib/securite.js'), require('../lib/schema.js'), require('../lib/enveloppes.js'));
Object.assign(globalThis, require('../lib/entree.js'));
const c = require('../lib/comptes.js');
const { signatureAttendue, sha256, toHex, utf8 } = require('../lib/securite.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (p) => JSON.parse(fs.readFileSync(path.join(racine, p), 'utf8'));
const S = {
  code: lire('specs/contrat-n8n/requete-compte-code.schema.json'),
  session: lire('specs/contrat-n8n/requete-compte-session.schema.json'),
  reponse: lire('specs/contrat-n8n/reponse-compte.schema.json'),
  enrich: lire('specs/contrat-n8n/requete-enrichissement.schema.json'),
  job: lire('specs/contrat-n8n/reponse-job.schema.json'),
};
const MAINTENANT = Date.parse('2026-11-01T10:00:00Z');
const config = { fenetre_secondes: '300' };
const INSTALLATION = '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10';
// Aléa fixe : octets 0, 1, 2… pour des tests reproductibles.
const alea = (n) => Buffer.from(Array.from({ length: n }, (_, i) => (i * 37 + 11) % 256));

const demande = { version_contrat: '2.0', request_id: '7d1c2a9e-5b3f-4e6a-8c2d-1f0e9a8b7c6d', email: ' Prenom.Nom@Exemple.fr ', installation: INSTALLATION };

function codeEnvoye() {
  const d = c.decisionCode({ texteCorps: demande, config, ligneCode: null, maintenant: MAINTENANT, schemaRequete: S.code, schemaReponse: S.reponse, alea });
  return { d, code: d.mail.sujet.match(/(\d{6})$/)[1] };
}

test('CPT-01 code envoyé : 6 chiffres, empreinte seule gardée, adresse normalisée', () => {
  const { d, code } = codeEnvoye();
  assert.equal(d.decision, 'envoi');
  assert.equal(d.reponse.statut, 'code_envoye');
  assert.equal(d.ligne.email, 'prenom.nom@exemple.fr');
  assert.notEqual(d.ligne.code_empreinte, code);
  assert.equal(d.ligne.code_empreinte, c.empreinteCode('prenom.nom@exemple.fr', code));
  assert.equal(d.mail.a, 'prenom.nom@exemple.fr');
  assert.ok(!JSON.stringify(d.reponse).includes(code), 'le code ne part jamais dans la réponse');
});

test('CPT-01 au plus 5 codes par heure et par adresse', () => {
  const ligne = { email: 'prenom.nom@exemple.fr', envois: 5, fenetre_debut: new Date(MAINTENANT - 10 * 60000).toISOString() };
  const d = c.decisionCode({ texteCorps: demande, config, ligneCode: ligne, maintenant: MAINTENANT, schemaRequete: S.code, schemaReponse: S.reponse, alea });
  assert.equal(d.decision, 'refus');
  assert.equal(d.reponse.erreur.code, 'quota_depasse');
  const vieille = { ...ligne, fenetre_debut: new Date(MAINTENANT - 2 * 3600000).toISOString() };
  assert.equal(c.decisionCode({ texteCorps: demande, config, ligneCode: vieille, maintenant: MAINTENANT, schemaRequete: S.code, schemaReponse: S.reponse, alea }).decision, 'envoi');
});

test('CPT-01 adresse mal formée refusée', () => {
  const d = c.decisionCode({ texteCorps: { ...demande, email: 'pas-un-mail' }, config, ligneCode: null, maintenant: MAINTENANT, schemaRequete: S.code, schemaReponse: S.reponse, alea });
  assert.equal(d.reponse.erreur.code, 'requete_invalide');
});

function session(code, ligneCode, compte = null) {
  return c.decisionSession({
    texteCorps: { version_contrat: '2.0', request_id: '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e', email: 'prenom.nom@exemple.fr', code, installation: INSTALLATION },
    config, ligneCode, compte, ligneUsage: null, maintenant: MAINTENANT + 60000, schemaRequete: S.session, schemaReponse: S.reponse, alea,
  });
}

test('CPT-01 bon code : compte gratuit créé, clé de 64 caractères, code consommé', () => {
  const { d, code } = codeEnvoye();
  const r = session(code, d.ligne);
  assert.equal(r.decision, 'connecte');
  assert.equal(r.compte.statut, 'gratuit');
  assert.match(r.reponse.compte.cle_session, /^[0-9a-f]{64}$/);
  assert.deepEqual(r.reponse.compte.quota, { enrichissements_restants_mois: 10, prix_restants_mois: 10 });
  assert.equal(r.ligne_code.code_empreinte, '');
  assert.deepEqual(validateSchema(S.reponse, r.reponse), []);
});

test('CPT-01 compte existant : même identifiant et même statut, nouvelle clé', () => {
  const { d, code } = codeEnvoye();
  const existant = { compte_id: '3c9e1f4a-2b7d-4e8f-a1c3-5d6e7f8a9b0c', email: 'prenom.nom@exemple.fr', statut: 'abonne', cle_session: 'a'.repeat(64), cree_le: '2026-01-01T00:00:00.000Z' };
  const r = session(code, d.ligne, existant);
  assert.equal(r.compte.compte_id, existant.compte_id);
  assert.equal(r.compte.statut, 'abonne');
  assert.notEqual(r.compte.cle_session, existant.cle_session);
  assert.equal(r.reponse.compte.quota.enrichissements_restants_mois, 500);
});

test('CPT-01 mauvais code : essai compté ; 5 essais ou code expiré : nouveau code exigé', () => {
  const { d, code } = codeEnvoye();
  const faux = code === '000000' ? '111111' : '000000';
  const r = session(faux, d.ligne);
  assert.equal(r.decision, 'echec');
  assert.equal(r.reponse.erreur.code, 'code_invalide');
  assert.equal(r.ligne_code.essais, 1);
  assert.equal(session(code, { ...d.ligne, essais: 5 }).reponse.erreur.code, 'code_expire');
  assert.equal(session(code, { ...d.ligne, expire_le: new Date(MAINTENANT).toISOString() }).reponse.erreur.code, 'code_expire');
  assert.equal(session(code, null).reponse.erreur.code, 'code_invalide');
});

test('CPT-04 compte bloqué : pas de clé, pas d\'accès au flux', () => {
  const { d, code } = codeEnvoye();
  const r = session(code, d.ligne, { compte_id: '3c9e1f4a-2b7d-4e8f-a1c3-5d6e7f8a9b0c', email: 'prenom.nom@exemple.fr', statut: 'bloque' });
  assert.equal(r.decision, 'refus');
  assert.equal(r.reponse.erreur.code, 'auth_invalide');
});

const compteActif = {
  compte_id: '3c9e1f4a-2b7d-4e8f-a1c3-5d6e7f8a9b0c', email: 'prenom.nom@exemple.fr', statut: 'gratuit',
  cle_session: 'b'.repeat(64), cle_expire_le: '2027-01-01T00:00:00.000Z',
};

function requeteSignee(cle, corps, chemin = '/webhook/iacave/enrichissement') {
  const texteCorps = JSON.stringify(corps);
  const empreinte = toHex(sha256(utf8(texteCorps)));
  const ts = String(MAINTENANT / 1000);
  return {
    texteCorps, empreinte,
    entetes: { 'x-iacav-installation': INSTALLATION, 'x-iacav-compte': compteActif.compte_id, 'x-iacav-horodatage': ts, 'x-iacav-signature': signatureAttendue(cle, ts, 'POST', chemin, empreinte) },
  };
}

function entree(compte, ligneUsage, cle = compteActif.cle_session) {
  const corps = lire('specs/contrat-n8n/exemples/requete-enrichissement.json');
  const r = requeteSignee(cle, corps);
  return c.entreeAvecCompte({
    compte, config, ligneUsage, maintenant: MAINTENANT, requestId: corps.request_id, type: 'enrichissement',
    decider: (cfg, usage) => decisionEntree({ type: 'enrichissement', ...r, config: cfg, jobExistant: null, ligneQuota: usage, maintenant: MAINTENANT, schemaRequete: S.enrich, schemaReponse: S.job }),
  });
}

test('CPT-02 sans compte ou session expirée : identification refusée', () => {
  assert.equal(entree(null, null).reponse.erreur.code, 'auth_invalide');
  assert.match(entree(null, null).reponse.erreur.message, /Connectez-vous/);
  assert.equal(entree({ ...compteActif, cle_expire_le: '2026-01-01T00:00:00.000Z' }, null).decision, 'refus');
});

test('CPT-02 signée avec la clé du compte : job créé, compte et usage du mois notés', () => {
  const d = entree(compteActif, null);
  assert.equal(d.decision, 'nouveau');
  assert.equal(d.job.compte_id, compteActif.compte_id);
  assert.equal(d.envoi.compte_id, compteActif.compte_id);
  assert.deepEqual(d.usage, { compte_id: compteActif.compte_id, mois: '2026-11', enrichissements: 1, prix: 0 });
  assert.equal(d.envoi.requete.version_contrat, '1.3', 'charge du sous-flux en 1.x : cadres renvoyés');
  assert.equal(d.reponse.quota.enrichissements_restants_mois, 10);
});

test('CPT-02 signée avec une autre clé : refusée', () => {
  assert.equal(entree(compteActif, null, 'c'.repeat(64)).reponse.erreur.code, 'auth_invalide');
});

test('CPT-04 quota gratuit épuisé : refus avec le message du gratuit ; abonné au-delà', () => {
  const usage = { compte_id: compteActif.compte_id, mois: '2026-11', enrichissements: 10, prix: 0 };
  const d = entree(compteActif, usage);
  assert.equal(d.reponse.erreur.code, 'quota_depasse');
  assert.match(d.reponse.erreur.message, /Quota gratuit atteint : 10 identifications/);
  assert.equal(entree({ ...compteActif, statut: 'abonne' }, usage).decision, 'nouveau');
  assert.equal(entree({ ...compteActif, statut: 'bloque' }, null).decision, 'refus');
});

test('CPT-02 état du compte et déconnexion signés ; la déconnexion révoque la clé', () => {
  const etat = (action, cle = compteActif.cle_session) => {
    const methode = action === 'deconnexion' ? 'POST' : 'GET';
    const empreinte = toHex(sha256(new Uint8Array()));
    const ts = String(MAINTENANT / 1000);
    const entetes = { 'x-iacav-installation': INSTALLATION, 'x-iacav-compte': compteActif.compte_id, 'x-iacav-horodatage': ts, 'x-iacav-signature': signatureAttendue(cle, ts, methode, c.CHEMINS_COMPTE[action], empreinte) };
    return c.decisionEtatCompte({ action, entetes, empreinte, config, compte: compteActif, ligneUsage: { compte_id: compteActif.compte_id, enrichissements: 3, prix: 1 }, maintenant: MAINTENANT, schemaReponse: S.reponse });
  };
  const ok = etat('etat');
  assert.equal(ok.reponse.statut, 'ok');
  assert.deepEqual(ok.reponse.compte.quota, { enrichissements_restants_mois: 7, prix_restants_mois: 9 });
  assert.ok(!('cle_session' in ok.reponse.compte));
  const fin = etat('deconnexion');
  assert.equal(fin.reponse.statut, 'deconnecte');
  assert.equal(fin.compte.cle_session, '');
  assert.equal(etat('etat', 'd'.repeat(64)).reponse.erreur.code, 'auth_invalide');
});

test('CPT-05 suppression signée : compte anonymisé, adresse et clé effacées', () => {
  const e = require('../lib/compte_etat.js');
  const empreinte = toHex(sha256(utf8('{}')));
  const ts = String(MAINTENANT / 1000);
  const signe = (cle) => ({ 'x-iacav-installation': INSTALLATION, 'x-iacav-compte': compteActif.compte_id, 'x-iacav-horodatage': ts, 'x-iacav-signature': signatureAttendue(cle, ts, 'POST', e.CHEMINS_COMPTE_21.suppression, empreinte) });
  const d = e.decisionCompteSigne({ action: 'suppression', entetes: signe(compteActif.cle_session), empreinte, config, compte: compteActif, ligneUsage: null, maintenant: MAINTENANT, schemaReponse: S.reponse });
  assert.equal(d.decision, 'suppression');
  assert.equal(d.reponse.statut, 'supprime');
  assert.ok(!('compte' in d.reponse));
  assert.deepEqual({ email: d.compte.email, statut: d.compte.statut, cle: d.compte.cle_session }, { email: '', statut: 'supprime', cle: '' });
  assert.equal(d.compte.compte_id, compteActif.compte_id);
  // Une autre clé ne supprime rien.
  const refus = e.decisionCompteSigne({ action: 'suppression', entetes: signe('d'.repeat(64)), empreinte, config, compte: compteActif, ligneUsage: null, maintenant: MAINTENANT, schemaReponse: S.reponse });
  assert.equal(refus.reponse.erreur.code, 'auth_invalide');
  assert.ok(!refus.compte);
});

test('CPT-01 codes tirés au hasard sûr : 6 chiffres', () => {
  for (let i = 0; i < 50; i++) assert.match(c.codeAleatoire(), /^\d{6}$/);
});

test('CPT-01 CPT-02 nœud assemblé : les trois chemins dans le bac à sable', async () => {
  const vm = require('node:vm');
  const a = require('../assembler.js');
  const executer = async (noeuds) => {
    const $ = (nom) => {
      if (!(nom in noeuds)) return { isExecuted: false, first: () => { throw new Error('absent : ' + nom); }, all: () => [] };
      const items = [].concat(noeuds[nom]).map((json) => ({ json }));
      return { first: () => items[0], all: () => items, isExecuted: true };
    };
    const ctx = vm.createContext({ $, TextEncoder, TextDecoder, Intl, Buffer, require });
    return JSON.parse(JSON.stringify(await vm.runInContext(`(async function () {\n${a.noeud('compte')}\n}).call({ helpers: {} })`, ctx)));
  };
  const [code] = await executer({ 'Webhook code': { body: demande }, 'Config code': [{}], 'Code en cours': [{}] });
  assert.equal(code.json.action, 'code');
  assert.equal(code.json.decision, 'envoi');
  const chiffres = code.json.mail.sujet.match(/(\d{6})$/)[1];
  const [ses] = await executer({
    'Webhook session': { body: { version_contrat: '2.0', request_id: '8e2d3b0f-6c4a-4f7b-9d3e-2a1f0b9c8d7e', email: 'prenom.nom@exemple.fr', code: chiffres, installation: INSTALLATION } },
    'Config session': [{}], 'Code de session': code.json.ligne, 'Compte de session': [{}], 'Usage de session': [{}],
  });
  assert.equal(ses.json.decision, 'connecte', JSON.stringify(ses.json.reponse));
  const [etat] = await executer({
    'Empreinte compte': { empreinte: 'x', entetes: {} }, 'Config compte': [{}], 'Compte signé': [{}], 'Usage du compte': [{}],
  });
  assert.equal(etat.json.action, 'etat');
  assert.equal(etat.json.reponse.erreur.code, 'auth_invalide');
});
