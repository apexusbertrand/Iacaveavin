// Flux d'erreur : message lisible pour le mail et erreur au contrat pour le
// job concerné (retrouvé par l'identifiant d'exécution).
const e = $input.first().json;
const ex = e.execution || {};
const message = (ex.error && ex.error.message) || 'erreur inconnue';
const code = /^photo_illisible/.test(message) ? 'photo_illisible' : 'interne';
const erreur = {
  code,
  message: code === 'photo_illisible' ? 'Étiquette illisible : reprenez une photo plus nette.' : 'Erreur interne du flux, relance possible.',
  reessayable: true,
};
return [{ json: {
  execution_id: String(ex.id || ''),
  flux: (e.workflow && e.workflow.name) || '',
  noeud: ex.lastNodeExecuted || '',
  url: ex.url || '',
  message: String(message).slice(0, 1000),
  erreur: JSON.stringify(erreur),
} }];
