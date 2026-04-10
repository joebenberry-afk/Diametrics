import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'diametrics_v1.db');

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
      await oldDb.close();
    } catch (e, st) {
      await oldDb.close();
      debugPrint('LegacyMigration: failed — will retry on next start. Error: $e\n$st');
      return; // Do NOT set the flag — migration retries next launch.
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
            // No insulinType column in v1 schema — use DB column default.
            insulinType: const Value.absent(),
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
