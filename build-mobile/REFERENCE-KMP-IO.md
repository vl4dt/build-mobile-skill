# KMP → iOS Xcode Integration Guide

## Overview

This guide covers how to connect a Kotlin Multiplatform `shared` module to an iOS app built in Xcode. There are three main approaches:

| Approach | Best For | Pros | Cons |
|---|---|---|---|
| Xcode Project Reference | Small/medium apps, quick iteration | No build step, instant changes | Requires Xcode project setup |
| Swift Package Manager (SPM) | Libraries, versioned releases | Native Swift ecosystem integration | Requires framework build step |
| CocoaPods | Existing Pod-based apps | Mature, well-documented | More complex setup |

---

## Prerequisites

### Gradle Setup (Android side)

```kotlin
// shared/build.gradle.kts (from REFERENCE-GRADLE.md)
plugins {
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")
}

kotlin {
    jvm()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            // @version-check kotlinx-serialization — EXAMPLE pin, verify
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0")
            // @version-check Ktor — EXAMPLE pin, verify
            implementation("io.ktor:ktor-client-core:3.1.0")
        }
        iosMain.dependencies {
            // @version-check Ktor Darwin — EXAMPLE pin, verify
            implementation("io.ktor:ktor-client-darwin:3.1.0")
        }
        commonTest.dependencies {
            implementation(kotlin("test"))
        }
    }
}
```

### Xcode Setup (iOS side)

- Xcode 15+ recommended
- iOS 16+ deployment target
- Swift 5.9+

---

## Approach 1: Xcode Project Reference (Recommended for Flutter + KMP)

This is the recommended approach for Flutter projects that also use KMP. The shared module is built as a framework and linked into the Xcode project.

### Step 1: Build the Framework

```bash
# Build iOS framework
cd /path/to/project
./gradlew :shared:linkReleaseFrameworkIosArm64
./gradlew :shared:linkReleaseFrameworkIosSimulatorArm64

# The framework will be at:
# shared/build/xcodeFrameworks/Release/shared.framework
```

### Step 2: Add Framework to Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Runner → TARGETS → Runner → General**
3. Scroll to **Frameworks, Libraries, and Embedded Content**
4. Click **+** → Add → Add Other → Add Frameworks and Libraries from Disk...
5. Navigate to `shared/build/xcodeFrameworks/Release/`
6. Select `shared.framework`
7. Set **Embed** to "Do Not Embed" (since it's built at runtime)

### Step 3: Configure Build Phase

1. Go to **Runner → TARGETS → Runner → Build Phases**
2. Click **+ → New Run Script Phase**
3. Name it "Build KMP Framework"
4. Add script:

```bash
# Build KMP framework before each build
cd "${PROJECT_DIR}/.."
./gradlew :shared:assembleXcf --configuration iosArm64
./gradlew :shared:assembleXcf --configuration iosSimulatorArm64
```

### Step 4: Swift Interop

In your Swift code, import the KMP framework:

```swift
import shared

// Access Kotlin objects directly
let viewModel = MyViewModel()
viewModel.fetchData()
```

### Step 5: Handle Platform-Specific Code

```kotlin
// shared/src/iosMain/kotlin/platform/IosPlatform.kt
package platform

import platform.Foundation.NSBundle
import platform.Foundation.NSBundle.mainBundle
import platform.Foundation.NSProcessInfo

actual fun getPlatformName(): String {
    return "iOS ${NSProcessInfo.processInfo.operatingSystemVersionString}"
}

actual fun getAppVersion(): String {
    return mainBundle.objectForInfoDictionary("CFBundleShortVersionString") as? String ?: "unknown"
}
```

```swift
// iOS Swift code calling Kotlin
import shared

struct PlatformInfo {
    let name: String
    let version: String
    
    init() {
        name = PlatformKt.getPlatformName()
        version = PlatformKt.getAppVersion()
    }
}
```

---

## Approach 2: Swift Package Manager (SPM)

### Step 1: Build and Publish the Framework

```bash
# Build fat framework (simulator + device)
./gradlew :shared:mergeXcf

# The merged framework is at:
# shared/build/xcodeFrameworks/Release/shared.xcframework
```

### Step 2: Create Package Structure

```
SharedPackage/
├── Package.swift
└── shared/
    └── shared.xcframework/
```

### Step 3: Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .iOS(.v16)
    ],
    targets: [
        .binaryTarget(
            name: "shared",
            path: "shared/shared.xcframework"
        )
    ]
)
```

### Step 4: Add to Xcode Project

1. In Xcode: **File → Add Package Dependencies**
2. Click **+** → Add local...
3. Select the `SharedPackage/` directory
4. Choose target and product
5. Click **Add Package**

### Step 5: Use in Swift

```swift
import shared

