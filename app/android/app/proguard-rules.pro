# AJO-14 : ML Kit référence les modèles de texte chinois, devanagari, japonais
# et coréen, que l'app n'embarque pas (alphabet latin seul). Sans ces lignes,
# R8 échoue sur les classes absentes à la build release.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Plugins appelés depuis Dart par JNI (bindings jnigen : shared_preferences,
# path_provider...). R8 ne voit pas ces appels et retirait les méthodes :
# la v1.0.0 restait figée au démarrage (NoSuchMethodError sur
# SharedPreferencesApiRegistrar.getAll, T125).
-keep class io.flutter.plugins.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
