# Fiche Google Play : IA cave à vin 1.0.0

Textes à coller dans la Play Console, dans l'ordre des rubriques. Décisions T123 et T124 (docs/decisions.md). Captures, icône et bannière : dossier store/ à côté de ce fichier.

## Identité

| Champ | Valeur |
| --- | --- |
| Nom de package | fr.apexus.iacaveavin |
| Nom de l'application (30 caractères max) | IA cave à vin |
| Langue par défaut | Français (France) – fr-FR |
| Application ou jeu | Application |
| Gratuite ou payante | Gratuite |
| Catégorie | Alimentation et boissons |
| Adresse e-mail de contact | apexus.claude@gmail.com (à confirmer par Bertrand) |
| Site web | https://apexus.fr (à confirmer) |
| Politique de confidentialité | URL de la page publiée à partir de politique-confidentialite.html, par exemple https://apexus.fr/iacaveavin/confidentialite |

## Description courte (80 caractères max, ici 72)

```
Votre cave à vin dans la poche : étiquette photographiée, fiche remplie.
```

## Description longue (4 000 caractères max, ici environ 2 600)

```
IA cave à vin tient l'inventaire de votre cave, bouteille par bouteille, et vous dit quoi ouvrir et quand.

PHOTOGRAPHIEZ L'ÉTIQUETTE
Prenez la bouteille en photo : domaine, cuvée, appellation, millésime, couleur, degré et volume sont lus sur l'étiquette. Le service d'identification complète ensuite la fiche avec les cépages, la fenêtre de garde, les accords mets et vins et les commentaires du domaine. Chaque valeur trouvée cite sa source : rien n'est inventé, une information introuvable reste vide. Vous validez ou corrigez chaque champ, et une saisie faite à la main n'est jamais écrasée.
Le code-barres et le millésime se lisent aussi à la volée avec l'appareil photo, sans réseau.

GÉREZ VOTRE STOCK
- Lots par format, propriétaire, emplacement et prix d'achat.
- Entrées, ouvertures, transferts et corrections d'inventaire, tous datés et motivés.
- Emplacements en arborescence : cave, armoire, casier avec vue en grille, clayette.
- Plusieurs propriétaires dans la même cave.

SACHEZ QUOI BOIRE
- Écran « À boire » : vins dans leur fenêtre de garde, ceux à boire vite en tête.
- Onglet « Passés » : les bouteilles qui ont dépassé leur fenêtre, à part.
- Alerte du mois : vins qui entrent en apogée ou arrivent en fin de fenêtre.
- Accords inversés : choisissez un plat, l'application propose les vins de votre cave.

DÉGUSTEZ ET PARTAGEZ
- Historique des dégustations avec note, plat, commentaire et photos.
- Fiche du vin en PDF ou en image, nommée d'après le vin.
- Liste d'achats pour racheter un vin ou noter un vin repéré ailleurs.

ANALYSEZ
- Statistiques : bouteilles par couleur, région, millésime et garde, valeur d'achat de la cave.
- Catalogue PDF de toute la cave.
- Export et import Excel avec simulation avant import.

VOS DONNÉES RESTENT CHEZ VOUS
La cave vit sur votre téléphone et fonctionne hors ligne : liste, fiches, stock, statistiques, PDF et Excel. Ni compte, ni publicité, ni mesure d'audience. Seules les photos d'étiquettes partent au service d'identification, après votre accord, et elles y sont effacées dès la fiche remplie. Sauvegarde et restauration complètes en un fichier.

À SAVOIR
L'identification par photo et le relevé des prix passent par un service en ligne d'Apexus, ouvert sur invitation pendant cette première version : l'adresse et la clé se saisissent dans les Paramètres. Sans elles, toute la gestion de cave fonctionne et les fiches restent « à enrichir » jusqu'à la connexion.

Application réservée aux personnes majeures. Elle ne vend pas d'alcool.
L'abus d'alcool est dangereux pour la santé, à consommer avec modération.
```

## Notes de version 1.0.0 (500 caractères max, ici 350)

```
Première version publiée.
- Ajout d'une bouteille par photo de l'étiquette, fiche complétée avec ses sources.
- Stock par lots, emplacements, propriétaires, dégustations avec photos.
- À boire, vins passés, alerte du mois, accords inversés.
- Statistiques, PDF, export et import Excel, sauvegarde.
- Formulaire de remontée d'information dans le menu.
```

## Éléments graphiques

| Élément | Fichier | Format exigé |
| --- | --- | --- |
| Icône | icone-512.png | 512 × 512, PNG |
| Image de présentation | banniere-1024x500.png | 1024 × 500, PNG ou JPEG |
| Captures téléphone (2 à 8) | captures/01 à 05 | 1080 × 1920, 9:16 |

