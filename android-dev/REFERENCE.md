# Android Dev Reference

## Version Discovery

**ALWAYS check these before pinning any version:**

```bash
# Latest Android SDK packages
sdkmanager --list

# Latest AGP (Android Gradle Plugin) versions
# Available at: https://developer.android.com/studio/releases/gradle-plugin

# Latest Kotlin / KMP versions
# Available at: https://kotlinlang.org/docs/releases.html

# Latest KMP-compatible dependencies (ktor, kotlinx, etc.)
# Available at: https://kotlinlang.org/api/kotlinx.coroutines/
# Available at: https://ktor.io/docs/index.html

# Latest Compose BOM
# Available at: https://developer.android.com/jetpack/androidx/releases/compose-kotlin

# Latest Compose Multiplatform (desktop/web) versions
# Available at: https://www.jetbrains.com/lp/compose-mpp/

# Latest Flutter stable version
flutter channel stable && flutter --version

# Latest Dart SDK version
# Bundled with Flutter — check flutter --version

# Latest Kotlin CLI template command (for KMP project creation)
kotlin --version
# Check kotlinlang.org for latest `kotlin create` / project template commands
```

## Root build.gradle.kts Template

```kotlin
plugins {
    id("com.android.application") version "8.12.1" apply false    // ← check sdkmanager --list for latest
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false // ← check kotlinlang.org/releases
    id("com.google.devtools.ksp") version "2.1.20-2.0.2" apply false
}
```

> **Compatibility:** AGP 8.12+ requires Kotlin 2.1+, JDK 17+, Gradle 8.14+.
> Always verify the compatibility matrix above before updating.

## KMP Root build.gradle.kts Template

```kotlin
plugins {
    id("com.android.library") version "8.12.1" apply false        // ← check latest
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false // ← check kotlinlang.org/releases
    id("org.jetbrains.kotlin.multiplatform") version "2.1.20" apply false  // ← check latest
    id("com.google.devtools.ksp") version "2.1.20-2.0.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

> **Compatibility:** KMP with Android target requires AGP 8.12+, Kotlin 2.1+, JDK 17+, Gradle 8.14+.
> **ALWAYS use the `org.jetbrains.kotlin.multiplatform` plugin — never manually stitch KMP source sets.**

## shared/build.gradle.kts Template (KMP Library)

```kotlin
plugins {
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")
    id("com.google.devtools.ksp")  // if using KSP in shared module
}

kotlin {
    // Targets — add only what you need
    jvm()
    iosArm64()
    iosSimulatorArm64()
    // iosX64()              // deprecated, prefer simulatorArm64
    // js()                  // add if targeting browser
    // wasmJs()              // add if targeting WASM

    sourceSets {
        commonMain.dependencies {
            // Shared dependencies — available on ALL platforms
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0")     // ← check latest
            implementation("io.ktor:ktor-client-core:3.1.0")                               // ← check latest
            implementation("io.ktor:ktor-client-content-negotiation:3.1.0")                // ← check latest
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.1")         // ← check latest
            // KMP-compatible DI, networking, etc.
        }
        commonTest.dependencies {
            implementation(kotlin("test"))
            implementation("io.ktor:ktor-client-mock:3.1.0")  // ← check latest (for common test)
        }
        androidMain.dependencies {
            implementation("io.ktor:ktor-client-android:3.1.0")  // ← check latest (Android-specific)
            implementation("androidx.appcompat:appcompat:1.7.1") // ← check latest
        }
        jvmMain.dependencies {
            implementation("io.ktor:ktor-client-jdkhttp:3.1.0")  // ← check latest (JVM-specific)
        }
        iosMain.dependencies {
            implementation("io.ktor:ktor-client-darwin:3.1.0")   // ← check latest (iOS-specific)
        }
    }
}

android {
    namespace = "com.example.shared"
    compileSdk = 36
    defaultConfig {
        minSdk = 26
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    kotlinOptions {
        jvmTarget = "21"
    }
}

## app/build.gradle.kts Template (Compose)

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.example.app"
    compileSdk = 36                    // ← sdkmanager --list for latest

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 26
        targetSdk = 36                // ← should match compileSdk
        versionCode = 1
        versionName = "1.0.0"
    }

    buildFeatures { compose = true }
    // Kotlin compiler extension is bundled with Kotlin 2.x — remove composeOptions block

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    kotlinOptions { jvmTarget = "21" }

    packaging { resources { excludes += "/META-INF/{LICENSE,NOTICE}.md" } }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2025.06.01")  // ← check latest
    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.activity:activity-compose:1.10.1")           // ← check latest
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.0")  // ← check latest
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.9.0")

    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
}
```

> **Compatibility Notes:**
> - AGP 8.12+ requires JDK 17+ (JDK 21 recommended) and Kotlin 2.1+
> - Compose BOM 2025.06.01+ works with AGP 8.2+ and Kotlin 2.1+
> - `composeOptions { kotlinCompilerExtensionVersion }` is deprecated with Kotlin 2.x (bundled)

## settings.gradle.kts Template

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "MyApp"
include(":app")
```

