# 07. Exigences non fonctionnelles

Seuils mesurés sur un téléphone Android milieu de gamme avec le jeu de démonstration porté à 5 000 fiches. Ce sont des critères de recette.

| Id | Domaine | Exigence |
| --- | --- | --- |
| NFR-01 | Performance | démarrage à froid sous 2 s, liste fluide à 60 images/s, filtre appliqué sous 300 ms, ouverture de fiche sous 500 ms |
| NFR-02 | Performance | PDF, Excel, compression d'images et calculs statistiques lourds dans des isolates, jamais sur le fil de l'interface |
| NFR-03 | Hors ligne | tout fonctionne sans réseau sauf l'enrichissement et les prix, qui passent en file d'attente avec un compteur visible |
| NFR-04 | Photos | répertoire privé de l'app, compression (docs/02-architecture.md), miniatures, suppression en cascade, espace occupé affiché |
| NFR-05 | Données | migrations testées sur une base de la version précédente, intégrité référentielle, suppression logique, aucune perte à la mise à jour |
| NFR-06 | Sécurité | aucun secret dans le code, l'APK ou le dépôt ; clé du flux en stockage sécurisé ; HTTPS seul ; version de diffusion obfusquée |
| NFR-07 | Sécurité | les réponses du flux sont validées contre le schéma avant tout enregistrement (AJO-12) |
| NFR-08 | Vie privée | consentement explicite avant le premier envoi de photos ; aucune donnée personnelle envoyée hormis les photos d'étiquettes ; photos effacées côté n8n après le job |
| NFR-09 | Vie privée | aucune mesure d'audience, aucun SDK publicitaire ; rapports de plantage seulement si l'utilisateur les active, sans aucune donnée de cave |
| NFR-10 | Accessibilité | contraste WCAG AA sur toutes les paires du thème (test automatique), TalkBack, tailles de police jusqu'à 200 %, cibles de 48 dp |
| NFR-11 | Langues | français par défaut, textes dans des fichiers ARB, anglais ajoutable sans toucher au code, formats de date et de nombre locaux |
| NFR-12 | Portabilité | aucune dépendance propre à Android sans équivalent iOS ; build iOS vérifié à la compilation dès qu'un Mac ou une CI macOS est disponible |
| NFR-13 | Tests | tests unitaires sur stock, garde, notes, valeurs, import Excel et statistiques ; tests widgets sur chaque écran et chaque état (docs/03-design-ergonomie.md) ; test d'intégration du parcours photo contre `FakeGateway` ; couverture d'au moins 80 % sur app/lib/domain |
| NFR-14 | Traçabilité | chaque exigence de docs/05-fonctionnel.md est couverte par au moins un test qui porte son identifiant ; la matrice est générée par `scripts/matrice_exigences.py` (à écrire au lot 0) |
| NFR-15 | Industrialisation | `flutter analyze` sans avertissement, formatage `dart format`, CI GitHub Actions qui lance analyse, tests, validation du contrat et build de l'APK à chaque push |
| NFR-16 | Contenu IA | tout texte rédigé par l'agent est marqué comme tel (FIC-07) et peut être signalé (PRV-R4) |
| NFR-17 | Modération | aucune incitation à boire dans l'app ; mention « L'abus d'alcool est dangereux pour la santé, à consommer avec modération » dans l'écran À propos |
