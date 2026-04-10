import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/db_instance.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart' as domain_models;
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

  Future<List<domain_models.MealLog>> getMealLogs() async {
    final rows = await db.select(db.mealMacroLogs).get();
    return rows.map(_mealFromRow).toList();
  }

  Future<void> addMealLog(domain_models.MealLog log) async {
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

  Future<void> updateMealLog(domain_models.MealLog log) async {
    await (db.update(db.mealMacroLogs)..where((t) => t.id.equals(log.id)))
        .write(MealMacroLogsCompanion(
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

  // ── Deletes ────────────────────────────────────────────────────────────

  Future<void> deleteGlucoseLog(String id) async {
    await (db.delete(db.glucoseLogs)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteMealLog(String id) async {
    await (db.delete(db.mealMacroLogs)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteMedicationLog(String id) async {
    await (db.delete(db.medicationLogs)..where((t) => t.id.equals(id))).go();
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

  domain_models.MealLog _mealFromRow(MealMacroLog row) => domain_models.MealLog(
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