// Same as Approach 1 — Kotlin types are directly accessible
let viewModel = MyViewModel()
```

---

## Approach 3: CocoaPods

### Step 1: Generate Podspec

```bash
# In shared/build.gradle.kts
kotlin {
    iosArm64("ios")
    iosSimulatorArm64("ios")
    
    // Generate CocoaPods spec
    cocoapods {
        summary = "Shared KMP module"
        homepage = "https://github.com/your-org/shared"
        authors = "Your Name"
        license = { type = "MIT" }
    }
}
```

### Step 2: Run Pod Install

```bash
# Generate podspec
./gradlew :shared:podspec

# In ios/ directory
pod install
```

### Step 3: Use in Swift

```swift
import shared

let viewModel = MyViewModel()
```

---

## iOS-Specific Source Sets

### Platform-Specific Implementations

```kotlin
// shared/src/commonMain/kotlin/platform/DeviceInfo.kt
package platform

// Expect declaration (contract)
expect fun getDeviceModel(): String
expect fun getOsVersion(): String
expect fun getAvailableStorageBytes(): Long

// shared/src/iosMain/kotlin/platform/DeviceInfo.kt
package platform

import platform.Foundation.NSProcessInfo
import platform.Foundation.NSUserDefaults

actual fun getDeviceModel(): String {
    return NSProcessInfo.processInfo.processorCount.toString()
}

actual fun getOsVersion(): String {
    return NSProcessInfo.processInfo.operatingSystemVersionString
}

actual fun getAvailableStorageBytes(): Long {
    return NSProcessInfo.processInfo.physicalMemory
}

// shared/src/iosMain/kotlin/data/DataSource.kt
package data

import platform.Foundation.NSURLSession

actual class HttpDataSource {
    suspend fun get(url: String): String {
        return NSURLSession.defaultSession.dataTaskWithURL(url) { data, _, _ ->
            String(data, charset = Charsets.UTF_8)
        }.toString()
    }
}
---

## Testing KMP from Swift

### Swift Unit Tests with KMP

```swift
import XCTest
import shared

final class KmpTests: XCTestCase {

    func testViewModelInitialization() {
        let viewModel = MyViewModel()
        XCTAssertNotNil(viewModel)
    }

    func testDataModelMapping() {
        // Test Kotlin data models in Swift
        let user = User(name: "Test", id: "1")
        XCTAssertEqual(user.name, "Test")
        XCTAssertEqual(user.id, "1")
    }

    func testNetworkCall() async throws {
        let dataSource = HttpDataSource()
        let result = try await dataSource.get("https://jsonplaceholder.typicode.com/users/1")
        XCTAssertFalse(result.isEmpty)
    }
}
```

### Mocking for Tests

```kotlin
// shared/src/commonTest/kotlin/MockDataSource.kt
class MockDataSource : DataSource {
    var shouldFail = false
    var mockResponse: String? = null

    override suspend fun get(url: String): String {
        if (shouldFail) throw RuntimeException("Mock failure")
        return mockResponse ?: "{\"data\": []}"
    }
}

// Use in tests
@Test
fun testErrorHandling() = runTest {
    val mock = MockDataSource()
    mock.shouldFail = true
    val viewModel = MyViewModel(mock)
    viewModel.loadData()
    assertTrue(viewModel.error is NetworkError)
}
```

### XCUITest with KMP

```swift
import XCTest

final class AppUITests: XCTestCase {

    func testAppLoadsWithKMPData() throws {
        let app = XCUIApplication()
        app.launch()
        // Verify data from KMP layer is displayed
        XCTAssertTrue(app.staticTexts.exists)
    }
}
```

---

## Common KMP Issues & Fixes

