# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DiaMetrics** is a Flutter diabetes management app targeting patients (including elderly users). It provides glucose, meal, and medication logging with AI-powered food image analysis, blood glucose projection, and an offline-first architecture. Accessibility and UI stability are high priorities.

---

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Code generation — MUST run after any changes to @freezed models, Drift tables, or @injectable services
dart run build_runner build --delete-conflicting-outputs

# Run app (GEMINI_API_KEY required for AI food analysis)
flutter run --dart-define=GEMINI_API_KEY=<your_key>

# Static analysis
flutter analyze --no-fatal-infos

# Tests
flutter test

# Run a single test file
flutter test test/database_test.dart
```

> **Always re-run `build_runner`** after adding or modifying `@freezed` models, Drift table definitions, or `@injectable` services. Generated files (`*.freezed.dart`, `*.g.dart`, `injection.config.dart`) must stay in sync.

---

## Architecture

**Pattern:** MVVM with strict separation of concerns.

```
lib/views/           → Presentation (Widgets, no business logic)
lib/viewmodels/      → State management (Riverpod Notifiers)
lib/repositories/    → Data access abstraction (SQLite queries)
lib/services/        → Business logic & external capabilities
lib/models/          → Freezed domain models (SQLite layer)
lib/core/            → Theme, security, shared widgets, DatabaseHelper
lib/database/        → Drift ORM schema and DB instance (food data)
lib/src/             → Clean Architecture module: Gemini AI, DI, food domain
```

### State Management — Riverpod

Two patterns are used:
- **`AsyncNotifierProvider`** — for persistent data (logs, user profile). Examples: `glucoseLogsProvider`, `mealLogsProvider`, `userProfileProvider`.
- **`StateNotifierProvider`** — for transient wizard/form state. Example: `loggingWizardProvider`.

After a write operation, always call `ref.invalidate(provider)` to trigger a fresh load rather than manually constructing new state.

### Dependency Injection — Bridge Pattern

GetIt + Injectable manages services in `lib/src/`. Riverpod manages app-layer state. The bridge is `getIt<T>()` called inside Riverpod providers or `ConsumerWidget.build`. Do not inject GetIt services directly into Freezed models or repository constructors.

---

## Dual Database Architecture ⚠️

The app has **two separate SQLite layers** — understanding which to use where is critical:

| Layer | Location | Used For |
|---|---|---|
| **Drift ORM** | `lib/database/database.dart` | `Logs`, `LocalFoods`, `CustomFoods`, `MealLogs` — food reference data and the newer Drift-based log schema |
| **Raw SQLite** (`DatabaseHelper`) | `lib/core/database/database_helper.dart` | `user_profiles`, `glucose_logs`, `meal_logs`, `medication_logs` — the primary runtime tables used by all repositories |

All repositories under `lib/repositories/` use **`DatabaseHelper`** (raw SQLite), not Drift. The Drift layer is used by the food RAG pipeline and is pre-populated from `assets/database/cleaned_food_database.csv` on first run.

**Current schema version:** `DatabaseHelper._databaseVersion = 3`
- v2 → v3: Added `name TEXT NOT NULL DEFAULT ''` column to `user_profiles`.

---

## Key Files

| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point — `ProviderScope`, `configureDependencies()`, routes directly to `DashboardView` |
| `lib/core/theme/app_tokens.dart` | Design tokens — **always use these, never hardcode colors or sizes** |
| `lib/core/database/database_helper.dart` | Raw SQLite singleton — schema creation and migrations |
| `lib/viewmodels/profile_viewmodel.dart` | `userProfileProvider` — app-wide user profile state |
| `lib/viewmodels/health_data_viewmodel.dart` | Providers for glucose/meal/medication log lists |
| `lib/viewmodels/logging_wizard_viewmodel.dart` | Wizard form state + `saveMealWithProjection()` |
| `lib/services/glucose_projection_service.dart` | Phase 1 Hovorka blood glucose projection algorithm |
| `lib/models/projection_result.dart` | Freezed models for projection curve data |
| `lib/services/food_rag_service.dart` | RAG enrichment: Gemini AI output → local food DB lookup |
| `lib/src/data/repositories/gemini_food_analyzer_impl.dart` | Gemini API: food image → nutrition estimates |
| `lib/src/core/di/injection.dart` | GetIt service registration |
| `assets/prompts/analysis_system.txt` | Gemini system prompt (elderly-friendly tone) |

---

## Data Flow — Meal Logging with Projection

This is the most complex flow in the app:

```
MealWizardView
  │
  ├── initState: checkRecentPreMealGlucose()   ← auto-fill if reading within 30 min
  ├── initState: UserRepository.getProfile()   ← load weightKg for Hovorka model
  │
  ├── User enters pre-meal glucose (required)
  ├── User enters macros (carbs/protein/fat) manually or via camera
  │     └── camera → ImagePicker → GeminiFoodAnalyzerImpl → FoodRagService.enrichWithLocalData()
  │
  └── saveMealWithProjection(weightKg)
        ├── save pre-meal GlucoseLog (if manually entered, not auto-detected)
        ├── save MealLog
        ├── _calculateIOB() ← rapid-acting insulin from last 4 hrs, linear decay
        ├── GlucoseProjectionService.project(...)
        └── navigate → ProjectionResultView
