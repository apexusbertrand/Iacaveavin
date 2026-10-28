// Pages citées par l'agent et absentes des résultats de recherche de l'appel
// (T108) : la valeur est retirée avec un motif et une alerte, au lieu de
// refuser toute la fiche. Le diagnostic de l'appel (raison d'arrêt, nombre de
// recherches et de résultats vus) part dans l'alerte. Dépend de modele.js et
// recherche.js.
if (typeof require !== 'undefined' && typeof urlsVues === 'undefined') {
  Object.assign(globalThis, require('./modele.js'), require('./recherche.js'));
}

/** URL des résultats de recherche, plus celles des citations du texte. */
function vuesEtCitations(message) {
  const urls = urlsVues(message);
  for (const b of (message && Array.isArray(message.content) && message.content) || []) {
    for (const c of (b && Array.isArray(b.citations) && b.citations) || []) {
      if (c && typeof c.url === 'string' && !urls.includes(c.url)) urls.push(c.url);
    }
  }
  return urls;
}

/** Raison d'arrêt, recherches lancées et résultats vus, en une ligne. */
function diagnosticRecherche(message, vues) {
  const u = (message && message.usage && message.usage.server_tool_use) || {};
  return 'arrêt ' + ((message && message.stop_reason) || '?') + ', ' + (u.web_search_requests || 0)
    + ' recherche(s), ' + vues.length + ' résultat(s) vu(s)';
}

/**
 * Retire les valeurs dont l'URL n'est pas dans sources_consultees (déjà
 * refaite à partir des URL vues). Une valeur lue sur l'étiquette garde sa
 * valeur et perd seulement l'URL. Renvoie le texte JSON corrigé, ou le texte
 * d'origine s'il est illisible.
 */
function retirerNonVues(texte, diagnostic) {
  let r;
  try {
    r = jsonDe(texte);
  } catch (e) {
    return texte;
  }
  if (r && r.resultat && !r.fiche) r = r.resultat;
  const vues = new Set((Array.isArray(r.sources_consultees) ? r.sources_consultees : []).map((s) => s && s.url));
  const retirees = [];
  const fiche = r.fiche && typeof r.fiche === 'object' ? r.fiche : {};
  for (const [champ, v] of Object.entries(fiche)) {
    if (!v || typeof v.url !== 'string' || !v.url || vues.has(v.url)) continue;
    retirees.push(v.url);
    if (v.source === 'etiquette') delete v.url;
    else fiche[champ] = { valeur: null, source: null, confiance: null, motif: 'page citée absente des résultats de recherche' };
  }
  if (Array.isArray(r.notes_critiques)) {
    r.notes_critiques = r.notes_critiques.filter((n) => {
      if (n && vues.has(n.url)) return true;
      if (n && n.url) retirees.push(n.url);
      return false;
    });
  }
  if (retirees.length) {
    r.alertes = [...(Array.isArray(r.alertes) ? r.alertes : []), {
      code: 'autre',
      message: (retirees.length + ' valeur(s) retirée(s) : page citée absente des résultats de recherche ('
        + diagnostic + ').').slice(0, 300),
    }];
  }
  return JSON.stringify(r);
}

if (typeof module !== 'undefined') module.exports = { vuesEtCitations, diagnosticRecherche, retirerNonVues };
