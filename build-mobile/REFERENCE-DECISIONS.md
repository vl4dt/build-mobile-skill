# Decision Trees, Troubleshooting & Platform Comparison

## 🧭 When to Use What: State Management (Flutter)

### Provider vs Riverpod vs BLoC

| Factor | Provider | Riverpod | BLoC |
|---|---|---|---|
| Learning curve | Easy | Medium | Steep |
| Boilerplate | Low | Medium | High |
| Testability | Good | Excellent | Excellent |
| Reactive updates | `notifyListeners()` | `AsyncValue` | `emit()` |
| Null safety | Manual | Built-in | Built-in |
| Async support | Manual | Native | Built-in |
| Performance | Good | Good | Good |
| Ecosystem | Largest | Growing | Mature |
| Best for | Small/medium apps | Medium/large apps | Large/complex apps |

**Decision tree:**
```
Is your app > 5 screens with complex async state?
  ├─ YES → Riverpod (AsyncValue + AsyncNotifier)
  │         ├─ Need strict unidirectional data flow? → BLoC
  │         └─ Prefer reactive patterns? → Riverpod
  └─ NO → Provider (simple ChangeNotifier)
          ├─ Already using BLoC elsewhere? → Consistency: BLoC
          └─ Need async support? → Riverpod
```

**Recommendation for AI agent users:** Riverpod is the safest default — excellent testability, null safety, and async support with moderate boilerplate.

---

### KMP vs Flutter for iOS

| Factor | KMP + SwiftUI | Flutter + Material/Cupertino |
|---|---|---|
| iOS UI quality | Native (SwiftUI) | Good (Cupertino) |
| Code sharing | Business logic only | UI + logic (70-80%) |
| iOS developer experience | Native | Flutter tooling |
| Performance | Native | Near-native |
| Learning curve | Kotlin + SwiftUI | Dart + Flutter |
| Team skills | Kotlin + Swift | Dart |
| App size | +2-3MB (framework) | +10-15MB (engine) |
| Store review | No issues | None |
| Community | Growing | Massive |
| CI/CD | Xcode + Gradle | Flutter + Gradle |
| Time to market (iOS) | Faster (native UX) | Slower (Cupertino theming) |

**Decision tree:**
```
Need to share iOS code with Android?
  ├─ YES → KMP
  │         ├─ Need native iOS UI? → KMP + SwiftUI
  │         └─ OK with Compose Multiplatform? → KMP + Compose Multiplatform
  └─ NO → Flutter
          ├─ Need rapid UI iteration? → Flutter
          ├─ Team knows Dart? → Flutter
          └─ Need maximum code sharing? → Flutter
```

**Recommendation for AI agent users:** For teams already using KMP for Android, extending to iOS with SwiftUI is natural. For greenfield projects needing maximum code sharing, Flutter is still the better choice.

---

### Jetpack Compose vs Native XML (Android)

| Factor | Jetpack Compose | XML Views |
|---|---|---|
| Code volume | ~40% less | More verbose |
| Learning curve | Medium (declarative) | Steep (imperative) |
| Performance | Slightly slower (JIT) | Faster (AOT) |
| Tooling | Layout Inspector | Layout Inspector |
| Compatibility | API 21+ | API 14+ |
| Team skills | Growing | Established |
| Maintenance | Easier | Harder |
| Best for | New apps | Legacy apps |

**Decision tree:**
```
Starting a new Android project?
  ├─ YES → Jetpack Compose
  └─ NO (legacy migration)
          ├─ Small migration scope → Hybrid (XML + Compose in same activity)
          └─ Large migration → Compose in new modules, XML in legacy
```

**Recommendation:** Always use Compose for new projects. Hybrid migration for legacy is well-documented.

---

## 📊 Platform Comparison Matrix

