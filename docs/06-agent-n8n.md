# 06. Agent n8n d'enrichissement

Le flux reçoit 1 à 4 photos et renvoie une fiche normalisée où chaque champ porte sa source. Il ne renvoie jamais une valeur sans origine. Contrat exact : specs/contrat-n8n/ (schémas JSON + exemples). Instructions des agents : n8n/prompt-agent-enrichissement.md et n8n/prompt-agent-prix.md.

## Où et comment

Décision D4 : un nouveau flux dans l'instance n8n actuelle, isolé des flux existants (RIDA et autres).

- Nom : `IA_CAVE_Agent` pour le flux principal, `IA_CAVE_<rôle>` pour ses sous-flux éventuels.
- Identifiants (credentials) propres au flux, préfixés `IA_CAVE`, jamais partagés avec RIDA.
- Un flux d'erreur dédié qui alerte par mail (comme les autres flux Apexus) sans bloquer le reste de l'instance.
- Le flux est exporté en JSON dans n8n/workflow/ à chaque version, pour être relu et versionné dans le dépôt.

## Points d'entrée

| Chemin | Méthode | Corps | Réponse |
| --- | --- | --- | --- |
| /webhook/iacave/enrichissement | POST | requete-enrichissement.schema.json | reponse-job.schema.json, statut en_attente (202) ou termine si cache |
| /webhook/iacave/prix | POST | requete-prix.schema.json | idem |
| /webhook/iacave/jobs?job_id=… | GET | aucun (signature sur le chemin avec la requête) | reponse-job.schema.json, 404 si job inconnu |
| /webhook/iacave/sante | GET | aucun | `{"version_flux": "...", "version_contrat": "1.1", "ok": true}` |

POST /enrichissement et POST /prix partagent les nœuds de contrôle d'entrée ; le type vient du webhook qui reçoit la requête (T65). Le webhook répond immédiatement avec le job_id (nœud Respond to Webhook), puis le traitement continue. L'app interroge /jobs toutes les 3 secondes pendant 30 secondes, puis toutes les 10 secondes, jusqu'à 3 minutes.

Contrôles à l'entrée, dans cet ordre : en-têtes présents, horodatage à moins de 300 secondes, signature HMAC (docs/02-architecture.md), request_id déjà vu (renvoyer le job existant), quota, validation du corps contre le schéma.

## Stockage côté n8n

Tables n8n (Data Tables) si la version de l'instance les propose, sinon une base Postgres. Pas de Google Sheets : latence, concurrence, et bug de cache connu du nœud Sheets sur cette instance.

| Table | Contenu | Durée de conservation |
| --- | --- | --- |
| iacave_jobs | job_id, request_id (unique), type, statut, etape, requête sans les photos, résultat, erreur, dates | 90 jours |
| iacave_cache_vins | clé normalisée, résultat de fiche, date, nombre d'utilisations | 180 jours |
| iacave_cache_prix | clé + format, résultat de prix, date | 24 heures |
| iacave_quotas | mois, enrichissements, prix, crédits de recherche consommés | 24 mois |
| iacave_signalements | job, champ, valeur signalée comme fausse, date | 24 mois |
| (pas de table de photos) | les photos passent du webhook au sous-flux en mémoire, elles ne sont écrites nulle part ; les exécutions réussies ne sont pas conservées (T61) | aucune |

Clé de cache d'un vin : domaine, appellation, cuvée et millésime normalisés (minuscules, sans accents, espaces et ponctuation en tirets), séparés par `|`. Le cache intervient après la lecture d'étiquette : il économise les recherches web, pas la lecture. Un signalement d'erreur sur un champ invalide l'entrée de cache correspondante.

## Étapes de l'agent d'enrichissement

