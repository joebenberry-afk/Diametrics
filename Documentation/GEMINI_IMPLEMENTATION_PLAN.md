# DiaMetrics — Gemini Implementation Plan
## Features 1–6: Dashboard Live Data, History Views, Glucose Trend Graph, Alerts, Analytics, Medication Reminders

---

## 0. CONTEXT — Read This First

You are working on **DiaMetrics**, a Flutter diabetes management app. The codebase follows strict MVVM with Riverpod state management. You must follow every convention below exactly.

### Tech Stack
- Flutter + Dart (null-safe)
- **State management:** `flutter_riverpod ^2.6.1` — `AsyncNotifierProvider` for data, `StateNotifierProvider` for forms
- **Database:** Raw SQLite via `sqflite` through `DatabaseHelper` singleton at `lib/core/database/database_helper.dart`
- **Models:** `@freezed` from `freezed_annotation` — run `dart run build_runner build --delete-conflicting-outputs` after every model change
- **DI:** `get_it` + `injectable` for services in `lib/src/`; Riverpod providers for app-layer state
- **Icons:** Material `Icons.*` (existing code uses this; `lucide_icons` package also available)
- **Font:** Inter via `google_fonts`

### Design Tokens — NEVER hardcode colors or sizes
```dart
// Import: import '../../core/theme/app_tokens.dart';
AppThemeTokens.brandPrimary       // Color(0xFF1B263B) — Deep Navy
AppThemeTokens.brandSecondary     // Color(0xFF415A77) — Slate Blue
AppThemeTokens.brandAccent        // Color(0xFF778DA9) — Steel Blue
AppThemeTokens.brandSuccess       // Color(0xFF2D6A4F) — Deep Green
AppThemeTokens.brandSuccessLight  // Color(0xFF52B788)
AppThemeTokens.bgSurface          // Color(0xFFF8F9FA)
AppThemeTokens.bgBackground       // Color(0xFFE0E1DD)
AppThemeTokens.bgSurfaceDark      // Color(0xFF0D1B2A)
AppThemeTokens.bgBackgroundDark   // Color(0xFF1B263B)
AppThemeTokens.textPrimary        // Color(0xFF0D1B2A)
AppThemeTokens.textSecondary      // Color(0xFF415A77)
AppThemeTokens.textPrimaryInverse // Color(0xFFE0E1DD)
AppThemeTokens.error              // Color(0xFF780000) — Deep Red
AppThemeTokens.warning            // Color(0xFFFFB703) — Amber
AppThemeTokens.spaceXs = 4.0
AppThemeTokens.spaceSm = 8.0
AppThemeTokens.spaceMd = 16.0
AppThemeTokens.spaceLg = 24.0
AppThemeTokens.spaceXl = 32.0
AppThemeTokens.radiusSm = 8.0
AppThemeTokens.radiusMd = 12.0
AppThemeTokens.radiusLg = 24.0
AppThemeTokens.radiusFull = 100.0
AppThemeTokens.minTapTarget = 56.0
```

### Existing Riverpod Providers (already in codebase — use these, don't recreate)
```dart
// lib/viewmodels/health_data_viewmodel.dart
final healthDataRepositoryProvider = Provider<HealthDataRepository>((ref) => HealthDataRepository());
final glucoseLogsProvider = AsyncNotifierProvider<GlucoseLogsViewModel, List<GlucoseLog>>(GlucoseLogsViewModel.new);
final mealLogsProvider = AsyncNotifierProvider<MealLogsViewModel, List<MealLog>>(MealLogsViewModel.new);
final medicationLogsProvider = AsyncNotifierProvider<MedicationLogsViewModel, List<MedicationLog>>(MedicationLogsViewModel.new);

// lib/viewmodels/profile_viewmodel.dart
final userProfileProvider = AsyncNotifierProvider<ProfileViewModel, UserProfile?>(ProfileViewModel.new);
```

### Existing Models

**GlucoseLog** (`lib/models/glucose_log.dart`):
```
id: String, timestamp: DateTime, value: double, unit: String (mg/dL|mmol/L),
context: String (fasting|pre_meal|post_meal_30|post_meal_120|bedtime|night_time),
notes: String?, isSynced: bool
```