## settings.gradle.kts Template (Multi-module)

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "MyApp"
include(":app", ":core", ":feature:auth")
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

## Compose Testing Patterns

### Basic Test

```kotlin
package com.example.app.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import org.junit.Rule
import org.junit.Test

class MainActivityTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun app_launches_andShowsContent() {
        composeTestRule.setContent {
            MyApp()
        }
        composeTestRule.onNodeWithText("Hello").assertIsDisplayed()
    }

    @Test
    fun button_click_updatesText() {
        composeTestRule.setContent { MyApp() }
        composeTestRule.onNodeWithContentDescription("Add").performClick()
        composeTestRule.onNodeWithText("1").assertIsDisplayed()
    }
}
```

### Activity Scenario Test (full app context)

```kotlin
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import com.example.app.MainActivity

class MainActivityScenarioTest {
    @get:Rule
    val activityRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun testWithActivity() {
        activityRule.onNodeWithText("Some Text").assertIsDisplayed()
    }
}
```

### Semantics for Testing

```kotlin
// In your Compose code:
Button(
    onClick = { /* ... */ },
    modifier = Modifier.semantics { testTag = "addButton" }
) { Text("Add") }

// In tests:
composeTestRule.onNodeWithTag("addButton").performClick()
```

## Common Dependencies (check versions with sdkmanager --list or pub search)

| Library | Dependency | Notes |
|---|---|---|
| Room | `androidx.room:room-runtime:2.7.2` + `room-ktx` + ksp `room-compiler` | Verify with sdkmanager |
| Navigation Compose | `androidx.navigation:navigation-compose:2.9.0` | Check latest |
| Hilt | `com.google.dagger:hilt-android:2.56.2` + ksp `hilt-compiler` | Verify ksp version match |
| Retrofit | `com.squareup.retrofit2:retrofit:2.12.0` + `converter-gson` | Check latest |
| Coil (images) | `io.coil-kt:coil-compose:2.7.0` | Check latest |
| DataStore | `androidx.datastore:datastore-preferences:1.1.6` | Check latest |
| WorkManager | `androidx.work:work-runtime-ktx:2.10.1` | Check latest |

## KMP Dependencies (ALWAYS check kotlinlang.org + Maven Central for latest)

| Library | Dependency | Target | Notes |
|---|---|---|---|
| Ktor Client (core) | `io.ktor:ktor-client-core:3.1.0` | commonMain | ← check latest |
| Ktor Client (Android) | `io.ktor:ktor-client-android:3.1.0` | androidMain | ← check latest |
| Ktor Client (JVM) | `io.ktor:ktor-client-jdkhttp:3.1.0` | jvmMain | ← check latest |
| Ktor Client (Darwin) | `io.ktor:ktor-client-darwin:3.1.0` | iosMain | ← check latest |
| Ktor Client (Mock) | `io.ktor:ktor-client-mock:3.1.0` | commonTest | ← check latest |
| Ktor Content Negotiation | `io.ktor:ktor-client-content-negotiation:3.1.0` | commonMain | ← check latest |
| Kotlinx Serialization | `org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0` | commonMain | ← check latest |
| Kotlinx Coroutines | `org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.1` | commonMain | ← check latest |
| Kotlinx DateTime | `org.jetbrains.kotlinx:kotlinx-datetime:0.6.2` | commonMain | ← check latest |
| Kotlinx Serialization KSP | `org.jetbrains.kotlinx:kotlinx-serialization-compiler-plugin:1.8.0` | N/A | Version matches kotlinx-serialization |
| KMP DI (Kodein) | `com.github.kodein-framework:kodein-di:0.20.0` | commonMain | ← check latest |
| KMP DI (Inject) | `io.insert-koin:koin-core:4.0.2` | commonMain | ← check latest |
| KMP Persistence (KotlinX Data) | `org.jetbrains.kotlinx:kotlinx-data:1.0.0` | commonMain | ← check latest |
| KMP Persistence (Kable) | `app.cash.kable:kable-core:2.3.0` | commonMain | ← check latest |
| KMP HTTP (Khttp) | `com.mohamedrejeb.khttp:khttp:1.2.0` | commonMain | ← check latest |
| KMP DI (Koin for KMP) | `io.insert-koin:koin-core:4.0.2` | commonMain | ← check latest — verify KMP compatibility |
| KMP Testing (Kotest) | `io.kotest:kotest-framework-engine:5.10.0` | commonTest | ← check latest |
| KMP Testing (MockK) | `io.mockk:mockk:1.13.17` | jvmTest | JVM-only; use for JVM target testing |

