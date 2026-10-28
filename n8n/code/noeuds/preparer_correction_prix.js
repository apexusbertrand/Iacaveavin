// Seconde et dernière chance pour l'agent prix : sa sortie refusée et les erreurs.
const c = $input.first().json;
const message = 'Ta réponse précédente a été refusée par les contrôles du flux. Corrige uniquement ces erreurs, sans inventer de prix :\n- '
  + c.erreurs.slice(0, 20).join('\n- ')
  + '\n\nRéponse refusée :\n' + c.sortie
  + '\n\nRenvoie uniquement l\'objet JSON {"offres": [...], "alertes": [...]}.';
return [{ json: { systeme: $('Décision prix').first().json.systeme, message } }];
