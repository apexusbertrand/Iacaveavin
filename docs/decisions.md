# Journal des décisions

Une ligne par décision, la plus récente en bas. Une décision ne s'efface pas : une décision qui en remplace une autre la cite. Claude Code ajoute ici toute décision technique qui change le sens d'un document, et la soumet à Bertrand.

## Décisions de Bertrand (2026-10-20)

| Id | Décision | Conséquence dans le cahier des charges |
| --- | --- | --- |
| D1 | Nom de l'application : IA cave à vin | identifiant Android `fr.apexus.iacaveavin`, dépôt `IA-cave-a-vin`, schéma de lien `iacaveavin://` |
| D2 | Notes Parker : uniquement ce qui est gratuit, rien de payant dans un premier temps | notes en accès libre ou citées par le domaine ou un marchand (`acces`, `citee_par`) ; pas de licence Liv-ex ; jamais de note estimée |
| D3 | Prix marché : sites publics de vente en ligne | agent prix limité aux marchands de n8n/sources-autorisees.yaml, millésime vérifié sur la page, médiane des offres, « non trouvé » plutôt qu'une estimation |
| D4 | Hébergement : un nouveau flux dans l'instance n8n actuelle | flux `IA_CAVE_Agent` isolé (identifiants, tables, flux d'erreur et quotas propres) |
| D5 | Pas de compte Google Play au départ ; publication une fois l'ensemble testé | distribution directe de l'APK par releases GitHub, clé de signature créée dès le lot 0, publication reportée au lot 6 |

## Décisions techniques (V3, 2026-10-20)

| Id | Décision | Raison |
| --- | --- | --- |
| T1 | Flutter, une base de code Android et iOS | portage iOS sans réécriture |
| T2 | Local-first : SQLite et photos sur le téléphone | usage en cave sans réseau, aucune donnée de cave sur un serveur |
| T3 | Appels au flux asynchrones (job + suivi) avec idempotence | un agent qui consulte plusieurs sites dépasse 30 s |
| T4 | specs/dictionnaire-donnees.yaml source unique des champs | base, Excel, PDF et contrat ne divergent plus |
| T5 | Contrat n8n en JSON Schema, validé des deux côtés | erreurs de format détectées avant l'enregistrement |
| T6 | Garde estimée en local par specs/regles-garde.yaml, jamais par l'agent | résultat déterministe, hors ligne, modifiable sans IA |
| T7 | Phase 1 : clé partagée saisie dans les Réglages + signature HMAC | app non publiée ; une clé par installation n'apporterait rien sans comptes |
| T8 | Recherche web par Tavily (offre gratuite, 1 000 crédits par mois), outil interchangeable | offre mensuelle renouvelée, sans carte bancaire, pensée pour les agents ; Brave n'est plus gratuit depuis février 2026 ; Exa ou Firecrawl restent des solutions de repli gratuites |
| T9 | Stockage des jobs dans les tables n8n ou Postgres, pas dans Google Sheets | latence, concurrence, bug de cache connu du nœud Sheets |
| T10 | Quotas mensuels : 100 enrichissements, 120 relevés de prix | tenir dans l'offre gratuite de recherche web |

## Décisions techniques proposées au lot 0 (2026-10-21), à valider par Bertrand

