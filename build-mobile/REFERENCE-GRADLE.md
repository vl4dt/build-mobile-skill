# Gradle, KMP & Android Templates Reference

## Version Discovery

**ALWAYS check these before pinning any version:**

```bash
sdkmanager --list
./gradlew --version
```

Check online:
- AGP: https://developer.android.com/studio/releases/gradle-plugin
- Kotlin: https://kotlinlang.org/docs/releases.html
- Compose BOM: https://developer.android.com/jetpack/androidx/releases/compose-kotlin
- Flutter/Dart: `flutter --version`

## Root build.gradle.kts

```kotlin
plugins {
    // @version-check AGP — EXAMPLE pin, verify: https://developer.android.com/studio/releases/gradle-plugin
    id("com.android.application") version "8.12.1" apply false
    // @version-check Kotlin — EXAMPLE pin, verify: https://kotlinlang.org/docs/releases.html
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false
    // @version-check KSP (must match Kotlin version) — EXAMPLE pin, verify
    id("com.google.devtools.ksp") version "2.1.20-2.0.2" apply false
}
```

> **Compatibility:** AGP 8.12+ requires Kotlin 2.1+, JDK 17+, Gradle 8.14+.

## KMP Root build.gradle.kts

```kotlin
plugins {
    // @version-check AGP — EXAMPLE pin, verify
    id("com.android.library") version "8.12.1" apply false
    // @version-check Kotlin — EXAMPLE pin, verify
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false
    // @version-check KMP — EXAMPLE pin, verify
    id("org.jetbrains.kotlin.multiplatform") version "2.1.20" apply false
    // @version-check KSP — EXAMPLE pin, verify
    id("com.google.devtools.ksp") version "2.1.20-2.0.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

> **ALWAYS use `org.jetbrains.kotlin.multiplatform` plugin — never manually stitch KMP source sets.**

## shared/build.gradle.kts (KMP Library)

```kotlin
plugins {
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")
    id("com.google.devtools.ksp")
}

kotlin {
    jvm()
    iosArm64()
    iosSimulatorArm64()
    // js(), wasmJs()

    sourceSets {
        commonMain.dependencies {
            // @version-check kotlinx-serialization — EXAMPLE pin, verify: https://github.com/Kotlin/kotlinx.serialization
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0")
            // @version-check Ktor — EXAMPLE pin, verify: https://ktor.io
            implementation("io.ktor:ktor-client-core:3.1.0")
            // @version-check kotlinx-coroutines — EXAMPLE pin, verify: https://kotlin.github.io/kotlinx.coroutines/
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.1")
        }
        commonTest.dependencies {
            implementation(kotlin("test"))
        }
        androidMain.dependencies {
            // @version-check Ktor Android — EXAMPLE pin, verify
            implementation("io.ktor:ktor-client-android:3.1.0")
        }
        jvmMain.dependencies {
            // @version-check Ktor JVM — EXAMPLE pin, verify
            implementation("io.ktor:ktor-client-jdkhttp:3.1.0")
        }
        iosMain.dependencies {
            // @version-check Ktor Darwin — EXAMPLE pin, verify
            implementation("io.ktor:ktor-client-darwin:3.1.0")
        }
    }
}

