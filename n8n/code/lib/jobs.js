// Jobs du flux : décision d'entrée des webhooks POST, réponse du suivi
// GET /jobs/:job_id, enveloppes conformes à reponse-job.schema.json.
// Dépend de securite.js, schema.js et metier.js (assemblés avant ce fichier
// dans le nœud Code, ou chargés par require dans les tests).

const VERSION_CONTRAT = '1.0';
const UUID_NUL = '00000000-0000-4000-8000-000000000000';
const DELAI_JOB_MS = 4 * 60 * 1000; // l'app abandonne à 3 min ; marge d'une minute
const HTTP = {
  requete_invalide: 400, version_non_supportee: 400, auth_invalide: 401, signature_expiree: 401,
  quota_depasse: 429, photo_illisible: 422, delai_depasse: 504, interne: 500,
};
const CHEMINS = {
  enrichissement: '/webhook/iacave/enrichissement',
  prix: '/webhook/iacave/prix',
};

const estUuid = (s) => typeof s === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(s);

function uuidV4(aleatoire = Math.random) {
  const h = [];
  for (let i = 0; i < 16; i++) h.push(Math.floor(aleatoire() * 256));
  h[6] = (h[6] & 0x0f) | 0x40;
  h[8] = (h[8] & 0x3f) | 0x80;
  const x = h.map((b) => b.toString(16).padStart(2, '0')).join('');
  return `${x.slice(0, 8)}-${x.slice(8, 12)}-${x.slice(12, 16)}-${x.slice(16, 20)}-${x.slice(20)}`;
}

/** Lignes de iacave_config → { cle: valeur }. */
function lireConfig(lignes) {
  const c = {};
  for (const l of lignes || []) if (l && l.cle) c[l.cle] = l.valeur == null ? '' : String(l.valeur);
  return c;
}

/** Quotas restants du mois à partir de la ligne iacave_quotas (ou rien). */
function quotaRestant(config, ligne) {
  const q = (cle, defaut) => {
    const n = parseInt(config[cle], 10);
    return Number.isFinite(n) && n >= 0 ? n : defaut;
  };
  const utilises = ligne || {};
  return {
    enrichissements_restants_mois: Math.max(0, q('quota_enrichissements', 100) - (utilises.enrichissements || 0)),
    prix_restants_mois: Math.max(0, q('quota_prix', 120) - (utilises.prix || 0)),
  };
}

function enveloppeErreur(code, message, { jobId, requestId, type, quota, ficheId, reessayable }) {
  const r = {
    version_contrat: VERSION_CONTRAT,
    job_id: estUuid(jobId) ? jobId : UUID_NUL,
    request_id: estUuid(requestId) ? requestId : UUID_NUL,
    type: type === 'prix' ? 'prix' : 'enrichissement',
    statut: 'erreur',
    erreur: { code, message: String(message).slice(0, 500), reessayable: reessayable !== undefined ? reessayable : !['quota_depasse', 'requete_invalide', 'version_non_supportee'].includes(code) },
  };
  if (estUuid(ficheId)) r.fiche_id = ficheId;
  if (quota) r.quota = quota;
  return r;
}

/** Enveloppe du contrat à partir d'une ligne de iacave_jobs. */
function enveloppeJob(job, quota) {
  const r = {
    version_contrat: VERSION_CONTRAT,
    job_id: job.job_id,
    request_id: job.request_id,
    type: job.type,
    statut: job.statut,
  };
  if (estUuid(job.fiche_id)) r.fiche_id = job.fiche_id;
  if (job.etape) r.etape = job.etape;
  if (quota) r.quota = quota;
  if (job.resultat) r.resultat = JSON.parse(job.resultat);
  if (job.erreur) r.erreur = JSON.parse(job.erreur);
  return r;
}

function parserCorps(texte) {
  try {
    const v = JSON.parse(texte);
    return v && typeof v === 'object' && !Array.isArray(v) ? v : null;
  } catch (e) {
    return null;
  }
}

/**
 * Décision à l'entrée de POST /enrichissement et POST /prix, dans l'ordre de
 * docs/06 : en-têtes, horodatage, signature, request_id déjà vu, quota,
 * schéma. Renvoie { decision: 'refus' | 'existant' | 'nouveau', http,
 * reponse } et, pour un nouveau job, la ligne à créer (job) et la charge du
 * sous-flux (envoi).
 */
