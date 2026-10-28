# 09. Distribution et publication

Décision D5 : pas de compte Google Play au départ. L'app est installée en direct sur les téléphones de test jusqu'à ce qu'elle soit complète et recettée (lot 5). La publication vient ensuite, sur décision.

## Phase 1 : distribution directe de l'APK

- La CI GitHub Actions construit l'APK de diffusion à chaque tag `v*` et l'attache à une release GitHub du dépôt privé.
- Sur le téléphone : télécharger l'APK depuis la release (application GitHub ou navigateur connecté au compte), autoriser l'installation depuis cette source une fois, installer.
- Les mises à jour s'installent par-dessus, à condition d'être signées avec la même clé. D'où la règle suivante.

### Clé de signature : à créer au lot 0 et à ne jamais perdre

- Créer un keystore dédié (`iacaveavin-upload.jks`) au lot 0. Il sert à toutes les versions installées en direct, puis de clé d'envoi le jour de la publication sur Google Play.
- Le keystore et ses mots de passe ne vont jamais dans le dépôt (voir .gitignore). Copie de sauvegarde chiffrée hors du PC (gestionnaire de mots de passe ou coffre).
- La CI le reçoit par des secrets GitHub (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`), créés par Bertrand dans les réglages du dépôt.
- Perdre cette clé avant la publication oblige à désinstaller l'app (et donc à restaurer une sauvegarde) sur chaque téléphone de test.

### Identité de l'app

| Élément | Valeur |
| --- | --- |
| Nom affiché | IA cave à vin |
| Identifiant Android (applicationId) | `fr.apexus.iacaveavin`, définitif dès la première installation |
| Schéma de lien profond | `iacaveavin://` |
| Version | `MAJEUR.MINEUR.CORRECTIF+build`, build incrémenté à chaque release |

Avant toute publication, vérifier que le nom n'est pas déjà une marque déposée dans la classe des logiciels.

## Phase 2 : Google Play, décidée le 2026-10-28 (T123)

- Compte personnel ou compte organisation Apexus-BMT. Un compte personnel créé après le 13 novembre 2023 doit faire tourner un test fermé d'au moins 12 testeurs inscrits sans interruption pendant 14 jours avant d'accéder à la production ([aide Play Console](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB)). Un compte organisation passe par une vérification d'entreprise.
- Le lot 5 sert de répétition : les testeurs de la recette élargie peuvent devenir les testeurs du test fermé. En recruter 15 à 20 pour absorber les départs.
- Livrable : Android App Bundle signé avec la clé d'envoi du lot 0, Play App Signing, niveau d'API cible exigé par Google au jour de la soumission. La CI le construit au tag `v*` (`iacaveavin-v1.0.0.aab`, avec l'APK signé et le zip des symboles de désobfuscation à déposer dans la Play Console). Sans tag poussé, l'onglet Actions, workflow « Application », « Run workflow » sur `main` avec la version (ex. `v1.0.0`) crée le tag et la release ; la version doit être celle de pubspec.yaml.
- Conformité (NFR-18, T122) : aucun écran « à venir », aucun contenu ni flux de démonstration dans l'app publiée.
- Fiche store : descriptions, captures faites avec le jeu de démonstration chargé par le test d'intégration (domaines inventés), icône, bannière, URL publique de politique de confidentialité (sur apexus.fr).
- Data safety : photos envoyées au serveur pour traitement, non partagées, effacées après traitement ; ni compte, ni publicité, ni localisation.
- Classification du contenu : questionnaire IARC, références à l'alcool, public adulte.
- Contenus générés par IA : vérifier la politique Google Play en vigueur au moment de la soumission. L'app prévoit déjà le marquage des textes rédigés par IA et leur signalement (FIC-07, PRV-R4).
- Avant publication publique, remplacer la clé partagée par des comptes et des quotas par compte (docs/10-evolutions.md).

## Phase 3 : App Store

- Adhésion Apple Developer Program, compilation sur Mac ou via une CI macOS.
- Texte explicite de demande d'accès à la caméra, étiquettes de confidentialité renseignées, âge minimum adapté à l'alcool.
- Si une connexion par un fournisseur tiers est proposée, Apple impose une option de connexion équivalente respectueuse de la vie privée, typiquement Sign in with Apple.
