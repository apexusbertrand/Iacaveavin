# Autocritique : V1, V2, V3

Trois passes sur le cahier des charges. Ce document garde la trace de ce que chaque passe a corrigé, et de ce qui reste fragile. Il ne s'adresse pas à l'agent de développement.

## V1 vers V2 (2026-10-20)

La V1 reprenait la demande fonction par fonction. La relecture y a trouvé 16 défauts, dont 4 bloquants : notes Parker « récupérées » sur un site payant, stock réduit à un champ quantité, appel n8n synchrone, données locales sans sauvegarde. Les 12 autres : prix sans source définie, webhook ouvert, enrichissement sans traçabilité, appellation confondue avec l'AOP, import Excel sans clé, statistiques non définies, contraste de l'orange, textes de châteaux recopiés, photo unique, pas d'identifiant standard (LWIN), publication sous-estimée, prompt sans lots ni recette. Détail dans le doc Claude « Cahier des charges : application cave à vin Apexus », section 12.

## V2 vers V3 (2026-10-20)

La V2 était un bon cahier des charges à lire. Elle restait un mauvais prompt pour Claude Code, et contenait encore des erreurs de fond. Vingt corrections :

| # | Défaut de la V2 | Risque | Correction V3 |
| --- | --- | --- | --- |
| 1 | Un document de 12 sections à coller en un bloc | contexte saturé, consignes diluées, rien ne persiste d'une session à l'autre | CLAUDE.md de moins de 200 lignes lu à chaque session, règles par dossier dans .claude/rules/ chargées seulement quand Claude touche app/ ou n8n/, docs lues à la demande, skill `/lot` |
| 2 | « Libellés de la fiche en orange » sur fond clair | contraste mesuré à 2,22:1, illisible ; texte blanc sur orange à 2,45:1 | jeton `primaryTexte` à 4,55:1, ratios mesurés dans specs/design-tokens.json, test de contraste automatique |
| 3 | Pays et région portés par le domaine | faux pour un négociant qui produit dans plusieurs régions | origine portée par la cuvée |
| 4 | Champs décrits à 4 endroits (modèle, Excel, PDF, contrat) | divergences garanties au fil des lots | specs/dictionnaire-donnees.yaml source unique, test d'alignement |
| 5 | Contrat n8n illustré par un seul exemple | chaque côté interprète à sa façon | JSON Schema pour requêtes et réponses, 7 exemples valides et 9 mutations rejetées, vérifiés par scripts/valider_contrat.py |
| 6 | Exigences sans identifiant | impossible de tracer une exigence jusqu'à son test | identifiants stables (LST-04, AJO-12...), tests nommés d'après eux, matrice générée |
| 7 | Lot 2 bloqué tant que le flux n8n n'existe pas | l'app attend le back-office | lot 2a contre une fausse passerelle qui rejoue les exemples, 2b flux en parallèle, 2c branchement ; lot 0 socle installable dès la première semaine |
| 8 | Licence Parker et API de prix envisagées | contraire aux décisions D2 et D3 | notes en accès libre ou citées (`citee_par`), marchands publics en liste blanche, millésime vérifié sur la page |
| 9 | Aucun outil de recherche web défini pour l'agent | l'agent ne peut rien enrichir | Tavily en offre gratuite, budget en crédits, quotas calibrés pour y tenir |
| 10 | Garde estimée par l'IA | résultat changeant d'un appel à l'autre, invérifiable | règles locales déterministes dans specs/regles-garde.yaml, modifiables sans code |
| 11 | Statuts de garde qui se chevauchent | « à boire vite » avant même le début de la fenêtre sur une garde courte | algorithme ordonné, cas de test vérifiés par script |
| 12 | Clé par installation obtenue par un enregistrement ouvert | n'importe qui s'enregistre : fausse sécurité | phase 1 : clé partagée saisie dans les Réglages, signature HMAC spécifiée octet par octet |
| 13 | Rien contre les pages web piégées | une page peut dicter une note ou un prix à l'agent | règle explicite dans les prompts, validation stricte du schéma, contrôle des URL et des domaines, alerte dédiée |
| 14 | Pas de cache | chaque bouteille d'un même vin repaie la recherche | cache par vin (180 jours) et par prix (24 heures) |
| 15 | Volumes de photos non chiffrés | sauvegardes de plusieurs centaines de Mo sans prévenir | budget par photo, espace affiché, archive sans photos |
| 16 | Publication Play au lot 5 | contraire à D5 ; clé de signature jamais évoquée | APK direct par releases GitHub, clé créée au lot 0 et sauvegardée, Play reporté au lot 6 |
| 17 | Export Excel non typé | virgules décimales et dates en texte dans un Excel français | cellules typées (XLS-02) |
| 18 | Textes rédigés par l'IA non signalés | confusion avec un texte du domaine, exigences possibles des stores | mention « rédigé par IA », bouton « Signaler une erreur » relié au cache |
| 19 | Stockage des jobs non précisé | risque d'utiliser Google Sheets, déjà instable sur l'instance | tables n8n ou Postgres, durées de conservation fixées |
| 20 | Aucune trace des décisions | les choix se perdent d'un lot à l'autre | docs/decisions.md avec questions ouvertes datées |

## Ce que la V3 ne règle pas

- Avec des sources gratuites, beaucoup de vins n'auront pas de note Parker : seules les notes publiées en accès libre ou reprises par un domaine ou un marchand sont visibles. C'est assumé (D2), l'app l'affiche clairement.
- Les conditions d'utilisation des sites marchands candidats ne sont pas vérifiées. Elles le seront au lot 2b, domaine par domaine.
- Le coût du modèle IA par enrichissement est inconnu tant que le flux ne tourne pas.
- Les règles de garde par défaut sont des ordres de grandeur prudents, à valider par Bertrand.
- Les couleurs Apexus sont approchées : il faut le logo en haute définition.
