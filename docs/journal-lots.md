# Journal des lots

Tenu par Claude Code (skill `/lot`). Une section par lot. Bertrand note la recette à la fin de chaque section.

## Lot 0 Socle

- Statut : réalisé, en attente de recette (branche `lot-0-socle`)
- Exigences : NAV-01, CMP-07, NFR-10 (test de contraste), NFR-14 (matrice), NFR-15 (CI)
  - [x] NAV-01 tiroir à 9 entrées, Mes vins en accueil, entrées des lots suivants vers un écran « arrive avec le lot N » (décision T11)
  - [x] CMP-07 jeu de 200 fiches fictives, 8 couleurs, millésimes 2005 à 2024, 3 propriétaires, 8 emplacements, chargement et effacement dans Paramètres (T12, T13)
  - [x] NFR-10 thème clair et sombre générés depuis specs/design-tokens.json ; test de contraste sur 36 paires texte/fond, chips de vin et badges ; police à 200 % ; cibles de 48 dp
  - [x] NFR-14 `scripts/matrice_exigences.py` (matrice, contrôle `--lot N`) et test des identifiants cités
  - [x] NFR-15 CI GitHub Actions : contrat, règles, code généré à jour, format, analyse, tests, matrice, APK de contrôle ; APK signé et release à chaque tag `v*`
  - [x] Socle : base drift alignée sur le dictionnaire (16 tables, test d'alignement), cadre de migrations (schéma v1 figé, NFR-05), référentiels initiaux (T14), écran liste en lecture, À propos avec la mention NFR-17
- Points d'étape :
  - 2026-10-21 fait : tout le périmètre du lot 0. En cours : rien. Bloquant : keystore et secrets GitHub à créer par Bertrand (app/README.md, Signature), puis tag `v0.1.0`. Prochaine étape : recette sur téléphone, puis lot 1.
- Mesures (2026-10-21, environnement de développement, pas le téléphone) :
  - chargement de la démo puis lecture des 200 fiches de la liste : 99 ms (SQLite en mémoire)
  - 131 tests au vert, `flutter analyze` sans aucun message
  - matrice : 5/5 exigences du lot 0 couvertes
  - volumes de photos (docs/02) : non mesurables au lot 0, aucune photo n'est encore prise ; reporté au lot 2a
  - fluidité de la liste et démarrage à froid : à mesurer sur le téléphone de Bertrand (`flutter test integration_test`, rapport `defilement_liste_demo`)
- Recette Bertrand :

## Lot 1 Cave locale

- Statut : réalisé, en attente de recette (branche `lot-1-cave-locale`, démarrée avant la recette du lot 0 à la demande de Bertrand, décision T25)
- Exigences : LST-01 à LST-10, FIC-01 à FIC-05, STK-01 à STK-07, EMP-01, EMP-02, EMP-04, EMP-05, PRO-01 à PRO-04, PRX-01, PAR-01 à PAR-06, SAV-01 à SAV-05, NAV-02
  - [x] LST-01 à LST-10 : tri à deux niveaux, couleur dans l'ordre du dictionnaire, groupes repliables, Parker sans note en fin, filtres combinables, recherche sans accents, vue compacte, sélection multiple (déplacer, changer de propriétaire ; PDF, Excel, enrichissement et prix signalés pour leurs lots), mémorisation, compteur
  - [x] FIC-01 à FIC-05 : fiche en blocs, formulaire complet avec contrôles, listes hiérarchiques avec recherche et ajout, onglets Opérations, Dégustations, Prix (courbe reportée, T37)
  - [x] STK-01 à STK-07 : ajouter ou ouvrir avec choix du lot, dégustation proposée, correction avec motif, inventaire, transfert partiel, réapprovisionnement, annulation 5 s
  - [x] EMP-01, EMP-02, EMP-04, EMP-05 : arbre sur 4 niveaux, grille et positions, « Où est-il ? », remplissage et alerte
  - [x] PRO-01 à PRO-04 : propriétaire par défaut, répartition sur la fiche, filtre et valeur (statistique au lot 3, T38), sans authentification
  - [x] PRX-01 : prix d'achat unitaire TTC par lot
  - [x] PAR-01 à PAR-06 : une page par liste modifiable, ajout, renommage, ordre, désactivation, fusion, suppression protégée, CSV, référentiels, réglages, règles de garde
  - [x] SAV-01 à SAV-05 : archive avec ou sans photos, sauvegarde hebdomadaire, restauration migrée tout ou rien, sauvegarde Android désactivée
  - [x] NAV-02 : lien iacaveavin://fiche/<id> (Android et iOS)
- Points d'étape :
  - 2026-10-21 fait : tout le périmètre du lot 1, 227 tests au vert. En cours : rien. Bloquant : recette du lot 0 puis du lot 1 sur téléphone. Prochaine étape : recette (50 vins réels, restauration sur un autre téléphone, 30 mouvements), puis lot 2a.
- Mesures (2026-10-21, environnement de développement) :
  - matrice : 43/43 exigences du lot 1 couvertes par au moins un test
  - restauration d'une archive de 201 fiches sur une base vide : fiches, lots, mouvements et photos identiques (test SAV-04)
  - stock après mouvements variés (ajout, ouverture, ajustement, transfert, annulation) égal à la somme des mouvements (tests STK)
  - critère de sortie (50 vins réels saisis, archive restaurée sur un autre téléphone, 30 mouvements) : à mesurer par Bertrand
- Recette Bertrand :

## Lot 2a Ajout photo côté app

- Statut : réalisé, en attente de recette (branche `lot-2a-ajout-photo`, issue de `lot-1-cave-locale`, décision T42)
- Exigences : AJO-01 à AJO-12, FIC-06 à FIC-09, PRV-R1 à PRV-R4
  - [x] AJO-01, AJO-02 : jusqu'à 4 photos (appareil ou galerie), compression 1 500 px qualité 80 dans un isolate, alerte flou ou reflet non bloquante (seuils T49)
  - [x] AJO-03, AJO-04 : fiche enregistrée tout de suite « à enrichir » (T43), lot saisi pendant l'attente (T45)
  - [x] AJO-05 : étapes du flux en clair, suivi toutes les 3 s puis 10 s
  - [x] AJO-06, AJO-08 : validation champ par champ (accepter, corriger, rejeter), source et confiance, confiance faible et désaccords surlignés, garde estimée localement si absente
  - [x] AJO-07 : doublon proposé, fusion dans la fiche existante
  - [x] AJO-09, NFR-03 : file d'attente hors ligne, compteur visible, délai de 3 min, relance
  - [x] AJO-10, AJO-11 : EAN et millésime en indices (EAN saisi, T48), quota affiché sous 20 %
  - [x] AJO-12, NFR-07 : réponse validée contre le schéma avant tout enregistrement, sinon erreur et fiche éditable
  - [x] FIC-06 à FIC-09 : pastille de provenance, mention IA, nouveau millésime, ré-enrichissement par l'écran de validation (T54)
  - [x] PRV-R1 à PRV-R4 : provenances proposées, validées, manuelles et verrouillées, déverrouillage par appui long, signalement (envoi au flux reporté, T50)
  - [x] NFR-08 : consentement avant le premier envoi de photos
- Points d'étape :
  - 2026-10-21 fait : tout le périmètre du lot 2a contre `FakeGateway`, migration de la base en v2 (T52). En cours : rien. Bloquant : recette des lots 0, 1 et 2a sur téléphone ; le lot 2b attend l'accès à n8n. Prochaine étape : recette, puis lot 2b dès que l'accès au flux est donné.
- Mesures (2026-10-21, environnement de développement) :
  - matrice : 20/20 exigences du lot 2a couvertes par au moins un test
  - les 7 exemples du contrat rejoués et validés, cas de rejet compris (tests du contrat)
  - parcours photo complet et parcours hors ligne en test de widget
  - critère de sortie (parcours photo complet en mode avion puis au retour du réseau) : à mesurer par Bertrand sur téléphone, scénario du faux flux choisi dans Paramètres (T51)
- Recette Bertrand :

## Lot 2b Flux n8n

- Statut : réalisé, en production sur l'instance n8n, en attente de recette (branche `lot-2b-flux-n8n`, issue de `lot-0-socle`, T56)
- Exigences : docs/06-agent-n8n.md en entier
  - [x] Flux IA_CAVE_Agent (sante, enrichissement, prix, suivi des jobs), IA_CAVE_Enrichissement, IA_CAVE_Prix, IA_CAVE_Erreurs, IA_CAVE_Purge ; tables iacave_*
  - [x] Sécurité : signature HMAC vérifiée, horodatage à 300 s, request_id idempotent, quotas, schéma de la requête
  - [x] Agent : lecture d'étiquette Claude, cache des vins 180 jours, contrôles de sortie, une correction puis erreur, réponse validée avant écriture
  - [x] Prix : cache 24 heures, offres des seules pages lues (T66), médiane par le flux, jamais d'estimation
  - [ ] Jeu d'essai des 30 étiquettes : script prêt (`scripts/jeu_essai.py`), photos à fournir par Bertrand
  - [ ] Sources : robots.txt lus, CGU à lire par Bertrand, aucun domaine actif
- Points d'étape :
  - 2026-10-21 fait : flux publiés et testés en production (enrichissement 17 s, cache 5 s, prix, suivi, refus de signature), données d'essai et clé de développement supprimées. Bloquant : clé `cle_app` et compte Tavily à créer par Bertrand. Prochaine étape : jeu d'essai.
- Mesures (taux par champ sur le jeu d'essai, durée moyenne, crédits et appels modèle par enrichissement) : sans recherche web, 2 appels au modèle, environ 8 000 jetons pour l'agent, 17 s ; avec le cache du vin, 1 appel, 5 s. Jeu d'essai à faire.
- Recette Bertrand :

## Lot 2c Branchement réel

- Statut : réalisé, en attente de recette (branche `lot-2c-branchement-reel`, issue de `lot-2a-ajout-photo` avec le lot 2b fusionné)
- Exigences : N8nGateway, PAR-05 (connexion), PRX-02 à PRX-06
  - [x] N8nGateway : seul client HTTP de l'app, requêtes signées (vecteur fixe testé), 15 s par requête, réponses validées contre le contrat, flux injoignable = job en attente
  - [x] PAR-05 : adresse du flux et clé dans le stockage sécurisé, jamais réaffichée, test de connexion (/sante puis appel signé), oubli de la connexion. Saisie par QR code reportée (T72)
  - [x] PRX-02 : relevé à la création (inclure_prix, lot 2a), sur une fiche, une sélection ou toute la cave avec nombre d'appels et quota avant confirmation
  - [x] PRX-03 : un relevé par fiche et par 24 heures sauf « forcer », historique jamais écrasé
  - [x] PRX-04 : « non trouvé » enregistré avec la date
  - [x] PRX-05 : dernier prix, date, nombre d'offres, lien vers l'offre, tendance, courbe (lien vers chaque offre : T73)
  - [x] PRX-06 : rafraîchissement mensuel au lancement, désactivé par défaut
- Points d'étape :
  - 2026-10-25 fait : périmètre du lot. Bloquant : clé `cle_app` à saisir dans n8n et dans l'app par Bertrand ; sans elle l'app reste sur le flux de démonstration. Prochaine étape : recette sur téléphone (20 bouteilles par photo).
- Mesures : à faire sur téléphone avec le vrai flux.
- Recette Bertrand :
  - 2026-10-26, premiers essais sur téléphone avec le vrai flux. Retours traités le jour même :
    - bug 1 (fiche à 0 bouteille absente de la liste) : corrigé, T78 ;
    - évolution 1 (fournisseur retiré, « Enregistrer » toujours visible) : T79 ;
    - évolution 2 (accords mets-vins toujours proposés) : flux Enrichissement republié, T80 et T81 ;
    - évolution 3 (code-barres par l'appareil photo ou une photo) : T82 ;
    - évolution 4 (résultat enregistré même à 0 bouteille) : la validation n'exige aucun lot, la fiche reste visible (T78), et une fiche sans domaine lisible prend le nom de sa cuvée (T83).
  - Constat : la recherche web échoue (« erreur d'authentification des outils »). La valeur rangée dans `tavily_cle` ne commence pas par `tvly-` : ce n'est pas une clé Tavily. À recoller par Bertrand.
  - 2026-10-26, second retour (évolutions 1, 1 bis et 2), traité le jour même :
    - évolution 2 (recherche web générale sans intermédiaire) : Tavily retiré, recherche intégrée de Claude dans les flux Enrichissement et Prix, sources refaites à partir des URL vues ; les trois flux sont republiés, /sante répond en contrat 1.1 (T85). Le commentaire de millésime et les accords obtenus avant ce changement venaient de la mémoire du modèle, pas d'une recherche ;
    - évolution 1 (recadrage sur l'étiquette, toutes les photos visibles) : cadre renvoyé par la lecture vision (contrat 1.1, T86), photo rognée à la réception, entière si aucune étiquette n'est identifiable, retouche ou retour à la photo entière à l'écran de validation, photo d'origine supprimée à la validation (AJO-13, T87) ; carrousel et plein écran de toutes les photos sur la fiche (FIC-10) ;
    - évolution 1 bis (bibliothèque de photos par bouteille) : onglet Photos de la fiche, photos de dégustation, de repas ou d'événement, jamais envoyées au flux (FIC-11, T88). Base en version 3 (colonnes `chemin_original` et `cadre` de photo).

## Lot 3 Restitution

- Statut : réalisé, en attente de recette (branche `lot-3-restitution`, issue de `lot-2c-branchement-reel` sans attendre la recette du lot 2, accord de Bertrand du 2026-10-27)
- Exigences :
  - [x] XLS-01 : export à 5 onglets (Vins, Lots, Mouvements, Listes, Notice), colonnes et ordre du dictionnaire, test d'alignement
  - [x] XLS-02 : nombres, dates et booléens écrits typés, jamais en texte
  - [x] XLS-03 : modèle vierge au même format
  - [x] XLS-04 : id rempli = mise à jour, id vide = création, Action SUPPRIMER = suppression logique, colonnes RO ignorées
  - [x] XLS-05 : quantité cible, mouvement d'ajustement de l'écart, motif « import Excel »
  - [x] XLS-06 : valeur de liste inconnue en erreur, ou créée en bloc après accord
  - [x] XLS-07 : simulation obligatoire, rapport par ligne, colonne et motif
  - [x] XLS-08 : sauvegarde automatique avant import, transaction tout ou rien
  - [x] XLS-09 : enrichissement des fiches créées avec photo, nombre d'appels et quota affichés
  - [x] XLS-10 : zip de photos rattachées par le nom de la colonne Photo principale (T90)
  - [x] PDF-01 : fiche unitaire A4 depuis le menu de la fiche
  - [x] PDF-02 : catalogue 2 fiches par page, filtres et tri de la liste repris et modifiables
  - [x] PDF-03 : page de garde (date, filtres, nombre de fiches), numéros de page
  - [x] PDF-04 : champs pdf du dictionnaire, photo, QR code iacaveavin://fiche/<id>, date d'édition, commentaires coupés à la phrase
  - [x] PDF-05 : génération dans un isolate avec progression, partage
  - [x] STA-01 : onglets Général, Régions (zoom pays, région, appellation), Garde, Valeur, Aide à l'achat
  - [x] STA-02 : explorateur (9 mesures, 20 dimensions, seconde dimension, filtres, 7 graphiques)
  - [x] STA-03 : graphiques compatibles seulement, donut à 8 parts au plus avec « Autres »
  - [x] STA-04 : un tap sur une part, une barre ou une ligne de légende ouvre la liste de ses vins
  - [x] STA-05 : favoris, export PNG, PDF et CSV
  - [x] STA-06 : calcul local, libellés en clair
- Points d'étape :
  - 2026-10-27 fait : tout le périmètre du lot, testé (au moins un test par exigence, 26 nouveaux tests). Dépendances pdf, xml et fl_chart ; le paquet excel est écarté (T89). En cours : rien. Bloquant : recette sur téléphone. Prochaine étape : APK de la pull request, recette de Bertrand.
- Mesures (poste de développement, à refaire sur téléphone pendant la recette) :
  - aller-retour Excel : 565 lignes (260 fiches et 305 lots), aucun écart, simulation et import en 2,6 s ;
  - catalogue PDF : 200 fiches avec photo en 8 à 9 s, cible 30 s ;
  - statistiques : 5 000 fiches lues et agrégées en 0,56 s, cible 1 s ; agrégation seule de toutes les mesures en moins de 0,1 s.
- Recette Bertrand :

## Lot 4 Confort

- Statut : non démarré
- Exigences : CMP-01 à CMP-06, EMP-03
- Points d'étape :
- Mesures :
- Recette Bertrand :

## Lot 5 Recette élargie

- Statut : non démarré
- Exigences : NFR-01 à NFR-17 mesurées, recette transverse de docs/08-lots-recette.md
- Points d'étape :
- Mesures :
- Recette Bertrand et décision de publication :