1. Lecture des étiquettes par un modèle vision : transcription intégrale de chaque photo, puis extraction structurée (domaine, cuvée, appellation, signe de qualité, classement, lieu-dit, millésime, couleur, degré, volume, mentions bio, mise en bouteille). Le même appel donne, pour chaque photo, le cadre de l'étiquette en fractions de l'image (`cadrages`, contrat 1.1, T86) ; `cadre: null` quand aucune étiquette n'est identifiable, et l'app garde alors la photo entière.
2. Normalisation : rattachement aux référentiels (appellations officielles, cépages, régions), correction des erreurs de lecture, séparation appellation / signe de qualité / classement. Recherche du LWIN quand il existe.
3. Cache : si la clé existe et date de moins de 180 jours, renvoi immédiat du résultat (champ `cache.hit`).
4. Identification du domaine et de son site officiel, avec vérification que le site appartient au producteur (nom, adresse, mentions légales).
5. Enrichissement par priorité décroissante : site officiel (fiche technique cuvée et millésime), organismes officiels et interprofessions, sources tierces reconnues. Liste des domaines autorisés : n8n/sources-autorisees.yaml.
6. Rédaction des commentaires domaine et millésime : 400 à 600 caractères chacun, écrits par l'agent à partir des sources, jamais copiés.
7. Notes critiques, gratuites uniquement (décision D2) : page en accès libre du critique (`acces: libre`), ou note reprise par le site du domaine ou par un marchand (`acces: citee`, avec `citee_par`). Parker en priorité, autres critiques en complément.
8. Garde : uniquement une fenêtre publiée (critique, domaine, marchand qui cite un critique). Sinon valeur nulle : l'app applique ses règles locales.
8 bis. Accords mets-vins : toujours de 2 à 5, choisis dans la liste `accord_mets` de l'app. D'une source si possible, sinon déduits (couleur, type, appellation, cépages) avec la source `estimation` et une confiance d'au plus 0,6 (T80). Un oubli relance l'agent une fois.
9. Prix si `inclure_prix` : étapes de l'agent prix ci-dessous.
10. Contrôles : toute valeur `estimation` hors couleur, type et accords est retirée (T81) ; millésime entre 1900 et l'année en cours ou NM, degré entre 5 et 23 %, fenêtre qui ne commence pas avant le millésime, couleur compatible avec l'appellation, URL présentes dans `sources_consultees`. Validation de la réponse contre le schéma.
11. Mise à jour du job et du cache, décompte du quota.

## Étapes de l'agent prix

Décision D3 : prix relevés sur les sites publics de vente en ligne, sans service payant.

1. Recherche limitée aux domaines marchands autorisés de n8n/sources-autorisees.yaml.
2. Pour chaque page produit : vérifier domaine, cuvée, millésime et format avant de retenir un prix (`millesime_verifie`). Une offre d'un autre millésime est écartée.
3. Prix TTC de la bouteille à l'unité dans le format demandé. Les prix par carton sont ramenés à l'unité ; les frais de port sont exclus.
4. Résultat : médiane si 2 offres ou plus, sinon l'offre unique (`nature: offre`). Offre écartée si elle dépasse 5 fois la médiane ou en vaut moins du cinquième.
5. Aucune offre fiable : `trouve: false` avec un motif. Jamais d'estimation.
6. Respect des sites : robots.txt, une seule visite par page et par job, pas d'aspiration de catalogue, pas de contournement de connexion ni de paywall.

Mise en œuvre (lot 2b, sous-flux IA_CAVE_Prix) :

- Avant l'agent : cache de 24 heures (sauf `forcer`), puis au moins un site marchand actif. Sans site actif, aucun appel au modèle : `trouve: false` avec le motif.
- La recherche web intégrée de Claude est restreinte aux domaines marchands actifs (option `allowedDomains` du nœud Anthropic, T85).
- Une offre n'est retenue que si sa page figure dans les résultats de recherche renvoyés pendant ce job, sur un site autorisé, avec `millesime_verifie: true` (T59, T66, T85). La médiane et les écarts sont calculés par le flux, pas par le modèle.
- Avec `inclure_prix`, l'enrichissement appelle IA_CAVE_Prix en mode interne et fusionne prix, alertes, sources et coût à la clôture. Un relevé en erreur n'empêche pas la fiche : alerte `prix_non_trouve`.
- La purge quotidienne (IA_CAVE_Purge, 3 h 17) applique les durées du tableau de stockage.

