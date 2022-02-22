#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-dontwarn com.google.common.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
-dontwarn android.content.pm.**
-dontwarn android.app.ActivityManager**
-dontwarn android.security.keystore.StrongBoxUnavailableException
-dontwarn android.security.keystore.**
-ignorewarnings