```

**Hovorka Phase 1 algorithm** (`GlucoseProjectionService`):
- TAG = netCarbs + 0.58×protein + 0.10×fat
- Gut absorption: `R_a(t) = A_G × D_G × t × exp(-t/t_max) / t_max²`
- High fat/protein (>40g fat or >25g protein): t_max += 30 min
- Alcohol: t_max += 20 min, −3 mg/dL/hr after 60 min
- Caffeine: absorption ×1.10
- IOB: linear decay over 240-min DIA window

---

## Providers Quick Reference

```dart
// Read user profile (UserProfile?)
ref.watch(userProfileProvider)

// Update user profile (also persists to DB)
ref.read(userProfileProvider.notifier).updateProfile(updatedProfile)

// Glucose / meal / medication log lists
ref.watch(glucoseLogsProvider)   // AsyncValue<List<GlucoseLog>>
ref.watch(mealLogsProvider)      // AsyncValue<List<MealLog>>
ref.watch(medicationLogsProvider)

// Wizard form state
ref.watch(loggingWizardProvider)
ref.read(loggingWizardProvider.notifier).setPreMealGlucose(value)
ref.read(loggingWizardProvider.notifier).saveMealWithProjection(weightKg: 70)

// Raw repository (for custom queries)
ref.read(healthDataRepositoryProvider)
```

---

## Code Conventions

- **Models:** `@freezed` with `abstract class`. Run `build_runner` after every change.
- **Styling:** use `AppThemeTokens` static constants — no hardcoded hex values, no raw `TextStyle` literals.
- **Icons:** `lucide_icons` package is the standard (`import 'package:lucide_icons/lucide_icons.dart'`). Existing code may use Material `Icons.*` — prefer Lucide for new code.
- **Font:** Inter via `google_fonts`.
- **Error handling:** guard all DB access and API calls; the UI must never crash or show blank screens on failure.
- **AI response values:** always clamp Gemini-returned numbers before use in layout — unclamped values cause infinite render loops.
- **ImagePicker / external activities:** set `AppLockConfig.ignoreNextResume = true` before launching to suppress the biometric re-lock that fires when the app returns to foreground.
- **Biometric lock:** `AuthWrapper` (whole-app) triggers on app resume after sleep. Individual health data screens no longer wrap content in `SensitiveDataOverlay` — that widget exists but is currently unused in the main flows.

---

## Settings & Profile

User profile editing is handled entirely through:
- **`lib/views/settings/settings_view.dart`** — full edit UI (name, age, gender, height, weight, diabetes type, diagnosis year, glucose unit, treatment flags, glucose targets)
- **`lib/viewmodels/profile_viewmodel.dart`** — `userProfileProvider`; call `.updateProfile(profile)` to persist

The dashboard reads `userProfileProvider` and displays the real patient name + glucose target range in the account card header. Tapping the account card navigates to `SettingsView`.

---

## Environment Variables

| Variable | Required | Notes |
|---|---|---|
| `GEMINI_API_KEY` | Yes (for AI features) | Pass via `--dart-define` only — never hardcode |

---

## Tests

- `test/widget_test.dart` — verifies app starts and shows DiaMetrics title/loading screen.
- `test/database_test.dart` — 5 CRUD tests against an in-memory SQLite DB (insert, query, field integrity, nullable defaults, delete).

---

## Security

- Credentials encrypted via `flutter_secure_storage`; biometric auth via `local_auth`.
- Whole-app lock on resume: `AuthWrapper` in the navigation stack.
- No API keys in source — `--dart-define` only.
