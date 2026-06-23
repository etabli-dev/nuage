# Application + MainActivity are referenced from AndroidManifest.xml so AGP
# keeps them automatically. Compose, DataStore, EncryptedSharedPreferences,
# WorkManager and the platform HttpURLConnection ship consumer ProGuard
# rules. The only app-specific keep we need is for data classes whose JSON
# field names matter — obfuscating those breaks the on-disk log format.

-keep class com.raban.etabli.probe.engine.** { *; }
-keep class com.raban.etabli.probe.net.** { *; }

-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Tink (transitive of androidx.security:security-crypto) references
# Google error-prone annotations that we don't ship.
-dontwarn com.google.errorprone.annotations.**
-dontwarn com.google.crypto.tink.**
-keep class com.google.crypto.tink.** { *; }
