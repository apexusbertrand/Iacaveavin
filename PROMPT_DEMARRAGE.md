# Démarrer avec Claude Code

## Prérequis sur le PC

| Outil | Pour quoi |
| --- | --- |
| Git | cloner et pousser le dépôt |
| Flutter SDK, canal stable | compiler l'app |
| Android Studio (SDK Android, platform-tools, un émulateur) | build Android, émulateur |
| Un téléphone Android en mode développeur, débogage USB activé | tester sur l'appareil réel |
| Python 3 avec `pip install jsonschema pyyaml` | scripts de vérification des specs |
| Claude Code | développement |

## Mettre le dépôt sur GitHub (une seule fois)

Si tu pars de l'archive `IA-cave-a-vin.zip` (dépôt git déjà initialisé, premier commit fait), dézippe-la puis, dans le dossier, avec GitHub CLI :

```bash
gh auth status        # sinon : gh auth login
gh repo create apexusbertrand/IA-cave-a-vin --private --source . --remote origin --push
```

Sans GitHub CLI : crée le dépôt vide sur github.com/new (nom `IA-cave-a-vin`, privé, sans README), puis :

```bash
git remote add origin https://github.com/apexusbertrand/IA-cave-a-vin.git
git push -u origin main
```

## Lancer la première session

Depuis le dossier du dépôt (ou après `git clone https://github.com/apexusbertrand/IA-cave-a-vin.git`) :

```bash
cd IA-cave-a-vin
claude
```

Claude Code lit CLAUDE.md tout seul. Colle ensuite ce premier message :

```text
Tu reprends le projet IA cave à vin. CLAUDE.md te donne les règles. Lis aussi docs/01-vision-perimetre.md, docs/02-architecture.md et docs/08-lots-recette.md.

Objectif de cette session : préparer puis réaliser le lot 0 (socle installable).

1. Vérifie l'environnement : flutter doctor -v, flutter devices, Python 3 avec jsonschema et pyyaml. Liste ce qui manque avec la commande pour l'installer. N'installe rien toi-même sur le système.
2. Lance python3 scripts/valider_contrat.py puis python3 scripts/verifier_regles.py. Les deux doivent afficher TOUT EST CONFORME.
3. Lance /lot 0 : plan, hypothèses, questions. Attends mon feu vert avant d'écrire du code.

À garder en tête dès le lot 0 : identifiant Android fr.apexus.iacaveavin ; thème généré depuis specs/design-tokens.json avec test de contraste ; aucun secret dans le dépôt ; keystore créé hors du dépôt selon docs/09-distribution-publication.md (tu me donnes les commandes, je les exécute et je garde les mots de passe).
```

## Sessions suivantes

Une session par lot, ou par morceau de lot :

```text
/lot 1
/lot 1 reprendre
/lot 1 recette
```

Le lot 2b (flux n8n) demande à Claude Code un accès à l'instance n8n (serveur MCP n8n configuré dans Claude Code, ou clé d'API de l'instance). C'est toi qui le configures ; les identifiants ne vont pas dans le dépôt.

## En fin de lot

Claude Code ouvre une pull request avec une checklist de test manuel. Tu installes l'APK de la release sur ton téléphone, tu déroules la checklist, tu réponds dans la pull request. Le lot suivant ne démarre qu'après ta recette.