| Feature | Native Android | Flutter | KMP + SwiftUI | Native iOS |
|---|---|---|---|---|
| UI Framework | Jetpack Compose | Flutter Widget Tree | SwiftUI | SwiftUI/UIKit |
| Language | Kotlin/Java | Dart | Kotlin/Swift | Swift/Objective-C |
| Code Sharing | None | 80-100% | 60-80% (logic) | None |
| Performance | Native | Near-native | Native | Native |
| Hot Reload | Flutter DevTools | Yes | Partial (Kotlin) | No (SwiftUI) |
| iOS Build | ❌ | ✅ (Mac) | ✅ (Mac) | ✅ (Mac) |
| Android Build | ✅ | ✅ | ✅ | ❌ |
| Web Support | ❌ | ✅ | ✅ (Compose Multiplatform) | ❌ |
| Desktop Support | ❌ | ✅ | ✅ (Compose Multiplatform) | ❌ |
| Learning Curve | Medium | Low | High (2 languages) | Low (Swift) |
| Hiring Pool | Large | Medium | Small | Large |
| Best Use Case | Android-only apps | Cross-platform | Android team + iOS expansion | iOS-only apps |

---

## 🔧 Troubleshooting

### Android / Gradle

| Issue | Cause | Fix |
|---|---|---|
| "AGP 8.x requires Kotlin 2.x" | Kotlin version too old | Update Kotlin to 2.1+ in root build.gradle.kts |
| "Compose BOM version mismatch" | BOM not pinned | Use `val composeBom = platform("androidx.compose:compose-bom:2025.06.01")` |
| "KMP compilation failed" | Missing native targets | Add `iosArm64()` and `iosSimulatorArm64()` to `kotlin {}` |
| "Could not find kotlin-stdlib" | Version mismatch | Ensure same Kotlin version in all modules |
| "AGP 8.12 requires JDK 17" | Old JDK | Set `org.gradle.java.home` to JDK 17+ path in gradle.properties |
| "Build failed - dex error" | Too many methods | Enable multidex or remove unused dependencies |
| "Resource not found" | R class not generated | Clean + rebuild: `./gradlew clean assembleDebug` |
| "Min SDK too low" | Library requires higher SDK | Check library docs for minSdk, update in build.gradle.kts |

### Flutter

| Issue | Cause | Fix |
|---|---|---|
| "Flutter pub get failed" | Network/DNS | `flutter pub cache repair` |
| "Platform not supported" | No Mac for iOS | Use `--platforms android,web` on Windows |
| "StatefulWidget not rebuilding" | Missing `setState()` | Ensure state change triggers rebuild |
| "Provider not found" | Wrong provider type | Check `Provider.of<T>(context, listen: false)` matches type |
| "go_router not navigating" | Missing builder | Ensure route has `builder: (c, s) => Screen()` |
| "BLoC not emitting" | Event not dispatched | Verify `bloc.dispatch(event)` in widget |
| "Image not loading" | Network permission missing | Add `<uses-permission android:name="android.permission.INTERNET"/>` |
| "Build fails - Xcode signing" | Missing provisioning | Xcode → Runner → Signing → "Automatically manage signing" |
| "Hot reload not working" | State lost in non-widget code | Use `valueListenableBuilder` or `ChangeNotifierProvider` |
| "Dart analyzer errors" | Outdated SDK | `flutter clean && flutter pub get` |

### KMP

| Issue | Cause | Fix |
|---|---|---|
| "Could not resolve KMP lib" | No KMP-compatible build | Check ktor.io/docs for KMP builds |
| "iosMain not found" | Wrong source set name | Use `iosMain` not `ios_main` |
| "Framework not found" | Not built | Run `./gradlew :shared:linkReleaseFrameworkIosArm64` |
| "Expect/actual mismatch" | Contract not implemented | Verify `expect` in commonMain, `actual` in iosMain |
| "Symbol not found" | Missing @ExportObjC | Add `@OptIn(InternalInferenceApi::class)` or `@ExportObjC` |
| "Architecture mismatch" | Simulator vs device | Build both: `iosArm64` + `iosSimulatorArm64` |

### iOS / SwiftUI

