# DiaMetrics

A Flutter diabetes management app for patients — including elderly users — that provides glucose, meal, and medication logging with AI-powered food analysis, blood glucose projection, and a fully offline, encrypted data store.

---

## Features

- **Glucose logging** — Record readings with context tags; view history with Time-in-Range % and estimated HbA1c
- **Real-time alerts** — Dashboard warnings for high, low, and critical glucose levels based on your personal target range
- **Meal logging** — Log macros manually, via AI camera analysis (Gemini Vision), or by scanning a food barcode
- **Blood glucose projection** — Hovorka Phase 1 algorithm projects your glucose curve 3 hours post-meal, with adaptive EKF calibration over time
- **Medication logging** — Track rapid-acting insulin, long-acting insulin, and oral medication with dosage history
- **Historical trends** — Multi-overlay glucose chart over 7 / 30 / 90 days with meal and insulin markers
- **Caribbean food support** — Specialised absorption profiles for regional staple foods
- **Biometric lock** — Fingerprint / face ID authentication; locks after 1 minute in background
- **Fully offline** — All health data stays on-device in an AES-256 encrypted SQLite database
- **Accessible design** — Built for elderly users: large text, large tap targets, high-contrast theme

---

## Screenshots

Screenshots coming soon.

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.10.8
- Dart SDK >= 3.10.8
- A physical device or emulator (biometric features require a real device for full testing)
- A Gemini API key (required only for AI food image analysis)

### Environment Variables

| Variable | Required | How to set |
|---|---|---|
| `GEMINI_API_KEY` | Yes (for AI features) | Pass via `--dart-define` at run time — never hardcode in source |

### Build and Run

```bash
# Install dependencies
flutter pub get

# Code generation — required after changes to @freezed models, Drift tables, or @injectable services
dart run build_runner build --delete-conflicting-outputs

# Run with AI features enabled
flutter run --dart-define=GEMINI_API_KEY=<your_key>

# Run without AI features (camera analysis will be unavailable)
flutter run

# Static analysis
flutter analyze --no-fatal-infos

# Tests
flutter test
```

---

## Architecture

DiaMetrics follows **MVVM** with a strict separation of concerns:

```
lib/views/        — Presentation (Widgets, no business logic)
lib/viewmodels/   — State management (Riverpod Notifiers)
lib/repositories/ — Data access abstraction (SQLite queries)
lib/services/     — Business logic and external capabilities
lib/models/       — Freezed domain models
lib/core/         — Theme tokens, security, shared widgets, DatabaseHelper
lib/database/     — Drift ORM schema (food reference data)
lib/src/          — Clean Architecture module: Gemini AI, DI, food domain
```

**State management:** Riverpod (`AsyncNotifierProvider` for persistent data, `StateNotifierProvider` for wizard/form state).

**Dependency injection:** GetIt + Injectable for services; Riverpod for app-layer state. The two are bridged via `getIt<T>()` calls inside providers.

**Database:** Two SQLite layers — Drift ORM for the food reference database, and a raw `DatabaseHelper` singleton for all runtime health data (glucose logs, meal logs, medication logs, user profile).

---

## Privacy and Security

- Health data never leaves the device. The only external network call is sending food images to the Gemini API when the user explicitly triggers AI analysis.
- The local SQLite database is encrypted with AES-256 via SQLCipher.
- Access tokens and secure preferences are stored in `flutter_secure_storage`.
- Biometric authentication (fingerprint / face ID) is enforced on every app launch and after the app has been in the background for more than 1 minute.

---

## License

MIT