android {
    namespace = "com.example.shared"
    compileSdk = 36
    defaultConfig { minSdk = 26 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    kotlinOptions { jvmTarget = "21" }
}
```

## app/build.gradle.kts (Compose)

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.example.app"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }
    buildFeatures { compose = true }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    kotlinOptions { jvmTarget = "21" }
    packaging { resources { excludes += "/META-INF/{LICENSE,NOTICE}.md" } }
}

dependencies {
    // @version-check Compose BOM — EXAMPLE pin, verify: https://developer.android.com/jetpack/androidx/releases/compose-kotlin
    val composeBom = platform("androidx.compose:compose-bom:2025.06.01")
    implementation(composeBom)
    androidTestImplementation(composeBom)
    // @version-check activity-compose — EXAMPLE pin, verify
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    // @version-check lifecycle-viewmodel-compose — EXAMPLE pin, verify
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.0")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
}
```

> **Notes:** AGP 8.12+ requires JDK 17+ (JDK 21 rec.), Kotlin 2.1+. Compose BOM 2025.06.01+ works with AGP 8.2+.
> `composeOptions { kotlinCompilerExtensionVersion }` is deprecated with Kotlin 2.x (bundled).

## settings.gradle.kts

```kotlin
pluginManagement {
    repositories { google(), mavenCentral(), gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(), mavenCentral() }
}
rootProject.name = "MyApp"
include(":app")
```

## gradle.properties

```properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
android.defaults.buildfeatures.buildconfig=true
android.nonFinalResIds=false
```

## Common Android Dependencies

| Library | Dependency | Notes |
|---|---|---|
| Room | `androidx.room:room-runtime:2.7.2` + ksp `room-compiler` | // @version-check Room — EXAMPLE pin |
| Navigation | `androidx.navigation:navigation-compose:2.9.0` | // @version-check Nav — EXAMPLE pin |
| Hilt | `com.google.dagger:hilt-android:2.56.2` + ksp `hilt-compiler` | // @version-check Hilt — EXAMPLE pin |
| Retrofit | `com.squareup.retrofit2:retrofit:2.12.0` + `converter-gson` | // @version-check Retrofit — EXAMPLE pin |
| Coil | `io.coil-kt:coil-compose:2.7.0` | // @version-check Coil — EXAMPLE pin |
| DataStore | `androidx.datastore:datastore-preferences:1.1.6` | // @version-check DataStore — EXAMPLE pin |
| WorkManager | `androidx.work:work-runtime-ktx:2.10.1` | // @version-check WorkManager — EXAMPLE pin |

## KMP Dependencies

| Library | Dependency | Target | Notes |
|---|---|---|---|
| Ktor Client (core) | `io.ktor:ktor-client-core:3.1.0` | commonMain | // @version-check Ktor — EXAMPLE pin |
| Ktor (Android) | `io.ktor:ktor-client-android:3.1.0` | androidMain | // @version-check Ktor Android — EXAMPLE pin |
| Ktor (JVM) | `io.ktor:ktor-client-jdkhttp:3.1.0` | jvmMain | // @version-check Ktor JVM — EXAMPLE pin |
| Ktor (Darwin) | `io.ktor:ktor-client-darwin:3.1.0` | iosMain | // @version-check Ktor Darwin — EXAMPLE pin |
| Ktor Mock | `io.ktor:ktor-client-mock:3.1.0` | commonTest | // @version-check Ktor Mock — EXAMPLE pin |
| Ktor Negotiation | `io.ktor:ktor-client-content-negotiation:3.1.0` | commonMain | // @version-check Ktor Negotiation — EXAMPLE pin |
| Serialization | `org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0` | commonMain | // @version-check Serialization — EXAMPLE pin |
| Coroutines | `org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.1` | commonMain | // @version-check Coroutines — EXAMPLE pin |
| DateTime | `org.jetbrains.kotlinx:kotlinx-datetime:0.6.2` | commonMain | // @version-check DateTime — EXAMPLE pin |
| Koin | `io.insert-koin:koin-core:4.0.2` | commonMain | // @version-check Koin — EXAMPLE pin, verify KMP compat |
| Kotest | `io.kotest:kotest-framework-engine:5.10.0` | commonTest | // @version-check Kotest — EXAMPLE pin |

> **ALWAYS verify KMP dependencies against the Kotlin version being used.** Not all JVM libs have KMP-compatible builds. All version pins in this document are EXAMPLES and must be checked before use.

## ADB Commands

```bash
adb install -r path/to/app.apk
adb uninstall com.example.app
adb shell pm clear com.example.app
adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png
adb push localfile /sdcard/remote_file
adb pull /sdcard/remote_file ./localfile
adb shell dumpsys gfxinfo com.example.app           # performance
adb shell dumpsys meminfo com.example.app            # memory
adb shell am start -W com.example.app/.MainActivity  # cold start
```

## Emulator Commands

```bash
emulator -avd Pixel_9 -no-window -no-audio -gpu swiftshader_indirect
avdmanager list avd
sdkmanager --install "system-images;android-36;google_apis;x86_64"
avdmanager create avd -n MyPixel -k "system-images;android-36;google_apis;x86_64"
adb emu kill
```

## Release Build

```kotlin
// app/build.gradle.kts
android {
    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = findProperty("KEYSTORE_PASSWORD") as String?
            keyAlias = findProperty("KEY_ALIAS") as String?
            keyPassword = findProperty("KEY_PASSWORD") as String?
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```
