# LearnFlutter Dependencies & Architecture Guide

## 🎯 Core Dependencies

### State Management
```yaml
flutter_bloc: ^8.1.0          # BLoC/Cubit pattern
equatable: ^2.0.0             # Value equality
```

### Database
```yaml
sqflite: ^2.2.0               # SQLite for user data
hive_flutter: ^1.1.0          # Local cache
sqflite_common_ffi: ^2.2.0    # FFI for desktop
```

### UI & Theme
```yaml
flutter_localization: latest  # Localization
google_fonts: latest          # Font management
hive: ^2.2.0                  # Data serialization
```

### Storage & Security
```yaml
shared_preferences: ^2.0.0    # Simple storage
flutter_secure_storage: ^9.0.0 # Secure token storage
```

### Networking
```yaml
http: ^1.0.0                  # HTTP client
```

### Notifications
```yaml
firebase_messaging: latest    # Push notifications
```

### Other Utils
```yaml
path: ^1.8.0                  # Path operations
intl: ^0.18.0                 # Internationalization
workmanager: ^0.5.0           # Background tasks
notification_center: latest   # Local notifications
```

---

## 📊 Project Statistics

- **Total Files Formatted**: 454
- **Changed**: 289
- **Architecture Level**: Clean Architecture with separation of concerns
- **State Management**: BLoC/Cubit Pattern
- **Database**: SQLite + Hive

---

## 🏗️ Architecture Overview

### Layer 1: Presentation (UI)
- Screens, Widgets, Dialogs
- BlocBuilder / BlocListener integration
- User interaction handling

### Layer 2: Business Logic (Cubit/BLoC)
- State management
- Input validation
- Business rules
- Data coordination

### Layer 3: Data Access (Repository/Database)
- CRUD operations
- Data transformation
- Error handling

### Layer 4: Core Services
- App configuration
- Global utilities
- Design system

---

## 📝 Module Structure Pattern

Each feature module follows this structure:

```
modules/[feature]/
├── cubit/
│   ├── [feature]_cubit.dart
│   └── [feature]_state.dart
├── screens/
│   └── [feature]_screen.dart
├── models/
│   └── [feature]_model.dart (if needed)
└── widgets/
    └── custom_widgets.dart (if needed)
```

---

## 🔄 Common Data Flows

### Login Flow
```
LoginScreen 
  → updateEmail() / updatePassword()
  → FormValidator validates
  → login() 
  → UserDatabase.getUserByEmail()
  → Verify password
  → updateLastLogin()
  → Emit success state
  → Navigate to home
```

### Form Validation Flow
```
TextFormField
  → onChanged: context.read<FormCubit>().updateEmail()
  → Cubit validates via FormValidator
  → Emit state with error
  → BlocBuilder updates UI with errorText
```

### Theme Customization Flow
```
SettingTextThemeScreen
  → Update font size via Slider
  → updateTextTokens() in bloc
  → TextToken updated
  → buildGoogleFont() applies new style
  → Preview updates in real-time
```

---

## ✅ Best Practices Applied

1. **Separation of Concerns**
   - UI separate from business logic
   - Database separate from UI

2. **Immutability**
   - States are immutable with copyWith()
   - Models use Equatable for comparison

3. **Error Handling**
   - Try-catch in all async operations
   - Error messages in state

4. **Validation**
   - FormValidator centralized
   - Real-time validation feedback

5. **Reusability**
   - Custom widgets in custom_widget/
   - Shared components in component/
   - Extensions for common operations

6. **Naming Conventions**
   - Classes: PascalCase
   - Methods/Variables: camelCase
   - Constants: camelCase
   - Private members: prefix with _

7. **Comments**
   - Vietnamese documentation
   - Focus on "why" not "what"
   - Clear and concise

---

## 🚀 Next Steps

1. **Add Repository Pattern Layer**
   ```dart
   // For better abstraction
   abstract class UserRepository {
     Future<UserModel?> getUserByEmail(String email);
     Future<void> insertUser(UserModel user);
   }
   
   class UserRepositoryImpl implements UserRepository {
     final UserDatabase _database;
     // Implementation
   }
   ```

2. **Implement Dependency Injection**
   ```dart
   // Use get_it for service locator
   final getIt = GetIt.instance;
   getIt.registerSingleton<UserRepository>(UserRepositoryImpl());
   ```

3. **Add Unit Tests**
   ```dart
   test('validateEmail returns error for invalid email', () {
     expect(
       FormValidator.validateEmail('invalid'),
       isNotNull,
     );
   });
   ```

4. **Add Integration Tests**
   ```dart
   testWidgets('Login screen shows error on wrong password', (tester) {
     // Test implementation
   });
   ```

5. **Implement Password Hashing**
   ```dart
   import 'package:bcrypt/bcrypt.dart';
   // Hash passwords before storing
   ```

6. **Add Analytics**
   ```dart
   // Track user events
   FirebaseAnalytics.instance.logEvent(
     name: 'user_login',
     parameters: {'email': user.email},
   );
   ```

---

## 📚 Reference Files

- **Architecture Overview**: [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Form Validation**: `lib/extendsion_ui/form/form.dart`
- **Database Setup**: `lib/db/sqlite/db_sqlite_helper.dart`
- **User Database**: `lib/db/sqlite/user_database.dart`
- **Login Example**: `lib/modules/auth/screens/login_screen.dart`
- **Form State Management**: `lib/extendsion_ui/form/form_cubit.dart`

---

**Project formatted and documented on**: December 31, 2025
**Total Formatting Changes**: 289 files
