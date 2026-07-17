---
name: setup-flutter
description: "Khởi tạo project Flutter mới (self-contained) theo kiến trúc feature-first + Cubit/State + singleton ApiClient/Repository, kèm theme/localization, feature auth mẫu, cấu hình Android/iOS và OTA Shorebird. Dùng khi user muốn init/scaffold/tạo mới một app Flutter. Trigger: \"tạo project flutter\", \"init flutter app\", \"scaffold flutter\", \"/setup-flutter <app_name> [bundle_id]\"."
license: MIT
version: 1.0.0
argument-hint: "<app_name> [bundle_id]"
---

# Setup Flutter Project (init new project)

Khởi tạo một **project Flutter mới** theo cấu trúc & convention: backbone `app / core / shared / features`, pattern **Cubit + State (Equatable)**, **singleton `ApiClient` / Repository**, cấu hình **Android / iOS**, pipeline OTA **Shorebird** (+ Fastlane tuỳ chọn).

> 📖 Hướng dẫn sử dụng dành cho người dùng: xem [USAGE.md](USAGE.md).

> **Quan trọng — command này TỰ CHỨA (self-contained):** toàn bộ nội dung file được nhúng ngay bên dưới và dùng **import tương đối** (`../../...`), nên **KHÔNG cần** bất kỳ repo nguồn nào (vd `learnflutter`) và **không cần** đổi tên package. Chạy được trên mọi máy, mọi người.
>
> Đây KHÔNG phải template Clean Architecture (injectable / dartz / usecase) — dùng `flutter_bloc` ở mức **Cubit**, repository **singleton** (`.instance`), config qua `String.fromEnvironment`.

## Arguments

`$ARGUMENTS` — `<app_name>` (snake_case) + (tuỳ chọn) `<bundle_id>`.
Ví dụ: `/setup-flutter my_app com.company.my_app`

Suy ra các biến (dùng xuyên suốt; thay bằng giá trị thật khi chạy lệnh):
- `APP_NAME` = tham số 1 (snake_case).
- `BUNDLE_ID` = tham số 2; nếu trống → hỏi user, mặc định `com.example.<app_name>`.
- `ORG` = `BUNDLE_ID` bỏ phần cuối (vd `com.company`).
- Lệnh `flutter`: nếu máy dùng fvm thì là `fvm flutter`, ngược lại `flutter`. Tự phát hiện (`which flutter` / có `.fvmrc`).

## Kiến trúc

```
Feature-first + Cubit/State

lib/
├── app/        → App widget gốc, theme, localization
├── core/       → hạ tầng dùng chung: network, config, cubit/state base, services, storage, utils
├── shared/     → UI tái sử dụng: components, widgets, models, utils
└── features/   → mỗi feature 1 thư mục: cubit/ · state/ · model/ · repos/ · screens/
```

- **State:** `flutter_bloc` → `BaseCubit<S>` + `BaseState` (Equatable). Không dùng BLoC events.
- **Network:** singleton `ApiClient.instance` (Dio + interceptors auth/retry/error/talker), trả `Map`/`BaseResponse`, ném `ApiException`.
- **Repository:** singleton (`.instance`) gọi `ApiClient.instance`, map sang model trong `shared/models`.
- **Config:** `core/config/environment_variables.dart` đọc `String.fromEnvironment(...)`, truyền qua `--dart-define`.

> **Quy ước import:** trong toàn bộ file `lib/` dùng **import tương đối** (`../../core/...`), KHÔNG dùng `package:<app_name>/...`. Nhờ vậy code không phụ thuộc tên project.

---

## Instructions

### 1. Tạo project & dọn dẹp

```bash
flutter create APP_NAME --org ORG --platforms android,ios
cd APP_NAME
```
> `flutter create --org` đã tự set `applicationId` (Android) và `PRODUCT_BUNDLE_IDENTIFIER` (iOS). Lưu ý: bundle id iOS không cho phép dấu `_`, Flutter sẽ tự camelCase phần `app_name` (vd `com.example.my_app` → iOS `com.example.myApp`).

