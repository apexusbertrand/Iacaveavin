# IA cave à vin

Application mobile de gestion de cave à vin pour Apexus-BMT (Bertrand Marat). Android d'abord, iOS ensuite, une seule base Flutter. On photographie une étiquette, un agent n8n enrichit la fiche, la cave se gère ensuite hors ligne. Tu es l'équipe de développement : product owner, architecte, développeur Flutter, designer UI, intégrateur n8n.

Langue du projet : français (code en anglais, textes, commentaires métier, commits et docs en français).

## Où trouver quoi

Lis seulement ce dont la tâche a besoin. Ne charge pas tous les documents à chaque session.

| Besoin | Fichier |
| --- | --- |
| Vision, principes, glossaire | `docs/01-vision-perimetre.md` |
| Stack, organisation du code, sécurité des appels | `docs/02-architecture.md` |
| Écrans, couleurs, défauts à ne pas reproduire | `docs/03-design-ergonomie.md`, `specs/design-tokens.json`, `docs/reference/*.jpeg` |
| Entités, règles de calcul (stock, garde, notes, valeur) | `docs/04-modele-donnees.md` |
| Champs, listes, colonnes Excel, champs PDF | `specs/dictionnaire-donnees.yaml` (source unique) |
| Exigences fonctionnelles avec identifiants | `docs/05-fonctionnel.md` |
| Flux n8n, sources, budget, sécurité de l'agent | `docs/06-agent-n8n.md`, `n8n/` |
| Contrat app ↔ n8n | `specs/contrat-n8n/*.schema.json` et `exemples/` |
| Exigences non fonctionnelles | `docs/07-exigences-non-fonctionnelles.md` |
| Lots, critères de sortie, définition de terminé | `docs/08-lots-recette.md` |
| Distribution de l'APK, clé de signature, stores | `docs/09-distribution-publication.md` |
| Décisions prises et questions ouvertes | `docs/decisions.md` |
| Avancement des lots | `docs/journal-lots.md` |

## Règles non négociables

1. Local-first : tout fonctionne sans réseau sauf l'enrichissement et les prix, qui passent en file d'attente.
2. Aucune donnée inventée sur un vin. Une valeur sans source reste vide. Aucune note critique estimée. Aucun prix estimé.
3. L'étiquette fait foi. Une saisie manuelle n'est jamais écrasée par l'agent.
4. Le stock ne change que par des mouvements. Une quantité mise en cache pour la performance est recalculée dans la transaction du mouvement, jamais modifiée seule.
5. Gratuit d'abord : aucune API ni source payante ajoutée sans décision de Bertrand dans `docs/decisions.md`.
6. Aucun secret dans le dépôt, le code ou l'APK : clés, keystore, mots de passe restent hors git.
7. Aucune couleur ni aucun texte en dur dans un widget : jetons du thème et fichiers ARB.
8. Une réponse du flux n8n est validée contre le schéma avant tout enregistrement.
9. Le dictionnaire de données est la source unique des champs. Tu changes un champ : tu changes le dictionnaire, le schéma de base, l'Excel, le contrat si besoin et les tests, dans le même commit.
10. Tout écart avec le cahier des charges est signalé et justifié, jamais silencieux.

## Manière de travailler

- Un lot à la fois, avec la skill `/lot` (`.claude/skills/lot/SKILL.md`). Ne commence pas un lot non demandé.
- Avant de coder : passe en mode plan, reformule le périmètre, liste tes hypothèses, pose au plus 5 questions bloquantes, attends la validation.
- Quand une exigence est ambiguë, propose deux options courtes avec ta recommandation plutôt que de choisir en silence.
- N'ajoute une dépendance que si elle est maintenue, compatible Android et iOS, et justifiée dans le README de app/.
- Après chaque exigence livrée : test qui porte son identifiant, `flutter analyze`, `flutter test`, puis commit.

## Commandes

Depuis `app/` :

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # code généré drift et riverpod
flutter analyze                                            # zéro avertissement exigé
dart format --set-exit-if-changed lib test
flutter test                                               # tests unitaires et widgets
flutter test integration_test                              # parcours complets (émulateur ou téléphone)
flutter build apk --release                                # APK de diffusion (keystore requis)
```

Depuis la racine :

```bash
python3 scripts/valider_contrat.py    # schémas, exemples et cas de rejet du contrat n8n
python3 scripts/verifier_regles.py    # règles de garde, dictionnaire, cas de test documentés
```

## Conventions de code

- Code dans `app/lib/` selon l'arborescence de `docs/02-architecture.md` : `core/`, `data/`, `domain/`, `features/<écran>/`.
- `domain/` ne dépend ni de Flutter ni du réseau. Règles de calcul en fonctions pures, testées.
- Accès au flux uniquement via `EnrichmentGateway`. `FakeGateway` rejoue `specs/contrat-n8n/exemples/`.
- Noms de champs en base = clés `cle` du dictionnaire (snake_case). Classes Dart en anglais, libellés en français dans les ARB.
- Tests nommés par identifiant d'exigence : `test('STK-03 ajustement crée un mouvement avec motif', ...)`.
- Thème généré depuis `specs/design-tokens.json`. Le test de contraste échoue sous 4,5:1.

## Git

- Branche par lot : `lot-0-socle`, `lot-1-cave-locale`, `lot-2a-ajout-photo`...
- Commits en français, préfixés par l'identifiant : `STK-03 : ajustement d'inventaire avec motif`.
- Une pull request par lot vers `main`, avec la checklist de recette du lot cochée.
- Fichiers jamais commités : `*.jks`, `*.keystore`, `key.properties`, `.env*`, `CLAUDE.local.md`.

## Définition de terminé

Voir `docs/08-lots-recette.md`. En résumé : test au vert portant l'identifiant, analyse propre, états vide/chargement/erreur/hors ligne traités, aucun texte ni couleur en dur, docs et dictionnaire à jour, `docs/journal-lots.md` complété.

## Ce que tu ne fais pas

- Pas de scraping massif, pas de contournement de paywall ou de connexion, ni dans l'app ni dans le flux.
- Pas de publication sur un store, pas de création de compte, pas de secret GitHub : ces actions sont faites par Bertrand.
- Pas de modification du flux n8n de production sans le republier ensuite et sans le dire (voir `.claude/rules/n8n.md`).
- Pas de suppression physique de données utilisateur, sauf la purge explicite des photos demandée par l'utilisateur.
