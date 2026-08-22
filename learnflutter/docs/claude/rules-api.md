# API & Network Rules — LearnFlutter

## Network Layer Architecture

```
ApiClient (Dio wrapper, singleton)
    ↓
Repository (business logic, error mapping)
    ↓
Cubit (state management, user-facing errors)
    ↓
Screen (UI layer)
```

## ApiClient Setup

### Singleton Pattern
```dart
// lib/core/network/api_client/api_client.dart
class ApiClient {
  static final _instance = ApiClient._();

  factory ApiClient() => _instance;

  final Dio _dio;

  ApiClient._() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      LoggerInterceptor(), // Curl-style logging
    );
    _dio.interceptors.add(
      AuthInterceptor(), // Add auth tokens
    );
    _dio.interceptors.add(
      ErrorInterceptor(), // Handle common errors
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post<T>(path, data: data);
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.sendTimeout:
        return NetworkException('Request timeout');
      case DioExceptionType.receiveTimeout:
        return NetworkException('Response timeout');
      case DioExceptionType.badResponse:
        return _handleHttpError(e.response?.statusCode, e.response?.data);
      default:
        return NetworkException('Network error');
    }
  }

  Exception _handleHttpError(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return ValidationException('Invalid request');
      case 401:
        return UnauthorizedException('Unauthorized');
      case 403:
        return ForbiddenException('Forbidden');
      case 404:
        return NotFoundException('Not found');
      case 500:
        return ServerException('Server error');
      default:
        return ApiException('API error: $statusCode');
    }
  }
}
```

## Interceptors

### Auth Interceptor
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired, trigger logout
      // emit(LogoutEvent());
    }
    handler.next(err);
  }
}
```

### Request Queue (Offline Support)
```dart
class NetworkQueueService {
  final Queue<PendingRequest> _queue = Queue();
  final ApiClient _apiClient;

  Future<T> enqueue<T>(Future<T> Function() request) async {
    try {
      // Try immediate request
      return await request();
    } catch (e) {
      if (_isNetworkError(e)) {
        // Queue for later
        final pending = PendingRequest(request);
        _queue.add(pending);
        return await pending.future;
      }
      rethrow;
    }
  }

  Future<void> processQueue() async {
    while (_queue.isNotEmpty) {
      final request = _queue.removeFirst();
      try {
        await request.execute();
      } catch (e) {
        _queue.addLast(request); // Re-queue if failed
      }
    }
  }

  bool _isNetworkError(Object e) {
    return e is NetworkException || 
           (e is DioException && e.type == DioExceptionType.unknown);
  }
}
```

## Repository Pattern

### API Abstraction
```dart
// lib/core/network/repositories/user_repository.dart
class UserRepository {
  final ApiClient _apiClient;
  final UserLocalRepository _localRepo;

  UserRepository(this._apiClient) : _localRepo = UserLocalRepository();

  /// Fetches user from API and caches locally
  Future<User> fetchUser(int id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/$id',
      );
      final user = User.fromJson(response);
      
      // Cache locally
      await _localRepo.saveUser(user);
      
      return user;
    } on UnauthorizedException {
      // Handle 401 — logout
      rethrow;
    } on NotFoundException {
      // Handle 404
      rethrow;
    } on NetworkException {
      // Try local cache
      return await _localRepo.getUser(id) ??
          (throw CacheNotFoundException('User not in cache'));
    }
  }

  /// Login endpoint
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final authResult = AuthResult.fromJson(response);
      
      // Store token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResult.token);
      
      return authResult;
    } on ValidationException catch (e) {
      // Handle 400
      rethrow;
    } on UnauthorizedException {
      // Invalid credentials
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } finally {
      // Clear token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }
}
```

## Error Handling

### Domain Exceptions
```dart
// lib/core/network/exceptions.dart
sealed class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ValidationException extends ApiException {
  final Map<String, String>? errors;
  
  ValidationException(String message, {this.errors}) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}
```

### Error Handling in Cubit
```dart
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _repository;

  LoginCubit(this._repository) : super(const LoginInitial());

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    
    try {
      final result = await _repository.login(email, password);
      emit(LoginSuccess(user: result.user));
    } on ValidationException catch (e) {
      emit(LoginFailure(
        message: e.errors?['email'] ?? 'Validation failed',
      ));
    } on UnauthorizedException {
      emit(const LoginFailure(message: 'Invalid email or password'));
    } on NetworkException {
      emit(const LoginFailure(message: 'Network error. Please check your connection.'));
    } catch (e) {
      appTalker.error('Unexpected error during login', e);
      emit(const LoginFailure(message: 'An unexpected error occurred'));
    }
  }
}
```

## Request/Response Models

### DTO (Data Transfer Object)
```dart
// lib/core/network/models/user_dto.dart
class UserDto {
  final int id;
  final String email;
  final String name;

