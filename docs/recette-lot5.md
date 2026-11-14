# Recette du lot 5 : recette élargie

État au 2026-11-14, branche lot-5-recette. Ce document suit les exigences non fonctionnelles (docs/07), la recette transverse (docs/08) et les vérifications à faire sur téléphone. Les testeurs ont leur guide : store/guide-testeurs.md.

## Mesures sur 5 000 fiches

Outil : `flutter test tool/recette/mesures_5000_test.dart` depuis app/. Cave de démonstration générée à 5 000 fiches (6 277 lots, 8 785 mouvements). Machine de développement, sans interface : les chiffres donnent l'ordre de grandeur, le téléphone sera plus lent.

| Mesure | Résultat | Cible |
| --- | --- | --- |
| Insertion de la cave | 507 ms | - |
| Chargement de la liste complète | 522 ms (339 ms au second) | part du démarrage sous 2 s |
| Filtre couleur et millésime, puis tri | 38 ms | 300 ms |
| Recherche texte | 15 ms | 300 ms |
| Ouverture d'une fiche | 40 ms | 500 ms |
| Statistiques, lecture des faits | 168 ms | 1 s (STA-06) |
| Statistiques, agrégat couleur × millésime | 24 ms | - |
| Export Excel complet | 1 164 ms, 1,8 Mo | en isolate |
| Archive de sauvegarde sans photos | 131 ms, 2,5 Mo | - |
| Catalogue PDF de 200 fiches | sous 30 s (test PDF-05) | 30 s |

Point d'attention : le chargement de la liste est le poste le plus lourd. Sur un téléphone d'entrée de gamme, il peut prendre 3 à 4 fois plus : à vérifier sur le téléphone avec une grosse cave (étape 2 ci-dessous).

## Exigences non fonctionnelles

| Exigence | État | Preuve |
| --- | --- | --- |
| NFR-01 Performance | mesurée sur machine, à confirmer sur téléphone | mesures ci-dessus ; démarrage à froid et fluidité de la liste : téléphone |
| NFR-02 Isolates | PDF, Excel, photos, archives : conforme. Statistiques calculées sur le fil principal | test NFR-02 ; écart proposé : garder les statistiques sur le fil principal, 168 ms sur 5 000 fiches |
| NFR-03 Hors ligne | conforme | tests AJO-09 NFR-03 |
| NFR-04 Photos | conforme | tests photo_test |
| NFR-05 Données | conforme | tests de migration NFR-05 |
| NFR-06 Sécurité | conforme | test ci_test, APK obfusqué (CI) |
| NFR-07 Contrat | conforme | tests AJO-12 NFR-07 |
| NFR-08 Consentement | conforme | parcours photo NFR-08 |
| NFR-09 Vie privée | conforme | test NFR-09 (aucun SDK d'audience ou de publicité) |
| NFR-10 Accessibilité | contraste conforme ; TalkBack, police à 200 %, cibles 48 dp à vérifier sur téléphone | tests contrast_test ; étapes 5 et 6 ci-dessous |
| NFR-11 Langues | conforme, anglais livré | lot 5b, tests LNG-01 à LNG-05 |
| NFR-12 Portabilité | non vérifiable ici : pas de Mac ni de CI macOS | lot 7 |
| NFR-13 Tests | conforme, 437 tests au vert | test NFR-13 |
| NFR-14 Traçabilité | 153 exigences couvertes sur 156 ; restent NFR-12 (lot 7), STK-R4 et NOT-R4, vérifiées sous d'autres identifiants (STK, LST-04) | docs/matrice-exigences.md |
| NFR-15 Industrialisation | conforme | CI GitHub Actions |
| NFR-16 Contenu IA | conforme | tests FIC-07 NFR-16 |
| NFR-17 Modération | conforme | mention dans À propos, test NFR-17 |
| NFR-18 Conformité store | conforme | tests NFR-18, CPT-08 |

## Recette transverse (docs/08)

| Point | Vérification |
| --- | --- |
| Vin courant photographié juste, en ne saisissant que prix, quantité, emplacement, propriétaire | testeurs (scénario 2 du guide) ; parcours photo automatisé |
| Aucune valeur enrichie sans source consultable | automatique : recetteViolations (test/recette), sur 5 000 fiches et une fiche enrichie |
| Champ modifié à la main jamais écrasé | tests PRV-R2, PRV-R3 |
| Stock affiché égal à la somme des mouvements | automatique : recetteViolations, 5 000 fiches puis 30 mouvements |
| Mode avion | tests AJO-09 NFR-03 ; testeurs (scénario 6) |
| Tris millésime, couleur, Parker, vins sans note en fin | tests LST-04, NOT-R1 |
| Simulation d'import Excel exacte, import en erreur sans effet | tests XLS |
| Catalogue PDF 2 fiches par page, filtres en page de garde | tests PDF-02, PDF-03 |
| Aucune clé technique à l'écran ni dans un export | tests NFR-11, recetteViolations, LNG-01 |
| Archive restaurée sur un autre téléphone à l'identique | tests SAV ; Bertrand au passage à la version Play Store |
| Contraste WCAG AA | test contrast_test |
| Aucune note ni aucun prix relevé sans URL | automatique : recetteViolations. Un prix saisi à la main (PRX-07) n'a pas d'URL : c'est une valeur de l'utilisateur |

## À vérifier sur le téléphone (Bertrand)

1. Démarrage à froid avec ta cave réelle : moins de 2 s jusqu'à la liste.
2. Faire défiler la liste de ta cave : pas de saccade. Pour tester une grosse cave : exporter d'abord une sauvegarde, importer un classeur de test de 5 000 fiches (je le génère sur demande depuis tool/recette), mesurer, puis restaurer la sauvegarde. La version publiée n'a pas de démo à charger (NFR-18).
3. Ouvrir une fiche, appliquer un filtre : réponse immédiate.
4. Générer le catalogue PDF de toute la cave : le téléphone reste utilisable pendant la génération.
5. Réglages Android > Accessibilité > taille de police au maximum : aucun texte coupé sur la liste, une fiche, les paramètres.
6. TalkBack activé : la liste, une fiche et le bouton « + » sont lus correctement.
7. Mode avion : liste, fiche, ouverture d'une bouteille, statistiques, PDF fonctionnent ; une photo d'étiquette crée une fiche « à enrichir ».

## Critère de sortie

4 semaines d'usage par 3 à 5 testeurs, aucun bug bloquant ouvert, décision écrite de publier (déjà prise, T123, à confirmer). Suivi dans docs/journal-lots.md, lot 5.
