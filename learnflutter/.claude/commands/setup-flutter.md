# Setup Flutter Project

Khởi tạo dự án Flutter mobile với Clean Architecture + Feature-first structure.

## Arguments

`$ARGUMENTS` — tên project (snake_case). Ví dụ: `/setup-flutter my_app`

## Architecture

```
Clean Architecture (3 layers):
  Presentation  →  BLoC / Cubit (UI state)
  Domain        →  UseCases + Entities + Repository interfaces
  Data          →  Repository impl + DataSources + Models
```

## Instructions

### 1. Tạo project

```bash
flutter create $ARGUMENTS --org com.company --platforms android,ios
cd $ARGUMENTS
```

### 2. Cài dependencies — pubspec.yaml

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # DI
  get_it: ^8.0.0
  injectable: ^2.4.4

  # Navigation
  go_router: ^14.2.7

  # Network
  dio: ^5.6.0
  retrofit: ^4.2.0

  # Local storage
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2

  # Functional / error handling
  dartz: ^0.10.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Utils
  logger: ^2.4.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code generation
  build_runner: ^2.4.12
  injectable_generator: ^2.6.2
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  retrofit_generator: ^9.1.4
```

Sau đó chạy:
```bash
flutter pub get
```

### 3. Cấu trúc thư mục — tạo toàn bộ

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── network_info.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       ├── extensions.dart
│       └── validators.dart
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_local_datasource.dart
│       │   │   └── auth_remote_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       ├── login_usecase.dart
│       │       └── logout_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           ├── pages/
│           │   └── login_page.dart
│           └── widgets/
│               └── login_form.dart
├── injection/
│   ├── injection.dart
│   └── injection.config.dart     ← generated
└── main.dart
```

### 4. Tạo các file core

**`lib/core/errors/failures.dart`**
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

**`lib/core/errors/exceptions.dart`**
```dart
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
```

**`lib/core/usecase/usecase.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

**`lib/core/network/dio_client.dart`**
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';

@singleton
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      _AuthInterceptor(),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: attach token from SecureStorage
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: refresh token or redirect to login
    }
    handler.next(err);
  }
}
```

**`lib/core/constants/api_constants.dart`**
```dart
class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
```

**`lib/core/constants/app_constants.dart`**
```dart
class AppConstants {
  AppConstants._();
  static const String appName = '$ARGUMENTS';
  static const String tokenKey = 'auth_token';
}
```

**`lib/core/router/app_router.dart`**
```dart
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/pages/login_page.dart';

@singleton
class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
      ],
    );
  }
}
```

**`lib/injection/injection.dart`**
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'injection/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: getIt<AppRouter>().router,
    );
  }
}
```

### 5. Feature mẫu — Auth

**`lib/features/auth/domain/entities/user.dart`**
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  const User({required this.id, required this.email, required this.name});

  @override
  List<Object> get props => [id, email, name];
}
```

**`lib/features/auth/domain/repositories/auth_repository.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}
```

**`lib/features/auth/domain/usecases/login_usecase.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase extends UseCase<User, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) =>
      repository.login(params.email, params.password);
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
```

**`lib/features/auth/presentation/bloc/auth_bloc.dart`**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

### 6. Chạy code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 7. analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - sort_constructors_first
    - require_trailing_commas

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
  errors:
    invalid_annotation_target: ignore
```

### 8. Verify & thông báo

Chạy `flutter analyze` để kiểm tra. Sau đó thông báo:
- Danh sách file đã tạo
- Cách thêm feature mới: tạo thư mục trong `lib/features/[feature_name]/` theo cùng pattern data/domain/presentation
- Lệnh tạo code: `dart run build_runner build --delete-conflicting-outputs`
- Cách đăng ký DI: thêm `@injectable` / `@singleton` annotation rồi re-run build_runner
