# Flutter-specific ProGuard rules
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter engine references Google Play Core split-install classes for deferred
# components. This app does not use deferred components, so suppress the warning
# to prevent R8 from failing with "missing class" errors at minification.
-dontwarn com.google.android.play.core.**

# Keep Hive model classes (prevents obfuscation of @HiveType fields)
-keep class **$HiveFieldAdapter { *; }
-keepnames class ** implements com.google.gson.TypeAdapterFactory
-keepnames class ** implements com.google.gson.JsonSerializer
-keepnames class ** implements com.google.gson.JsonDeserializer

# Keep classes used by flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep home_widget classes
-keep class es.antonborri.home_widget.** { *; }

# Keep geolocator / location classes
-keep class com.baseflow.geolocator.** { *; }

# Keep just_audio classes
-keep class com.ryanheise.just_audio.** { *; }

# General Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-dontwarn okhttp3.**
-dontwarn okio.**
