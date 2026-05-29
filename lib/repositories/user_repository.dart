import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/db_instance.dart';
import '../models/user_profile.dart';

/// Riverpod handle for [UserRepository]. Lets viewmodels inject it (and
/// override it in tests) instead of constructing it directly.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

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

  /// Updates only the EKF-specific columns for a given profile id.
  ///
  /// This is a targeted write that leaves all other columns (name, weight,
  /// targets, insulin settings, etc.) untouched, preventing the background
  /// EKF tuning task from overwriting concurrent user edits in Settings.
  Future<void> updateEkfParameters({
    required String profileId,
    required double metabolicClearanceRate,
    required double insulinSensitivityFactor,
    required double absorptionDelayBase,
    required int tuningMealCount,
    required double fastingSetpoint,
    required double ekfCovP1,
    required double ekfCovISF,
    required double ekfCovTMax,
  }) async {
    await (db.update(db.userProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(UserProfilesCompanion(
      metabolicClearanceRate: Value(metabolicClearanceRate),
      insulinSensitivityFactor: Value(insulinSensitivityFactor),
      absorptionDelayBase: Value(absorptionDelayBase),
      tuningMealCount: Value(tuningMealCount),
      fastingSetpoint: Value(fastingSetpoint),
      ekfCovP1: Value(ekfCovP1),
      ekfCovISF: Value(ekfCovISF),
      ekfCovTMax: Value(ekfCovTMax),
      updatedAt: Value(DateTime.now()),
    ));
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
