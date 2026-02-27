# LearnFlutter - Clean Architecture Project

## 📁 Project Architecture

Dự án này được tổ chức theo **Clean Architecture** với separation of concerns rõ ràng:

```
lib/
├── app/                          # App configuration & setup
│   ├── app_root.dart            # Main app setup
│   └── app_local_translate.dart  # Localization config
│
├── core/                          # Core utilities & shared logic
│   ├── app/                      # App-level configs
│   │   ├── app_theme.dart
│   │   ├── app_text_style.dart
│   │   ├── app_box_decoration.dart
│   │   └── device_dimension.dart
│   ├── keyboard/                 # Keyboard handling
│   ├── service/                  # Core services (Firebase, notifications)
│   ├── https/                    # HTTP client setup
│   ├── regex/                    # Regex patterns
│   └── theme_token/              # Design tokens
│
├── db/                            # Database layer
│   ├── sqlite/
│   │   ├── db_sqlite_helper.dart         # Database initialization
│   │   └── user_database.dart            # User CRUD operations
│   ├── hive_demo/                # Local cache with Hive
│   └── models/
│       └── user_model.dart               # Data models
│
├── extendsion_ui/                 # UI extensions & forms
│   └── form/
│       ├── form.dart             # Form validators
│       ├── form_cubit.dart        # Form state management
│       └── form_state.dart        # Form state
│
├── modules/                       # Feature modules
│   ├── auth/                     # Authentication module
│   │   ├── cubit/
│   │   │   ├── login_cubit.dart
│   │   │   └── login_state.dart
│   │   └── screens/
│   │       └── login_screen.dart
│   ├── theme/                    # Theme customization
│   ├── setting/                  # Settings module
│   ├── home/                     # Home module
│   ├── material/                 # Material components showcase
│   └── [other modules]/
│
├── component/                     # Reusable components
│   ├── base_loading_screen/
│   ├── search_bar/
│   ├── pagination/
│   ├── bottom_sheet/
│   ├── routes/                   # App routing
│   └── [other components]/
│
├── custom_widget/                 # Custom widgets
│   ├── custom_textfield.dart
│   ├── custom_snackbar.dart
│   └── [other custom widgets]/
│
├── utils_helper/                  # Helper utilities
│   ├── extension/                 # Dart extensions
│   │   ├── extension_widget.dart
│   │   ├── extension_context.dart
│   │   └── extension_list.dart
│   ├── dialog_utils.dart
│   ├── bitmap_utils.dart
│   └── [other helpers]/
│
├── constraint/                    # App constraints & constants
│   └── define_constraint.dart
│
├── l10n/                          # Localization
│
└── main.dart                      # Entry point
```

## 🏗️ Architecture Layers

### 1. **Data Layer** (`/db`)
- SQLite database operations
- Hive local cache
- API calls (via HTTP client)
- Models for data entities

**Files:**
- `db_sqlite_helper.dart` - Database initialization (Singleton pattern)
- `user_database.dart` - CRUD operations for users
- `user_model.dart` - Data model with serialization

### 2. **Business Logic Layer** (`/modules/**/cubit`)
- Cubits/BLoCs for state management
- Business logic separation
- Input validation
- Database operations coordination

**Files:**
- `login_cubit.dart` - Login logic
- `form_cubit.dart` - Form state management
- `*_state.dart` - State definitions

### 3. **Presentation Layer** (`/modules/**/screens`, `/component`, `/custom_widget`)
- UI widgets & screens
- User interaction handling
- State listening via BlocBuilder/BlocListener
- Dialog & bottom sheet management

**Files:**
- `login_screen.dart` - Login UI
- Custom widgets for reusability
- Components for shared functionality

### 4. **Core Layer** (`/core`)
- Global configurations
- Shared utilities
- Service initialization
- Design tokens & themes

**Files:**
- `app_theme.dart` - Theme configuration
- `db_sqlite_helper.dart` - Database service
- Keyboard, HTTP, Firebase services

## 🎯 Key Design Patterns

### 1. **Singleton Pattern**
```dart
class DbSqliteHelper {
  static final DbSqliteHelper _instance = DbSqliteHelper._internal();
  factory DbSqliteHelper() => _instance;
  DbSqliteHelper._internal();
}
```

### 2. **Repository Pattern** (via Database classes)
- `UserDatabase` acts as repository for user data
- Abstracts database operations from business logic

### 3. **BLoC Pattern** (Cubits)
- `LoginCubit` manages login flow
- `FormCubit` handles form validation
- Separates UI from business logic

### 4. **Extension Methods**
```dart
// Easy to read and maintain
context.read<LoginCubit>().login();
widget.paddingSymmetric(horizontal: 16);
```

## 📋 Feature Structure Example: Auth Module

```
modules/auth/
├── cubit/
│   ├── login_cubit.dart       # Main login logic
│   └── login_state.dart        # Login state definition
└── screens/
    └── login_screen.dart       # Login UI
```

### Login Flow:
1. **UI Layer** (`login_screen.dart`)
   - TextFormFields for email/password
   - Buttons trigger Cubit methods
   - BlocBuilder/BlocListener handle state changes

2. **Business Logic** (`login_cubit.dart`)
   - Validates form via `FormValidator`
   - Queries user from database
   - Updates last login time
   - Manages loading/error states

