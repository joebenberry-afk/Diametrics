import '../core/database/database_helper.dart';
import '../models/user_profile.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbHelper.database;

    // Build the SQLite map manually — never rely on toJson() which may include
    // types (Dart bool, DateTime) that SQLite cannot store natively.
    final map = <String, dynamic>{
      'id': profile.id,
      'name': profile.name,
      'age': profile.age,
      'gender': profile.gender,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'targetWeightKg': profile.targetWeightKg,
      'diabetesType': profile.diabetesType,
      'diagnosisYear': profile.diagnosisYear,
      'preferredGlucoseUnit': profile.preferredGlucoseUnit,
      // Booleans MUST be stored as integers in SQLite
      'usesInsulin': profile.usesInsulin ? 1 : 0,
      'usesPills': profile.usesPills ? 1 : 0,
      'usesCgm': profile.usesCgm ? 1 : 0,
      'hasAgreedToDisclaimer': profile.hasAgreedToDisclaimer ? 1 : 0,
      // Glucose targets
      'targetGlucoseMin': profile.targetGlucoseMin,
      'targetGlucoseMax': profile.targetGlucoseMax,
      // ML Adaptive parameters
      'metabolicClearanceRate': profile.metabolicClearanceRate,
      'insulinSensitivityFactor': profile.insulinSensitivityFactor,
      'absorptionDelayBase': profile.absorptionDelayBase,
      // Dates as ISO8601 strings
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    };

    await db.transaction((txn) async {
      // Ensure we only ever have ONE profile on the device.
      // This wipes any phantom profiles created if Onboarding was aborted.
      await txn.delete('user_profiles');
      await txn.insert('user_profiles', map);
    });
  }

  Future<UserProfile?> getProfile() async {
    final db = await _dbHelper.database;
    // Force fetch the MOST RECENT profile if multiple somehow exist
    final maps = await db.query(
      'user_profiles',
      orderBy: 'updatedAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final raw = Map<String, dynamic>.from(maps.first);

    // Re-map SQLite column types back to Dart types for fromJson
    final map = <String, dynamic>{
      'id': raw['id'],
      'name': raw['name'] ?? '',
      'age': raw['age'],
      'gender': raw['gender'],
      'heightCm': raw['heightCm'],
      'weightKg': raw['weightKg'],
      'targetWeightKg': raw['targetWeightKg'],
      'diabetesType': raw['diabetesType'],
      'diagnosisYear': raw['diagnosisYear'],
      'preferredGlucoseUnit': raw['preferredGlucoseUnit'] ?? 'mg/dL',
      // Convert SQLite integers back to booleans
      'usesInsulin': raw['usesInsulin'] == 1,
      'usesPills': raw['usesPills'] == 1,
      'usesCgm': raw['usesCgm'] == 1,
      'hasAgreedToDisclaimer': raw['hasAgreedToDisclaimer'] == 1,
      'targetGlucoseMin': raw['targetGlucoseMin'] ?? 70.0,
      'targetGlucoseMax': raw['targetGlucoseMax'] ?? 180.0,
      // ML parameters with safe fallbacks if column missing from old installs
      'metabolicClearanceRate': raw['metabolicClearanceRate'] ?? 0.010,
      'insulinSensitivityFactor': raw['insulinSensitivityFactor'] ?? 50.0,
      'absorptionDelayBase': raw['absorptionDelayBase'] ?? 40.0,
      // Dates are already ISO8601 strings — fromJson parses them
      'createdAt': raw['createdAt'],
      'updatedAt': raw['updatedAt'],
    };

    return UserProfile.fromJson(map);
  }
}