**MealLog** (`lib/models/meal_log.dart`):
```
id: String, timestamp: DateTime, name: String?, carbohydrates: double,
dietaryFiber: double, proteins: double, fats: double, calories: double,
containsAlcohol: bool, containsCaffeine: bool,
mealType: String (breakfast|lunch|dinner|snack), notes: String?, isSynced: bool
```

**MedicationLog** (`lib/models/medication_log.dart`):
```
id: String, timestamp: DateTime,
medicationType: String (rapid_acting_insulin|long_acting_insulin|pill),
name: String?, units: double, notes: String?, isSynced: bool
```

**UserProfile** (`lib/models/user_profile.dart`):
```
id: String, name: String, age: int, gender: String, heightCm: double,
weightKg: double, targetWeightKg: double?, diabetesType: String,
diagnosisYear: int, preferredGlucoseUnit: String,
usesInsulin: bool, usesPills: bool, usesCgm: bool,
targetGlucoseMin: double (default 70.0), targetGlucoseMax: double (default 180.0),
hasAgreedToDisclaimer: bool, createdAt: DateTime, updatedAt: DateTime
```

### HealthDataRepository — Existing Methods
```dart
// lib/repositories/health_data_repository.dart
Future<List<GlucoseLog>> getGlucoseLogs()
Future<void> addGlucoseLog(GlucoseLog log)
Future<GlucoseLog?> getRecentGlucoseByContext(String context, Duration within)
Future<List<MealLog>> getMealLogs()
Future<void> addMealLog(MealLog log)
Future<List<MedicationLog>> getMedicationLogs()
Future<List<MedicationLog>> getRecentMedicationLogs(Duration within)
Future<void> addMedicationLog(MedicationLog log)
```

### Existing View Pattern (use ConsumerWidget for read-only, ConsumerStatefulWidget for forms)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';

class MyView extends ConsumerWidget {
  const MyView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(glucoseLogsProvider);
    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (logs) => /* your UI */,
    );
  }
}
```

### Current `lib/views/dashboard/dashboard_view.dart` — What Needs To Change
The four `MetricCard` widgets have **hardcoded values** that need to be replaced with live data:
- Glucose card: `value: '104'`, `trendData: const [95, 102, 108, 104, 110, 104]`  → latest glucose from DB
- Meals card: `value: '1,840'` → total kcal today from DB
- Medication card: `value: '2'` → count of doses today from DB
- Activity card: hardcoded step count → remove or keep as placeholder

The "Recent Activity" section has two hardcoded `ListTile` entries → replace with latest 5 entries across all log types sorted by timestamp desc.

The `MetricCard.onTap` callbacks are all empty `() {}` → wire them to navigate to history screens.

---

## FEATURE 1 — Dashboard Live Data

### 1.1 New Riverpod Providers (add to `lib/viewmodels/health_data_viewmodel.dart`)

Add these four computed providers **at the bottom** of the existing file:

```dart
/// Latest glucose reading (most recent GlucoseLog, any context).
final latestGlucoseProvider = Provider<AsyncValue<GlucoseLog?>>((ref) {
  return ref.watch(glucoseLogsProvider).whenData((logs) {
    if (logs.isEmpty) return null;
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.first;
  });
});

/// Today's total calories from MealLogs.
final todayCaloriesProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(mealLogsProvider).whenData((logs) {
    final today = DateTime.now();
    return logs
        .where((l) =>
            l.timestamp.year == today.year &&
            l.timestamp.month == today.month &&
            l.timestamp.day == today.day)
        .fold(0.0, (sum, l) => sum + l.calories);
  });
});

/// Today's medication dose count.
final todayDoseCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(medicationLogsProvider).whenData((logs) {
    final today = DateTime.now();
    return logs
        .where((l) =>
            l.timestamp.year == today.year &&
            l.timestamp.month == today.month &&
            l.timestamp.day == today.day)
        .length;
  });
});