### 2. Dependencies — `pubspec.yaml`

Thay block `dependencies` / `dev_dependencies` bằng (core deps cho backbone; bổ sung theo feature sau):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Network
  dio: ^5.7.0
  curl_logger_dio_interceptor: ^1.0.0
  talker_dio_logger: ^4.4.1

  # Storage
  shared_preferences: ^2.3.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Localization / UI nền tảng
  flutter_localization: ^0.3.2
  flutter_screenutil: ^5.9.3
  google_fonts: ^6.2.1

  # Config
  flutter_dotenv: ^5.2.1

  # OTA
  shorebird_code_push: ^2.0.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

```bash
flutter pub get
```
> Nếu SDK/Flutter mới hơn báo version conflict, nâng các package lên bản tương thích (đây là mốc đã test với Flutter 3.29.x / Dart 3.7).

### 3. Tạo cây thư mục

```bash
rm -f lib/main.dart
mkdir -p lib/app/localization lib/app/theme \
  lib/core/config lib/core/cubit lib/core/state \
  lib/core/network/api_client/interceptors \
  lib/core/repositories lib/core/services lib/core/storage lib/core/utils \
  lib/shared/components lib/shared/widgets lib/shared/models lib/shared/utils \
  lib/features/auth/cubit lib/features/auth/state lib/features/auth/model \
  lib/features/auth/repos lib/features/auth/screens
```

### 4. File hạ tầng `core/` — tạo nguyên văn

**`lib/core/state/base_state.dart`**
```dart
import 'package:equatable/equatable.dart';

class BaseState extends Equatable {
  @override
  List<Object?> get props => [];
}
```

**`lib/core/cubit/base_cubit.dart`**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lớp cơ sở cho mọi Cubit — chuẩn hoá khởi tạo state & nơi cắm
/// logging / error handling tập trung về sau.
abstract class BaseCubit<E> extends Cubit<E> {
  BaseCubit(super.initialState);
}
```

**`lib/core/config/environment_variables.dart`**
```dart
abstract class EnvironmentVariables {
  static const appTitle = String.fromEnvironment('appTitle');
  static const appServerUrl = String.fromEnvironment('appServerUrl');
  static const appServerApiKey = String.fromEnvironment('appServerApiKey');
}
```

**`lib/core/network/api_client/api_exception.dart`**
```dart
/// ApiException: wrapper cho lỗi API.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
```

**`lib/core/network/api_client/base_response.dart`**
```dart
/// BaseResponse - chuẩn hoá phản hồi API: { status, message, errorData, data }.
class BaseResponse<T> {
  final int status;
  final String message;
  final dynamic errorData;
  final T? data;

  BaseResponse({
    required this.status,
    required this.message,
    this.errorData,
    this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json,
      [T Function(dynamic)? fromJsonT]) {
    final rawData = json['data'];
    return BaseResponse<T>(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      errorData: json['errorData'],
      data: (rawData != null && fromJsonT != null)
          ? fromJsonT(rawData)
          : rawData as T?,
    );
  }

  bool get isSuccess => status == 0;
}
```

**`lib/core/network/api_client/interceptors/auth_interceptor.dart`**
```dart
import 'package:dio/dio.dart';

import '../api_client.dart';

/// Gắn Bearer token vào mỗi request và refresh token khi gặp 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.apiClient);

  final ApiClient apiClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = apiClient.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;

    final canRefresh = status == 401 &&
        apiClient.tokenRefreshHandler != null &&
        options.extra['retried'] != true;

    if (canRefresh) {
      try {
        final newToken = await apiClient.tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          apiClient.setAuthToken(newToken);
          options.extra['retried'] = true;
          final cloneReq = await apiClient.dio.fetch(options);
          return handler.resolve(cloneReq);
        }
      } catch (_) {
        // ignore refresh errors and fall through
      }
    }

    handler.next(err);
  }
}
```

**`lib/core/network/api_client/interceptors/error_interceptor.dart`**
```dart
import 'package:dio/dio.dart';

