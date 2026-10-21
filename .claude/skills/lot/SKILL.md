---
name: lot
description: Démarre, reprend ou recette un lot du plan de livraison d'IA cave à vin (docs/08-lots-recette.md). Utiliser quand Bertrand demande de lancer, continuer, terminer ou recetter un lot, par exemple « /lot 1 » ou « /lot 2a recette ».
argument-hint: "[numéro du lot] [demarrer|reprendre|recette]"
disable-model-invocation: true
---

Lot demandé : $0. Action : $1 (par défaut : demarrer s'il n'a jamais commencé, sinon reprendre).

## 1. Situer le lot

1. Lis la ligne du lot $0 dans `docs/08-lots-recette.md` : contenu, identifiants d'exigences, critère de sortie.
2. Lis dans `docs/05-fonctionnel.md` et `docs/07-exigences-non-fonctionnelles.md` uniquement les exigences du lot.
3. Lis l'entrée du lot dans `docs/journal-lots.md` et `git log --oneline -20` sur la branche du lot si elle existe.
4. Vérifie que le lot précédent est recetté (journal). Sinon, dis-le et demande s'il faut continuer quand même. Exception : le lot 2b peut avancer dès que le lot 0 est terminé.

## 2. Planifier (action demarrer ou reprendre)

1. Passe en mode plan.
2. Présente : le périmètre en 5 lignes, la liste des exigences avec l'ordre de réalisation, les fichiers ou dossiers touchés, tes hypothèses, les risques.
3. Pose au plus 5 questions bloquantes, chacune avec ta recommandation.
4. Attends la validation de Bertrand avant d'écrire du code.

## 3. Réaliser

1. Crée ou reprends la branche `lot-$0-<nom-court>`.
2. Pour chaque exigence, dans l'ordre validé :
   - écris d'abord le test qui porte l'identifiant, puis le code ;
   - `flutter analyze`, `dart format`, `flutter test` au vert ;
   - commit `<ID> : <ce qui est fait>` ;
   - coche l'exigence dans `docs/journal-lots.md`.
3. Si une exigence se révèle ambiguë ou contradictoire : arrête-toi sur ce point, propose deux options, continue sur les autres exigences en attendant.
4. Si tu touches un champ, le contrat ou une règle : applique `.claude/rules/specs.md` et relance `python3 scripts/valider_contrat.py` et `python3 scripts/verifier_regles.py`.

## 4. Recetter (action recette, ou fin de réalisation)

1. Déroule la définition de terminé de `docs/08-lots-recette.md` pour chaque exigence du lot.
2. Mesure ce que le critère de sortie demande (temps, volumes, nombre de cas) et note les chiffres dans le journal.
3. Prépare pour Bertrand une checklist de test manuel sur téléphone : 10 étapes au plus, chacune avec le résultat attendu.
4. Ouvre la pull request vers `main` avec : exigences livrées, mesures, écarts et décisions proposées, checklist manuelle.
5. Le lot n'est « recetté » que lorsque Bertrand l'a confirmé. Note sa réponse et la date dans le journal.

## Règles de conduite

- Ne déborde pas sur le lot suivant, même pour « gagner du temps ».
- Toute décision qui change le sens d'un document : une ligne proposée dans `docs/decisions.md`, signalée dans la pull request.
- Termine chaque session par un point d'étape de 5 lignes au plus dans `docs/journal-lots.md` : fait, en cours, bloquant, prochaine étape.
