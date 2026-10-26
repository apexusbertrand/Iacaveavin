#!/usr/bin/env node
// Compare les nœuds Code d'un flux exporté de n8n (JSON) avec le code
// assemblé du dépôt. Usage : node n8n/code/comparer.js <export.json>
// Un export n8n ou la réponse de get_workflow_details conviennent. Les
// caractères U+0300 à U+036F écrits en clair ou échappés comptent pour égaux
// (même expression régulière). Le saut de ligne final, que n8n retire, ne
// compte pas.
const fs = require('fs');
const path = require('path');
const a = require('./assembler.js');

const brut = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const flux = brut.workflow || brut;
const lit = (s) => s.replace(/\\u0300-\\u036f/g, '̀-ͯ').replace(/\s+$/, '');

// Nom du nœud → script, lu dans les générateurs : o.code(variable, 'Nom', 'script', ...).
const scripts = {};
const src = path.join(__dirname, '../workflow/src');
for (const f of fs.readdirSync(src).filter((x) => x.endsWith('.gen.js'))) {
  const t = fs.readFileSync(path.join(src, f), 'utf8');
  for (const m of t.matchAll(/o\.code\('[^']+', '([^']+)', '([a-z0-9_]+)'/g)) scripts[m[1]] = m[2];
}

let ecarts = 0;
for (const n of flux.nodes.filter((x) => x.type === 'n8n-nodes-base.code')) {
  const script = scripts[n.name];
  if (!script) {
    console.log('INCONNU ', n.name);
    ecarts++;
    continue;
  }
  const ok = lit(n.parameters.jsCode) === lit(a.noeud(script));
  if (!ok) ecarts++;
  console.log(ok ? 'IDENTIQUE' : 'DIFFÉRENT', n.name, '←', script);
}
process.exit(ecarts ? 1 : 0);
