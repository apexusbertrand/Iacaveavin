// Flux d'erreur des flux IA_CAVE_* : job concerné passé en erreur, mail
// d'alerte sans photo (docs/06, « Où et comment »).
module.exports = (o) => `import { workflow, node, trigger, ifElse, sticky, expr } from '@n8n/workflow-sdk';

const declencheur = trigger({
  type: 'n8n-nodes-base.errorTrigger', version: 1,
  config: { name: 'Erreur dans un flux IA_CAVE' },
  output: [{ execution: { id: '1', error: { message: 'erreur' }, lastNodeExecuted: 'Nœud' }, workflow: { id: 'x', name: 'IA_CAVE_Enrichissement' } }]
});

${o.code('analyser', 'Erreur analysée', 'erreurs', "{ execution_id: '1', erreur: '{}', message: 'erreur' }")}

${o.lire('jobExecution', 'Job concerné', 'jobs', [['execution_id', o.ex('{{ $json.execution_id || "aucune" }}')]])}

${o.si('jobTrouve', 'Job trouvé ?', '{{ !!$json.job_id }}')}

${o.ecrire('jobErreur', 'Passer le job en erreur', 'jobs', 'update',
    { statut: "'erreur'", erreur: o.ex("{{ $('Erreur analysée').first().json.erreur }}"), journal: o.ex("{{ $('Erreur analysée').first().json.message }}") },
    [['job_id', o.ex("{{ $('Job concerné').first().json.job_id }}")]])}

${o.lire('configMail', 'Destinataire', 'config', [['cle', "'email_alerte'"]])}

const mail = node({
  type: 'n8n-nodes-base.gmail', version: 2.2,
  config: { name: "Mail d'alerte", executeOnce: true,
    parameters: { resource: 'message', operation: 'send',
      sendTo: ${o.ex("{{ $json.valeur || 'apexus.bertrand@gmail.com' }}")},
      subject: ${o.ex("IA cave à vin : erreur dans {{ $('Erreur analysée').first().json.flux }}")},
      emailType: 'html',
      message: ${o.ex("<p>Le flux <b>{{ $('Erreur analysée').first().json.flux }}</b> s'est arrêté au nœud <b>{{ $('Erreur analysée').first().json.noeud }}</b>.</p><p>Message : {{ $('Erreur analysée').first().json.message }}</p><p>Job : {{ $('Job concerné').first().json.job_id || 'aucun' }}</p><p><a href=\"{{ $('Erreur analysée').first().json.url }}\">Voir l'exécution</a></p>")},
      options: { appendAttribution: false } },
    credentials: ${o.IDENTIFIANTS.gmail} },
  output: [{ id: 'm1' }]
});

const note = sticky('## IA_CAVE_Erreurs\\nFlux d\\'erreur de IA_CAVE_Agent et de ses sous-flux. Source : n8n/workflow/src/ du dépôt iacaveavin.', [analyser, jobExecution, jobTrouve, jobErreur, configMail, mail], { color: 3 });

export default workflow('ia-cave-erreurs', 'IA_CAVE_Erreurs')
  .add(declencheur)
  .to(analyser)
  .to(jobExecution)
  .to(jobTrouve
    .onTrue(jobErreur.to(configMail))
    .onFalse(configMail))
  .add(configMail)
  .to(mail)
  .add(note);
`;