| Id | Décision | Raison |
| --- | --- | --- |
| T11 | NAV-01 livré au lot 0 : tiroir complet, les entrées des lots suivants ouvrent un écran « arrive avec le lot N » | docs/08 place NAV-01 au lot 0, docs/05 marque la section NAV [lot 1] ; choix de Bertrand le 2026-10-21. Proposition : annoter NAV-01 [lot 0] dans docs/05 |
| T12 | Le jeu de démonstration vit dans une cave dédiée (cave_id fixe) et son effacement est physique | effacer la démo sans toucher aux vrais vins ; ce sont des données fictives, la règle de suppression logique vise les données de l'utilisateur |
| T13 | Écran Paramètres réduit au jeu de démonstration au lot 0 ; base vide au premier lancement, l'état vide propose aussi de charger la démo | CMP-07 demande la démo « dans les Réglages », les réglages complets (PAR-05) sont au lot 1 ; choix de Bertrand le 2026-10-21 |
| T14 | Référentiels provisoires saisis au lot 0 (47 pays, 83 régions, 21 sous-régions, 221 appellations, 153 cépages, 40 accords) ; `scripts/generer_referentiels.py --inao` régénère les appellations depuis le CSV de l'INAO | data.gouv.fr inaccessible depuis l'environnement de développement ; choix de Bertrand le 2026-10-21 |
| T15 | Une appellation sans sous-région (Champagne, Alsace, Cahors...) est rattachée directement à sa région | le dictionnaire prévoit appellation → sous-région, mais beaucoup de régions n'ont pas de sous-région ; à confirmer avant FIC-02 (lot 1) |
| T16 | Millésime stocké en texte (4 chiffres ou « NM »), dates métier en texte ISO, horodatages en texte ISO UTC, montants en décimal | l'ordre lexical de « 2005 »…« 2024 » suit l'ordre des années et « NM » se range à part ; fichiers de base lisibles |
| T17 | Champs `calcule` non stockés au lot 0 : le stock est la somme des mouvements calculée à la lecture | règle 4 respectée sans cache ; un cache dénormalisé viendra si les mesures du lot 5 (5 000 fiches) l'exigent |
| T18 | `favori` et `statut_enrichissement` nullables avec valeur par défaut, comme le dictionnaire (non obligatoires) | alignement strict vérifié par test ; proposition : les marquer `oblig: true` dans le dictionnaire |
| T19 | Riverpod sans génération de code (providers écrits à la main) | moins de code généré pour un gain nul à ce stade ; CLAUDE.md cite « code généré drift et riverpod » |
| T20 | Police système au lot 0, Inter (OFL) ajoutée quand ses fichiers seront fournis | repli prévu par specs/design-tokens.json ; pas d'accès au dépôt de la police depuis l'environnement de développement |
| T21 | Code généré (drift, traductions, jetons de thème, listes du dictionnaire) commité ; la CI régénère et échoue en cas d'écart | `git clone` puis `flutter run` fonctionne sans étape préalable |
| T22 | Une build release sans `android/key.properties` échoue au lieu de signer avec la clé de debug | un APK signé debug installé sur le téléphone bloquerait les mises à jour signées |
| T23 | Flutter figé à 3.47.7 stable dans la CI | builds reproductibles ; montée de version par décision |
| T24 | Dépôt GitHub réel : `apexusbertrand/Iacaveavin` (et non `IA-cave-a-vin` comme écrit dans D1 et PROMPT_DEMARRAGE.md) | dépôt créé par Bertrand sous ce nom |

## Décisions techniques proposées au lot 1 (2026-10-21), à valider par Bertrand

| Id | Décision | Raison |
| --- | --- | --- |
| T25 | Lot 1 démarré avant la recette du lot 0, sur une branche issue de `lot-0-socle` | demande de Bertrand le 2026-10-21 (« avancer les prochains lots ») ; le lot 2b reste bloqué sans accès à n8n |
| T26 | Tri, filtres, groupes et recherche calculés en mémoire par des fonctions pures du domaine | testable sans base, 5 000 fiches tiennent en mémoire ; mesure de NFR-01 à confirmer au lot 5 |
| T27 | Toute valeur absente se range en fin de liste, quel que soit le critère et le sens | généralisation de NOT-R4 (note Parker) aux autres critères |
| T28 | « Année d'apogée » ajoutée aux critères de tri | LST-03 la cite comme groupable alors que LST-01 ne la listait pas ; un groupe suit le tri 1 |
| T29 | Changer de critère de tri garde le sens choisi | évite un saut de liste ; le sens se bascule d'un tap |
| T30 | Dans les groupes propriétaire et emplacement, un vin se range sous le propriétaire ou l'emplacement qui a le plus de bouteilles | une fiche n'apparaît qu'une fois |
| T31 | Déplacer ou changer de propriétaire une sélection (LST-08) transfère chaque lot en entier par mouvements (STK-R5) | le stock ne change que par des mouvements (règle 4) |
| T32 | Annulation de 5 s : les mouvements créés sont supprimés physiquement, ainsi que le lot cible d'un transfert | prévu par STK-R4 tant que l'action n'est pas confirmée |
| T33 | Inventaire (STK-04) : une étape par emplacement qui contient directement des lots, écart enregistré avec le motif « inventaire » | parcours emplacement par emplacement sans doublon |
| T34 | Sauvegarde hebdomadaire (SAV-03) faite au lancement de l'app si elle est due, sans photos, sans tâche de fond | pas de dépendance workmanager au lot 1 ; les photos sont déjà sur le téléphone |
| T35 | Restauration (SAV-04) : l'archive est migrée à part, puis copiée table par table dans une seule transaction | en cas d'échec, la cave actuelle reste intacte |
| T36 | SAV-05 : `android:allowBackup="false"` | évite qu'Android restaure une base partielle ou ancienne à la réinstallation |
| T37 | FIC-05 : historique des prix marché en liste chronologique au lot 1 ; la courbe arrive avec les prix réels (lot 2c) ou les graphiques (lot 3) | aucun prix marché ne peut exister avant le lot 2c |
| T38 | PRO-03 : filtre par propriétaire et valeur d'achat par propriétaire livrés ; la dimension statistique arrive avec les statistiques (lot 3) | STA est au lot 3 |
| T39 | PAR-05 : connexion au flux n8n et rafraîchissement automatique des prix affichés mais inactifs jusqu'au lot 2c ; langue française seule | ces réglages pilotent des fonctions des lots 2c et suivants |
| T40 | Un motif de mouvement déjà utilisé ne se fusionne pas | les mouvements sont immuables ; on peut le renommer ou le désactiver |
| T41 | Tous les écrans de premier niveau gardent le tiroir ; « Emplacements » et « Sauvegarde » quittent l'écran « à venir » | livrés au lot 1 |

