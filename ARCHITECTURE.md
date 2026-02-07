# TRINI-DIABETES RESEARCH APP - MASTER ARCHITECTURE

**Objective:** Build a Proof-of-Concept (PoC) diabetes logging app for elderly users (60+) in Trinidad.
**Core Philosophy:** Accessibility First, Offline First, Zero-Cost Operation.

## 1. TECH STACK
- **Framework:** Flutter (Mobile).
- **Database:** Drift (SQLite) - Local storage.
- **AI Engine (Local):** `mediapipe_genai` running `DeepSeek-R1-Distill-1.5B-Q4.gguf`.
- **AI Engine (Cloud):** DeepSeek V3 API (Fallback only).
- **Backup:** Google Drive API (User-controlled, "WhatsApp-style").

## 2. ENGINEERING GUIDELINES (Strict Enforcement)
*Critical for Grant Approval & Medical Safety (IEC 62366)*
1.  **Touch Targets:** ALL tappable widgets must be wrapped in `SizedBox(minWidth: 48, minHeight: 48)`.
2.  **Typography Scaling:** NEVER use fixed height containers. Use `Expanded` or `Flexible`.
3.  **Color Safety:**
    - Critical (<70 or >250): `Color(0xFFD32F2F)` [Red]
    - Normal (70-180): `Color(0xFF388E3C)` [Green]
    - Action Buttons: `Color(0xFF003366)` [Navy]
4.  **Spacing:** Minimum padding between interactive elements: 16dp.

## 3. UI/UX GUIDELINES ("Big Design" System)
- **Typography:**
  - Body Text: Minimum **18sp** (Roboto/Poppins).
  - Headings: Minimum **24sp** (Bold).
- **Components:**
  - `BigButton`: Height 64px, rounded corners, label + icon.
  - `VoiceFAB`: 120px circular microphone button for main input.
  - `StatusCard`: Large card showing "Last Glucose" with 40sp font.
- **Accessibility:** All widgets must have `Semantics()` labels for TalkBack.

## 4. IMPLEMENTATION PHASES (Agent Instructions)

### PHASE 1: Project Skeleton & Theme
- Initialize Flutter project.
- Implement `theme.dart` with the High Contrast palette.
- Create the `BigButton`, `VoiceFAB` and `StatusCard` widgets.
- **Constraint:** Ensure all text scales automatically.

### PHASE 2: Local Database (Drift)
- Create `database.dart`.
- **Table `Logs`:**
  - `id` (Int), `timestamp` (DateTime), `bg_value` (Double).
  - `food_items` (String/JSON), `portion_size` (String).
  - `finished_meal` (Bool) - *Critical for research.*
  - `context_tags` (String) - e.g., "Post-Exercise", "Fasting".
- **Query:** `getRecentLogs(Duration)` returns last 48h for AI analysis.

### PHASE 3: Voice Input & Extraction
- **Action:** Record audio -> Native Speech-to-Text -> Text.
- **AI Task:** Send text to AI with `extraction_system.txt` prompt.
- **Goal:** Convert *"I ate a bowl of callaloo but felt shaky"* into:
  - `{"food": "Callaloo", "symptoms": ["Shaky"], "portion": "1 bowl"}`.

### PHASE 4: The Hybrid AI Engine (Strategy Pattern)
- **Component:** `AIServiceRepository`.
- **Logic:**
  1. **Check:** Is `DeepSeek-1.5B.gguf` downloaded?
  2. **IF YES (Local):** Load model via MediaPipe. Run inference on device. (Cost: $0).
  3. **IF NO (Cloud):** Send anonymized JSON to DeepSeek API. (Cost: Low).
- **Model Management:**
  - Create `ModelDownloader` service to fetch the .gguf file.
  - Show "Download AI" progress bar in Settings.
- **Safety:** Regex filter to block medical advice (words like "dose", "inject").

### PHASE 5: Privacy & Backup
- **Encryption:** Use `sqlcipher` to encrypt the local database.
- **Cloud:** "Backup to Drive" button.
- **Auth:** `google_sign_in` with `drive.file` scope (App Data folder only).