import '../api_exception.dart';

/// Bọc lỗi Dio thành [ApiException] với message thân thiện.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      return handler.next(err);
    }

    final apiEx = ApiException(
      _extractErrorMessage(err),
      statusCode: err.response?.statusCode,
      data: err.response?.data,
    );

    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: apiEx,
      type: err.type,
      response: err.response,
    ));
  }

  String _extractErrorMessage(DioException error) {
    try {
      final resp = error.response;
      if (resp?.data is Map && resp?.data['message'] != null) {
        return resp!.data['message'].toString();
      }
      if (resp?.statusMessage != null && resp!.statusMessage!.isNotEmpty) {
        return resp.statusMessage!;
      }
    } catch (_) {}

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';
      case DioExceptionType.receiveTimeout:
        return 'Receive timed out';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No Internet Connection';
      default:
        return error.message ?? 'An unknown error occurred';
    }
  }
}
```

**`lib/core/network/api_client/interceptors/retry_interceptor.dart`**
```dart
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Tự động retry khi timeout hoặc lỗi server 5xx, có giới hạn lần thử.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryInterval = const Duration(seconds: 1),
  });

  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    int retryCount = extra['retry_count'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      extra['retry_count'] = retryCount;
      developer.log(
        'Retrying ${err.requestOptions.path} (attempt $retryCount)',
        name: 'RetryInterceptor',
      );
      try {
        await Future.delayed(retryInterval);
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return super.onError(e, handler);
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    return status != null && status >= 500 && status <= 599;
  }
}
```

**`lib/core/network/api_client/api_client.dart`**
```dart
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

export 'api_exception.dart';
export 'base_response.dart';

typedef TokenRefreshHandler = Future<String?> Function();

