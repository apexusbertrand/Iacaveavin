// Clôture du job (docs/06, étape 11) : statut, coût, cache, quota, alerte à
// 80 %. La réponse complète est validée contre le contrat avant écriture.
// @inclure schema.js
// @inclure normalisation.js
// @inclure metier.js
// @inclure modele.js
// @inclure agent.js
// @inclure jobs.js
const envoi = $('Déclencheur enrichissement').first().json;
// Trois chemins mènent ici : cache, sortie conforme, sortie corrigée.
function resultatConforme() {
  for (const n of ['Contrôles après correction', 'Contrôles de sortie', 'Résultat du cache']) {
    try {
      if ($(n).isExecuted) {
        const j = $(n).first().json;
        if (j && j.ok) return j;
      }
    } catch (e) {
      // Nœud absent de cette exécution.
    }
  }
  throw new Error('aucun résultat conforme à clôturer');
}
const c = resultatConforme();
const config = lireConfig($('Config enrichissement').all().map((i) => i.json));
const ligneQuota = $('Quota clôture').all().map((i) => i.json).find((r) => r.mois) || null;
const schema = __SCHEMA_REPONSE__;
const maintenant = Date.now();
const jour = jourParis(new Date(maintenant));
const resultat = c.resultat;
resultat.cache = c.cache ? { hit: true, cle: c.cle, date: c.date_cache || jour } : { hit: false };
resultat.cout = { appels_modele: c.cout.appels_modele, credits_recherche: c.cout.credits_recherche, duree_ms: Math.max(0, maintenant - (envoi.recu_le || maintenant)) };
const statut = statutFinal(resultat);
const job = { job_id: envoi.job_id, request_id: envoi.requete.request_id, type: 'enrichissement', statut, etape: 'termine', fiche_id: envoi.requete.fiche_id || '', resultat: JSON.stringify(resultat) };
const erreurs = validateSchema(schema, enveloppeJob(job, quotaRestant(config, ligneQuota)));
if (erreurs.length) throw new Error('Réponse finale hors contrat : ' + erreurs.slice(0, 5).join(' ; '));

const mois = moisQuota(new Date(maintenant));
const q = ligneQuota || { mois, enrichissements: 0, prix: 0, credits_recherche: 0, appels_modele: 0, alerte_envoyee: false };
const quota = {
  mois,
  enrichissements: (q.enrichissements || 0) + 1,
  prix: q.prix || 0,
  credits_recherche: (q.credits_recherche || 0) + resultat.cout.credits_recherche,
  appels_modele: (q.appels_modele || 0) + resultat.cout.appels_modele,
  alerte_envoyee: !!q.alerte_envoyee,
};
const plafond = parseInt(config.quota_enrichissements, 10) || 100;
const seuil = parseFloat(config.seuil_alerte) || 0.8;
const alerte = !quota.alerte_envoyee && quota.enrichissements >= Math.ceil(plafond * seuil);
if (alerte) quota.alerte_envoyee = true;
const sansTranscription = { ...resultat, transcription: [] };
return [{ json: {
  job_id: envoi.job_id,
  statut,
  resultat: job.resultat,
  journal: JSON.stringify({ cout: resultat.cout, cache: c.cache, erreurs_corrigees: c.erreurs_avant || [] }),
  ecrire_cache: c.avec_cle && !c.cache && statut === 'termine',
  cache_ligne: { cle: c.cle, resultat: JSON.stringify(sansTranscription), utilisations: 1, date_maj: jour },
  quota,
  alerte,
  alerte_message: `Quota d'enrichissements IA cave à vin : ${quota.enrichissements} sur ${plafond} ce mois (${mois}).`,
  email: config.email_alerte || '',
} }];
