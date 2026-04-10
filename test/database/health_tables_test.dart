import 'package:drift/drift.dart' hide isNull, isNotNull;
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
