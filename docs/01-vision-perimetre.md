# 01. Vision et périmètre

## Le produit en une phrase

IA cave à vin : on photographie une étiquette, la fiche du vin se remplit presque seule, et la cave se gère ensuite hors ligne sur le téléphone.

## Pour qui

- Phase 1 (ce cahier des charges) : Bertrand et son foyer, une cave privée de quelques centaines de bouteilles (170 références environ au départ), plusieurs propriétaires possibles.
- Phase 2 (docs/10-evolutions.md) : particuliers sur les stores, puis caves professionnelles.

## Plateformes

Android d'abord. iOS ensuite sans réécriture : une seule base de code Flutter dès le premier jour.
Pas de publication sur Google Play au départ (décision D5) : l'app est installée en direct (APK) et testée jusqu'à ce qu'elle soit complète.

## Ce que l'utilisateur saisit lui-même

Prix d'achat, quantité, format s'il diffère de 75 cl, emplacement, propriétaire. Tout le reste vient de l'étiquette ou de l'agent n8n, et se valide d'un geste.

## Principes directeurs

En cas de doute, ces principes tranchent, dans cet ordre.

1. Local-first. Données et photos vivent sur le téléphone. Le réseau sert uniquement à l'enrichissement et aux prix. Liste, fiche, stock, statistiques, PDF et Excel fonctionnent en mode avion.
2. L'étiquette fait foi. Ce qui est lu sur la bouteille prime sur toute source web. Un désaccord est signalé, jamais tranché en silence.
3. Rien sans source. Chaque valeur enrichie connaît son origine, son URL, sa date et un indice de confiance. Une valeur introuvable reste vide et le dit. Aucune note critique n'est estimée ni inventée.
4. La saisie manuelle n'est jamais écrasée. Un champ modifié à la main est verrouillé face aux ré-enrichissements, sauf déverrouillage explicite.
5. Une fiche, plusieurs lots, des mouvements. La fiche décrit le vin (cuvée + millésime). Le stock vit dans des lots. Un lot n'évolue que par des mouvements datés et motivés.
6. Gratuit d'abord. Aucune source payante en phase 1 (décisions D2 et D3). Le seul coût variable est l'appel au modèle IA déjà présent sur l'instance n8n.
7. Prêt pour la suite. UUID partout, horodatage, suppression logique, cave_id sur chaque table : synchronisation, comptes et multi-caves n'imposeront pas de migration lourde.

## Dans le périmètre

Liste et tris, fiche vin, ajout par photo avec enrichissement, stock et corrections, emplacements, propriétaires, prix d'achat et historique de prix marché, statistiques façon BI, PDF unitaire et catalogue, export et import Excel, paramétrage des listes, sauvegarde et restauration, fonctions de confort (à boire, alertes, code-barres, liste d'achats, dégustations). Détail : docs/05-fonctionnel.md.

## Hors périmètre de la phase 1

Comptes utilisateurs, synchronisation entre appareils, achat ou vente de vin dans l'app, gestion professionnelle, fonctions sociales, publication sur les stores, iOS.

## Glossaire

| Terme | Sens dans ce projet |
| --- | --- |
| Fiche vin | Une cuvée d'un domaine pour un millésime. C'est la ligne de la liste. |
| Cuvée | Le vin générique d'un domaine, sans millésime (domaine + nom de cuvée + appellation + couleur). |
| Lot | Des bouteilles identiques d'une fiche : même format, propriétaire, emplacement, prix d'achat. |
| Mouvement | Entrée, ouverture, sortie, ajustement ou transfert. Immuable. |
| Provenance | Origine d'une valeur : étiquette, site officiel, organisme officiel, interprofession, critique, marchand, tiers, estimation, manuel, import. |
| Garde | Fenêtre de dégustation : début, apogée, fin (années). |
| NM | Non millésimé (champagne brut sans année, par exemple). |
| EAN | Code-barres à 13 chiffres. Indice d'identification, jamais une clé fiable. |
| LWIN | Identifiant ouvert et gratuit d'un vin (LWIN7) ou d'un vin et de son millésime (LWIN11), géré par Liv-ex. |
| Job | Un appel au flux n8n (enrichissement ou prix), suivi de façon asynchrone. |
