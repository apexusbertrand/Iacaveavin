# app/

Projet Flutter d'IA cave à vin, créé au lot 0 :

```bash
flutter create --org fr.apexus --project-name iacaveavin --platforms android,ios .
```

Identifiant Android `fr.apexus.iacaveavin` (docs/09-distribution-publication.md), définitif dès la première installation. Flutter 3.47.7 stable, Dart 3.13.

## Commandes

Depuis `app/` :

```bash
flutter pub get                       # génère aussi les traductions (lib/core/l10n/generated)
dart run build_runner build           # code drift (lib/data/db/app_database.g.dart)
dart run tool/generate_theme_tokens.dart   # jetons de thème depuis specs/design-tokens.json
flutter analyze --fatal-infos         # zéro avertissement
dart format lib test tool integration_test
flutter test                          # tests unitaires et widgets
flutter test integration_test         # parcours complet, téléphone ou émulateur branché
flutter run                           # lancer sur le téléphone en debug
```

Depuis la racine : `python3 scripts/generer_referentiels.py` régénère `assets/referentiels/listes-dictionnaire.json` après une modification des listes du dictionnaire ; `python3 scripts/matrice_exigences.py --lot 0` vérifie la couverture des exigences.

Le code généré (drift, l10n, jetons) est commité : un `git clone` puis `flutter run` suffit. La CI régénère tout et échoue si le résultat diffère de ce qui est commité.

## Organisation

