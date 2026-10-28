// Purge quotidienne des tables iacave_* selon les durées de docs/06
// (stockage côté n8n). Aucune donnée de l'app n'est touchée : seulement les
// jobs, caches, quotas, signalements et journal des remontées du flux.
module.exports = (o) => {
  const purge = (variable, nom, cle, colonne, duree) => `const ${variable} = node({
  type: 'n8n-nodes-base.dataTable', version: 1.1,
  config: { name: ${o.q(nom)}, alwaysOutputData: true, executeOnce: true,
    parameters: { resource: 'row', operation: 'deleteRows', dataTableId: ${o.table(cle)}, matchType: 'allConditions',
      filters: { conditions: [{ keyName: ${o.q(colonne)}, condition: 'lt', keyValue: ${o.ex(`{{ $now.minus(${duree}).toISO() }}`)} }] },
      options: { dryRun: false } } },
  output: [{ id: 1 }]
});`;
  return `import { workflow, node, trigger, sticky, expr } from '@n8n/workflow-sdk';

const chaqueNuit = trigger({
  type: 'n8n-nodes-base.scheduleTrigger', version: 1.4,
  config: { name: 'Chaque nuit', parameters: { rule: { interval: [{ field: 'days', daysInterval: 1, triggerAtHour: 3, triggerAtMinute: 17 }] } } },
  output: [{}]
});

${purge('jobs', 'Jobs de plus de 90 jours', 'jobs', 'createdAt', '{ days: 90 }')}

${purge('cacheVins', 'Cache vins de plus de 180 jours', 'cache_vins', 'updatedAt', '{ days: 180 }')}

${purge('cachePrix', 'Cache prix de plus de 24 heures', 'cache_prix', 'updatedAt', '{ hours: 24 }')}

${purge('quotas', 'Quotas de plus de 24 mois', 'quotas', 'createdAt', '{ months: 24 }')}

${purge('signalements', 'Signalements de plus de 24 mois', 'signalements', 'createdAt', '{ months: 24 }')}

${purge('remontees', 'Remontées de plus de 30 jours', 'remontees', 'createdAt', '{ days: 30 }')}

const note = sticky('## IA_CAVE_Purge\\nDurées de conservation de docs/06 (stockage côté n8n). Source : n8n/workflow/src/ du dépôt iacaveavin.', [jobs, cacheVins, cachePrix, quotas, signalements], { color: 5 });

export default workflow('ia-cave-purge', 'IA_CAVE_Purge')
  .add(chaqueNuit)
  .to(jobs)
  .to(cacheVins)
  .to(cachePrix)
  .to(quotas)
  .to(signalements)
  .to(remontees)
  .add(note);
`;
};