| Issue | Cause | Fix |
|---|---|---|
| "Build failed - signing" | Missing provisioning | Xcode → Signing → "Automatically manage signing" |
| "Simulator not found" | No iOS runtime | `xcrun simctl list runtimes` → install missing runtime |
| "Code signing error" | Expired cert | Xcode → Accounts → Manage Certificates → refresh |
| "SwiftUI preview not working" | Framework not in build path | Add to target → General → Frameworks |
| "NavigationStack not working" | iOS 15 or earlier | Use `NavigationView` for iOS 15, `NavigationStack` for iOS 16+ |
| "View not updating" | Missing @State/@Observable | Check state management: @State, @Binding, @Observable |
| "Animation not playing" | Missing animation modifier | Add `.animation(.default, value: someValue)` |
| "App not launching on device" | Provisioning profile mismatch | Verify profile matches device + bundle ID + entitlements |

---

## ❓ FAQ

### Q: Can I run Flutter on Windows?
**A:** Yes — Android, Web, and Desktop (Windows) work on Windows. iOS and macOS require a Mac.

### Q: Can I run KMP on Windows?
**A:** JVM and Android targets compile on Windows. iOS targets require macOS. Use CI/CD or a Mac for iOS builds.

### Q: Should I use KMP for iOS?
**A:** If your team already uses Kotlin for Android, KMP is a natural extension for shared business logic. For UI, use SwiftUI (native iOS) or Compose Multiplatform (cross-platform). If you need maximum code sharing, consider Flutter.

### Q: When to use Provider vs Riverpod vs BLoC?
**A:** Provider for small/medium apps. Riverpod for medium/large apps with complex async state. BLoC for large apps requiring strict unidirectional data flow. Riverpod is the safest default for most projects.

### Q: How do I connect Flutter + KMP?
**A:** Flutter handles iOS UI (via SwiftUI or Flutter widgets). KMP shared module provides business logic. Build KMP framework and link it to the Xcode project (see REFERENCE-KMP-IO.md).

### Q: Can I use KMP for web?
**A:** Yes — add `wasmJs()` target to your KMP setup. Compose Multiplatform also supports web rendering.

### Q: What's the minimum iOS version for SwiftUI?
**A:** iOS 13 for basic SwiftUI. iOS 16 for `NavigationStack`, `Chart`, and `Maps`. iOS 17 for `@Observable` and `ViewTesting`.

### Q: Do I need a Mac for Flutter iOS builds?
**A:** Yes — iOS builds require Xcode, which is macOS-only. Use a Mac (local or remote) or CI/CD (GitHub Actions, Codemagic).

### Q: How do I handle API keys in Flutter/KMP?
**A:** Never hardcode. Use environment variables, `flutter build --dart-define=KEY=value`, or `.env` files with `flutter_dotenv`. For Android, use `local.properties` or `gradle.properties` with `findProperty()`.

### Q: How do I share code between Flutter and KMP?
**A:** Not directly — Flutter and KMP are separate codebases. However, you can share backend APIs (REST/GraphQL) and data models (via JSON serialization) between them. For true code sharing, pick one: either Flutter (Dart) or KMP (Kotlin).

### Q: Is Compose Multiplatform production-ready for iOS?
**A:** Compose Multiplatform for iOS is in beta. For production iOS apps, use SwiftUI with KMP for shared logic (see REFERENCE-KMP-IO.md). For Android-only, Compose is production-ready.

### Q: What's the best way to test KMP shared code?
**A:** Write tests in `commonTest` using Kotlin test frameworks (Kotest, KotlinTest). Run with `./gradlew :shared:allTests`. For iOS-specific tests, write Swift XCTest that calls KMP code.

---

## 🗺 Decision Summary

| Scenario | Recommended Approach |
|---|---|
| Android-only app | Jetpack Compose + Kotlin |
| Cross-platform (Android + iOS + Web) | Flutter (Dart) |
| Android + iOS expansion (existing Android team) | KMP + SwiftUI |
| Greenfield cross-platform with mobile focus | Flutter |
| Enterprise Android app | Jetpack Compose + Hilt + Koin |
| Startup needing rapid iteration | Flutter + Riverpod |
| Android team wants iOS without learning Swift | KMP + Compose Multiplatform (beta) |
| iOS team wants Android expansion | KMP + Compose (Android) + SwiftUI (iOS) |
| Shared business logic, different UI per platform | KMP + native UI (SwiftUI + Compose) |
| Shared business logic + shared UI | Flutter or Compose Multiplatform (Android) |