| Dossier | Contenu |
| --- | --- |
| `lib/core/` | thème généré, contraste WCAG, traductions ARB, navigation (tiroir NAV-01), vues d'état communes |
| `lib/data/db/` | tables drift (une par entité du dictionnaire), requête de la liste |
| `lib/data/demo/` | jeu de démonstration CMP-07 (générateur déterministe, dépôt drift) |
| `lib/data/referentiels/` | chargement des listes au premier lancement |
| `lib/domain/` | entités et interfaces sans Flutter ni réseau |
| `lib/features/` | un dossier par écran : `wine_list`, `wine_detail`, `wine_edit`, `locations`, `settings`, `backup`, `about`, `placeholder`, `add` (photo, identification, validation) |
| `assets/referentiels/` | pays, régions, sous-régions, appellations, cépages, accords, listes du dictionnaire |
| `lib/data/enrichment/` | contrat n8n : validation, `EnrichmentGateway` et `FakeGateway`, file d'attente, application des propositions |
| `lib/data/files/` | photos : compression, contrôle qualité, miniatures, répertoire privé |
| `assets/contrat/` | copie de specs/contrat-n8n (schémas et exemples rejoués par `FakeGateway`) |
| `assets/regles/` | copie de specs/regles-garde.yaml (un test vérifie qu'elle est identique) |
| `drift_schemas/` | instantanés du schéma, un par version, pour les tests de migration |
| `tool/` | générateur des jetons de thème |

## Migrations de la base

Schéma en version 1. Pour une nouvelle version : incrémenter `schemaVersion` dans `lib/data/db/app_database.dart`, lancer `dart run drift_dev make-migrations`, écrire l'étape dans `migration`, puis compléter `test/drift/app_database/migration_test.dart` avec une base de la version précédente remplie du jeu de démonstration (NFR-05).

## Dépendances

Chaque dépendance ajoutée est listée ici avec sa raison (règle de CLAUDE.md). Toutes sont maintenues et compatibles Android et iOS (vérifié sur pub.dev le 2026-10-21).

| Paquet | Raison | Android | iOS |
| --- | --- | --- | --- |
| flutter_riverpod 3.4 | état et injection, providers testables sans widget (docs/02) | oui | oui |
| drift 2.35 | base SQLite typée, migrations versionnées et testées | oui | oui |
| drift_flutter 0.3 | ouverture de la base dans un isolate dédié, SQLite embarqué | oui | oui |
| go_router 18.1 | navigation par chemins, prépare le lien profond `iacaveavin://fiche/<id>` (NAV-02, lot 1) | oui | oui |
| intl 0.20 | formats de date, de nombre et de devise français (NFR-11) | oui | oui |
| uuid 4.6 | identifiants UUID v4 générés sur le téléphone | oui | oui |
| flutter_localizations (SDK) | traductions Material et ARB | oui | oui |
| drift_dev, build_runner (dev) | génération du code drift et des tests de migration | - | - |
| shared_preferences 2.5 | réglages et état de la liste mémorisés (PAR-05, LST-09), aucun secret | oui | oui |
| archive 4.5 | archive zip de sauvegarde, compressée dans un isolate (SAV-01) | oui | oui |
| share_plus 13.3 | feuille de partage du système pour exporter l'archive et les CSV (SAV-01, PAR-04) | oui | oui |
| file_picker 13.1 | choisir une archive à restaurer ou un CSV à importer (SAV-04, PAR-04) | oui | oui |
| path_provider 2.1, path 1.9 | répertoire privé de l'app pour photos et sauvegardes locales (NFR-04, SAV-03) | oui | oui |
| yaml 3.1 | règles de garde embarquées lues par l'écran PAR-06 ; les tests lisent aussi le dictionnaire | oui | oui |
| json_schema 5.2 | validation des réponses du flux contre le contrat avant tout enregistrement (AJO-12, NFR-07) | oui | oui |
| image 4.12 | compression 1 500 px, miniature et contrôle flou ou reflet, en Dart pur dans un isolate (AJO-02, NFR-04) | oui | oui |
| image_picker 1.2 | appareil photo et galerie, plugin officiel (AJO-01, T47) | oui | oui |
| url_launcher 6.3 | ouvrir l'URL d'une provenance (FIC-06) | oui | oui |
| crypto 3.0 | SHA-256 et HMAC de la signature des requêtes au flux (docs/02), paquet Dart de l'équipe Dart, sans code natif | oui | oui |
| flutter_secure_storage 11.2 | clé du flux dans le Keystore Android et le Trousseau iOS, jamais dans les préférences (PAR-05, règle Flutter) | oui | oui |
| integration_test (SDK, dev) | parcours complets sur téléphone | - | - |

Police : système (Roboto sur Android) au lot 0, repli prévu par specs/design-tokens.json. Inter (OFL) sera embarquée quand les fichiers de police seront ajoutés au dépôt.

## Signature (à faire une fois par Bertrand)

Le keystore et ses mots de passe ne vont jamais dans le dépôt. Sans `android/key.properties`, une build release échoue volontairement : on n'installe jamais un APK signé avec la clé de debug, sinon les mises à jour suivantes ne s'installeraient plus par-dessus.

1. Créer le keystore hors du dépôt (keytool est fourni avec Android Studio, dossier `jbr/bin`). Choisir un mot de passe fort, le même pour le keystore et la clé :

   ```bash
   mkdir -p ~/cles-apexus
   keytool -genkeypair -v -keystore ~/cles-apexus/iacaveavin-upload.jks \
     -keyalg RSA -keysize 4096 -validity 10000 -alias iacaveavin-upload \
     -dname "CN=Bertrand Marat, O=Apexus-BMT, C=FR"
   ```

2. Sauvegarder `iacaveavin-upload.jks` et le mot de passe dans le gestionnaire de mots de passe (copie chiffrée hors du PC).

3. Donner la clé à la CI par les secrets du dépôt (GitHub CLI, depuis le dossier du dépôt) :

   ```bash
   base64 -w0 ~/cles-apexus/iacaveavin-upload.jks | gh secret set ANDROID_KEYSTORE_BASE64
   gh secret set ANDROID_KEYSTORE_PASSWORD      # saisir le mot de passe
   gh secret set ANDROID_KEY_PASSWORD           # même mot de passe
   echo -n iacaveavin-upload | gh secret set ANDROID_KEY_ALIAS
   ```

   Sous Windows PowerShell, l'étape base64 devient :
   `[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\cles-apexus\iacaveavin-upload.jks")) | gh secret set ANDROID_KEYSTORE_BASE64`
   (sur macOS : `base64 -i ~/cles-apexus/iacaveavin-upload.jks | gh secret set ANDROID_KEYSTORE_BASE64`).

4. Pour une build release sur le PC (facultatif), créer `app/android/key.properties`, ignoré par git :

   ```properties
   storeFile=/chemin/absolu/vers/cles-apexus/iacaveavin-upload.jks
   storePassword=...
   keyAlias=iacaveavin-upload
   keyPassword=...
   ```

## Publier un APK

La CI construit l'APK signé et obfusqué à chaque tag `v*` et l'attache à une release GitHub :

```bash
git checkout main && git pull
git tag v0.1.0 && git push origin v0.1.0
```

Le numéro après `+` dans `pubspec.yaml` (build) s'incrémente à chaque release.
