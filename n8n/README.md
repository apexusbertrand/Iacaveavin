# Flux n8n IA_CAVE_Agent

Ce dossier contient tout ce qu'il faut pour construire et faire évoluer le flux d'enrichissement sur l'instance n8n actuelle d'Apexus. Spécification : docs/06-agent-n8n.md. Contrat : specs/contrat-n8n/.

| Fichier | Rôle |
| --- | --- |
| prompt-agent-enrichissement.md | prompt système de l'agent d'enrichissement |
| prompt-agent-prix.md | prompt système de l'agent prix |
| sources-autorisees.yaml | domaines consultables, avec leur statut de vérification |
| workflow/ | export JSON des flux publiés (`IA_CAVE_*.json`) et leurs générateurs (workflow/src/) |
| code/ | code des nœuds Code, bibliothèques, tests, assembleur, comparaison et export |
| jeu-essai/ | photos d'étiquettes réelles et résultats attendus |

## Découpage du flux

1. Webhook POST `iacave/enrichissement` : contrôles d'entrée (en-têtes, horodatage, HMAC, request_id, quota, schéma), création du job, stockage temporaire des photos, réponse immédiate (Respond to Webhook) avec `statut: en_attente`.
2. Traitement asynchrone (sous-flux `IA_CAVE_Enrichissement`) : lecture des étiquettes, normalisation, cache, agent d'enrichissement avec outils de recherche et de lecture de pages, agent prix si demandé.
3. Contrôles de sortie (nœud Code) : URL citées présentes dans `sources_consultees`, domaines de prix autorisés, bornes des valeurs, validation contre `resultat_enrichissement`. Une sortie invalide relance l'agent une fois avec le message d'erreur, puis passe le job en `erreur`.
4. Écriture du résultat dans `iacave_jobs`, du cache, du quota ; effacement des photos.
5. Webhook GET `iacave/jobs?job_id=…` : lecture du job (paramètre de requête, voir T63).
6. Webhook POST `iacave/prix` : mêmes contrôles d'entrée, sous-flux `IA_CAVE_Prix`, cache de 24 heures.
7. Webhook GET `iacave/sante` : version du flux et du contrat.
8. Flux d'erreur : mail d'alerte avec le job_id, sans les photos.

## Flux et tables en ligne (instance apexus.app.n8n.cloud)

| Élément | Identifiant | Rôle |
| --- | --- | --- |
| IA_CAVE_Agent | Hxe2WOxtYcF6HWcQ | webhooks /sante, /enrichissement, /prix, /jobs |
| IA_CAVE_Enrichissement | 5z197yDZlge7nrpM | lecture d'étiquette, cache, agent, contrôles, clôture |
| IA_CAVE_Prix | PeGDu6KX9n4SDml1 | relevé de prix, seul (POST /prix) ou appelé par l'enrichissement |
| IA_CAVE_Erreurs | DBnqjEW2q6d4YeOh | flux d'erreur : job en erreur, mail à apexus.bertrand@gmail.com |
| IA_CAVE_Purge | 2MMx8azV92NVEEEE | purge chaque nuit à 3 h 17 (durées de docs/06) |
| iacave_config | wZNVTkGzqgeu2smf | clés, quotas, destinataire des alertes |
| iacave_jobs, iacave_cache_vins, iacave_cache_prix, iacave_quotas, iacave_signalements | voir n8n/workflow/src/outils.js | données du flux |

URL de l'app : `https://apexus.app.n8n.cloud/webhook/iacave/...` (sante, enrichissement, prix, `jobs?job_id=…`).

## Mise en service par Bertrand

1. Clé de l'app. Générer une clé de 32 caractères ou plus, par exemple `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`. Dans n8n, ouvrir la table iacave_config, ligne `cle_app`, coller la clé dans `valeur`. La même clé va dans l'app (Paramètres, connexion, lot 2c). Jamais dans git, jamais dans un mail.
2. Tavily. Créer le compte sur tavily.com (offre gratuite, 1 000 crédits par mois), copier la clé API dans la ligne `tavily_cle`. Sans elle, le flux lit l'étiquette et laisse vides les champs qui demandent une recherche, avec le motif « recherche web indisponible ».
3. Sources. Lire les CGU des domaines de sources-autorisees.yaml (les robots.txt sont déjà notés), puis passer à `actif` ceux qui conviennent. L'activation demande une session de développement pour réassembler et republier les nœuds Code (T69).
4. Vérifier : `curl https://apexus.app.n8n.cloud/webhook/iacave/sante` renvoie `ok: true` dès que la clé est en place.
5. Jeu d'essai : déposer les 30 dossiers dans jeu-essai/, puis `IACAVE_URL=https://apexus.app.n8n.cloud IACAVE_CLE=... python3 scripts/jeu_essai.py`. Le rapport s'écrit dans jeu-essai/.

Les identifiants « Anthropic account » et « Gmail APEXUS » sont ceux de l'instance, utilisés sans modification (T63).

## Faire évoluer un flux

- Le code des nœuds vit dans code/noeuds/ et code/lib/ ; `node --test code/test/*.test.js` le teste hors n8n.
- `node code/assembler.js <flux>` produit le source SDK complet dans code/dist/ ; `node code/operations.js "Nom du nœud=script"` produit les opérations de mise à jour (paramètres remplacés en entier).
- Après publication : télécharger le flux, `node code/comparer.js <flux.json>` vérifie que le code en ligne est celui du dépôt, `node code/exporter.js <flux.json>` écrit l'export dans workflow/ en refusant tout secret.

## Configuration (table iacave_config)

| Clé | Valeur par défaut | Rôle |
| --- | --- | --- |
| cle_app | vide, à saisir | clé partagée avec l'app (signature HMAC) |
| tavily_cle | vide, à saisir | recherche web |
| fenetre_secondes | 300 | écart maximal d'horodatage |
| quota_enrichissements | 100 | par mois |
| quota_prix | 120 | par mois |
| seuil_alerte | 0.8 | mail d'alerte de quota |
| email_alerte | apexus.bertrand@gmail.com | destinataire des alertes |

## Avant chaque mise en production du flux

- [ ] `python3 scripts/valider_contrat.py` et `node --test n8n/code/test/*.test.js` passent.
- [ ] Les 30 cas de n8n/jeu-essai/ tournent et atteignent les cibles de docs/06-agent-n8n.md.
- [ ] Export JSON du flux déposé dans workflow/ (`code/exporter.js`), conforme au code (`code/comparer.js`), version incrémentée dans /sante.
- [ ] Flux republié après modification, puis appel réel à /sante.
