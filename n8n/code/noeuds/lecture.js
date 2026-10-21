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
const e = lecture.etiquette || {};
const cle = cleVin({ domaine: e.domaine, appellation: e.appellation, cuvee: e.cuvee, millesime: e.millesime });
return [{ json: { lecture: { ...lecture, transcription }, transcription, cle: cle || 'aucune-cle', avec_cle: !!cle, brut_modele: texteDe(brut).slice(0, 4000) } }];
