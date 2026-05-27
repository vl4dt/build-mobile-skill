---
name: build-mobile
version: 2.0.0
description: Android, Flutter, KMP, and SwiftUI development toolkit with SDK tooling workflows, cross-platform compatibility matrices, and iOS/macOS remote Mac build guidance.
source: github:vl4dt/android-dev-skill/build-mobile
license: Apache-2.0
---

# Build Mobile

## 🔴 Golden Rules

1. **ALWAYS prefer SDK tooling** — use `flutter pub add`, `sdkmanager`, `avdmanager`, `gradlew`.
2. **ALWAYS check latest versions** before pinning SDK/platform/plugin/dependency.
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

## Pre-flight

```bash
sdkmanager --list && flutter doctor --verbose && ./gradlew --version
```
**Compatibility:** AGP 8.x ↔ Kotlin 1.9+, AGP 8.3+ ↔ Kotlin 2.0+, Flutter 3.44+ ↔ Dart 3.12, KMP 2.1+ ↔ AGP 8.12+

## 🏗 SDK Tooling

### Flutter
```bash
flutter create my_app --org com.example --platforms android,ios,web,windows,macos,linux
flutter pub add <package> && flutter pub get
flutter test && flutter build apk --release && flutter build appbundle --release
flutter run -d android || flutter run -d ios  # Run (Mac for iOS)
```

### Android / Gradle
```bash
./gradlew assembleDebug && ./gradlew test && ./gradlew app:connectedInstrumentTest
./gradlew app:lint && ./gradlew :app:dependencies
```

### KMP
```bash
./gradlew :shared:compileKotlinIosArm64 && ./gradlew :shared:linkReleaseFrameworkIosArm64
./gradlew :shared:jvmTest && ./gradlew :shared:allTests
```

### iOS / SwiftUI
```bash
xcrun simctl list devices && xcrun simctl boot "iPhone 16"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -sdk iphoneos build
```

## ⚡ Quick Commands

| Action | Android | Flutter | KMP | iOS |
|---|---|---|---|---|
| Build debug | `./gradlew assembleDebug` | `flutter build apk` | `./gradlew :shared:compileKotlinIosArm64` | `xcodebuild -sdk iphonesimulator` |
| Build release | `./gradlew assembleRelease` | `flutter build appbundle --release` | `./gradlew :shared:linkReleaseFrameworkIosArm64` | `xcodebuild -sdk iphoneos` |
| Run tests | `./gradlew test` | `flutter test` | `./gradlew :shared:allTests` | `xcodebuild test` |
| Lint/check | `./gradlew app:lint` | `flutter analyze` | `./gradlew :shared:jvmLint` | `xcrun swiftlint` |
| Clean | `./gradlew clean` | `flutter clean` | `./gradlew clean` | `xcodebuild clean` |
| **See full reference** | [REFERENCE-GRADLE.md](REFERENCE-GRADLE.md) | [REFERENCE-FLUTTER.md](REFERENCE-FLUTTER.md) | [REFERENCE-GRADLE.md](REFERENCE-GRADLE.md) | [REFERENCE-SWIFTUI.md](REFERENCE-SWIFTUI.md) |
| **Real-world example** | — | [REFERENCE-FLUTTER-EXAMPLE.md](REFERENCE-FLUTTER-EXAMPLE.md) | — | — |
| **Decision guide** | — | [REFERENCE-DECISIONS.md](REFERENCE-DECISIONS.md) | [REFERENCE-DECISIONS.md](REFERENCE-DECISIONS.md) | [REFERENCE-DECISIONS.md](REFERENCE-DECISIONS.md) |

### Debugging & Audit
```bash
adb logcat -s MainActivity && adb shell dumpsys gfxinfo com.example.app
log stream --predicate 'process == "simulator"' --level debug
./scripts/android-env.sh && ./scripts/ios-env.sh && ./scripts/version-sync.sh
```

---

## 📖 References

| Reference | Covers |
|---|---|
| [REFERENCE-GRADLE.md](REFERENCE-GRADLE.md) | Gradle templates, KMP structure, Android deps, ADB, emulators, release builds |
| [REFERENCE-FLUTTER.md](REFERENCE-FLUTTER.md) | Project scaffolding, pubspec, state management (Provider/Riverpod/BLoC), go_router, dependencies |
| [REFERENCE-FLUTTER-EXAMPLE.md](REFERENCE-FLUTTER-EXAMPLE.md) | Complete real-world Flutter app: auth+list+detail, repository pattern, error handling, deep links, device info |
| [REFERENCE-COMPOSE.md](REFERENCE-COMPOSE.md) | Layouts, theming, Material3, Navigation, ViewModel, bottom sheets, dialogs, snackbars, forms |
| [REFERENCE-SWIFTUI.md](REFERENCE-SWIFTUI.md) | App lifecycle, layouts, ViewModifiers, animations, testing, Charts, Maps, accessibility, remote Mac |
| [REFERENCE-KMP-IO.md](REFERENCE-KMP-IO.md) | KMP→iOS Xcode integration (SPM, CocoaPods, project reference), Swift interop, testing from Swift |
| [REFERENCE-DECISIONS.md](REFERENCE-DECISIONS.md) | Provider vs Riverpod vs BLoC, KMP vs Flutter, Compose vs native, platform matrix, troubleshooting, FAQ |
