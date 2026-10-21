#!/usr/bin/env node
// Opérations update_workflow qui remplacent en entier les paramètres des
// nœuds Code (règle .claude/rules/n8n.md : jamais d'écriture par chemin).
// Usage : node n8n/code/operations.js "Nom du nœud=script" ...
const a = require('./assembler.js');
const ops = process.argv.slice(2).map((arg) => {
  const [nodeName, script] = arg.split('=');
  return {
    type: 'updateNodeParameters',
    nodeName,
    replace: true,
    parameters: { mode: 'runOnceForAllItems', language: 'javaScript', jsCode: a.noeud(script) },
  };
});
process.stdout.write(JSON.stringify(ops));
