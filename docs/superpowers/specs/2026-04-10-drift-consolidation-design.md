# DiaMetrics 1.0 — Drift Consolidation & Trends View

**Date:** 2026-04-10  
**Status:** Approved

---

## Goal

Consolidate all app data into the single encrypted Drift database (`app.db`, SQLCipher AES-256), retire the unencrypted raw SQLite layer (`diametrics_v1.db` + `DatabaseHelper`), migrate existing user data automatically, and add a glucose history screen with overlaid meal/medication markers.

---

## Background

The app currently has two SQLite databases:

| Database | File | Encrypted | Tables |
|---|---|---|---|
| Drift ORM | `app.db` | ✅ SQLCipher | `LocalFoods`, `CustomFoods`, `MealLogs` (diary), `N5kIngredients` |
| Raw SQLite | `diametrics_v1.db` | ❌ | `glucose_logs`, `meal_logs`, `medication_logs`, `user_profiles` |

Health data (glucose readings, meals, medications, user profile) is unencrypted. This migration moves it into `app.db`.

---

## Architecture

### Single Database After Migration

```
app.db (SQLCipher, AES-256)
├── Food Layer (unchanged)
│   ├── LocalFoods
│   ├── CustomFoods
│   ├── MealLogs          ← photo/diary meal log (unchanged)
│   └── N5kIngredients
└── Health Layer (new — schema v5)
    ├── GlucoseLogs
    ├── MealMacroLogs     ← macro-based meal log for projection
    ├── MedicationLogs
    └── UserProfiles
```

### Repository Layer (unchanged interfaces)

`UserRepository` and `HealthDataRepository` keep identical method signatures. All callers (ViewModels, services) are untouched. Only the internals change: raw SQL → Drift query builder.

---

## Drift Schema Changes

### Version bump: 4 → 5

`onUpgrade` creates the 4 new health tables when upgrading from v4 to v5.

### New Table: `GlucoseLogs`