> **ALWAYS verify KMP dependencies against the Kotlin version you're using.**
> Not all JVM libraries have KMP-compatible builds. Look for the `-common` or `-js`/`-jvm`/`-ios` suffixes.

## ADB Commands Cheat Sheet

```bash
# Install APK
adb install -r path/to/app.apk

# Uninstall
adb uninstall com.example.app

# Clear app data
adb shell pm clear com.example.app

# Screenshot from emulator
adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png

# File operations
adb push localfile /sdcard/remote_file
adb pull /sdcard/remote_file ./localfile

# Network
adb shell dumpsys netpolicy
adb shell pm list permission

# Performance
adb shell dumpsys gfxinfo com.example.app
adb shell dumpsys meminfo com.example.app
adb shell am start -W com.example.app/.MainActivity  # cold start time
```

## Emulator Commands

```bash
# Start emulator (headless for CI)
emulator -avd Pixel_9 -no-window -no-audio -gpu swiftshader_indirect

# List AVDs
avdmanager list avd

# Create new AVD (ALWAYS use avdmanager)
sdkmanager --install "system-images;android-36;google_apis;x86_64"
avdmanager create avd -n MyPixel -k "system-images;android-36;google_apis;x86_64"

# Kill emulator
adb emu kill

# Check if emulator is running
adb devices | grep emulator
```

## Release Build (signed APK)

```kotlin
// In app/build.gradle.kts
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

---

# Flutter / Dart Reference

## Scaffold a Flutter Project

```bash
# ALWAYS use flutter create — never scaffold manually
flutter create my_app --org com.example --platforms android,windows,web
cd my_app
flutter pub get

# Add platforms to existing project
flutter create . --platforms ios
flutter create . --platforms macos
```

## main.dart (minimal entry point)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure bindings are ready for async work
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
```

## Provider State Management Template

```dart
// models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  User({required this.id, required this.name, required this.email});
}

// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    // TODO: actual login logic
    _user = User(id: '1', name: 'John', email: email);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}

// widgets/login_screen.dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        auth.login(emailController.text, passController.text);
                      }
                    },
                    child: const Text('Login'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Riverpod 2.x Template

```dart
// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final AsyncValue<User?> user;
  const AuthState({required this.user});
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    // TODO: actual login
    state = AsyncData(User(id: '1', name: 'John', email: email));
  }

  void logout() {
    state = const AsyncData(null);
  }
}

// Usage in widget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    return userAsync.when(
      data: (user) => user != null
          ? Text('Hello, ${user.name}')
          : const Text('Not logged in'),
      loading: () => const CircularProgressIndicator(),
      error: (err, stk) => Text('Error: $err'),
    );
  }
}
```

## BLoC Template

```dart
// auth_event.dart
abstract class AuthEvent {
  const AuthEvent();
}
class LoginEvent extends AuthEvent {
  final String email; final String password;
  const LoginEvent({required this.email, required this.password});
}
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// auth_state.dart
abstract class AuthState {
  const AuthState();
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: actual login
      final user = User(id: '1', name: 'John', email: event.email);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}

// Usage: BlocProvider<AuthBloc>(create: (_) => AuthBloc(), child: ...)
```

## go_router Navigation Template

```dart
// routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

// Usage in MaterialApp: router: AppRouter.router
```

## KMP Common Patterns

### Network Client (Ktor) — KMP

```kotlin
// shared/src/commonMain/kotlin/network/AppHttpClient.kt
package network

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class AppHttpClient(private val baseUrl: String) {
    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true })
        }
        install(/* retry/timeout plugins as needed */)
    }

    suspend fun get<T>(path: String): T {
        return client.get { url(baseUrl); url(path) }.body()
    }

    suspend fun post<T, R>(path: String, body: T): R {
        return client.post { url(baseUrl); url(path); setBody(body) }.body()
    }
}