/// Last 5 log entries across all types, sorted newest first.
/// Each entry is a map with keys: type (String), label (String), subtitle (String), timestamp (DateTime), icon (IconData), color (Color).
final recentActivityProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final glucoseAsync = ref.watch(glucoseLogsProvider);
  final mealsAsync = ref.watch(mealLogsProvider);
  final medsAsync = ref.watch(medicationLogsProvider);

  if (glucoseAsync.isLoading || mealsAsync.isLoading || medsAsync.isLoading) {
    return const AsyncLoading();
  }

  final entries = <Map<String, dynamic>>[];

  glucoseAsync.valueOrNull?.forEach((g) => entries.add({
        'type': 'glucose',
        'label': '${g.value.toStringAsFixed(0)} ${g.unit}',
        'subtitle': g.context.replaceAll('_', ' '),
        'timestamp': g.timestamp,
        'icon': Icons.bloodtype_outlined,
        'color': AppThemeTokens.brandPrimary,
      }));

  mealsAsync.valueOrNull?.forEach((m) => entries.add({
        'type': 'meal',
        'label': m.name ?? '${m.mealType[0].toUpperCase()}${m.mealType.substring(1)}',
        'subtitle': '${m.carbohydrates.toStringAsFixed(0)}g carbs • ${m.calories.toStringAsFixed(0)} kcal',
        'timestamp': m.timestamp,
        'icon': Icons.restaurant_outlined,
        'color': AppThemeTokens.brandSuccess,
      }));

  medsAsync.valueOrNull?.forEach((med) => entries.add({
        'type': 'medication',
        'label': med.name ?? med.medicationType.replaceAll('_', ' '),
        'subtitle': '${med.units.toStringAsFixed(1)} units',
        'timestamp': med.timestamp,
        'icon': Icons.medication_outlined,
        'color': AppThemeTokens.brandAccent,
      }));

  entries.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
  return AsyncData(entries.take(5).toList());
});
```

### 1.2 Update `lib/views/dashboard/dashboard_view.dart`

Replace the entire file. Key changes:
1. Add imports for the new providers
2. Watch all four new providers
3. Replace hardcoded MetricCard values with live data
4. Replace hardcoded Recent Activity ListTiles with live data from `recentActivityProvider`
5. Wire MetricCard onTap callbacks to navigate to history views (created in Feature 2)
6. Add out-of-range visual indicator on the Glucose card (red accent if latest glucose is outside `targetGlucoseMin`–`targetGlucoseMax`)

**Glucose MetricCard logic:**
```dart
// Get latest glucose
final latestGlucose = ref.watch(latestGlucoseProvider);
final glucoseValue = latestGlucose.valueOrNull?.value;
final glucoseDisplay = glucoseValue != null
    ? glucoseValue.toStringAsFixed(0)
    : '--';

// Get last 6 readings for trendData
final allGlucose = ref.watch(glucoseLogsProvider).valueOrNull ?? [];
allGlucose.sort((a, b) => a.timestamp.compareTo(b.timestamp));
final trendData = allGlucose.take(6).map((g) => g.value).toList();

