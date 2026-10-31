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

1. Webhook POST `iacave/enrichissement` : contrôles d'entrée (compte actif, en-têtes, horodatage, HMAC avec la clé du compte, request_id, quota du compte, schéma), création du job, stockage temporaire des photos, réponse immédiate (Respond to Webhook) avec `statut: en_attente`.
2. Traitement asynchrone (sous-flux `IA_CAVE_Enrichissement`) : lecture des étiquettes, normalisation, cache, agent d'enrichissement avec outils de recherche et de lecture de pages, agent prix si demandé.
3. Contrôles de sortie (nœud Code) : URL citées présentes dans `sources_consultees`, domaines de prix autorisés, bornes des valeurs, validation contre `resultat_enrichissement`. Une sortie invalide relance l'agent une fois avec le message d'erreur, puis passe le job en `erreur`.
4. Écriture du résultat dans `iacave_jobs`, du cache, du quota ; effacement des photos.
5. Webhook GET `iacave/jobs?job_id=…` : lecture du job (paramètre de requête, voir T63).
6. Webhook POST `iacave/prix` : mêmes contrôles d'entrée, sous-flux `IA_CAVE_Prix`, cache de 24 heures.
7. Webhook GET `iacave/sante` : version du flux et du contrat.
8. Webhook POST `iacave/remontee` (flux `IA_CAVE_Remontee`, RET-01) : mêmes contrôles de signature, schéma, pièce jointe vérifiée, 5 envois par jour et par compte, mail à apexus.claude@gmail.com avec le contact en copie et en réponse.
9. Flux d'erreur : mail d'alerte avec le job_id, sans les photos.
10. Flux `IA_CAVE_Comptes` (CPT-01 à CPT-04, T126) : POST `iacave/compte/code` (code par mail), POST `iacave/compte/session` (clé de session), GET `iacave/compte` et POST `iacave/compte/deconnexion` (signés).
11. Chaque résultat de job renvoyé à l'app est copié dans `iacave_vins_traites` avec le compte pseudonyme (T128).

## Flux et tables en ligne (instance apexus.app.n8n.cloud)

| Élément | Identifiant | Rôle |
| --- | --- | --- |
| IA_CAVE_Agent | Hxe2WOxtYcF6HWcQ | webhooks /sante, /enrichissement, /prix, /jobs |
| IA_CAVE_Enrichissement | 5z197yDZlge7nrpM | lecture d'étiquette, cache, agent, contrôles, clôture |
| IA_CAVE_Prix | PeGDu6KX9n4SDml1 | relevé de prix, seul (POST /prix) ou appelé par l'enrichissement |
| IA_CAVE_Erreurs | DBnqjEW2q6d4YeOh | flux d'erreur : job en erreur, mail à apexus.bertrand@gmail.com |
| IA_CAVE_Remontee | F8HcTU0BuXS1dNas | webhook /remontee : remontée d'information de l'app par mail (T118) |
| IA_CAVE_Comptes | jUmLq33SWvOw5i9G | webhooks /compte/code, /compte/session, /compte, /compte/deconnexion (T126) |
| IA_CAVE_Purge | 2MMx8azV92NVEEEE | purge chaque nuit à 3 h 17 (durées de docs/06) |
| iacave_config | wZNVTkGzqgeu2smf | clés, quotas, destinataire des alertes |
| iacave_jobs, iacave_cache_vins, iacave_cache_prix, iacave_quotas, iacave_signalements, iacave_remontees, iacave_comptes, iacave_codes, iacave_usages, iacave_vins_traites | voir n8n/workflow/src/outils.js | données du flux |

URL de l'app : `https://apexus.app.n8n.cloud/webhook/iacave/...` (sante, enrichissement, prix, `jobs?job_id=…`, remontee, compte/code, compte/session, compte, compte/deconnexion). Elle est fixée dans l'app (T126).

## Mise en service par Bertrand

