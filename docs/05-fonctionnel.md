# 05. Spécifications fonctionnelles

Chaque exigence porte un identifiant stable (LST-01, AJO-04...). Les tests, les commits et la recette s'y réfèrent : un test se nomme d'après l'exigence qu'il couvre, par exemple `test('LST-04 tri Parker : vins sans note en fin de liste', ...)`. Une exigence retirée garde son identifiant, barré, pour ne pas casser la traçabilité.

Lot de livraison entre crochets. Détail des lots : docs/08-lots-recette.md.

## NAV. Navigation [lot 1]

- NAV-01. Tiroir latéral comme sur les captures : Mes vins (accueil), À boire, Emplacements, Statistiques, Liste d'achats, Import et export, Sauvegarde, Paramètres, À propos.
- NAV-02. Lien profond `iacaveavin://fiche/<id>` qui ouvre une fiche (utilisé par le QR code des PDF).

## LST. Liste des vins [lot 1]

- LST-01. Tri à deux niveaux (tri 1 puis tri 2), chacun croissant ou décroissant. Critères : millésime, couleur, note Parker, meilleure note toutes sources, nom, domaine, pays, région, appellation, propriétaire, emplacement, prix d'achat, valeur marché, quantité, date d'ajout, début et fin de garde, statut de garde.
- LST-02. Tri par couleur dans l'ordre de la liste « couleur » du dictionnaire (rouge, blanc, rosé, champagne, effervescent, liquoreux, orange, autre), pas dans l'ordre alphabétique.
- LST-03. Groupes repliables quand le tri 1 est groupable (millésime, couleur, pays, région, propriétaire, emplacement, année d'apogée), avec nombre de vins et de bouteilles.
- LST-04. Tri par note Parker : les vins sans note Parker passent en fin de liste, quel que soit le sens (NOT-R4).
- LST-05. Filtres combinables : stock (en stock, épuisé, tous), couleur, type, pays, région, appellation, plage de millésimes, propriétaire, emplacement avec ses sous-emplacements, statut de garde, année de consommation idéale, note minimale, plage de prix, cépage, statut d'enrichissement, favoris.
- LST-06. Recherche instantanée insensible aux accents et à la casse sur nom, domaine, appellation, lieu-dit, cépage et commentaires.
- LST-07. Vue cartes et vue compacte (une ligne : pastille couleur, nom, millésime, quantité).
- LST-08. Sélection multiple : PDF, export Excel, déplacer, changer de propriétaire, ré-enrichir, rafraîchir les prix.
- LST-09. Tri, filtres et vue mémorisés d'une session à l'autre.
- LST-10. Compteur en sous-titre : vins affichés et bouteilles correspondantes.

## FIC. Fiche vin [lot 1]

- FIC-01. Lecture comme décrit dans docs/03-design-ergonomie.md, mode édition sur tous les champs.
- FIC-02. Listes hiérarchiques : choisir l'appellation renseigne la sous-région, la région et le pays. Une valeur absente peut être ajoutée à la liste depuis le formulaire.
- FIC-03. Onglet Opérations : mouvements du plus récent au plus ancien (type, quantité, lot, motif, date).
- FIC-04. Onglet Dégustations : notes personnelles, proposées à chaque ouverture, jamais imposées.
- FIC-05. Onglet Prix : prix d'achat par lot, courbe des prix marché, dernier prix et sa date, bouton Rafraîchir.
- FIC-06. Pastille de provenance par valeur enrichie : source, URL ouvrable, date, confiance, « Signaler une erreur » (PRV-R4).
- FIC-07. Les commentaires rédigés par l'agent portent la mention « rédigé par IA à partir de [site] ».
- FIC-08. Dupliquer pour un autre millésime : nouvelle fiche sur la même cuvée, seuls les champs liés au millésime sont à enrichir.
- FIC-09. Ré-enrichir : relance le flux sur les champs non verrouillés et montre les différences avant de les appliquer.
- FIC-10. Toutes les photos de la bouteille sont visibles : carrousel sur la fiche, plein écran avec zoom et balayage d'une photo à l'autre (2026-10-26, évolution 1).
- FIC-11. Bibliothèque de photos par bouteille, ajoutées à tout moment (dégustation, repas, événement) depuis l'appareil photo ou la galerie, supprimables. Ces photos ne sont jamais envoyées au flux et ne deviennent pas la photo principale (2026-10-26, évolution 1 bis, T88). Elles sont dans l'onglet Dégustations et photos de la fiche, sous les dégustations ; une photo prise en notant une dégustation s'affiche sous celle-ci et n'est pas répétée (2026-10-28, T120).

## AJO. Ajout d'une bouteille par photo [lot 2a côté app, 2b côté n8n]

Cible : moins de 30 secondes de saisie active pour un vin courant.

- AJO-01. Le FAB « + » propose : photo (par défaut), scan du code-barres, saisie manuelle, import Excel.
- AJO-02. Prise de vue de 1 à 4 photos (étiquette, contre-étiquette, capsule, collerette) avec guide de cadrage. Détection de flou et de reflet, invitation à reprendre. Import depuis la galerie possible.
- AJO-03. Compression locale (1 600 px stockés, 1 500 px envoyés, qualité 80, miniature 320 px) et enregistrement immédiat de la fiche en `a_enrichir`.
- AJO-04. Pendant le travail de l'agent, l'utilisateur renseigne le lot : quantité, format, prix d'achat, date, propriétaire, emplacement, valeurs par défaut pré-remplies. Le fournisseur n'est plus saisi (2026-10-26, T79). Le lot reste facultatif : la fiche s'enregistre même à 0 bouteille (T78).
- AJO-05. Avancement en clair à partir du champ `etape` : lecture de l'étiquette, identification, enrichissement, notes, prix.
- AJO-06. Écran de validation : chaque champ proposé avec valeur, source et confiance. Confiance sous 0,6 surlignée. Tout accepter, ou accepter, modifier, rejeter champ par champ. Un désaccord étiquette/source s'affiche côte à côte (alerte `desaccord_etiquette_source`).
- AJO-07. Doublon : même domaine, cuvée et millésime déjà en cave, l'app propose d'ajouter un lot à la fiche existante.
- AJO-08. Enregistrement : fiche, lot, mouvement d'entrée, provenances, notes, prix.
- AJO-09. Hors ligne ou en erreur : la fiche reste `a_enrichir`, le job part au retour du réseau, une notification signale la fin. Sans réponse en 3 minutes : `erreur`, relance possible.
- AJO-10. Le code-barres EAN accompagne les photos comme indice, jamais comme identifiant (certains producteurs gardent le même EAN d'un millésime à l'autre).
- AJO-11. Quota restant affiché (champ `quota` de la réponse) quand il passe sous 20 %.
- AJO-12. Toute réponse du flux est validée contre specs/contrat-n8n/reponse-job.schema.json. Une réponse invalide est traitée comme une erreur, journalisée, et la fiche reste éditable à la main.
- AJO-13. Recadrage sur l'étiquette : la lecture du flux renvoie le cadre de l'étiquette de chaque photo (contrat 1.1) ; l'app rogne la photo à la réception, garde la photo entière quand aucune étiquette n'est identifiable, et permet de retoucher le cadre ou de revenir à la photo entière à l'écran de validation. La photo d'origine est conservée jusqu'à la validation de la fiche, puis supprimée (2026-10-26, évolution 1, T86, T87).
- AJO-14. Millésime lu par l'appareil photo, comme le code-barres : lecture à la volée dans un viseur (la même année lue seule sur deux images de suite) ou sur une photo de la galerie. Lecture sur le téléphone, sans réseau. Les dates de fondation (« depuis 1919 ») sont écartées. Le champ reste modifiable (2026-10-28, T116).
- AJO-15. Validation progressive : dès que l'étiquette est lue, l'écran Identification passe seul à l'écran de validation, rempli avec la lecture ; les champs trouvés par le serveur s'y ajoutent à chaque retour du flux. On peut corriger ou rejeter un champ pendant l'attente ; l'enregistrement s'ouvre à la fin de la recherche. Le lot se saisit sur le même écran tant qu'il n'existe pas. En cas d'échec, la lecture reste affichée avec une relance (2026-10-28, T117).

## STK. Stock et corrections [lot 1]

- STK-01. Ajouter ou ouvrir une ou plusieurs bouteilles depuis la fiche. Avec plusieurs lots, l'app demande lequel et propose le dernier utilisé.
- STK-02. Ouvrir crée un mouvement `ouverture` et propose une note de dégustation.
- STK-03. Correction de stock : l'utilisateur saisit la quantité réelle du lot, l'app crée un mouvement `ajustement` de l'écart avec motif obligatoire (inventaire, erreur de saisie, casse, offert, autre).
- STK-04. Mode inventaire : parcours emplacement par emplacement, chaque lot confirmé ou corrigé, rapport final des écarts.
- STK-05. Transfert d'emplacement ou de propriétaire, quantité partielle possible (STK-R5).
- STK-06. Une fiche à 0 bouteille reste en base, filtrable « épuisé », réapprovisionnable en un tap.
- STK-07. Annulation pendant 5 secondes après toute action de stock.

## EMP. Emplacements [lot 1, vue casier au lot 4]

- EMP-01. Arbre paramétrable sur 4 niveaux : cave, meuble, casier, clayette.
- EMP-02. Un casier peut porter une grille (lignes A à Z, colonnes 1 à 50). Les positions d'un lot sont des cellules (A3, B5).
- EMP-03. [lot 4] Vue casier : cases occupées teintées de la couleur du vin, cases vides grises. Un tap ouvre la fiche, un appui long sur une case vide range une bouteille.
- EMP-04. « Où est-il ? » : le chevron de l'emplacement sur la fiche ouvre l'emplacement, cases du vin en surbrillance.
- EMP-05. Taux de remplissage par emplacement, alerte non bloquante au-delà de la capacité.

## PRO. Propriétaires [lot 1]

- PRO-01. Liste paramétrable avec un propriétaire par défaut. Chaque lot appartient à un propriétaire.
- PRO-02. La fiche affiche la répartition (« Bertrand 4, Julie 2 »).
- PRO-03. Filtre, dimension statistique et valeur par propriétaire.
- PRO-04. Notion de gestion, pas de droit d'accès (pas d'authentification en phase 1).

