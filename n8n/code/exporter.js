#!/usr/bin/env node
// Export versionné des flux IA_CAVE_* (règle .claude/rules/n8n.md) : garde
// nom, nœuds, connexions et réglages d'un flux téléchargé (export n8n ou
// réponse de get_workflow_details), refuse tout ce qui ressemble à un secret.
// Usage : node n8n/code/exporter.js <flux.json>...  → n8n/workflow/<nom>.json
const fs = require('fs');
const path = require('path');

const SECRETS = [
  /tvly-[A-Za-z0-9_-]{10,}/, // clé Tavily
  /sk-ant-[A-Za-z0-9_-]{10,}/, // clé Anthropic
  /"api_key"\s*:\s*"[^"{]/, // clé en clair dans un corps de requête
  /dev-[A-Za-z0-9_-]{20,}/, // clé de développement du flux
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
];

let erreur = false;
for (const fichier of process.argv.slice(2)) {
  const brut = JSON.parse(fs.readFileSync(fichier, 'utf8'));
  const w = brut.workflow || brut;
  const flux = {
    name: w.name,
    nodes: w.nodes,
    connections: w.connections,
    settings: w.settings,
    meta: { source: 'dépôt iacaveavin, n8n/workflow/src/ et n8n/code/', idN8n: w.id, versionId: w.versionId },
  };
  const texte = JSON.stringify(flux, null, 2) + '\n';
  const trouve = SECRETS.find((r) => r.test(texte));
  if (trouve) {
    console.error(`REFUS ${w.name} : motif de secret ${trouve}`);
    erreur = true;
    continue;
  }
  const sortie = path.join(__dirname, '../workflow', w.name + '.json');
  fs.writeFileSync(sortie, texte);
  console.log('exporté', sortie, texte.length, 'octets');
}
process.exit(erreur ? 1 : 0);
