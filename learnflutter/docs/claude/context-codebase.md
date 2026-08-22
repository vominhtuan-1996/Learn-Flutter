# Codebase Context — LearnFlutter

## Technology Stack Summary

| Category | Technology | Version | Location |
|----------|-----------|---------|----------|
| **Language** | Dart | ≥3.0.0 | — |
| **Framework** | Flutter | 3.29.3 | `.fvmrc` |
| **State** | flutter_bloc | 8.0.1 | core/cubit, features/*/cubit |
| **State** | hooks_riverpod | 2.5.1 | app/localization |
| **Network** | Dio | 5.1.1 | core/network |
| **Storage** | Hive | 2.2.3 | core/storage/hive_demo |
| **Storage** | SQLite | 2.2.8 | core/storage/sqlite |
| **Storage** | SharedPreferences | 2.1.0 | core/services |
| **UI** | flutter_animate | 4.5.2 | features/home, custom_paint, etc. |
| **Maps** | google_maps_flutter | 2.12.3 | features/map |
| **Maps** | flutter_map | 8.1.1 | features/map (alternative) |
| **Camera** | camera | 0.11.0 | features/camera_wesome |
| **QR** | qr_code_scanner, mobile_scanner | 1.0.1, 6.0.0 | features/qr_scan |
| **Charts** | syncfusion_flutter_charts | 29.1.38 | features/chart |
| **Game** | flame | 1.15.0 | features/games |
| **Chat** | flutter_chat_ui | 1.6.15 | features/chat |
| **Notify** | flutter_local_notifications | 17.2.2 | features/notification |
| **Background** | workmanager | 0.6.0 | core/services |
| **3D** | flutter_3d_controller | 2.2.0 | features/flutter_3d, photo_3d |
| **OTA** | shorebird_code_push | 2.0.4 | core/services/shorebird |
| **i18n** | flutter_localization | 0.3.2 | lib/l10n |

## Directory Map

```
lib/
├── main.dart                          [DEFAULT ENTRY POINT]
├── main_*.dart                        [68+ FEATURE ENTRY POINTS]
│
├── app/
│   ├── app.dart                       [ROOT APP WIDGET - Splash + Routing]
│   ├── intro_splash.dart              [INTRO SPLASH SCREEN LOGIC]
│   ├── localization/
│   │   └── app_local_translate.dart   [RIVERPOD LOCALE PROVIDER]
│   └── theme/
│       ├── extension_theme.dart       [THEME EXTENSIONS]
│       └── habit_builder_theme.dart   [APP THEME CONFIG]
│
├── core/                              [SHARED LAYER - 100% reuse]
│   ├── animation/                     [GLOBAL ANIMATIONS]
│   ├── config/                        [ENV, APP CONFIG]
│   ├── constants/                     [DEFINE_CONSTRAINT, KEYS]
│   ├── cubit/                         [GLOBAL CUBITS IF ANY]
│   ├── debound.dart                   [DEBOUNCE UTILITY]
│   ├── engines/                       [PLATFORM ENGINES]
│   │   ├── engine_google_map/         [GOOGLE MAPS ENGINE]
│   │   └── engine_bottom_sheet/       [BOTTOM SHEET ENGINE]
│   ├── extensions/                    [DART/FLUTTER EXTENSIONS]
│   │   ├── form/
│   │   ├── shape/
│   │   └── extension_context.dart
│   ├── global/                        [GLOBAL SINGLETONS]
│   ├── network/
│   │   ├── api_client/
│   │   │   ├── api_client.dart        [DIO SINGLETON WRAPPER]
│   │   │   └── network_queue_service.dart
│   │   └── repositories/
│   │       └── user_repository.dart   [USER API ABSTRACTION]
│   ├── repositories/
│   ├── services/
│   │   ├── keyboard/                  [KEYBOARD TRACKING]
│   │   ├── talker/                    [LOGGING - app_talker.dart]
│   │   ├── log/                       [FILE LOGGING, GOOGLE CHAT]
│   │   ├── shorebird/                 [OTA SERVICE]
│   │   └── ...
│   ├── state/                         [GLOBAL STATE DEFS]
│   ├── storage/
│   │   ├── hive_demo/                 [HIVE ORM EXAMPLES]
│   │   │   └── model/
│   │   │       └── person.dart
│   │   └── sqlite/                    [SQLITE EXAMPLES]
│   └── utils/
│       ├── device_dimension.dart      [SCREEN SIZE UTILS]
│       ├── utils_helper.dart          [COMMON HELPERS]
│       ├── extension/                 [EXTENSIONS]
│       └── ...
│
├── features/                          [68 FEATURES]
│   ├── ar_kit/                        [AR KIT EXPLORATION]
│   ├── auth/                          [AUTHENTICATION]
│   │   ├── cubit/
│   │   │   ├── login_cubit.dart
│   │   │   └── login_state.dart
│   │   ├── screens/
│   │   │   └── login_screen.dart
│   │   └── repos/
│   │       └── user_repository.dart
│   ├── home/                          [MAIN HOME FEED]
│   │   ├── cubit/
│   │   │   ├── home_cubit.dart
│   │   │   └── home_state.dart
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   ├── camera_wesome/                 [CAMERA INTEGRATION]
│   ├── chart/                         [SYNCFUSION CHARTS]
│   ├── chat/                          [FLUTTER CHAT UI]
│   ├── custom_paint/                  [CANVAS DRAWING]
│   ├── map/                           [GOOGLE MAPS + LEAFLET]
│   ├── notification/                  [LOCAL NOTIFICATIONS]
│   ├── qr_scan/                       [QR SCANNING]
│   ├── setting/                       [THEME/SETTINGS]
│   │   ├── cubit/
│   │   │   └── setting_cubit.dart
│   │   ├── state/
│   │   │   └── setting_state.dart
│   │   ├── screens/
│   │   └── widgets/
│   ├── web_view/                      [WEBVIEW EMBEDDING]
│   ├── [60+ OTHER FEATURES...]
│   │
│   └── [FEATURE STRUCTURE - Each feature has:]
│       ├── cubit/
│       │   ├── *_cubit.dart
│       │   └── *_state.dart
│       ├── screens/
│       │   ├── *_screen.dart
│       │   └── widgets/
│       ├── repos/
│       ├── models/
│       └── README.md (sometimes)
│
├── shared/                            [SHARED ACROSS FEATURES]
│   ├── widgets/
│   │   ├── base_loading_screen/       [LOADING OVERLAY - BaseLoadingCubit]
│   │   ├── search_bar/                [SEARCH WIDGET - SearchBarCubit]
│   │   ├── routes/                    [ROUTING CONFIG]
│   │   └── [OTHER SHARED WIDGETS]
│   └── ...
│
└── l10n/                              [LOCALIZATION]
    ├── app_localizations.dart         [BASE CLASS]
    ├── app_localizations_vi.dart      [VIETNAMESE]
    ├── app_localizations_en.dart      [ENGLISH]
    └── helper.dart                    [LOCALE SWITCHING HELPER]
```

## Key Entry Points

| File | Purpose | Usage |
|------|---------|-------|
| `lib/main.dart` | Default entry point | `fvm flutter run` |
| `lib/main_home.dart` | Home feature demo | `fvm flutter run -t lib/main_home.dart` |
| `lib/main_qr_code.dart` | QR scanning demo | `fvm flutter run -t lib/main_qr_code.dart` |
| `lib/main_balance.dart` | Balance bar animation | `fvm flutter run -t lib/main_balance.dart` |
| `lib/main_permission.dart` | Permission handling | `fvm flutter run -t lib/main_permission.dart` |
| `lib/main_story.dart` | Storyboard/animations | `fvm flutter run -t lib/main_story.dart` |

## State Management Summary

### Global Cubits
- **SettingCubit** → Theme, language switching (`features/setting/`)
- **BaseLoadingCubit** → App-wide loading overlay (`shared/widgets/base_loading_screen/`)
- **SearchBarCubit** → Global search state (`shared/widgets/search_bar/`)

### Feature Cubits
- **LoginCubit** → Authentication flow (`features/auth/`)
- **HomeCubit** → Home feed state (`features/home/`)
- Individual feature cubits for other features

### Riverpod Providers
- **Locale provider** → Language switching (`app/localization/app_local_translate.dart`)

## Services & Singletons

| Service | Location | Purpose |
|---------|----------|---------|
| **ApiClient** | `core/network/api_client/` | Dio wrapper, HTTP requests |
| **KeyboardService** | `core/services/keyboard/` | Keyboard height tracking |
| **AppTalker** | `core/services/talker/` | Structured logging |
| **LogFileService** | `core/services/log/` | File-based logging |
| **LogGoogleChat** | `core/services/log/` | Google Chat webhook |
| **ShorebirdService** | `core/services/shorebird/` | OTA update management |
| **DailyLogScheduler** | `core/services/log/` | Daily log rotation |

## Networking Architecture

```
ApiClient (Dio wrapper)
    ↓ [with interceptors: auth, logging, error]
    ↓
UserRepository (business logic)
    ↓
LoginCubit (state management)
    ↓
LoginScreen (UI layer)
```

**Interceptors:**
- AuthInterceptor → Adds Bearer token
- LoggerInterceptor → Curl-style request/response logging
- ErrorInterceptor → Maps HTTP status to domain exceptions

## Testing Setup

```
test/
├── core/
│   ├── api_client_test.dart          [API CLIENT TESTS]
│   ├── keyboard_service_test.dart    [KEYBOARD SERVICE]
│   ├── queue_engine_test.dart        [QUEUE ENGINE]
│   └── network/
│       ├── api_client_test.dart
│       └── network_queue_service_test.dart
├── features/
│   ├── auth/
│   │   ├── cubit/
│   │   │   └── login_cubit_test.dart [CUBIT TESTS]
│   │   └── repos/
│   └── [OTHER FEATURE TESTS]
└── helpers/
    ├── mock_*.dart                   [MOCK CLASSES]
    └── test_helpers.dart             [TEST UTILITIES]
```

**Run tests:**
```bash
fvm flutter test                       # All tests
fvm flutter test test/core/            # Specific directory
fvm flutter test --coverage            # With coverage
```

## Build & Configuration

### Environment Variables
- **Stored in:** `example/fastlane/.env` (gitignored)
- **Keys:** FIREBASE_TOKEN, FIREBASE_*_APP_ID, MATCH_PASSWORD, etc.
- **Loaded via:** flutter_dotenv

### Flutter Version Management
- **Tool:** FVM (Flutter Version Manager)
- **Pinned to:** 3.29.3 (in `.fvmrc`)
- **Always use:** `fvm flutter ...` instead of system `flutter`

### Build Artifacts
- **Scripts:** `scripts/` directory
  - `build_android.sh`, `build_ios.sh`
  - `distribute_android.sh`, `distribute_ios.sh`
  - `release.sh`, `env.sh`

## Localization System

**Supported languages:** Vietnamese (vi), English (en)

**How to use:**
```dart
// Get current locale
context.locale.toString()

// Access translations
AppLocalizations.of(context)?.localizedString

// Switch language
// Via SettingCubit or app_local_translate provider
```

## Shorebird OTA Integration

**App ID:** `c8c81c70-83b7-4984-bbb8-3f722cb13277`
**Account:** `tuanvm37@fpt.com`

**Flow:**
1. **ShorebirdService** singleton checks for updates (debounced 15 min)
2. **Auto-download** if update available
3. **SnackBar prompt** to restart app
4. **Auto-restart** on user consent

## Git Workflow

### Commit Convention
```
feat(scope): description        # New feature
fix(scope): description         # Bug fix
refactor(scope): description    # Code refactoring
test(scope): description        # Test changes
docs(scope): description        # Documentation
```

### Recent Work (Latest Commits)
1. **442e4b5** — feat(pipeline): production-ready Shorebird + Fastlane + Firebase
2. **37d8e00** — refactor(home): format & extract pages; use IndexedStack
3. **75232b4** — test(network): add ApiClient & UserRepository unit tests
4. **4e1315c** — feat(auth): switch LoginCubit to use UserRepository (API)
5. **804c474** — feat(network+repo): add UserRepository & ApiClient singleton

## Known Issues & TODOs

- **Multiple entry points:** Slower compilation time (68 main_*.dart files)
- **No code generation:** Hive adapters need manual `build_runner` runs
- **SharedPreferences for tokens (demo):** Use flutter_secure_storage in production
- **Localization (simple):** No automatic key extraction like intl+ARB

## Performance Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| **APK Size (debug)** | ~50MB | Includes all features + dependencies |
| **Startup Time** | ~3-5s | Depends on device, feature initialization |
| **Build Time** | ~2-3min | Multiple entry points slow compilation |
| **Test Coverage** | ~40-50% | Core layer well-tested, features varying |

## Next Steps for Contributors

1. **Pick a feature** from `lib/features/` to enhance
2. **Follow architecture rules** in `docs/claude/rules-*.md`
3. **Add unit tests** in `test/` directory
4. **Run tests:** `fvm flutter test`
5. **Format code:** `fvm dart format lib/`
6. **Commit:** Use conventional commit format
