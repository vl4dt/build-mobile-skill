---
name: build-mobile
version: 2.0.0
description: Android, Flutter, KMP, and SwiftUI development toolkit with SDK tooling workflows, cross-platform compatibility matrices, and iOS/macOS remote Mac build guidance.
source: github:vl4dt/android-dev-skill/build-mobile
license: Apache-2.0
---

# Build Mobile

## 🔴 Golden Rules

1. **ALWAYS prefer SDK tooling** over manual file creation — use `flutter pub add`, `sdkmanager`, `avdmanager`, `gradlew`.
2. **ALWAYS check latest versions** before pinning any SDK/platform/plugin/dependency.
3. **ALWAYS verify compatibility** across SDK ↔ JDK ↔ Gradle ↔ Kotlin ↔ Compose ↔ Flutter ↔ plugins.

## Environment (refresh: `scripts/android-env.sh`)

| Component | Placeholder | Notes |
|---|---|---|
| SDK | `<SDK_PATH>` | Set ANDROID_HOME |
| JDK | `<JDK_VERSION>` | JDK 17+ (21 rec.) |
| Platforms | `<SDK_TARGETS>` | e.g., android-36 |
| Build Tools | `<BUILD_TOOLS>` | e.g., 36.0.0 |
| System Images | `<IMAGES>` | e.g., android-36 |
| CMake | `<CMAKE_VER>` | e.g., 4.1.2 |
| AVDs | `<AVD_NAMES>` | e.g., Pixel_9 |
| Gradle | `gradlew` | Project-local only |
| Flutter | `<FLUTTER_VER>` | Set FLUTTER_HOME |
| Dart | `<DART_VER>` | Bundled with Flutter |

### Flutter Targets

| Target | Requires | Notes |
|---|---|---|
| Android | Local SDK | SDK + AVDs |
| Windows | VS + Win SDK | Desktop |
| Web | Browser | Chrome/Edge |
| iOS | Remote Mac | User-configured |
| Linux | Dependencies | Desktop |
| macOS | Remote Mac | User-configured |

## Pre-flight

```bash
sdkmanager --list                              # SDK packages
flutter channel stable && flutter upgrade --dry-run
flutter doctor --verbose                       # Health check
./gradlew --version                            # Gradle version
```

**Compatibility:** AGP 8.x ↔ Kotlin 1.9+, AGP 8.3+ ↔ Kotlin 2.0+, Flutter 3.44+ ↔ Dart 3.12, KMP 2.1+ ↔ AGP 8.12+

## 🏗 SDK Tooling

### Project Creation
```bash
flutter create my_app --org com.example --platforms android,ios,web,windows,macos,linux
flutter create . --platforms ios               # add platform to existing
```

### Dependencies
```bash
flutter pub add <package>                      # Flutter deps
./gradlew app:dependencies                     # Android tree
```

### KMP
```bash
# Configure via Gradle plugins (see REFERENCE-GRADLE.md)
./gradlew :shared:compileKotlinIosArm64
./gradlew :shared:jvmTest
```

### Build & Test
```bash
./gradlew assembleDebug                        # Android
./gradlew test                                 # Unit
flutter test                                   # Flutter
```

---

## Advanced

See [REFERENCE-GRADLE.md](REFERENCE-GRADLE.md) for Gradle templates, KMP structure.
See [REFERENCE-FLUTTER.md](REFERENCE-FLUTTER.md) for pubspec, folder structure, state management.
See [REFERENCE-COMPOSE.md](REFERENCE-COMPOSE.md) for Compose testing patterns.
See [REFERENCE-SWIFTUI.md](REFERENCE-SWIFTUI.md) for SwiftUI, Xcode CLI, remote Mac setup.
