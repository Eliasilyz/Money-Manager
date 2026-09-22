# R8 rules for Flutter release builds.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core is not bundled; Flutter only references it for deferred features.
-dontwarn com.google.android.play.core.**
