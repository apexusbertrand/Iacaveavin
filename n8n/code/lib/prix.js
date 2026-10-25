// Relevé de prix (docs/06, étapes de l'agent prix) : clé de cache, décision
// avant l'agent, lecture de sa sortie. Une offre n'est retenue que si sa page
// a réellement été lue par l'outil lire_page pendant ce job : l'agent ne peut
// pas citer un prix qu'il n'a pas vu. Dépend de normalisation.js, metier.js,
// modele.js et schema.js.
if (typeof require !== 'undefined' && typeof agregerPrix === 'undefined') {
  Object.assign(globalThis, require('./metier.js'), require('./modele.js'), require('./schema.js'));
}

const CACHE_PRIX_MS = 24 * 3600 * 1000;

/** Clé du cache de prix : vin, format et devise. */
function clePrix(identite, formatCl, devise) {
  const vin = cleVin(identite || {});
  return vin ? vin + '|' + formatCl + '|' + devise : null;
}

/** Résultat « aucun prix » au contrat, avec son motif. */
function prixNonTrouve(motif, { formatCl, devise, jour }) {
  return {
    prix: [{ format_cl: formatCl, trouve: false, prix: null, devise, date: jour, motif }],
    alertes: [{ code: 'prix_non_trouve', message: motif.slice(0, 300) }],
    sources_consultees: [],
  };
}

/**
 * Avant l'agent : cache de 24 heures (sauf forcer), puis conditions minimales
 * (clé Tavily, au moins un site marchand actif). Sans elles, aucun appel au
 * modèle : le résultat est « non trouvé » avec le motif.
 */
function decisionPrix({ requete, config, ligneCache, maintenant, domainesMarchands }) {
  const jour = jourParis(new Date(maintenant));
  const base = { formatCl: requete.format_cl, devise: requete.devise, jour };
  const cle = clePrix(requete.identite, requete.format_cl, requete.devise);
  if (cle && ligneCache && !requete.forcer) {
    const age = maintenant - Date.parse(ligneCache.date_maj || ligneCache.updatedAt || 0);
    if (age < CACHE_PRIX_MS) {
      try {
        return { agent: false, cle, cache: true, date_cache: String(ligneCache.date_maj).slice(0, 10), resultat: JSON.parse(ligneCache.resultat), jour };
      } catch (e) {
        // Ligne de cache illisible : on refait le relevé.
      }
    }
  }
  if (!domainesMarchands.length) {
    return { agent: false, cle, cache: false, resultat: prixNonTrouve('Aucun site marchand vérifié n\'est encore actif.', base), jour };
  }
  if (!config.tavily_cle) {
    return { agent: false, cle, cache: false, resultat: prixNonTrouve('Recherche web non configurée.', base), jour };
  }
  return { agent: true, cle, cache: false, resultat: null, jour };
}

/** Message système et message utilisateur de l'agent prix. */
function messagesPrix({ prompt, requete, jour, domainesMarchands }) {
  const systeme = prompt
    .replace("{{ $now.setZone('Europe/Paris').toFormat('yyyy-MM-dd') }}", jour)
    .replace('{{ JSON.stringify($json.identite) }}', JSON.stringify(requete.identite))
    .replace('{{ $json.format_cl }}', String(requete.format_cl))
    .replace('{{ $json.devise }}', requete.devise)
    .replace('{{ JSON.stringify($json.domaines_marchands) }}', JSON.stringify(domainesMarchands))
    + '\n\nOutils : `recherche_web` (déjà limitée aux sites autorisés) et `lire_page` (texte d\'une page produit).'
    + ' Seules les pages lues avec `lire_page` comptent : une offre dont la page n\'a pas été lue est écartée par le flux.'
    + '\nFormat de sortie : {"offres": [{"site", "url", "prix", "millesime_verifie"}], "alertes": [{"code", "message"}]}.'
    + ' Le flux calcule lui-même la médiane, le format du contrat et les sources consultées.';
  const message = 'Relève le prix de ce vin : ' + JSON.stringify(requete.identite)
    + ', format ' + requete.format_cl + ' cl, devise ' + requete.devise + '. Renvoie uniquement l\'objet JSON.';
  return { systeme, message };
}

