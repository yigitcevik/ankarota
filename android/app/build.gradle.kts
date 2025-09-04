import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

// Try multiple possible paths for .env file
val envFile = rootProject.file("../.env")
val envProperties = Properties()
println("🔍 DEBUG: Looking for .env file at: ${envFile.absolutePath}")
println("🔍 DEBUG: .env file exists: ${envFile.exists()}")

if (envFile.exists()) {
    envFile.reader(Charsets.UTF_8).use { reader ->
        envProperties.load(reader)
    }
    val apiKey = envProperties.getProperty("GOOGLE_MAPS_API_KEY", "NOT_FOUND")
    println("🔍 DEBUG: API Key from .env: ${if (apiKey != "NOT_FOUND") "${apiKey.substring(0, 12)}..." else "NOT_FOUND"}")
    println("🔍 DEBUG: manifestPlaceholders will be set to: $apiKey")
} else {
    println("🔍 DEBUG: .env file not found!")
    println("🔍 DEBUG: Current working directory: ${System.getProperty("user.dir")}")
    println("🔍 DEBUG: Project dir: ${project.projectDir}")
    println("🔍 DEBUG: Root project dir: ${rootProject.projectDir}")
}

android {
    namespace = "com.example.ankarota"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ankarota"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = envProperties.getProperty("GOOGLE_MAPS_API_KEY", "")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