function decisionEntree({
  type, entetes, empreinte, texteCorps, config, jobExistant, ligneQuota,
  maintenant, schemaRequete, schemaReponse, aleatoire,
}) {
  const corps = parserCorps(texteCorps);
  const requestId = corps && corps.request_id;
  const quota = quotaRestant(config, ligneQuota);
  const refus = (code, message) => {
    const reponse = enveloppeErreur(code, message, { requestId, type });
    return { decision: 'refus', http: HTTP[code], reponse };
  };

  const auth = verifierRequete({
    entetes, methode: 'POST', chemin: CHEMINS[type], corps: empreinte, cle: config.cle_app,
    maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return refus(auth.code, auth.message);
  if (!corps) return refus('requete_invalide', 'Corps JSON illisible.');
  if (typeof corps.version_contrat !== 'string' || !/^1\./.test(corps.version_contrat)) {
    return refus('version_non_supportee', 'Version de contrat attendue : 1.x.');
  }
  if (jobExistant && jobExistant.job_id) {
    // Idempotence : même request_id, même job, renvoyé tel quel.
    return { decision: 'existant', http: 200, reponse: enveloppeJob(jobExistant, quota) };
  }
  const restant = type === 'prix' ? quota.prix_restants_mois : quota.enrichissements_restants_mois;
  if (restant <= 0) {
    const r = enveloppeErreur('quota_depasse', type === 'prix'
      ? 'Quota mensuel de recherches de prix atteint, relance possible le 1er du mois.'
      : "Quota mensuel d'enrichissements atteint. La fiche reste en brouillon, relance possible le 1er du mois.",
    { requestId, type, quota, ficheId: corps.fiche_id });
    return { decision: 'refus', http: HTTP.quota_depasse, reponse: r };
  }
  const erreurs = validateSchema(schemaRequete, corps);
  if (erreurs.length) return refus('requete_invalide', 'Requête hors contrat : ' + erreurs.slice(0, 3).join(' ; '));

  const jobId = uuidV4(aleatoire);
  const sansPhotos = { ...corps };
  if (sansPhotos.photos) sansPhotos.photos = sansPhotos.photos.map((p) => ({ index: p.index, type_photo: p.type_photo, mime: p.mime, octets: Math.floor(p.base64.length * 0.75) }));
  const job = {
    job_id: jobId,
    request_id: corps.request_id,
    type,
    statut: 'en_attente',
    etape: type === 'prix' ? 'prix' : 'lecture_etiquette',
    fiche_id: corps.fiche_id || '',
    installation: auth.installation,
    requete: JSON.stringify(sansPhotos),
    resultat: '',
    erreur: '',
    version_flux: '__VERSION_FLUX__',
  };
  const reponse = enveloppeJob(job, quota);
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  return { decision: 'nouveau', http: 202, reponse, job, envoi: { job_id: jobId, type, requete: corps, recu_le: maintenant } };
}

/** Réponse de GET /jobs/:job_id (signature d'un corps vide). */
function reponseSuivi({ entetes, jobId, config, job, ligneQuota, maintenant, schemaReponse }) {
  const quota = quotaRestant(config, ligneQuota);
  const auth = verifierRequete({
    entetes, methode: 'GET', chemin: '/webhook/iacave/jobs/' + jobId, corps: new Uint8Array(),
    cle: config.cle_app, maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return { http: HTTP[auth.code], reponse: enveloppeErreur(auth.code, auth.message, { jobId }) };
  if (!job || !job.job_id) {
    return { http: 404, reponse: enveloppeErreur('requete_invalide', 'Job inconnu ou expiré.', { jobId, reessayable: false }) };
  }
  let reponse = enveloppeJob(job, quota);
  const age = maintenant - Date.parse(job.createdAt || job.updatedAt || 0);
  if (['en_attente', 'en_cours'].includes(job.statut) && age > DELAI_JOB_MS) {
    reponse = enveloppeErreur('delai_depasse', 'Le flux n\'a pas terminé dans le délai : relancez l\'enrichissement.', {
      jobId: job.job_id, requestId: job.request_id, type: job.type, quota, ficheId: job.fiche_id,
    });
  }
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) {
    reponse = enveloppeErreur('interne', 'Réponse enregistrée hors contrat.', { jobId: job.job_id, requestId: job.request_id, type: job.type });
    return { http: 500, reponse, erreurs: verif };
  }
  return { http: 200, reponse };
}

if (typeof module !== 'undefined') {
  module.exports = {
    UUID_NUL, CHEMINS, uuidV4, lireConfig, quotaRestant, enveloppeErreur, enveloppeJob,
    decisionEntree, reponseSuivi, estUuid,
  };
}
