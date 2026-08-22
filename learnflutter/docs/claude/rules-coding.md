# Coding Rules — LearnFlutter

## Dart & Flutter Code Style

### File Organization
- **One logical component per file** — screens, Cubits, widgets, models each in their own file
- **Imports organized:**
  1. `dart:` imports (core language)
  2. `package:flutter/` imports
  3. Package imports (third-party)
  4. Relative imports (local project)
- **No `part` or `part of`** — use direct imports instead

### Naming Conventions
- **Classes:** PascalCase (`HomeScreen`, `LoginCubit`, `UserRepository`)
- **Files:** snake_case (`home_screen.dart`, `login_cubit.dart`)
- **Variables/Functions:** camelCase (`userName`, `calculateTotal()`)
- **Constants:** camelCase or UPPER_SNAKE_CASE for globals
- **Private members:** Leading underscore (`_privateField`, `_privateMethod()`)
- **BLoC/Cubit classes:** `*Cubit`, `*Bloc` suffix (not `*ViewModel`, `*Controller`)
- **State classes:** `*State` suffix (e.g., `LoginState`, `AuthState`)

### Formatting
```bash
# Always run before committing
fvm dart format lib/
```
- Line length: 80–120 characters (auto-formatted)
- Trailing commas in multi-line collections
- 2-space indentation (enforced by formatter)

### Comments
- **No docstring clutter:** Only document WHY, not WHAT
- **No block comments (`/* */`)** — use `//` for multi-line
- **Avoid obvious comments:** Good variable names are better than `// increment counter`
- **Reference issues/PRs sparingly:** Link in commit messages, not code comments

**Good:**
```dart
// Debounce rapid scroll events to avoid excessive API calls
void _onScroll() { ... }
```

**Avoid:**
```dart
// This method handles scrolling
// It takes no parameters
// It calls _onScroll
void _onScroll() { ... }
```

### Null Safety
- **Always use non-nullable by default:** `String name` not `String? name`
- **Only `?` when truly optional:** Use `String?` for API fields that may be null
- **Avoid `!` operator:** If you need it, reconsider the design
- **Late initialization:** `late String value` only for guaranteed-before-use fields

### Code Organization within a File
1. Imports (in order above)
2. Constants / enums
3. Class definition
4. Constructor + initialization
5. Public methods
6. Private methods
7. Helper getters/setters (bottom)

**Example:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const String _defaultName = 'Guest';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(_defaultName);

  String _formatText(String input) => input.toUpperCase();
}
```

## Error Handling

### Avoid Silent Failures
- **Always handle exceptions** at the boundary (API calls, platform channels)
- **Use try-catch for specific exceptions**, not `Exception` base class
- **Log errors with context:** Use `AppTalker` for structured logging

**Good:**
```dart
try {
  final user = await userRepository.login(email, password);
  // handle success
} on NetworkException catch (e) {
  appTalker.error('Login failed: network error', e);
  emit(LoginFailure(message: 'Network error. Please try again.'));
} catch (e) {
  appTalker.error('Unexpected error during login', e);
  emit(LoginFailure(message: 'An unexpected error occurred.'));
}
```

**Avoid:**
```dart
try {
  final user = await userRepository.login(email, password);
} catch (e) {
  // Silent failure
}
```

### Network Errors
- **Wrap Dio exceptions** in domain-specific exceptions (e.g., `LoginException`)
- **Surface HTTP status codes** to the UI layer only when actionable (401 → re-login, 500 → retry)
- **Never expose raw exception types** to the UI

## Async Patterns

### Futures & Async-Await
- **Prefer `async/await` over `.then()`** — more readable
- **Don't await unnecessarily:** If you need multiple concurrent requests, use `Future.wait()`

**Good:**
```dart
final users = await Future.wait([
  repo.fetchUsers(),
  repo.fetchFollowers(),
]);
```

**Avoid:**
```dart
await repo.fetchUsers();
await repo.fetchFollowers(); // Sequential, slower
```

### Streams & RxDart
- **Use `.asBroadcastStream()`** if multiple listeners needed
- **Dispose subscriptions** in `close()` method of Cubits
- **Prefer Cubit streams** over raw `StreamController` for state management

## Testing

- **All public APIs should be testable** — avoid tight coupling to BuildContext
- **Mock external dependencies:** APIs, storage, native plugins
- **Use `fakeRestClient` for network testing:** See `core/network/rest_api/`
- **Write unit tests for:** Cubits, repositories, utilities
- **Write widget tests for:** Complex UI interactions, animations

## Dependencies

### Adding New Packages
- **Check for existing solutions first:** grep `lib/pubspec.yaml` for similar packages
- **Prefer mature, maintained packages** (high pub score, regular updates)
- **Avoid adding unnecessary dependencies:** Use stdlib when possible
- **Update `pubspec.yaml` conservatively:** Use `^` for compatible versions

### Removing Unused Imports
- **Run `flutter analyze` regularly**
- **Remove unused variables/imports before committing**

## Performance

### Build Optimization
- **Use `const` constructors** whenever possible
- **Lazy-load features** — don't initialize all modules at startup
- **Avoid rebuilds:** Use `GetIt` for singletons instead of `Provider` wrapping entire tree
- **Profile with DevTools:** `fvm flutter run --profile`

### Asset Management
- **Compress images before committing:** Use `ImageUtils.compressImage()`
- **Use WebP format** for photos (smaller than PNG/JPG)
- **Don't check in debug APKs or .ipa files**

## Git & Commits

### Commit Messages
Format: `type(scope): description`

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`

**Examples:**
```
feat(auth): add LoginCubit with UserRepository integration
fix(keyboard): prevent rebuild on keyboard visibility change
refactor(home): extract HomeAnimationPage logic into separate widget
test(network): add unit tests for ApiClient
docs(setup): update build instructions
```

### What to Commit
- ✅ Source code changes
- ✅ Test files
- ✅ Documentation updates
- ❌ Build artifacts (`.apk`, `.ipa`, `.xcarchive`)
- ❌ IDE local settings (`.vscode/settings.local.json`)
- ❌ `.env` files with secrets (keep in `.gitignore`)
- ❌ `build/`, `.dart_tool/`, `pubspec.lock` (usually)

## Secrets & Configuration

### Never Commit Secrets
- **API keys, tokens, passwords:** Use `.env` file (gitignored)
- **Load at runtime:** Use `flutter_dotenv` or similar
- **Fallback to hardcoded defaults only for demo/test keys**

### Environment-Specific Code
- **Avoid conditional compilation** — use runtime config instead
- **Config files:** `lib/core/config/` for env-specific settings
- **Example:** Switch API domain via environment variable

## Code Reviews

- **Self-review before pushing:** Run formatter, analyzer, tests
- **Keep PRs focused:** One feature or fix per PR
- **Write clear PR descriptions:** Reference issues, explain why not just what
