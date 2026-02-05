# DIABETES RESEARCH APP - MASTER ARCHITECTURE
**Objective:** Build a Proof-of-Concept (PoC) diabetes logging app for elderly/visually impaired users in Trinidad.
**Tech Stack:** Flutter (Dart), SQLite (Drift), DeepSeek API, Google Drive Backup (googleapis).

## CORE CONSTRAINTS (Strict Adherence Required)
1.  **Accessibility First:** All UI elements must use `Semantics()` for screen readers. Minimum font size 18sp. High contrast (Black/White/Yellow).
2.  **Offline First:** All data lives locally in `drift` database. No external servers except for optional backup.
3.  **Privacy:** No patient data is sent to the cloud *except* anonymized JSON snippets for DeepSeek analysis, which are discarded immediately after.

## DATA STRUCTURE (Schema)
**Table: Logs**
- `id` (Int, AutoIncrement)
- `timestamp` (DateTime) - Vital for "Dawn Effect" detection.
- `bg_value` (Double) - Blood Glucose.
- `bg_unit` (String) - "mg/dL" or "mmol/L".
- `context_tags` (String) - JSON List ["Before Breakfast", "Feeling Shaky", "Post-Walk"].
- `food_volume` (String) - "Fist-size", "Half-plate".
- `finished_meal` (Boolean) - *Did they finish the food?*
- `image_path` (String) - Local path to food photo.

## PHASES OF IMPLEMENTATION (Agent Tasks)

### PHASE 1: Project Skeleton & Accessibility
- **Action:** Initialize Flutter project.
- **Dependency:** Add `drift`, `sqlite3_flutter_libs`, `path_provider`, `google_fonts`.
- **UI System:** Create a `styles.dart` file defining a "Senior Theme":
    - Primary Color: High Contrast Blue (#004488).
    - Font: 'Poppins' or 'Roboto', minimal weight 500.
    - Component: `BigButton` widget (Height: 60px, TextSize: 20px).

### PHASE 2: The "Drift" Database
- **Action:** Create `database.dart`.
- **Logic:** Implement the `Logs` table defined above.
- **Query:** Write a specific query `getLogsForAnalysis(Duration window)` that returns the last 48 hours of data formatted as a simplified JSON string for the AI.

### PHASE 3: Voice & Input (The "Unstated Needs")
- **Action:** Implement a large "Microphone" Floating Action Button.
- **Logic:**
    1. Record audio.
    2. Transcribe (Device Native STT).
    3. Send text to DeepSeek Agent for extraction.
    4. **Prompt for Extraction:** "Extract: 1) Food Name, 2) Volume/Portion, 3) Did they finish? (True/False). Return JSON."

### PHASE 4: The Hybrid AI Engine (On-Demand Strategy)
- **Objective:** Switch between Cloud (API) and Local (Device) AI.
- **Constraint:** App size on App Store must be <100MB. Model must be downloaded post-install.
- **Components:**
    1.  `DeepSeekCloudService`: Standard API calls (Default).
    2.  `ModelManager`:
        - Function `isModelDownloaded()`: Checks if file exists locally.
        - Function `downloadModel()`: Downloads the 1.2GB quantized model (DeepSeek 1.5B) with a progress bar.
    3.  `LocalLlamaService`:
        - Initializes ONLY if `ModelManager.isModelDownloaded()` is true.
        - Uses `flutter_llama_cpp` (or `mediapipe_genai`) to load the file from the Documents directory.

### PHASE 5: The "WhatsApp" Backup
- **Action:** Implement Google Drive Backup.
- **Logic:**
    - On button press -> Close Database.
    - Encrypt `app.db`.
    - Upload to User's Google Drive AppFolder.