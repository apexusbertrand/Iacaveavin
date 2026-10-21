# 10. Évolutions

Trois évolutions prévues, à ne pas développer maintenant. Le modèle de la phase 1 les prépare : cave_id, UUID, horodatage et suppression logique sur toutes les tables, contrat n8n versionné, passerelle d'enrichissement remplaçable.

## 10.1 Cave professionnelle

Cible : caviste, restaurant, cave d'entreprise.

- Plusieurs caves et sites, transferts entre caves.
- Multi-utilisateurs avec rôles (lecture, sommelier, gestionnaire, administrateur) et journal d'audit.
- Valorisation du stock au coût moyen pondéré ou en premier entré, premier sorti. Inventaires périodiques signés, écarts valorisés.
- Entrées rattachées aux bons de livraison et factures, sorties rattachées aux ventes ou à la carte des vins.
- Étiquettes internes à code-barres ou QR par bouteille ou par casier, lecture en rafale.
- Seuils de réassort et propositions de commande.
- Interfaces avec caisse, ERP et comptabilité (export des mouvements valorisés), carte des vins publiée.
- Interface web de gestion en complément du mobile.

## 10.2 Authentification et synchronisation

- Comptes par e-mail, Google ou Apple.
- Synchronisation entre appareils avec résolution des conflits, hors ligne conservé.
- Cave partagée en famille, droits par personne.
- Sauvegarde cloud chiffrée et automatique.
- n8n reste l'orchestrateur de l'enrichissement. Une base managée (Supabase ou Firebase par exemple) porte comptes et synchronisation, choix à faire le moment venu.
- La clé partagée disparaît : quotas et sécurité passent au niveau du compte.

## 10.3 Commercialisation

- Freemium : cave locale gratuite et quelques enrichissements par mois. Abonnement pour l'illimité, les prix, le catalogue PDF, la synchronisation.
- Les sources gratuites de la phase 1 (notes citées, pages marchandes publiques, offre gratuite de recherche) ne tiennent pas à l'échelle d'un produit vendu. Prévoir des licences : notes critiques (l'API Robert Parker existe via Liv-ex pour ses membres professionnels), prix (API destinées aux marchands), recherche web en offre payante.
- Coûts variables à couvrir : modèle IA, recherche web, licences, hébergement n8n. Le coût moyen mesuré au lot 2b sert de base au prix.
- Paiement par Google Play Billing et par les achats intégrés Apple pour toute fonction numérique vendue dans l'app, commission des stores comprise dans le calcul.
- Juridique : CGU, CGV, politique de confidentialité, contrats de sous-traitance RGPD avec l'hébergeur et le fournisseur IA, dépôt de marque après recherche d'antériorité.
- Marque blanche pour cavistes (leur logo, leurs couleurs), dans la continuité du métier d'Apexus.
