// Lecture des sorties des modèles : texte, JSON entouré ou non de balises,
// coût d'un passage d'agent.

/** Premier texte trouvé dans la sortie d'un nœud de modèle. */
function texteDe(sortie) {
  if (typeof sortie === 'string') return sortie;
  if (!sortie || typeof sortie !== 'object') return '';
  for (const k of ['output', 'text', 'content', 'message', 'response']) {
    const v = sortie[k];
    if (typeof v === 'string' && v.trim()) return v;
    if (Array.isArray(v)) {
      const t = v.map((x) => (typeof x === 'string' ? x : (x && x.text) || '')).join('');
      if (t.trim()) return t;
    }
    if (v && typeof v === 'object') {
      const t = texteDe(v);
      if (t) return t;
    }
  }
  return '';
}

/** Objet JSON contenu dans un texte de modèle (balises ```json tolérées). */
function jsonDe(texte) {
  const t = String(texte || '').replace(/```(?:json)?/gi, '');
  const debut = t.indexOf('{');
  const fin = t.lastIndexOf('}');
  if (debut < 0 || fin <= debut) throw new Error('aucun objet JSON dans la réponse du modèle');
  return JSON.parse(t.slice(debut, fin + 1));
}

/** Coût d'un passage d'agent à partir de ses étapes intermédiaires. */
function coutAgent(sortie) {
  const etapes = (sortie && sortie.intermediateSteps) || [];
  const outils = etapes.map((e) => (e && e.action && e.action.tool) || '').filter(Boolean);
  return {
    appels_modele: etapes.length + 1,
    credits_recherche: outils.filter((o) => /recherche|lire|search|extract/i.test(o)).length,
  };
}

if (typeof module !== 'undefined') module.exports = { texteDe, jsonDe, coutAgent };
