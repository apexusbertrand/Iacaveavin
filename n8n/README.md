# Flux n8n IA_CAVE_Agent

Ce dossier contient tout ce qu'il faut pour construire et faire évoluer le flux d'enrichissement sur l'instance n8n actuelle d'Apexus. Spécification : docs/06-agent-n8n.md. Contrat : specs/contrat-n8n/.

| Fichier | Rôle |
| --- | --- |
| prompt-agent-enrichissement.md | prompt système de l'agent d'enrichissement |
| prompt-agent-prix.md | prompt système de l'agent prix |
| sources-autorisees.yaml | domaines consultables, avec leur statut de vérification |
| workflow/ | export JSON du flux à chaque version (`IA_CAVE_Agent_v<version>.json`) |
| jeu-essai/ | photos d'étiquettes réelles et résultats attendus |

## Découpage du flux

1. Webhook POST `iacave/enrichissement` : contrôles d'entrée (en-têtes, horodatage, HMAC, request_id, quota, schéma), création du job, stockage temporaire des photos, réponse immédiate (Respond to Webhook) avec `statut: en_attente`.
2. Traitement asynchrone (sous-flux `IA_CAVE_Enrichissement`) : lecture des étiquettes, normalisation, cache, agent d'enrichissement avec outils de recherche et de lecture de pages, agent prix si demandé.
3. Contrôles de sortie (nœud Code) : URL citées présentes dans `sources_consultees`, domaines de prix autorisés, bornes des valeurs, validation contre `resultat_enrichissement`. Une sortie invalide relance l'agent une fois avec le message d'erreur, puis passe le job en `erreur`.
4. Écriture du résultat dans `iacave_jobs`, du cache, du quota ; effacement des photos.
5. Webhook GET `iacave/jobs?job_id=…` : lecture du job (paramètre de requête, voir T63).
6. Webhook POST `iacave/prix` : même chaîne, sous-flux `IA_CAVE_Prix`, cache de 24 heures.
7. Webhook GET `iacave/sante` : version du flux et du contrat.
8. Flux d'erreur : mail d'alerte avec le job_id, sans les photos.

## Configuration

| Paramètre | Valeur par défaut | Où |
| --- | --- | --- |
| Clé secrète partagée avec l'app | générée (32 octets aléatoires, base64) | credential `IA_CAVE_Cle_App` |
| Fenêtre d'horodatage | 300 s | variable du flux |
| Quota mensuel d'enrichissements | 100 | table de configuration |
| Quota mensuel de prix | 120 | table de configuration |
| Seuil d'alerte de quota | 80 % | table de configuration |
| Outil de recherche | Tavily, offre gratuite | credential `IA_CAVE_Tavily` |
| Modèle vision | modèle vision déjà configuré sur l'instance | credential existant, utilisé en lecture seule |

## Avant chaque mise en production du flux

- [ ] `python3 scripts/valider_contrat.py` passe (schémas et exemples à jour).
- [ ] Les 30 cas de n8n/jeu-essai/ tournent et atteignent les cibles de docs/06-agent-n8n.md.
- [ ] Export JSON du flux déposé dans workflow/ et numéro de version incrémenté dans /sante.
- [ ] Flux republié après modification, puis appel réel à /sante depuis l'app (bouton « Tester la connexion »).
