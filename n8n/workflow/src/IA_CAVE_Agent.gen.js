// Flux principal IA_CAVE_Agent : points d'entrée de docs/06 (santé,
// enrichissement, suivi des jobs). Le traitement tourne dans
// IA_CAVE_Enrichissement, lancé sans attente.
const SOUS_FLUX_ENRICHISSEMENT = '5z197yDZlge7nrpM';

module.exports = (o) => {
  const CTL = "$('Contrôles enrichissement').first().json";
  return `import { workflow, node, trigger, ifElse, sticky, expr } from '@n8n/workflow-sdk';

${o.webhook('webhookSante', 'Webhook santé', 'GET', 'iacave/sante', false)}
${o.lire('configSante', 'Config santé', 'config', [], { tout: true })}
${o.code('sante', 'Santé du flux', 'sante', "{ version_flux: '0.1.0', version_contrat: '1.0', ok: true }")}
const repondreSante = node({
  type: 'n8n-nodes-base.respondToWebhook', version: 1.5,
  config: { name: 'Répondre santé', parameters: { respondWith: 'firstIncomingItem', options: { responseCode: 200 } } }
});

${o.webhook('webhookEnrich', 'Webhook enrichissement', 'POST', 'iacave/enrichissement', true)}
${o.code('empreinte', 'Empreinte enrichissement', 'empreinte', "{ empreinte: 'x', texteCorps: '{}', requestId: 'x', entetes: {} }")}
${o.lire('configEnrich', 'Config enrichissement', 'config', [], { tout: true })}
${o.lire('jobExistant', 'Job existant enrichissement', 'jobs', [['request_id', o.ex("{{ $('Empreinte enrichissement').first().json.requestId }}")]])}
${o.lire('quotaEnrich', 'Quota enrichissement', 'quotas', [['mois', o.ex(o.MOIS)]])}
${o.code('controles', 'Contrôles enrichissement', 'controle_enrichissement', "{ decision: 'refus', http: 401, reponse: {} }")}
${o.si('siNouveau', 'Nouveau job ?', "{{ $json.decision === 'nouveau' }}")}
${o.ecrire('creerJob', 'Créer le job', 'jobs', 'insert', Object.fromEntries(
    ['job_id', 'request_id', 'type', 'statut', 'etape', 'fiche_id', 'installation', 'requete', 'resultat', 'erreur', 'version_flux']
      .map((k) => [k, o.ex(`{{ ${CTL}.job.${k} }}`)])))}
${o.code('charge', 'Charge du sous-flux', 'charge', "{ job_id: 'x' }")}
const lancer = node({
  type: 'n8n-nodes-base.executeWorkflow', version: 1.4,
  config: { name: 'Lancer l\\'enrichissement', executeOnce: true,
    parameters: { mode: 'once', source: 'database',
      workflowId: { __rl: true, mode: 'id', value: ${o.q(SOUS_FLUX_ENRICHISSEMENT)}, cachedResultName: 'IA_CAVE_Enrichissement' },
      options: { waitForSubWorkflow: false } } }
});
${o.repondre('repondreCree', 'Répondre job créé', `{{ ${CTL}.reponse }}`, `{{ ${CTL}.http }}`)}
${o.repondre('repondreEnrich', 'Répondre enrichissement', '{{ $json.reponse }}', '{{ $json.http }}')}

${o.webhook('webhookSuivi', 'Webhook suivi', 'GET', 'iacave/jobs', false)}
${o.lire('configSuivi', 'Config suivi', 'config', [], { tout: true })}
${o.lire('jobSuivi', 'Job suivi', 'jobs', [['job_id', o.ex("{{ $('Webhook suivi').first().json.query.job_id || 'aucun' }}")]])}
${o.lire('quotaSuivi', 'Quota suivi', 'quotas', [['mois', o.ex(o.MOIS)]])}
${o.code('suivi', 'Suivi du job', 'suivi', "{ http: 200, reponse: {} }")}
${o.repondre('repondreSuivi', 'Répondre suivi', '{{ $json.reponse }}', '{{ $json.http }}')}

const note = sticky('## IA_CAVE_Agent\\nPoints d\\'entrée de l\\'app IA cave à vin (docs/06-agent-n8n.md) : santé, enrichissement, suivi des jobs. Code des nœuds : n8n/code/ du dépôt iacaveavin, assemblé par n8n/code/assembler.js. Ne pas modifier à la main.', [configSante, sante, repondreSante], { color: 5 });

export default workflow('ia-cave-agent', 'IA_CAVE_Agent')
  .add(webhookSante)
  .to(configSante)
  .to(sante)
  .to(repondreSante)
  .add(webhookEnrich)
  .to(empreinte)
  .to(configEnrich)
  .to(jobExistant)
  .to(quotaEnrich)
  .to(controles)
  .to(siNouveau
    .onTrue(creerJob.to(charge).to(lancer).to(repondreCree))
    .onFalse(repondreEnrich))
  .add(webhookSuivi)
  .to(configSuivi)
  .to(jobSuivi)
  .to(quotaSuivi)
  .to(suivi)
  .to(repondreSuivi)
  .add(note);
`;
};
