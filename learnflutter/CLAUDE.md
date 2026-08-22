# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# LearnFlutter — Learning & Feature Exploration App

68+ feature modules demonstrating Flutter patterns: BLoC/Cubit, Riverpod, networking, maps, camera, OTA updates, etc.

## Commands

**Always use `fvm flutter`, never bare `flutter`** (pinned to 3.29.3 via `.fvmrc`).

```bash
# Run
fvm flutter run -t lib/main.dart              # default
fvm flutter run -t lib/main_story.dart        # animations
fvm flutter run -t lib/main_qr_code.dart      # QR scanning
fvm flutter run -t lib/main_balance.dart      # balance bar
fvm flutter run -t lib/main_riverpod.dart     # Riverpod demo
fvm flutter run -t lib/main_permission.dart   # permissions

# Test
fvm flutter test                                        # all
fvm flutter test test/core/api_client_test.dart        # single file
fvm flutter test --name "description substring"        # single test

# Quality
fvm dart format lib/
fvm flutter analyze

# Build
fvm flutter build apk -t lib/main.dart
fvm flutter build appbundle -t lib/main.dart
fvm flutter build ipa -t lib/main.dart
```

## Architecture

**Pattern:** Feature-module (Clean Architecture inspired). Two coexisting state management approaches.

```
lib/
├── main.dart / main_*.dart     # Multiple entry points per feature demo
├── app/                        # Root widget, splash, theme, localization
├── core/                       # Cross-cutting: network, storage, services, utils
│   ├── network/api_client/     # Dio singleton + request queue
│   ├── network/repositories/   # UserRepository (API abstraction)
│   ├── services/               # KeyboardService, ShorebirdService, AppTalker, logging
│   ├── storage/                # Hive + SQLite demos
│   └── engines/                # Platform engines (GoogleMaps, BottomSheet)
├── features/                   # 68+ feature modules, each: cubit/ state/ screens/
├── shared/widgets/             # Reusable UI, routing
└── l10n/                       # vi + en localizations
```

**State management split:**
- `flutter_bloc` Cubits — global state (`SettingCubit`, `BaseLoadingCubit`, `SearchBarCubit`) and per-feature state
- `hooks_riverpod` — functional/hook patterns, locale provider

**Key singletons (do not recreate):**
- `ApiClient` — `lib/core/network/api_client/api_client.dart`
- `AppTalker` — `lib/core/services/talker/app_talker.dart`
- `ShorebirdService` — OTA checks, debounced 15 min
- `KeyboardService` — keyboard height from `window.viewInsets`

**Keyboard handling:** `GlobalNoKeyboardRebuild` prevents widget rebuilds on keyboard show/hide. `KeyboardService` tracks height in logical pixels.

**Logging:** Multi-tier — console via AppTalker, file via `LogFileService`, Google Chat webhook via `LogGoogleChat`, daily rotation via `DailyLogScheduler`.

**OTA:** `ShorebirdService` auto-downloads patch + shows SnackBar restart prompt. App ID: `c8c81c70-83b7-4984-bbb8-3f722cb13277`.

**Localization:** `flutter_localization` (Riverpod). Languages: vi, en. Switch via `lib/l10n/helper.dart`. Access: `AppLocalizations.of(context)?.key`.

## Rules & Docs

Detailed rules live in `docs/claude/`:
- `rules-architecture.md` — layer boundaries, Cubit lifecycle, feature module structure
- `rules-api.md` — ApiClient setup, repository pattern, error handling
- `rules-coding.md` — Dart style, widget conventions, state patterns
- `rules-testing.md` — test patterns
- `rules-security.md`, `rules-database.md`
- `context-codebase.md`, `context-domain.md`, `guardrails.md`

## Quirks

- **No code generation:** Uses `equatable` not `freezed` for value equality (`freezed_annotation` present but optional).
- **Features are demos:** Not all production-grade. Each module explores a specific library/pattern.
- **Dual state management:** Cubits and Riverpod coexist — don't consolidate unless asked.
- **Shorebird Flutter version** (3.44.0) differs from FVM project version (3.29.3). Build scripts pass `--flutter-version=3.29.3`.
- **Commit convention:** Conventional Commits — `feat`, `fix`, `refactor`, `test`, `docs`, `style`.
