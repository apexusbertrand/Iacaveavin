// Recherche web intégrée de Claude (nœud Anthropic, option webSearch,
// décision T85) : URL réellement renvoyées par la recherche, coût de l'appel,
// sources consultées refaites à partir de ces URL. Dépend de normalisation.js,
// metier.js et modele.js.
if (typeof require !== 'undefined' && typeof urlsCitees === 'undefined') {
  Object.assign(globalThis, require('./metier.js'), require('./modele.js'));
}

/** Forme comparable d'une URL : hôte sans www, sans fragment ni barre finale. */
function urlComparable(u) {
  try {
    const x = new URL(u);
    return x.hostname.toLowerCase().replace(/^www\./, '') + x.pathname.replace(/\/+$/, '') + x.search;
  } catch (e) {
    return null;
  }
}

/** URL des résultats de recherche renvoyés pendant l'appel au modèle. */
function urlsVues(message) {
  const urls = [];
  for (const b of (message && Array.isArray(message.content) && message.content) || []) {
    if (!b || !/_tool_result$/.test(b.type || '')) continue;
    const contenu = Array.isArray(b.content) ? b.content : [b.content];
    for (const r of contenu) if (r && typeof r.url === 'string' && !urls.includes(r.url)) urls.push(r.url);
  }
  return urls;
}

/** Coût d'un appel avec recherche intégrée : un appel, une unité par recherche. */
function coutRecherche(message) {
  const u = (message && message.usage && message.usage.server_tool_use) || {};
  return { appels_modele: 1, credits_recherche: (u.web_search_requests || 0) + (u.web_fetch_requests || 0) };
}

/**
 * sources_consultees refaite à partir des résultats de recherche : seules les
 * URL vues restent, et chaque URL citée et vue y figure. Une URL citée sans
 * avoir été vue reste absente : les contrôles de sortie la refusent.
 * Renvoie le texte JSON corrigé, ou le texte d'origine s'il est illisible.
 */
function completerSources(texte, vues, jour) {
  let r;
  try {
    r = jsonDe(texte);
  } catch (e) {
    return texte;
  }
  if (r && r.resultat && !r.fiche) r = r.resultat;
  const vu = new Set(vues.map(urlComparable).filter(Boolean));
  const citees = urlsCitees(r);
  const garder = [];
  const ajouter = (u) => {
    if (typeof u === 'string' && vu.has(urlComparable(u)) && !garder.includes(u)) garder.push(u);
  };
  for (const s of Array.isArray(r.sources_consultees) ? r.sources_consultees : []) ajouter(s && s.url);
  citees.forEach(ajouter);
  r.sources_consultees = garder.map((url) => ({ url, consultee_le: jour, utilisee: citees.includes(url) }));
  return JSON.stringify(r);
}

if (typeof module !== 'undefined') {
  module.exports = { urlComparable, urlsVues, coutRecherche, completerSources };
}