/** URL lues par l'outil lire_page, tirées des étapes intermédiaires de l'agent. */
function pagesLues(sortie) {
  const urls = [];
  for (const e of (sortie && sortie.intermediateSteps) || []) {
    const a = (e && e.action) || {};
    if (!/lire|extract/i.test(a.tool || '')) continue;
    const entree = a.toolInput;
    const brut = entree && typeof entree === 'object' ? entree.url || JSON.stringify(entree) : String(entree || '');
    const m = /https?:\/\/[^\s"'<>]+/.exec(brut);
    if (m && !urls.includes(m[0])) urls.push(m[0]);
  }
  return urls;
}

const CODES_ALERTE = ['prix_non_trouve', 'contenu_suspect_ignore', 'identification_incertaine', 'autre'];

/**
 * Sortie de l'agent prix → { ok, erreurs, resultat, cout, ecartees }. Le
 * résultat suit $defs.resultat_prix ; la médiane et les écarts sont calculés
 * ici (agregerPrix), pas par le modèle.
 */
function analyserSortiePrix(sortie, { requete, jour, domainesMarchands, schemaReponse, dejaLues = [] }) {
  const cout = coutAgent(sortie);
  let brut;
  try {
    brut = jsonDe(texteDe(sortie));
  } catch (e) {
    return { ok: false, erreurs: ['sortie non JSON : ' + e.message], resultat: null, cout };
  }
  if (brut && brut.resultat) brut = brut.resultat;
  let offres = brut.offres;
  if (!Array.isArray(offres) && Array.isArray(brut.prix) && brut.prix[0]) offres = brut.prix[0].offres;
  if (!Array.isArray(offres)) offres = [];
  // L'agent de correction n'a pas d'outil : il reprend les pages du premier passage.
  const lues = [...new Set([...dejaLues, ...pagesLues(sortie)])];
  const ecartees = [];
  const valides = [];
  for (const o of offres) {
    const prix = typeof (o && o.prix) === 'string' ? parseFloat(o.prix.replace(',', '.')) : o && o.prix;
    const offre = { ...o, prix };
    if (!o || typeof o.url !== 'string' || !lues.includes(o.url)) ecartees.push({ url: o && o.url, motif: 'page non lue' });
    else if (!domaineAutorise(o.url, domainesMarchands)) ecartees.push({ url: o.url, motif: 'site non autorisé' });
    else if (o.millesime_verifie !== true) ecartees.push({ url: o.url, motif: 'millésime non vérifié' });
    else if (!(prix > 0)) ecartees.push({ url: o.url, motif: 'prix illisible' });
    else valides.push(offre);
  }
  const p = agregerPrix(valides, { formatCl: requete.format_cl, devise: requete.devise, date: jour, domainesMarchands });
  if (p.trouve === false) delete p.nature;
  const alertes = (Array.isArray(brut.alertes) ? brut.alertes : [])
    .filter((x) => x && CODES_ALERTE.includes(x.code) && typeof x.message === 'string' && x.message.length >= 3)
    .map((x) => ({ code: x.code, message: x.message.slice(0, 300) }));
  if (!p.trouve && !alertes.some((x) => x.code === 'prix_non_trouve')) {
    alertes.push({ code: 'prix_non_trouve', message: 'Aucune offre fiable du même millésime et du même format.' });
  }
  const retenues = new Set((p.offres || []).map((o) => o.url));
  const resultat = {
    prix: [p],
    alertes,
    sources_consultees: lues.map((url) => ({ url, consultee_le: jour, utilisee: retenues.has(url) })),
  };
  const erreurs = validateSchema(schemaReponse.$defs.resultat_prix, resultat, schemaReponse);
  return { ok: erreurs.length === 0, erreurs, resultat, cout, ecartees };
}

if (typeof module !== 'undefined') {
  module.exports = {
    ...require('./metier.js'), ...require('./modele.js'), ...require('./schema.js'),
    CACHE_PRIX_MS, clePrix, prixNonTrouve, decisionPrix, messagesPrix, pagesLues, analyserSortiePrix,
  };
}