// Color: red if out of range, green if in range, primary if no data
final profile = ref.watch(userProfileProvider).valueOrNull;
Color glucoseColor = AppThemeTokens.brandPrimary;
if (glucoseValue != null && profile != null) {
  if (glucoseValue < profile.targetGlucoseMin || glucoseValue > profile.targetGlucoseMax) {
    glucoseColor = AppThemeTokens.error;
  } else {
    glucoseColor = AppThemeTokens.brandSuccess;
  }
}
```

**Calories MetricCard logic:**
```dart
final calories = ref.watch(todayCaloriesProvider).valueOrNull ?? 0.0;
final caloriesDisplay = calories > 0 ? calories.toStringAsFixed(0) : '0';
```

**Medication MetricCard logic:**
```dart
final doseCount = ref.watch(todayDoseCountProvider).valueOrNull ?? 0;
final dosesDisplay = doseCount.toString();
```

**Recent Activity section:**
```dart
final activityAsync = ref.watch(recentActivityProvider);
// For each entry in activityAsync.valueOrNull, render a ListTile with:
//   leading: CircleAvatar with entry['icon'] and entry['color']
//   title: Text(entry['label'])
//   subtitle: Text('${_timeAgo(entry['timestamp'])} • ${entry['subtitle']}')
// If list is empty, show Text('No activity yet. Start logging!')
```

**Time-ago helper (add as private function in the file):**
```dart
String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
```

---

## FEATURE 2 — History / Log Views

Create three new history screens. All three follow the same pattern.

### 2.1 `lib/views/history/glucose_history_view.dart`

**ConsumerWidget**. Full-screen list of all glucose logs.

**AppBar:** "Glucose History" with back button.

**Body:** `ref.watch(glucoseLogsProvider).when(...)` — on data, show a `ListView.builder` of logs sorted newest-first.

**Each list item — `_GlucoseHistoryTile`:**
- Leading: colored circle showing the value (color = green if in range, red if out, amber if borderline)
- Title: `"${log.value.toStringAsFixed(0)} ${log.unit}"`
- Subtitle: `"${log.context.replaceAll('_', ' ')} • ${_formatDate(log.timestamp)}"`
- Trailing: icon chip if notes exist

**In-range logic:** compare `log.value` against `ref.watch(userProfileProvider).valueOrNull?.targetGlucoseMin/Max`. Default to 70/180 if profile not loaded.

**Empty state:** centered column with icon + "No glucose readings yet.\nTap '+' to log your first reading."

**FAB:** same as dashboard — opens glucose wizard.

**Color coding:**
- `< targetGlucoseMin` → `AppThemeTokens.warning` (hypo risk)
- `> targetGlucoseMax` → `AppThemeTokens.error` (hyper)
- Within range → `AppThemeTokens.brandSuccess`

### 2.2 `lib/views/history/meal_history_view.dart`

**ConsumerWidget**. Full-screen list of all meal logs.

**AppBar:** "Meal History"

**Each list item — `_MealHistoryTile`:**
- Leading: `CircleAvatar` with `Icons.restaurant` in `AppThemeTokens.brandSuccess`
- Title: meal name or `"${mealType} meal"` if name is null
- Subtitle: `"${log.carbohydrates.toStringAsFixed(0)}g carbs • ${log.proteins.toStringAsFixed(0)}g protein • ${log.fats.toStringAsFixed(0)}g fat"`
- Trailing: `Text(log.calories > 0 ? '${log.calories.toStringAsFixed(0)} kcal' : '')`
- Below subtitle: `Text(_formatDate(log.timestamp), style: textSecondary)`
- Small chips for alcohol/caffeine if present: amber `FilterChip`-style tags

**Empty state:** "No meals logged yet."

### 2.3 `lib/views/history/medication_history_view.dart`

**ConsumerWidget**. Full-screen list of all medication logs.

**AppBar:** "Medication History"

**Each list item — `_MedicationHistoryTile`:**
- Leading: `CircleAvatar` with `Icons.medication` in `AppThemeTokens.brandAccent`
- Title: `med.name ?? med.medicationType.replaceAll('_', ' ')`
- Subtitle: `"${med.units.toStringAsFixed(1)} units • ${_formatDate(med.timestamp)}"`

**Empty state:** "No medication logged yet."

### 2.4 Shared `_formatDate` helper (add to each file or a shared utils file)
```dart
String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today ${_timeStr(dt)}';
  if (diff.inDays == 1) return 'Yesterday ${_timeStr(dt)}';
  return '${dt.day}/${dt.month}/${dt.year} ${_timeStr(dt)}';
}

String _timeStr(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
```

### 2.5 Wire navigation from dashboard

In `dashboard_view.dart`, update the MetricCard `onTap` callbacks:
```dart
// Glucose card
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlucoseHistoryView())),

// Meals card
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealHistoryView())),

