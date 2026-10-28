// POST /iacave/remontee (RET-01, contrat 1.3) : remontée d'information de
// l'utilisateur envoyée par mail. Dépend de securite.js et schema.js.

const CHEMIN_REMONTEE = '/webhook/iacave/remontee';
const DESTINATAIRE_REMONTEE = 'apexus.claude@gmail.com';
const REMONTEES_PAR_JOUR = 5;
const VERSION_CONTRAT_REMONTEE = '1.3';
const HTTP_REMONTEE = { requete_invalide: 400, auth_invalide: 401, signature_expiree: 401, quota_depasse: 429, interne: 500 };
const UUID_NUL_REMONTEE = '00000000-0000-4000-8000-000000000000';

/** Jour civil à Paris (AAAA-MM-JJ), pour le plafond quotidien. */
function jourRemontee(date) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Paris' }).format(date);
}

/** Une ligne de texte : ni retour à la ligne ni caractère de contrôle. */
function uneLigne(texte) {
  return String(texte).replace(/[\u0000-\u001f\u007f]+/g, ' ').replace(/\s+/g, ' ').trim();
}

/** Nombre d'octets décodés d'une chaîne base64. */
function octetsBase64(b64) {
  const s = String(b64).replace(/\s/g, '');
  const pad = s.endsWith('==') ? 2 : s.endsWith('=') ? 1 : 0;
  return Math.floor((s.length * 3) / 4) - pad;
}

/** Signature du fichier conforme au type annoncé (PDF ou image). */
function signatureFichierOk(mime, b64) {
  const debut = String(b64).replace(/\s/g, '').slice(0, 24);
  const prefixes = {
    'application/pdf': ['JVBERi0'],
    'image/jpeg': ['/9j/'],
    'image/png': ['iVBORw0KGgo'],
    'image/webp': ['UklGR'],
  }[mime] || [];
  return prefixes.some((p) => debut.startsWith(p));
}

/**
 * Décision sur une remontée : refus (avec la réponse au contrat) ou envoi
 * (avec le mail à composer et la ligne de journal).
 */
function decisionRemontee({ entetes, empreinte, texteCorps, config, envoisDuJour, maintenant, schemaRequete, schemaReponse }) {
  let corps = null;
  try {
    const v = JSON.parse(texteCorps);
    corps = v && typeof v === 'object' && !Array.isArray(v) ? v : null;
  } catch (e) {
    corps = null;
  }
  const requestId = corps && /^[0-9a-f-]{36}$/i.test(corps.request_id || '') ? corps.request_id : UUID_NUL_REMONTEE;
  const refus = (code, message, extra = {}) => ({
    decision: 'refus',
    http: HTTP_REMONTEE[code],
    reponse: {
      version_contrat: VERSION_CONTRAT_REMONTEE,
      request_id: requestId,
      statut: 'erreur',
      ...extra,
      erreur: { code, message, reessayable: !['requete_invalide', 'quota_depasse'].includes(code) },
    },
  });
  const auth = verifierRequete({
    entetes, methode: 'POST', chemin: CHEMIN_REMONTEE, corps: empreinte, cle: config.cle_app,
    maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return refus(auth.code, auth.message);
  if (!corps) return refus('requete_invalide', 'Corps JSON illisible.');
  const erreurs = validateSchema(schemaRequete, corps);
  if (erreurs.length) return refus('requete_invalide', 'Remontée hors contrat : ' + erreurs.slice(0, 3).join(' ; '));
  const pj = corps.piece_jointe;
  if (pj && octetsBase64(pj.base64) > 5 * 1024 * 1024) return refus('requete_invalide', 'Pièce jointe de plus de 5 Mo.');
  if (pj && !signatureFichierOk(pj.mime, pj.base64)) return refus('requete_invalide', 'Pièce jointe : le contenu ne correspond pas à un PDF ou à une image.');
  const jour = jourRemontee(new Date(maintenant));
  const plafond = parseInt(config.remontees_par_jour, 10) || REMONTEES_PAR_JOUR;
  const deja = (envoisDuJour || []).filter((r) => r && r.installation === auth.installation && r.jour === jour).length;
  if (deja >= plafond) {
    return refus('quota_depasse', `${plafond} remontées par jour au plus : réessayez demain.`, { envoi_restants_jour: 0 });
  }
  const titre = uneLigne(corps.titre);
  const contact = corps.email_contact.trim();
  const texte = [
    'Remontée envoyée depuis l\'application IA cave à vin.',
    '',
    'De : ' + contact,
    'Titre : ' + titre,
    'Version de l\'app : ' + (corps.version_app ? uneLigne(corps.version_app) : 'inconnue'),
    'Installation : ' + auth.installation,
    'Date du téléphone : ' + corps.date_client,
    pj ? 'Pièce jointe : ' + uneLigne(pj.nom) : 'Pièce jointe : aucune',
    '',
    '----',
    String(corps.commentaire).replace(/\r\n?/g, '\n'),
    '----',
    '',
    'Répondre à ce mail écrit à ' + contact + '.',
  ].join('\n');
  const reponse = {
    version_contrat: VERSION_CONTRAT_REMONTEE,
    request_id: corps.request_id,
    statut: 'envoye',
    envoi_restants_jour: Math.max(0, plafond - deja - 1),
  };
  // Réponse si Gmail refuse l'envoi (adresse rejetée, panne) : rien n'est parti.
  const reponseEchec = {
    version_contrat: VERSION_CONTRAT_REMONTEE,
    request_id: corps.request_id,
    statut: 'erreur',
    erreur: { code: 'interne', message: 'Le mail n\'est pas parti, réessayez plus tard.', reessayable: true },
  };
  const verif = [...validateSchema(schemaReponse, reponse), ...validateSchema(schemaReponse, reponseEchec)];
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  return {
    decision: 'envoi',
    http: 200,
    reponse,
    reponse_echec: reponseEchec,
    mail: {
      a: DESTINATAIRE_REMONTEE,
      cc: contact,
      repondreA: contact,
      nomExpediteur: 'IA cave à vin, de la part de ' + contact,
      sujet: '[IA cave à vin] ' + titre,
      texte,
    },
    piece: pj ? { nom: uneLigne(pj.nom), mime: pj.mime, base64: String(pj.base64).replace(/\s/g, '') } : null,
    ligne: {
      request_id: corps.request_id, installation: auth.installation, jour, titre,
      email_contact: contact, piece_jointe: pj ? uneLigne(pj.nom) : '',
    },
  };
}

if (typeof module !== 'undefined') {
  module.exports = { CHEMIN_REMONTEE, DESTINATAIRE_REMONTEE, REMONTEES_PAR_JOUR, jourRemontee, octetsBase64, signatureFichierOk, decisionRemontee };
}
