# Journal des décisions

Une ligne par décision, la plus récente en bas. Une décision ne s'efface pas : une décision qui en remplace une autre la cite. Claude Code ajoute ici toute décision technique qui change le sens d'un document, et la soumet à Bertrand.

## Décisions de Bertrand (2026-10-20)

| Id | Décision | Conséquence dans le cahier des charges |
| --- | --- | --- |
| D1 | Nom de l'application : IA cave à vin | identifiant Android `fr.apexus.iacaveavin`, dépôt `IA-cave-a-vin`, schéma de lien `iacaveavin://` |
| D2 | Notes Parker : uniquement ce qui est gratuit, rien de payant dans un premier temps | notes en accès libre ou citées par le domaine ou un marchand (`acces`, `citee_par`) ; pas de licence Liv-ex ; jamais de note estimée |
| D3 | Prix marché : sites publics de vente en ligne | agent prix limité aux marchands de n8n/sources-autorisees.yaml, millésime vérifié sur la page, médiane des offres, « non trouvé » plutôt qu'une estimation |
| D4 | Hébergement : un nouveau flux dans l'instance n8n actuelle | flux `IA_CAVE_Agent` isolé (identifiants, tables, flux d'erreur et quotas propres) |
| D5 | Pas de compte Google Play au départ ; publication une fois l'ensemble testé | distribution directe de l'APK par releases GitHub, clé de signature créée dès le lot 0, publication reportée au lot 6 |

## Décisions techniques (V3, 2026-10-20)

| Id | Décision | Raison |
| --- | --- | --- |
| T1 | Flutter, une base de code Android et iOS | portage iOS sans réécriture |
| T2 | Local-first : SQLite et photos sur le téléphone | usage en cave sans réseau, aucune donnée de cave sur un serveur |
| T3 | Appels au flux asynchrones (job + suivi) avec idempotence | un agent qui consulte plusieurs sites dépasse 30 s |
| T4 | specs/dictionnaire-donnees.yaml source unique des champs | base, Excel, PDF et contrat ne divergent plus |
| T5 | Contrat n8n en JSON Schema, validé des deux côtés | erreurs de format détectées avant l'enregistrement |
| T6 | Garde estimée en local par specs/regles-garde.yaml, jamais par l'agent | résultat déterministe, hors ligne, modifiable sans IA |
| T7 | Phase 1 : clé partagée saisie dans les Réglages + signature HMAC | app non publiée ; une clé par installation n'apporterait rien sans comptes |
| T8 | Recherche web par Tavily (offre gratuite, 1 000 crédits par mois), outil interchangeable | offre mensuelle renouvelée, sans carte bancaire, pensée pour les agents ; Brave n'est plus gratuit depuis février 2026 ; Exa ou Firecrawl restent des solutions de repli gratuites |
| T9 | Stockage des jobs dans les tables n8n ou Postgres, pas dans Google Sheets | latence, concurrence, bug de cache connu du nœud Sheets |
| T10 | Quotas mensuels : 100 enrichissements, 120 relevés de prix | tenir dans l'offre gratuite de recherche web |

## À compléter

| Id | Sujet | Quand |
| --- | --- | --- |
| Q1 | Valeurs exactes des couleurs Apexus extraites du logo | lot 0 |
| Q2 | Validation des règles de garde par défaut (specs/regles-garde.yaml) | avant la fin du lot 1 |
| Q3 | Vérification des domaines candidats de n8n/sources-autorisees.yaml | lot 2b |
| Q4 | Coût moyen d'un enrichissement en appels au modèle IA | fin du lot 2b |
| Q5 | Publier ou non sur Google Play, compte personnel ou organisation | fin du lot 5 |
