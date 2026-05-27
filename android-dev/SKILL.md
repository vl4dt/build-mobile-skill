---
name: android-dev
version: 1.0.0
description: Android, Flutter, and Kotlin Multiplatform development toolkit with pre-cached SDK paths, build toolchains, and remote Mac iOS build setup. Use when the user mentions Android, Flutter, iOS, KMP, Kotlin Multiplatform, APK, AAB, Gradle, Compose, emulator, AVD, instrumented tests, Dart, pub, hot reload, state management, Xcode, simulator, IPA, remote Mac, or native Kotlin Android development.
source: github:vladdev/android-dev-skill/android-dev
license: Apache-2.0
---

<!-- Generated badge — do not edit manually -->
<!-- agent-skills.io compatible skill -->

# Android Dev

## 🔴 Golden Rules

1. **ALWAYS prefer SDK tooling over manual file creation.** If the SDK can create, scaffold, or manage it, use the SDK command.
2. **ALWAYS check for latest available versions** of SDK platforms, build tools, plugins, and dependencies before starting work.
3. **ALWAYS ensure compatibility** between all components (SDK ↔ JDK ↔ Gradle ↔ Kotlin ↔ Compose ↔ Flutter ↔ plugins).

## Environment (cached — run `scripts/android-env.sh` to refresh)

| Component | Path / Version |
|---|---|
| SDK | `C:\Users\vl4dt\AppData\Local\Android\Sdk` |
| JDK | Temurin 21.0.3 (`JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.3.9-hotspot\`) |
| Platforms | android-34, android-35, android-36, android-36.1 |
| Build Tools | 33.0.1, 34.0.0, 35.0.0, 36.0.0, 37.0.0 |
| System Images | android-35, android-36 |
| CMake | 4.1.2 |
| Emulator AVDs | `Pixel_9`, `Pixel_9_Pro_XL` |
| Gradle | project-local `gradlew` only (no system gradle) |
| Flutter | 3.44.0 (stable) at `C:\Users\vl4dt\scoop\apps\flutter\3.44.0` |
| Dart | 3.12.0 (bundled with Flutter) |
| React Native | not installed |

### Flutter Targets

| Target | Status | Notes |
|---|---|---|
| Android | ✓ | SDK 36, AVDs available |
| Windows Desktop | ✓ | VS Community 2022, Win10 SDK |
| Web | ✓ | Chrome, Edge |
| iOS | 🟡 Remote Mac needed | MacBook Pro on same network — see Remote Mac section below |
| Linux | ✓ | May need dependencies |
| macOS | 🟡 Remote Mac needed | Same MacBook Pro |

## Pre-flight: Check for Latest Versions

**Before starting ANY task, check what's latest:**

```bash
# Latest Android SDK platforms & build tools
sdkmanager --list

# Latest Flutter version available
flutter channel stable
flutter upgrade --dry-run

# Check Flutter doctor for any issues
flutter doctor --verbose

# Available Gradle wrapper versions
./gradlew --version
```

**Compatibility matrix to verify before changes:**

| Component | Compatible With |
|---|---|
| AGP 8.x | Kotlin 1.9.x+, JDK 11+ (JDK 21 recommended) |
| AGP 7.x | Kotlin 1.5.x-1.8.x, JDK 8+ |
| Flutter 3.44+ | Dart 3.12+, AGP 8.7+ recommended |
| Compose BOM 2024+ | AGP 8.2+, Kotlin 1.9.20+ |
| Kotlin 2.0+ | AGP 8.3+ required |
| Gradle 8.x | AGP 8.x, Kotlin 1.9.x |
| Gradle 9.x | AGP 8.7+, Kotlin 2.1+ |
| KMP (Kotlin 2.1+) | AGP 8.12+, JDK 17+, Gradle 8.14+, AGP 8.12+ for Android target |

---

## 🏗 SDK Tooling — Always Prefer These

### 1. Project Creation

```bash
# Flutter project — ALWAYS use flutter create, never scaffold manually
flutter create my_app --org com.example --platforms android,ios,web,windows,macos,linux
cd my_app

# Add platforms to existing project — use flutter create, not manual edits
flutter create . --platforms ios    # adds iOS to existing project
flutter create . --platforms macos  # adds macOS to existing project

# Native Android project — use android studio project creation or
# flutter create --template=app_plain for minimal Kotlin project
# (No RN installed, skip React Native)
```

### 2. Artifact / Class / File Creation

**Flutter — use `flutter create` to generate new files:**

```bash
# Create a new screen/page widget (generates .dart file with scaffold)
flutter create lib/screens/settings_screen.dart --template=module
# Or use flutter create to scaffold a widget:
flutter create -t package_free --output lib/screens/settings_screen.dart
# Best approach: flutter create a new file using the snippet generator
# Since flutter create doesn't support single files natively,
# use the flutter create template for reusable widgets via a small module,
# then extract. For daily work, the following is preferred:

# Add a new package/dependency — ALWAYS use flutter pub add, NEVER edit pubspec.yaml manually
flutter pub add <package_name>
flutter pub add --dev <package_name>   # dev dependency
flutter pub get                        # fetch after adding

# Create a new Flutter app module (for reusing flutter create templates)
# Then extract needed files
```

**Native Android — use SDK / Gradle tooling:**

```bash
# Create new AVD — ALWAYS use avdmanager, never create manually
avdmanager create avd -n "My_Pixel_9" -k "system-images;android-36;google_apis;x86_64"

# List available system images for the latest API
sdkmanager --list "system-images;android-36;google_apis;x86_64"

# Update SDK components — ALWAYS use sdkmanager, never download manually
sdkmanager "platforms;android-36" "build-tools;37.0.0" "platform-tools"

# Create new Android library module — use gradle or manual structure via sdkmanager
# (Gradle doesn't have a native "new module" command; use the project template approach below)
```

### 3. Dependency Management

```bash
# Flutter — ALWAYS use flutter pub add
flutter pub add dio:^5.7.0
flutter pub add --dev mocktail:^1.0.4
flutter pub upgrade --major-versions     # upgrade all deps, resolve conflicts
flutter pub outdated                     # check for outdated packages

# Native Android / KMP — use Gradle version catalogs or direct dependency declarations
# in build.gradle.kts — update via Gradle's dependency locking / version catalog updates
./gradlew app:dependencies                  # inspect dependency tree
```

### 4. Kotlin Multiplatform (KMP)

```bash
# Create KMP project — ALWAYS use the KMP project template / IDE wizard
# The official Gradle template via SDK tooling:

# Step 1: Create a Kotlin Multiplatform library
# Use the Kotlin Multiplatform Gradle plugin via SDK/Gradle, not manual setup
./gradlew createKmpProject                  # if available via template
# Or use the Kotlin template: kotlin create <project-name> --type library
# (Check kotlinlang.org for the latest CLI template command)

# Step 2: Add platforms — use Gradle, not manual settings.gradle edits
# Add iOS target via Gradle build configuration
# Add JS/Wasm targets via Gradle build configuration

# Step 3: Build KMP artifacts
./gradlew :shared:build                   # build shared module
./gradlew :shared:publishToMavenLocal     # publish for consumption
./gradlew :shared:compileKotlinJvm        # compile JVM target
./gradlew :shared:compileKotlinIosArm64   # compile iOS target

# Step 4: Test KMP code
./gradlew :shared:jvmTest                 # JVM unit tests
./gradlew :shared:iosArm64Test            # iOS native tests
./gradlew :shared:allTests                # all platform tests

# Step 5: Add KMP dependencies
# In shared/build.gradle.kts, use Gradle dependency declarations:
kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation("io.ktor:ktor-client-core:3.1.0")   // ← check latest
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0")  // ← check latest
        }
    }
}
# ALWAYS check kotlinlang.org/releases and Maven Central for latest KMP-compatible versions
```

### 5. Build & Run

```bash
# Gradle (Native/Kotlin) — ALWAYS use gradlew, never system gradle
./gradlew assembleDebug
./gradlew assembleRelease
./gradlew clean

