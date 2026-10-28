# AJO-14 : ML Kit référence les modèles de texte chinois, devanagari, japonais
# et coréen, que l'app n'embarque pas (alphabet latin seul). Sans ces lignes,
# R8 échoue sur les classes absentes à la build release.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
