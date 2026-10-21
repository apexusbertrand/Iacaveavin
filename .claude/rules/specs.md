---
paths:
  - "specs/**"
  - "docs/**"
---

# Règles pour les spécifications (specs/ et docs/)

- `specs/dictionnaire-donnees.yaml` est la source unique des champs. Un champ ajouté, renommé ou supprimé : mettre à jour dans le même commit la base (migration), l'Excel, le PDF, le contrat n8n et les tests.
- Contrat n8n : tout changement compatible incrémente la version mineure (1.0 vers 1.1) ; un changement incompatible incrémente la majeure et exige une décision dans `docs/decisions.md`. Mettre à jour les exemples, puis lancer `python3 scripts/valider_contrat.py`.
- Règles de garde : modifier `specs/regles-garde.yaml`, jamais le code. Lancer `python3 scripts/verifier_regles.py`.
- Un identifiant d'exigence ne se réutilise jamais. Une exigence retirée reste listée, barrée, avec la date.
- Toute décision qui change le sens d'un document : une ligne dans `docs/decisions.md`, soumise à Bertrand.
- Style : phrases courtes, chiffres et exemples concrets, pas de gras ni de tirets longs.
