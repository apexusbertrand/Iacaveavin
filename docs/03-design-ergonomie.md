# 03. Design et ergonomie

Le modèle ergonomique est l'application des captures de docs/reference/ : liste en cartes avec photo d'étiquette, fiche en blocs libellé/valeur, statistiques en graphiques simples. On garde sa structure et sa densité. On remplace son rouge par l'identité Apexus. Les valeurs de couleur, tailles et espacements sont dans specs/design-tokens.json : le thème Flutter est généré depuis ce fichier, aucune couleur en dur dans les widgets.

| Capture | Ce qu'on en reprend |
| --- | --- |
| docs/reference/01-liste.jpeg | barre de titre avec compteur, pastille de filtres, chips de critères, groupes repliables, cartes, FAB, bouton haut de page |
| docs/reference/02-fiche-informations.jpeg | blocs libellé/valeur groupés, chevron vers l'emplacement, barre de proportion des cépages |
| docs/reference/03-fiche-entete.jpeg | en-tête photo + identité, compteurs restantes/consommées, deux grands boutons avec compteur |
| docs/reference/04-statistiques.jpeg | onglets, donut avec pourcentages, barres empilées par millésime et couleur |

## Couleurs et contraste

Le logo Apexus associe un fond noir, un engrenage rouge-orangé et un carré orange. Les valeurs de specs/design-tokens.json sont provisoires : les remplacer par les valeurs exactes du logo haute définition (dossier Images du OneDrive Apexus), puis relancer le test de contraste.

Règles issues des mesures WCAG (détail dans le fichier de jetons) :

- barre supérieure anthracite, titre blanc (17:1) ;
- l'orange de marque sert aux aplats : FAB, bouton principal, chips actives, onglet actif, avec texte et icônes anthracite dessus (6,9:1) ;
- interdit en thème clair : texte blanc sur orange (2,45:1) et orange utilisé comme couleur de texte sur fond clair (2,22:1) ;
- les libellés de la fiche et la région sur les cartes utilisent `primaryTexte`, un orange foncé à 4,55:1 sur la surface claire ;
- thème sombre natif, cohérent avec le fond noir du logo : l'orange de marque y passe en texte (7,6:1).

Les couleurs de vin forment une palette sémantique séparée. Elles ne se confondent pas avec l'orange de marque, en particulier le vin orange et le liquoreux.

Badge de note : couleur selon la note sur 100 (95 et plus or, 90 à 94 vert, 85 à 89 vert clair, moins de 85 gris), suivie de l'initiale de la source (P pour Parker). Une note citée par un tiers porte un petit guillemet.

## Écran liste (capture 01)

- Barre : menu, titre « Mes vins », sous-titre « 170 vins · 412 bouteilles », recherche, menu.
- Bandeau : pastille « 3 filtres actifs » avec réinitialisation, bascule vue cartes / vue compacte.
- Chips des critères actifs, chacune supprimable (« Tri 1 : Millésime (Z-A) », « En stock »), repli « Afficher plus (+1) ».
- Groupes : quand le tri principal est groupable (millésime, couleur, pays, région, propriétaire, emplacement, année d'apogée), en-tête repliable avec nombre de vins, valeur du groupe, nombre de bouteilles.
- Carte : vignette d'étiquette à gauche (un quart de la largeur), nom en gras sur une ligne, région en `primaryTexte` et sous-région, appellation en `secondary`, drapeau, millésime en grand, badge de note, prix, icône bouteille teintée de la couleur du vin et quantité.
- Sur la carte, en plus de la capture : pastille de statut de garde et marqueur « à valider » tant que l'enrichissement n'est pas validé.
- Bouton flottant « Haut de la page » après deux écrans de défilement, FAB « + » pour l'ajout.
- Gestes : glisser vers la gauche ouvre une bouteille (annulable 5 s), appui long lance la sélection multiple.

## Fiche vin (captures 02 et 03)

- Barre : Retour, Modifier, menu (dupliquer pour un autre millésime, ré-enrichir, rafraîchir le prix, PDF, partager, supprimer).
- En-tête : photo principale à gauche (un tap ouvre la galerie plein écran), à droite le nom en capitales, le millésime en gras, le format, la chip couleur, le prix, « 5 restantes » et « 0 consommée » avec accord du pluriel.
- Deux boutons larges : « Ajouter 1 bouteille » et « Ouvrir 1 bouteille », chacun avec son compteur moins/plus.
- Onglets : Informations, Opérations, Dégustations, Prix.
- Informations en cartes groupées, libellé à gauche en `primaryTexte`, valeur à droite.
  - Origine : pays et drapeau, région, sous-région, appellation, signe de qualité, classement, lieu-dit, domaine.
  - Cave : emplacement avec chevron vers la vue casier, positions, propriétaires, garde et statut, degré.
  - Vin : cépages avec barre de proportion, accords mets et vins, notes critiques.
  - Commentaires : domaine, millésime, personnel.
- Pastille de provenance discrète à côté de chaque valeur enrichie. Un tap affiche source, URL, date, confiance, et un bouton « Signaler une erreur ».
- Champ vide : un tiret, comme sur la capture. Un champ vide n'est jamais masqué en mode édition.

## Statistiques (capture 04)

- Onglets : Général, Régions, Garde, Valeur, Aide à l'achat, Explorer.
- Donut avec pourcentages et légende, barres horizontales empilées millésime × couleur.

## Défauts des captures à ne pas reproduire

| Défaut observé | Règle |
| --- | --- |
| Le champ Appellation contient « APPELLATION D'ORIGINE PROTÉGÉE » (capture 02) | appellation, signe de qualité et classement sont trois champs distincts : « Bourgogne Côte d'Or », « AOP », vide |
| Légende « wine_0 » dans les statistiques (capture 04) | tout libellé affiché passe par les traductions, un test échoue si une clé technique apparaît |
| Barres sans valeur (capture 04) | toute barre montre sa valeur en bout de barre ou au tap |
| Libellés rouges sur fond clair | avec l'orange Apexus, ce serait illisible : `primaryTexte` obligatoire |

## Inventaire des états

Chaque écran prévoit ces états, testés en widget test :

| État | Rendu |
| --- | --- |
| Vide | illustration sobre + action, ex. « Aucun vin. Photographiez votre première étiquette. » |
| Chargement | squelettes, jamais d'écran blanc |
| Erreur | message en clair + action (réessayer, voir le détail) |
| Hors ligne | bandeau discret ; les actions réseau passent en file d'attente avec un compteur |
| À valider | marqueur sur la carte et bandeau sur la fiche tant que l'enrichissement n'est pas validé |

## Règles transverses

Material 3, cibles tactiles d'au moins 48 dp, tailles de police dynamiques jusqu'à 200 % sans texte coupé. Listes déroulantes avec recherche dès 10 valeurs. Annulation pendant 5 secondes après toute action de stock. Confirmation demandée uniquement pour les actions destructrices. Libellés accessibles (TalkBack) sur toutes les icônes.
