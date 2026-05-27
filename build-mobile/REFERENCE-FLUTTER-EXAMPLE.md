# Real-World Flutter App Example

## Project Structure

```
my_app/
├── lib/
│   ├── main.dart                    # App entry, Router, Theme
│   ├── core/
│   │   ├── network/
│   │   │   ├── api_client.dart      # Dio client
│   │   │   └── interceptors.dart    # Auth/Logging interceptors
│   │   ├── errors/
│   │   │   ├── app_error.dart       # AppError enum + class
│   │   │   └── failure.dart         # Failure interface
│   │   ├── utils/
│   │   │   ├── deep_link_handler.dart
│   │   │   └── device_info_provider.dart
│   │   └── theme/
│   │       └── app_theme.dart       # ThemeData + custom colors
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart      # User +fromJson
│   │   │   └── post_model.dart      # Post +fromJson
│   │   ├── repositories/
│   │   │   └── user_repository.dart # Repository pattern
│   │   └── services/
│   │       └── auth_service.dart    # Auth API calls
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── auth_providers.dart   # State management
│   │   │   └── domain/
│   │   │       └── auth_use_case.dart
│   │   ├── home/
│   │   │   ├── presentation/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── post_list.dart
│   │   │   │   ├── post_card.dart
│   │   │   │   └── home_providers.dart
│   │   │   └── domain/
│   │   │       └── fetch_posts_use_case.dart
│   │   └── post/
│   │       └── presentation/
│   │           └── post_detail_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── loading_state.dart
│   │   ├── error_state.dart
│   │   ├── empty_state.dart
│   │   └── custom_button.dart
│       └── routes/
│           └── app_router.dart      # go_router config
├── test/
│   ├── unit/
│   │   ├── user_repository_test.dart
│   │   └── auth_use_case_test.dart
│   └── widget/
│       ├── login_screen_test.dart
│       └── post_list_test.dart
├── pubspec.yaml
└── analysis_options.yaml
```

## Core: Network & Error Handling

### api_client.dart

```dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ))
    ..interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

// interceptors.dart
class AuthInterceptor extends Interceptor {
  final String? token;

  AuthInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null && token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
```

### app_error.dart

```dart
enum AppErrorType { network, server, auth, validation, unknown }

class AppError implements Exception {
  final String message;
  final AppErrorType type;
  final int? statusCode;

  const AppError(this.message, {this.type = AppErrorType.unknown, this.statusCode});

  factory AppError.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return const AppError('No internet connection', type: AppErrorType.network);
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) {
          return const AppError('Authentication failed', type: AppErrorType.auth);
        }
        return AppError('Server error', type: AppErrorType.server, statusCode: status);
      case DioExceptionType.cancel:
        return const AppError('Request cancelled', type: AppErrorType.unknown);
      default:
        return AppError(e.message ?? 'Unknown error', type: AppErrorType.unknown);
    }
  }

  @override
  String toString() => 'AppError($message, $type)';
}
```

## Core: Deep Links & Device Info

### deep_link_handler.dart

```dart
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  Stream<Uri?> get uriStream => _appLinks.uriStream;

  Future<void> handleDeepLinks() async {
    // Handle initial link (app opened from deep link)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Handle incoming links (app already running)
    uriStream.listen((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final path = uri.path;
    final userId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

    if (path.startsWith('/post/')) {
      // Navigate to post detail
      debugPrint('Navigate to post: $userId');
    } else if (path.startsWith('/user/')) {
      // Navigate to user profile
      debugPrint('Navigate to user: $userId');
    }
  }
}
```

### device_info_provider.dart

```dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoProvider {
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = <String, dynamic>{};

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      info.addAll({
        'model': android.model,
        'manufacturer': android.manufacturer,
        'brand': android.brand,
        'androidVersion': android.version.release,
        'deviceId': android.id,
      });
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      info.addAll({
        'model': ios.model,
        'name': ios.name,
        'systemVersion': ios.systemVersion,
        'identifierForVendor': ios.identifierForVendor,
      });
    }

    return info;
  }
}
```

## Data: Repository Pattern

### user_repository.dart

```dart
import 'package:dio/dio.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository({required ApiClient api}) : _api = api;

  Future<UserModel> getUser(String id) async {
    try {
      final data = await _api.get('/users/$id');
      return UserModel.fromJson(data);
    } on AppError catch (e) {
      throw AppError('Failed to load user: ${e.message}', type: e.type, statusCode: e.statusCode);
    }
  }

  Future<List<PostModel>> getPosts({int page = 1}) async {
    try {
      final data = await _api.get('/posts?_page=$page&_limit=10');
      final list = data as List<dynamic>;
      return list.map((json) => PostModel.fromJson(json)).toList();
    } on AppError catch (e) {
      throw AppError('Failed to load posts: ${e.message}', type: e.type, statusCode: e.statusCode);
    }
  }
}
```

### user_model.dart

```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserModel({required this.id, required this.name, required this.email, this.avatarUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['image'] as String?,
    );
  }
}

class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;

  PostModel({required this.id, required this.title, required this.body, required this.userId});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }
}
```

## Feature: Auth (3 State Management Options)

### Option A: Provider

