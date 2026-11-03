// Comptes (CPT-01 à CPT-04, contrat 2.0) : connexion par code envoyé par
// mail, clé de session propre au compte, quotas selon le statut. Dépend de
// securite.js, schema.js et enveloppes.js (assemblés avant ce fichier dans le
// nœud Code, chargés par require dans les tests).
if (typeof require !== 'undefined' && typeof enveloppeJob === 'undefined') Object.assign(globalThis, require('./enveloppes.js'));

const VERSION_CONTRAT_COMPTE = '2.0';
const CODE_VALABLE_S = 600;
const ESSAIS_CODE_MAX = 5;
const HTTP_COMPTE = {
  requete_invalide: 400, code_invalide: 401, code_expire: 401, auth_invalide: 401,
  signature_expiree: 401, quota_depasse: 429, interne: 500,
};
const CHEMINS_COMPTE = { etat: '/webhook/iacave/compte', deconnexion: '/webhook/iacave/compte/deconnexion' };

/** Octets aléatoires sûrs (le nœud Code n'a pas globalThis.crypto). */
function octetsAleatoires(n) {
  return require('crypto').randomBytes(n);
}

/** Tirage dans [0, 1) sûr, pour uuidV4. */
function aleatoireSur(alea = octetsAleatoires) {
  const b = alea(4);
  return (((b[0] << 24) >>> 0) + (b[1] << 16) + (b[2] << 8) + b[3]) / 4294967296;
}

function codeAleatoire(alea = octetsAleatoires) {
  return String(Math.floor(aleatoireSur(alea) * 1000000)).padStart(6, '0');
}

