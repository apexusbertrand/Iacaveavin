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

- Statut : non démarré
- Exigences : docs/06-agent-n8n.md en entier
- Points d'étape :
- Mesures (taux par champ sur le jeu d'essai, durée moyenne, crédits et appels modèle par enrichissement) :
- Recette Bertrand :

## Lot 2c Branchement réel

- Statut : non démarré
- Exigences : N8nGateway, PAR-05 (connexion), PRX-02 à PRX-06
- Points d'étape :
- Mesures :
- Recette Bertrand :

## Lot 3 Restitution

- Statut : non démarré
- Exigences : STA-01 à STA-06, PDF-01 à PDF-05, XLS-01 à XLS-10
- Points d'étape :
- Mesures :
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
