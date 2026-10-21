// Clôture d'un relevé de prix : coût, cache de 24 heures, quota du mois,
// alerte à 80 %. En mode job, la réponse complète est validée contre le
// contrat avant écriture ; en mode interne, le résultat repart vers
// l'enrichissement qui l'a demandé.
// @inclure schema.js
// @inclure normalisation.js
// @inclure enveloppes.js
const e = $('Déclencheur prix').first().json;
function resultatConforme() {
  for (const n of ['Contrôles correction prix', 'Contrôles prix', 'Décision prix']) {
    try {
      if ($(n).isExecuted) {
        const j = $(n).first().json;
        if (j && j.ok) return j;
      }
    } catch (err) {
      // Nœud absent de cette exécution.
    }
  }
  throw new Error('aucun résultat de prix conforme à clôturer');
}
const c = resultatConforme();
const config = lireConfig($('Config prix').all().map((i) => i.json));
const ligneQuota = $('Quota prix').all().map((i) => i.json).find((r) => r.mois) || null;
const maintenant = Date.now();
const jour = jourParis(new Date(maintenant));
const mode = e.mode || 'job';
const resultat = { ...c.resultat };
resultat.cache = c.cache ? { hit: true, cle: c.cle, date: c.date_cache || jour } : { hit: false };
resultat.cout = { appels_modele: c.cout.appels_modele, credits_recherche: c.cout.credits_recherche, duree_ms: Math.max(0, maintenant - (e.recu_le || maintenant)) };
const trouve = (resultat.prix || []).some((p) => p.trouve);
// Relevé fini, prix trouvé ou non : trouve et motif portent le sens.
const statut = 'termine';
const job = { job_id: e.job_id, request_id: e.requete.request_id, type: 'prix', statut, etape: 'termine', fiche_id: e.requete.fiche_id || '', resultat: JSON.stringify(resultat) };
if (mode === 'job') {
  const erreurs = validateSchema(__SCHEMA_REPONSE__, enveloppeJob(job, quotaRestant(config, ligneQuota)));
  if (erreurs.length) throw new Error('Réponse de prix hors contrat : ' + erreurs.slice(0, 5).join(' ; '));
}
const mois = moisQuota(new Date(maintenant));
const q = ligneQuota || { mois, enrichissements: 0, prix: 0, credits_recherche: 0, appels_modele: 0, alerte_envoyee: false };
// En mode interne, l'enrichissement décompte lui-même son coût.
const quota = {
  mois,
  enrichissements: q.enrichissements || 0,
  prix: (q.prix || 0) + (mode === 'job' ? 1 : 0),
  credits_recherche: (q.credits_recherche || 0) + (mode === 'job' ? resultat.cout.credits_recherche : 0),
  appels_modele: (q.appels_modele || 0) + (mode === 'job' ? resultat.cout.appels_modele : 0),
  alerte_envoyee: !!q.alerte_envoyee,
};
const plafond = parseInt(config.quota_prix, 10) || 120;
const seuil = parseFloat(config.seuil_alerte) || 0.8;
const alerte = mode === 'job' && !quota.alerte_envoyee && quota.prix >= Math.ceil(plafond * seuil);
if (alerte) quota.alerte_envoyee = true;
return [{ json: {
  mode,
  job_id: e.job_id,
  statut,
  resultat: job.resultat,
  journal: JSON.stringify({ cout: resultat.cout, cache: !!c.cache, ecartees: c.ecartees || [], erreurs_corrigees: c.erreurs_avant || [] }),
  ecrire_cache: !c.cache && !!c.cle && c.cle !== 'aucune-cle' && trouve,
  cache_ligne: { cle: c.cle, resultat: JSON.stringify({ ...resultat, cache: undefined, cout: undefined }), date_maj: new Date(maintenant).toISOString() },
  quota,
  alerte,
  alerte_message: `Quota de relevés de prix IA cave à vin : ${quota.prix} sur ${plafond} ce mois (${mois}).`,
  email: config.email_alerte || '',
  retour: { ok: true, prix: resultat.prix, alertes: resultat.alertes, sources_consultees: resultat.sources_consultees, cout: resultat.cout },
} }];
