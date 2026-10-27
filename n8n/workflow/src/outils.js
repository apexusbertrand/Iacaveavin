// Générateurs de nœuds pour le source SDK des flux IA_CAVE_* (le SDK
// n'accepte ni fonction ni boucle : on produit ici son texte).

const TABLES = {
  config: ['wZNVTkGzqgeu2smf', 'iacave_config'],
  jobs: ['HD54X4WojTN5H2fX', 'iacave_jobs'],
  cache_vins: ['AVjh9z57rSyHHW1e', 'iacave_cache_vins'],
  cache_prix: ['nnNm6j6kXtECZxrn', 'iacave_cache_prix'],
  quotas: ['1ip3UBzHPzShXuiU', 'iacave_quotas'],
  signalements: ['HcfygIuRGsBxv9vG', 'iacave_signalements'],
};

const IDENTIFIANTS = {
  // Identifiants propres à l'app, choisis par Bertrand le 2026-10-26.
  anthropic: "{ anthropicApi: { id: 'Nv5Wx8v6RReLoKNy', name: 'Claude AI Cave' } }",
  gmail: "{ gmailOAuth2: { id: 'Lvc7ImPNsOcz6WAu', name: 'Gmail Claude' } }",
};

const MODELE = 'claude-sonnet-5';
// Agent d'enrichissement : Claude Sonnet 4.6, choix de Bertrand du 2026-10-26.
const MODELE_AGENT = 'claude-sonnet-4-6';

const q = (s) => JSON.stringify(s);
const ex = (s) => `expr(${q(s)})`;

function table(cle) {
  const [id, nom] = TABLES[cle];
  return `{ __rl: true, mode: 'id', value: ${q(id)}, cachedResultName: ${q(nom)} }`;
}

function conditions(filtres) {
  return `{ conditions: [${filtres.map(([col, valeur, cond = 'eq']) => `{ keyName: ${q(col)}, condition: ${q(cond)}, keyValue: ${valeur} }`).join(', ')}] }`;
}

function colonnes(valeurs) {
  const v = Object.entries(valeurs).map(([k, x]) => `${q(k)}: ${x}`).join(', ');
  const schema = Object.entries(valeurs).map(([k]) => {
    const type = ['utilisations', 'enrichissements', 'prix', 'credits_recherche', 'appels_modele'].includes(k) ? 'number'
      : k === 'alerte_envoyee' ? 'boolean' : 'string';
    return `{ id: ${q(k)}, displayName: ${q(k)}, required: false, defaultMatch: false, display: true, type: ${q(type)}, canBeUsedToMatch: true }`;
  }).join(', ');
  return `{ mappingMode: 'defineBelow', value: { ${v} }, matchingColumns: [], schema: [${schema}] }`;
}

/** Lecture de lignes. filtres : [[colonne, valeurSDK, condition?]]. */
function lire(variable, nom, cle, filtres, { tout = false, limite = 1 } = {}) {
  const f = filtres && filtres.length ? `, matchType: 'allConditions', filters: ${conditions(filtres)}` : '';
  const l = tout ? 'returnAll: true' : `returnAll: false, limit: ${limite}`;
  return `const ${variable} = node({
  type: 'n8n-nodes-base.dataTable', version: 1.1,
  config: { name: ${q(nom)}, alwaysOutputData: true, executeOnce: true,
    parameters: { resource: 'row', operation: 'get', dataTableId: ${table(cle)}${f}, ${l} } },
  output: [{ id: 1 }]
});`;
}

/** Écriture : insert, update (filtres) ou upsert (filtres). valeurs : {colonne: valeurSDK}. */
function ecrire(variable, nom, cle, operation, valeurs, filtres, { uneFois = true } = {}) {
  const f = filtres ? `, matchType: 'allConditions', filters: ${conditions(filtres)}` : '';
  return `const ${variable} = node({
  type: 'n8n-nodes-base.dataTable', version: 1.1,
  config: { name: ${q(nom)}, executeOnce: ${uneFois},
    parameters: { resource: 'row', operation: ${q(operation)}, dataTableId: ${table(cle)}${f}, columns: ${colonnes(valeurs)} } },
  output: [{ id: 1 }]
});`;
}

/** Nœud Code exécuté une fois, avec le script assemblé [script]. */
function code(variable, nom, script, sortie = '{}') {
  return `const ${variable} = node({
  type: 'n8n-nodes-base.code', version: 2,
  config: { name: ${q(nom)}, executeOnce: true,
    parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: CODE(${q(script)}) } },
  output: [${sortie}]
});`;
}

/** Condition « vrai si l'expression vaut true ». */
function si(variable, nom, expression) {
  return `const ${variable} = ifElse({
  version: 2.3,
  config: { name: ${q(nom)}, parameters: { conditions: {
    options: { caseSensitive: true, leftValue: '', typeValidation: 'loose', version: 2 },
    conditions: [{ leftValue: ${ex(expression)}, rightValue: true, operator: { type: 'boolean', operation: 'true', singleValue: true } }],
    combinator: 'and' } } }
});`;
}

function repondre(variable, nom, corps, http) {
  return `const ${variable} = node({
  type: 'n8n-nodes-base.respondToWebhook', version: 1.5,
  config: { name: ${q(nom)}, parameters: { respondWith: 'json', responseBody: ${ex(corps)},
    options: { responseCode: ${ex(http)} } } }
});`;
}

function webhook(variable, nom, methode, chemin, brut) {
  return `const ${variable} = trigger({
  type: 'n8n-nodes-base.webhook', version: 2.2,
  config: { name: ${q(nom)}, parameters: { httpMethod: ${q(methode)}, path: ${q(chemin)}, responseMode: 'responseNode',
    options: { ${brut ? 'rawBody: true' : ''} } } },
  output: [{ headers: {}, params: {}, query: {}, body: {} }]
});`;
}

/** Texte d'un prompt du dépôt : ce qui suit la ligne « --- ». */
function prompt(fichier) {
  const t = require('fs').readFileSync(require('path').join(__dirname, '../../..', fichier), 'utf8');
  return t.slice(t.indexOf('\n---\n') + 5).trim();
}

const MOIS = "{{ $now.setZone('Europe/Paris').toFormat('yyyy-MM') }}";

module.exports = { prompt, TABLES, IDENTIFIANTS, MODELE, MODELE_AGENT, MOIS, q, ex, table, lire, ecrire, code, si, repondre, webhook };
