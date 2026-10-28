// Normalisation et dates : clé de cache, domaines, mois de quota, jour à
// Paris (docs/06, étape 3 et budget).

/** Minuscules, sans accents, espaces et ponctuation en tirets. */
function normaliser(texte) {
  return String(texte == null ? '' : texte)
    .replace(/œ/g, 'oe').replace(/Œ/g, 'oe').replace(/æ/g, 'ae').replace(/Æ/g, 'ae').replace(/ß/g, 'ss')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
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
  module.exports = { normaliser, cleVin, hote, domaineAutorise, moisQuota, jourParis };
}