| Issue | Cause | Fix |
|---|---|---|
| "Could not resolve org.jetbrains.kotlin:kotlin-stdlib" | Gradle version mismatch | Ensure same Kotlin version in all modules |
| "Framework not found" | Framework not built | Run `./gradlew :shared:linkReleaseFrameworkIosArm64` |
| "Symbol not found" | Missing @ExportObjC | Add `@OptIn(InternalInferenceApi::class)` or `@ExportObjC` |
| "Cannot access class" | Expect/actual mismatch | Verify source set names match: `iosMain` not `ios_main` |
| "Build failed - architecture mismatch" | Simulator vs Device | Build both: `iosArm64` + `iosSimulatorArm64` |
| "Kotlin/Native compilation failed" | Xcode command line tools | `sudo xcode-select -switch /Applications/Xcode.app` |
| "Undefined symbol" | Native library missing | Add required native dependencies to `iosMain` source set |
| "Thread sanitizer warning" | Shared mutable state | Use `@OptIn(Atomicity::class)` or proper synchronization |
| "Coroutines not working on main" | Missing dispatcher | Use `MainDispatcher` from `kotlinx-coroutines-ios` |
| "SwiftUI preview not working" | Framework not in build path | Add framework to Xcode target → General → Frameworks |

---

## Architecture Patterns

### MVVM with KMP

```kotlin
// shared/src/commonMain/kotlin/viewmodel/UserViewModel.kt
@OptIn(ExperimentalContractsApi::class)
class UserViewModel(
    private val repository: UserRepository,
    private val coroutineScope: CoroutineScope = CoroutineScope(SupervisorJob())
) {
    private val _state = MutableStateFlow(UserState())
    val state: StateFlow<UserState> = _state.asStateFlow()

    fun loadUsers() {
        coroutineScope.launch {
            _state.value = UserState.Loading
            try {
                val users = repository.getUsers()
                _state.value = UserState.Success(users)
            } catch (e: Exception) {
                _state.value = UserState.Error(e.message ?: "Unknown error")
            }
        }
    }

    sealed interface UserState {
        object Loading : UserState
        data class Success(val users: List<User>) : UserState
        data class Error(val message: String) : UserState
    }
}

// shared/src/commonMain/kotlin/data/UserRepository.kt
class UserRepository(
    private val api: UserApi,
    private val local: UserLocalDao
) {
    suspend fun getUsers(): List<User> {
        return try {
            val remote = api.getUsers()
            local.insertAll(remote)
            remote
        } catch (e: Exception) {
            local.getAll()
        }
    }
}
```

### SwiftUI + KMP Integration

```swift
import shared
import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.users, id: \.id) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        Text(user.name)
                    }
                }
            }
            .overlay {
                if viewModel.state is UserState.Loading {
                    ProgressView()
                } else if let error = (viewModel.state as? UserState.Error)?.message {
                    Text(error)
                }
            }
            .task {
                await viewModel.loadUsers()
            }
        }
    }
}
```

### Android + KMP Integration

```kotlin
// app/src/main/kotlin/MainActivity.kt
class MainActivity : ComponentActivity() {
    private val viewModel: UserViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                UserListView(viewModel = viewModel)
            }
        }
    }
}
```

---

## Build Optimization

### Incremental Builds

```kotlin
// gradle.properties
kotlin.native.cacheKind=cache
kotlin.native.binary.memoryModel=experimental
kotlin.native.ignoreDisabledTargets=true
```

### CI/CD for KMP + iOS

```yaml
# .github/workflows/build-kmp-ios.yml
name: Build KMP iOS Framework
on:
  push:
    branches: [main]

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'
      - run: chmod +x gradlew
      - run: ./gradlew :shared:mergeXcf --configuration iosSimulatorArm64
      - uses: actions/upload-artifact@v4
        with:
          name: kmp-framework
          path: shared/build/xcodeFrameworks/Release/shared.xcframework
```

---

## When to Use KMP vs Native

| Factor | KMP | Native |
|---|---|---|
| Code sharing | 60-80% (business logic) | 0% |
| UI sharing | Not yet (Compose Multiplatform) | Full control |
| Team size | Small teams | Large teams |
| Time to market | Faster | Slower |
| Performance | Near-native | Native |
| Testing | Shared tests | Platform tests |
| Maintenance | One codebase | Two codebases |
| iOS expertise | Shared knowledge | Dedicated |

> **Use KMP when:** You share business logic, data models, networking, and domain rules.  
> **Use native when:** You need platform-specific UI, complex animations, or deep OS integration.

## Migration Checklist

- [ ] Add `shared/` module with Kotlin Multiplatform setup
- [ ] Identify shareable code (models, repositories, viewmodels)
- [ ] Create expect/actual declarations for platform-specific code
- [ ] Build iOS framework and add to Xcode project
- [ ] Write Swift interop layer
- [ ] Test on both simulator and device
- [ ] Add CI/CD pipeline for framework builds
- [ ] Document API surface for iOS/Android teams
- [ ] Write shared tests for common code
- [ ] Profile and optimize critical paths
