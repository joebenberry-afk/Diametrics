import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import '../core/database/database_helper.dart';

class HealthDataRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Glucose
  Future<List<GlucoseLog>> getGlucoseLogs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('glucose_logs');
    return maps.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['isSynced'] = map['synced'] == 1;
      return GlucoseLog.fromJson(map);
    }).toList();
  }

  Future<void> addGlucoseLog(GlucoseLog log) async {
    final db = await _dbHelper.database;
    final map = log.toJson();
    map['synced'] = map.remove('isSynced') == true ? 1 : 0;
    await db.insert('glucose_logs', map);
  }

  /// Returns the most recent glucose log matching [context] within [within].
  Future<GlucoseLog?> getRecentGlucoseByContext(
    String context,
    Duration within,
  ) async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(within).toIso8601String();
    final maps = await db.query(
      'glucose_logs',
      where: 'context = ? AND timestamp > ?',
      whereArgs: [context, cutoff],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final map = Map<String, dynamic>.from(maps.first);
    map['isSynced'] = map['synced'] == 1;
    return GlucoseLog.fromJson(map);
  }

  // Meals
  Future<List<MealLog>> getMealLogs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('meal_logs');
    return maps.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['isSynced'] = map['synced'] == 1;
      map['containsAlcohol'] = map['containsAlcohol'] == 1;
      map['containsCaffeine'] = map['containsCaffeine'] == 1;
      return MealLog.fromJson(map);
    }).toList();
  }

  Future<void> addMealLog(MealLog log) async {
    final db = await _dbHelper.database;
    final map = log.toJson();
    map['synced'] = map.remove('isSynced') == true ? 1 : 0;
    map['containsAlcohol'] = map['containsAlcohol'] == true ? 1 : 0;
    map['containsCaffeine'] = map['containsCaffeine'] == true ? 1 : 0;
    await db.insert('meal_logs', map);
  }

  // Medications (including time-windowed query for IOB)
  Future<List<MedicationLog>> getMedicationLogs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('medication_logs');
    return maps.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['isSynced'] = map['synced'] == 1;
      return MedicationLog.fromJson(map);
    }).toList();
  }

  /// Returns all medication logs within [within] duration (for IOB calculation).
  Future<List<MedicationLog>> getRecentMedicationLogs(Duration within) async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(within).toIso8601String();
    final maps = await db.query(
      'medication_logs',
      where: 'timestamp > ?',
      whereArgs: [cutoff],
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['isSynced'] = map['synced'] == 1;
      return MedicationLog.fromJson(map);
    }).toList();
  }

  Future<void> addMedicationLog(MedicationLog log) async {
    final db = await _dbHelper.database;
    final map = log.toJson();
    map['synced'] = map.remove('isSynced') == true ? 1 : 0;
    await db.insert('medication_logs', map);
  }
}