/** Comparaison en temps constant de deux chaînes. */
function egalEnTempsConstant(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

function normaliserEmail(email) {
  return String(email || '').trim().toLowerCase();
}

/** Le code n'est jamais gardé en clair : seulement son empreinte. */
function empreinteCode(email, code) {
  return toHex(sha256(utf8(normaliserEmail(email) + '\n' + code)));
}

function moisCompte(date) {
  const p = new Intl.DateTimeFormat('fr-FR', { timeZone: 'Europe/Paris', year: 'numeric', month: '2-digit' }).formatToParts(date);
  return p.find((x) => x.type === 'year').value + '-' + p.find((x) => x.type === 'month').value;
}

function entier(config, cle, defaut) {
  const n = parseInt(config[cle], 10);
  return Number.isFinite(n) && n >= 0 ? n : defaut;
}

/** CPT-04 : limites mensuelles selon le statut du compte. */
function limitesCompte(config, statut) {
  if (statut === 'abonne') {
    return { quota_enrichissements: entier(config, 'quota_abonne_enrichissements', 500), quota_prix: entier(config, 'quota_abonne_prix', 500) };
  }
  if (statut === 'gratuit') {
    return { quota_enrichissements: entier(config, 'quota_gratuit_enrichissements', 10), quota_prix: entier(config, 'quota_gratuit_prix', 10) };
  }
  return { quota_enrichissements: 0, quota_prix: 0 };
}

/** Compte connu, non bloqué, avec une clé de session non expirée. */
function compteActif(compte, maintenant) {
  return !!(compte && compte.compte_id && compte.statut !== 'bloque' && compte.cle_session
    && Date.parse(compte.cle_expire_le || 0) > maintenant);
}

/**
 * Configuration vue par les contrôles d'entrée existants : la clé du compte
 * remplace la clé partagée, les limites du statut remplacent les quotas
 * globaux. Un compte inactif n'a pas de clé : toute signature est refusée.
 */
function configPourCompte(config, compte, maintenant) {
  return {
    ...config,
    cle_app: compteActif(compte, maintenant) ? compte.cle_session : '',
    ...limitesCompte(config, compte && compte.statut),
  };
}

function compteDepuisEntetes(entetes) {
  for (const [k, v] of Object.entries(entetes || {})) {
    if (k.toLowerCase() === 'x-iacav-compte') return String(Array.isArray(v) ? v[0] : v);
  }
  return '';
}

function comptePublic(compte, config, ligneUsage) {
  return {
    compte_id: compte.compte_id,
    email: compte.email,
    statut_compte: compte.statut,
    quota: quotaRestant(limitesCompte(config, compte.statut), ligneUsage),
  };
}

function erreurCompte(code, message, requestId, reessayable) {
  return {
    http: HTTP_COMPTE[code],
    reponse: {
      version_contrat: VERSION_CONTRAT_COMPTE,
      request_id: estUuid(requestId) ? requestId : UUID_NUL,
      statut: 'erreur',
      erreur: { code, message, reessayable: reessayable !== undefined ? reessayable : !['requete_invalide', 'quota_depasse'].includes(code) },
    },
  };
}

/** Corps lu, adresse mise en minuscules et sans espaces autour. */
function lireCorps(texteCorps) {
  try {
    const v = typeof texteCorps === 'string' ? JSON.parse(texteCorps) : texteCorps;
    if (!v || typeof v !== 'object' || Array.isArray(v)) return null;
    return typeof v.email === 'string' ? { ...v, email: normaliserEmail(v.email) } : v;
  } catch (e) {
    return null;
  }
}

/**
 * POST /compte/code (CPT-01) : code à 6 chiffres envoyé par mail, valable
 * 10 minutes, 5 envois par heure et par adresse au plus. La réponse ne dit
 * pas si l'adresse a déjà un compte.
 */
function decisionCode({ texteCorps, config, ligneCode, maintenant, schemaRequete, schemaReponse, alea = octetsAleatoires }) {
  const corps = lireCorps(texteCorps);
  const requestId = corps && corps.request_id;
  if (!corps) return { decision: 'refus', ...erreurCompte('requete_invalide', 'Corps JSON illisible.', requestId) };
  const erreurs = validateSchema(schemaRequete, corps);
  if (erreurs.length) return { decision: 'refus', ...erreurCompte('requete_invalide', 'Adresse mail invalide ou demande hors contrat.', requestId) };
  const email = normaliserEmail(corps.email);
  const parHeure = entier(config, 'codes_par_heure', 5);
  const debut = ligneCode && Date.parse(ligneCode.fenetre_debut || 0);
  const dansLHeure = debut && maintenant - debut < 3600 * 1000;
  const envois = dansLHeure ? (parseInt(ligneCode.envois, 10) || 0) : 0;
  if (envois >= parHeure) {
    return { decision: 'refus', ...erreurCompte('quota_depasse', `${parHeure} codes par heure au plus : réessayez dans une heure.`, requestId) };
  }
  const code = codeAleatoire(alea);
  const reponse = { version_contrat: VERSION_CONTRAT_COMPTE, request_id: corps.request_id, statut: 'code_envoye', code_valable_s: CODE_VALABLE_S };
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  return {
    decision: 'envoi',
    http: 200,
    reponse,
    ligne: {
      email,
      code_empreinte: empreinteCode(email, code),
      expire_le: new Date(maintenant + CODE_VALABLE_S * 1000).toISOString(),
      essais: 0,
      envois: envois + 1,
      fenetre_debut: dansLHeure ? ligneCode.fenetre_debut : new Date(maintenant).toISOString(),
    },
    mail: {
      a: email,
      sujet: `Votre code IA cave à vin : ${code}`,
      texte: [
        'Bonjour,',
        '',
        `Votre code de connexion à IA cave à vin : ${code}`,
        '',
        'Il est valable 10 minutes. Si vous n\'avez rien demandé, ignorez ce message : sans le code, personne ne peut se connecter à votre compte.',
        '',
        'IA cave à vin, Apexus-BMT',
      ].join('\n'),
    },
  };
}

/**
 * POST /compte/session (CPT-01) : code juste et non expiré, compte créé au
 * besoin (statut gratuit), nouvelle clé de session renvoyée. 5 essais au plus
 * par code, puis il faut en demander un autre.
 */
function decisionSession({
  texteCorps, config, ligneCode, compte, ligneUsage, maintenant, schemaRequete, schemaReponse, alea = octetsAleatoires,
}) {
  const corps = lireCorps(texteCorps);
  const requestId = corps && corps.request_id;
  if (!corps) return { decision: 'refus', ...erreurCompte('requete_invalide', 'Corps JSON illisible.', requestId) };
  const erreurs = validateSchema(schemaRequete, corps);
  if (erreurs.length) return { decision: 'refus', ...erreurCompte('requete_invalide', 'Demande hors contrat : ' + erreurs.slice(0, 3).join(' ; '), requestId) };
  const email = normaliserEmail(corps.email);
  if (!ligneCode || !ligneCode.code_empreinte) {
    return { decision: 'refus', ...erreurCompte('code_invalide', 'Aucun code en cours pour cette adresse : demandez-en un.', requestId, false) };
  }
  const essais = parseInt(ligneCode.essais, 10) || 0;
  if (essais >= ESSAIS_CODE_MAX || Date.parse(ligneCode.expire_le || 0) <= maintenant) {
    return { decision: 'refus', ...erreurCompte('code_expire', 'Code expiré ou trop d\'essais : demandez un nouveau code.', requestId, false) };
  }
  if (!egalEnTempsConstant(empreinteCode(email, corps.code), String(ligneCode.code_empreinte))) {
    return {
      decision: 'echec',
      ...erreurCompte('code_invalide', `Code incorrect. Essais restants : ${ESSAIS_CODE_MAX - essais - 1}.`, requestId, true),
      ligne_code: { email, essais: essais + 1 },
    };
  }
  if (compte && compte.statut === 'bloque') {
    return { decision: 'refus', ...erreurCompte('auth_invalide', 'Compte suspendu : écrivez à apexus.claude@gmail.com.', requestId, false) };
  }
  const jours = entier(config, 'cle_session_jours', 180);
  const nouveau = {
    compte_id: compte && compte.compte_id ? compte.compte_id : uuidV4(() => aleatoireSur(alea)),
    email,
    statut: compte && compte.statut ? compte.statut : 'gratuit',
    cle_session: toHex(alea(32)),
    cle_expire_le: new Date(maintenant + jours * 86400 * 1000).toISOString(),
    cree_le: compte && compte.cree_le ? compte.cree_le : new Date(maintenant).toISOString(),
    derniere_connexion: new Date(maintenant).toISOString(),
    installation: corps.installation,
  };
  const usage = compte && ligneUsage && ligneUsage.compte_id === nouveau.compte_id ? ligneUsage : null;
  const reponse = {
    version_contrat: VERSION_CONTRAT_COMPTE,
    request_id: corps.request_id,
    statut: 'connecte',
    compte: { ...comptePublic(nouveau, config, usage), cle_session: nouveau.cle_session, cle_expire_le: nouveau.cle_expire_le },
  };
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  // Le code ne sert qu'une fois.
  return { decision: 'connecte', http: 200, reponse, compte: nouveau, ligne_code: { email, code_empreinte: '', essais: ESSAIS_CODE_MAX } };
}

/**
 * GET /compte et POST /compte/deconnexion (CPT-02), signés avec la clé du
 * compte. La déconnexion révoque la clé.
 */
function decisionEtatCompte({ action, entetes, empreinte, config, compte, ligneUsage, maintenant, schemaReponse }) {
  const methode = action === 'deconnexion' ? 'POST' : 'GET';
  const configCompte = configPourCompte(config, compte, maintenant);
  if (!compteActif(compte, maintenant)) {
    return { decision: 'refus', ...erreurCompte('auth_invalide', 'Session expirée ou inconnue : reconnectez-vous.', null, false) };
  }
  const auth = verifierRequete({
    entetes, methode, chemin: CHEMINS_COMPTE[action], corps: empreinte, cle: configCompte.cle_app,
    maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return { decision: 'refus', ...erreurCompte(auth.code, auth.message, null) };
  const reponse = {
    version_contrat: VERSION_CONTRAT_COMPTE,
    request_id: UUID_NUL,
    statut: action === 'deconnexion' ? 'deconnecte' : 'ok',
    compte: comptePublic(compte, config, ligneUsage && ligneUsage.compte_id === compte.compte_id ? ligneUsage : null),
  };
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  const r = { decision: action, http: 200, reponse };
  if (action === 'deconnexion') r.compte = { compte_id: compte.compte_id, cle_session: '', cle_expire_le: new Date(maintenant).toISOString() };
  return r;
}

/**
 * Contrôles d'entrée de /enrichissement, /prix et /jobs avec un compte :
 * refus clair sans session, sinon la décision existante avec la clé et les
 * limites du compte. Renvoie aussi la ligne d'usage du mois à écrire pour un
 * nouveau job (le compteur avance à l'envoi accepté).
 */
function entreeAvecCompte({ compte, config, ligneUsage, maintenant, requestId, type, decider }) {
  if (!compteActif(compte, maintenant)) {
    const message = compte && compte.statut === 'bloque'
      ? 'Compte suspendu : l\'identification n\'est pas disponible.'
      : 'Connectez-vous à votre compte pour utiliser l\'identification et les prix.';
    return { decision: 'refus', http: 401, reponse: enveloppeErreur('auth_invalide', message, { requestId, type, reessayable: false }) };
  }
  const usage = ligneUsage && ligneUsage.compte_id === compte.compte_id ? ligneUsage : null;
  const d = decider(configPourCompte(config, compte, maintenant), usage);
  if (d.decision === 'refus' && d.reponse && d.reponse.erreur && d.reponse.erreur.code === 'quota_depasse' && compte.statut === 'gratuit') {
    const lim = limitesCompte(config, 'gratuit');
    d.reponse.erreur.message = type === 'prix'
      ? `Quota gratuit atteint : ${lim.quota_prix} relevés de prix par mois. Relance possible le 1er du mois.`
      : `Quota gratuit atteint : ${lim.quota_enrichissements} identifications par mois. La fiche reste à enrichir, relance possible le 1er du mois.`;
  }
  if (d.decision === 'nouveau') {
    d.job.compte_id = compte.compte_id;
    d.envoi.compte_id = compte.compte_id;
    // La charge utile 2.0 est celle de la 1.3 : seule l'authentification
    // change. Le sous-flux raisonne en version 1.x (cadres d'étiquette).
    d.envoi.requete = { ...d.envoi.requete, version_contrat: '1.3' };
    d.usage = {
      compte_id: compte.compte_id,
      mois: moisCompte(new Date(maintenant)),
      enrichissements: ((usage && usage.enrichissements) || 0) + (type === 'prix' ? 0 : 1),
      prix: ((usage && usage.prix) || 0) + (type === 'prix' ? 1 : 0),
    };
  }
  return d;
}

if (typeof module !== 'undefined') {
  module.exports = {
    VERSION_CONTRAT_COMPTE, CODE_VALABLE_S, ESSAIS_CODE_MAX, CHEMINS_COMPTE, codeAleatoire, normaliserEmail, empreinteCode,
    moisCompte, limitesCompte, compteActif, configPourCompte, compteDepuisEntetes, decisionCode, decisionSession,
    decisionEtatCompte, entreeAvecCompte, comptePublic, erreurCompte,
  };
}
