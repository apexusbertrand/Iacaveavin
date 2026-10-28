// Seconde et dernière chance : la sortie refusée et les erreurs à corriger.
const c = $input.first().json;
const message = 'Ta réponse précédente a été refusée par les contrôles du flux. Corrige uniquement ces erreurs, sans inventer de valeur (une valeur sans source vaut null avec un motif) :\n- '
  + c.erreurs.slice(0, 20).join('\n- ')
  + '\n\nRéponse refusée :\n' + c.sortie
  + '\n\nRenvoie uniquement l\'objet JSON `resultat` corrigé.';
return [{ json: { systeme: $('Préparation agent').first().json.systeme, message } }];
