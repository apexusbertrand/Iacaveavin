// Enveloppes conformes à reponse-job.schema.json, configuration et quotas.

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

if (typeof module !== 'undefined') {
  module.exports = { VERSION_CONTRAT, UUID_NUL, DELAI_JOB_MS, HTTP, CHEMINS, estUuid, uuidV4, lireConfig, quotaRestant, enveloppeErreur, enveloppeJob };
}
