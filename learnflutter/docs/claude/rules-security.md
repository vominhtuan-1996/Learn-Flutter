# Security Rules — LearnFlutter

## Authentication & Authorization

### Token Storage
**Never** store tokens in plain text.

```dart
// ❌ WRONG: Plain text storage
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token); // Insecure!

// ✅ CORRECT: Use platform-specific secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'auth_token', value: token);

// Retrieve
final token = await secureStorage.read(key: 'auth_token');
```

### Token Refresh
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // Attempt token refresh
        final newToken = await _refreshToken();
        
        // Retry original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        
        final response = await dio.request(
          options.path,
          options: options,
        );
        handler.resolve(response);
      } catch (e) {
        // Refresh failed — logout user
        _triggerLogout();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<String> _refreshToken() async {
    final response = await _apiClient.post('/auth/refresh');
    return response['token'];
  }

  void _triggerLogout() {
    // Clear stored tokens
    secureStorage.delete(key: 'auth_token');
    // Redirect to login
    // eventBus.emit(LogoutEvent());
  }
}
```

### Session Management
```dart
class SessionService {
  static const _sessionTimeoutDuration = Duration(minutes: 30);
  Timer? _sessionTimer;

  void startSessionTimeout() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeoutDuration, _handleSessionTimeout);
  }

  void resetSessionTimeout() {
    startSessionTimeout(); // Reset on user activity
  }

  void _handleSessionTimeout() {
    // Auto-logout on timeout
    _triggerLogout();
  }

  void dispose() {
    _sessionTimer?.cancel();
  }
}
```

## Data Security

### Encrypted Local Storage
```dart
import 'package:hive_flutter/hive_flutter.dart';

// Hive with encryption
await Hive.initFlutter();

// Generate encryption key (once, store securely)
final key = Hive.generateSecureKey();
await secureStorage.write(key: 'hive_key', value: base64Encode(key));

// Open encrypted box
final encryptedBox = await Hive.openBox<User>(
  'users',
  encryptionCipher: HiveAesCipher(key),
);
```

### API Data Validation
```dart
// ❌ WRONG: Trust all API responses
final user = User.fromJson(apiResponse);

// ✅ CORRECT: Validate before using
class User {
  final String email;
  final int age;

  factory User.fromJson(Map<String, dynamic> json) {
    // Validate email format
    if (!_isValidEmail(json['email'])) {
      throw ValidationException('Invalid email format');
    }
    
    // Validate age is reasonable
    final age = json['age'] as int?;
    if (age == null || age < 0 || age > 150) {
      throw ValidationException('Invalid age');
    }

    return User(email: json['email'], age: age);
  }

  static bool _isValidEmail(dynamic email) {
    if (email is! String) return false;
    return RegExp(r'^[\w-\.]+@[\w-\.]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
```

## Input Validation

### Form Inputs
```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@[\w-\.]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: _validatePassword,
          ),
        ],
      ),
    );
  }
}
```

### URL Validation
```dart
bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.isAbsolute && 
           (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

// Use in WebView
if (_isValidUrl(url)) {
  // Load URL
} else {
  // Reject URL
}
```

## XSS Prevention (WebView)

### Safe WebView Usage
```dart
class SafeWebView extends StatelessWidget {
  final String initialUrl;

  const SafeWebView({required this.initialUrl});

  @override
  Widget build(BuildContext context) {
    // ❌ WRONG: Direct user input
    // WebViewWidget(controller: WebViewController()..loadRequest(Uri.parse(userInput)));

    // ✅ CORRECT: Validate & restrict to allowed domains
    if (!_isAllowedUrl(initialUrl)) {
      return Center(child: Text('Invalid URL: $initialUrl'));
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Evaluate if needed
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          if (!_isAllowedUrl(url)) {
            // Block navigation to untrusted domain
            controller.loadRequest(Uri.parse('about:blank'));
          }
        },
      ))
      ..loadRequest(Uri.parse(initialUrl));

    return WebViewWidget(controller: controller);
  }

  bool _isAllowedUrl(String url) {
    final uri = Uri.parse(url);
    // Whitelist allowed domains
    const allowedDomains = ['example.com', 'trusted-partner.com'];
    return allowedDomains.any((domain) => uri.host.endsWith(domain));
  }
}
```

## SQL Injection Prevention

### SQLite Queries
```dart
// ❌ WRONG: String concatenation
String query = "SELECT * FROM users WHERE id = $userId"; // SQL injection risk!

// ✅ CORRECT: Parameterized queries
Future<User?> getUser(int userId) async {
  final db = await _dbService.database;
  final maps = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [userId], // Parameterized
  );
  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  }
  return null;
}

