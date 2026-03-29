import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")

}

android {
    namespace = "com.rebtal.app"
    compileSdk = 36
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rebtal.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Keep secrets (like Maps key) out of source-control.
        // Provide it via:
        // - gradle.properties: MAPS_API_KEY=...
        // - OR environment variable: MAPS_API_KEY=...
        // If empty, maps may not work until you add it.
        manifestPlaceholders["MAPS_API_KEY"] =
            (project.findProperty("MAPS_API_KEY") as String?)
                ?: System.getenv("MAPS_API_KEY")
                ?: ""
    }

    signingConfigs {
        create("release") {
            // Uses android/key.properties (ignored by git) if present.
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val props = Properties()
                keystorePropertiesFile.inputStream().use { stream ->
                    props.load(stream)
                }
                storeFile = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
                keyAlias = props["keyAlias"] as String
                keyPassword = props["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // For Play Store you must sign with a release keystore (key.properties).
            val keystorePropertiesFile = rootProject.file("key.properties")
            signingConfig =
                if (keystorePropertiesFile.exists()) {
                    signingConfigs.getByName("release")
                } else {
                    // Allows local release builds to succeed, but NOT store uploads.
                    signingConfigs.getByName("debug")
                }

            // Keep size reasonable for store releases.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