# Run on emulator
emulator -avd Pixel_9 -no-window &
sleep 15 && adb wait-for-device
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.package.name/.MainActivity

# Tests
./gradlew test                          # unit tests
./gradlew connectedAndroidTest          # instrumented (needs running emulator)
```

### 6. Emulator Management

```bash
# Create new AVD with sdkmanager + avdmanager
sdkmanager --install "system-images;android-36;google_apis;x86_64"
avdmanager create avd -n "Pixel_9_API36" -k "system-images;android-36;google_apis;x86_64"

# List all AVDs
avdmanager list avd

# Start / stop
emulator -avd Pixel_9 &
adb emu kill
```

---

## Quick Commands

### Flutter / Dart

```bash
# Run
dart run                                # equivalent of `flutter run` for Dart scripts
flutter run                             # runs on default connected device
flutter run -d windows                  # target specific device
flutter run -d chrome                   # web in Chrome
flutter run -d "Pixel_9"                # specific emulator

# Hot reload is automatic during `flutter run` — just save files

# Build
flutter build apk                       # release APK
flutter build appbundle                 # AAB (Play Store)
flutter build apk --split-per-abi       # separate APKs per ABI
flutter build windows                   # Windows executable
flutter build web                         # web in build/web/
flutter build ios                       # requires macOS

# Testing
flutter test                            # unit + widget tests
flutter test test/widget_test.dart      # specific file
flutter test --coverage                 # with coverage report
flutter drive --target=test_driver/app.dart   # integration tests

