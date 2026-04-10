# Drift Consolidation & Trends View Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move all health data (glucose, meal, medication, user profile) from the unencrypted raw SQLite layer into the existing encrypted Drift database, auto-migrate existing user data, retire `DatabaseHelper`, and add a Glucose Trends screen that overlays meals and medications on the glucose chart.

**Architecture:** Four new Drift tables are added to `AppDatabase` (schema v4→v5). `UserRepository` and `HealthDataRepository` are rewritten against Drift with identical public interfaces — no ViewModel or service changes. A one-time `LegacyMigrationService` copies rows from `diametrics_v1.db` into Drift then deletes the old file. `GlucoseTrendView` is replaced by a richer `TrendsView` using `fl_chart` with overlay markers for meals and insulin.

**Tech Stack:** Flutter, Drift 2.x, sqflite (migration only), fl_chart ^0.69.2, Riverpod 2.x, Freezed 3.x, go_router.

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Modify | `lib/database/database.dart` | Add 4 health tables, schema v5 migration |
| Modify | `lib/repositories/user_repository.dart` | Drift-backed implementation |
| Modify | `lib/repositories/health_data_repository.dart` | Drift-backed implementation |
| Create | `lib/services/legacy_migration_service.dart` | One-time old→Drift copy |
| Modify | `lib/main.dart` | Call migration before app starts |
| Delete | `lib/core/database/database_helper.dart` | Retired |
| Create | `lib/viewmodels/trends_viewmodel.dart` | TrendsData + provider |
| Create | `lib/views/trends/trends_view.dart` | Replaces GlucoseTrendView |
| Modify | `lib/views/history/glucose_trend_view.dart` | Replaced — delete after Task 8 |
| Modify | `lib/router/app_router.dart` | Import TrendsView, keep same route |
| Modify | `lib/views/dashboard/dashboard_view.dart` | Add "Trends" icon button |
| Modify | `test/widget_test.dart` | Wrap in ProviderScope |
| Create | `test/database/health_tables_test.dart` | Drift health table CRUD tests |

---

### Task 1: Fix widget test

**Files:**
- Modify: `test/widget_test.dart`

The test calls `tester.pumpWidget(const DiametricsApp())` without a `ProviderScope`. `DiametricsApp` is a `ConsumerWidget` and throws `Bad state: No ProviderScope found` without one.

- [ ] **Step 1: Edit the test**

Replace `test/widget_test.dart` with:

