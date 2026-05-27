# Flutter / Dart Reference

## Scaffold a Flutter Project

### On Windows (no macOS available)

```bash
# Create project with platforms available on Windows
flutter create my_app --org com.example --platforms android,web

cd my_app && flutter pub get

# ⚠️ iOS and macOS platforms CANNOT be generated on Windows
# You must use a Mac, or add them later on a Mac machine
flutter create . --platforms ios    # Requires macOS
flutter create . --platforms macos  # Requires macOS
```

### On macOS (full platform support)

```bash
# Create with ALL platforms at once
flutter create my_app --org com.example --platforms android,ios,web,macos,windows,linux

cd my_app && flutter pub get

# To ADD a platform to an existing project
flutter create . --platforms ios
flutter create . --platforms macos
flutter create . --platforms linux
flutter create . --platforms windows
```

### Adding iOS/macOS to an Existing Project from Windows

If your project was created without iOS/macOS:

1. **On a Mac**, clone the repo or copy the project
2. Run `flutter create . --platforms ios` and `flutter create . --platforms macos`
3. Commit the generated `ios/` and `macos/` folders
4. Push back to your Windows machine

Alternatively, use [FlutterGen](https://fluttergen.com/) or manual setup for iOS build configs if you only need Android development locally.

### Platform Requirements Summary

| Platform | Windows | macOS | Linux | Notes |
|---|---|---|---|---|
| Android | ✅ | ✅ | ✅ | Requires Android SDK |
| iOS | ❌ | ✅ | ❌ | Requires macOS + Xcode |
| Web | ✅ | ✅ | ✅ | Browser-based, no IDE needed |
| Desktop | ✅ | ✅ | ✅ | Windows: no setup. macOS: needs Xcode. Linux: GTK |
| macOS | ❌ | ✅ | ❌ | Requires macOS + Xcode |
| Linux | ❌ | ✅ | ✅ | Requires GTK development packages |

> **WARNING:** The `flutter create . --platforms ios` and `--platforms macos` commands will **fail silently or throw an error on Windows**. Always check your host OS before adding Apple platforms.

## main.dart (minimal)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ),
      home: const HomeScreen(),
    );
  }
}
```

## State Management Templates

### Provider

```dart
// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  User? get user => _user;
  bool get loading => _loading;
  Future<void> login(String email, String password) async {
    _loading = true; notifyListeners();
    _user = User(id: '1', name: 'John', email: email);
    _loading = false; notifyListeners();
  }
  void logout() { _user = null; notifyListeners(); }
}
```

```dart
// Consumer in widget
Consumer<AuthProvider>(
  builder: (context, auth, child) {
    if (auth.loading) return const CircularProgressIndicator();
    return ElevatedButton(
      onPressed: () => auth.login('email', 'pass'),
      child: const Text('Login'),
    );
  },
)
```

### Riverpod 2.x

```dart
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => null;
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = AsyncData(User(id: '1', name: 'John', email: email));
  }
}
```

```dart
// Usage
final userAsync = ref.watch(authProvider);
userAsync.when(data: (user) => user != null ? Text(user.name) : const Text('Not logged in'));
```

### BLoC

```dart
// auth_event.dart
abstract class AuthEvent {}
class LoginEvent extends AuthEvent {
  final String email, password;
  const LoginEvent({required this.email, required this.password});
}