# Analyze & fix
flutter analyze                         # static analysis
flutter fix                             # auto-fix warnings
flutter format                          # format code

# Package management
flutter pub add <package>               # add dependency
flutter pub add --dev <package>         # add dev dependency
flutter pub get                         # fetch dependencies
flutter pub upgrade                     # upgrade all
flutter pub deps                        # dependency tree

# Emulators
flutter emulators                       # list
flutter emulators --launch Pixel_9      # launch
flutter devices                         # list connected

# Debug
flutter logs                            # tail device logs
flutter doctor --verbose                # health check
flutter pub cache repair                # fix broken packages

# Compose Testing (Kotlin native)
androidTestImplementation("androidx.compose.ui:ui-test-junit4")
debugImplementation("androidx.compose.ui:ui-test-manifest")
```

---

## Scaffold a New Project

### Flutter

```bash
flutter create my_app --org com.example --platforms android,windows,web
cd my_app
flutter pub get
flutter run                               # run on default device
```

#### Flutter pubspec.yaml essentials

```yaml
name: my_app
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.12.0                          # ← always check flutter --version first
  flutter: ">=3.44.0"                    # ← always check flutter --version first

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  # State management
  provider: ^6.1.2
  # or riverpod: ^2.6.1
  # or bloc: ^8.1.4
  # Networking
  dio: ^5.7.0
  # Navigation
  go_router: ^14.6.1
  # Local storage
  shared_preferences: ^2.3.3
  # Hive (NoSQL local db)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  # Image picker
  image_picker: ^1.1.2
  # Device info (iOS/Android)
  device_info_plus: ^11.1.1
  # Deep links / universal links
  app_links: ^6.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mocktail: ^1.0.4
  flutter_launcher_icons: ^0.14.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont.ttf
```

#### Recommended folder structure

```
lib/
├── main.dart                 # entry point
├── main_bindings.dart        # dependency injection (if using GetX)
├── main_routes.dart          # route definitions (if using go_router)
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   └── auth/
│       ├── data/
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── controllers/
│       │   └── widgets/
│       └── domain/
└── shared/
    ├── widgets/
    └── themes/

test/
├── unit_test.dart
├── widget_test.dart
└── mocks/
```

### Compose (Native Kotlin)

Create `build.gradle.kts` (root) and `app/build.gradle.kts` with:
- `compileSdk = 36`, `minSdk = 26`, `targetSdk = 36` ← check latest via `sdkmanager --list`
- `buildFeatures { compose = true }`
- Compose BOM latest: check via `sdkmanager --list` or Maven Central
- KSP for Room if needed

### Kotlin Multiplatform (KMP) Project Structure

```bash
# ALWAYS use SDK/Gradle templates — never manually stitch KMP projects together
# The shared module contains commonMain, jvmMain, iosMain, etc.
# The android app module depends on shared via Gradle dependency

# Example: Create a shared KMP module
# Use Gradle's Kotlin Multiplatform plugin — check kotlinlang.org for latest template
mkdir shared && cd shared
# Use the kotlin multiplatform plugin via Gradle init or template:
kotlin create shared --type library  # ← check kotlinlang.org for latest CLI

# Or manually scaffold via Gradle (if template CLI not available):
# Add to root build.gradle.kts:
# id("org.jetbrains.kotlin.multiplatform") version "<latest>" apply false
# Add to shared/build.gradle.kts:
# plugins { id("org.jetbrains.kotlin.multiplatform") }
# kotlin {
#     jvm()
#     iosArm64()
#     iosSimulatorArm64()
#     sourceSets {
#         commonMain.dependencies { /* shared deps */ }
#         androidMain.dependencies { /* Android-only deps */ }
#     }
# }
```

---

## Remote Mac Setup (for iOS / macOS builds)

### Mac Details

| Property | Value |
|---|---|
| Hostname | `Ricardos-MacBook-Pro.local` |
| IP | `10.74.74.139` |
| SSH User | `ricardo` |
| macOS | 26.5 (Sequoia) | 10-core Apple Silicon | 16 GB RAM |
| Xcode | 26.5 (Build 17F42) |
| Homebrew | 5.1.14 at `/opt/homebrew` |
| Flutter | 3.44.0 at `/Users/ricardo/development/flutter` |
| CocoaPods | 1.16.2 at `/opt/homebrew/bin/pod` |
| Android SDK | at `/Users/ricardo/Library/Android/sdk` |
| Android Studio | at `/Users/ricardo/Applications/Android Studio.app` |
| Android Licenses | ✅ Accepted |
| Git | `Ricardo Alfredo Salgado Barcenas <ricr.sb@gmail.com>` |
| Disk | 926 GB SSD (51 GB free) |

### 1. Connect from Windows

```bash
ssh ricardo@10.74.74.139
```

> **Tip:** Set up SSH keys for passwordless auth:
> ```bash
> ssh-keygen -t ed25519 -C "pi-agent"
> sshpass -p 'Mulder911' ssh-copy-id ricardo@10.74.74.139
> ```

### 2. Run Flutter commands (non-interactive SSH)

Because macOS uses zsh as the default shell, non-interactive SSH sessions don't load `.zprofile` or `.zshrc`. Use `zsh -l -c` to get the full environment:

```bash
# Check Flutter version
ssh ricardo@10.74.74.139 'zsh -l -c "flutter --version"'

