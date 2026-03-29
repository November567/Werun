import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) load(file.inputStream())
}

android {
    namespace = "com.mapp05.werun"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.mapp05.werun"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Workaround for mergeDebugJavaResource failures caused by duplicate
    // files in dependencies (e.g. META-INF licenses, plugin resources).
    // These duplicates trigger a com.google.common.base.VerifyException during
    // the merge task. Excluding or picking first avoids the crash.
    packaging {
        resources {
            // pickFirst is safer than exclude if a file is actually needed by
            // some library. We limit to a few common problematic patterns.
            pickFirsts += listOf(
                "META-INF/**",
                "LICENSE",
                "LICENSE.txt",
                "NOTICE",
                "NOTICE.txt",
                "dependencies.properties"
            )
            excludes += listOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase
    implementation("com.google.firebase:firebase-core:21.1.1")
    implementation("com.google.firebase:firebase-firestore:24.9.1")
    implementation("com.google.firebase:firebase-storage:20.2.1")
    implementation("com.google.firebase:firebase-auth:22.3.1")
    
    // Google Play Services
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    
    // Others
    implementation("androidx.multidex:multidex:2.0.1")
}