```dart
class GlucoseLogs extends Table {
  TextColumn get id => text()();                          // UUID, PRIMARY KEY
  RealColumn get value => real()();
  TextColumn get unit => text()();                        // 'mg/dL' | 'mmol/L'
  TextColumn get context => text()();                     // fasting | pre_meal | post_meal_30 | post_meal_120 | bedtime | night_time
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### New Table: `MealMacroLogs`

Renamed from `meal_logs` to avoid collision with the existing Drift `MealLogs` (photo diary) table.

```dart
class MealMacroLogs extends Table {
  TextColumn get id => text()();                          // UUID, PRIMARY KEY
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get name => text().nullable()();
  RealColumn get carbohydrates => real()();
  RealColumn get dietaryFiber => real().withDefault(const Constant(0.0))();
  RealColumn get proteins => real()();
  RealColumn get fats => real()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  BoolColumn get containsAlcohol => boolean().withDefault(const Constant(false))();
  BoolColumn get containsCaffeine => boolean().withDefault(const Constant(false))();
  TextColumn get mealType => text()();                    // breakfast | lunch | dinner | snack
  TextColumn get foodFormFactor => text().withDefault(const Constant('standard'))();
  BoolColumn get postExercise => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### New Table: `MedicationLogs`

```dart
class MedicationLogs extends Table {
  TextColumn get id => text()();                          // UUID, PRIMARY KEY
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get medicationType => text()();              // rapid_acting_insulin | long_acting_insulin | pill
  TextColumn get insulinType => text()();                 // 'Humalog / NovoLog' default
  TextColumn get name => text().nullable()();
  RealColumn get units => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### New Table: `UserProfiles`

```dart
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  RealColumn get targetWeightKg => real().nullable()();
  TextColumn get diabetesType => text()();
  IntColumn get diagnosisYear => integer()();
  TextColumn get preferredGlucoseUnit => text()();
  BoolColumn get usesInsulin => boolean().withDefault(const Constant(false))();
  BoolColumn get usesPills => boolean().withDefault(const Constant(false))();
  BoolColumn get usesCgm => boolean().withDefault(const Constant(false))();
  RealColumn get targetGlucoseMin => real()();
  RealColumn get targetGlucoseMax => real()();
  RealColumn get metabolicClearanceRate => real().withDefault(const Constant(0.010))();
  RealColumn get insulinSensitivityFactor => real().withDefault(const Constant(50.0))();
  RealColumn get absorptionDelayBase => real().withDefault(const Constant(40.0))();
  IntColumn get tuningMealCount => integer().withDefault(const Constant(0))();
  RealColumn get fastingSetpoint => real().withDefault(const Constant(90.0))();
  TextColumn get insulinCategory => text().withDefault(const Constant('standard_rapid'))();
  RealColumn get insulinDiaMinutes => real().withDefault(const Constant(240.0))();
  RealColumn get ekfCovP1 => real().withDefault(const Constant(1.0))();
  RealColumn get ekfCovISF => real().withDefault(const Constant(1.0))();
  RealColumn get ekfCovTMax => real().withDefault(const Constant(1.0))();
  BoolColumn get hasAgreedToDisclaimer => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### `@DriftDatabase` annotation update

Add the 4 new tables to the `tables` list in `lib/database/database.dart`:

```dart
@DriftDatabase(tables: [
  LocalFoods, CustomFoods, MealLogs, N5kIngredients,  // existing
  GlucoseLogs, MealMacroLogs, MedicationLogs, UserProfiles,  // new
])
class AppDatabase extends _$AppDatabase { ... }
```

### Migration callback

```dart
schemaVersion: 5,
migration: MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 5) {
      await m.createTable(glucoseLogs);
      await m.createTable(mealMacroLogs);
      await m.createTable(medicationLogs);
      await m.createTable(userProfiles);
    }
  },
),
```

---

## Repository Rewrites

### `UserRepository` (`lib/repositories/user_repository.dart`)

Depends on `AppDatabase` via `getIt<AppDatabase>()`.

| Method | Implementation |
|---|---|
| `saveProfile(UserProfile)` | `into(db.userProfiles).insertOnConflictUpdate(profileToCompanion(profile))` |
| `getProfile()` | `(select(db.userProfiles)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])..limit(1)).getSingleOrNull()` → map to `UserProfile` |

Mapping helpers: `_toCompanion(UserProfile) → UserProfilesCompanion` and `_fromRow(UserProfile) → UserProfile` (Drift row → Freezed model).

### `HealthDataRepository` (`lib/repositories/health_data_repository.dart`)

Depends on `AppDatabase` via `getIt<AppDatabase>()`.

| Method | Drift Implementation |
|---|---|
| `getGlucoseLogs()` | `select(db.glucoseLogs).get()` → map rows to `GlucoseLog` |
| `addGlucoseLog(GlucoseLog)` | `into(db.glucoseLogs).insert(toCompanion(log))` |
| `getRecentGlucoseByContext(context, within)` | `(select(db.glucoseLogs)..where((t) => t.context.equals(context) & t.timestamp.isBiggerThanValue(cutoff))..orderBy(...)..limit(1)).getSingleOrNull()` |
| `getMealLogs()` | `select(db.mealMacroLogs).get()` → map to `MealLog` |
| `addMealLog(MealLog)` | `into(db.mealMacroLogs).insert(toCompanion(log))` |
| `getMedicationLogs()` | `select(db.medicationLogs).get()` → map to `MedicationLog` |
| `getRecentMedicationLogs(within)` | `(select(db.medicationLogs)..where((t) => t.timestamp.isBiggerThanValue(cutoff))..orderBy(...)).get()` |
| `addMedicationLog(MedicationLog)` | `into(db.medicationLogs).insert(toCompanion(log))` |

---

## One-Time Data Migration

### `LegacyMigrationService` (`lib/services/legacy_migration_service.dart`)

Called from `main.dart` before `runApp`, after `configureDependencies()`.

```dart
class LegacyMigrationService {
  static const _migratedKey = 'legacy_migrated';

  static Future<void> runIfNeeded(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return;

    final dbPath = join(await getDatabasesPath(), 'diametrics_v1.db');
    if (!await File(dbPath).exists()) {
      await prefs.setBool(_migratedKey, true);
      return;
    }

    // Open old DB read-only via sqflite
    final oldDb = await openDatabase(dbPath, readOnly: true);
    try {
      await _migrateGlucoseLogs(oldDb, db);
      await _migrateMealLogs(oldDb, db);
      await _migrateMedicationLogs(oldDb, db);
      await _migrateUserProfile(oldDb, db);
    } finally {
      await oldDb.close();
    }

    await File(dbPath).delete();
    await prefs.setBool(_migratedKey, true);
  }
}
```

Each `_migrate*` method reads all rows from the old table and bulk-inserts into Drift using `insertAll` with `InsertMode.insertOrIgnore` (idempotent — safe to re-run if interrupted).

Column mapping: SQLite `INTEGER 0/1` → Dart `bool`; SQLite `TEXT` ISO8601 → `DateTime.parse()`.

---

## Trends View

### New files

| File | Purpose |
|---|---|
| `lib/views/trends/trends_view.dart` | Main screen |
| `lib/viewmodels/trends_viewmodel.dart` | `AsyncNotifierProvider<TrendsViewModel, TrendsData>` |

### `TrendsData` model (`lib/models/trends_data.dart`)

```dart
@freezed
class TrendsData with _$TrendsData {
  const factory TrendsData({
    required List<GlucoseLog> glucoseLogs,
    required List<MealLog> mealLogs,
    required List<MedicationLog> medicationLogs,
  }) = _TrendsData;
}
```

### `TrendsViewModel` (`lib/viewmodels/trends_viewmodel.dart`)

```dart
final selectedRangeProvider = StateProvider<int>((ref) => 7); // days

final trendsProvider = AsyncNotifierProvider<TrendsViewModel, TrendsData>(
  TrendsViewModel.new,
);

class TrendsViewModel extends AsyncNotifier<TrendsData> {
  @override
  Future<TrendsData> build() async {
    final days = ref.watch(selectedRangeProvider);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final repo = ref.read(healthDataRepositoryProvider);
    final glucose = await repo.getGlucoseLogs();
    final meals = await repo.getMealLogs();
    final meds = await repo.getMedicationLogs();
    return TrendsData(
      glucoseLogs: glucose.where((g) => g.timestamp.isAfter(cutoff)).toList(),
      mealLogs: meals.where((m) => m.timestamp.isAfter(cutoff)).toList(),
      medicationLogs: meds.where((m) => m.timestamp.isAfter(cutoff)).toList(),
    );
  }
}
```

### `TrendsView` layout

```
TrendsView (ConsumerWidget)
├── AppBar: "Glucose Trends"
├── Row: [7D] [30D] [90D] chips — tapping updates selectedRangeProvider
├── SizedBox(height: screenHeight * 0.4)
│   └── LineChart (fl_chart)
│       ├── glucose spots: FlSpot(minutesSinceStart, value)
│       ├── target band: RangeAnnotation horizontal between min/max
│       ├── meal markers: VerticalLine at meal timestamps (green triangle)
│       └── medication markers: VerticalLine at med timestamps (orange triangle)
├── Padding
│   └── Row: [Avg: X mg/dL] [In Range: X%] [Est. HbA1c: X%]
└── Expanded
    └── ListView of GlucoseLog tiles (most recent first)
```

### Stats calculations

| Stat | Formula |
|---|---|
| Average glucose | `mean(glucoseLogs.map((g) => g.value))` |
| Time in range % | `logs where value ∈ [targetMin, targetMax] / total logs × 100` |
| Est. HbA1c | `(avgGlucose_mgdL + 46.7) / 28.7` (ADAG formula) |

Values for mmol/L users: convert to mg/dL before calculation (`× 18.0182`), display converted back.

### Navigation

Add a chart icon button to the `DashboardView` AppBar that navigates to `TrendsView`.

---

## Widget Test Fix

`test/widget_test.dart`: wrap `DiametricsApp` in `ProviderScope`:

```dart
await tester.pumpWidget(const ProviderScope(child: DiametricsApp()));
```

---

## Files Changed / Created

| Action | File |
|---|---|
| **Modify** | `lib/database/database.dart` — add 4 tables + schema v5 migration |
| **Modify** | `lib/database/db_instance.dart` — schema version bump |
| **Modify** | `lib/repositories/user_repository.dart` — Drift implementation |
| **Modify** | `lib/repositories/health_data_repository.dart` — Drift implementation |
| **Create** | `lib/services/legacy_migration_service.dart` |
| **Create** | `lib/models/trends_data.dart` + generated files |
| **Create** | `lib/viewmodels/trends_viewmodel.dart` |
| **Create** | `lib/views/trends/trends_view.dart` |
| **Modify** | `lib/views/dashboard/dashboard_view.dart` — add Trends nav |
| **Modify** | `lib/main.dart` — call `LegacyMigrationService.runIfNeeded()` |
| **Delete** | `lib/core/database/database_helper.dart` |
| **Modify** | `test/widget_test.dart` — ProviderScope wrap |

---

## Out of Scope

- Cloud sync (`synced` columns dropped — deferred to post-1.0)
- Removing `sqflite` from `pubspec.yaml` — kept for `LegacyMigrationService`; can be dropped in a follow-up once migration has shipped
- Medication detail screen, CGM integration, notification reminders