/// ApiClient - Singleton Dio wrapper dùng chung toàn app.
class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;
  String? _authToken;
  TokenRefreshHandler? _tokenRefreshHandler;

  String? get authToken => _authToken;
  TokenRefreshHandler? get tokenRefreshHandler => _tokenRefreshHandler;

  /// Gọi 1 lần lúc khởi động app.
  void init({
    required String baseUrl,
    TokenRefreshHandler? tokenRefreshHandler,
  }) {
    _tokenRefreshHandler = tokenRefreshHandler;
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      AuthInterceptor(this),
      RetryInterceptor(dio: dio),
      ErrorInterceptor(),
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
        ),
      ),
    ]);
  }

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;
  void setTokenRefreshHandler(TokenRefreshHandler handler) =>
      _tokenRefreshHandler = handler;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _wrap(() => dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _wrap(() => dio.post(path, data: data));

  Future<dynamic> put(String path, {Object? data}) =>
      _wrap(() => dio.put(path, data: data));

  Future<dynamic> delete(String path, {Object? data}) =>
      _wrap(() => dio.delete(path, data: data));

  Future<dynamic> _wrap(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
```

### 5. File `shared/models/`

**`lib/shared/models/base_model.dart`**
```dart
/// BaseModel - hợp đồng tối thiểu cho model serialize sang JSON.
abstract class BaseModel {
  Map<String, dynamic> toJson();
}
```

**`lib/shared/models/user_model.dart`**
```dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;

  const UserModel({required this.id, required this.email, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};

  @override
  List<Object?> get props => [id, email, name];
}
```

### 6. File `app/` — theme, localization, root

**`lib/app/theme/app_colors.dart`**
```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
}
```

**`lib/app/theme/app_text_style.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyle {
  static TextStyle get heading =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get title =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);
}
```

**`lib/app/theme/app_theme.dart`**
```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary, brightness: Brightness.light),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary, brightness: Brightness.dark),
      );
}
```

**`lib/app/theme/theme_storage.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const String _key = 'theme_mode';

  Future<ThemeMode> read() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> write(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
```

**`lib/app/theme/theme_controller.dart`**
```dart
import 'package:flutter/material.dart';

import '../../core/cubit/base_cubit.dart';
import 'theme_storage.dart';

/// Quản lý ThemeMode toàn app theo pattern Cubit ([BaseCubit]).
class ThemeController extends BaseCubit<ThemeMode> {
  ThemeController(this._storage) : super(ThemeMode.system);

  final ThemeStorage _storage;

  Future<void> load() async => emit(await _storage.read());

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _storage.write(mode);
  }

  Future<void> toggle() async =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
```

**`lib/app/localization/app_local_translate.dart`**
```dart
import 'package:flutter_localization/flutter_localization.dart';

/// Khai báo key dịch & locale (flutter_localization).
mixin AppLocale {
  static const String title = 'title';
  static const String loginTitle = 'loginTitle';
  static const String email = 'email';
  static const String password = 'password';
  static const String loginButton = 'loginButton';

  static const Map<String, dynamic> en = {
    title: 'My App',
    loginTitle: 'Sign in',
    email: 'Email',
    password: 'Password',
    loginButton: 'Login',
  };

  static const Map<String, dynamic> vi = {
    title: 'My App',
    loginTitle: 'Đăng nhập',
    email: 'Email',
    password: 'Mật khẩu',
    loginButton: 'Đăng nhập',
  };
}

const List<MapLocale> kAppLocales = [
  MapLocale('en', AppLocale.en),
  MapLocale('vi', AppLocale.vi),
];
```

**`lib/app/app.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../features/auth/screens/login_page.dart';
import 'localization/app_local_translate.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_storage.dart';

/// Root widget: theme (qua [ThemeController]) + localization + màn hình khởi đầu.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    _localization.init(mapLocales: kAppLocales, initLanguageCode: 'vi');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeController(ThemeStorage())..load(),
      child: BlocBuilder<ThemeController, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => MaterialApp(
              title: AppLocale.en[AppLocale.title] as String,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              supportedLocales: _localization.supportedLocales,
              localizationsDelegates: _localization.localizationsDelegates,
              home: const LoginPage(),
            ),
          );
        },
      ),
    );
  }
}
```

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/environment_variables.dart';
import 'core/network/api_client/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final baseUrl = EnvironmentVariables.appServerUrl.isNotEmpty
      ? EnvironmentVariables.appServerUrl
      : 'https://api.example.com';
  ApiClient.instance.init(baseUrl: baseUrl);

  runApp(const App());
}
```

### 7. Feature mẫu — `auth/` (pattern Cubit/State/Repo/Screen)

**`lib/features/auth/repos/auth_repository.dart`**
```dart
import '../../../core/network/api_client/api_client.dart';
import '../../../shared/models/user_model.dart';

/// AuthRepository - singleton, gọi [ApiClient] và map sang [UserModel].
class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final ApiClient _api = ApiClient.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final resp = await _api.post('/auth/login',
        data: {'email': email, 'password': password});

    final token = resp['token'] ?? resp['accessToken'];
    if (token is String && token.isNotEmpty) _api.setAuthToken(token);

    final userJson = resp['user'] ?? resp;
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  Future<void> logout() async => _api.clearAuthToken();
}
```

**`lib/features/auth/state/auth_state.dart`**
```dart
import '../../../core/state/base_state.dart';
import '../../../shared/models/user_model.dart';

class AuthState extends BaseState {
  final bool loading;
  final UserModel? user;
  final String? error;

  AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, UserModel? user, String? error}) =>
      AuthState(
        loading: loading ?? this.loading,
        user: user ?? this.user,
        error: error,
      );

  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [loading, user, error];
}
```

**`lib/features/auth/cubit/auth_cubit.dart`**
```dart
import '../../../core/cubit/base_cubit.dart';
import '../repos/auth_repository.dart';
import '../state/auth_state.dart';

class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit() : super(AuthState());

  final AuthRepository _repo = AuthRepository.instance;

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await _repo.login(email: email, password: password);
      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthState());
  }
}
```