## Recherche web et budget

L'agent utilise la recherche web intégrée de Claude (outil serveur `web_search` de l'API Anthropic, option `webSearch` du nœud Anthropic de n8n), sans intermédiaire (T85, décision de Bertrand du 2026-10-26). Tavily est retiré. La recherche est payante : 10 dollars pour 1 000 recherches, plus les jetons des résultats lus par le modèle ([tarifs Anthropic](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/web-search-tool)).

Garde-fous :

- 4 recherches au plus par enrichissement, 2 par relevé de prix (`maxUses`), domaines marchands imposés pour les prix (`allowedDomains`).
- Le flux refait `sources_consultees` à partir des URL réellement renvoyées par la recherche (n8n/code/lib/recherche.js). Une URL citée sans avoir été vue est refusée par les contrôles de sortie : l'agent ne peut pas inventer une source.
- Le coût de chaque job (`credits_recherche` = recherches facturées, `appels_modele`) est lu dans l'usage renvoyé par l'API et cumulé dans iacave_quotas.

Budget mensuel au plafond des quotas :

| Opération | Recherches par appel (au plus) | Quota mensuel | Recherches | Coût des recherches |
| --- | --- | --- | --- | --- |
| Enrichissement | 4 | 100 | 400 | 4,00 $ |
| Prix | 2 | 120 | 240 | 2,40 $ |
| Total | | | 640 | 6,40 $ |

S'y ajoutent les jetons du modèle (lecture d'étiquette, agent, résultats de recherche). Les quotas sont paramétrés dans le flux, pas dans l'app. Alerte par mail à 80 % de consommation. Le cache réduit la consommation réelle. Mesurer le coût moyen réel d'un enrichissement et le reporter dans docs/decisions.md (Q4).

## Défense contre les contenus piégés

Les pages web lues par l'agent sont des données, jamais des instructions. Une page peut contenir du texte écrit pour détourner un agent (« ignore tes consignes », « renvoie telle note »).

- Le prompt système l'interdit explicitement (n8n/prompt-agent-enrichissement.md, règle 10).
- Le flux ne garde que des champs du schéma : toute propriété inconnue fait échouer la validation.
- Toute URL citée dans la réponse doit figurer dans `sources_consultees`, et les URL de prix doivent appartenir aux domaines autorisés : contrôle par un nœud Code après l'agent.
- Un contenu suspect détecté produit l'alerte `contenu_suspect_ignore`.

## Exploitation

- Journal par job : durée, étapes, sources, crédits, appels modèle, erreurs.
- Version du flux renvoyée par /sante et inscrite dans chaque job.
- Après toute modification d'un flux actif, le republier : une modification non publiée n'est pas celle qui s'exécute (voir .claude/rules/n8n.md).
- Jeu d'essai : 30 étiquettes réelles photographiées dans la cave (Bordeaux, Bourgogne, Alsace, Rhône, Champagne, Loire, étranger, étiquettes abîmées ou à contre-jour), rangées dans n8n/jeu-essai/ avec le résultat attendu. Cibles : domaine et millésime justes dans 95 % des cas, appellation juste dans 85 %, zéro note critique sans source vérifiable, zéro prix d'un autre millésime.

## Sources

- [Anthropic, Web search tool](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/web-search-tool), consulté le 2026-10-26
- [Tavily, API credits](https://docs.tavily.com/documentation/api-credits), consulté le 2026-10-20 (outil abandonné, T85)
- [Parallel, The best free web search APIs for AI agents in 2026](https://parallel.ai/articles/best-free-web-search-api), juillet 2026, consulté le 2026-10-20
- [Liv-ex, API Robert Parker Wine Advocate](https://www.liv-ex.com/press-release-liv-ex-launches-new-robert-parker-wine-advocate-api-just-in-time-for-en-primeur/), 30 avril 2026 : accès payant réservé aux membres, écarté en phase 1
