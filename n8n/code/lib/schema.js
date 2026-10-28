// Validateur JSON Schema 2020-12 réduit aux mots-clés du contrat
// (specs/contrat-n8n/). Les nœuds Code de n8n n'acceptent pas de module
// externe : ce fichier est recopié tel quel dans le nœud par
// n8n/code/assembler.js. Vérifié contre jsonschema (Python) par
// n8n/code/test/schema.test.js.

const FORMATS = {
  uuid: (s) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(s),
  date: (s) => {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
    if (!m) return false;
    const d = new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
    return d.getUTCFullYear() === +m[1] && d.getUTCMonth() === +m[2] - 1 && d.getUTCDate() === +m[3];
  },
  'date-time': (s) => /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$/i.test(s) && !isNaN(Date.parse(s)),
  uri: (s) => /^[a-z][a-z0-9+.-]*:[^\s]*$/i.test(s),
};

function typeOf(v) {
  if (v === null) return 'null';
  if (Array.isArray(v)) return 'array';
  if (typeof v === 'number') return Number.isInteger(v) ? 'integer' : 'number';
  return typeof v;
}

function typeMatches(v, t) {
  const actual = typeOf(v);
  return actual === t || (t === 'number' && actual === 'integer');
}

function deepEqual(a, b) {
  if (a === b) return true;
  if (typeOf(a) !== typeOf(b) && !(typeof a === 'number' && typeof b === 'number')) return false;
  if (Array.isArray(a)) return a.length === b.length && a.every((x, i) => deepEqual(x, b[i]));
  if (a && typeof a === 'object') {
    const ka = Object.keys(a);
    const kb = Object.keys(b);
    return ka.length === kb.length && ka.every((k) => Object.prototype.hasOwnProperty.call(b, k) && deepEqual(a[k], b[k]));
  }
  return false;
}

function resolveRef(root, ref) {
  if (!ref.startsWith('#')) throw new Error('référence externe non prise en charge : ' + ref);
  let node = root;
  for (const part of ref.slice(1).split('/').filter(Boolean)) {
    node = node[part.replace(/~1/g, '/').replace(/~0/g, '~')];
    if (node === undefined) throw new Error('référence introuvable : ' + ref);
  }
  return node;
}