// shared/src/commonMain/kotlin/network/ApiService.kt
class ApiService(private val client: AppHttpClient) {
    suspend fun getUser(id: String): User {
        return client.get<User>("/users/$id")
    }
}
```

### KMP Shared Module with Repository Pattern

```kotlin
// shared/src/commonMain/kotlin/repository/UserRepository.kt
package repository

interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun searchUsers(query: String): List<User>
}

class RemoteUserRepository(private val apiService: ApiService) : UserRepository {
    override suspend fun getUser(id: String): User = apiService.getUser(id)
    override suspend fun searchUsers(query: String): List<User> = listOf() // impl
}

// android app depends on shared via Gradle:
// implementation project(":shared")
```

### KMP Testing

```kotlin
// shared/src/commonTest/kotlin/UserTest.kt
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe

class UserTest : FunSpec({
    test("user deserializes correctly") {
        val json = """{"id":"1","name":"John"}"""
        val user = kotlinx.serialization.json.Json.decodeFromString<User>(json)
        user.id shouldBe "1"
        user.name shouldBe "John"
    }
})

// shared/src/androidInstrumentedTest/kotlin/UserAndroidTest.kt
// Android-specific tests (needs running emulator)

// shared/src/iosTest/kotlin/UserIosTest.kt
// iOS-specific tests (runs on iOS simulator)
```

### KMP Build Commands Reference

```bash
# Build all KMP targets
./gradlew :shared:build

# Build specific target
./gradlew :shared:compileKotlinJvm
./gradlew :shared:compileKotlinIosArm64
./gradlew :shared:compileKotlinIosSimulatorArm64

# Test specific target
./gradlew :shared:jvmTest
./gradlew :shared:iosArm64Test
./gradlew :shared:allTests    # all targets

# Publish to local Maven
./gradlew :shared:publishToMavenLocal

# Create framework (iOS)
./gradlew :shared:podBundle  # for iOS Xcode integration
```

### Consuming KMP from Android App

```kotlin
// app/build.gradle.kts
dependencies {
    implementation(project(":shared"))  // ← Gradle dependency, NOT manual file copy
}
```

### Consuming KMP from iOS (Xcode)

```bash
# In iOS project, use Xcode's "Frameworks, Libraries, and Embedded Content"
# Or use Swift Package Manager with the KMP-generated framework
# Or use CocoaPods with the podspec generated by KMP
# The preferred approach: Xcode project reference to sharedFramework
```

---

## Common Flutter Dependencies (ALWAYS check pub.dev for latest before using)

| Category | Package | Dependency |
|---|---|---|
| State Management (Provider) | provider | `provider: ^6.1.5` |
| State Management (Riverpod) | flutter_riverpod | `flutter_riverpod: ^2.7.0` |
| State Management (BLoC) | flutter_bloc | `flutter_bloc: ^9.1.0` |
| HTTP Client | dio | `dio: ^5.8.0` |
| HTTP (alternative) | http | `http: ^1.3.0` |
| Routing | go_router | `go_router: ^16.3.0` |
| Local Storage (prefs) | shared_preferences | `shared_preferences: ^2.5.0` |
| Local Storage (Hive) | hive + hive_flutter | `hive: ^2.2.4`, `hive_flutter: ^1.1.1` |
| Local Storage (SQLite) | drift | `drift: ^2.26.0` |
| JSON Serialization | json_serializable + json_annotation | `json_serializable: ^6.9.0`, `build_runner: ^2.5.0` |
| Image Picker | image_picker | `image_picker: ^1.2.0` |
| Image Cropping | image_cropper | `image_cropper: ^10.1.0` |
| Charts | fl_chart | `fl_chart: ^1.0.0` |
| Forms | form_validator | `form_validator: ^2.2.0` |
| Date/Time | intl | `intl: ^0.20.0` |
| Permissions | permission_handler | `permission_handler: ^12.0.0` |
| Local Notifications | flutter_local_notifications | `flutter_local_notifications: ^18.0.0` |
| Push Notifications | firebase_messaging | `firebase_messaging: ^12.0.0` |
| Firebase Core | firebase_core | `firebase_core: ^4.2.0` |
| Firebase Auth | firebase_auth | `firebase_auth: ^6.1.0` |
| Firebase Firestore | cloud_firestore | `cloud_firestore: ^6.0.0` |
| Animations | shimmer | `shimmer: ^3.0.0` |
| UI Kit | flutter_staggered_grid_view | `flutter_staggered_grid_view: ^0.7.2` |
| SVG | flutter_svg | `flutter_svg: ^2.0.17` |
| PDF | printing + pdf | `printing: ^5.14.0`, `pdf: ^3.12.0` |
| WebSocket | web_socket_channel | `web_socket_channel: ^3.1.0` |
| Settings | easy_settings | `easy_settings: ^1.2.0` |
| iOS Widgets | ios_platform_columns | `ios_platform_columns: ^1.0.1` |
| iOS Device Info | device_info_plus | `device_info_plus: ^12.1.0` |
| Deep Links | app_links | `app_links: ^6.4.0` |

> **ALWAYS run `flutter pub upgrade --major-versions` or check pub.dev for latest compatible versions before adding dependencies.**
> Use `flutter pub deps` to inspect your dependency tree and check for conflicts.

## Flutter Testing Patterns

### Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockApi extends Mock implements ApiClient {}

void main() {
  late MockApi api;

  setUp(() {
    api = MockApi();
  });

  test('fetches user data correctly', () async {
    when(() => api.fetchUser('1')).thenAnswer(
      (_) async => {'name': 'John', 'email': 'john@test.com'},
    );

    final result = await api.fetchUser('1');
    expect(result['name'], 'John');
    verify(() => api.fetchUser('1')).called(1);
  });
}
```

### Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('counter increments', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

### Integration Test

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  main();
}

// test/integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app loads and navigates', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

## Flutter Build Configurations

### Android (android/app/build.gradle.kts)

```kotlin
android {
    namespace = "com.example.app"
    compileSdk = 36                // ← check sdkmanager --list for latest

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 26
        targetSdk = 36            // ← should match compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures { buildConfig = true }

    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
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

### Flutter Environment Variables

```dart
// Use package:freezed_annotation + build_runner for typed env config
// Or simple approach:
import 'dart:io';

class Env {
  static String get apiKey => Platform.environment['API_KEY'] ?? 'dev-key';
  static String get baseUrl => Platform.environment['BASE_URL'] ?? 'https://api.dev.com';
  static bool get isProd => Platform.environment['FLUTTER_ENV'] == 'production';
}
```

## Common Flutter Patterns

### Repository Pattern

```dart
abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<List<User>> searchUsers(String query);
  Future<void> updateUser(User user);
}

class RemoteUserRepository implements UserRepository {
  final ApiClient api;
  RemoteUserRepository({required this.api});

  @override
  Future<User?> getUser(String id) async {
    final data = await api.get('/users/$id');
    return User.fromJson(data);
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final data = await api.get('/users/search?q=$query');
    return (data as List).map((d) => User.fromJson(d)).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await api.put('/users/${user.id}', user.toJson());
  }
}
```

### Error Handling

```dart
enum AppErrorType { network, server, auth, validation, unknown }

class AppError implements Exception {
  final String message;
  final AppErrorType type;
  final StackTrace? stack;

  const AppError(this.message, {this.type = AppErrorType.unknown, this.stack});

  factory AppError.from(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          return AppError('No internet connection', type: AppErrorType.network);
        case DioExceptionType.badResponse:
          return AppError('Server error', type: AppErrorType.server);
        default:
          return AppError(error.message ?? 'Unknown error');
      }
    }
    return AppError(error.toString());
  }
}

// Usage with try/catch or Bloc/Provider error states
```

### Loading / Empty / Error States

```dart
/// Generic state-aware widget for list/detail screens
class StateWidget extends StatelessWidget {
  final StateType state;
  final Widget? content;
  final VoidCallback? onRetry;

  const StateWidget({super.key, required this.state, this.content, this.onRetry});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateType.loading:
        return const Center(child: CircularProgressIndicator());
      case StateType.error:
        return Center(
          child: Column(
            children: [
              const Text('Something went wrong'),
              if (onRetry != null)
                ElevatedButton(onPressed: onRetry!, child: const Text('Retry')),
            ],
          ),
        );
      case StateType.empty:
        return const Center(child: Text('No data available'));
      case StateType.success:
        return content!;
    }
  }
}