```dart
// Basic widget test for DiaMetrics app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiametricsApp()));
    expect(find.text('DiaMetrics'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test**

```bash
flutter test test/widget_test.dart
```

Expected: `+1: All tests passed!`

- [ ] **Step 3: Commit**

```bash
git add test/widget_test.dart
git commit -m "fix(test): wrap DiametricsApp in ProviderScope"
```

---

### Task 2: Add health tables to Drift schema (v4→v5)

**Files:**
- Modify: `lib/database/database.dart`

Add 4 new table classes. Use `@DataClassName` to avoid naming conflicts with the existing Freezed domain models (`GlucoseLog`, `MedicationLog`, `UserProfile` all exist as Freezed classes in `lib/models/`).

After editing, run `build_runner` to regenerate `database.g.dart`.

- [ ] **Step 1: Add the 4 health table classes to `lib/database/database.dart`**

Insert after the `N5kIngredients` class (before the `@DriftDatabase` annotation, currently at line 50):

```dart
@DataClassName('GlucoseLogRow')
class GlucoseLogs extends Table {
  TextColumn get id => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get context => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealMacroLog')
class MealMacroLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get name => text().nullable()();
  RealColumn get carbohydrates => real()();
  RealColumn get dietaryFiber => real().withDefault(const Constant(0.0))();
  RealColumn get proteins => real()();
  RealColumn get fats => real()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  BoolColumn get containsAlcohol => boolean().withDefault(const Constant(false))();
  BoolColumn get containsCaffeine => boolean().withDefault(const Constant(false))();
  TextColumn get mealType => text()();
  TextColumn get foodFormFactor => text().withDefault(const Constant('standard'))();
  BoolColumn get postExercise => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationLogRow')
class MedicationLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get medicationType => text()();
  TextColumn get insulinType => text().withDefault(const Constant('Humalog / NovoLog'))();
  TextColumn get name => text().nullable()();
  RealColumn get units => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserProfileRow')
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

- [ ] **Step 2: Update the `@DriftDatabase` annotation (currently line 50)**

Replace:
```dart
@DriftDatabase(tables: [LocalFoods, CustomFoods, MealLogs, N5kIngredients])
```

With:
```dart
@DriftDatabase(tables: [
  LocalFoods, CustomFoods, MealLogs, N5kIngredients,
  GlucoseLogs, MealMacroLogs, MedicationLogs, UserProfiles,
])
```

- [ ] **Step 3: Bump schema version and add v5 migration**

Replace the `schemaVersion` getter and `migration` getter (currently lines 57–80):

```dart
@override
int get schemaVersion => 5;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from == 1) {
      await m.createTable(localFoods);
      await m.createTable(customFoods);
      await m.createTable(mealLogs);
    }
    if (from <= 2) {
      await m.createTable(n5kIngredients);
    }
    if (from <= 3) {
      await m.addColumn(mealLogs, mealLogs.totalCalories);
      await m.addColumn(mealLogs, mealLogs.totalProtein);
      await m.addColumn(mealLogs, mealLogs.totalFat);
    }
    if (from <= 4) {
      await m.createTable(glucoseLogs);
      await m.createTable(mealMacroLogs);
      await m.createTable(medicationLogs);
      await m.createTable(userProfiles);
    }
  },
);
```

- [ ] **Step 4: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `Succeeded after ...` with no errors. This regenerates `lib/database/database.g.dart`.

- [ ] **Step 5: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/database/
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/database/database.dart lib/database/database.g.dart
git commit -m "feat(db): add health tables to Drift schema (v5)"
```

---

### Task 3: Write tests for Drift health tables

**Files:**
- Create: `test/database/health_tables_test.dart`

Test the 4 new Drift tables using an in-memory database — same pattern as the existing `test/database_test.dart`.

- [ ] **Step 1: Create the test file**

Create `test/database/health_tables_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/database/database.dart';

AppDatabase _openTestDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('Health Tables (Drift)', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    // ── GlucoseLogs ──────────────────────────────────────────────────────

    test('insert and retrieve a glucose log', () async {
      final ts = DateTime(2026, 4, 10, 8, 0);
      await db.into(db.glucoseLogs).insert(GlucoseLogsCompanion(
        id: const Value('g1'),
        value: const Value(120.0),
        unit: const Value('mg/dL'),
        context: const Value('fasting'),
        timestamp: Value(ts),
      ));

      final rows = await db.select(db.glucoseLogs).get();
      expect(rows, hasLength(1));
      expect(rows.first.value, 120.0);
      expect(rows.first.context, 'fasting');
      expect(rows.first.notes, isNull);
    });

    test('glucose log with notes round-trips correctly', () async {
      await db.into(db.glucoseLogs).insert(GlucoseLogsCompanion(
        id: const Value('g2'),
        value: const Value(85.0),
        unit: const Value('mg/dL'),
        context: const Value('pre_meal'),
        timestamp: Value(DateTime.now()),
        notes: const Value('stress at work'),
      ));

      final row = await db.select(db.glucoseLogs).getSingle();
      expect(row.notes, 'stress at work');
    });

    // ── MealMacroLogs ────────────────────────────────────────────────────

    test('insert and retrieve a meal macro log', () async {
      await db.into(db.mealMacroLogs).insert(MealMacroLogsCompanion(
        id: const Value('m1'),
        timestamp: Value(DateTime.now()),
        carbohydrates: const Value(45.0),
        proteins: const Value(20.0),
        fats: const Value(10.0),
        mealType: const Value('lunch'),
      ));

      final rows = await db.select(db.mealMacroLogs).get();
      expect(rows, hasLength(1));
      expect(rows.first.carbohydrates, 45.0);
      expect(rows.first.containsAlcohol, false); // default
      expect(rows.first.foodFormFactor, 'standard'); // default
    });

    // ── MedicationLogs ───────────────────────────────────────────────────

    test('insert and retrieve a medication log', () async {
      await db.into(db.medicationLogs).insert(MedicationLogsCompanion(
        id: const Value('med1'),
        timestamp: Value(DateTime.now()),
        medicationType: const Value('rapid_acting_insulin'),
        units: const Value(4.0),
      ));

      final rows = await db.select(db.medicationLogs).get();
      expect(rows, hasLength(1));
      expect(rows.first.units, 4.0);
      expect(rows.first.insulinType, 'Humalog / NovoLog'); // default
    });

    // ── UserProfiles ─────────────────────────────────────────────────────

    test('insert and retrieve a user profile', () async {
      final now = DateTime(2026, 1, 1);
      await db.into(db.userProfiles).insert(UserProfilesCompanion(
        id: const Value('p1'),
        age: const Value(35),
        gender: const Value('male'),
        heightCm: const Value(175.0),
        weightKg: const Value(80.0),
        diabetesType: const Value('type2'),
        diagnosisYear: const Value(2020),
        preferredGlucoseUnit: const Value('mg/dL'),
        targetGlucoseMin: const Value(70.0),
        targetGlucoseMax: const Value(180.0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final rows = await db.select(db.userProfiles).get();
      expect(rows, hasLength(1));
      expect(rows.first.age, 35);
      expect(rows.first.usesInsulin, false);
      expect(rows.first.metabolicClearanceRate, closeTo(0.010, 0.0001));
    });

    test('insertOnConflictUpdate replaces existing profile', () async {
      final now = DateTime(2026, 1, 1);
      final companion = UserProfilesCompanion(
        id: const Value('p1'),
        age: const Value(35),
        gender: const Value('male'),
        heightCm: const Value(175.0),
        weightKg: const Value(80.0),
        diabetesType: const Value('type2'),
        diagnosisYear: const Value(2020),
        preferredGlucoseUnit: const Value('mg/dL'),
        targetGlucoseMin: const Value(70.0),
        targetGlucoseMax: const Value(180.0),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      await db.into(db.userProfiles).insert(companion);
      await db.into(db.userProfiles).insertOnConflictUpdate(
        companion.copyWith(age: const Value(36)),
      );

      final rows = await db.select(db.userProfiles).get();
      expect(rows, hasLength(1));
      expect(rows.first.age, 36);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they pass**

```bash
flutter test test/database/health_tables_test.dart
```

Expected: `+5: All tests passed!`

- [ ] **Step 3: Commit**

```bash
git add test/database/health_tables_test.dart
git commit -m "test(db): add Drift health table CRUD tests"
```

---

### Task 4: Rewrite UserRepository

**Files:**
- Modify: `lib/repositories/user_repository.dart`

Replace the entire file. Same public interface (`saveProfile`, `getProfile`) — internal implementation now uses Drift. Import `db` from `lib/database/db_instance.dart` (the global encrypted DB singleton).

- [ ] **Step 1: Replace `lib/repositories/user_repository.dart`**

```dart
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/db_instance.dart';
import '../models/user_profile.dart';

class UserRepository {
  Future<void> saveProfile(UserProfile profile) async {
    await db.into(db.userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion(
        id: Value(profile.id),
        name: Value(profile.name),
        age: Value(profile.age),
        gender: Value(profile.gender),
        heightCm: Value(profile.heightCm),
        weightKg: Value(profile.weightKg),
        targetWeightKg: Value(profile.targetWeightKg),
        diabetesType: Value(profile.diabetesType),
        diagnosisYear: Value(profile.diagnosisYear),
        preferredGlucoseUnit: Value(profile.preferredGlucoseUnit),
        usesInsulin: Value(profile.usesInsulin),
        usesPills: Value(profile.usesPills),
        usesCgm: Value(profile.usesCgm),
        targetGlucoseMin: Value(profile.targetGlucoseMin),
        targetGlucoseMax: Value(profile.targetGlucoseMax),
        metabolicClearanceRate: Value(profile.metabolicClearanceRate),
        insulinSensitivityFactor: Value(profile.insulinSensitivityFactor),
        absorptionDelayBase: Value(profile.absorptionDelayBase),
        tuningMealCount: Value(profile.tuningMealCount),
        fastingSetpoint: Value(profile.fastingSetpoint),
        insulinCategory: Value(profile.insulinCategory),
        insulinDiaMinutes: Value(profile.insulinDiaMinutes),
        ekfCovP1: Value(profile.ekfCovP1),
        ekfCovISF: Value(profile.ekfCovISF),
        ekfCovTMax: Value(profile.ekfCovTMax),
        hasAgreedToDisclaimer: Value(profile.hasAgreedToDisclaimer),
        createdAt: Value(profile.createdAt),
        updatedAt: Value(profile.updatedAt),
      ),
    );
  }

  Future<UserProfile?> getProfile() async {
    final row = await (db.select(db.userProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  UserProfile _fromRow(UserProfileRow row) => UserProfile(
    id: row.id,
    name: row.name,
    age: row.age,
    gender: row.gender,
    heightCm: row.heightCm,
    weightKg: row.weightKg,
    targetWeightKg: row.targetWeightKg,
    diabetesType: row.diabetesType,
    diagnosisYear: row.diagnosisYear,
    preferredGlucoseUnit: row.preferredGlucoseUnit,
    usesInsulin: row.usesInsulin,
    usesPills: row.usesPills,
    usesCgm: row.usesCgm,
    targetGlucoseMin: row.targetGlucoseMin,
    targetGlucoseMax: row.targetGlucoseMax,
    metabolicClearanceRate: row.metabolicClearanceRate,
    insulinSensitivityFactor: row.insulinSensitivityFactor,
    absorptionDelayBase: row.absorptionDelayBase,
    tuningMealCount: row.tuningMealCount,
    fastingSetpoint: row.fastingSetpoint,
    insulinCategory: row.insulinCategory,
    insulinDiaMinutes: row.insulinDiaMinutes,
    ekfCovP1: row.ekfCovP1,
    ekfCovISF: row.ekfCovISF,
    ekfCovTMax: row.ekfCovTMax,
    hasAgreedToDisclaimer: row.hasAgreedToDisclaimer,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
```

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/repositories/user_repository.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Run full test suite**

```bash
flutter test
```

Expected: all tests pass (widget + database + health_tables + projection + EKF).

- [ ] **Step 4: Commit**

```bash
git add lib/repositories/user_repository.dart
git commit -m "refactor(repo): migrate UserRepository to Drift"
```

---

### Task 5: Rewrite HealthDataRepository

**Files:**
- Modify: `lib/repositories/health_data_repository.dart`

Replace the entire file. Same public interface — 8 methods unchanged. Internal implementation uses Drift. The `isSynced` field in Freezed models is always `false` on read (the Drift tables don't store it).

- [ ] **Step 1: Replace `lib/repositories/health_data_repository.dart`**

```dart
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/db_instance.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';

class HealthDataRepository {
  // ── Glucose ────────────────────────────────────────────────────────────

  Future<List<GlucoseLog>> getGlucoseLogs() async {
    final rows = await db.select(db.glucoseLogs).get();
    return rows.map(_glucoseFromRow).toList();
  }

  Future<void> addGlucoseLog(GlucoseLog log) async {
    await db.into(db.glucoseLogs).insert(GlucoseLogsCompanion(
      id: Value(log.id),
      value: Value(log.value),
      unit: Value(log.unit),
      context: Value(log.context),
      timestamp: Value(log.timestamp),
      notes: Value(log.notes),
    ));
  }

  Future<GlucoseLog?> getRecentGlucoseByContext(
    String context,
    Duration within,
  ) async {
    final cutoff = DateTime.now().subtract(within);
    final row = await (db.select(db.glucoseLogs)
          ..where(
            (t) =>
                t.context.equals(context) &
                t.timestamp.isBiggerThanValue(cutoff),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _glucoseFromRow(row);
  }

  // ── Meals ──────────────────────────────────────────────────────────────

  Future<List<MealLog>> getMealLogs() async {
    final rows = await db.select(db.mealMacroLogs).get();
    return rows.map(_mealFromRow).toList();
  }

  Future<void> addMealLog(MealLog log) async {
    await db.into(db.mealMacroLogs).insert(MealMacroLogsCompanion(
      id: Value(log.id),
      timestamp: Value(log.timestamp),
      name: Value(log.name),
      carbohydrates: Value(log.carbohydrates),
      dietaryFiber: Value(log.dietaryFiber),
      proteins: Value(log.proteins),
      fats: Value(log.fats),
      calories: Value(log.calories),
      containsAlcohol: Value(log.containsAlcohol),
      containsCaffeine: Value(log.containsCaffeine),
      mealType: Value(log.mealType),
      foodFormFactor: Value(log.foodFormFactor),
      postExercise: Value(log.postExercise),
      notes: Value(log.notes),
    ));
  }

  // ── Medications ────────────────────────────────────────────────────────

  Future<List<MedicationLog>> getMedicationLogs() async {
    final rows = await db.select(db.medicationLogs).get();
    return rows.map(_medFromRow).toList();
  }

  Future<List<MedicationLog>> getRecentMedicationLogs(Duration within) async {
    final cutoff = DateTime.now().subtract(within);
    final rows = await (db.select(db.medicationLogs)
          ..where((t) => t.timestamp.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return rows.map(_medFromRow).toList();
  }

  Future<void> addMedicationLog(MedicationLog log) async {
    await db.into(db.medicationLogs).insert(MedicationLogsCompanion(
      id: Value(log.id),
      timestamp: Value(log.timestamp),
      medicationType: Value(log.medicationType),
      insulinType: Value(log.insulinType),
      name: Value(log.name),
      units: Value(log.units),
      notes: Value(log.notes),
    ));
  }

  // ── Mappers ────────────────────────────────────────────────────────────

  GlucoseLog _glucoseFromRow(GlucoseLogRow row) => GlucoseLog(
    id: row.id,
    timestamp: row.timestamp,
    value: row.value,
    unit: row.unit,
    context: row.context,
    notes: row.notes,
  );

  MealLog _mealFromRow(MealMacroLog row) => MealLog(
    id: row.id,
    timestamp: row.timestamp,
    name: row.name,
    carbohydrates: row.carbohydrates,
    dietaryFiber: row.dietaryFiber,
    proteins: row.proteins,
    fats: row.fats,
    calories: row.calories,
    containsAlcohol: row.containsAlcohol,
    containsCaffeine: row.containsCaffeine,
    mealType: row.mealType,
    foodFormFactor: row.foodFormFactor,
    postExercise: row.postExercise,
    notes: row.notes,
  );

  MedicationLog _medFromRow(MedicationLogRow row) => MedicationLog(
    id: row.id,
    timestamp: row.timestamp,
    medicationType: row.medicationType,
    insulinType: row.insulinType,
    name: row.name,
    units: row.units,
    notes: row.notes,
  );
}
```

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/repositories/health_data_repository.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Run full test suite**

```bash
flutter test
```

Expected: all pass.

- [ ] **Step 4: Commit**

```bash
git add lib/repositories/health_data_repository.dart
git commit -m "refactor(repo): migrate HealthDataRepository to Drift"
```

---

### Task 6: Create LegacyMigrationService

**Files:**
- Create: `lib/services/legacy_migration_service.dart`

Reads all rows from the old `diametrics_v1.db` (opened read-only via sqflite), bulk-inserts into the Drift health tables using `insertOrIgnore` (idempotent), deletes the old file, and records a `SharedPreferences` flag so it only runs once. Safe to call on every startup — exits immediately after first successful run.

- [ ] **Step 1: Create `lib/services/legacy_migration_service.dart`**

```dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database.dart';
import '../database/db_instance.dart';

/// One-time migration from the legacy unencrypted SQLite database
/// (`diametrics_v1.db`) into the encrypted Drift database (`app.db`).
///
/// Safe to call on every app startup — exits immediately after the first
/// successful run (guarded by a SharedPreferences flag).
class LegacyMigrationService {
  static const _migratedKey = 'legacy_migrated_v1';

  static Future<void> runIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return;

    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, 'diametrics_v1.db');

    if (!await File(dbPath).exists()) {
      // New install — no old data to migrate.
      await prefs.setBool(_migratedKey, true);
      return;
    }

    debugPrint('LegacyMigration: found diametrics_v1.db — migrating…');

    final oldDb = await openDatabase(dbPath, readOnly: true);
    try {
      await _migrateGlucoseLogs(oldDb);
      await _migrateMealLogs(oldDb);
      await _migrateMedicationLogs(oldDb);
      await _migrateUserProfile(oldDb);
    } finally {
      await oldDb.close();
    }

    await File(dbPath).delete();
    await prefs.setBool(_migratedKey, true);
    debugPrint('LegacyMigration: complete — old DB deleted.');
  }

  static Future<void> _migrateGlucoseLogs(Database oldDb) async {
    final rows = await oldDb.query('glucose_logs');
    if (rows.isEmpty) return;
    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.glucoseLogs,
          GlucoseLogsCompanion(
            id: Value(row['id'] as String),
            value: Value((row['value'] as num).toDouble()),
            unit: Value(row['unit'] as String),
            context: Value(row['context'] as String),
            timestamp: Value(DateTime.parse(row['timestamp'] as String)),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    debugPrint('LegacyMigration: migrated ${rows.length} glucose logs.');
  }

  static Future<void> _migrateMealLogs(Database oldDb) async {
    final rows = await oldDb.query('meal_logs');
    if (rows.isEmpty) return;
    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.mealMacroLogs,
          MealMacroLogsCompanion(
            id: Value(row['id'] as String),
            timestamp: Value(DateTime.parse(row['timestamp'] as String)),
            name: Value(row['name'] as String?),
            carbohydrates: Value((row['carbohydrates'] as num).toDouble()),
            dietaryFiber: Value((row['dietaryFiber'] as num?)?.toDouble() ?? 0.0),
            proteins: Value((row['proteins'] as num).toDouble()),
            fats: Value((row['fats'] as num).toDouble()),
            calories: Value((row['calories'] as num?)?.toDouble() ?? 0.0),
            containsAlcohol: Value((row['containsAlcohol'] as int?) == 1),
            containsCaffeine: Value((row['containsCaffeine'] as int?) == 1),
            mealType: Value(row['mealType'] as String? ?? 'lunch'),
            foodFormFactor: Value(row['foodFormFactor'] as String? ?? 'standard'),
            postExercise: Value((row['postExercise'] as int?) == 1),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    debugPrint('LegacyMigration: migrated ${rows.length} meal logs.');
  }

  static Future<void> _migrateMedicationLogs(Database oldDb) async {
    final rows = await oldDb.query('medication_logs');
    if (rows.isEmpty) return;
    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.medicationLogs,
          MedicationLogsCompanion(
            id: Value(row['id'] as String),
            timestamp: Value(DateTime.parse(row['timestamp'] as String)),
            medicationType: Value(row['medicationType'] as String),
            // insulinType not stored in legacy DB — use the Freezed default
            insulinType: const Value('Humalog / NovoLog'),
            name: Value(row['name'] as String?),
            units: Value((row['units'] as num).toDouble()),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    debugPrint('LegacyMigration: migrated ${rows.length} medication logs.');
  }

  static Future<void> _migrateUserProfile(Database oldDb) async {
    final rows = await oldDb.query(
      'user_profiles',
      orderBy: 'updatedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return;
    final row = rows.first;
    await db.into(db.userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion(
        id: Value(row['id'] as String),
        name: Value(row['name'] as String? ?? ''),
        age: Value(row['age'] as int),
        gender: Value(row['gender'] as String),
        heightCm: Value((row['heightCm'] as num).toDouble()),
        weightKg: Value((row['weightKg'] as num).toDouble()),
        targetWeightKg: Value(
          row['targetWeightKg'] != null
              ? (row['targetWeightKg'] as num).toDouble()
              : null,
        ),
        diabetesType: Value(row['diabetesType'] as String),
        diagnosisYear: Value(row['diagnosisYear'] as int),
        preferredGlucoseUnit: Value(
          row['preferredGlucoseUnit'] as String? ?? 'mg/dL',
        ),
        usesInsulin: Value((row['usesInsulin'] as int?) == 1),
        usesPills: Value((row['usesPills'] as int?) == 1),
        usesCgm: Value((row['usesCgm'] as int?) == 1),
        targetGlucoseMin: Value(
          (row['targetGlucoseMin'] as num?)?.toDouble() ?? 70.0,
        ),
        targetGlucoseMax: Value(
          (row['targetGlucoseMax'] as num?)?.toDouble() ?? 180.0,
        ),
        metabolicClearanceRate: Value(
          (row['metabolicClearanceRate'] as num?)?.toDouble() ?? 0.010,
        ),
        insulinSensitivityFactor: Value(
          (row['insulinSensitivityFactor'] as num?)?.toDouble() ?? 50.0,
        ),
        absorptionDelayBase: Value(
          (row['absorptionDelayBase'] as num?)?.toDouble() ?? 40.0,
        ),
        tuningMealCount: Value(row['tuningMealCount'] as int? ?? 0),
        fastingSetpoint: Value(
          (row['fastingSetpoint'] as num?)?.toDouble() ?? 90.0,
        ),
        insulinCategory: Value(
          row['insulinCategory'] as String? ?? 'standard_rapid',
        ),
        insulinDiaMinutes: Value(
          (row['insulinDiaMinutes'] as num?)?.toDouble() ?? 240.0,
        ),
        ekfCovP1: Value((row['ekfCovP1'] as num?)?.toDouble() ?? 1.0),
        ekfCovISF: Value((row['ekfCovISF'] as num?)?.toDouble() ?? 1.0),
        ekfCovTMax: Value((row['ekfCovTMax'] as num?)?.toDouble() ?? 1.0),
        hasAgreedToDisclaimer: Value(
          (row['hasAgreedToDisclaimer'] as int?) == 1,
        ),
        createdAt: Value(DateTime.parse(row['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(row['updatedAt'] as String)),
      ),
    );
    debugPrint('LegacyMigration: migrated user profile.');
  }
}
```

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/services/legacy_migration_service.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/legacy_migration_service.dart
git commit -m "feat: add LegacyMigrationService (diametrics_v1.db → Drift)"
```

---

### Task 7: Wire migration into main.dart and delete DatabaseHelper

**Files:**
- Modify: `lib/main.dart`
- Delete: `lib/core/database/database_helper.dart`

Call `LegacyMigrationService.runIfNeeded()` in `main()` before `runApp`, after `initDatabase()`. Then delete `DatabaseHelper` — nothing imports it after Tasks 4 and 5.

- [ ] **Step 1: Update `lib/main.dart`**

Replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'database/db_instance.dart';
import 'package:diametrics/src/core/di/injection.dart';
import 'router/app_router.dart';
import 'services/legacy_migration_service.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  try {
    await ReminderService.initialize();
  } catch (e) {
    debugPrint('Reminder initialization failed: $e');
  }

  try {
    await initDatabase();
    await LegacyMigrationService.runIfNeeded();
    await db.populateLocalFoodsIfEmpty();
    await db.populateN5kIfEmpty();
  } catch (e) {
    debugPrint('Database initialization failed: $e');
  }

  runApp(const ProviderScope(child: DiametricsApp()));
}

class DiametricsApp extends ConsumerWidget {
  const DiametricsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DiaMetrics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 2: Delete `lib/core/database/database_helper.dart`**

```bash
rm "lib/core/database/database_helper.dart"
```

- [ ] **Step 3: Run static analysis on the entire lib directory**

```bash
flutter analyze --no-fatal-infos
```

Expected: `No issues found!`

If you see errors about `database_helper.dart` being imported somewhere still, grep for it:
```bash
grep -r "database_helper" lib/
```
And remove any remaining imports. After Tasks 4 and 5, only `user_repository.dart` and `health_data_repository.dart` imported it — both have been replaced.

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart
git rm lib/core/database/database_helper.dart
git commit -m "feat: wire legacy migration in main.dart, retire DatabaseHelper"
```

---

### Task 8: Create TrendsViewModel

**Files:**
- Create: `lib/viewmodels/trends_viewmodel.dart`

`selectedRangeProvider` holds the selected day count (7, 30, or 90). `trendsProvider` is an `AsyncNotifierProvider` that watches `selectedRangeProvider` and re-fetches all three log types when the range changes.

No Freezed needed for `TrendsData` — it's a simple container never serialized.

- [ ] **Step 1: Create `lib/viewmodels/trends_viewmodel.dart`**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import 'health_data_viewmodel.dart';

class TrendsData {
  final List<GlucoseLog> glucoseLogs;
  final List<MealLog> mealLogs;
  final List<MedicationLog> medicationLogs;

  const TrendsData({
    required this.glucoseLogs,
    required this.mealLogs,
    required this.medicationLogs,
  });
}

/// Selected time range in days. Defaults to 7.
final selectedRangeProvider = StateProvider<int>((ref) => 7);

final trendsProvider =
    AsyncNotifierProvider<TrendsViewModel, TrendsData>(TrendsViewModel.new);

class TrendsViewModel extends AsyncNotifier<TrendsData> {
  @override
  Future<TrendsData> build() async {
    final days = ref.watch(selectedRangeProvider);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final repo = ref.read(healthDataRepositoryProvider);

    final allGlucose = await repo.getGlucoseLogs();
    final allMeals = await repo.getMealLogs();
    final allMeds = await repo.getMedicationLogs();

    return TrendsData(
      glucoseLogs: allGlucose
          .where((g) => g.timestamp.isAfter(cutoff))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      mealLogs: allMeals.where((m) => m.timestamp.isAfter(cutoff)).toList(),
      medicationLogs:
          allMeds.where((m) => m.timestamp.isAfter(cutoff)).toList(),
    );
  }
}
```

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/viewmodels/trends_viewmodel.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/viewmodels/trends_viewmodel.dart
git commit -m "feat(vm): add TrendsViewModel with date-range filtering"
```

---

### Task 9: Create TrendsView

**Files:**
- Create: `lib/views/trends/trends_view.dart`

Full `TrendsView` using `fl_chart`. Replaces the glucose-only `GlucoseTrendView`. Glucose is plotted as a line chart; meals appear as green upward triangle markers; insulin doses appear as orange downward triangle markers. Stats row below shows avg glucose, time-in-range %, and estimated HbA1c.

- [ ] **Step 1: Create `lib/views/trends/trends_view.dart`**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/glucose_log.dart';
import '../../models/meal_log.dart';
import '../../models/medication_log.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/trends_viewmodel.dart';

class TrendsView extends ConsumerWidget {
  const TrendsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(selectedRangeProvider);
    final trendsAsync = ref.watch(trendsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    final targetMin = profile?.targetGlucoseMin ?? 70.0;
    final targetMax = profile?.targetGlucoseMax ?? 180.0;
    final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Trends'),
        backgroundColor: AppThemeTokens.brandPrimary,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
      ),
      body: SafeArea(
        child: trendsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) => _TrendsContent(
            data: data,
            selectedDays: selectedDays,
            targetMin: targetMin,
            targetMax: targetMax,
            unit: unit,
          ),
        ),
      ),
    );
  }
}

class _TrendsContent extends ConsumerWidget {
  final TrendsData data;
  final int selectedDays;
  final double targetMin;
  final double targetMax;
  final String unit;

  const _TrendsContent({
    required this.data,
    required this.selectedDays,
    required this.targetMin,
    required this.targetMax,
    required this.unit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: AppThemeTokens.spaceMd),
        _RangeChips(selectedDays: selectedDays),
        const SizedBox(height: AppThemeTokens.spaceMd),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.38,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeTokens.spaceMd,
            ),
            child: _GlucoseChart(
              glucoseLogs: data.glucoseLogs,
              mealLogs: data.mealLogs,
              medicationLogs: data.medicationLogs,
              targetMin: targetMin,
              targetMax: targetMax,
              selectedDays: selectedDays,
            ),
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
        _StatsRow(
          glucoseLogs: data.glucoseLogs,
          targetMin: targetMin,
          targetMax: targetMax,
          unit: unit,
        ),
        const Divider(height: AppThemeTokens.spaceLg),
        Expanded(
          child: _GlucoseLogList(logs: data.glucoseLogs, unit: unit),
        ),
      ],
    );
  }
}

// ── Range selector chips ────────────────────────────────────────────────────

class _RangeChips extends ConsumerWidget {
  final int selectedDays;
  const _RangeChips({required this.selectedDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [7, 30, 90].map((days) {
        final label = days == 7 ? '7D' : days == 30 ? '30D' : '90D';
        final isSelected = selectedDays == days;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppThemeTokens.spaceXs),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(selectedRangeProvider.notifier).state = days,
            selectedColor: AppThemeTokens.brandPrimary,
            labelStyle: TextStyle(
              color: isSelected
                  ? AppThemeTokens.textPrimaryInverse
                  : AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Chart ───────────────────────────────────────────────────────────────────

class _GlucoseChart extends StatelessWidget {
  final List<GlucoseLog> glucoseLogs;
  final List<MealLog> mealLogs;
  final List<MedicationLog> medicationLogs;
  final double targetMin;
  final double targetMax;
  final int selectedDays;

  const _GlucoseChart({
    required this.glucoseLogs,
    required this.mealLogs,
    required this.medicationLogs,
    required this.targetMin,
    required this.targetMax,
    required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseLogs.isEmpty) {
      return const Center(child: Text('No glucose readings in this period.'));
    }

    final rangeStart = glucoseLogs.first.timestamp;

    double toX(DateTime ts) =>
        ts.difference(rangeStart).inMinutes.toDouble();

    final spots = glucoseLogs
        .map((g) => FlSpot(toX(g.timestamp), g.value))
        .toList();

    final mealLines = mealLogs.map((m) => VerticalLine(
      x: toX(m.timestamp),
      color: AppThemeTokens.brandSuccess.withOpacity(0.6),
      strokeWidth: 1.5,
      dashArray: [4, 4],
      label: VerticalLineLabel(
        show: true,
        labelResolver: (_) => '🍽',
        style: const TextStyle(fontSize: 10),
        alignment: Alignment.topCenter,
      ),
    )).toList();

    final medLines = medicationLogs
        .where((m) => m.medicationType == 'rapid_acting_insulin')
        .map((m) => VerticalLine(
          x: toX(m.timestamp),
          color: AppThemeTokens.brandAccent.withOpacity(0.6),
          strokeWidth: 1.5,
          dashArray: [4, 4],
          label: VerticalLineLabel(
            show: true,
            labelResolver: (_) => '💉',
            style: const TextStyle(fontSize: 10),
            alignment: Alignment.topCenter,
          ),
        ))
        .toList();

    final maxX = spots.last.x;
    final allY = spots.map((s) => s.y).toList()
      ..addAll([targetMin, targetMax]);
    final minY = (allY.reduce((a, b) => a < b ? a : b) - 20).clamp(0, 400).toDouble();
    final maxY = (allY.reduce((a, b) => a > b ? a : b) + 20).clamp(0, 600).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppThemeTokens.brandPrimary,
            barWidth: 2,
            dotData: FlDotData(
              show: spots.length <= 20,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: AppThemeTokens.brandPrimary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: targetMin,
              color: AppThemeTokens.brandSuccess.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
            HorizontalLine(
              y: targetMax,
              color: AppThemeTokens.error.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
          ],
          verticalLines: [...mealLines, ...medLines],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxX / 4,
              getTitlesWidget: (value, _) {
                final dt =
                    rangeStart.add(Duration(minutes: value.toInt()));
                final label = selectedDays <= 7
                    ? '${dt.month}/${dt.day}'
                    : '${dt.month}/${dt.day}';
                return Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppThemeTokens.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppThemeTokens.brandAccent.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }
}

// ── Stats row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<GlucoseLog> glucoseLogs;
  final double targetMin;
  final double targetMax;
  final String unit;

  const _StatsRow({
    required this.glucoseLogs,
    required this.targetMin,
    required this.targetMax,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    // All math done in mg/dL; convert for display if user prefers mmol/L
    double toMgdL(double v) =>
        unit == 'mmol/L' ? v * 18.0182 : v;
    double fromMgdL(double v) =>
        unit == 'mmol/L' ? v / 18.0182 : v;

    final mgValues = glucoseLogs.map((g) => toMgdL(g.value)).toList();
    final avg = mgValues.reduce((a, b) => a + b) / mgValues.length;
    final tMinMg = toMgdL(targetMin);
    final tMaxMg = toMgdL(targetMax);
    final inRange =
        mgValues.where((v) => v >= tMinMg && v <= tMaxMg).length;
    final tirPct = (inRange / mgValues.length * 100);
    // ADAG formula: eA1c = (avgGlucose_mgdL + 46.7) / 28.7
    final hba1c = (avg + 46.7) / 28.7;

    final displayAvg = unit == 'mmol/L'
        ? '${fromMgdL(avg).toStringAsFixed(1)} mmol/L'
        : '${avg.toStringAsFixed(0)} mg/dL';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeTokens.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(label: 'Avg', value: displayAvg),
          _StatCell(label: 'In Range', value: '${tirPct.toStringAsFixed(0)}%'),
          _StatCell(label: 'Est. HbA1c', value: '${hba1c.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Log list ────────────────────────────────────────────────────────────────

class _GlucoseLogList extends StatelessWidget {
  final List<GlucoseLog> logs;
  final String unit;

  const _GlucoseLogList({required this.logs, required this.unit});

  @override
  Widget build(BuildContext context) {
    final sorted = List<GlucoseLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (sorted.isEmpty) {
      return const Center(
        child: Text('No readings logged in this period.'),
      );
    }

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final g = sorted[i];
        final ts = g.timestamp;
        final dateStr =
            '${ts.day}/${ts.month}/${ts.year}  ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
        return ListTile(
          dense: true,
          leading: const Icon(
            Icons.water_drop_outlined,
            color: AppThemeTokens.brandPrimary,
          ),
          title: Text(
            '${g.value.toStringAsFixed(unit == 'mmol/L' ? 1 : 0)} $unit',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${g.context.replaceAll('_', ' ')} · $dateStr',
            style: const TextStyle(fontSize: 11),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze --no-fatal-infos lib/views/trends/trends_view.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/views/trends/trends_view.dart lib/viewmodels/trends_viewmodel.dart
git commit -m "feat(ui): add TrendsView with glucose chart + meal/med overlay"
```

---

### Task 10: Wire TrendsView into the router and dashboard

**Files:**
- Modify: `lib/router/app_router.dart`
- Modify: `lib/views/dashboard/dashboard_view.dart`
- Delete: `lib/views/history/glucose_trend_view.dart` (replaced)

Replace the import of `GlucoseTrendView` in the router with `TrendsView` (same route path — no change to `route_names.dart`). Add a bar-chart icon button to the Dashboard `AppBar` that navigates to `Routes.glucoseTrend`.

- [ ] **Step 1: Update `lib/router/app_router.dart`**

Replace the import line:
```dart
import '../views/history/glucose_trend_view.dart';
```
With:
```dart
import '../views/trends/trends_view.dart';
```

Replace the `GlucoseTrendView()` builder (inside the `glucose-trend` GoRoute):
```dart
GoRoute(
  path: 'glucose-trend',
  builder: (_, _) => const GlucoseTrendView(),
),
```
With:
```dart
GoRoute(
  path: 'glucose-trend',
  builder: (_, _) => const TrendsView(),
),
```

- [ ] **Step 2: Delete the old trend view**

```bash
rm "lib/views/history/glucose_trend_view.dart"
```

- [ ] **Step 3: Add "Trends" icon button to `DashboardView`**

In `lib/views/dashboard/dashboard_view.dart`, inside the `Scaffold` widget, add an `appBar` property. Find the existing `Scaffold(` (around line 76) and add an `appBar`:

```dart
return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(
          Icons.bar_chart_rounded,
          color: AppThemeTokens.brandPrimary,
        ),
        tooltip: 'Trends',
        onPressed: () => context.push(Routes.glucoseTrend),
      ),
    ],
  ),
  body: SafeArea(
```

Note: the existing `body: SafeArea(` is still there — only the `appBar` parameter is added.

- [ ] **Step 4: Run static analysis**

```bash
flutter analyze --no-fatal-infos
```

Expected: `No issues found!`

- [ ] **Step 5: Run full test suite**

```bash
flutter test
```

Expected: all pass.

- [ ] **Step 6: Commit**

```bash
git add lib/router/app_router.dart lib/views/dashboard/dashboard_view.dart
git rm lib/views/history/glucose_trend_view.dart
git commit -m "feat(nav): wire TrendsView to router and dashboard AppBar"
```

---

### Task 11: Final verification

**Files:** (no changes — verification only)

- [ ] **Step 1: Run full static analysis**

```bash
flutter analyze --no-fatal-infos
```

Expected: `No issues found!`

- [ ] **Step 2: Confirm DatabaseHelper is gone**

```bash
grep -r "DatabaseHelper\|database_helper" lib/
```

Expected: no output.

- [ ] **Step 3: Confirm no raw sqflite in repositories**

```bash
grep -r "sqflite\|DatabaseHelper" lib/repositories/
```

Expected: no output.

- [ ] **Step 4: Run full test suite with expanded reporter**

```bash
flutter test --reporter=expanded
```

Expected output includes:
- `widget_test.dart` — 1 test passes ✅
- `database_test.dart` — 5 tests pass ✅
- `database/health_tables_test.dart` — 5 tests pass ✅
- `services/glucose_projection_test.dart` — 27 tests pass ✅
- `services/ekf_tuning_test.dart` — 22 tests pass ✅
- Total: 60 tests, 0 failures

- [ ] **Step 5: Commit if any stray fixes needed**

Only commit if Step 1 or 2 revealed something requiring a fix.

```bash
git add -p
git commit -m "fix: clean up remaining legacy DB references"
```
