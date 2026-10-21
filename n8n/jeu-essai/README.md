# Jeu d'essai de l'agent

30 bouteilles réelles de la cave, photographiées dans les conditions normales d'usage (cave peu éclairée comprise). À constituer par Bertrand avant le lot 2b.

Pour chaque bouteille, un dossier `NN-domaine-millesime/` contenant :

- `etiquette.jpg`, et si utile `contre-etiquette.jpg`, `capsule.jpg` ;
- `attendu.json` : les valeurs justes pour domaine, cuvée, appellation, signe de qualité, classement, millésime, couleur, et, si connues, cépages, degré, note Parker publiée.

Répartition visée : 6 Bordeaux, 6 Bourgogne, 3 Alsace, 3 Rhône, 3 Champagne, 3 Loire, 3 étrangers, 3 étiquettes difficiles (abîmées, manuscrites, à contre-jour).

Un script (à écrire au lot 2b) envoie chaque dossier au flux, compare la réponse à `attendu.json` et produit un rapport : taux de bonnes réponses par champ, notes sans source, prix d'un autre millésime, durée et crédits consommés. Ce rapport est joint à la recette du lot 2b.