```dart
// auth_providers.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  AppError? _error;
  bool get loggedIn => _user != null;
  User? get user => _user;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiClient();
      final data = await api.post('/login', data: {'email': email, 'password': password});
      _user = User.fromJson(data);
    } on AppError catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}

// login_screen.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) return const Center(child: CircularProgressIndicator());

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(auth.error!.message, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: auth.isLoading ? null : () => context.read<AuthProvider>().login(email.text, password.text),
                child: const Text('Login'),
              ),
            ]),
          );
        },
      ),
    );
  }
}
```

### Option B: Riverpod

```dart
// auth_providers.dart
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final api = ApiClient();
      final data = await api.post('/login', data: {'email': email, 'password': password});
      state = AsyncData(User.fromJson(data));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void logout() => state = const AsyncData(null);
}

// login_screen.dart (Riverpod)
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: userAsync.when(
        data: (user) => _buildForm(ref, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(WidgetRef ref, User? user) {
    // ... form with ref.read(authProvider.notifier).login(email, password)
  }
}
```

### Option C: BLoC

```dart
// auth_event.dart
abstract class AuthEvent {}
class LoginEvent extends AuthEvent {
  final String email, password;
  const LoginEvent({required this.email, required this.password});
}
class LogoutEvent extends AuthEvent {}

// auth_state.dart
sealed class AuthState {
  const AuthState();
}
final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {}
final class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}
final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final api = ApiClient();
        final data = await api.post('/login', data: {'email': event.email, 'password': event.password});
        emit(Authenticated(User.fromJson(data)));
      } on AppError catch (e) {
        emit(AuthError(e.message));
      }
    });
    on<LogoutEvent>((event, emit) => emit(AuthInitial()));
  }
}

// login_screen.dart (BLoC)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state) {
            case AuthLoading(): return const Center(child: CircularProgressIndicator());
            case Authenticated(): return const Center(child: Text('Logged in'));
            case AuthError(): return Center(child: Text(state.message));
            case AuthInitial(): return _buildForm();
          }
        },
      ),
    );
  }

  Widget _buildForm() {
    return ElevatedButton(
      onPressed: () => context.read<AuthBloc>().add(
        LoginEvent(email: email.text, password: password.text),
      ),
      child: const Text('Login'),
    );
  }
}
```

## Feature: Home (List + Detail + Loading/Empty/Error States)

### home_screen.dart

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: const PostListScreen(),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }
}

class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) return const EmptyState(title: 'No posts yet');
        return RefreshIndicator(
          onRefresh: () => ref.read(postListProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(
              post: posts[index],
              onTap: () => context.go('/post/${posts[index].id}'),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.read(postListProvider.notifier).refresh(),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}
```

### post_detail_screen.dart

```dart
class PostDetailScreen extends ConsumerWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: postAsync.when(
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            // User info section
            const Divider(),
            const Text('Author Info', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
```

## Shared: State Widgets

```dart
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

class EmptyState extends StatelessWidget {
  final String title;
  const EmptyState({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorState({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          ElevatedButton(onPressed: onRetry!, child: const Text('Retry')),
      ],
    );
  }
}
```

## Routing: go_router with Deep Links

```dart
import 'package:go_router/go_router.dart';

final _authShell = ShellRoute(
  builder: (context, state, child) => child,
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen(), routes: [
      GoRoute(path: 'register', builder: (c, s) => const RegisterScreen()),
    ]),
    GoRoute(path: '/', builder: (c, s) => const HomeScreen(), routes: [
      GoRoute(path: 'post/:id', builder: (c, s) => PostDetailScreen(postId: int.parse(s.pathParameters['id']!))),
    ]),
  ],
);

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [_authShell],
  redirect: (context, state) {
    // Check auth state before allowing access
    final isLoggedIn = context.read<AuthProvider>().loggedIn;
    if (!isLoggedIn && state.fullPath != '/login') return '/login';
    return null;
  },
);

// main.dart
@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deepLinkHandler = DeepLinkHandler();
  deepLinkHandler.handleDeepLinks();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        Provider(create: (_) => UserRepository(api: ApiClient())),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'My App',
        routerConfig: router,
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
```

## pubspec.yaml

```yaml
name: my_app
description: A real-world Flutter app example.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  dio: ^5.8.0
  provider: ^6.1.5
  flutter_riverpod: ^2.7.0
  flutter_bloc: ^9.1.0
  go_router: ^16.3.0
  shared_preferences: ^2.5.0
  device_info_plus: ^12.1.0
  app_links: ^6.4.0
  flutter_local_notifications: ^18.0.0
  fl_chart: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.4
```

## Testing Examples

```dart
// test/unit/user_repository_test.dart
void main() {
  late MockApiClient api;
  late UserRepository repository;

  setUp(() {
    api = MockApiClient();
    repository = UserRepository(api: api);
  });

  test('fetches user successfully', () async {
    when(() => api.get('/users/1')).thenAnswer((_) async => {'id': 1, 'name': 'John', 'email': 'john@test.com'});
    final result = await repository.getUser('1');
    expect(result.name, 'John');
    verify(() => api.get('/users/1')).called(1);
  });

  test('throws AppError on network failure', () async {
    when(() => api.get('/users/999')).thenThrow(() => const AppError('Not found', type: AppErrorType.server));
    expect(() => repository.getUser('999'), throwsA(isA<AppError>()));
  });
}

// test/widget/post_list_test.dart
void main() {
  testWidgets('displays loading indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PostListScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays posts when loaded', (tester) async {
    // Mock ref/watch to return posts...
    await tester.pumpWidget(const MaterialApp(home: PostListScreen()));
    expect(find.byType(PostCard), findsWidgets);
  });
}
```