3. **Data Layer** (`user_database.dart`)
   - CRUD operations
   - Database transactions
   - Error handling

## 🔄 Data Flow

```
User Input (UI)
    ↓
BlocBuilder/BlocListener
    ↓
Cubit methods (login, updateEmail, etc.)
    ↓
FormValidator / Business Logic
    ↓
UserDatabase (CRUD)
    ↓
SQLite Database
    ↓
Emit new State
    ↓
UI Update
```

## 📦 Form Validation System

### Files:
- `extendsion_ui/form/form.dart` - FormValidator class with validators
- `extendsion_ui/form/form_cubit.dart` - Form state management
- `extendsion_ui/form/form_state.dart` - Form state definition

### Validators Available:
- `validateEmail()` - Email format
- `validatePassword()` - Strong password (8+, uppercase, lowercase, digit, special)
- `validatePhone()` - Phone number (10-11 digits)
- `validateName()` - Name validation
- `validateUrl()` - URL format
- `validateUsername()` - Username (3-20 alphanumeric + underscore)
- `validateAge()` - Age >= 18
- `validateCreditCard()` - Credit card validation
- `validateMinLength()` / `validateMaxLength()` - Length validation
- `validateNumber()` / `validateInteger()` - Number validation
- `validateRegex()` - Custom regex

### Password Strength Checker:
```dart
final strength = FormValidator.checkPasswordStrength(password);
// Returns: empty, weak, medium, strong
// With color and label properties
```

## 🗄️ User Database

### Model: UserModel
```dart
UserModel(
  id, email, password, fullName, phone, avatar, token,
  isActive, createdAt, updatedAt, lastLogin
)
```

### Database Operations:
- `insertUser()` - Create user
- `getUserByEmail()` / `getUserById()` - Read
- `updateUser()` / `updateLastLogin()` / `updateToken()` - Update
- `deleteUser()` / `deactivateUser()` / `activateUser()` - Delete
- `userExists()` - Check existence
- `getAllUsers()` / `getActiveUsers()` - List
- `searchUsers()` - Search functionality
- `getUserCount()` - Statistics

## 🎨 Theming System

### Core Theme Files:
- `core/app/app_theme.dart` - Theme configuration
- `core/app/app_text_style.dart` - Text styles
- `core/app/app_box_decoration.dart` - Box decorations
- `core/theme_token/` - Design tokens

### Text Theme Management:
- `modules/theme/setting_texttheme_screen.dart` - Theme customizer
- Font family, size, weight, color picker
- Real-time preview

## 🚀 Getting Started

### 1. Initialize Database
```dart
final dbHelper = DbSqliteHelper();
await dbHelper.database; // Initializes database
```

### 2. Register Cubits in BlocProvider
```dart
BlocProvider<LoginCubit>(
  create: (_) => LoginCubit(),
  child: const LoginScreen(),
)
```

### 3. Use in UI
```dart
// Read
context.read<LoginCubit>().login();

// Watch
BlocBuilder<LoginCubit, LoginState>(
  builder: (context, state) {
    return TextField(
      errorText: state.emailError,
    );
  },
)

// Listen
BlocListener<LoginCubit, LoginState>(
  listener: (context, state) {
    if (state.isLoginSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  },
)
```

## 📝 Code Style

### Formatting
All code is formatted using Dart formatter:
```bash
dart format .
```

### Naming Conventions
- **Classes**: PascalCase (e.g., `LoginCubit`, `UserModel`)
- **Variables**: camelCase (e.g., `emailError`, `isLoading`)
- **Constants**: camelCase (e.g., `maxRetries`, `defaultTimeout`)
- **Private members**: prefix with `_` (e.g., `_database`, `_userDatabase`)

### Comments
- Clear, concise Vietnamese comments
- Explain "why", not "what"
- Each comment represents one logical explanation

## ⚠️ Important Notes

1. **Password Hashing**: Currently stores passwords as plain text. In production:
   ```dart
   // Use bcrypt or argon2
   import 'package:bcrypt/bcrypt.dart';
   String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
   bool isMatch = BCrypt.checkpw(password, hashedPassword);
   ```

2. **Token Management**: Implement secure token storage:
   ```dart
   // Use flutter_secure_storage for tokens
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   ```

3. **Error Handling**: All database operations wrap with try-catch
   ```dart
   try {
     await _userDatabase.insertUser(user);
   } catch (e) {
     emit(state.copyWith(errorMessage: 'Error: $e'));
   }
   ```

## 📚 Dependencies Used

- **State Management**: flutter_bloc, equatable
- **Database**: sqflite, hive_flutter
- **UI**: flutter_localization, google_fonts
- **Network**: http (in core/https)
- **Storage**: shared_preferences, flutter_secure_storage
- **Notifications**: firebase_messaging
- **Forms**: custom validators

## 🔗 Related Screens

- `/modules/auth/screens/login_screen.dart` - Login implementation
- `/modules/theme/setting_texttheme_screen.dart` - Theme customizer
- `/modules/form_validation/main_form_valid.dart` - Form examples
- `/modules/setting/setting_screen.dart` - Settings UI

---

**Last Updated**: Dec 31, 2025
**Version**: 1.0.0 (Clean Architecture)
