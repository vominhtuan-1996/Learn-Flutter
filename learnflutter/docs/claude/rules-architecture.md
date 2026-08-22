# Architecture Rules — LearnFlutter

## Layered Architecture

The app follows **Clean Architecture** with these layers:

```
UI Layer (screens/, widgets/)
    ↓
State Management (Cubit/BLoC, Riverpod)
    ↓
Repository/Domain Layer (repos/, domain/)
    ↓
Data Layer (services/, network/, storage/)
    ↓
Platform Layer (native bridge, system APIs)
```

### UI Layer
- **Responsibility:** Display data, capture user input, dispatch events
- **Location:** `lib/features/*/screens/`, `lib/shared/widgets/`
- **Rules:**
  - StatelessWidget by default
  - StatefulWidget only for local UI state (animations, text input focus)
  - Use Cubit for business logic, not StatefulWidget
  - Never call repositories directly from UI
  - Never use `const` for widgets with mutable state

### State Management Layer
- **Responsibility:** Hold app state, validate changes, coordinate side-effects
- **Location:** `lib/features/*/cubit/`, `lib/core/cubit/`
- **Rules:**
  - Cubit for feature-level state (e.g., LoginCubit in auth feature)
  - Global Cubits for app-wide state (SettingCubit, BaseLoadingCubit)
  - Riverpod for functional/provider-based patterns
  - **Emit states, never setState**
  - Handle errors in Cubit, emit error states
  - Never hold UI widgets in Cubit state

### Repository / Domain Layer
- **Responsibility:** Abstract business logic and data sources
- **Location:** `lib/core/repositories/`, `lib/features/*/repos/`
- **Rules:**
  - Repositories implement interfaces (contracts)
  - No Cubit/BLoC dependencies in repositories
  - Return domain models, never raw API DTOs
  - Handle exceptions and convert to domain-specific errors
  - Example: `UserRepository.login(email, password) → User` (not raw API response)

### Data Layer
- **Responsibility:** Fetch/store data from APIs, databases, native code
- **Location:** `lib/core/network/`, `lib/core/storage/`, `lib/core/services/`
- **Rules:**
  - ApiClient wraps Dio with interceptors
  - Service classes for specific concerns (KeyboardService, ShorebirdService)
  - Never expose Dio/Hive/SQLite directly to repositories
  - Map API DTOs to domain models in repositories, not in data layer
  - Implement caching strategies at this layer

## Feature Module Structure

**Each feature should follow this structure:**

```
lib/features/[feature_name]/
├── cubit/
│   ├── [feature]_cubit.dart      # Cubit class
│   └── [feature]_state.dart      # State classes
├── screens/
│   ├── [feature]_screen.dart     # Main screen
│   └── widgets/                   # Feature-specific widgets
├── models/                        # Domain models (optional)
├── repos/                         # Feature-specific repositories (optional)
└── README.md                      # Feature documentation
```

### Feature Independence
- **Features should be loosely coupled**
- **One feature should not import from another feature's private code**
- **If two features need shared logic, move it to `lib/core/`**
- **Use routing for navigation between features** (via `lib/shared/widgets/routes/`)

## State Management Pattern

### Cubit Lifecycle
```dart
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _userRepository;

  LoginCubit(this._userRepository) : super(const LoginInitial());

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    try {
      final user = await _userRepository.login(email, password);
      emit(LoginSuccess(user: user));
    } on LoginException catch (e) {
      emit(LoginFailure(message: e.message));
    }
  }

  @override
  Future<void> close() async {
    // Clean up subscriptions, streams
    await super.close();
  }
}
```

### State Classes
- **Immutable:** Use `const` constructors, `equatable` for equality
- **One state per outcome:** `InitialState`, `LoadingState`, `SuccessState`, `ErrorState`
- **No redundant states:** Don't emit intermediate loading states if not needed

**Good:**
```dart
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;

  const LoginSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}
```

**Avoid:**
```dart
// Too many states
class LoginCubit extends Cubit<String> {
  // Emitting raw strings is untyped and error-prone
}
```

### Global Cubits (AppRoot level)
- **SettingCubit:** Theme, language preferences
- **BaseLoadingCubit:** App-wide loading overlay (e.g., during API calls)
- **SearchBarCubit:** Global search state
- **KeyboardService:** Keyboard visibility (listener pattern, not Cubit)

## Dependency Injection

### Service Locator Pattern
- **Use GetIt singleton** for registering services
- **Initialization:** Call `setupServiceLocator()` at app startup (or inline in `main()`)
- **Pattern:** `final apiClient = getIt<ApiClient>()`

**Convention (if setup exists):**
```dart
// lib/injector.dart (or core/config/service_locator.dart)
final sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerSingleton<KeyboardService>(KeyboardService());
  sl.registerSingleton<AppTalker>(AppTalker());

  // API
  sl.registerSingleton<ApiClient>(ApiClient());

  // Repositories
  sl.registerSingleton<UserRepository>(UserRepository(sl<ApiClient>()));

  // Cubits
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<UserRepository>()));
}
```

