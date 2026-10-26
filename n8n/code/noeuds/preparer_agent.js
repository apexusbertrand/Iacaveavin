// Message système et message utilisateur de l'agent d'enrichissement. Le
// prompt vient de n8n/prompt-agent-enrichissement.md ; la date du jour est
// injectée ici, jamais devinée par l'agent.
// @inclure normalisation.js
const envoi = $('Déclencheur enrichissement').first().json;
const config = {};
for (const i of $('Config enrichissement').all()) config[i.json.cle] = i.json.valeur;
const d = $('Décision cache').first().json;
const req = envoi.requete;
const jour = jourParis(new Date());
const sources = __SOURCES__;
const schema = __SCHEMA_REPONSE__;
let systeme = __PROMPT_ENRICHISSEMENT__
  .replace("{{ $now.setZone('Europe/Paris').toFormat('yyyy-MM-dd') }}", jour)
  .replace('{{ JSON.stringify($json.champs_verrouilles || []) }}', JSON.stringify(req.champs_verrouilles || []))
  .replace('{{ JSON.stringify($json.indices || {}) }}', JSON.stringify(req.indices || {}));
systeme += '\n\nOutils : `recherche_web` (une requête, 5 résultats) et `lire_page` (texte d\'une URL). '
  + (config.tavily_cle ? '' : 'La recherche web n\'est pas configurée : n\'appelle aucun outil, renseigne seulement ce que dit l\'étiquette et mets les autres valeurs à null avec le motif « recherche web indisponible ». ')
  + 'Si un outil renvoie une erreur, continue sans lui.'
  + '\nAccords mets-vins permis (règle 15), libellés exacts : ' + JSON.stringify(__ACCORDS__)
  + '\nDomaines vérifiés (à privilégier) : ' + JSON.stringify(sources)
  + '. Un domaine absent de cette liste ne sert que s\'il s\'agit du site officiel du producteur, vérifié (nom, adresse, mentions légales).'
  + '\nLa lecture des photos est déjà faite : elle t\'est donnée dans le message. Ne renseigne ni `prix`, ni `cache`, ni `cout`, et laisse `transcription` vide : le flux les complète.'
  + '\nFormat exact : un objet JSON conforme à $defs.resultat_enrichissement du schéma suivant. Chaque champ de `fiche` est un objet {valeur, source, url, confiance, motif, note}.'
  + '\n' + JSON.stringify({ $defs: schema.$defs });
const message = 'Lecture des photos (' + $('Photos en binaire').first().json.types + ') :\n'
  + JSON.stringify(d.lecture)
  + '\n\nRenvoie uniquement l\'objet JSON `resultat`.';
return [{ json: { systeme, message } }];
