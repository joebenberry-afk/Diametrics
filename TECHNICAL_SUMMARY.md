# DiaMetrics - Technical Summary

**Course:** ECNG2005 — Laboratory and Project Design III
**Date:** February 23, 2026
**Repository:** [github.com/joebenberry-afk/Diametrics](https://github.com/joebenberry-afk/Diametrics)

---

## 1. Project Overview

DiaMetrics is a proof-of-concept mobile application designed to assist elderly diabetic patients (60+) in Trinidad and Tobago with daily blood glucose monitoring and food logging. The application is developed in collaboration with Dr. Rocke (BIRD Lab) and the Ministry of Health (Trinidad), with the ultimate goal of supporting a pilot clinical study.

**Core design principles:**
- **Accessibility First** — Minimum 18sp font sizes, high-contrast colour palette, 48dp touch targets (IEC 62366 compliant)
- **100% Offline Operation** — All data processing and AI inference run on-device with no internet dependency (critical for rural connectivity)
- **Zero-Cost Operation** — No API costs, subscriptions, or cloud dependencies
- **Data Privacy** — All patient data stored locally with AES-256 encryption; no central server (HIPAA avoidance strategy)

---

## 2. Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.10+ (Dart) | Cross-platform mobile development |
| Database | Drift (SQLite ORM) + SQLCipher | Typed local storage with AES-256 encryption |
| AI — Image Recognition | Google ML Kit Image Labeling | Offline on-device food photo classification |
| AI — Text Recognition | Google ML Kit Text Recognition | Offline OCR for nutrition label scanning |
| AI — Barcode Scanning | Google ML Kit Barcode Scanning | Offline product barcode identification |
| Food Database | USDA FoodData Central (SR Legacy) | Pre-populated 7,803-item offline nutritional reference |
| Image Capture | Image Picker | Camera and gallery access |
| Typography | Google Fonts (Poppins) | Accessible, consistent typography |
| Permissions | Permission Handler | Runtime permission management |
| Key Storage | SharedPreferences | Encryption key and onboarding state persistence |

---

## 3. System Architecture

```
+----------------------------------------------------------+
|                    PRESENTATION LAYER                     |
|  Login > Onboarding Flow > Main Dashboard (5 Tab Layout) |
|  [Home] [Glucose] [Food AI] [Reminders] [Emergency]      |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|                    BUSINESS LOGIC LAYER                   |
|  Nutrition Label Parser | ML Kit Services | Search Engine |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|                    DATA LAYER (Encrypted)                 |
|  Drift ORM > SQLCipher (AES-256)                         |
|  Tables: Logs | LocalFoods | CustomFoods | MealLogs      |
+---------------------------+------------------------------+
                            |
+---------------------------v------------------------------+
|                   ON-DEVICE AI LAYER                      |
|  ML Kit Image Labeling  (food photo classification)      |
|  ML Kit Text Recognition (nutrition label OCR)           |
|  ML Kit Barcode Scanning (product identification)        |
+----------------------------------------------------------+
```

---

## 4. Database Schema (Drift/SQLite — Encrypted)

The database uses SQLCipher for AES-256 encryption at rest. The encryption key is generated once at first launch and stored securely on-device.

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

DiaMetrics implements a fully offline, hybrid AI pipeline for food logging. All ML Kit models are bundled with the application and execute on-device without network access.

### 5.1 Camera-Based Food Recognition
1. User captures a photo of their meal via the in-app camera.
2. The image is processed by **Google ML Kit Image Labeling** on-device.
3. ML Kit returns confidence-scored labels (e.g., "Rice", "Chicken", "Curry").
4. Labels are matched against the 7,803-item local SQLite database using SQL `LIKE` queries.
5. Matching foods with their carbohydrate values are presented to the user for confirmation and logging.

### 5.2 Text-Based Food Search
1. User types a food name into the search bar.
2. A real-time SQL `LIKE` query searches both `custom_foods` (user-added, checked first) and `local_foods` (USDA reference database).
3. Results are displayed with carbohydrate values; tapping a result logs it as a meal.

### 5.3 Nutrition Label Scanner (OCR)
1. User photographs a Nutrition Facts panel on product packaging.
2. **Google ML Kit Text Recognition** extracts all visible text from the image on-device.
3. A custom `NutritionLabelParser` utility class applies regex pattern matching to extract:
   - Serving Size
   - Calories
   - Total Carbohydrates
   - Total Fat, Protein, Sugars, Fiber, Sodium
4. Extracted values auto-fill the "Add Custom Food" dialog for user confirmation and permanent storage.

### 5.4 Barcode Scanning
1. User scans a product barcode using **Google ML Kit Barcode Scanning**.
2. The barcode value is queried against the `custom_foods` table.
3. If found: the stored nutritional information is immediately used for logging.
4. If not found: the user is prompted to add the product manually (or scan the nutrition label), creating a permanent entry for future scans.

---

## 6. Application Screens

| Screen | File | Description |
|--------|------|-------------|
| Login | `login_screen.dart` | Sign-in with "Continue as Guest" option |
| Personal Info | `personal_info_screen.dart` | Name, age, contact details |
| Health Info | `health_info_screen.dart` | Diabetes type, insulin use, target range |
| Medical Settings | `medical_settings_screen.dart` | Medication details, doctor info |
| Permissions | `permissions_screen.dart` | Runtime permission requests |
| Home Dashboard | `home_screen.dart` | Overview with mascot, status cards, recent logs |
| Glucose Logging | `glucose_log_screen.dart` | Blood glucose value entry with context tags |
| Food Recording | `add_food_screen.dart` | AI-powered food logging (Camera, Gallery, Barcode, Text, Custom, OCR) |
| Statistics | `statistics_screen.dart` | Charts and trends |
| Reminders | `reminders_screen.dart` | Medication and glucose check reminders |
| Emergency | `emergency_screen.dart` | Emergency contacts and hypo/hyperglycemia thresholds |
| Circle Management | `circle_management_screen.dart` | Caregiver/family circle configuration |
| Debug | `debug_screen.dart` | Development-only database inspection |

---

## 7. Accessibility Compliance

DiaMetrics is designed for elderly users (60+) who may have visual impairments, motor skill challenges, or low technical literacy.

| Requirement | Implementation |
|-------------|---------------|
| Minimum font size | 18sp body text, 24sp headings (Poppins Medium) |
| Touch target size | All interactive elements minimum 48 x 48 dp |
| Colour contrast | High-contrast palette (Black/White/Cyan) with distinct colour-coded alerts |
| Colour safety | Red (#D32F2F) for critical, Green (#388E3C) for normal, Navy (#003366) for actions |
| Screen reader support | Semantic labels on all widgets for TalkBack/VoiceOver |
| Typography scaling | No fixed-height containers; uses Expanded/Flexible layouts |
| Component spacing | Minimum 16dp padding between interactive elements |

---

## 8. Security Implementation

| Feature | Technology | Detail |
|---------|-----------|--------|
| Database Encryption | SQLCipher (AES-256-CBC) | All patient data encrypted at rest |
| Key Generation | Dart `Random.secure()` | 32-character cryptographically random key |
| Key Storage | SharedPreferences (device-local) | Key never transmitted over network |
| Data Locality | 100% on-device | No cloud storage, no server communication |
| Privacy Compliance | HIPAA avoidance by design | No central server stores patient data |

---

## 9. Build & Compatibility

| Parameter | Value |
|-----------|-------|
| Flutter SDK | 3.10+ |
| Dart SDK | ^3.10.8 |
| Android minSdk | 21 (Android 5.0 Lollipop) |
| Android targetSdk | 35 (Android 16) |
| Database schema version | 2 |
| Offline food database | 7,803 items (USDA SR Legacy + Trinidadian foods) |
| Total dependencies | 12 production packages |
| Analysis status | 0 errors, 0 warnings |

---

## 10. Current Status & Remaining Work

### Completed
- [x] Theme system and accessibility widgets (BigButton, GlassyCard, SeniorTextField)
- [x] Onboarding flow (Login, Personal Info, Health Info, Medical Settings, Permissions)
- [x] Main dashboard with 5-tab navigation layout
- [x] Glucose logging with context tags
- [x] AES-256 database encryption (SQLCipher)
- [x] Offline food database (7,803 USDA + Trinidadian items)
- [x] AI-powered camera food recognition (ML Kit Image Labeling)
- [x] Barcode scanning for custom food lookup
- [x] Nutrition label OCR scanner (ML Kit Text Recognition)
- [x] Text-based food search against local database
- [x] Custom food entry with manual and scanned inputs
- [x] Meal logging with carb estimates

### Remaining
- [ ] Cloud AI integration for enhanced food analysis accuracy (when online)
- [ ] Sync manager for pending offline data
- [ ] Google Drive backup functionality
- [ ] Statistics charts and trend visualization
- [ ] CSV/PDF export for clinician review
