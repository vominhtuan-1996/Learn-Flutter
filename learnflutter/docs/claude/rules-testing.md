# Testing Rules — LearnFlutter

## Testing Philosophy

- **Test behavior, not implementation** — Test the public API, not internal details
- **Prefer unit tests** — They're fast and catch bugs early
- **Integration tests** verify components work together
- **Widget tests** check UI rendering and interaction
- **Aim for coverage:** Core logic 80%+, UI components 60%+, features 50%+

## Test Organization

```
test/
├── core/
│   ├── network/
│   │   ├── api_client_test.dart
│   │   └── network_queue_service_test.dart
│   ├── keyboard_service_test.dart
│   └── queue_engine_test.dart
├── features/
│   ├── auth/
│   │   ├── cubit/
│   │   │   └── login_cubit_test.dart
│   │   └── repos/
│   │       └── user_repository_test.dart
│   └── home/
│       └── cubit/
│           └── home_cubit_test.dart
├── helpers/
│   ├── mock_api_client.dart
│   ├── mock_repository.dart
│   └── test_helpers.dart
└── widget_test.dart
```

**Run tests:**
```bash
fvm flutter test                          # All tests
fvm flutter test test/core/               # Specific directory
fvm flutter test -d chrome                # On web
fvm flutter test --coverage               # With coverage report
```

## Unit Testing

