# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**水赫手记 (Shuihe Shouji)** — a personal productivity app built with Flutter (Dart SDK ^3.11.0). Features: Todo List, Memo, Journal, and Settings. Full product spec is in `product.md`.

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run -d chrome        # Run on web (not in scope but available)
flutter analyze              # Static analysis (uses flutter_lints)
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires macOS + Xcode)
dart run build_runner build  # Generate Drift database code (app_database.g.dart)
```

## Architecture

Clean Architecture with three layers, per `product.md`:

```
lib/
├── main.dart           # Bootstrap: pre-loads settings into ProviderContainer before runApp
├── app.dart            # ShuiheApp: MaterialApp.router with theme + go_router
├── core/
│   ├── database/       # Drift (SQLite) — tables + queries in app_database.dart, singleton via databaseProvider
│   ├── theme/          # shadcn/ui tokens: AppColors, AppTextStyles, AppSpacing, AppTheme (light/dark)
│   ├── services/       # SoundService, HapticService, DataExportService, DataImportService
│   ├── settings/       # AppSettingsData (immutable model) + SharedPreferences persistence
│   └── router/         # go_router config with StatefulShellRoute for bottom nav
├── shared/widgets/     # Design system components (AppButton, AppCard, AppInput, etc.)
└── features/           # Feature modules: todo/, memo/, journal/, settings/
    └── <feature>/
        ├── domain/     # Entities (immutable, with copyWith) + Repository interfaces
        ├── data/
        │   ├── repositories/  # Repository implementations backed by Drift
        │   └── mappers/       # Convert Drift row ↔ domain entity
        └── presentation/
            ├── providers/     # Riverpod StateNotifierProvider per feature
            ├── pages/         # Full-screen pages
            └── widgets/       # Feature-specific widgets
```

### Data Flow Pattern

Each feature follows the same wiring:

1. `databaseProvider` (singleton `AppDatabase`) → injected into repository impl
2. Repository impl registered as `Provider<XxxRepository>` in the feature's provider file
3. `StateNotifierProvider` subscribes to repository streams → UI rebuilds reactively
4. All state classes are immutable with `copyWith`

### Key Providers (entry points for each feature)

- `todoProvider` — `StateNotifierProvider<TodoNotifier, TodoState>` in `features/todo/presentation/providers/`
- `memoProvider` — same pattern in `features/memo/presentation/providers/`
- `journalProvider` — same pattern in `features/journal/presentation/providers/`
- `settingsProvider` — `StateNotifierProvider<SettingsNotifier, AppSettingsData>` in `core/settings/`
- `databaseProvider` — `Provider<AppDatabase>` in `core/database/`

## Key Technical Decisions

- **State management**: Riverpod 2.x (`StateNotifierProvider` + reactive `Stream` from Drift)
- **Local database**: Drift 2.x (SQLite) — requires code generation via `build_runner`; DB file: `shuihe.sqlite` in app documents directory
- **Routing**: `go_router` with `StatefulShellRoute.indexedStack` for 4 bottom tabs (`/todo`, `/memo`, `/journal`, `/settings`). Full-screen routes (e.g. `/memo/edit`) use `parentNavigatorKey` to push above the shell
- **Rich text**: Journal content stored as Delta JSON (`[{"insert": "text\n"}]`) for future `flutter_quill` integration — currently uses plain `TextField` with 2s debounce auto-save
- **Settings persistence**: `SharedPreferences` (not Drift) — loaded once at startup before widget tree via `ProviderContainer`
- **Design system**: shadcn/ui tokens ported to Flutter — all colors via `AppColors`, typography via `AppTextStyles`, spacing via `AppSpacing`

## Design System Rules

- **Never hardcode colors** in widgets — use `AppColors` or `Theme.of(context)`
- Dark mode via dual `ThemeData` (`AppTheme.light()` / `AppTheme.dark()`), not conditional color switching in components
- Use `shared/widgets/app_*.dart` components, not raw Material widgets
- Sound/haptic feedback managed centrally via `SoundService`/`HapticService` — always check user settings before triggering

## Todo Completion Feedback (Core UX)

When a todo is marked done, trigger simultaneously:
1. Sound effect (`assets/sounds/todo_done.mp3`) via `SoundService`
2. Haptic feedback (`HapticFeedback.lightImpact()`) via `HapticService`
3. Visual animation: checkbox scale bounce → strikethrough text → fade → move to completed section

Use `unawaited()` for sound/haptic calls to avoid blocking the UI.

## Platforms

- Android: minSdkVersion 21
- iOS: 13+
- Web: not in scope