**Usage:**
```dart
final userRepo = sl<UserRepository>();
final apiClient = sl<ApiClient>();
```

## Networking Pattern

### API Client & Repositories
```
ApiClient (Dio wrapper)
    ↓
UserRepository (abstracts login, logout, fetch user)
    ↓
LoginCubit (calls repo.login(), emits states)
    ↓
LoginScreen (listens to LoginCubit, shows UI)
```

### Example Flow
```dart
// 1. ApiClient (data layer)
class ApiClient {
  Future<Map<String, dynamic>> post(String path, {required Map<String, dynamic> body}) async {
    final response = await _dio.post(path, data: body);
    return response.data;
  }
}

// 2. Repository (domain layer)
class UserRepository {
  final ApiClient _apiClient;

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/login', body: {
        'email': email,
        'password': password,
      });
      return User.fromJson(response);
    } catch (e) {
      throw LoginException(message: 'Failed to login');
    }
  }
}

// 3. Cubit (state management)
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _repo;

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _repo.login(email, password);
      emit(LoginSuccess(user: user));
    } on LoginException catch (e) {
      emit(LoginFailure(message: e.message));
    }
  }
}

// 4. Screen (UI layer)
@override
Widget build(BuildContext context) {
  return BlocBuilder<LoginCubit, LoginState>(
    builder: (context, state) {
      if (state is LoginLoading) return LoadingWidget();
      if (state is LoginSuccess) return HomeScreen();
      if (state is LoginFailure) return ErrorWidget(message: state.message);
      return LoginForm();
    },
  );
}
```

## Storage Patterns

### Shared Preferences (for key-value)
- **Use for:** Auth tokens, user preferences, simple flags
- **Wrapper:** `lib/core/storage/shared_preferences_wrapper.dart` (if exists) or direct usage
- **Pattern:**
  ```dart
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token);
  final token = prefs.getString('auth_token');
  ```

### Hive (for NoSQL/local objects)
- **Use for:** User data, cache, offline data
- **Location:** `lib/core/storage/hive_demo/`
- **Pattern:**
  ```dart
  final box = Hive.box<Person>('persons');
  box.add(Person(name: 'John'));
  ```

### SQLite (for structured data)
- **Use for:** Complex queries, relational data
- **Location:** `lib/core/storage/sqlite/`

## Naming Conventions (Architecture)

| Element | Pattern | Example |
|---------|---------|---------|
| Feature folder | `snake_case` | `lib/features/user_auth/` |
| Cubit class | `{Feature}Cubit` | `LoginCubit`, `SettingCubit` |
| State class | `{Feature}State` | `LoginState`, `LoginSuccess` |
| Repository interface | `{Model}Repository` | `UserRepository`, `PostRepository` |
| Screen widget | `{Feature}Screen` | `LoginScreen`, `HomeScreen` |
| Repository file | `{model}_repository.dart` | `user_repository.dart` |
| Service | `{Function}Service` | `KeyboardService`, `ShorebirdService` |

## Anti-Patterns (Avoid)

### ❌ Data Leakage
```dart
// WRONG: Exposing API response directly
class UserRepository {
  Future<UserApiDto> getUser() async => apiClient.getUser();
}

// RIGHT: Map to domain model
Future<User> getUser() async {
  final dto = await apiClient.getUser();
  return User.fromDto(dto);
}
```

### ❌ Tight Coupling
```dart
// WRONG: Cubit depends on specific API client
class LoginCubit extends Cubit<LoginState> {
  final ApiClient _apiClient; // Too specific
}

// RIGHT: Depend on abstraction (repository)
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _repository; // Abstraction
}
```

### ❌ Business Logic in UI
```dart
// WRONG: API call in screen
class LoginScreen extends StatelessWidget {
  void _login() async {
    final response = await apiClient.post('/login', ...);
  }
}

// RIGHT: Delegate to Cubit
class LoginScreen extends StatelessWidget {
  void _login() {
    context.read<LoginCubit>().login(email, password);
  }
}
```

### ❌ Mixing State Patterns
```dart
// WRONG: StatefulWidget + Cubit for same state
class LoginScreen extends StatefulWidget {
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(...); // Conflicting patterns
  }
}

// RIGHT: Use Cubit only
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(...);
  }
}
```

## Circular Dependencies

- **Never import from feature → feature**
- **Always route through `lib/shared/widgets/routes/` or `lib/core/`**
- **Use routing instead of direct imports for navigation**

**Example:**
```dart
// ❌ WRONG: auth feature imports home feature
import 'package:learnflutter/features/home/screens/home_screen.dart';

// ✅ RIGHT: Use routing
Navigator.of(context).pushNamed(Routes.home);
```