// Renvoie { errors: [chemins et messages], evaluated: Set des propriétés
// évaluées à cet endroit } (nécessaire à unevaluatedProperties).
function check(schema, data, root, path) {
  const errors = [];
  const evaluated = new Set();
  if (schema === true) return { errors, evaluated };
  if (schema === false) return { errors: [path + ' : interdit'], evaluated };
  const err = (m) => errors.push((path || '/') + ' : ' + m);
  const sub = (s, d, p) => check(s, d, root, p);
  const t = typeOf(data);

  if (schema.$ref) {
    const r = sub(resolveRef(root, schema.$ref), data, path);
    errors.push(...r.errors);
    r.evaluated.forEach((k) => evaluated.add(k));
  }
  if (schema.type !== undefined) {
    const types = Array.isArray(schema.type) ? schema.type : [schema.type];
    if (!types.some((x) => typeMatches(data, x))) err('type ' + t + ' au lieu de ' + types.join('|'));
  }
  if (schema.enum && !schema.enum.some((e) => deepEqual(e, data))) err('valeur hors liste : ' + JSON.stringify(data));
  if ('const' in schema && !deepEqual(schema.const, data)) err('valeur attendue : ' + JSON.stringify(schema.const));

  if (t === 'string') {
    const len = [...data].length;
    if (schema.minLength !== undefined && len < schema.minLength) err('moins de ' + schema.minLength + ' caractères');
    if (schema.maxLength !== undefined && len > schema.maxLength) err('plus de ' + schema.maxLength + ' caractères');
    if (schema.pattern && !new RegExp(schema.pattern, 'u').test(data)) err('motif non respecté : ' + schema.pattern);
    if (schema.format && FORMATS[schema.format] && !FORMATS[schema.format](data)) err('format ' + schema.format + ' invalide');
  }
  if (typeof data === 'number') {
    if (schema.minimum !== undefined && data < schema.minimum) err('inférieur à ' + schema.minimum);
    if (schema.maximum !== undefined && data > schema.maximum) err('supérieur à ' + schema.maximum);
    if (schema.exclusiveMinimum !== undefined && data <= schema.exclusiveMinimum) err('doit dépasser ' + schema.exclusiveMinimum);
    if (schema.exclusiveMaximum !== undefined && data >= schema.exclusiveMaximum) err('doit rester sous ' + schema.exclusiveMaximum);
  }
  if (t === 'array') {
    if (schema.minItems !== undefined && data.length < schema.minItems) err('moins de ' + schema.minItems + ' éléments');
    if (schema.maxItems !== undefined && data.length > schema.maxItems) err('plus de ' + schema.maxItems + ' éléments');
    if (schema.uniqueItems && data.some((x, i) => data.findIndex((y) => deepEqual(x, y)) !== i)) err('éléments en double');
    if (schema.items !== undefined) {
      data.forEach((x, i) => errors.push(...sub(schema.items, x, path + '/' + i).errors));
    }
  }
  if (t === 'object') {
    for (const k of schema.required || []) {
      if (!Object.prototype.hasOwnProperty.call(data, k)) err('propriété obligatoire absente : ' + k);
    }
    const props = schema.properties || {};
    for (const k of Object.keys(data)) {
      if (Object.prototype.hasOwnProperty.call(props, k)) {
        errors.push(...sub(props[k], data[k], path + '/' + k).errors);
        evaluated.add(k);
      }
    }
    if (schema.additionalProperties !== undefined) {
      for (const k of Object.keys(data)) {
        if (Object.prototype.hasOwnProperty.call(props, k)) continue;
        if (schema.additionalProperties === false) err('propriété inconnue : ' + k);
        else errors.push(...sub(schema.additionalProperties, data[k], path + '/' + k).errors);
        evaluated.add(k);
      }
    }
  }

  const keep = (r) => r.evaluated.forEach((k) => evaluated.add(k));
  if (schema.allOf) {
    for (const s of schema.allOf) {
      const r = sub(s, data, path);
      errors.push(...r.errors);
      if (!r.errors.length) keep(r);
    }
  }
  if (schema.anyOf) {
    const rs = schema.anyOf.map((s) => sub(s, data, path));
    const ok = rs.filter((r) => !r.errors.length);
    if (!ok.length) err('aucune des variantes ne convient (' + rs.map((r) => r.errors[0]).join(' ; ') + ')');
    ok.forEach(keep);
  }
  if (schema.oneOf) {
    const rs = schema.oneOf.map((s) => sub(s, data, path));
    const ok = rs.filter((r) => !r.errors.length);
    if (ok.length !== 1) err(ok.length ? 'plusieurs variantes conviennent' : 'aucune des variantes ne convient');
    else keep(ok[0]);
  }
  if (schema.not !== undefined && !sub(schema.not, data, path).errors.length) err('forme interdite');
  if (schema.if !== undefined) {
    const cond = sub(schema.if, data, path);
    const branch = cond.errors.length ? schema.else : schema.then;
    if (!cond.errors.length) keep(cond);
    if (branch !== undefined) {
      const r = sub(branch, data, path);
      errors.push(...r.errors);
      if (!r.errors.length) keep(r);
    }
  }
  if (t === 'object' && schema.unevaluatedProperties !== undefined) {
    for (const k of Object.keys(data)) {
      if (evaluated.has(k)) continue;
      if (schema.unevaluatedProperties === false) err('propriété inconnue : ' + k);
      else errors.push(...sub(schema.unevaluatedProperties, data[k], path + '/' + k).errors);
      evaluated.add(k);
    }
  }
  return { errors, evaluated };
}

/** Liste des erreurs de [data] contre [schema] (vide si conforme). */
function validateSchema(schema, data, root) {
  return check(schema, data, root || schema, '').errors;
}

if (typeof module !== 'undefined') module.exports = { validateSchema };
