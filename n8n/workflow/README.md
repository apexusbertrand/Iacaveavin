# Exports des flux

Un fichier par flux publié (`IA_CAVE_*.json`), produit par `node n8n/code/exporter.js` à partir du flux téléchargé de n8n. L'exportateur refuse tout ce qui ressemble à une clé ; la CI refait ce contrôle et vérifie que le code des nœuds est celui de n8n/code/ (`n8n/code/comparer.js`). L'historique des versions est celui de git ; l'identifiant de version n8n figure dans `meta.versionId`.

Les générateurs (`src/*.gen.js`) décrivent les flux en Workflow SDK : nœuds, connexions, paramètres. Le code des nœuds Code y est remplacé à l'assemblage.