1. ~~Clé de l'app (ligne `cle_app` d'iacave_config)~~ : plus lue depuis le contrat 2.0 (T126), la ligne peut être vidée puis supprimée. Chaque compte a sa clé de session, créée à la connexion. Passer un compte en abonné ou le suspendre : colonne `statut` d'iacave_comptes (`abonne`, `bloque`).
2. Recherche web. Rien à saisir : l'agent utilise la recherche intégrée de Claude avec l'identifiant Anthropic « Claude AI Cave » (T85). La recherche web doit être autorisée dans la console Anthropic de l'organisation (c'est le cas, essai du 2026-10-26) ; elle est facturée 10 dollars pour 1 000 recherches. La ligne `tavily_cle` de iacave_config n'est plus lue et peut être supprimée.
3. Sources. Lire les CGU des domaines de sources-autorisees.yaml (les robots.txt sont déjà notés), puis passer à `actif` ceux qui conviennent. L'activation demande une session de développement pour réassembler et republier les nœuds Code (T69).
4. Vérifier : `curl https://apexus.app.n8n.cloud/webhook/iacave/sante` renvoie `ok: true`, `version_contrat: "2.0"`.
5. Jeu d'essai : déposer les 30 dossiers dans jeu-essai/, se connecter une fois dans l'app (ou par POST /compte/code puis /compte/session) pour obtenir un compte_id et sa clé de session, puis `IACAVE_URL=https://apexus.app.n8n.cloud IACAVE_COMPTE=... IACAVE_CLE=... python3 scripts/jeu_essai.py`. Le rapport s'écrit dans jeu-essai/.

Les identifiants « Claude AI Cave » (Anthropic) et « Gmail Claude » sont ceux choisis par Bertrand le 2026-10-26 (T85), à la place de « Anthropic account » et « Gmail APEXUS » (T63).

## Faire évoluer un flux

- Le code des nœuds vit dans code/noeuds/ et code/lib/ ; `node --test code/test/*.test.js` le teste hors n8n.
- `node code/assembler.js <flux>` produit le source SDK complet dans code/dist/ ; `node code/operations.js "Nom du nœud=script"` produit les opérations de mise à jour (paramètres remplacés en entier).
- Après publication : télécharger le flux, `node code/comparer.js <flux.json>` vérifie que le code en ligne est celui du dépôt, `node code/exporter.js <flux.json>` écrit l'export dans workflow/ en refusant tout secret.

## Configuration (table iacave_config)

| Clé | Valeur par défaut | Rôle |
| --- | --- | --- |
| ~~cle_app~~ | plus lue (T126) | ancienne clé partagée |
| fenetre_secondes | 300 | écart maximal d'horodatage |
| quota_enrichissements | 100 | plafond global du mois, toutes installations : sert à l'alerte de coût |
| quota_prix | 120 | idem pour les prix |
| quota_gratuit_enrichissements, quota_gratuit_prix | 10, 10 | par compte gratuit et par mois (T127) |
| quota_abonne_enrichissements, quota_abonne_prix | 500, 500 | par compte abonné et par mois |
| codes_par_heure | 5 | codes de connexion par adresse et par heure |
| cle_session_jours | 180 | durée d'une session |
| seuil_alerte | 0.8 | mail d'alerte de quota |
| email_alerte | apexus.bertrand@gmail.com | destinataire des alertes |
| remontees_par_jour | 5 (valeur prise si la ligne manque) | remontées par jour et par compte |

## Avant chaque mise en production du flux

- [ ] `python3 scripts/valider_contrat.py` et `node --test n8n/code/test/*.test.js` passent.
- [ ] Les 30 cas de n8n/jeu-essai/ tournent et atteignent les cibles de docs/06-agent-n8n.md.
- [ ] Export JSON du flux déposé dans workflow/ (`code/exporter.js`), conforme au code (`code/comparer.js`), version incrémentée dans /sante.
- [ ] Flux republié après modification, puis appel réel à /sante.
