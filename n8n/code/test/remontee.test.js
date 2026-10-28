// RET-01 : remontée d'information par mail (contrat 1.3).
// Lancer : node --test n8n/code/test/*.test.js
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

Object.assign(globalThis, require('../lib/securite.js'), require('../lib/schema.js'));
const r = require('../lib/remontee.js');
const a = require('../assembler.js');
const { signatureAttendue, sha256, toHex, utf8 } = require('../lib/securite.js');

const racine = path.resolve(__dirname, '../../..');
const lire = (p) => JSON.parse(fs.readFileSync(path.join(racine, p), 'utf8'));
const schemaRequete = lire('specs/contrat-n8n/requete-remontee.schema.json');
const schemaReponse = lire('specs/contrat-n8n/reponse-remontee.schema.json');
const exemple = lire('specs/contrat-n8n/exemples/requete-remontee.json');

const CLE = 'cle-de-developpement';
const MAINTENANT = Date.parse('2026-10-28T20:00:00Z');
const INSTALLATION = '0b8f7e2a-4c1d-4a9b-8e3f-2d6c5b4a3f10';
const config = { cle_app: CLE, fenetre_secondes: '300' };

function signe(corps, { cle = CLE, chemin = r.CHEMIN_REMONTEE } = {}) {
  const texteCorps = typeof corps === 'string' ? corps : JSON.stringify(corps);
  const empreinte = toHex(sha256(utf8(texteCorps)));
  const ts = String(MAINTENANT / 1000);
  return {
    texteCorps, empreinte,
    entetes: {
      'x-iacav-installation': INSTALLATION,
      'x-iacav-horodatage': ts,
      'x-iacav-signature': signatureAttendue(cle, ts, 'POST', chemin, empreinte),
    },
  };
}

const decider = (corps, over = {}) => r.decisionRemontee({
  ...signe(corps, over), config, envoisDuJour: [], maintenant: MAINTENANT,
  schemaRequete, schemaReponse, ...over,
});

test('RET-01 remontée signée : mail à l\'équipe, copie et réponse au contact', () => {
  const d = decider(exemple);
  assert.equal(d.decision, 'envoi');
  assert.equal(d.http, 200);
  assert.deepEqual(validateSchema(schemaReponse, d.reponse), []);
  assert.deepEqual(validateSchema(schemaReponse, d.reponse_echec), []);
  assert.equal(d.reponse.envoi_restants_jour, 4);
  assert.equal(d.mail.a, 'apexus.claude@gmail.com');
  assert.equal(d.mail.cc, exemple.email_contact);
  assert.equal(d.mail.repondreA, exemple.email_contact);
  assert.equal(d.mail.sujet, '[IA cave à vin] Millésime mal lu');
  assert.match(d.mail.texte, /De : bertrand\.exemple@exemple\.fr/);
  assert.match(d.mail.texte, /le millésime proposé était 2012/);
  assert.match(d.mail.texte, /Pièce jointe : capture\.pdf/);
  assert.equal(d.piece.mime, 'application/pdf');
  assert.equal(d.ligne.installation, INSTALLATION);
  assert.equal(d.ligne.jour, '2026-10-28');
});

test('RET-01 refus : signature, contrat, faux PDF, plafond quotidien', () => {
  assert.equal(decider(exemple, { cle: 'autre' }).reponse.erreur.code, 'auth_invalide');
  // Signé pour un autre chemin : refusé.
  assert.equal(decider(exemple, { chemin: '/webhook/iacave/prix' }).http, 401);
  const mauvaisMail = decider({ ...exemple, email_contact: 'bertrand@exemple' });
  assert.equal(mauvaisMail.reponse.erreur.code, 'requete_invalide');
  assert.equal(mauvaisMail.reponse.erreur.reessayable, false);
  const zip = decider({ ...exemple, piece_jointe: { ...exemple.piece_jointe, mime: 'application/zip' } });
  assert.equal(zip.http, 400);
  // Type annoncé PDF, contenu PNG : refusé.
  const faux = decider({ ...exemple, piece_jointe: { ...exemple.piece_jointe, base64: 'iVBORw0KGgoAAAANSUhEUg==' } });
  assert.match(faux.reponse.erreur.message, /ne correspond pas/);
  const lourd = 'JVBERi0' + 'A'.repeat(7 * 1024 * 1024 - 7);
  assert.equal(decider({ ...exemple, piece_jointe: { ...exemple.piece_jointe, base64: lourd } }).http, 400);
  const jour = r.jourRemontee(new Date(MAINTENANT));
  const cinq = Array.from({ length: 5 }, () => ({ installation: INSTALLATION, jour }));
  const plein = decider(exemple, { envoisDuJour: cinq });
  assert.equal(plein.http, 429);
  assert.equal(plein.reponse.erreur.code, 'quota_depasse');
  assert.deepEqual(validateSchema(schemaReponse, plein.reponse), []);
  // Les envois d'une autre installation ou d'hier ne comptent pas.
  const autres = [...cinq.map((x) => ({ ...x, installation: 'autre' })), { installation: INSTALLATION, jour: '2026-10-27' }];
  assert.equal(decider(exemple, { envoisDuJour: autres }).decision, 'envoi');
  // Un titre sur plusieurs lignes ne casse pas l'objet du mail.
  assert.equal(decider({ ...exemple, titre: 'A\nBcc: x@y.fr' }).mail.sujet, '[IA cave à vin] A Bcc: x@y.fr');
});

test('RET-01 nœud assemblé : pièce jointe en binaire, base64 retiré du JSON', async () => {
  const s = signe(exemple);
  const noeuds = {
    'Empreinte remontée': { empreinte: s.empreinte, texteCorps: s.texteCorps, entetes: s.entetes },
    'Config remontée': [{ cle: 'cle_app', valeur: CLE }],
    'Remontées du jour': [{}],
  };
  const $ = (nom) => {
    const items = [].concat(noeuds[nom]).map((json) => ({ json }));
    return { first: () => items[0], all: () => items };
  };
  const helpers = {
    prepareBinaryData: async (buffer, fileName, mimeType) => ({ data: buffer.toString('base64'), fileName, mimeType }),
  };
  const ctx = vm.createContext({ $, TextEncoder, TextDecoder, Intl, Buffer, Date: class extends Date {
    constructor(...x) { super(...(x.length ? x : [MAINTENANT])); }
    static now() { return MAINTENANT; }
  } });
  const [item] = await vm.runInContext(`(async function () {\n${a.noeud('remontee')}\n})`, ctx).call({ helpers });
  assert.equal(item.json.decision, 'envoi', JSON.stringify(item.json.reponse));
  assert.equal(item.json.avec_piece, true);
  assert.equal(item.json.piece.base64, undefined);
  assert.equal(item.binary.piece_jointe.fileName, 'capture.pdf');
  assert.equal(item.binary.piece_jointe.data, exemple.piece_jointe.base64);
});