enum StateType { loading, error, empty, success }
```

---

# Flutter iOS / macOS (Remote Mac)

## Remote Mac Details

| Property | Value |
|---|---|
| Hostname | `Ricardos-MacBook-Pro.local` |
| IP | `10.74.74.139` |
| SSH User | `ricardo` |
| macOS | 26.5 (Sequoia) |
| Xcode | 26.5 (Build 17F42) |
| Chip | 10-core Apple Silicon |
| RAM | 16 GB |
| Flutter | Not installed — install via `brew install flutter` |

## Install Flutter on Mac (one-time)

```bash
ssh ricardo@10.74.74.139
brew install flutter
flutter doctor --verbose
sudo xcodebuild -license
```

## iOS Project Setup (run on Mac)

```bash
# Add iOS platform to existing project — use flutter create
flutter create . --platforms ios

# Open iOS project in Xcode (on Mac)
open ios/Runner.xcworkspace

# Add macOS platform too
flutter create . --platforms macos
open macos/Runner.xcworkspace
```

## Available iOS Simulators (on remote Mac)

```bash
# iOS 26.5 (latest)
iPhone 17 Pro        (904D8B6A-FCE4-4DF1-9D11-021E039FA42D)
iPhone 17 Pro Max    (B8E35BFA-5BB0-4627-A036-13328F9C463D)
iPhone 17e           (AE79FB65-E453-4037-8E17-5A394C63ED07)
iPhone Air           (BD98A50D-7F9B-4A88-938B-65992F033C13)
iPhone 17            (5383801E-6879-4BBB-8281-15440111105D)
iPad Pro 13-inch (M5) (DB932232-38B7-462D-BF45-AC05F127D7D1)
iPad Pro 11-inch (M5) (FE2379A6-8A31-47A1-A0DF-813D1BA3CBF4)
iPad mini (A17 Pro)  (550156B8-E292-4BC0-8DB4-A2EC35B9CEC)
iPad Air 13-inch (M4) (E2EC5314-E9B4-47D8-BF88-646F5B4080E6)
iPad Air 11-inch (M4) (25CC8C9A-4DAA-4113-AFFE-623AAE1FC184)
iPad (A16)           (B0DAC45B-C81B-4F47-9ABC-6E31ADFE0CB2)

# iOS 26.4
iPhone 17 Pro        (DF5E2530-0CC2-4B6A-80BD-CF12D94ADC1D)
iPhone 17 Pro Max    (C1000371-5358-4D7E-8F68-3B2EB20EF11D)
iPhone 17e           (1D843F17-CD95-4147-956D-1285ABA748D2)
iPhone Air           (64758AC7-F5A5-4604-B28E-6F07FA730A40)
iPhone 17            (EAE163B7-140D-4919-BAC1-DF8BEC64D31A)
iPad Pro 13-inch (M5) (2E65BC0C-BEF4-4F9B-8B98-A6A7B0D68BB3)
iPad Pro 11-inch (M5) (D0AC8F61-B173-4DB8-AC31-C80E1EC2BE4C)
iPad mini (A17 Pro)  (24C290F5-1876-4E9A-B300-481062CF6773)
iPad Air 13-inch (M4) (A26A0B73-A2AD-43C2-8B19-4837FAC2C184)
iPad Air 11-inch (M4) (41AB9C06-389B-4D04-876F-5E6DE7EDB417)
iPad (A16)           (2DA732C1-98E1-4A77-A9B9-B35F973D4D9C)

# iOS 18.6 (stable) — best for shipping
iPhone 16 Pro        (3EF36628-C22A-470E-9B01-3EC8BCBC145F)
iPhone 16 Pro Max    (0308251E-D97F-4C59-86D6-755B66792F81)
iPhone 16e           (00A89305-1264-4102-A643-D88BDDBF3CDA)
iPhone 16            (743B7481-7DFD-4C14-83DC-70D2483EC8AC)
iPhone 16 Plus       (0C0A0157-5CC2-4DDF-A8B2-8BD58644B4D1)
iPad Pro 11-inch (M4) (41C3976C-C438-457F-A14A-D7FDC679E497)
iPad Pro 13-inch (M4) (B5CF2320-1277-4082-850C-F74DE70A1FB2)
iPad mini (A17 Pro)  (16E3BC53-3D83-4AC2-891A-FD31A22D6618)
iPad (A16)           (764720CF-847F-4908-86A2-BAAE94DF143D)
iPad Air 13-inch (M3) (CF9E749E-CAD8-429D-93AD-2A0FDBA43F26)
iPad Air 11-inch (M3) (A99D4E45-2B69-4D25-ACCF-D15301DD5AAE)