  UserDto({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
```

### Domain Model
```dart
// lib/core/models/user.dart
class User {
  final int id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  // Convert from DTO
  factory User.fromDto(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      name: dto.name,
    );
  }

  // Convert from JSON (for local storage)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };
}
```

## API Endpoints Naming

### RESTful Convention
```
GET    /users              # List all
GET    /users/:id          # Get one
POST   /users              # Create
PUT    /users/:id          # Update
DELETE /users/:id          # Delete
GET    /users/:id/posts    # Nested resource

POST   /users/:id/follow   # Custom action
POST   /posts/:id/like     # Another custom action
```

### Implementation
```dart
class UserRepository {
  // List
  Future<List<User>> getUsers({int limit = 20, int offset = 0}) {
    return _apiClient.get('/users?limit=$limit&offset=$offset');
  }

  // Get one
  Future<User> getUser(int id) {
    return _apiClient.get('/users/$id');
  }

  // Create
  Future<User> createUser(CreateUserRequest request) {
    return _apiClient.post('/users', data: request.toJson());
  }

  // Update
  Future<User> updateUser(int id, UpdateUserRequest request) {
    return _apiClient.put('/users/$id', data: request.toJson());
  }

  // Delete
  Future<void> deleteUser(int id) {
    return _apiClient.delete('/users/$id');
  }

  // Custom action
  Future<void> followUser(int userId) {
    return _apiClient.post('/users/$userId/follow');
  }
}
```

## Pagination

### Cursor-Based (Preferred)
```dart
class PaginationRequest {
  final String? cursor;
  final int limit;

  PaginationRequest({this.cursor, this.limit = 20});

  Map<String, dynamic> toQueryParams() {
    return {
      'cursor': cursor,
      'limit': limit,
    };
  }
}

Future<List<User>> getUsers(PaginationRequest request) async {
  final response = await _apiClient.get<Map<String, dynamic>>(
    '/users',
    queryParameters: request.toQueryParams(),
  );
  
  return (response['data'] as List)
    .map((u) => User.fromJson(u))
    .toList();
}
```

### Offset-Based
```dart
Future<List<User>> getUsers({required int page, int pageSize = 20}) {
  final offset = (page - 1) * pageSize;
  return _apiClient.get('/users?offset=$offset&limit=$pageSize');
}
```

## Timeouts & Retries

### Timeout Configuration
```dart
final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  sendTimeout: const Duration(seconds: 30),
));
```

### Retry Logic
```dart
Future<T> _withRetry<T>(
  Future<T> Function() request, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      
      // Exponential backoff
      await Future.delayed(Duration(seconds: 2 << i));
    }
  }
  throw Exception('Failed after $maxRetries retries');
}

// Usage
final user = await _withRetry(() => _apiClient.get('/users/1'));
```

## Testing API Calls

### Mock ApiClient
```dart
class MockApiClient implements ApiClient {
  Map<String, dynamic>? mockResponse;
  Exception? mockError;

  @override
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    if (mockError != null) throw mockError!;
    return mockResponse as T;
  }

  @override
  Future<T> post<T>(String path, {dynamic data}) async {
    if (mockError != null) throw mockError!;
    return mockResponse as T;
  }
}

// Test
test('login success', () async {
  final mockApi = MockApiClient();
  mockApi.mockResponse = {'token': 'abc123', 'user': {...}};

  final repo = UserRepository(mockApi);
  final result = await repo.login('test@example.com', 'password');

  expect(result.token, 'abc123');
});
```

## Rate Limiting

```dart
class RateLimitedApiClient {
  final ApiClient _apiClient;
  final Duration _windowDuration = const Duration(minutes: 1);
  final int _maxRequests = 100;
  
  final List<DateTime> _requestTimes = [];

  Future<T> get<T>(String path) async {
    _cleanOldRequests();
    
    if (_requestTimes.length >= _maxRequests) {
      throw RateLimitException('Rate limit exceeded');
    }
    
    _requestTimes.add(DateTime.now());
    return _apiClient.get<T>(path);
  }

  void _cleanOldRequests() {
    final now = DateTime.now();
    _requestTimes.removeWhere(
      (time) => now.difference(time) > _windowDuration,
    );
  }
}
```
