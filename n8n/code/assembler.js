#!/usr/bin/env node
// Assemble le code des nœuds Code et le source SDK des flux n8n.
//
// - n8n/code/noeuds/<nom>.js : script d'un nœud Code. Une ligne
//   « // @inclure <fichier> » est remplacée par n8n/code/lib/<fichier> ;
//   __VERSION_FLUX__, __SCHEMA_REPONSE__, __SCHEMA_ENRICHISSEMENT__,
//   __SCHEMA_PRIX__, __SCHEMA_REMONTEE__, __SCHEMA_REPONSE_REMONTEE__, __VECTEUR__, __SOURCES__ et __ACCORDS__ par leurs valeurs.
// - n8n/workflow/src/<flux>.sdk.js : source SDK du flux ; CODE('<nom>') y
//   est remplacé par le script assemblé du nœud, en chaîne JSON.
//
// Usage : node n8n/code/assembler.js <flux>   → écrit n8n/code/dist/<flux>.sdk.js
const fs = require('fs');
const path = require('path');

const ici = __dirname;
const racine = path.resolve(ici, '../..');
const VERSION_FLUX = '0.4.0';

const lire = (p) => fs.readFileSync(path.join(racine, p), 'utf8');

// Schémas sans description ni titre : mêmes règles, moitié moins de texte.
function epure(v) {
  if (Array.isArray(v)) return v.map(epure);
  if (v && typeof v === 'object') {
    const o = {};
    for (const [k, x] of Object.entries(v)) if (!['description', 'title', '$id', '$schema'].includes(k)) o[k] = epure(x);
    return o;
  }
  return v;
}
const json = (p) => JSON.stringify(epure(JSON.parse(lire(p))));

// Bibliothèque recopiée sans commentaires ni lignes vides ; le dépôt garde
// la version commentée.
function sansCommentaires(code) {
  return code
    .replace(/^if \(typeof (module|require) !== 'undefined'[^\n]*\{\n[\s\S]*?\n\}$/gm, '')
    .replace(/^if \(typeof (module|require) !== 'undefined'.*$/gm, '')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .split('\n')
    .filter((l) => !/^\s*\/\//.test(l) && l.trim())
    .join('\n');
}

/** Texte du prompt système : ce qui suit la ligne « --- » du fichier. */
function prompt(fichier) {
  const t = lire('n8n/' + fichier);
  return t.slice(t.indexOf('\n---\n') + 5).trim();
}

/** Domaines actifs de sources-autorisees.yaml, par rubrique. */
function sources() {
  const out = {};
  let rubrique = null;
  for (const ligne of lire('n8n/sources-autorisees.yaml').split('\n')) {
    const r = /^([a-z_]+):\s*$/.exec(ligne);
    if (r) { rubrique = r[1]; out[rubrique] = out[rubrique] || []; continue; }
    const d = /^\s*-\s*\{domaine:\s*([^,}\s]+).*statut:\s*([a-z_]+)/.exec(ligne);
    if (d && rubrique && d[2] === 'actif') out[rubrique].push(d[1]);
  }
  return out;
}

/** Libellés de la liste accord_mets de l'application (règle 15 du prompt). */
function accords() {
  return JSON.parse(lire('app/assets/referentiels/accords-mets.json')).valeurs
    .filter((v) => v.actif !== false)
    .map((v) => v.libelle);
}

function noeud(nom) {
  let s = fs.readFileSync(path.join(ici, 'noeuds', nom + '.js'), 'utf8');
  s = s.replace(/^\/\/ @inclure (\S+)$/gm, (_, f) => sansCommentaires(fs.readFileSync(path.join(ici, 'lib', f), 'utf8')));
  return s
    .replace(/__VERSION_FLUX__/g, VERSION_FLUX)
    .replace(/__SCHEMA_REPONSE__/g, () => json('specs/contrat-n8n/reponse-job.schema.json'))
    .replace(/__SCHEMA_ENRICHISSEMENT__/g, () => json('specs/contrat-n8n/requete-enrichissement.schema.json'))
    .replace(/__SCHEMA_PRIX__/g, () => json('specs/contrat-n8n/requete-prix.schema.json'))
    .replace(/__SCHEMA_REMONTEE__/g, () => json('specs/contrat-n8n/requete-remontee.schema.json'))
    .replace(/__SCHEMA_REPONSE_REMONTEE__/g, () => json('specs/contrat-n8n/reponse-remontee.schema.json'))
    .replace(/__VECTEUR__/g, () => json('specs/contrat-n8n/vecteur-signature.json'))
    .replace(/__PROMPT_ENRICHISSEMENT__/g, () => JSON.stringify(prompt('prompt-agent-enrichissement.md')))
    .replace(/__PROMPT_PRIX__/g, () => JSON.stringify(prompt('prompt-agent-prix.md')))
    .replace(/__SOURCES__/g, () => JSON.stringify(sources()))
    .replace(/__ACCORDS__/g, () => JSON.stringify(accords()));
}

function flux(nom) {
  const gen = path.join(racine, 'n8n/workflow/src', nom + '.gen.js');
  const src = fs.existsSync(gen)
    ? require(gen)(require(path.join(racine, 'n8n/workflow/src/outils.js')))
    : fs.readFileSync(path.join(racine, 'n8n/workflow/src', nom + '.sdk.js'), 'utf8');
  return src
    .replace(/CODE\((['"])([a-z0-9_-]+)\1\)/g, (_, _q, n) => JSON.stringify(noeud(n)))
    .replace(/__VERSION_FLUX__/g, VERSION_FLUX);
}

if (require.main === module) {
  const nom = process.argv[2];
  const out = path.join(ici, 'dist', nom + '.sdk.js');
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, flux(nom));
  console.log(out, fs.statSync(out).size, 'octets');
}

module.exports = { noeud, flux, sources, prompt, VERSION_FLUX };