# iOS 18.4
iPhone 16 Pro        (C7ED2AB6-8A8B-434B-AF65-4D52555EF5E3)
iPhone 16 Pro Max    (9103A950-37E6-4F53-969D-1CCD651511C8)
iPhone 16e           (4C0BE873-F6C2-4E14-A6C7-2B7402FA9C6E)
iPhone 16            (5E106985-052A-40D4-8D11-9F46C418254D)
iPhone 16 Plus       (7DC5B104-AAD4-4209-ADA2-8008C831C263)
iPad Pro 11-inch (M4) (BB8837E9-7FAF-4739-9139-772633DA54E6)
iPad Pro 13-inch (M4) (30F9AF91-D6E8-4453-8B0E-78A492D7B76E)
iPad mini (A17 Pro)  (04D864D5-D836-4374-B73C-62FA2439A890)
iPad (A16)           (44C2AA78-1904-4191-8030-7C4F8FDF938D)
iPad Air 13-inch (M3) (CDDB3AFD-EC05-4DE0-A48F-7DA679047E59)
iPad Air 11-inch (M3) (9E0D980B-990C-4254-9EFB-84C050D2D809)

# iOS 18.2
iPhone 16 Pro        (F867CA8C-59FF-4A80-9908-8F6EA5E7F57D)
iPhone 16 Pro Max    (B89EDFAC-5B73-4D1C-91F9-276A4DC69E6D)
iPhone 16            (A1A55A4B-1620-4C2D-847C-1F58615CB5A0)
iPhone 16 Plus       (788D756A-C4E4-4209-ADA2-8008C831C263)
iPhone SE (3rd gen)  (37CB5C49-9107-43D5-BDD9-06C4C6D5EB8C)
iPad Pro 11-inch (M4) (0AEF7299-E77C-48E1-B5F5-BB1505FB21C6)
iPad Pro 13-inch (M4) (9C24C9FC-62A9-45AF-9773-B0D631CBB32E)
iPad Air 11-inch (M2) (CD0C5C44-4F06-4902-8D53-70A967DD6457)
iPad Air 13-inch (M2) (073FE9BC-A1CC-43BC-BDCB-62A70FC20541)
iPad mini (A17 Pro)  (AE4309A0-41CF-4BB3-B3C0-C1A07CEF11C0)
iPad (10th gen)      (58B82F93-4718-49F8-A7CE-C28E7BFF8F16)

# iOS 17.5 (legacy)
iPhone 15 Pro        (5687992E-CC71-43A1-94FA-327EA11ED3F9)
iPhone 15 Pro Max    (0B608358-32D9-4A57-9687-4D75C49CFDD0)
iPhone 15            (578F1AC7-920F-4534-AB47-3A038D9A5274)
iPhone 15 Plus       (B2CB630A-1283-479D-9AC7-1F86A472E2A5)
iPhone SE (3rd gen)  (4AAA6C8B-0964-4AD9-B28E-7AF6C368DB9F)
iPad Pro 11-inch (M4) (AB43200E-735C-46D1-96F3-7531C867D936)
iPad Pro 13-inch (M4) (91877136-4FBE-48FE-989D-65A20CAB688D)
iPad Air 11-inch (M2) (2221DF54-C18C-48CC-9159-8AE7B9DFCDD0)
iPad Air 13-inch (M2) (23FFB937-D519-44D2-9571-CF75E9C67787)
iPad (10th gen)      (CC4663C9-CCF0-43C2-8D5C-075A4FD6ECCA)
iPad mini (6th gen)  (29D5676E-D896-4B38-BEFF-A72C40C3E69B)
```

### Recommended Simulators

```bash
# Latest stable (iOS 18.6) — best for shipping
ssh ricardo@10.74.74.139 'zsh -l -c \"flutter run -d "iPhone 16 Pro Max"\"'

# Latest beta (iOS 26.5) — test new APIs
ssh ricardo@10.74.74.139 'zsh -l -c \"flutter run -d "iPhone 17 Pro Max"\"'

# Smallest device (fastest boot)
ssh ricardo@10.74.74.139 'zsh -l -c \"flutter run -d "iPhone 16e"\"'

# iPad testing
ssh ricardo@10.74.74.139 'zsh -l -c \"flutter run -d "iPad Pro 11-inch (M4)"\"'
```

## iOS Info.plist Configuration

```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone for recording</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to save images</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby results</string>
```

## iOS Build (Remote via SSH)

```bash
# Build release IPA
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter build ipa --release\"'

# Build without code signing (for testing)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter build ipa --release --no-codesign\"'

# Build debug (for simulator)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter build ios --debug --simulator\"'

# Build for specific architecture (arm64 for modern devices)
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter build ios --release --no-simulator --no-codesign --split-debug-info=debug/\"'

