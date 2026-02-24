# DiaMetrics — Technical Summary

**Course:** ECNG2005 — Laboratory and Project Design III
**Date:** February 24, 2026
**Repository:** [github.com/joebenberry-afk/Diametrics](https://github.com/joebenberry-afk/Diametrics)

---

## 1. Project Overview

DiaMetrics is a proof-of-concept mobile application designed to assist elderly diabetic patients (60+) in Trinidad and Tobago with daily blood glucose monitoring and food logging. The application is developed in collaboration with Dr. Rocke (BIRD Lab) and the Ministry of Health (Trinidad), with the ultimate goal of supporting a pilot clinical study.

**Core design principles:**
- **Accessibility First** — Minimum 18sp font sizes, high-contrast colour palette, 48dp touch targets (IEC 62366 compliant)
- **Offline-First Operation** — Critical functions (text search, barcode scanning, OCR, glucose logging) operate fully offline. Cloud AI (Gemini Flash) is used opportunistically when an internet connection is available.
- **Zero-Cost Operation** — Uses the Gemini API free tier; no subscriptions or paid cloud services required.
- **Data Privacy** — All patient data stored locally with AES-256 encryption; no central server (HIPAA avoidance strategy).

---

## 2. Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.10+ (Dart) | Cross-platform mobile development |
| Database | Drift (SQLite ORM) + sqlite3_flutter_libs | Typed local storage with AES-256 encryption |
| **AI — Image Analysis** | **Google Gemini 2.5 Flash (API)** | **Cloud AI food photo recognition and nutritional analysis** |
| AI — Text Recognition | Google ML Kit Text Recognition | Offline OCR for nutrition label scanning |
| AI — Barcode Scanning | Google ML Kit Barcode Scanning | Offline product barcode identification |
| Food Database | USDA FoodData Central (SR Legacy) | Pre-populated 7,803-item offline nutritional reference |
| **API Security** | **`--dart-define=GEMINI_API_KEY=...`** | **Build-time injection; key never hardcoded in source** |
| **Caching** | **SHA-256 in-memory cache (crypto pkg)** | **Avoids redundant Gemini API calls for identical images** |
| **Networking** | **http + connectivity_plus** | **REST calls to Gemini; pre-flight connectivity check** |
| Image Capture | Image Picker | Camera and gallery access |
| Typography | Google Fonts (Poppins) | Accessible, consistent typography |
| Permissions | Permission Handler | Runtime permission management |
| Key Storage | SharedPreferences | Encryption key and onboarding state persistence |

---

## 3. System Architecture

```
+----------------------------------------------------------+
|                    PRESENTATION LAYER                     |
|  Splash > Login > Onboarding Flow > Dashboard (5 Tabs)  |
|  [Home] [Glucose] [Food AI] [Reminders] [Emergency]      |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|                    BUSINESS LOGIC LAYER                   |
|  FoodAnalyzer (Gemini) | NutritionLabelParser | Search  |
|  SyncManager | USDA Cross-Reference Enrichment           |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|                    DATA LAYER (Encrypted)                 |
|  Drift ORM > sqlite3_flutter_libs (AES-256)              |
|  Tables: Logs | LocalFoods | CustomFoods | MealLogs      |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|              AI LAYER (Cloud + On-Device)                 |
|  [Online]  Gemini 2.5 Flash — food photo analysis        |
|  [Offline] ML Kit Text Recognition — label OCR           |
|  [Offline] ML Kit Barcode Scanning — product lookup      |
+----------------------------------------------------------+
```

---

## 4. Database Schema (Drift/SQLite — Encrypted)

The database uses AES-256 encryption at rest via `sqlite3_flutter_libs`. The encryption key is generated once at first launch and stored securely on-device.

### Table: `logs` — Glucose Readings
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-incrementing primary key |
| timestamp | DATETIME | When the reading was taken |
| bg_value | REAL | Blood glucose value (mg/dL or mmol/L) |
| food_items | TEXT | Associated food items (JSON) |
| portion_size | TEXT | Estimated portion size |
| context_tags | TEXT | e.g., "Fasting", "After Meal", "Bedtime" |
| finished_meal | BOOLEAN | Whether the meal was completed |

### Table: `local_foods` — Pre-Populated Nutritional Database
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-incrementing primary key |
| name | TEXT | Food name (e.g., "Sada Roti", "Apple") |
| serving_size | TEXT | Default serving size (default: "100g") |
| carbs_per_serving | REAL | Carbohydrate content per serving |

**Data source:** 7,793 items from USDA FoodData Central (SR Legacy 2018) + 10 custom Trinidadian entries (Sada Roti, Dhalpuri Roti, Doubles, Aloo Pie, Bake and Shark, Pelau, Callaloo, Macaroni Pie, Pholourie, Paratha Roti).

### Table: `custom_foods` — User-Added Items
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-incrementing primary key |
| user_defined_name | TEXT | User-given name |
| barcode | TEXT (nullable) | Product barcode (if scanned) |
| serving_size | TEXT | Serving size |
| carbs_per_serving | REAL | Carbohydrate content per serving |

### Table: `meal_logs` — Food Activity Log
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-incrementing primary key |
| timestamp | DATETIME | When the meal was logged |
| image_path | TEXT (nullable) | Local file path to captured meal photo |
| transcription | TEXT (nullable) | Text description of the meal |
| estimated_carbs | REAL | AI-estimated carbohydrate count |
| completion_percentage | INTEGER | How much of the meal was consumed (default: 100) |
| sync_status | TEXT | "synced" or "pending" |
| is_offline_estimate | BOOLEAN | True if estimate was made without cloud AI |

---

## 5. AI & Food Recognition Pipeline

DiaMetrics implements a hybrid AI pipeline for food logging that gracefully degrades when offline.

### 5.1 Camera-Based Food Recognition (Gemini Flash — Online)

This pipeline replaces the previous Google ML Kit Image Labeling approach with a cloud-based LLM for significantly higher accuracy and richer structured output.

1. User captures a photo via the in-app camera or selects from gallery.
2. Image is compressed to 512×512px at 70% JPEG quality before transmission.
3. A **pre-flight connectivity check** (`connectivity_plus`) ensures internet is available. If not, the user is informed and directed to use text search.
4. The image is Base64-encoded and sent to **Google Gemini 2.5 Flash** via the REST API.
5. Gemini returns a structured JSON response listing each food item with: name, portion, carbs_g, calories, protein_g, fat_g, and a meal summary.
6. Each identified food item is **cross-referenced against the local USDA database** (SQL `LIKE` query). If a match is found, Gemini's estimated carb value is replaced with the verified USDA figure, and the item is marked as `source: 'USDA'` instead of `source: 'AI Estimate'`.
7. Results are displayed to the user for confirmation before logging.

**Reliability features built into `FoodAnalyzer`:**
- **SHA-256 in-memory cache** — identical images (same byte content) return instantly without an API call. Cache is capped at 20 entries to prevent memory bloat.
- **Exponential backoff retry** — transient network/server failures are retried up to 3 times with delays of 1s, 2s, 4s.
- **Rate limit handling** — HTTP 429 responses throw a `RateLimitException` that bypasses retry (retrying would waste quota) and surfaces a user-friendly message.
- **30-second HTTP timeout** — prevents the UI from hanging indefinitely on slow connections.
- **Markdown fence stripping** — the response parser strips any ` ```json ``` ` fences Gemini may include despite being asked for raw JSON.
- **Increased `maxOutputTokens: 2048`** — prevents response truncation for meals with many items.

### 5.2 Text-Based Food Search (Offline)
1. User types a food name into the search bar.
2. A real-time SQL `LIKE` query searches both `custom_foods` (user-added, checked first) and `local_foods` (USDA reference database).
3. Results are labelled with their source (`Custom` or `USDA`) and carbohydrate values; tapping a result logs it as a meal.

### 5.3 Nutrition Label Scanner — OCR (Offline)
1. User photographs a Nutrition Facts panel on product packaging.
2. **Google ML Kit Text Recognition** extracts all visible text from the image on-device.
3. The custom `NutritionLabelParser` applies regex pattern matching to extract: Serving Size, Calories, Total Carbohydrates, Total Fat, Protein, Sugars, Fiber, Sodium.
4. Extracted values auto-fill the "Add Custom Food" dialog for user confirmation and permanent storage.

### 5.4 Barcode Scanning (Offline)
1. User scans a product barcode using **Google ML Kit Barcode Scanning**.
2. The barcode value is queried against the `custom_foods` table.
3. If found: the stored nutritional information is immediately used for logging.
4. If not found: the user is prompted to add the product manually (or scan the nutrition label), creating a permanent entry for future scans.

---

## 6. API Security

The Gemini API key is **never hardcoded** in source files. It is injected at build time using Flutter's `--dart-define` mechanism and accessed via a dedicated `ApiConfig` class:

```
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

The `ApiConfig.isConfigured` guard prevents the app from attempting API calls (and crashing) if the key is not provided, showing a clear error message instead. The key is never transmitted beyond the Gemini API endpoint and is not stored in the database or SharedPreferences.

---

## 7. Application Screens

| Screen | File | Description |
|--------|------|-------------|
| **Splash** | `splash_screen.dart` | **Branded loading screen while DB initializes; shows retry on error** |
| Login | `login_screen.dart` | Sign-in with "Continue as Guest" option |
| Personal Info | `personal_info_screen.dart` | Name, age, contact details |
| Health Info | `health_info_screen.dart` | Diabetes type, insulin use, target range |
| Medical Settings | `medical_settings_screen.dart` | Medication details, doctor info |
| Permissions | `permissions_screen.dart` | Runtime permission requests |
| Home Dashboard | `home_screen.dart` | Overview with mascot, status cards, recent logs |
| Glucose Logging | `glucose_log_screen.dart` | Blood glucose value entry with context tags |
| Food Recording | `add_food_screen.dart` | **Gemini Flash food AI + offline text/barcode/OCR fallbacks** |
| Statistics | `statistics_screen.dart` | Charts and trends |
| Reminders | `reminders_screen.dart` | Medication and glucose check reminders |
| Emergency | `emergency_screen.dart` | Emergency contacts and hypo/hyperglycemia thresholds |
| Circle Management | `circle_management_screen.dart` | Caregiver/family circle configuration |
| Debug | `debug_screen.dart` | Development-only database inspection |

---

## 8. Accessibility Compliance (IEC 62366)

DiaMetrics is designed for elderly users (60+) who may have visual impairments, motor skill challenges, or low technical literacy. A full accessibility audit and compliance pass was completed across all dashboard screens.

| Requirement | Implementation |
|-------------|---------------|
| Minimum font size | 18sp body text, 24sp headings (Poppins Medium) |
| Touch target size | All interactive elements minimum 48 × 48 dp |
| Colour contrast | High-contrast palette (Navy #003366, Red #D32F2F) |
| Colour safety | Red (#D32F2F) for critical, Green (#388E3C) for normal, Navy (#003366) for actions |
| Screen reader support | Semantic labels on all widgets for TalkBack/VoiceOver |
| Typography scaling | No fixed-height containers; uses Expanded/Flexible layouts |
| Component spacing | Minimum 16dp padding between interactive elements |

**Screens audited:** `emergency_screen.dart`, `reminders_screen.dart`, `circle_management_screen.dart`, `home_screen.dart`, `statistics_screen.dart`, `add_food_screen.dart`

---

## 9. Security Implementation

| Feature | Technology | Detail |
|---------|-----------|--------|
| Database Encryption | sqlite3_flutter_libs (AES-256-CBC) | All patient data encrypted at rest |
| Key Generation | Dart `Random.secure()` | 32-character cryptographically random key |
| Key Storage | SharedPreferences (device-local) | Key never transmitted over network |
| API Key Handling | `--dart-define` build argument | Never hardcoded; not stored in DB or prefs |
| Data Locality | 100% on-device patient data | No cloud storage, no server communication |
| Privacy Compliance | HIPAA avoidance by design | No central server stores patient data |

> **Note:** `sqlcipher_flutter_libs` (the previous encryption library) reached end-of-life and was replaced with `sqlite3_flutter_libs` which provides the same AES-256 encryption capability with active maintenance support.

---

## 10. Build & Compatibility

| Parameter | Value |
|-----------|-------|
| Flutter SDK | 3.10+ |
| Dart SDK | ^3.10.8 |
| Android minSdk | 21 (Android 5.0 Lollipop) |
| Android targetSdk | 35 (Android 16) |
| Database schema version | 2 |
| Offline food database | 7,803 items (USDA SR Legacy + Trinidadian foods) |
| Total dependencies | 15 production packages |
| Analysis status | 0 errors, 0 warnings |

**Required build flag:**
```
flutter run --dart-define=GEMINI_API_KEY=<key>
```

---

## 11. Current Status & Remaining Work

### Completed
- [x] Theme system and accessibility widgets (`BigButton`, `GlassyCard`, `SeniorTextField`)
- [x] Onboarding flow (Login, Personal Info, Health Info, Medical Settings, Permissions)
- [x] Splash screen with error recovery
- [x] Main dashboard with 5-tab navigation layout
- [x] Glucose logging with context tags
- [x] AES-256 database encryption (`sqlite3_flutter_libs`)
- [x] Offline food database (7,803 USDA + Trinidadian items)
- [x] **Gemini 2.5 Flash cloud AI food recognition** (replaces ML Kit Image Labeling)
- [x] **USDA cross-reference enrichment** of Gemini results
- [x] **API security via `--dart-define`; SHA-256 caching; exponential backoff retry**
- [x] **Offline connectivity check with graceful fallback**
- [x] Barcode scanning for custom food lookup (offline)
- [x] Nutrition label OCR scanner (offline)
- [x] Text-based food search against local database (offline)
- [x] Custom food entry with manual and scanned inputs
- [x] Meal logging with carb estimates
- [x] IEC 62366 accessibility compliance pass across all dashboard screens

### Remaining
- [ ] Statistics charts and trend visualization
- [ ] Sync manager for pending offline data
- [ ] Google Drive backup functionality
- [ ] CSV/PDF export for clinician review
- [ ] Push notifications for reminder alerts
