-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Google Play Services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Kotlin metadata
-keep class kotlin.Metadata { *; }