**`lib/features/auth/screens/login_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../../app/localization/app_local_translate.dart';
import '../../../app/theme/app_text_style.dart';
import '../cubit/auth_cubit.dart';
import '../state/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocale.loginTitle.getString(context))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error!)));
            }
            if (state.isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Welcome ${state.user!.name}')));
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocale.title.getString(context),
                    style: AppTextStyle.heading),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocale.email.getString(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocale.password.getString(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.loading
                        ? null
                        : () => context.read<AuthCubit>().login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            ),
                    child: state.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLocale.loginButton.getString(context)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

> **Thêm feature mới:** tạo `lib/features/<name>/` với `cubit/ · state/ · model/ · repos/ · screens/` theo đúng pattern trên, dùng import tương đối.

### 8. `test/widget_test.dart` — thay smoke test mặc định

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:APP_NAME/features/auth/screens/login_page.dart';

void main() {
  testWidgets('LoginPage renders email & password fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
```
> File test nằm ngoài `lib/` nên **buộc** dùng `package:APP_NAME/...` — thay `APP_NAME` bằng tên package thật (giá trị `name:` trong `pubspec.yaml`).

### 9. `analysis_options.yaml`

Thêm block `analyzer` (giữ `include: package:flutter_lints/flutter.yaml` sẵn có):
```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

### 10. Cấu hình Android (đã gần xong nhờ `--org`)

- `applicationId` đã = `BUNDLE_ID`. Kiểm tra `android/app/build.gradle` (hoặc `build.gradle.kts`): `namespace` + `applicationId`.
- Signing release: tạo keystore + `android/key.properties`, thêm `signingConfigs { release { ... } }` đọc từ `key.properties`. **Không commit** keystore / `key.properties`.
- `minSdk` ≥ 21 (theo plugin yêu cầu).

### 11. Cấu hình iOS

- `PRODUCT_BUNDLE_IDENTIFIER` đã set qua `--org` (iOS camelCase phần app_name). Đổi thêm nếu cần trong `ios/Runner.xcodeproj` (Debug/Release/Profile).
- Set Display Name, Team/Signing trong Xcode.
- `cd ios && pod install`.

### 12. OTA Shorebird (tuỳ chọn — standalone, không cần repo nguồn)

```bash
shorebird init        # tạo shorebird.yaml + app_id cho project này
shorebird release android   # / ios — build bản phát hành có Shorebird engine
shorebird patch android     # / ios — đẩy hotfix OTA
```
> Cần cài Shorebird CLI (`https://docs.shorebird.dev`) và đăng nhập. Bước này không bắt buộc cho lần chạy đầu.

### 13. CI/CD Fastlane (tuỳ chọn)

Nếu cần pipeline ký + phát hành tự động:
```bash
fastlane init        # khởi tạo fastlane/ (Appfile, Fastfile) cho project
```
Sau đó tự định nghĩa lane (vd `enterprise`, `patch`) gọi `flutter build` + `shorebird release/patch`. Điền `app_identifier` = `BUNDLE_ID`, secrets để trong `fastlane/.env` và **gitignore** nó.

### 14. `.gitignore` — chặn secrets

Thêm:
```gitignore
# signing / secrets
fastlane/.env
android/key.properties
*.keystore
*.jks
```

### 15. Verify & báo cáo

```bash
flutter analyze        # kỳ vọng: No issues found
flutter test           # smoke test pass
flutter run --dart-define=appServerUrl=https://api.example.com --dart-define=appTitle=APP_NAME
```

Sau khi xong, thông báo cho user:
- Backbone đã dựng (`app / core / shared / features`) + feature mẫu `auth`, dùng **import tương đối** (không phụ thuộc tên project).
- Bundle id Android/iOS đã set qua `--org`.
- Việc cần làm tay (tuỳ chọn): keystore Android + `key.properties`, signing iOS, `shorebird init`, `fastlane init`.
- Cách thêm feature mới (`cubit/state/model/repos/screens`).
