# Fiche Google Play : IA cave à vin

Textes à coller dans la Play Console, dans l'ordre des rubriques. Décisions T123 et T124, comptes T126 à T129 (docs/decisions.md). Mis à jour le 2026-10-31 pour la version avec comptes, pas encore compilée. Captures, icône et bannière : dossier store/ à côté de ce fichier.

## Identité

| Champ | Valeur |
| --- | --- |
| Nom de package | fr.apexus.iacaveavin |
| Nom de l'application (30 caractères max) | IA cave à vin |
| Langue par défaut | Français (France) – fr-FR |
| Application ou jeu | Application |
| Gratuite ou payante | Gratuite |
| Catégorie | Alimentation et boissons |
| Adresse e-mail de contact | apexus.claude@gmail.com (confirmé le 2026-11-01, V8) |
| Site web | aucun (choix de Bertrand du 2026-11-01, V8) |
| Politique de confidentialité | URL publique obligatoire : page publiée à partir de politique-confidentialite.html, hébergement à choisir (Q8) |

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
La cave vit sur votre téléphone et fonctionne hors ligne, sans compte : liste, fiches, stock, statistiques, PDF et Excel. Ni publicité, ni mesure d'audience. Seules les photos d'étiquettes partent au service d'identification, après votre accord, et elles n'y sont jamais enregistrées. Sauvegarde et restauration complètes en un fichier.

À SAVOIR
L'identification par photo et le relevé des prix passent par un service en ligne d'Apexus, avec un compte gratuit : votre adresse mail et un code reçu par mail, sans mot de passe. 10 identifications et 10 relevés de prix par mois. Sans compte, toute la gestion de cave fonctionne et les fiches restent « à enrichir » jusqu'à la connexion.

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
L'identification par photo et le relevé des prix demandent un compte gratuit : Paramètres > Compte, saisir une adresse mail, « Recevoir un code », puis saisir le code à six chiffres reçu par mail. N'importe quelle adresse convient, le compte est créé à la première connexion.
```

~~Point à trancher par Bertrand : donner la clé partagée à Google expose cette clé.~~ Réglé par les comptes (T126) : l'examinateur se connecte avec sa propre adresse.

Suppression du compte : bouton « Supprimer mon compte » dans le menu Compte de l'app (CPT-05, fait le 2026-11-03). Google demande aussi un lien web dans la rubrique « Suppression des données » ; la page de la politique de confidentialité, une fois publiée (Q8), peut servir de lien si elle explique la démarche.

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
| Les utilisateurs peuvent demander la suppression | Oui, dans l'app (menu Compte, « Supprimer mon compte ») ou par mail à apexus.claude@gmail.com ; la cave elle-même est sur le téléphone et s'efface en désinstallant l'application |
| Partage avec des tiers | Non. Les prestataires qui traitent pour le compte d'Apexus (hébergeur n8n, modèle d'IA Anthropic, Gmail pour l'envoi des codes et des remontées) ne comptent pas comme partage au sens de Google |
| Création de compte | Oui : adresse mail et code reçu par mail, sans mot de passe |

Données collectées (toutes facultatives : sans compte, rien ne part ; aucune n'est partagée) :

| Type Google | Donnée réelle | Traitement éphémère | Finalités |
| --- | --- | --- | --- |
| Photos et vidéos > Photos | photos d'étiquettes envoyées pour l'identification, après consentement | Oui : gardées en mémoire le temps du traitement, jamais écrites | Fonctionnalités de l'application |
| Contenus générés par l'utilisateur > Autres | indices saisis (texte libre, code-barres, millésime), valeurs signalées comme fausses, fiches et prix trouvés pour le compte | Non (requête gardée 90 jours, signalements 24 mois, base des vins traités sans limite, rattachée à l'identifiant pseudonyme du compte) | Fonctionnalités de l'application, analyses (amélioration du service) |
| Informations personnelles > Adresse e-mail | adresse du compte ; adresse de contact d'une remontée | Non (compte : jusqu'à sa suppression ; remontée : journal 30 jours, mail dans la boîte de l'équipe) | Gestion du compte, Fonctionnalités de l'application, Communications du développeur |
| Informations personnelles > Identifiants utilisateur | identifiant de compte aléatoire (pseudonyme) | Non (tant que le compte existe) | Gestion du compte, sécurité, prévention des fraudes (quotas) |
| Messages > Autres messages in-app | titre, commentaire et pièce jointe d'une remontée | Non (mail dans la boîte de l'équipe) | Communications du développeur |
| Identifiants de l'appareil ou autres | identifiant d'installation aléatoire, généré par l'application | Non (90 jours avec chaque requête) | Fonctionnalités de l'application, sécurité, prévention des fraudes (quotas) |

Non collectés : position, contacts, nom, données financières, santé, historique de navigation, identifiant publicitaire, journaux de plantage, mesures d'audience. Prix d'achat, stock, emplacements et dégustations restent sur le téléphone.

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
