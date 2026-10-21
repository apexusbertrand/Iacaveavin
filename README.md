# IA cave à vin

Application mobile de gestion de cave à vin, aux couleurs d'Apexus-BMT. On photographie une étiquette, un agent n8n complète la fiche à partir de sources vérifiables, puis la cave se gère hors ligne : stock, emplacements, propriétaires, prix, statistiques, PDF, Excel.

Android d'abord, iOS ensuite, une seule base de code Flutter.

Statut au 2026-10-21 : lot 0 (socle installable) réalisé, en attente de recette sur téléphone.

## Comment ce dépôt est organisé

Le dépôt est le cahier des charges exécutable par Claude Code. Les consignes permanentes sont courtes ; le détail est lu à la demande.

| Chemin | Contenu |
| --- | --- |
| `CLAUDE.md` | règles et conventions lues par Claude Code à chaque session |
| `PROMPT_DEMARRAGE.md` | prérequis et premier message à coller dans Claude Code |
| `.claude/rules/` | règles chargées seulement quand Claude touche `app/`, `n8n/` ou les specs |
| `.claude/skills/lot/` | la commande `/lot` : planifier, réaliser et recetter un lot |
| `docs/01` à `docs/10` | cahier des charges : vision, architecture, design, données, fonctionnel, agent n8n, non fonctionnel, lots, distribution, évolutions |
| `docs/decisions.md` | décisions prises et questions ouvertes |
| `docs/autocritique.md` | ce que chaque version du cahier des charges a corrigé |
| `docs/reference/` | captures de l'application de référence |
| `specs/` | sources lisibles par la machine : dictionnaire de données, contrat n8n (JSON Schema + exemples), jetons de design, règles de garde |
| `n8n/` | prompts des agents, sources autorisées, jeu d'essai, exports du flux |
| `scripts/` | vérifications des specs, lancées aussi par la CI |
| `app/` | le projet Flutter (créé au lot 0) |

## Décisions de départ

| | Décision |
| --- | --- |
| D1 | Nom : IA cave à vin |
| D2 | Notes Parker : uniquement les sources gratuites (accès libre, notes citées par le domaine ou un marchand) |
| D3 | Prix marché : sites publics de vente en ligne |
| D4 | Back-office : un nouveau flux dans l'instance n8n actuelle |
| D5 | Pas de compte Google Play au départ : APK installé en direct jusqu'à la fin des tests |

Détail et décisions techniques : `docs/decisions.md`.

## Démarrer

Voir `PROMPT_DEMARRAGE.md`.

## Vérifier les spécifications

```bash
pip install jsonschema pyyaml
python3 scripts/valider_contrat.py
python3 scripts/verifier_regles.py
```