# Build macOS app
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter build macos --release\"'
```

## iOS Testing (Remote)

```bash
# Run widget tests
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter test test/widget_test.dart\"'

# Run all tests on iOS simulator
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter test --no-pub --coverage\"'

# Run on specific iOS simulator
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter test -d "iPhone 15" test/unit_test.dart\"'
```

## Xcode Build Commands (on Mac)

```bash
# Clean build
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner

# Build for simulator
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -sdk iphonesimulator -arch x86_64 build

# Build for device
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -sdk iphoneos -arch arm64 build

# Build with signing
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -sdk iphoneos \
  CODE_SIGN_IDENTITY="iPhone Developer: Your Name" \
  PROVISIONING_PROFILE="your-profile-uuid" \
  CODE_SIGNING_ALLOWED=NO build

# Archive for App Store
xcodebuild archive -workspace ios/Runner.xcworkspace \
  -scheme Runner -configuration Release \
  -archive-path build/Runner.xcarchive

# Export IPA from archive
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist exportOptions.plist
```

## exportOptions.plist (for IPA export)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <!-- or "apple-developer", "enterprise", "development", "ad-hoc" -->
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>none</string>
</dict>
</plist>
```

## iOS Certificate & Provisioning (one-time setup on Mac)

```bash
# List available certificates
security find-identity -v -p codesigning

# List available provisioning profiles
security find-identity -v -p provisioning
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# For development builds, use the default Xcode provisioning:
# Xcode → Preferences → Accounts → Apple ID → Manage Certificates
# Create "Apple Development" certificate

# For AdHoc/Enterprise, export the provisioning profile from:
# https://developer.apple.com/account/
```

## iOS Simulator Management

```bash
# List all available simulators
xcrun simctl list devices
xcrun simctl list devices -j | jq '.devices | to_entries[] | {key: .key, devices: [.value[] | select(.availability != "(available)")]}'

# Launch a specific simulator
xcrun simctl boot "iPhone 15 Pro Max"

# Shut down simulator
xcrun simctl shutdown "iPhone 15 Pro Max"

# Reset all simulators
xcrun simctl shutdown all && xcrun simctl erase all

# Install and launch on simulator
xcrun simctl install booted /path/to/Runner.ipa
xcrun simctl launch booted com.yourcompany.app

# View simulator logs
xcrun simctl spawn booted log stream --predicate 'process == "Runner"' --level debug

# Create custom simulator
xcrun simctl create "My Custom iPhone 15" com.apple.CoreSimulator.SimDeviceType.iPhone-15 ios17.0

# Delete simulator
xcrun simctl delete "My Custom iPhone 15"

# Take screenshot
xcrun simctl io booted screenshot /path/to/screenshot.png
```

## macOS App Configuration

```bash
# Add macOS platform
flutter create . --platforms macos

# Build macOS app
flutter build macos --release

# Run macOS app on remote Mac
ssh ricardo@10.74.74.139 'zsh -l -c \"cd /path/to/app && flutter run -d macos\"'

# macOS app bundle is at: build/macos/Build/Products/Release/my_app.app
```

## CI/CD: GitHub Actions for iOS (from Windows)

```yaml
# .github/workflows/ios-build.yml
name: iOS Build

on:
  push:
    tags:
      - 'v*'

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build IPA
        run: flutter build ipa --release --no-codesign

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: ios-app
          path: build/ios/ipa/*.ipa
```

## Common iOS Issues & Fixes

| Issue | Fix |
|---|---|
| "Signing is required" | Open `ios/Runner.xcworkspace` → Runner target → Signing & Capabilities → check "Automatically manage signing" |
| "No signing certificate" | Xcode → Settings → Accounts → Add Apple ID → create Development certificate |
| "Could not find compatible Application Host" | Run `xcodebuild -showsdks` and `sudo xcode-select -switch /Applications/Xcode.app` |
| "Build failed" | Clean: `cd ios && pod deintegrate && pod install` |
| "Simulator not found" | List: `xcrun simctl list devices`, ensure device is booted: `xcrun simctl boot "iPhone 15"` |
| "Code signing error" | Check provisioning profile: `security find-identity -v -p codesigning` |
| "Pod install fails" | `sudo gem install ffi` then `cd ios && pod install --repo-update` |
| "Architectures mismatch (arm64 vs x86_64)" | For simulator: `x86_64`. For device: `arm64`. Use `--simulator` flag for simulator builds. |
