# Prompt pour Claude for Chrome : publier IA cave à vin sur Google Play

À coller dans Claude for Chrome, connecté au compte Google apexus.claude@gmail.com et au compte GitHub apexusbertrand, une fois la version 1.4.0 construite (release GitHub v1.4.0 avec le fichier iacaveavin-v1.4.0.aab). Suite de store/prompt-claude-chrome-play-console.md. Suivi : docs/journal-lots.md, lot 6.

```
Tu m'aides à terminer la publication de mon application Android « IA Cave a vin » (fr.apexus.iacaveavin) dans la Google Play Console. Je suis Bertrand, propriétaire du compte développeur APEXUS (apexus.claude@gmail.com). La fiche française, le contenu de l'application et la classification sont déjà remplis. Travaille dans un nouvel onglet.

SOURCES (je suis connecté à GitHub, le dépôt est privé)
- Fiche anglaise : https://github.com/apexusbertrand/Iacaveavin/blob/lot-6-google-play/store/fiche-play-en.md
- Fiche française (notes de version) : https://github.com/apexusbertrand/Iacaveavin/blob/lot-6-google-play/store/fiche-play.md
Recopie les textes à l'identique, entre les blocs de code, sans les reformuler. Si une question de la Console n'a pas de réponse dans ces fichiers, arrête-toi et demande-moi. N'invente jamais une réponse.

CE QUE TU NE FAIS PAS SANS MON ACCORD EXPLICITE DANS LE CHAT
- Envoyer en examen, publier, déployer une version, en test comme en production.
- Accepter un contrat, des conditions ou une déclaration légale, dont la déclaration de professionnel.
- Payer, saisir un moyen de paiement, créer un produit payant ou un abonnement.
- Modifier les réglages du compte, les utilisateurs, la clé de signature, Play App Signing.
- Supprimer quoi que ce soit.
Si une page demande un mot de passe, une validation en deux étapes ou un téléversement de fichier, arrête-toi et laisse-moi faire.

ÉTAPE 1 : FICHE EN ANGLAIS
Croissance > Présence sur le Play Store > Fiche principale > Gérer les traductions : ajoute « Anglais (Royaume-Uni) – en-GB » et « Anglais (États-Unis) – en-US ». Pour chacune, colle le nom, la description courte et la description longue de la fiche anglaise. Les captures anglaises sont store/captures-en/01 à 05 : arrête-toi, je les téléverse moi-même. Enregistre en brouillon.

ÉTAPE 2 : VERSION 1.4.0 EN TEST INTERNE
Tester et publier > Tests > Tests internes. Vérifie que la liste « Testeurs IA cave à vin » est cochée dans l'onglet Testeurs. Crée une nouvelle version (ou reprends le brouillon « 1.3.1 (8) » et vide-le).
- Le fichier : arrête-toi, je téléverse iacaveavin-v1.4.0.aab moi-même. Ne téléverse pas le zip de symboles : il ne sert pas à Google Play.
- Nom de la version : « 1.4.0 (9) ».
- Notes de version : fr-FR depuis la fiche française, en-GB et en-US depuis la fiche anglaise.
- Enregistre, puis montre-moi les erreurs et avertissements de la page « Vérifier la version ». Un avertissement sur les symboles de débogage natifs peut être ignoré ; dis-moi tous les autres mot pour mot.
- Attends mon accord pour « Enregistrer et publier » en test interne.

ÉTAPE 3 : PAYS (à faire après mon retour de test sur téléphone)
Tester et publier > Production > Pays et régions : demande-moi la liste des pays dans le chat avant de cocher quoi que ce soit.

ÉTAPE 4 : PRODUCTION
Production > Créer une version > « Promouvoir » la version 1.4.0 (9) du test interne (ou ajouter le même App Bundle depuis la bibliothèque). Mêmes notes de version. Montre-moi la page de vérification, puis attends mon accord écrit pour « Envoyer pour examen ».

ÉTAPE 5 : STATUT DE PROFESSIONNEL
Ouvre la page où la Console demande de déclarer si le compte est un professionnel (trader) au sens de l'Union européenne. Montre-moi la question et les choix, sans rien cocher : c'est une déclaration légale que je fais moi-même.

À LA FIN
Compte rendu court : ce qui est fait, ce qui attend mon action, chaque message d'erreur ou d'avertissement de la Console mot pour mot.
```

Avant l'étape 2 sur ton téléphone : la version du Play Store est signée par Google, Android refusera de l'installer par-dessus la version GitHub. Exporte une sauvegarde (menu Sauvegarde), désinstalle la version GitHub, installe depuis le lien de test interne, puis restaure la sauvegarde.
