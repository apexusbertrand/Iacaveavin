// Message système et message utilisateur de l'agent d'enrichissement. Le
// prompt vient de n8n/prompt-agent-enrichissement.md ; la date du jour est
// injectée ici, jamais devinée par l'agent.
// @inclure normalisation.js
const envoi = $('Déclencheur enrichissement').first().json;
const d = $('Décision cache').first().json;
const req = envoi.requete;
const jour = jourParis(new Date());
const sources = __SOURCES__;
const schema = __SCHEMA_REPONSE__;
let systeme = __PROMPT_ENRICHISSEMENT__
  .replace("{{ $now.setZone('Europe/Paris').toFormat('yyyy-MM-dd') }}", jour)
  .replace('{{ JSON.stringify($json.champs_verrouilles || []) }}', JSON.stringify(req.champs_verrouilles || []))
  .replace('{{ JSON.stringify($json.indices || {}) }}', JSON.stringify(req.indices || {}));
// Recherche web intégrée de Claude (T85) : 4 recherches au plus par appel.
systeme += '\n\nOutil : la recherche web intégrée, 4 recherches au plus. Une URL citée doit venir d\'un résultat de recherche de cet appel, sinon le flux la refuse. '
  + 'Si la recherche ne donne rien, renseigne seulement ce que dit l\'étiquette et mets les autres valeurs à null avec un motif.'
  + '\nAccords mets-vins permis (règle 15), libellés exacts : ' + JSON.stringify(__ACCORDS__)
  + '\nDomaines vérifiés (à privilégier) : ' + JSON.stringify(sources)
  + '. Un domaine absent de cette liste ne sert que s\'il s\'agit du site officiel du producteur, vérifié (nom, adresse, mentions légales).'
  + (req.signalements && req.signalements.length
    ? '\nValeurs signalées fausses par l\'utilisateur sur cette fiche (PRV-R4) : ' + JSON.stringify(req.signalements)
      + '. Ne les repropose pas, sauf si une source consultée dans cet appel les confirme explicitement ; sinon cherche la bonne valeur, ou mets null avec un motif.'
    : '')
  + '\nLa lecture des photos est déjà faite : elle t\'est donnée dans le message. Ne renseigne ni `prix`, ni `cache`, ni `cout`, ni `cadrages`, et laisse `transcription` vide : le flux les complète.'
  + '\nFormat exact : un objet JSON conforme à $defs.resultat_enrichissement du schéma suivant. Chaque champ de `fiche` est un objet {valeur, source, url, confiance, motif, note}.'
  + '\n' + JSON.stringify({ $defs: schema.$defs });
const message = 'Lecture des photos (' + $('Photos en binaire').first().json.types + ') :\n'
  + JSON.stringify(d.lecture)
  + '\n\nRenvoie uniquement l\'objet JSON `resultat`.';
return [{ json: { systeme, message } }];