// Medication card
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationHistoryView())),
```

---

## FEATURE 3 — Glucose Trend Graph

### 3.1 `lib/views/history/glucose_trend_view.dart`

**ConsumerWidget**. Accessible from tapping the Glucose MetricCard on the dashboard (replace navigation or add as a second tab/button on `GlucoseHistoryView`).

**Layout:**
```
AppBar: "Glucose Trends" + back button
├── Period selector tabs: [Today | 7 Days | 30 Days]  (Tab bar, no separate Scaffold)
├── Summary row: Avg | Min | Max | Time-in-Range %
├── Trend chart (CustomPainter)
└── ListView of readings (same as GlucoseHistoryView but filtered)
```

**Period selector state:** use a local `StatefulWidget` (or `ConsumerStatefulWidget`) with a `_selectedPeriod` int (0=today, 1=7days, 2=30days).

**Filter logs by period:**
```dart
List<GlucoseLog> _filterByPeriod(List<GlucoseLog> logs, int period) {
  final now = DateTime.now();
  final cutoff = switch (period) {
    0 => DateTime(now.year, now.month, now.day),
    1 => now.subtract(const Duration(days: 7)),
    2 => now.subtract(const Duration(days: 30)),
    _ => now.subtract(const Duration(days: 7)),
  };
  return logs.where((l) => l.timestamp.isAfter(cutoff)).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
}
```

**Summary stats:**
```dart
double avg = filtered.isEmpty ? 0 : filtered.map((l) => l.value).reduce((a, b) => a + b) / filtered.length;
double min = filtered.isEmpty ? 0 : filtered.map((l) => l.value).reduce((a, b) => a < b ? a : b);
double max = filtered.isEmpty ? 0 : filtered.map((l) => l.value).reduce((a, b) => a > b ? a : b);
int inRangeCount = filtered.where((l) => l.value >= targetMin && l.value <= targetMax).length;
double timeInRange = filtered.isEmpty ? 0 : (inRangeCount / filtered.length) * 100;
```

**Summary row widget — 4 tiles in a Row:**
```
[ Avg        ] [ Min        ] [ Max        ] [ TIR        ]
[ 118 mg/dL  ] [ 72 mg/dL   ] [ 195 mg/dL  ] [ 82%        ]
```
Each tile: small `Container` with label + bold value. TIR tile: color green if ≥70%, amber if 50–70%, red if <50%.

**Trend Chart — `_GlucoseTrendChart` (CustomPainter):**

Inputs: `List<GlucoseLog> logs`, `double targetMin`, `double targetMax`.

Drawing steps:
1. Background zones:
   - Below `targetMin`: light red fill
   - `targetMin` to `targetMax`: light green fill (the target band)
   - Above `targetMax`: light red fill
2. Horizontal dashed lines at `targetMin` and `targetMax` in their respective colors
3. X-axis: time scale (0h to 24h for today; date labels for 7/30 days)
4. Y-axis: glucose values, auto-scaled (min of data or 50, max of data or 250), labels every 50 mg/dL
5. Line connecting all data points: `AppThemeTokens.brandPrimary`, stroke 2.5
6. Dots at each data point: filled circle, radius 4, color based on in-range status (green/red/amber)
7. Reserve `60px` left margin for Y-axis labels, `30px` bottom margin for X-axis

Chart size: `SizedBox(height: 220)` inside a `Padding`.

**Empty state:** "No glucose readings for this period."

---

## FEATURE 4 — Out-of-Range Alerts (In-App Banners)

This feature shows a visual alert banner on the dashboard when the most recent glucose reading is outside the patient's target range. No push notifications required — purely in-app UI.

### 4.1 New provider (add to `lib/viewmodels/health_data_viewmodel.dart`)

```dart
enum GlucoseAlertLevel { none, hypo, hyperElevated, hyperHigh }

/// Returns the alert level for the most recent glucose reading against user targets.
final glucoseAlertProvider = Provider<GlucoseAlertLevel>((ref) {
  final latest = ref.watch(latestGlucoseProvider).valueOrNull;
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (latest == null || profile == null) return GlucoseAlertLevel.none;

  final v = latest.value;
  if (v < profile.targetGlucoseMin) return GlucoseAlertLevel.hypo;
  if (v > profile.targetGlucoseMax + 70) return GlucoseAlertLevel.hyperHigh;
  if (v > profile.targetGlucoseMax) return GlucoseAlertLevel.hyperElevated;
  return GlucoseAlertLevel.none;
});
```

### 4.2 `_AlertBanner` widget (add as private class in `dashboard_view.dart`)

```dart
class _AlertBanner extends StatelessWidget {
  final GlucoseAlertLevel level;
  final double glucoseValue;
  final String unit;

