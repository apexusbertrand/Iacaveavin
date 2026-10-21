// Règles métier du flux, en fonctions pures : clé de cache, prix, contrôles
// de sortie de l'agent (docs/06-agent-n8n.md, étapes 3, 10 et agent prix).

/** Minuscules, sans accents, espaces et ponctuation en tirets. */
function normaliser(texte) {
  return String(texte == null ? '' : texte)
    .replace(/œ/g, 'oe').replace(/Œ/g, 'oe').replace(/æ/g, 'ae').replace(/Æ/g, 'ae').replace(/ß/g, 'ss')
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Clé de cache d'un vin : domaine, appellation, cuvée et millésime
 * normalisés, séparés par « | ». null si domaine ou millésime manque : sans
 * identité sûre, pas de cache.
 */
function cleVin({ domaine, appellation, cuvee, millesime }) {
  if (!domaine || millesime == null || millesime === '') return null;
  return [domaine, appellation, cuvee, millesime].map(normaliser).join('|');
}

function hote(url) {
  try {
    return new URL(url).hostname.toLowerCase().replace(/^www\./, '');
  } catch (e) {
    return null;
  }
}

/** Vrai si [url] appartient à l'un des [domaines] (sous-domaines compris). */
function domaineAutorise(url, domaines) {
  const h = hote(url);
  return !!h && domaines.some((d) => h === d || h.endsWith('.' + d));
}

function mediane(valeurs) {
  const v = [...valeurs].sort((a, b) => a - b);
  const m = v.length >> 1;
  return v.length % 2 ? v[m] : (v[m - 1] + v[m]) / 2;
}

const arrondi = (x) => Math.round(x * 100) / 100;

/**
 * Agent prix, étape 4 : médiane si 2 offres ou plus, sinon l'offre unique.
 * Une offre à plus de 5 fois la médiane ou à moins du cinquième est écartée.
 * Les offres hors domaines autorisés ou d'un millésime non vérifié sont
 * écartées avant le calcul (docs/06, étapes 1 et 2).
 */
function agregerPrix(offres, { formatCl, devise, date, domainesMarchands }) {
  const base = { format_cl: formatCl, devise, date };
  let retenues = (offres || []).filter(
    (o) => o && o.prix > 0 && o.millesime_verifie !== false && domaineAutorise(o.url, domainesMarchands),
  );
  if (retenues.length >= 2) {
    const m = mediane(retenues.map((o) => o.prix));
    retenues = retenues.filter((o) => o.prix <= 5 * m && o.prix >= m / 5);
  }
  if (!retenues.length) {
    return { ...base, trouve: false, prix: null, motif: 'aucune offre fiable du même millésime et du même format' };
  }
  retenues = retenues.slice(0, 10).map((o) => ({
    site: o.site || hote(o.url),
    url: o.url,
    prix: arrondi(o.prix),
    millesime_verifie: o.millesime_verifie === true,
  }));
  const seule = retenues.length === 1;
  return {
    ...base,
    trouve: true,
    prix: arrondi(seule ? retenues[0].prix : mediane(retenues.map((o) => o.prix))),
    nature: seule ? 'offre' : 'mediane',
    nb_offres: retenues.length,
    offres: retenues,
    site: seule ? retenues[0].site : null,
    url: seule ? retenues[0].url : null,
  };
}

/** Toutes les URL citées dans un résultat, hors sources_consultees. */
function urlsCitees(resultat) {
  const urls = [];
  for (const champ of Object.values(resultat.fiche || {})) {
    if (champ && champ.url) urls.push(champ.url);
  }
  for (const n of resultat.notes_critiques || []) urls.push(n.url);
  for (const p of resultat.prix || []) {
    if (p.url) urls.push(p.url);
    for (const o of p.offres || []) urls.push(o.url);
  }
  return urls;
}

const CHAMP_VIDE = (motif) => ({ valeur: null, source: null, confiance: null, motif });
const OBLIGATOIRES = ['domaine', 'appellation', 'millesime', 'couleur'];

/**
 * Contrôles de sortie de l'agent d'enrichissement (docs/06, étape 10, et
 * défense contre les contenus piégés). Renvoie le résultat nettoyé et la
 * liste des erreurs bloquantes ; une erreur bloquante relance l'agent une
 * fois avec ces messages, puis passe le job en erreur.
 */
function controlerEnrichissement(resultat, { anneeCourante, champsVerrouilles = [], domainesMarchands = [] }) {
  const r = JSON.parse(JSON.stringify(resultat));
  const erreurs = [];
  r.alertes = r.alertes || [];
  const fiche = r.fiche || {};

  // Règle 3 et PRV-R2 : un champ verrouillé n'est jamais proposé.
  for (const champ of champsVerrouilles) {
    if (!fiche[champ]) continue;
    if (fiche[champ].valeur != null) {
      r.alertes.push({ code: 'champ_verrouille_ignore', champ, message: 'Champ saisi par l\'utilisateur : proposition retirée.' });
    }
    if (OBLIGATOIRES.includes(champ)) fiche[champ] = CHAMP_VIDE('champ verrouillé par l\'utilisateur');
    else delete fiche[champ];
  }

  const mill = fiche.millesime && fiche.millesime.valeur;
  if (typeof mill === 'number' && (mill < 1900 || mill > anneeCourante)) {
    erreurs.push(`millésime ${mill} hors de 1900 à ${anneeCourante}`);
  }
  const degre = fiche.degre && fiche.degre.valeur;
  if (typeof degre === 'number' && (degre < 5 || degre > 23)) erreurs.push(`degré ${degre} hors de 5 à 23 %`);
  const fenetres = [];
  if (fiche.garde && fiche.garde.valeur) fenetres.push(['garde', fiche.garde.valeur]);
  for (const n of r.notes_critiques || []) if (n.fenetre) fenetres.push(['fenêtre de ' + n.source_critique, n.fenetre]);
  for (const [nom, f] of fenetres) {
    if (f.fin < f.debut) erreurs.push(`${nom} : fin avant le début`);
    if (typeof mill === 'number' && f.debut < mill) erreurs.push(`${nom} : début avant le millésime`);
  }
  const app = normaliser(fiche.appellation && fiche.appellation.valeur);
  const couleur = fiche.couleur && fiche.couleur.valeur;
  if (app === 'champagne' && couleur && !['champagne', 'rose', 'effervescent'].includes(couleur)) {
    erreurs.push(`couleur ${couleur} incompatible avec l'appellation Champagne`);
  }

  const consultees = new Set((r.sources_consultees || []).map((s) => s.url));
  for (const url of urlsCitees(r)) {
    if (!consultees.has(url)) erreurs.push(`URL citée absente de sources_consultees : ${url}`);
  }
  for (const p of r.prix || []) {
    for (const u of [p.url, ...(p.offres || []).map((o) => o.url)].filter(Boolean)) {
      if (!domaineAutorise(u, domainesMarchands)) erreurs.push(`prix sur un site non autorisé : ${u}`);
    }
  }
  r.fiche = fiche;
  return { resultat: r, erreurs };
}

/** Mois de quota (AAAA-MM) d'une date, fuseau Europe/Paris. */
function moisQuota(date) {
  const p = new Intl.DateTimeFormat('fr-FR', { timeZone: 'Europe/Paris', year: 'numeric', month: '2-digit' })
    .formatToParts(date);
  return p.find((x) => x.type === 'year').value + '-' + p.find((x) => x.type === 'month').value;
}

/** Date du jour (AAAA-MM-JJ), fuseau Europe/Paris. */
function jourParis(date) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Paris' }).format(date);
}

if (typeof module !== 'undefined') {
  module.exports = {
    normaliser, cleVin, hote, domaineAutorise, mediane, agregerPrix, urlsCitees,
    controlerEnrichissement, moisQuota, jourParis,
  };
}