### Cubit Testing
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('LoginCubit', () {
    late MockUserRepository mockUserRepository;
    late LoginCubit loginCubit;

    setUp(() {
      mockUserRepository = MockUserRepository();
      loginCubit = LoginCubit(mockUserRepository);
    });

    tearDown(() async {
      await loginCubit.close();
    });

    test('initial state is LoginInitial', () {
      expect(loginCubit.state, const LoginInitial());
    });

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] when login succeeds',
      build: () {
        when(mockUserRepository.login(any, any))
            .thenAnswer((_) async => mockUser);
        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password'),
      expect: () => [
        const LoginLoading(),
        LoginSuccess(user: mockUser),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when login fails',
      build: () {
        when(mockUserRepository.login(any, any))
            .thenThrow(UnauthorizedException('Invalid credentials'));
        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'wrong'),
      expect: () => [
        const LoginLoading(),
        const LoginFailure(message: 'Invalid email or password'),
      ],
    );
  });
}
```

### Repository Testing
```dart
void main() {
  group('UserRepository', () {
    late MockApiClient mockApiClient;
    late UserRepository userRepository;

    setUp(() {
      mockApiClient = MockApiClient();
      userRepository = UserRepository(mockApiClient);
    });

    test('login returns User on success', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockResponse = {
        'token': 'abc123',
        'user': {'id': 1, 'email': email, 'name': 'Test User'},
      };
      
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await userRepository.login(email, password);

      // Assert
      expect(result.token, 'abc123');
      expect(result.user.email, email);
      verify(mockApiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      })).called(1);
    });

    test('login throws UnauthorizedException on 401', () async {
      when(mockApiClient.post(any, data: anyNamed('data')))
          .thenThrow(UnauthorizedException('Unauthorized'));

      expect(
        () => userRepository.login('test@example.com', 'wrong'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
```

### Helper Function Testing
```dart
void main() {
  group('ValidationHelpers', () {
    test('isValidEmail returns true for valid emails', () {
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name+tag@example.co.uk'), true);
    });

    test('isValidEmail returns false for invalid emails', () {
      expect(isValidEmail('notanemail'), false);
      expect(isValidEmail('test@'), false);
      expect(isValidEmail('@example.com'), false);
    });

    test('isStrongPassword checks all requirements', () {
      // Too short
      expect(isStrongPassword('Test1'), false);
      
      // No uppercase
      expect(isStrongPassword('test12345'), false);
      
      // No digit
      expect(isStrongPassword('TestPassword'), false);
      
      // Valid
      expect(isStrongPassword('TestPassword123'), true);
    });
  });
}
```

## Mocking

### Mock Setup with Mockito
```dart
// test/helpers/mocks.dart

import 'package:mockito/mockito.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockUserRepository extends Mock implements UserRepository {}

class MockKeyboardService extends Mock implements KeyboardService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}
```

### Named Arguments in Mocks
```dart
// Mocking with named arguments
when(mockApiClient.post(
  any,
  data: anyNamed('data'),
  headers: anyNamed('headers'),
)).thenAnswer((_) async => {'status': 'success'});

// Verify named arguments
verify(mockApiClient.post(
  '/users',
  data: {'name': 'John'},
)).called(1);
```

### Capturing Arguments
```dart
test('captured arguments are verified', () async {
  final captured = <dynamic>[];
  when(mockRepository.login(captureAny, captureAny))
      .thenAnswer((_) async => mockUser);

  await cubit.login('test@example.com', 'password');

  expect(captured, ['test@example.com', 'password']);
});
```

## Widget Testing

### Basic Widget Test
```dart
void main() {
  group('LoginScreen', () {
    testWidgets('renders login form', (WidgetTester tester) async {
      // Arrange
      final mockLoginCubit = MockLoginCubit();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>(
            create: (_) => mockLoginCubit,
            child: const LoginScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('submits form when button pressed', (WidgetTester tester) async {
      final mockLoginCubit = MockLoginCubit();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>(
            create: (_) => mockLoginCubit,
            child: const LoginScreen(),
          ),
        ),
      );

      // Enter email
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );

      // Enter password
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify
      verify(() => mockLoginCubit.login(
        'test@example.com',
        'password123',
      )).called(1);
    });

    testWidgets('shows loading state during login', (WidgetTester tester) async {
      final mockLoginCubit = MockLoginCubit();
      
      whenListen(
        mockLoginCubit,
        Stream.fromIterable([
          const LoginInitial(),
          const LoginLoading(),
        ]),
        initialState: const LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>(
            create: (_) => mockLoginCubit,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when login fails', (WidgetTester tester) async {
      final mockLoginCubit = MockLoginCubit();
      
      whenListen(
        mockLoginCubit,
        Stream.fromIterable([
          const LoginInitial(),
          const LoginFailure(message: 'Invalid credentials'),
        ]),
        initialState: const LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>(
            create: (_) => mockLoginCubit,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
```

### Golden File Testing
```dart
void main() {
  testWidgets('LoginScreen matches golden file', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginCubit>(
          create: (_) => MockLoginCubit(),
          child: const LoginScreen(),
        ),
      ),
    );

    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('login_screen.png'),
    );
  });
}
```

**Update golden files:**
```bash
fvm flutter test --update-goldens
```

## Integration Testing

### Full Feature Flow
```dart
// test/integration/login_flow_test.dart

void main() {
  group('Login Integration Test', () {
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
    });

    testWidgets('complete login flow', (WidgetTester tester) async {
      // Mock successful API response
      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => {
            'token': 'abc123',
            'user': {'id': 1, 'email': 'test@example.com', 'name': 'Test'},
          });

      // Build app with mocked API
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginCubit>(
            create: (_) => LoginCubit(UserRepository(mockApiClient)),
            child: const LoginScreen(),
          ),
        ),
      );

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Submit
      await tester.tap(find.byType(ElevatedButton));

      // Wait for loading
      await tester.pumpAndSettle();

      // Verify success state (should navigate to home)
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

## Common Patterns

### Testing Async Functions
```dart
test('async function completes successfully', () async {
  final result = await repository.fetchData();
  expect(result, isNotNull);
  expect(result.id, 1);
});

test('async function throws exception', () async {
  when(mockApiClient.get(any))
      .thenThrow(NetworkException('Connection failed'));

  expect(
    () => repository.fetchData(),
    throwsA(isA<NetworkException>()),
  );
});
```

### Testing Streams
```dart
test('stream emits correct values', () {
  final controller = StreamController<int>();
  
  expect(
    controller.stream,
    emits(1),
  );

  controller.add(1);
});

test('stream emits multiple values', () {
  final controller = StreamController<String>();
  
  expect(
    controller.stream,
    emitsInOrder(['hello', 'world']),
  );

  controller.add('hello');
  controller.add('world');
});
```

### Testing Time-Dependent Code
```dart
test('debounce delays execution', () async {
  addTearDown(tester.binding.window.physicalSizeTestValue = const Size(800, 600));

  int callCount = 0;
  final debounced = debounce<String>((_) {
    callCount++;
  }, duration: const Duration(milliseconds: 100));

  debounced('test');
  debounced('test');
  debounced('test');

  expect(callCount, 0); // Not called yet

  await Future.delayed(const Duration(milliseconds: 150));

  expect(callCount, 1); // Called once after debounce
});
```

## Code Coverage

### Generate Coverage Report
```bash
# Generate coverage
fvm flutter test --coverage

# Convert to readable format (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# View
open coverage/html/index.html
```

### Exclude from Coverage
```dart
// coverage:ignore-file
import 'package:some_package/some_package.dart';

// Or specific lines
// coverage:ignore-line
void unusedFunction() {}
```

## Best Practices

### ✅ DO
- **Test public APIs** — Test what users of the code will call
- **Name tests clearly** — `test('should emit [Loading, Success] when login succeeds', ...)`
- **Use AAA pattern** — Arrange, Act, Assert
- **Keep tests focused** — One concept per test
- **Mock external dependencies** — ApiClient, Database, SharedPreferences
- **Test edge cases** — Empty lists, null values, errors
- **Isolate tests** — Each test should be independent

### ❌ DON'T
- **Test private methods** — Refactor if needed to test
- **Depend on test order** — Tests should run in any order
- **Sleep in tests** — Use `pumpAndSettle()` in widget tests
- **Mock everything** — Only mock external dependencies
- **Test implementation details** — Test behavior instead
- **Ignore test failures** — Fix failing tests immediately
- **Write fragile tests** — Brittle tests slow down development

## Test Configuration

### Test Helpers
```dart
// test/helpers/test_helpers.dart

class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
}

Future<void> pumpApp(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(TestApp(child: widget));
}
```

### Setup/Teardown
```dart
void main() {
  setUp(() {
    // Initialize test fixtures
    mockApiClient = MockApiClient();
  });

  tearDown(() {
    // Clean up
    mockApiClient.close();
  });

  group('Feature', () {
    // Tests here
  });
}
```
