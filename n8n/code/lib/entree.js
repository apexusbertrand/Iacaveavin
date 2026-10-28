// Décision d'entrée des webhooks POST /enrichissement et /prix. Dépend de
// securite.js, schema.js et enveloppes.js (assemblés avant ce fichier dans le
// nœud Code, chargés par require dans les tests).
if (typeof require !== 'undefined' && typeof enveloppeJob === 'undefined') Object.assign(globalThis, require('./enveloppes.js'));

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

if (typeof module !== 'undefined') module.exports = { ...require('./enveloppes.js'), decisionEntree };