// auth_state.dart
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) => emit(AuthLoading()));
  }
}
```

```dart
// Usage
BlocProvider<AuthBloc>(create: (_) => AuthBloc(), child: ...)
```

## go_router Navigation

```dart
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen(), routes: [
        GoRoute(path: 'register', builder: (c, s) => const RegisterScreen()),
      ]),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen(), routes: [
        GoRoute(path: 'settings', builder: (c, s) => const SettingsScreen()),
      ]),
    ],
  );
}
// MaterialApp: router: AppRouter.router
```

## Recommended Folder Structure

```
lib/
├── main.dart
├── core/ (constants, errors, network, theme, utils)
├── data/ (models, repositories, services)
├── features/
│   └── auth/ (data, presentation/bloc, domain)
└── shared/ (widgets, themes)
test/
├── unit/
├── widget/
└── mocks/
```

## Common Flutter Dependencies

| Category | Package | Dependency | Notes |
|---|---|---|---|
| State (Provider) | provider | `provider: ^6.1.5` | // @version-check Provider — EXAMPLE pin |
| State (Riverpod) | flutter_riverpod | `flutter_riverpod: ^2.7.0` | // @version-check Riverpod — EXAMPLE pin |
| State (BLoC) | flutter_bloc | `flutter_bloc: ^9.1.0` | // @version-check BLoC — EXAMPLE pin |
| HTTP | dio | `dio: ^5.8.0` | // @version-check Dio — EXAMPLE pin |
| HTTP | http | `http: ^1.3.0` | // @version-check http — EXAMPLE pin |
| Routing | go_router | `go_router: ^16.3.0` | // @version-check go_router — EXAMPLE pin |
| Storage (prefs) | shared_preferences | `shared_preferences: ^2.5.0` | // @version-check shared_preferences — EXAMPLE pin |
| Storage (Hive) | hive + hive_flutter | `hive: ^2.2.4`, `hive_flutter: ^1.1.1` | // @version-check Hive — EXAMPLE pin |
| Storage (SQLite) | drift | `drift: ^2.26.0` | // @version-check Drift — EXAMPLE pin |
| JSON | json_serializable + json_annotation | `json_serializable: ^6.9.0`, `build_runner: ^2.5.0` | // @version-check json_serializable — EXAMPLE pin |
| Image Picker | image_picker | `image_picker: ^1.2.0` | // @version-check image_picker — EXAMPLE pin |
| Charts | fl_chart | `fl_chart: ^1.0.0` | // @version-check fl_chart — EXAMPLE pin |
| Permissions | permission_handler | `permission_handler: ^12.0.0` | // @version-check permission_handler — EXAMPLE pin |
| Local Notifications | flutter_local_notifications | `flutter_local_notifications: ^18.0.0` | // @version-check flutter_local_notifications — EXAMPLE pin |
| Firebase Core | firebase_core | `firebase_core: ^4.2.0` | // @version-check firebase_core — EXAMPLE pin |
| Firebase Auth | firebase_auth | `firebase_auth: ^6.1.0` | // @version-check firebase_auth — EXAMPLE pin |
| SVG | flutter_svg | `flutter_svg: ^2.0.17` | // @version-check flutter_svg — EXAMPLE pin |
| PDF | printing + pdf | `printing: ^5.14.0`, `pdf: ^3.12.0` | // @version-check printing — EXAMPLE pin |
| Deep Links | app_links | `app_links: ^6.4.0` | // @version-check app_links — EXAMPLE pin |
| Device Info | device_info_plus | `device_info_plus: ^12.1.0` | // @version-check device_info_plus — EXAMPLE pin |

> **ALWAYS check pub.dev for latest versions.** All version pins in this document are EXAMPLES and must be verified before use.
> Use `flutter pub upgrade --major-versions` and `flutter pub deps` to audit your project.

## Flutter Testing

### Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApi extends Mock implements ApiClient {}

void main() {
  late MockApi api;
  setUp(() => api = MockApi());

  test('fetches user data correctly', () async {
    when(() => api.fetchUser('1')).thenAnswer((_) async => {'name': 'John'});
    final result = await api.fetchUser('1');
    expect(result['name'], 'John');
  });
}
```

### Widget Test

```dart
testWidgets('counter increments', (tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});
```

### Integration Test

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test.dart';
void main() { IntegrationTestWidgetsFlutterBinding.ensureInitialized(); main(); }
```

## Flutter Build Configurations

```kotlin
// @version-check Android build config — EXAMPLE minSdk/targetSdk, verify
// android/app/build.gradle.kts
android {
    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
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
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

## Common Flutter Patterns

### Repository Pattern

```dart
abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<List<User>> searchUsers(String query);
}

class RemoteUserRepository implements UserRepository {
  final ApiClient api;
  RemoteUserRepository({required this.api});
  @override
  Future<User?> getUser(String id) async {
    final data = await api.get('/users/$id');
    return User.fromJson(data);
  }
}
```

### Error Handling

```dart
enum AppErrorType { network, server, auth, validation, unknown }
class AppError implements Exception {
  final String message; final AppErrorType type;
  const AppError(this.message, {this.type = AppErrorType.unknown});
  factory AppError.from(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          return AppError('No internet', type: AppErrorType.network);
        default: return AppError('Server error', type: AppErrorType.server);
      }
    }
    return AppError(error.toString());
  }
}
```

### Loading / Empty / Error States

```dart
class StateWidget extends StatelessWidget {
  final StateType state; final Widget? content; final VoidCallback? onRetry;
  const StateWidget({super.key, required this.state, this.content, this.onRetry});
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateType.loading: return const Center(child: CircularProgressIndicator());
      case StateType.error: return Center(child: Column(children: [const Text('Error'), if(onRetry!=null) ElevatedButton(onPressed:onRetry!, child: const Text('Retry'))]));
      case StateType.empty: return const Center(child: Text('No data'));
      case StateType.success: return content!;
    }
  }
}
enum StateType { loading, error, empty, success }
```
