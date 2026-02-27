# DiaMetrics: AI Agent Context

## 🏥 Project Overview
**DiaMetrics** is a production-grade HealthTech UI/UX framework and application designed for diabetes management. It prioritizes patient safety, HIPAA-aligned security, and a high-fidelity user experience.

### Core Architecture
- **Framework:** Flutter (Dart)
- **Architecture:** Rigid **MVVM** (Model-View-ViewModel) with a strict separation of concerns:
    - **Views:** Presentation layer (`lib/views`).
    - **ViewModels:** Logic and state management (`lib/viewmodels`).
    - **Repositories:** Data access abstraction (`lib/repositories`).
    - **Services:** External API and business capability layer (`lib/services`).
    - **Core:** Cross-cutting concerns like database setup, security, and theme (`lib/core`).
- **State Management:** `flutter_riverpod` using strictly immutable data structures (via `freezed`). **Never mutate state directly.**
- **Persistence:** **Offline-first** architecture using `drift` (SQLite) for local caching.
- **Security:** `flutter_secure_storage` for credentials and `local_auth` for biometric protection of sensitive data.

### Technical Stack
- **Database:** Drift (SQLite), SQLite3
- **Data Modeling:** Freezed, JSON Serializable
- **UI Components:** Material 3, Lucide Icons, Google Fonts (Inter)
- **AI/ML:** Google ML Kit (Text Recognition, Barcode Scanning, Image Labeling)

---

## 🛠 Building and Running

### Prerequisites
- Flutter SDK (latest stable recommended)
- Dart SDK

### Key Commands
1.  **Initialize Project:**
    ```bash
    flutter pub get
    ```
2.  **Code Generation (Freezed/Drift/Injectable):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  **Run Application:**
    ```bash
    flutter run
    ```
4.  **Static Analysis:**
    ```bash
    flutter analyze
    ```

---

## 🎨 Development Conventions

### Styling & UI
- **Token-Based Design System:** Strictly adhere to the design tokens defined in `lib/core/theme/app_tokens.dart`.
- **No Hardcoding:** Never hardcode hex values or specific text styles in UI widgets. Use `context.tokens` (or equivalent theme accessors) to inherit from the Material 3 context.
- **Typography:** Use the **Inter** font family exclusively for maximum readability.
- **Iconography:** Use **Lucide Icons** for all medical and utility iconography.
- **Sensitive Data:** Wrap health-related data in `SensitiveDataOverlay` (from `lib/core/widgets`) to ensure it is obscured until biometric verification.

### Code Quality & Standards
- **Zero Hallucination:** Verify all package dependencies in `pubspec.yaml` before implementation.
- **Immutability:** All models must use `@freezed` to ensure structural equality and immutability.
- **Dependency Injection:** Use `get_it` and `injectable` for service and repository registration.
- **Error Handling:** Implement robust error handling for all data access and API calls, ensuring the UI remains stable during failures.

### RAG & AI Integration
- **Local RAG:** Use `FoodRagService` (`lib/services/food_rag_service.dart`) to augment AI-generated food analysis with verified data from the local SQLite database (`assets/database/cleaned_food_database.csv`).

---

## 📂 Key Directory Structure
- `lib/core/`: Foundation logic (security, theme, shared widgets).
- `lib/database/`: SQLite database definitions and instances.
- `lib/models/`: Data entities and logic-free structures.
- `lib/repositories/`: Abstracted data fetching logic.
- `lib/services/`: Specific functional logic (e.g., AI analysis, logging).
- `lib/viewmodels/`: Reactive state controllers.
- `lib/views/`: Feature-specific UI screens.
- `assets/database/`: Local knowledge bases for RAG.
- `Documentation/`: Comprehensive project research and policy documents.
