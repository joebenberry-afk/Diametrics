# Changelog

All notable changes to DiaMetrics are documented here.
This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-04-10

### Features

#### Glucose Management
- Manual glucose logging with context tags: Morning Fasting, Before Meal, 30 / 60 / 120 / 180 min After Meal, Bedtime, and General
- Glucose history view showing all readings newest-first, with swipe-to-delete and an undo snackbar
- Real-time dashboard alerts for high, low, and critical glucose readings based on the user's configured target range
- Time-in-Range percentage and estimated HbA1c (ADAG formula) displayed in the Trends view; HbA1c requires approximately 90 days of data and is shown as "—" for shorter ranges by design

#### Meal Logging
- Macro logging wizard capturing carbohydrates, protein, fat, and calories
- AI-powered food image analysis — point the camera at any meal and Gemini Vision returns automatic macro estimates, enriched against a local food database
- Barcode scanner — scan packaged food barcodes to auto-fill nutrition data fetched from the Open Food Facts database
- Adjustable meal modifiers: alcohol content, caffeine, fibre, liquid form, and post-exercise state — each modifier adjusts the glucose response projection accordingly

#### Glucose Projection
- Hovorka Phase 1 blood glucose projection algorithm produces a 3-hour post-meal glucose curve from the entered macros and the user's body weight
- Insulin-on-Board (IOB) calculation using rapid-acting insulin doses from the last 4 hours with linear decay over a configurable Duration of Insulin Action window
- Confidence band on the projection chart that narrows as the app accumulates personal response data
- Adaptive Extended Kalman Filter (EKF) tuning — the algorithm automatically calibrates absorption parameters to the user's metabolism over time without overwriting the base user profile
- Caribbean food heuristics — specialised gut absorption profiles for regional staple foods including dasheen, doubles, roti, and similar items

#### Medication Logging
- Log rapid-acting insulin, long-acting insulin, and oral medication (pills) from a single wizard
- Dosage tracking with dynamic units: insulin units for injectable types, pill count for oral medication
- Medication history view with swipe-to-delete and undo

#### Historical Trends
- Multi-overlay glucose chart with 7-day, 30-day, and 90-day time range selectors
- Meal log markers and rapid-acting insulin dose markers overlaid on the glucose chart
- Summary statistics per selected range: average glucose, Time-in-Range percentage, and estimated HbA1c
- Full scrollable glucose log list, newest entry first

#### Onboarding
- Multi-step onboarding wizard: welcome screen, demographics (name, age, gender, height, weight), diabetes information (type, diagnosis year), medication and treatment details, and glucose target configuration
- All onboarding data is saved to the local encrypted user profile before the main app is shown

#### Profile and Settings
- Full user profile editing: name, age, gender, height, weight, diabetes type, diagnosis year
- Preferred glucose unit (mg/dL or mmol/L) applied consistently across all views, charts, and alerts
- Configurable low and high glucose target range used for dashboard alerts, chart reference bands, and Time-in-Range calculation
- Treatment flags: insulin pump use, continuous glucose monitor (CGM) use, and Duration of Insulin Action
- Emergency contact configuration accessible from both the dashboard and settings

#### Security and Privacy
- All health data (glucose readings, meals, medications, user profile) is stored entirely on-device using AES-256 SQLCipher-encrypted SQLite
- Biometric authentication (fingerprint or face ID) locks the entire app after 1 minute in the background and on every cold start
- No health data is transmitted to any external server; food images sent for AI analysis are the only data that leaves the device, and only when the user explicitly triggers the camera feature
- Credentials and secure tokens managed via `flutter_secure_storage`

#### Accessibility
- Designed with elderly users as the primary audience: minimum 14 sp body text, large tap targets (44 x 44 px minimum), and generous spacing throughout
- High-contrast colour scheme derived from a strict design token system (`AppThemeTokens`) — no ad-hoc colour values anywhere in the codebase
- Screen reader semantic labels on all interactive elements and data displays

### Known Issues

The following issues are known at the time of the 1.0.0 release and are scheduled for resolution in 1.0.1.

1. **Duplicate emergency contacts route** — The emergency contacts screen is registered at two separate routes (`/dashboard/emergency-contacts` and `/settings/emergency-contacts`). Both routes function correctly; consolidation to a single canonical route is pending.

2. **`sqflite` listed as unused dependency** — `sqflite` is declared in `pubspec.yaml` as a remnant of a previous database architecture. It is not used at runtime and has no functional impact. It will be removed from `pubspec.yaml` in 1.0.1.

3. **Height and weight input is metric only** — The onboarding and settings screens accept height in centimetres and weight in kilograms with no option for imperial units. Imperial unit support (feet/inches, pounds/stones) is planned for a future release.

4. **Activity card shows placeholder step data** — The Activity card on the dashboard displays static step count data. Live pedometer integration via the `pedometer` package is partially wired but not yet active. Real-time step tracking will be enabled in a future release.

5. **Swipe-to-delete is the only delete gesture in history views** — There is no visible delete button on log entries. Users must swipe left to reveal the delete action. A long-press context menu providing an explicit delete option will be added in 1.0.1 to improve discoverability.

6. **HbA1c estimate shown only for the 90-day range** — The ADAG formula used to estimate HbA1c is only meaningful when approximately 90 days of glucose data are available. The value is intentionally shown as "—" for the 7-day and 30-day range selections.
