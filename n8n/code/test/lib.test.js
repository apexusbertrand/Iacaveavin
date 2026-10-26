// Tests des fonctions des nœuds Code du flux. Lancer : node --test n8n/code/test/
const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const { sha256, toHex, utf8, signatureAttendue, verifierRequete } = require('../lib/securite.js');
const m = require('../lib/metier.js');
const { validateSchema } = require('../lib/schema.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (p) => JSON.parse(fs.readFileSync(path.join(racine, p), 'utf8'));
const vecteur = lire('specs/contrat-n8n/vecteur-signature.json');
const schemaReponse = lire('specs/contrat-n8n/reponse-job.schema.json');
const termine = lire('specs/contrat-n8n/exemples/enrichissement-termine.json');

test('NFR-06 SHA-256 en JavaScript pur identique à node:crypto', () => {
  for (const n of [0, 1, 55, 56, 63, 64, 65, 1000, 100000]) {
    const data = crypto.randomBytes(n);
    assert.equal(toHex(sha256(data)), crypto.createHash('sha256').update(data).digest('hex'));
  }
});

test('NFR-06 signature conforme au vecteur fixe du contrat', () => {
  const corps = utf8(vecteur.corps);
  assert.equal(toHex(sha256(corps)), vecteur.sha256_corps);
  assert.equal(
    signatureAttendue(vecteur.cle, vecteur.horodatage, vecteur.methode, vecteur.chemin, corps),
    vecteur.signature,
  );
  // Clé longue (> 64 octets) : même résultat que node:crypto.
  const cle = 'k'.repeat(100);
  const attendu = crypto.createHmac('sha256', cle)
    .update(`1\nGET\n/x\n${crypto.createHash('sha256').update('').digest('hex')}`).digest('hex');
  assert.equal(signatureAttendue(cle, '1', 'GET', '/x', new Uint8Array()), attendu);
});

const requete = (over = {}) => ({
  entetes: {
    'X-IACAV-Installation': '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10',
    'X-IACAV-Horodatage': vecteur.horodatage,
    'X-IACAV-Signature': vecteur.signature,
  },
  methode: 'POST',
  chemin: vecteur.chemin,
  corps: utf8(vecteur.corps),
  cle: vecteur.cle,
  maintenant: Number(vecteur.horodatage) + 10,
  ...over,
});

test('NFR-06 requête signée acceptée', () => {
  assert.deepEqual(verifierRequete(requete()), { ok: true, installation: '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10' });
});

test('NFR-06 refus : en-tête absent, horodatage hors fenêtre, signature fausse, corps modifié', () => {
  const sans = requete();
  delete sans.entetes['X-IACAV-Signature'];
  assert.equal(verifierRequete(sans).code, 'auth_invalide');
  assert.equal(verifierRequete(requete({ maintenant: Number(vecteur.horodatage) + 301 })).code, 'signature_expiree');
  assert.equal(verifierRequete(requete({ maintenant: Number(vecteur.horodatage) - 301 })).code, 'signature_expiree');
  assert.equal(verifierRequete(requete({ cle: 'autre-cle' })).code, 'auth_invalide');
  assert.equal(verifierRequete(requete({ corps: utf8(vecteur.corps + ' ') })).code, 'auth_invalide');
  assert.equal(verifierRequete(requete({ chemin: '/webhook/iacave/prix' })).code, 'auth_invalide');
  assert.equal(verifierRequete(requete({ cle: '' })).code, 'auth_invalide');
  // Empreinte du corps calculée à l'entrée du flux : même verdict.
  assert.equal(verifierRequete(requete({ corps: vecteur.sha256_corps })).ok, true);
});

test('docs/06 clé de cache normalisée', () => {
  assert.equal(
    m.cleVin({ domaine: "Château L'Évangile", appellation: 'Pomerol', cuvee: null, millesime: 2015 }),
    'chateau-l-evangile|pomerol||2015',
  );
  assert.equal(
    m.cleVin({ domaine: 'Domaine  Zind-Humbrecht', appellation: 'Alsace Grand Cru', cuvee: 'Clos Windsbuhl', millesime: 'NM' }),
    'domaine-zind-humbrecht|alsace-grand-cru|clos-windsbuhl|nm',
  );
  assert.equal(m.normaliser('Cœur de Cuvée'), 'coeur-de-cuvee');
  assert.equal(m.cleVin({ domaine: '', millesime: 2015 }), null);
  assert.equal(m.cleVin({ domaine: 'X', millesime: null }), null);
});

const marchands = ['vinatis.com', 'millesima.fr', 'nicolas.com'];
const offre = (prix, site = 'vinatis.com', verifie = true) => ({
  site, url: `https://www.${site}/vin-${prix}`, prix, millesime_verifie: verifie,
});
const params = { formatCl: 75, devise: 'EUR', date: '2026-10-21', domainesMarchands: marchands };

test('docs/06 prix : médiane, offre unique, aberrations et sites non autorisés écartés', () => {
  const p = m.agregerPrix([offre(20), offre(30, 'millesima.fr'), offre(25, 'nicolas.com'), offre(400)], params);
  assert.equal(p.trouve, true);
  assert.equal(p.nature, 'mediane');
  assert.equal(p.nb_offres, 3, 'offre à plus de 5 fois la médiane écartée');
  assert.equal(p.prix, 25);
  const seule = m.agregerPrix([offre(18.499), offre(19, 'cavevolee.fr')], params);
  assert.equal(seule.nature, 'offre');
  assert.equal(seule.prix, 18.5);
  assert.equal(seule.url, 'https://www.vinatis.com/vin-18.499');
  const aucune = m.agregerPrix([offre(20, 'vinatis.com', false)], params);
  assert.equal(aucune.trouve, false, 'millésime non vérifié : jamais retenu');
  assert.ok(aucune.motif.length > 3);
  for (const r of [p, seule, aucune]) {
    const doc = { ...termine, resultat: { ...termine.resultat, prix: [r] } };
    assert.deepEqual(validateSchema(schemaReponse, doc), [], 'prix agrégé conforme au contrat');
  }
});

function avecSources(res) {
  const urls = new Set(m.urlsCitees(res));
  return { ...res, sources_consultees: [...urls].map((url) => ({ url, consultee_le: '2026-10-21', utilisee: true })) };
}

test('NFR-07 contrôles de sortie : exemple du contrat accepté une fois mis en règle', () => {
  // L'exemple du contrat cite deux offres absentes de sources_consultees et
  // retient une offre au millésime non vérifié (écart T59) : on le met aux
  // règles de docs/06 avant de le contrôler.
  const r = JSON.parse(JSON.stringify(termine.resultat));
  const offres = r.prix[0].offres.filter((o) => o.millesime_verifie);
  r.prix = [m.agregerPrix(offres, { formatCl: 75, devise: 'EUR', date: '2026-10-20', domainesMarchands: offres.map((o) => o.site) })];
  const propre = avecSources(r);
  const { resultat, erreurs } = m.controlerEnrichissement(propre, {
    anneeCourante: 2026, domainesMarchands: offres.map((o) => o.site),
  });
  assert.deepEqual(erreurs, []);
  assert.deepEqual(validateSchema(schemaReponse, { ...termine, resultat }), []);
  const brut = m.controlerEnrichissement(termine.resultat, { anneeCourante: 2026, domainesMarchands: offres.map((o) => o.site) });
  assert.equal(brut.erreurs.length, 3, 'l\'exemple brut est refusé par les contrôles');
});

test('NFR-07 contrôles de sortie : URL non consultée, bornes, fenêtre, site de prix non autorisé', () => {
  const base = avecSources(termine.resultat);
  const ctx = { anneeCourante: 2026, domainesMarchands: [] };
  const r = JSON.parse(JSON.stringify(base));
  r.fiche.degre = { valeur: 31, source: 'etiquette', confiance: 0.9 };
  r.fiche.millesime = { valeur: 2031, source: 'etiquette', confiance: 0.9 };
  r.fiche.garde = { valeur: { debut: 2020, fin: 2018 }, source: 'critique', url: 'https://piege.example/note', confiance: 0.8 };
  const e = m.controlerEnrichissement(r, ctx).erreurs.join(' | ');
  assert.match(e, /degré 31/);
  assert.match(e, /millésime 2031/);
  assert.match(e, /fin avant le début/);
  assert.match(e, /absente de sources_consultees : https:\/\/piege.example\/note/);
  assert.match(e, /prix sur un site non autorisé/);
});

test('PRV-R2 champ verrouillé retiré de la proposition, avec alerte', () => {
  const ctx = { anneeCourante: 2026, champsVerrouilles: ['degre', 'domaine'], domainesMarchands: [] };
  const r = JSON.parse(JSON.stringify(termine.resultat));
  r.prix = [];
  const { resultat } = m.controlerEnrichissement(r, ctx);
  assert.equal(resultat.fiche.degre, undefined);
  assert.equal(resultat.fiche.domaine.valeur, null, 'champ obligatoire vidé avec motif');
  assert.ok(resultat.alertes.some((a) => a.code === 'champ_verrouille_ignore' && a.champ === 'degre'));
  assert.deepEqual(validateSchema(schemaReponse, { ...termine, resultat }), []);
});

test('FIC-01 règle 2 : valeur estimée retirée sauf couleur, type et accords', () => {
  const r = JSON.parse(JSON.stringify(termine.resultat));
  r.prix = [];
  r.fiche.signe_qualite = { valeur: 'AOC', source: 'estimation', confiance: 0.7, note: 'déduit' };
  r.fiche.commentaire_millesime = { valeur: 'Texte rédigé de mémoire, sans source.', source: 'estimation', confiance: 0.5 };
  r.fiche.type = { valeur: 'tranquille', source: 'estimation', confiance: 0.9, note: 'pas de bulles' };
  const { resultat } = m.controlerEnrichissement(r, { anneeCourante: 2026 });
  assert.equal(resultat.fiche.signe_qualite.valeur, null);
  assert.equal(resultat.fiche.commentaire_millesime.valeur, null);
  assert.equal(resultat.fiche.type.valeur, 'tranquille');
  assert.deepEqual(validateSchema(schemaReponse, { ...termine, resultat }), []);
});

test('FIC-01 règle 15 : accords toujours proposés, pris dans la liste', () => {
  const permis = ['Volaille', 'Charcuterie', 'Fromage à pâte molle', 'Poisson grillé'];
  const ctx = { anneeCourante: 2026, accordsPermis: permis, accordsObligatoires: true };
  const r = JSON.parse(JSON.stringify(termine.resultat));
  r.prix = [];
  r.fiche.accords = { valeur: ['volaille', 'Pizza aux anchois', 'Fromage a pate molle'], source: 'estimation', confiance: 0.9 };
  const ok = m.controlerEnrichissement(r, ctx);
  assert.deepEqual(ok.resultat.fiche.accords.valeur, ['Volaille', 'Fromage à pâte molle']);
  assert.equal(ok.resultat.fiche.accords.confiance, 0.6, 'confiance plafonnée');
  assert.ok(!ok.erreurs.some((e) => /accords/.test(e)));
  r.fiche.accords = { valeur: null, source: null, confiance: null, motif: 'recherche web indisponible' };
  assert.match(m.controlerEnrichissement(r, ctx).erreurs.join(' | '), /accords mets-vins manquants/);
  assert.deepEqual(m.controlerEnrichissement(r, { ...ctx, champsVerrouilles: ['accords'] }).erreurs.filter((e) => /accords/.test(e)), []);
  assert.deepEqual(m.controlerEnrichissement(r, { anneeCourante: 2026 }).erreurs.filter((e) => /accords/.test(e)), [], 'cache : pas de relance');
});

test('NFR-07 recherche intégrée : URL vues, coût, sources refaites (T85)', () => {
  const rc = require('../lib/recherche.js');
  const message = {
    content: [
      { type: 'web_search_tool_result', content: [{ type: 'web_search_result', url: 'https://masonesime.com/' }, { url: 'https://www.demeter.fr/a' }] },
      { type: 'web_search_tool_result', content: { type: 'web_search_tool_result_error', error_code: 'max_uses_exceeded' } },
      { type: 'text', text: 'x' },
    ],
    usage: { server_tool_use: { web_search_requests: 3 } },
  };
  assert.deepEqual(rc.urlsVues(message), ['https://masonesime.com/', 'https://www.demeter.fr/a']);
  assert.deepEqual(rc.coutRecherche(message), { appels_modele: 1, credits_recherche: 3 });
  assert.equal(rc.urlComparable('https://www.Demeter.fr/a/#x'), rc.urlComparable('https://demeter.fr/a'));
  const r = { fiche: {
    domaine_site_officiel: { valeur: 'https://masonesime.com', source: 'site_officiel', url: 'https://masonesime.com', confiance: 1 },
    cepages: { valeur: null, source: null, confiance: null, motif: 'x', url: 'https://inventee.fr/p' },
  }, sources_consultees: [{ url: 'https://pas-vue.fr', consultee_le: '2020-01-01' }] };
  const c = JSON.parse(rc.completerSources(JSON.stringify(r), rc.urlsVues(message), '2026-10-26'));
  assert.deepEqual(c.sources_consultees, [{ url: 'https://masonesime.com', consultee_le: '2026-10-26', utilisee: true }]);
  assert.equal(rc.completerSources('pas de JSON', [], '2026-10-26'), 'pas de JSON');
});

test('docs/06 quota mensuel au fuseau de Paris', () => {
  assert.equal(m.moisQuota(new Date('2026-10-31T23:30:00Z')), '2026-11');
  assert.equal(m.jourParis(new Date('2026-10-21T22:30:00Z')), '2026-10-22');
});