Les captures viennent des vrais écrans avec le jeu de démonstration (domaines inventés). Pour les refaire : `flutter test --update-goldens tool/store/captures_test.dart` depuis app/.

## Accès à l'application (Contenu de l'application > Accès)

Choisir « Toutes les fonctionnalités ou certaines d'entre elles sont soumises à restriction », puis :

```
La gestion de cave (liste, fiches, stock, emplacements, statistiques, PDF, Excel, sauvegarde) est accessible sans aucun identifiant.
L'identification par photo et le relevé des prix utilisent un service en ligne réservé aux testeurs : Paramètres > Connexion au flux d'enrichissement, saisir l'adresse et la clé secrète ci-dessous, puis « Tester la connexion ».
Adresse : https://apexus.app.n8n.cloud
Clé : [clé dédiée à l'examen Google, à créer par Bertrand]
```

Point à trancher par Bertrand : donner la clé partagée à Google expose cette clé. Le mieux est une clé dédiée à l'examen, révoquée ensuite. Cela demande une évolution du flux (plusieurs clés acceptées), non faite à ce jour.

## Annonces

Non, l'application ne contient pas d'annonces.

## Public cible et contenu

| Question | Réponse |
| --- | --- |
| Tranches d'âge ciblées | 18 ans et plus uniquement |
| Attire les enfants | Non |

## Classification du contenu (questionnaire IARC)

Catégorie : « Toutes les autres catégories d'applications » (ni jeu, ni réseau social).

| Question | Réponse |
| --- | --- |
| Violence, peur, sexualité, langage grossier | Non |
| Substances contrôlées : références à l'alcool | Oui (l'application gère une cave à vin) |
| Vente d'alcool ou incitation à consommer | Non |
| Jeux d'argent, simulés ou réels | Non |
| Contenu généré par les utilisateurs partagé avec d'autres | Non (rien n'est publié ni partagé entre utilisateurs) |
| Partage de la position | Non |
| Achats numériques | Non |
| Navigateur web ou moteur de recherche non restreint | Non |

## Sécurité des données (Data safety)

Réponses générales :

| Question | Réponse |
| --- | --- |
| L'application collecte ou partage-t-elle des données ? | Oui |
| Données chiffrées en transit | Oui (HTTPS uniquement) |
| Les utilisateurs peuvent demander la suppression | Oui, par mail à l'adresse de contact ; la cave elle-même est sur le téléphone et s'efface en désinstallant l'application |
| Partage avec des tiers | Non. Les prestataires qui traitent pour le compte d'Apexus (hébergeur n8n, modèle d'IA Anthropic, Gmail pour l'envoi des remontées) ne comptent pas comme partage au sens de Google |

Données collectées (toutes facultatives, aucune n'est partagée) :

| Type Google | Donnée réelle | Traitement éphémère | Finalités |
| --- | --- | --- | --- |
| Photos et vidéos > Photos | photos d'étiquettes envoyées pour l'identification, après consentement | Oui : gardées en mémoire le temps du traitement, jamais écrites | Fonctionnalités de l'application |
| Contenus générés par l'utilisateur > Autres | indices saisis (texte libre, code-barres, millésime), valeurs signalées comme fausses | Non (requête gardée 90 jours, signalements 24 mois) | Fonctionnalités de l'application |
| Informations personnelles > Adresse e-mail | adresse de contact saisie dans le formulaire de remontée | Non (journal 30 jours, mail dans la boîte de l'équipe) | Communications du développeur |
| Messages > Autres messages in-app | titre, commentaire et pièce jointe d'une remontée | Non (mail dans la boîte de l'équipe) | Communications du développeur |
| Identifiants de l'appareil ou autres | identifiant d'installation aléatoire, généré par l'application | Non (90 jours avec chaque requête) | Fonctionnalités de l'application, sécurité, prévention des fraudes (quotas) |

Non collectés : position, contacts, identité, données financières, santé, historique de navigation, identifiant publicitaire, journaux de plantage, mesures d'audience. Prix d'achat, stock, emplacements et dégustations restent sur le téléphone.

## Autres déclarations

| Rubrique | Réponse |
| --- | --- |
| Application d'actualités | Non |
| Application de santé | Non |
| Application financière | Non |
| Application gouvernementale | Non |
| Contenu généré par IA | Oui : les textes de la fiche proposés par le service d'identification sont générés par IA, marqués comme tels dans l'application et signalables (FIC-07, PRV-R4) |
| Autorisations sensibles | Appareil photo, pour photographier l'étiquette et lire le code-barres et le millésime |

## Test fermé (compte personnel)

Avant la production : test fermé avec au moins 12 testeurs inscrits sans interruption pendant 14 jours. Prévoir 15 à 20 adresses Gmail pour absorber les départs (docs/09).
