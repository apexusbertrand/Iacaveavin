// Réponse du modèle vision → transcription et champs lus sur l'étiquette,
// puis clé de cache (docs/06, étapes 1 à 3).
// @inclure normalisation.js
// @inclure modele.js
const brut = $input.first().json;
let lecture;
try {
  lecture = jsonDe(texteDe(brut));
} catch (e) {
  throw new Error('photo_illisible : lecture d\'étiquette inexploitable (' + e.message + ')');
}
const transcription = (lecture.transcription || [])
  .filter((t) => t && Number.isInteger(t.index) && typeof t.texte === 'string')
  .map((t) => ({ index: Math.max(0, Math.min(3, t.index)), texte: t.texte }));
if (!transcription.length) transcription.push({ index: 0, texte: '' });
// Cadre de l'étiquette par photo (contrat 1.1) : borné à l'image, au moins
// 10 % de chaque côté, sinon null et la photo reste entière.
const nombre = (v) => (typeof v === 'number' && Number.isFinite(v) ? v : null);
const cadrages = [];
for (const c of Array.isArray(lecture.cadrages) ? lecture.cadrages : []) {
  if (!c || !Number.isInteger(c.index) || c.index < 0 || c.index > 3 || cadrages.some((x) => x.index === c.index)) continue;
  const k = c.cadre || {};
  const x = nombre(k.x), y = nombre(k.y), l = nombre(k.largeur), h = nombre(k.hauteur);
  let cadre = null;
  if (x !== null && y !== null && l !== null && h !== null) {
    const x0 = Math.max(0, Math.min(1, x)), y0 = Math.max(0, Math.min(1, y));
    const l0 = Math.min(1 - x0, l), h0 = Math.min(1 - y0, h);
    if (l0 >= 0.1 && h0 >= 0.1) cadre = { x: +x0.toFixed(4), y: +y0.toFixed(4), largeur: +l0.toFixed(4), hauteur: +h0.toFixed(4) };
  }
  cadrages.push({ index: c.index, cadre });
}
const e = lecture.etiquette || {};
const cle = cleVin({ domaine: e.domaine, appellation: e.appellation, cuvee: e.cuvee, millesime: e.millesime });
// T111 : résultat partiel écrit dans le job dès la lecture, pour que l'app
// affiche ce qui est lu sur l'étiquette pendant l'enrichissement. Une valeur
// absente ou hors format reste nulle, avec son motif (règle 2).
const COULEURS = ['rouge', 'blanc', 'rose', 'champagne', 'effervescent', 'liquoreux', 'orange', 'autre'];
const lu = (valeur) => (valeur === null || valeur === undefined
  ? { valeur: null, source: null, confiance: null, motif: 'non lu sur l\'étiquette' }
  : { valeur, source: 'etiquette', confiance: null });
const texte = (v) => (typeof v === 'string' && v.trim() ? v.trim().slice(0, 300) : null);
const millesime = Number.isInteger(e.millesime) && e.millesime >= 1900 && e.millesime <= 2100 ? e.millesime : e.millesime === 'NM' ? 'NM' : null;
const fiche = {
  domaine: lu(texte(e.domaine)), cuvee: lu(texte(e.cuvee)), appellation: lu(texte(e.appellation)),
  millesime: lu(millesime), couleur: lu(COULEURS.includes(e.couleur) ? e.couleur : null),
};
for (const k of ['degre', 'volume_cl']) {
  if (nombre(e[k]) !== null && e[k] > 0) fiche[k] = lu(e[k]);
}
const partiel = { fiche, transcription, notes_critiques: [], alertes: [], sources_consultees: [] };
return [{ json: { lecture: { ...lecture, transcription, cadrages }, transcription, cadrages, cle: cle || 'aucune-cle', avec_cle: !!cle, partiel: JSON.stringify(partiel), brut_modele: texteDe(brut).slice(0, 4000) } }];
