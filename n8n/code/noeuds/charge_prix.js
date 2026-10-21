// Prix demandé avec l'enrichissement (inclure_prix) : requête de relevé tirée
// de la fiche conforme, envoyée au sous-flux IA_CAVE_Prix en mode interne.
const envoi = $('Déclencheur enrichissement').first().json;
let c = null;
for (const n of ['Contrôles après correction', 'Contrôles de sortie', 'Résultat du cache']) {
  try {
    if ($(n).isExecuted && $(n).first().json.ok) { c = $(n).first().json; break; }
  } catch (e) {
    // Nœud absent de cette exécution.
  }
}
const f = (c && c.resultat && c.resultat.fiche) || {};
const v = (k) => (f[k] && f[k].valeur != null ? f[k].valeur : null);
const millesime = v('millesime');
return [{ json: {
  mode: 'interne',
  job_id: envoi.job_id,
  recu_le: Date.now(),
  requete: {
    version_contrat: '1.0',
    request_id: envoi.requete.request_id,
    identite: {
      domaine: v('domaine') || '', cuvee: v('cuvee'), appellation: v('appellation'),
      millesime: millesime == null ? '' : millesime, couleur: v('couleur') || 'autre', lwin: v('lwin'), ean: null,
    },
    format_cl: Number(v('volume_cl')) || 75,
    devise: 'EUR',
    forcer: false,
    date_client: envoi.requete.date_client,
  },
} }];
