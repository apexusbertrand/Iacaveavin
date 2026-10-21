---
paths:
  - "app/**"
---

# Règles pour le code Flutter (app/)

- Architecture : `core/`, `data/`, `domain/`, `features/<écran>/` (docs/02-architecture.md). Une feature ne lit jamais la base directement : elle passe par un cas d'usage du domaine ou un DAO.
- Base drift : une table par entité du dictionnaire, colonnes nommées comme les clés `cle`, index sur tous les champs de tri et de filtre de LST-01 et LST-05. Toute évolution de schéma = migration numérotée + test de migration depuis la version précédente remplie du jeu de démonstration.
- Stock : la quantité d'un lot se calcule depuis les mouvements (STK-R1). Une vue ou une colonne dénormalisée est permise pour la performance, recalculée dans la même transaction que le mouvement, et vérifiée par un test.
- Isolates pour PDF, Excel, compression d'images, archives et statistiques lourdes (NFR-02).
- Photos : répertoire privé de l'app, chemins relatifs en base, miniature générée à l'enregistrement.
- Réseau : seul `N8nGateway` fait des appels HTTP. Délais : 15 s par requête, 3 min par job. Toute réponse est validée contre `specs/contrat-n8n/reponse-job.schema.json` avant usage.
- Clé du flux : `flutter_secure_storage` uniquement, jamais dans les préférences, les logs, les exports ou les archives de sauvegarde.
- Signature des requêtes : implémenter exactement la formule de docs/02-architecture.md, avec un test sur un vecteur fixe.
- Thème : généré depuis `specs/design-tokens.json`. `primaryTexte` pour tout texte orange sur fond clair, jamais `primary`. Test de contraste sur toutes les paires texte/fond du thème clair et du thème sombre.
- Textes : fichiers ARB uniquement. Un test parcourt les écrans en widget test et échoue si un libellé contient `_` suivi d'un chiffre ou une clé non traduite (défaut « wine_0 »).
- Plugins : aucun plugin propre à Android sans équivalent iOS (NFR-12). Vérifier la plateforme dans pub.dev avant d'ajouter.
- Performance : listes avec `ListView.builder` ou équivalent paresseux, miniatures en cache, requêtes paginées au-delà de 200 lignes.
- Tests : nommés par identifiant d'exigence, un fichier de test par feature, cas limites de docs/04-modele-donnees.md repris tels quels.
