// Sous-flux d'enrichissement (docs/06, étapes 1 à 11), lancé sans attente
// par IA_CAVE_Agent après la création du job. Étape 9 (prix) : IA_CAVE_Prix
// en mode interne, avec attente.
module.exports = (o) => {
  const TROUVE = "$('Déclencheur enrichissement').first().json";
  const CLOT = "$('Clôture').first().json";
  const cfg = (cle) => `($('Config enrichissement').all().find(i => i.json.cle === '${cle}') || { json: {} }).json.valeur || ''`;
  return `import { workflow, node, trigger, ifElse, languageModel, tool, sticky, expr } from '@n8n/workflow-sdk';

const declencheur = trigger({
  type: 'n8n-nodes-base.executeWorkflowTrigger', version: 1.3,
  config: { name: 'Déclencheur enrichissement', parameters: { inputSource: 'passthrough' } },
  output: [{ job_id: 'id', type: 'enrichissement', requete: { request_id: 'id', photos: [] }, recu_le: 0 }]
});

${o.ecrire('jobEnCours', 'Job en cours', 'jobs', 'update',
    { statut: "'en_cours'", etape: "'lecture_etiquette'", execution_id: o.ex('{{ $execution.id }}') },
    [['job_id', o.ex(`{{ ${TROUVE}.job_id }}`)]])}

${o.lire('config', 'Config enrichissement', 'config', [], { tout: true })}

${o.code('photos', 'Photos en binaire', 'photos', "{ noms: 'photo_0', types: 'photo 0 (etiquette)' }")}

const vision = node({
  type: '@n8n/n8n-nodes-langchain.anthropic', version: 1,
  config: { name: 'Lecture vision', executeOnce: true,
    parameters: { resource: 'image', operation: 'analyze',
      modelId: { __rl: true, mode: 'id', value: ${o.q(o.MODELE)} },
      text: ${o.q(o.prompt('n8n/prompt-lecture-etiquette.md'))},
      inputType: 'binary', binaryPropertyName: ${o.ex('{{ $json.noms }}')},
      simplify: true, options: { maxTokens: 4000 } },
    credentials: ${o.IDENTIFIANTS.anthropic} },
  output: [{ content: '{}' }]
});

${o.code('lecture', 'Lecture étiquette', 'lecture', "{ cle: 'aucune-cle', avec_cle: false, lecture: {}, transcription: [] }")}

${o.lire('cacheVin', 'Cache vin', 'cache_vins', [['cle', o.ex('{{ $json.cle }}')]])}

${o.code('decision', 'Décision cache', 'decision_cache', "{ cache: false }")}

// PRV-R4 : une ligne par signalement, en parallèle du chemin principal.
${o.code('signalements', 'Signalements', 'signalements', "{ job_id: 'x', champ: 'cepages', valeur: 'x', date_signalement: '2026-10-27' }")}

${o.ecrire('signalementsEcrire', 'Enregistrer les signalements', 'signalements', 'insert', {
    job_id: o.ex('{{ $json.job_id }}'), champ: o.ex('{{ $json.champ }}'),
    valeur: o.ex('{{ $json.valeur }}'), date_signalement: o.ex('{{ $json.date_signalement }}'),
  }, null, { uneFois: false })}

${o.si('siCache', 'Cache valide ?', '{{ $json.cache }}')}

${o.code('resCache', 'Résultat du cache', 'resultat_cache', "{ ok: true }")}

// T111 : la lecture de l'étiquette part dans le job, l'app l'affiche pendant
// que l'agent cherche.
${o.ecrire('etapeEnrich', 'Étape enrichissement', 'jobs', 'update',
    { etape: "'enrichissement'", resultat: o.ex("{{ $('Lecture étiquette').first().json.partiel }}") },
    [['job_id', o.ex(`{{ ${TROUVE}.job_id }}`)]])}

${o.code('preparer', 'Préparation agent', 'preparer_agent', "{ systeme: 'x', message: 'x' }")}

const claudeCorrection = languageModel({
  type: '@n8n/n8n-nodes-langchain.lmChatAnthropic', version: 1.6,
  config: { name: 'Claude correction',
    parameters: { model: { __rl: true, mode: 'list', value: ${o.q(o.MODELE)}, cachedResultName: 'Claude Sonnet 5' },
      options: { maxTokensToSample: 8000, promptCaching: '5m' } },
    credentials: ${o.IDENTIFIANTS.anthropic} }
});

// Recherche web intégrée de Claude (T85) : un seul appel, au plus 4
// recherches, sortie brute (simplify: false) pour lire les URL vues et le
// nombre de recherches.
const agent = node({
  type: '@n8n/n8n-nodes-langchain.anthropic', version: 1,
  config: { name: 'Agent enrichissement', executeOnce: true,
    parameters: { resource: 'text', operation: 'message',
      modelId: { __rl: true, mode: 'id', value: ${o.q(o.MODELE_AGENT)} },
      messages: { values: [{ role: 'user', content: ${o.ex('{{ $json.message }}')} }] },
      simplify: false,
      options: { system: ${o.ex("{{ $('Préparation agent').first().json.systeme }}")}, webSearch: true, maxUses: 4, maxTokens: 8000 } },
    credentials: ${o.IDENTIFIANTS.anthropic} },
  output: [{ content: [] }]
});

${o.code('controles', 'Contrôles de sortie', 'controles_agent', "{ ok: true, erreurs: [] }")}

${o.si('siOk', 'Sortie conforme ?', '{{ $json.ok }}')}

${o.code('prepCorr', 'Préparation correction', 'preparer_correction', "{ systeme: 'x', message: 'x' }")}

const agentCorr = node({
  type: '@n8n/n8n-nodes-langchain.agent', version: 3.1,
  config: { name: 'Agent correction', executeOnce: true,
    parameters: { promptType: 'define', text: ${o.ex('{{ $json.message }}')},
      options: { systemMessage: ${o.ex('{{ $json.systeme }}')}, maxIterations: 2, returnIntermediateSteps: true, passthroughBinaryImages: false, enableStreaming: false } },
    subnodes: { model: claudeCorrection } },
  output: [{ output: '{}' }]
});

${o.code('controlesCorr', 'Contrôles après correction', 'controles_correction', "{ ok: true, erreurs: [] }")}

${o.si('siOk2', 'Correction conforme ?', '{{ $json.ok }}')}

${o.code('echec', 'Échec des contrôles', 'echec', "{ job_id: 'x', erreur: '{}' }")}

${o.ecrire('jobErreur', 'Job en erreur', 'jobs', 'update',
    { statut: "'erreur'", erreur: o.ex('{{ $json.erreur }}'), journal: o.ex('{{ $json.journal }}') },
    [['job_id', o.ex('{{ $json.job_id }}')]])}

${o.si('siPrix', 'Prix demandé ?', `{{ ${TROUVE}.requete.inclure_prix !== false }}`)}

${o.code('chargePrix', 'Charge prix', 'charge_prix', "{ mode: 'interne', job_id: 'x', requete: {} }")}

const releve = node({
  type: 'n8n-nodes-base.executeWorkflow', version: 1.4,
  config: { name: 'Relevé de prix', executeOnce: true, onError: 'continueRegularOutput',
    parameters: { mode: 'once', source: 'database',
      workflowId: { __rl: true, mode: 'id', value: 'PeGDu6KX9n4SDml1', cachedResultName: 'IA_CAVE_Prix' },
      options: { waitForSubWorkflow: true } } },
  output: [{ ok: true }]
});

${o.lire('quotaCloture', 'Quota clôture', 'quotas', [['mois', o.ex(o.MOIS)]])}

${o.code('cloture', 'Clôture', 'cloture', "{ job_id: 'x', statut: 'termine', resultat: '{}', quota: {}, ecrire_cache: false, alerte: false }")}

${o.ecrire('jobTermine', 'Job terminé', 'jobs', 'update',
    { statut: o.ex('{{ $json.statut }}'), etape: "'termine'", resultat: o.ex('{{ $json.resultat }}'), journal: o.ex('{{ $json.journal }}') },
    [['job_id', o.ex('{{ $json.job_id }}')]])}

${o.ecrire('quotaEcrire', 'Quota du mois', 'quotas', 'upsert', {
    mois: o.ex(`{{ ${CLOT}.quota.mois }}`),
    enrichissements: o.ex(`{{ ${CLOT}.quota.enrichissements }}`),
    prix: o.ex(`{{ ${CLOT}.quota.prix }}`),
    credits_recherche: o.ex(`{{ ${CLOT}.quota.credits_recherche }}`),
    appels_modele: o.ex(`{{ ${CLOT}.quota.appels_modele }}`),
    alerte_envoyee: o.ex(`{{ ${CLOT}.quota.alerte_envoyee }}`),
  }, [['mois', o.ex(`{{ ${CLOT}.quota.mois }}`)]])}

${o.si('siEcrireCache', 'Écrire le cache ?', `{{ ${CLOT}.ecrire_cache }}`)}

${o.ecrire('cacheEcrire', 'Cache du vin', 'cache_vins', 'upsert', {
    cle: o.ex(`{{ ${CLOT}.cache_ligne.cle }}`),
    resultat: o.ex(`{{ ${CLOT}.cache_ligne.resultat }}`),
    utilisations: o.ex(`{{ ${CLOT}.cache_ligne.utilisations }}`),
    date_maj: o.ex(`{{ ${CLOT}.cache_ligne.date_maj }}`),
  }, [['cle', o.ex(`{{ ${CLOT}.cache_ligne.cle }}`)]])}

${o.si('siAlerte', 'Alerte quota ?', `{{ ${CLOT}.alerte }}`)}

const mailQuota = node({
  type: 'n8n-nodes-base.gmail', version: 2.2,
  config: { name: 'Mail quota', executeOnce: true,
    parameters: { resource: 'message', operation: 'send',
      sendTo: ${o.ex(`{{ ${CLOT}.email || 'apexus.bertrand@gmail.com' }}`)},
      subject: 'IA cave à vin : 80 % du quota mensuel atteint',
      emailType: 'html',
      message: ${o.ex(`<p>{{ ${CLOT}.alerte_message }}</p><p>Les quotas se règlent dans la table iacave_config.</p>`)},
      options: { appendAttribution: false } },
    credentials: ${o.IDENTIFIANTS.gmail} },
  output: [{ id: 'm1' }]
});

const note = sticky('## IA_CAVE_Enrichissement\\nLecture d\\'étiquette, cache, agent, contrôles, clôture (docs/06). Source : n8n/workflow/src/ et n8n/code/ du dépôt iacaveavin.', [jobEnCours, config, photos, vision, lecture], { color: 5 });

export default workflow('ia-cave-enrichissement', 'IA_CAVE_Enrichissement')
  .add(declencheur)
  .to(jobEnCours)
  .to(config)
  .to(photos)
  .to(vision)
  .to(lecture)
  .to(cacheVin)
  .to(decision)
  .to(siCache
    .onTrue(resCache.to(siPrix))
    .onFalse(etapeEnrich.to(preparer).to(agent).to(controles).to(siOk
      .onTrue(siPrix)
      .onFalse(prepCorr.to(agentCorr).to(controlesCorr).to(siOk2
        .onTrue(siPrix)
        .onFalse(echec.to(jobErreur)))))))
  .add(decision)
  .to(signalements)
  .to(signalementsEcrire)
  .add(siPrix
    .onTrue(chargePrix.to(releve).to(quotaCloture))
    .onFalse(quotaCloture))
  .add(quotaCloture)
  .to(cloture)
  .to(jobTermine)
  .to(quotaEcrire)
  .to(siEcrireCache
    .onTrue(cacheEcrire.to(siAlerte.onTrue(mailQuota)))
    .onFalse(siAlerte))
  .add(note);
`;
};
