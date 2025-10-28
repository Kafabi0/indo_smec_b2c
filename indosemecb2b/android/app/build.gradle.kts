plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.indosemecb2b"
    compileSdk = 35  // Update ke 34

    compileOptions {
        // ✅ TAMBAHKAN INI - Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.indosemecb2b"
        minSdk = 21  // Minimal 21 untuk notifications
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ TAMBAHKAN INI - Enable multidex (opsional tapi direkomendasikan)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ WAJIB - Core library desugaring untuk Java 8+ APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}