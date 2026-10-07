import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================
// KEY PROPERTIES
// ============================================================

val keystoreProperties = Properties()

val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {

    namespace = "com.premmotors.assetaudit"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    // ==========================================================
    // COMPILE OPTIONS
    // ==========================================================

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ==========================================================
    // DEFAULT CONFIG
    // ==========================================================

    defaultConfig {

        applicationId = "com.premmotors.assetaudit"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    // ==========================================================
    // SIGNING CONFIG
    // ==========================================================

    signingConfigs {

        create("release") {

            keyAlias =
                keystoreProperties["keyAlias"] as String

            keyPassword =
                keystoreProperties["keyPassword"] as String

            storeFile =
                keystoreProperties["storeFile"]?.let {
                    file(it)
                }

            storePassword =
                keystoreProperties["storePassword"] as String
        }
    }

    // ==========================================================
    // BUILD TYPES
    // ==========================================================

    buildTypes {

        getByName("release") {

            // IMPORTANT:
            // Debug signing removed
            // Release keystore used here

            signingConfig =
                signingConfigs.getByName("release")
        }
    }
}

// ============================================================
// FLUTTER
// ============================================================

flutter {
    source = "../.."
}