import { workflow, node, trigger, sticky, expr } from '@n8n/workflow-sdk';

const webhookSante = trigger({
  type: 'n8n-nodes-base.webhook',
  version: 2.2,
  config: {
    name: 'Webhook santé',
    parameters: { httpMethod: 'GET', path: 'iacave/sante', responseMode: 'responseNode', options: {} }
  },
  output: [{ headers: {}, params: {}, query: {}, body: {} }]
});

const configSante = node({
  type: 'n8n-nodes-base.dataTable',
  version: 1.1,
  config: {
    name: 'Config santé',
    alwaysOutputData: true,
    parameters: {
      resource: 'row',
      operation: 'get',
      dataTableId: { __rl: true, mode: 'id', value: 'wZNVTkGzqgeu2smf', cachedResultName: 'iacave_config' },
      returnAll: true
    }
  },
  output: [{ cle: 'cle_app', valeur: '' }]
});

const sante = node({
  type: 'n8n-nodes-base.code',
  version: 2,
  config: {
    name: 'Santé du flux',
    executeOnce: true,
    parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: CODE('sante') }
  },
  output: [{ version_flux: '__VERSION_FLUX__', version_contrat: '1.0', ok: true }]
});

const repondreSante = node({
  type: 'n8n-nodes-base.respondToWebhook',
  version: 1.5,
  config: {
    name: 'Répondre santé',
    parameters: { respondWith: 'firstIncomingItem', options: { responseCode: 200 } }
  }
});

const note = sticky('## IA_CAVE_Agent\nFlux de l\'app IA cave à vin (docs/06-agent-n8n.md). Code des nœuds : n8n/code/ du dépôt, assemblé par n8n/code/assembler.js. Ne pas modifier à la main : réimporter depuis le dépôt.', [webhookSante, configSante, sante, repondreSante], { color: 5 });

export default workflow('ia-cave-agent', 'IA_CAVE_Agent')
  .add(webhookSante)
  .to(configSante)
  .to(sante)
  .to(repondreSante)
  .add(note);