# Run Flutter doctor
ssh ricardo@10.74.74.139 'zsh -l -c "flutter doctor -v"'

# List simulators
ssh ricardo@10.74.74.139 'zsh -l -c "xcrun simctl list devices"'
```

### 3. Remote iOS Builds

```bash
# Run iOS app on simulator (via Mac SSH)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter run -d "iPhone 16 Pro Max"\"'

# Build IPA (for TestFlight/AdHoc)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter build ipa --release\"'

# Build without code signing (quick test)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter build ipa --release --no-codesign\"'

# Build macOS app
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter build macos --release\"'

# Run macOS app
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter run -d macos\"'

# List iOS simulators on Mac
ssh ricardo@10.74.74.139 'zsh -l -c \"xcrun simctl list devices -j\"' | jq '.'
```

### 4. Sync Code to Mac (if needed)

```bash
# rsync via SSH (set up SSH keys first)
rsync -avz --exclude=.git --exclude=build/ lib/ android/ ios/ pubspec.yaml \
  ricardo@10.74.74.139:/Users/ricardo/projects/my_app/

# Or use git: push from Windows, pull on Mac
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /Users/ricardo/projects/my_app && git pull\"'
```

### 5. Xcode CLI Commands (on Mac)

```bash
ssh ricardo@10.74.74.139

# List all simulators
xcrun simctl list devices

# Launch simulator
xcrun simctl boot "iPhone 16 Pro Max"
xcrun simctl launch booted com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max

# Clear all simulators
xcrun simctl shutdown all && xcrun simctl erase all

# Install IPA on simulator
xcrun simctl install booted /path/to/app.ipa

# Get simulator logs
log stream --process simulator --predicate 'eventMessage contains "error"' --level debug

# Create custom simulator
xcrun simctl create "My Custom iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max ios26.5
xcrun simctl delete "My Custom iPhone"

# Take simulator screenshot
xcrun simctl io booted screenshot /path/to/screenshot.png
```

### 6. Headless CI Build (on Mac)

```bash
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && \
  flutter build ipa --release --no-codesign && \
  ls build/ios/ipa/ -la\"'
```

### 7. Physical iOS Device

```bash
# Connect iPhone to Mac via USB, trust the computer
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/flutter/app && flutter run -d <device-udid>\"'

# Find device UIDs
ssh ricardo@10.74.74.139 'zsh -l -c \"xcrun devicectl list devices\"'
```

---

## Limitations

- No Android Studio GUI (no layout editor, no visual debugger)
- No physical device detected
- No React Native, Appium, Maestro
- iOS/macOS builds require remote MacBook Pro — SSH connected and working
- Use `adb shell screencap -p | base64` for emulator UI verification
- Flutter licenses not yet accepted: run `flutter doctor --android-licenses` if prompted

---

## 🔒 Compatibility Checklist

**Before making any changes, verify:**

1. **JDK ↔ Gradle ↔ AGP**: JDK 21 → Gradle 8.x+ → AGP 8.7+
2. **Kotlin ↔ AGP**: Kotlin 1.9.x → AGP 8.x, Kotlin 2.0+ → AGP 8.3+
3. **Compose ↔ AGP**: Compose BOM 2024+ → AGP 8.2+
4. **Flutter ↔ Dart ↔ AGP**: Flutter 3.44 → Dart 3.12 → AGP 8.7+
5. **KMP ↔ AGP**: Kotlin 2.1+ → AGP 8.12+ (for Android target), JDK 17+, Gradle 8.14+
6. **KMP ↔ Kotlin**: Kotlin 2.1.0+ required for stable multiplatform (JVM, iOS, Android, JS, Wasm targets)
7. **SDK platform ↔ Build tools**: Ensure targetSdk has a matching build-tools version

**To check compatibility, run:**
```bash
sdkmanager --list                                    # all available SDK packages
./gradlew --version                                  # Gradle version
flutter --version                                    # Flutter + Dart versions
kotlin -version                                      # Kotlin compiler version (for KMP)
# Cross-reference versions against the matrix above
```

---

## Advanced

See [REFERENCE.md](REFERENCE.md) for project templates, Gradle snippets, Compose testing patterns, Flutter state management templates, and full Flutter iOS/macOS build guides.