// For complex queries
final maps = await db.rawQuery(
  'SELECT * FROM users WHERE email = ? AND age > ?',
  [userEmail, minAge], // Parameterized arguments
);
```

## Deep Link Security

### Validate Deep Links
```dart
class DeepLinkHandler {
  static Future<void> handleDeepLink(Uri uri) async {
    // Validate scheme
    if (uri.scheme != 'myapp') {
      throw InvalidDeepLinkException('Invalid scheme');
    }

    // Validate host
    const allowedHosts = ['auth', 'profile', 'purchase'];
    if (!allowedHosts.contains(uri.host)) {
      throw InvalidDeepLinkException('Unknown host: ${uri.host}');
    }

    // Validate and extract parameters
    final userId = uri.queryParameters['user_id'];
    if (userId == null || !RegExp(r'^\d+$').hasMatch(userId)) {
      throw InvalidDeepLinkException('Invalid user_id');
    }

    // Handle deep link
    // Navigator.pushNamed(context, uri.host, arguments: {userId: userId});
  }
}

// Usage in main.dart
Future<void> _handleDeepLink(Uri uri) async {
  try {
    await DeepLinkHandler.handleDeepLink(uri);
  } catch (e) {
    appTalker.error('Invalid deep link: $uri', e);
  }
}
```

## Platform Security

### iOS Configuration
- **Bitcode:** Enabled (for App Store optimization)
- **Data Protection:** Mark sensitive files as NSFileProtectionComplete
- **Keychain:** Use for sensitive data storage

### Android Configuration
- **Android Keystore:** Use for key storage
- **Certificate Pinning:** Pin API certificate to prevent MITM

```dart
// Certificate pinning with Dio
import 'package:dio/dio.dart';

final dio = Dio();
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Validate certificate
      try {
        // Implement certificate validation
      } catch (e) {
        return handler.reject(DioException(...));
      }
      handler.next(options);
    },
  ),
);
```

## Secrets Management

### Environment Variables
```dart
// ❌ WRONG: Hardcoded API keys
const String apiKey = 'sk_live_abc123...'; // Exposed in source code!

// ✅ CORRECT: Load from .env file
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

// Access
final apiKey = dotenv.env['API_KEY']!;
```

**`.env` file (gitignored):**
```
API_KEY=sk_live_abc123...
API_SECRET=secret_key_xyz...
FIREBASE_TOKEN=...
```

### Build-Time Secrets (Gradle/Xcode)
```gradle
// android/app/build.gradle
android {
  buildTypes {
    release {
      buildConfigField "String", "API_KEY", "\"${System.getenv('API_KEY')}\""
    }
  }
}
```

Access in code:
```dart
import 'package:learnflutter/BuildConfig'; // Generated
const apiKey = BuildConfig.API_KEY;
```

## Permissions

### Request Only Needed Permissions
```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isDenied ? false : status.isGranted;
  }

  // Check before using
  static Future<bool> isCameraAccessGranted() async {
    return await Permission.camera.isGranted;
  }
}

// Usage
if (await PermissionService.requestCameraPermission()) {
  // Use camera
} else {
  // Show permission denied dialog
}
```

## Error Messages

### Don't Expose Sensitive Information
```dart
// ❌ WRONG: Exposing stack trace or API details
emit(LoginFailure(message: 'Database error: ${e.toString()}'));

// ✅ CORRECT: Generic user-friendly error
emit(const LoginFailure(message: 'Login failed. Please try again.'));

// Log full details server-side
appTalker.error('Login error', e, StackTrace.current);
```

## Logging Security

### Don't Log Sensitive Data
```dart
// ❌ WRONG: Logging tokens
appTalker.info('Token: $token');

// ✅ CORRECT: Sanitize logs
appTalker.info('Token received (length: ${token.length})');

// For debugging only (remove before release)
appTalker.debug('Full token: $token');
```

## HTTPS Only

### Force HTTPS
```dart
// lib/core/config/network_config.dart
final baseUrl = 'https://api.example.com'; // Never HTTP in production

// Validate in interceptor
class HttpsEnforcer extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.uri.scheme != 'https') {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Only HTTPS connections allowed',
        ),
      );
    }
    handler.next(options);
  }
}
```

## Dependency Security

### Monitor Dependencies
```bash
# Check for vulnerable packages
fvm flutter pub outdated
fvm flutter pub get --warn-on-flutter-update

# Analyze pub.dev security scores
# When adding dependencies, check:
# - Maintenance status
# - Open issues/security advisories
# - Package score on pub.dev
```

## Code Obfuscation

### Obfuscate Release Builds
```bash
# iOS
fvm flutter build ipa --obfuscate --split-debug-info=build/ios/debug_symbols

# Android
fvm flutter build appbundle --obfuscate --split-debug-info=build/android/debug_symbols
```

## Testing Security

### Security Unit Tests
```dart
test('invalid email is rejected', () {
  expect(_isValidEmail('notanemail'), false);
  expect(_isValidEmail('test@'), false);
  expect(_isValidEmail('test@example.com'), true);
});

test('token refresh on 401', () async {
  mockDio.mockError = DioException(
    response: Response(statusCode: 401),
  );

  // Should trigger refresh
  expect(() => apiClient.get('/protected'), throwsA(isA<UnauthorizedException>()));
});

test('secure storage used for tokens', () async {
  await authService.login(email, password);
  
  // Verify stored in secure storage, not SharedPreferences
  final token = await secureStorage.read(key: 'auth_token');
  expect(token, isNotNull);
});
```