## PRX. Prix [lot 1 pour l'achat, lot 2 pour le marché]

- PRX-01. Prix d'achat saisi à la main par lot, unitaire TTC, dans la devise de la cave.
- PRX-02. Prix marché relevé automatiquement à la création (si `inclure_prix`), puis sur demande pour une fiche, une sélection ou toute la cave. Pour la cave entière, l'app affiche le nombre d'appels et le quota restant avant de demander confirmation.
- PRX-03. Chaque relevé ajoute une ligne d'historique, rien n'est écrasé. Pas plus d'un relevé par fiche et par 24 heures, sauf « forcer ».
- PRX-04. Un prix introuvable est enregistré « non trouvé » avec la date. Jamais d'estimation présentée comme un prix.
- PRX-05. Affichage : dernier prix, date, nombre d'offres, lien vers chaque offre, tendance par rapport au relevé précédent, courbe.
- PRX-06. Rafraîchissement automatique mensuel en option, désactivé par défaut.

## STA. Statistiques façon BI [lot 3]

- STA-01. Tableaux prêts à l'emploi :

| Onglet | Contenu |
| --- | --- |
| Général | indicateurs (bouteilles, références, valeur d'achat, valeur marché), donut par couleur, barres millésime × couleur |
| Régions | bouteilles par pays puis région, zoom jusqu'à l'appellation |
| Garde | bouteilles par année d'entrée dans la fenêtre, à boire cette année, à boire vite, passées |
| Valeur | achat contre marché par couleur et région, évolution de la valeur marché |
| Aide à l'achat | ouvertures des 12 derniers mois contre stock, mois de stock restant par couleur et région |

- STA-02. Explorateur : l'utilisateur choisit une mesure, une dimension, une seconde dimension facultative, des filtres et un type de graphique.
  - Mesures : nombre de bouteilles, nombre de références, valeur d'achat, valeur marché, plus-value latente, prix moyen, note moyenne, bouteilles ouvertes sur une période, années moyennes avant de boire.
  - Dimensions : couleur, type, pays, région, sous-région, appellation, domaine, millésime, tranche de 5 millésimes, cépage principal, propriétaire, emplacement, statut de garde, année de début de garde, année d'apogée, tranche de note, tranche de prix, fournisseur, mois d'achat, mois d'ouverture.
  - Graphiques : donut, barres verticales, barres horizontales, barres empilées, courbe, tableau croisé, indicateur seul.
- STA-03. Seuls les graphiques compatibles sont proposés : donut sur une dimension et 8 parts au plus (le reste en « Autres »), courbe sur une dimension ordonnée (millésime, années, mois), empilé et tableau croisé sur deux dimensions.
- STA-04. Un tap sur une part ou une barre ouvre la liste filtrée correspondante.
- STA-05. Vues enregistrables en favoris, export PNG, PDF et CSV.
- STA-06. Calcul local en moins d'une seconde pour 5 000 fiches. Aucun libellé technique affiché.

## PDF [lot 3]

- PDF-01. Fiche unitaire depuis la fiche vin, A4 portrait. Le fichier partagé porte le nom du vin, « Domaine - Cuvée - Millésime.pdf », comme l'image de CMP-06 (2026-10-28, T115).
- PDF-02. Catalogue : 2 fiches par page A4 (moitié haute, moitié basse). Filtres optionnels : millésime, couleur, région, pays, année de consommation idéale, propriétaire, emplacement, en stock seulement. Tri au choix.
- PDF-03. Page de garde optionnelle (date, filtres appliqués, nombre de fiches), numéros de page.
- PDF-04. Contenu d'une fiche : champs marqués `pdf: true` dans le dictionnaire, photo d'étiquette, QR code vers la fiche, date d'édition. Commentaires tronqués à la phrase entière la plus proche.
- PDF-05. Génération hors ligne en arrière-plan avec progression : 200 fiches en moins de 30 secondes. Partage par la feuille de partage du système.

## XLS. Excel [lot 3]

- XLS-01. Export xlsx à 5 onglets : Vins, Lots, Mouvements (lecture seule), Listes (valeurs autorisées), Notice (règles d'import). Colonnes = clés `excel` du dictionnaire, dans l'ordre du dictionnaire.
- XLS-02. Cellules typées : nombres, dates et booléens écrits comme tels, jamais comme du texte (pas de problème de virgule décimale à l'ouverture dans un Excel français).
- XLS-03. Modèle vierge téléchargeable, même format que l'export.
- XLS-04. Import : id rempli = mise à jour, id vide = création, Action = SUPPRIMER = suppression logique. Colonnes `RO:` ignorées.
- XLS-05. La quantité importée est une quantité cible : l'app crée le mouvement d'ajustement de l'écart, motif « import Excel ».
- XLS-06. Valeur de liste inconnue : erreur, ou création que l'utilisateur valide en bloc.
- XLS-07. Simulation obligatoire avant import, avec rapport : créations, mises à jour, suppressions, erreurs par ligne, colonne et motif.
- XLS-08. Sauvegarde automatique avant import, import transactionnel tout ou rien.
- XLS-09. Option d'enrichissement des fiches créées, nombre d'appels et quota affichés avant lancement.
- XLS-10. Photos : colonne nom de fichier et import d'un zip de photos.

## PAR. Paramétrage [lot 1]

- PAR-01. Un écran par liste du dictionnaire (section `listes`) marquée `modifiable`.
- PAR-02. Ajouter, renommer, réordonner, désactiver. Fusionner deux doublons (les fiches sont re-pointées). Suppression interdite pour une valeur utilisée.
- PAR-03. Listes préchargées depuis app/assets/referentiels/ (docs/04-modele-donnees.md).
- PAR-04. Import et export de chaque liste en CSV.
- PAR-05. Réglages : adresse du flux n8n et clé secrète (saisie ou QR code, stockage sécurisé, jamais affichée en clair), test de connexion (`/sante`), devise, langue, thème, propriétaire et emplacement par défaut, tri par défaut, échelle de note perso (/20 ou /100), prix affiché sur les cartes (achat ou marché), notifications, rafraîchissement automatique des prix, espace occupé par les photos.
- PAR-06. Écran « Règles de garde » en lecture : règles appliquées, avec l'indication « valeurs par défaut à valider » tant que `a_valider` est vrai.

## SAV. Sauvegarde et restauration [lot 1]

- SAV-01. Export d'une archive zip (base, photos, manifeste avec version de schéma et date) vers la feuille de partage : Drive, mail, PC.
- SAV-02. Variante « sans photos », quelques Mo, proposée par défaut pour les sauvegardes fréquentes.
- SAV-03. Sauvegarde locale automatique hebdomadaire, 3 dernières conservées. Rappel si aucun export externe depuis 30 jours.
- SAV-04. Restauration complète après confirmation, avec migration du schéma si l'archive est plus ancienne.
- SAV-05. Ne pas compter sur la sauvegarde automatique d'Android : son quota par application est trop faible pour les photos.

## CMP. Confort [lot 4]

- CMP-01. À boire : vins dans leur fenêtre, triés par fin de fenêtre, `a_boire_vite` en tête.
- CMP-02. Alerte mensuelle : vins qui entrent en apogée ou en fin de fenêtre.
- CMP-03. Liste d'achats : vins à racheter (proposé quand une fiche tombe à 0) ou repérés ailleurs.
- CMP-04. Accords inversés : je choisis un plat, l'app propose les vins de la cave compatibles et à boire.
- CMP-05. Historique des dégustations : date, plat, note, commentaire.
- CMP-06. Favoris et partage d'une fiche en image ou en PDF.
- CMP-07. [lot 0] Jeu de démonstration de 200 fiches fictives (domaines inventés, toutes couleurs, millésimes 2005 à 2024, plusieurs propriétaires et emplacements), activable et effaçable dans les Réglages. Il sert aux tests de performance et aux captures.
- CMP-08. Photos de dégustation : en notant une dégustation, ajout de 6 photos au plus (appareil ou galerie), ramenées à la taille d'un écran de smartphone (1 080 × 1 920 au plus), rattachées à la dégustation, visibles dans son historique et dans la bibliothèque de la bouteille, jamais envoyées au flux (2026-10-28, T114).
- CMP-09. Vins passés : sur l'écran À boire, un onglet Passés liste à part les vins en stock dont la fenêtre de garde est dépassée (année en cours après la fin de garde), fin la plus ancienne en tête. Ils n'apparaissent ni dans l'onglet À boire ni dans les accords inversés (2026-10-28, T121).

## RET. Remontée d'information [lot 4]

- RET-01. Formulaire « Remontée d'information » du menu : titre (120 caractères), commentaire (5 000 caractères) et adresse mail de contact, tous obligatoires, adresse au format contrôlé (exemple : prenom.nom@exemple.fr). Une pièce jointe au plus, PDF ou image (JPEG, PNG, WebP), type vérifié sur le contenu du fichier et non sur l'extension, 5 Mo au plus ; une image est ramenée à la taille d'un écran (CMP-08) et envoyée en JPEG. L'envoi passe par le flux (POST /remontee, contrat 1.3) : mail à apexus.claude@gmail.com, copie à l'adresse de contact, réponse à cette adresse. 5 envois par jour et par installation. Hors ligne ou en erreur, la saisie reste à l'écran. Rien n'est enregistré sur le téléphone (2026-10-28, T118).
