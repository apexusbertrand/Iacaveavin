# Matrice exigences -> tests

Générée par `python3 scripts/matrice_exigences.py`. Ne pas modifier à la main.

| Exigence | Source | Libellé | Tests |
| --- | --- | --- | --- |
| NAV-01 | docs/05 | Tiroir latéral comme sur les captures : Mes vins (accueil), À boire, E | 4 |
| NAV-02 | docs/05 | Lien profond `iacaveavin://fiche/<id>` qui ouvre une fiche (utilisé pa | 1 |
| LST-01 | docs/05 | Tri à deux niveaux (tri 1 puis tri 2), chacun croissant ou décroissant | 4 |
| LST-02 | docs/05 | Tri par couleur dans l'ordre de la liste « couleur » du dictionnaire ( | 1 |
| LST-03 | docs/05 | Groupes repliables quand le tri 1 est groupable (millésime, couleur, p | 1 |
| LST-04 | docs/05 | Tri par note Parker : les vins sans note Parker passent en fin de list | 1 |
| LST-05 | docs/05 | Filtres combinables : stock (en stock : au moins une bouteille ; épuis | 8 |
| LST-06 | docs/05 | Recherche instantanée insensible aux accents et à la casse sur nom, do | 2 |
| LST-07 | docs/05 | Vue cartes et vue compacte (une ligne : pastille couleur, nom, millési | 1 |
| LST-08 | docs/05 | Sélection multiple : PDF, export Excel, déplacer, changer de propriéta | 1 |
| LST-09 | docs/05 | Tri, filtres et vue mémorisés d'une session à l'autre. | 3 |
| LST-10 | docs/05 | Compteur en sous-titre : vins affichés et bouteilles correspondantes. | 1 |
| LST-11 | docs/05 | Sur la tuile d'un vin, le statut de garde est suivi des années avant l | 3 |
| LST-12 | docs/05 | La couleur du vin se lit d'un coup d'œil : pastille ronde de 40 points | 1 |
| FIC-01 | docs/05 | Lecture comme décrit dans docs/03-design-ergonomie.md, mode édition su | 10 |
| FIC-02 | docs/05 | Listes hiérarchiques : choisir l'appellation renseigne la sous-région, | 2 |
| FIC-03 | docs/05 | Onglet Opérations : mouvements du plus récent au plus ancien (type, qu | 2 |
| FIC-04 | docs/05 | Onglet Dégustations : notes personnelles, proposées à chaque ouverture | 1 |
| FIC-05 | docs/05 | Onglet Prix : prix d'achat par lot, courbe des prix marché, dernier pr | 1 |
| FIC-06 | docs/05 | Pastille de provenance par valeur enrichie : source, URL ouvrable, dat | 2 |
| FIC-07 | docs/05 | Les commentaires rédigés par l'agent portent la mention « rédigé par I | 2 |
| FIC-08 | docs/05 | Dupliquer pour un autre millésime : nouvelle fiche sur la même cuvée,  | 1 |
| FIC-09 | docs/05 | Ré-enrichir : relance le flux sur les champs non verrouillés et montre | 1 |
| FIC-10 | docs/05 | Toutes les photos de la bouteille sont visibles : carrousel sur la fic | 1 |
| FIC-11 | docs/05 | Bibliothèque de photos par bouteille, ajoutées à tout moment (dégustat | 3 |
| AJO-01 | docs/05 | Le FAB « + » propose : photo (par défaut), scan du code-barres, saisie | 2 |
| AJO-02 | docs/05 | Prise de vue de 1 à 4 photos (étiquette, contre-étiquette, capsule, co | 3 |
| AJO-03 | docs/05 | Compression locale (1 600 px stockés, 1 500 px envoyés, qualité 80, mi | 2 |
| AJO-04 | docs/05 | Pendant le travail de l'agent, l'utilisateur renseigne le lot : quanti | 1 |
| AJO-05 | docs/05 | Avancement en clair à partir du champ `etape` : lecture de l'étiquette | 6 |
| AJO-06 | docs/05 | Écran de validation : chaque champ proposé avec valeur, source et conf | 2 |
| AJO-07 | docs/05 | Doublon : même domaine, cuvée et millésime déjà en cave, l'app propose | 1 |
| AJO-08 | docs/05 | Enregistrement : fiche, lot, mouvement d'entrée, provenances, notes, p | 4 |
| AJO-09 | docs/05 | Hors ligne ou en erreur : la fiche reste `a_enrichir`, le job part au  | 5 |
| AJO-10 | docs/05 | Le code-barres EAN accompagne les photos comme indice, jamais comme id | 3 |
| AJO-11 | docs/05 | Quota restant affiché (champ `quota` de la réponse) quand il passe sou | 2 |
| AJO-12 | docs/05 | Toute réponse du flux est validée contre specs/contrat-n8n/reponse-job | 9 |
| AJO-13 | docs/05 | Recadrage sur l'étiquette : la lecture du flux renvoie le cadre de l'é | 7 |
| AJO-14 | docs/05 | Millésime lu par l'appareil photo, comme le code-barres : lecture à la | 5 |
| AJO-15 | docs/05 | Validation progressive : dès que l'étiquette est lue, l'écran Identifi | 1 |
| AJO-16 | docs/05 | À la création d'une fiche (photo ou saisie manuelle), la quantité du l | 2 |
| STK-01 | docs/05 | Ajouter ou ouvrir une ou plusieurs bouteilles depuis la fiche. Avec pl | 2 |
| STK-02 | docs/05 | Ouvrir crée un mouvement `ouverture` et propose une note de dégustatio | 2 |
| STK-03 | docs/05 | Correction de stock : l'utilisateur saisit la quantité réelle du lot,  | 2 |
| STK-04 | docs/05 | Mode inventaire : parcours emplacement par emplacement, chaque lot con | 1 |
| STK-05 | docs/05 | Transfert d'emplacement ou de propriétaire, quantité partielle possibl | 1 |
| STK-06 | docs/05 | Une fiche à 0 bouteille reste en base, filtrable « épuisé », réapprovi | 4 |
| STK-07 | docs/05 | Annulation pendant 5 secondes après toute action de stock. | 2 |
| EMP-01 | docs/05 | Arbre paramétrable sur 4 niveaux : cave, meuble, casier, clayette. | 4 |
| EMP-02 | docs/05 | Un casier peut porter une grille (lignes A à Z, colonnes 1 à 50). Les  | 2 |
| EMP-03 | docs/05 | [lot 4] Vue casier : cases occupées teintées de la couleur du vin, cas | 4 |
| EMP-04 | docs/05 | « Où est-il ? » : le chevron de l'emplacement sur la fiche ouvre l'emp | 2 |
| EMP-05 | docs/05 | Taux de remplissage par emplacement, alerte non bloquante au-delà de l | 2 |
| PRO-01 | docs/05 | Liste paramétrable avec un propriétaire par défaut. Chaque lot apparti | 3 |
| PRO-02 | docs/05 | La fiche affiche la répartition (« Bertrand 4, Julie 2 »). | 3 |
| PRO-03 | docs/05 | Filtre, dimension statistique et valeur par propriétaire. | 1 |
| PRO-04 | docs/05 | Notion de gestion, pas de droit d'accès (pas d'authentification en pha | 1 |
| PRX-01 | docs/05 | Prix d'achat saisi à la main par lot, unitaire TTC, dans la devise de  | 2 |
| PRX-02 | docs/05 | Prix marché relevé automatiquement à la création (si `inclure_prix`),  | 3 |
| PRX-03 | docs/05 | Chaque relevé ajoute une ligne d'historique, rien n'est écrasé. Pas pl | 1 |
| PRX-04 | docs/05 | Un prix introuvable est enregistré « non trouvé » avec la date. Jamais | 1 |
| PRX-05 | docs/05 | Affichage : dernier prix, date, nombre d'offres, lien vers chaque offr | 1 |
| PRX-06 | docs/05 | Rafraîchissement automatique mensuel en option, désactivé par défaut. | 1 |
| PRX-07 | docs/05 | Prix à date saisi à la main depuis l'onglet Prix de la fiche (« Saisir | 2 |
| STA-01 | docs/05 | Tableaux prêts à l'emploi : | 2 |
| STA-02 | docs/05 | Explorateur : l'utilisateur choisit une mesure, une dimension, une sec | 4 |
| STA-03 | docs/05 | Seuls les graphiques compatibles sont proposés : donut sur une dimensi | 2 |
| STA-04 | docs/05 | Un tap sur une part ou une barre ouvre la liste filtrée correspondante | 2 |
| STA-05 | docs/05 | Vues enregistrables en favoris, export PNG, PDF et CSV. | 2 |
| STA-06 | docs/05 | Calcul local en moins d'une seconde pour 5 000 fiches. Aucun libellé t | 3 |
| STA-07 | docs/05 | Onglet Garde des statistiques : sous le statut de garde, la priorité d | 2 |
| PDF-01 | docs/05 | Fiche unitaire depuis la fiche vin, A4 portrait. Le fichier partagé po | 2 |
| PDF-02 | docs/05 | Catalogue : 2 fiches par page A4 (moitié haute, moitié basse). Filtres | 2 |
| PDF-03 | docs/05 | Page de garde optionnelle (date, filtres appliqués, nombre de fiches), | 1 |
| PDF-04 | docs/05 | Contenu d'une fiche : champs marqués `pdf: true` dans le dictionnaire, | 2 |
| PDF-05 | docs/05 | Génération hors ligne en arrière-plan avec progression : 200 fiches en | 2 |
| XLS-01 | docs/05 | Export xlsx à 5 onglets : Vins, Lots, Mouvements (lecture seule), List | 3 |
| XLS-02 | docs/05 | Cellules typées : nombres, dates et booléens écrits comme tels, jamais | 1 |
| XLS-03 | docs/05 | Modèle vierge téléchargeable, même format que l'export. | 1 |
| XLS-04 | docs/05 | Import : id rempli = mise à jour, id vide = création, Action = SUPPRIM | 2 |
| XLS-05 | docs/05 | La quantité importée est une quantité cible : l'app crée le mouvement  | 1 |
| XLS-06 | docs/05 | Valeur de liste inconnue : erreur, ou création que l'utilisateur valid | 1 |
| XLS-07 | docs/05 | Simulation obligatoire avant import, avec rapport : créations, mises à | 3 |
| XLS-08 | docs/05 | Sauvegarde automatique avant import, import transactionnel tout ou rie | 1 |
| XLS-09 | docs/05 | Option d'enrichissement des fiches créées, nombre d'appels et quota af | 1 |
| XLS-10 | docs/05 | Photos : colonne nom de fichier et import d'un zip de photos. | 1 |
| PAR-01 | docs/05 | Un écran par liste du dictionnaire (section `listes`) marquée `modifia | 2 |
| PAR-02 | docs/05 | Ajouter, renommer, réordonner, désactiver. Fusionner deux doublons (le | 4 |
| PAR-03 | docs/05 | Listes préchargées depuis app/assets/referentiels/ (docs/04-modele-don | 1 |
| PAR-04 | docs/05 | Import et export de chaque liste en CSV. | 1 |
| PAR-05 | docs/05 | Réglages : ~~adresse du flux n8n et clé secrète (saisie ou QR code, st | 2 |
| PAR-06 | docs/05 | Écran « Règles de garde » en lecture : règles appliquées, avec l'indic | 1 |
| PAR-07 | docs/05 | « Règles de garde » est une entrée du menu principal et l'écran devien | 6 |
| SAV-01 | docs/05 | Export d'une archive zip (base, photos, manifeste avec version de sché | 2 |
| SAV-02 | docs/05 | Variante « sans photos », quelques Mo, proposée par défaut pour les sa | 1 |
| SAV-03 | docs/05 | Sauvegarde locale automatique hebdomadaire, 3 dernières conservées. Ra | 2 |
| SAV-04 | docs/05 | Restauration complète après confirmation, avec migration du schéma si  | 3 |
| SAV-05 | docs/05 | Ne pas compter sur la sauvegarde automatique d'Android : son quota par | 1 |
| CMP-01 | docs/05 | À boire : vins dans leur fenêtre, triés par fin de fenêtre, `a_boire_v | 2 |
| CMP-02 | docs/05 | Alerte mensuelle : vins qui entrent en apogée ou en fin de fenêtre. | 3 |
| CMP-03 | docs/05 | Liste d'achats : vins à racheter (proposé quand une fiche tombe à 0) o | 4 |
| CMP-04 | docs/05 | Accords inversés : je choisis un plat, l'app propose les vins de la ca | 2 |
| CMP-05 | docs/05 | Historique des dégustations : date, plat, note, commentaire. | 3 |
| CMP-06 | docs/05 | Favoris et partage d'une fiche en image ou en PDF. | 1 |
| CMP-07 | docs/05 | [lot 0] Jeu de démonstration de 200 fiches fictives (domaines inventés | 19 |
| CMP-08 | docs/05 | Photos de dégustation : en notant une dégustation, ajout de 6 photos a | 4 |
| CMP-10 | docs/05 | Modifier une dégustation : date, note, plat et commentaire se corrigen | 1 |
| CMP-09 | docs/05 | Vins passés : sur l'écran À boire, un onglet Passés liste à part les v | 2 |
| RET-01 | docs/05 | Formulaire « Remontée d'information » du menu : titre (120 caractères) | 14 |
| CPT-01 | docs/05 | Connexion par code reçu par mail : l'utilisateur saisit son adresse (f | 2 |
| CPT-02 | docs/05 | Le bon code ouvre une session : le flux crée le compte au premier pass | 1 |
| CPT-03 | docs/05 | L'identification par photo, les prix et la remontée exigent un compte  | 5 |
| CPT-04 | docs/05 | Formules : gratuite (10 identifications et 10 relevés de prix par mois | 2 |
| CPT-05 | docs/05 | Supprimer mon compte : bouton du menu Compte, confirmé avant l'envoi.  | 2 |
| CPT-06 | docs/05 | Abonnement : en formule gratuite, boutons « Abonnement mensuel » et «  | 2 |
| CPT-07 | docs/05 | Le compte a son propre menu, à droite, ouvert par l'icône de compte en | 1 |
| NFR-01 | docs/07 | Performance : démarrage à froid sous 2 s, liste fluide à 60 images/s, | - |
| NFR-02 | docs/07 | Performance : PDF, Excel, compression d'images et calculs statistique | - |
| NFR-03 | docs/07 | Hors ligne : tout fonctionne sans réseau sauf l'enrichissement et le | 2 |
| NFR-04 | docs/07 | Photos : répertoire privé de l'app, compression (docs/02-archite | 1 |
| NFR-05 | docs/07 | Données : migrations testées sur une base de la version précédent | 6 |
| NFR-06 | docs/07 | Sécurité : aucun secret dans le code, l'APK ou le dépôt ; clé du f | 2 |
| NFR-07 | docs/07 | Sécurité : les réponses du flux sont validées contre le schéma ava | - |
| NFR-08 | docs/07 | Vie privée : consentement explicite avant le premier envoi de photos | 1 |
| NFR-09 | docs/07 | Vie privée : aucune mesure d'audience, aucun SDK publicitaire ; rapp | - |
| NFR-10 | docs/07 | Accessibilité : contraste WCAG AA sur toutes les paires du thème (test  | 10 |
| NFR-11 | docs/07 | Langues : français par défaut, textes dans des fichiers ARB, angl | 3 |
| NFR-12 | docs/07 | Portabilité : aucune dépendance propre à Android sans équivalent iOS  | - |
| NFR-13 | docs/07 | Tests : tests unitaires sur stock, garde, notes, valeurs, impor | - |
| NFR-14 | docs/07 | Traçabilité : chaque exigence de docs/05-fonctionnel.md est couverte  | 1 |
| NFR-15 | docs/07 | Industrialisation : `flutter analyze` sans avertissement, formatage `dart f | 2 |
| NFR-16 | docs/07 | Contenu IA : tout texte rédigé par l'agent est marqué comme tel (FIC | - |
| NFR-17 | docs/07 | Modération : aucune incitation à boire dans l'app ; mention « L'abus | 1 |
| NFR-18 | docs/07 | Conformité store : l'app publiée ne montre aucun écran « à venir » ni « ar | 3 |
| STK-R1 | docs/04 | Quantité d'un lot = somme de ses mouvements. Jamais de champ quantité  | 3 |
| STK-R2 | docs/04 | Une quantité de lot ne devient jamais négative : le mouvement qui la r | 2 |
| STK-R3 | docs/04 | Stock d'une fiche = somme de ses lots. Bouteilles consommées = somme d | 1 |
| STK-R4 | docs/04 | Un mouvement est immuable. Une erreur se corrige par un mouvement inve | - |
| STK-R5 | docs/04 | Transfert d'une partie d'un lot : création d'un lot cible et de deux m | 1 |
| NOT-R1 | docs/04 | Note Parker affichée = la plus récente des notes de critique « Robert  | 1 |
| NOT-R2 | docs/04 | Meilleure note = maximum des notes ramenées sur 100 (une note sur 20 e | 1 |
| NOT-R3 | docs/04 | Une note « citée » (reprise par un domaine ou un marchand) garde le no | 1 |
| NOT-R4 | docs/04 | Tri par note Parker : les vins sans note Parker passent en fin de list | - |
| VAL-R1 | docs/04 | Valeur d'achat = somme des quantités × prix d'achat unitaire des lots. | 1 |
| VAL-R2 | docs/04 | Valeur marché = somme des quantités × dernier prix marché trouvé pour  | 1 |
| VAL-R3 | docs/04 | Plus-value latente = valeur marché − valeur d'achat, calculée uniqueme | 1 |
| PRV-R1 | docs/04 | Toute valeur proposée par l'agent crée une ligne de provenance au stat | 1 |
| PRV-R2 | docs/04 | L'utilisateur accepte (`valide`), corrige (`manuel`) ou rejette (`reje | 1 |
| PRV-R3 | docs/04 | Déverrouiller un champ est une action explicite sur la fiche (appui lo | 1 |
| PRV-R4 | docs/04 | « Signaler une erreur » sur une valeur enrichie passe `signale` à vrai | 3 |

141 exigences couvertes sur 150.
