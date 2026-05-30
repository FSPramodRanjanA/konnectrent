# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_bloc / equatable
-keep class com.google.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# Shared Preferences
-keep class androidx.datastore.** { *; }

# Keep all model classes (Dart compiled)
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn sun.misc.**

# Flutter references Play Core split-install classes for deferred components.
# This app does not use deferred components, so suppress the missing-class errors.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