## Décisions techniques proposées au lot 2a (2026-10-21), à valider par Bertrand

| Id | Décision | Raison |
| --- | --- | --- |
| T42 | Lot 2a démarré avant la recette du lot 1, sur une branche issue de `lot-1-cave-locale` | même demande que T25 ; le lot 2b attend l'accès à n8n |
| T43 | Une fiche photo naît tout de suite avec un domaine vide et le millésime « NM », statut `a_enrichir` ; la liste l'affiche « Vin à identifier » | AJO-03 exige une fiche enregistrée avant la réponse du flux ; aucune valeur inventée (règle 2) |
| T44 | Toutes les provenances d'une fiche sont rangées sous l'entité `fiche_vin`, avec le nom de champ du contrat (domaine, appellation, degre...) | un seul point de lecture pour la fiche, les champs verrouillés et la requête ; la table de correspondance contrat → dictionnaire est dans `domain/enrichment.dart` |
| T45 | Le lot saisi pendant l'attente (AJO-04) est enregistré tout de suite, par un mouvement, et rejoint la fiche existante en cas de fusion (AJO-07) | le stock ne change que par des mouvements (règle 4) |
| T46 | Fin d'enrichissement signalée dans l'app (badge de file, écran d'identification), sans notification système avant le lot 4 | évite une dépendance de notifications et une permission Android 13 au lot 2a |
| T47 | Prise de vue avec `image_picker` (appareil photo ou galerie) sans cadre de visée personnalisé | plugin officiel Android et iOS ; un cadre demanderait le paquet `camera`, plus lourd ; à revoir après la recette |
| T48 | Code-barres EAN saisi en texte, contrôlé par la clé EAN-13 ; lecture par l'appareil photo reportée | un lecteur demande un paquet de plus (mobile_scanner) ; l'EAN reste un indice (AJO-10) |
| T49 | Seuils photo : flou si la variance du laplacien est sous 100, reflet si plus de 8 % des pixels sont saturés ; alerte non bloquante | valeurs de départ à recalibrer sur les photos réelles de la recette |
| T50 | PRV-R4 : le signalement est enregistré (`signale` à vrai, valeur barrée) mais n'est pas encore transmis au flux, faute de champ dans le contrat 1.0 ; proposition : champ `signalements` dans la requête, contrat 1.1, au lot 2b | écart signalé (règle 10) ; le message affiché ne promet pas l'envoi |
| T51 | Paramètres : scénario du faux flux (terminé, partiel, cache, quota, réponse invalide, sans réponse) et hors ligne simulé, jusqu'au lot 2c | recette du lot 2a sur téléphone sans n8n |
| T52 | Base en version 2 : colonnes `envoye_le` et `reponse` sur `job` (dictionnaire, migration et test de migration) | délai de 3 min compté depuis l'envoi, dernière réponse validée gardée pour l'écran de validation |
| T53 | Déverrouiller un champ (PRV-R3) le repasse au statut `valide` : le prochain ré-enrichissement peut le proposer à nouveau | appui long sur le champ, avec confirmation |
| T54 | Ré-enrichir (FIC-09) passe par l'écran de validation, qui montre la valeur actuelle à côté de la valeur proposée ; rien n'est appliqué sans validation | « montre les différences avant de les appliquer » |
| T55 | Nouveau millésime (FIC-08) : même cuvée, cépages et accords repris, photos reprises, aucun lot, commentaire de millésime, degré et garde vides, statut `a_enrichir` | seuls les champs liés au millésime sont à enrichir |

## À compléter

| Id | Sujet | Quand |
| --- | --- | --- |
| Q1 | Valeurs exactes des couleurs Apexus extraites du logo | lot 0 |
| Q2 | Validation des règles de garde par défaut (specs/regles-garde.yaml) | avant la fin du lot 1 |
| Q3 | Vérification des domaines candidats de n8n/sources-autorisees.yaml | lot 2b |
| Q4 | Coût moyen d'un enrichissement en appels au modèle IA | fin du lot 2b |
| Q5 | Publier ou non sur Google Play, compte personnel ou organisation | fin du lot 5 |