  const _AlertBanner({required this.level, required this.glucoseValue, required this.unit});

  @override
  Widget build(BuildContext context) {
    if (level == GlucoseAlertLevel.none) return const SizedBox.shrink();

    final (Color bg, Color text, IconData icon, String message) = switch (level) {
      GlucoseAlertLevel.hypo => (
          const Color(0xFFFFF3CD),
          const Color(0xFF856404),
          Icons.warning_amber_rounded,
          'Low glucose detected: ${glucoseValue.toStringAsFixed(0)} $unit. Consider fast-acting carbohydrates.',
        ),
      GlucoseAlertLevel.hyperElevated => (
          const Color(0xFFFFE4E4),
          AppThemeTokens.error,
          Icons.arrow_upward_rounded,
          'Glucose above target: ${glucoseValue.toStringAsFixed(0)} $unit. Monitor closely.',
        ),
      GlucoseAlertLevel.hyperHigh => (
          AppThemeTokens.error,
          Colors.white,
          Icons.priority_high_rounded,
          'High glucose: ${glucoseValue.toStringAsFixed(0)} $unit. Contact your care team if persistent.',
        ),
      _ => (Colors.transparent, Colors.transparent, Icons.info, ''),
    };

    return Semantics(
      liveRegion: true,
      label: 'Alert: $message',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(color: text.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: text, size: 22),
            const SizedBox(width: AppThemeTokens.spaceSm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.3 Add alert banner to `DashboardView.build()`

Insert the banner **between the AccountCard and the "Health Overview" title**:

```dart
// After AccountCard widget:
const SizedBox(height: AppThemeTokens.spaceSm),

// Alert banner (only visible when needed)
Builder(builder: (context) {
  final alertLevel = ref.watch(glucoseAlertProvider);
  final latestGlucose = ref.watch(latestGlucoseProvider).valueOrNull;
  if (alertLevel == GlucoseAlertLevel.none || latestGlucose == null) {
    return const SizedBox.shrink();
  }
  return _AlertBanner(
    level: alertLevel,
    glucoseValue: latestGlucose.value,
    unit: latestGlucose.unit,
  );
}),

const SizedBox(height: AppThemeTokens.spaceMd),
```

---

## FEATURE 5 — Analytics Summary Card

A "Today's Summary" card on the dashboard showing key stats for today at a glance.

### 5.1 New provider (add to `lib/viewmodels/health_data_viewmodel.dart`)

```dart
class DailySummary {
  final double avgGlucose;
  final double totalCarbs;
  final double totalCalories;
  final int glucoseReadings;
  final int mealsLogged;
  final int dosesLogged;
  final double timeInRangePct; // 0.0 to 100.0

  const DailySummary({
    required this.avgGlucose,
    required this.totalCarbs,
    required this.totalCalories,
    required this.glucoseReadings,
    required this.mealsLogged,
    required this.dosesLogged,
    required this.timeInRangePct,
  });
}

final dailySummaryProvider = Provider<AsyncValue<DailySummary>>((ref) {
  final glucoseAsync = ref.watch(glucoseLogsProvider);
  final mealsAsync = ref.watch(mealLogsProvider);
  final medsAsync = ref.watch(medicationLogsProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;

  if (glucoseAsync.isLoading || mealsAsync.isLoading || medsAsync.isLoading) {
    return const AsyncLoading();
  }

  final today = DateTime.now();
  bool isToday(DateTime dt) =>
      dt.year == today.year && dt.month == today.month && dt.day == today.day;

  final todayGlucose = (glucoseAsync.valueOrNull ?? []).where((l) => isToday(l.timestamp)).toList();
  final todayMeals = (mealsAsync.valueOrNull ?? []).where((l) => isToday(l.timestamp)).toList();
  final todayMeds = (medsAsync.valueOrNull ?? []).where((l) => isToday(l.timestamp)).toList();

  final targetMin = profile?.targetGlucoseMin ?? 70.0;
  final targetMax = profile?.targetGlucoseMax ?? 180.0;

  final avgGlucose = todayGlucose.isEmpty ? 0.0 :
      todayGlucose.map((g) => g.value).reduce((a, b) => a + b) / todayGlucose.length;
  final inRange = todayGlucose.where((g) => g.value >= targetMin && g.value <= targetMax).length;
  final tir = todayGlucose.isEmpty ? 0.0 : (inRange / todayGlucose.length) * 100;
  final totalCarbs = todayMeals.fold(0.0, (sum, m) => sum + m.carbohydrates);
  final totalCalories = todayMeals.fold(0.0, (sum, m) => sum + m.calories);

  return AsyncData(DailySummary(
    avgGlucose: avgGlucose,
    totalCarbs: totalCarbs,
    totalCalories: totalCalories,
    glucoseReadings: todayGlucose.length,
    mealsLogged: todayMeals.length,
    dosesLogged: todayMeds.length,
    timeInRangePct: tir,
  ));
});
```

### 5.2 `_DailySummaryCard` widget (add as private class in `dashboard_view.dart`)

```dart
class _DailySummaryCard extends ConsumerWidget {
  const _DailySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_outlined, size: 18, color: AppThemeTokens.brandPrimary),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Text(
                "Today's Summary",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Could not load summary'),
            data: (s) => s.glucoseReadings == 0 && s.mealsLogged == 0 && s.dosesLogged == 0
                ? const Text(
                    'No data logged today yet.',
                    style: TextStyle(color: AppThemeTokens.textSecondary),
                  )
                : Column(
                    children: [
                      // Time-in-range progress bar
                      if (s.glucoseReadings > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Time in Range',
                                style: TextStyle(fontSize: 13, color: AppThemeTokens.textSecondary)),
                            Text(
                              '${s.timeInRangePct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: s.timeInRangePct >= 70
                                    ? AppThemeTokens.brandSuccess
                                    : s.timeInRangePct >= 50
                                        ? AppThemeTokens.warning
                                        : AppThemeTokens.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (s.timeInRangePct / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppThemeTokens.error.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              s.timeInRangePct >= 70
                                  ? AppThemeTokens.brandSuccess
                                  : s.timeInRangePct >= 50
                                      ? AppThemeTokens.warning
                                      : AppThemeTokens.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppThemeTokens.spaceMd),
                      ],
                      // Stats row
                      Row(
                        children: [
                          _SummaryStatTile(
                            label: 'Avg Glucose',
                            value: s.avgGlucose > 0 ? '${s.avgGlucose.toStringAsFixed(0)}' : '--',
                            unit: 'mg/dL',
                          ),
                          _SummaryStatTile(
                            label: 'Carbs',
                            value: '${s.totalCarbs.toStringAsFixed(0)}',
                            unit: 'g',
                          ),
                          _SummaryStatTile(
                            label: 'Calories',
                            value: s.totalCalories > 0 ? '${s.totalCalories.toStringAsFixed(0)}' : '--',
                            unit: 'kcal',
                          ),
                          _SummaryStatTile(
                            label: 'Readings',
                            value: '${s.glucoseReadings}',
                            unit: 'today',
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _SummaryStatTile({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: AppThemeTokens.textSecondary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppThemeTokens.textSecondary)),
        ],
      ),
    );
  }
}
```

### 5.3 Add summary card to dashboard

Insert `_DailySummaryCard` between the metrics grid and the Recent Activity section:
```dart
const SizedBox(height: AppThemeTokens.spaceLg),
const _DailySummaryCard(),
const SizedBox(height: AppThemeTokens.spaceLg),
// ... Recent Activity section
```

---

## FEATURE 6 — Medication Reminders (Local Notifications)

### 6.1 Add dependency to `pubspec.yaml`

Add under `dependencies:`:
```yaml
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
```

Run `flutter pub get` after adding.

### 6.2 `lib/services/reminder_service.dart` (new file)

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Schedule a daily medication reminder at [hour]:[minute].
  /// [id] must be unique per reminder (use a stable integer).
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Daily reminders to take medication',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
```

### 6.3 Initialize in `lib/main.dart`

Add `await ReminderService.initialize();` inside `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await ReminderService.initialize();   // ADD THIS LINE
  runApp(const ProviderScope(child: DiametricsApp()));
}
```

### 6.4 Reminders section in `lib/views/settings/settings_view.dart`

Add a new `_SectionCard` at the bottom of the settings form (before the final `SizedBox(height: spaceXl)`):

```dart
_SectionCard(
  title: 'Medication Reminders',
  icon: Icons.alarm_outlined,
  isDark: isDark,
  children: [
    _ReminderTimePicker(
      label: 'Morning Reminder',
      reminderId: 1,
    ),
    const Divider(height: 1),
    _ReminderTimePicker(
      label: 'Evening Reminder',
      reminderId: 2,
    ),
  ],
),
```

### 6.5 `_ReminderTimePicker` widget (add as private class in `settings_view.dart`)

```dart
class _ReminderTimePicker extends StatefulWidget {
  final String label;
  final int reminderId;

  const _ReminderTimePicker({required this.label, required this.reminderId});

  @override
  State<_ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<_ReminderTimePicker> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
      if (_enabled) _scheduleReminder();
    }
  }

  void _scheduleReminder() {
    ReminderService.scheduleDailyReminder(
      id: widget.reminderId,
      title: 'Medication Reminder',
      body: 'Time to take your medication. Stay on track!',
      hour: _time.hour,
      minute: _time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        widget.label,
        style: const TextStyle(
          color: AppThemeTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: GestureDetector(
        onTap: _enabled ? _pickTime : null,
        child: Text(
          _enabled ? 'Daily at ${_time.format(context)} — tap to change' : 'Disabled',
          style: TextStyle(
            color: _enabled ? AppThemeTokens.brandPrimary : AppThemeTokens.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
      value: _enabled,
      onChanged: (v) {
        setState(() => _enabled = v);
        if (v) {
          _scheduleReminder();
        } else {
          ReminderService.cancelReminder(widget.reminderId);
        }
      },
      activeThumbColor: AppThemeTokens.brandPrimary,
      activeTrackColor: AppThemeTokens.brandPrimary.withValues(alpha: 0.4),
    );
  }
}
```

---

## IMPLEMENTATION ORDER

Complete each feature fully before starting the next:

1. **Feature 1** — Add 4 providers to `health_data_viewmodel.dart`, rewrite `dashboard_view.dart` to use them.
2. **Feature 2** — Create 3 history view files, update dashboard navigation.
3. **Feature 5** — Add `DailySummary` class + `dailySummaryProvider` to viewmodel, add `_DailySummaryCard` + `_SummaryStatTile` to dashboard.
4. **Feature 4** — Add `glucoseAlertProvider` + `GlucoseAlertLevel` enum, add `_AlertBanner` to dashboard.
5. **Feature 3** — Create `glucose_trend_view.dart`, wire from `GlucoseHistoryView` AppBar action or dashboard Glucose card.
6. **Feature 6** — Add `pubspec.yaml` dep, create `reminder_service.dart`, update `main.dart`, add reminders section to `settings_view.dart`.

After completing ALL features, run:
```bash
flutter analyze --no-fatal-infos
```
Fix every warning and error before considering the work done.

---

## QUALITY REQUIREMENTS

- Every new widget that shows health data must remain stable (no crashes) when lists are empty or providers return null.
- All `AsyncValue.when(...)` calls must include `loading:` and `error:` branches.
- Empty states must show a helpful message, never a blank screen.
- No hardcoded colors or sizes — use `AppThemeTokens` only.
- No hardcoded strings for timestamps — always compute dynamically from `DateTime.now()`.
- All tap targets must be at least `AppThemeTokens.minTapTarget` (56px) in height.
- `Semantics` labels must be added to any interactive element that doesn't have an inherent label (e.g., icon-only buttons, charts).
