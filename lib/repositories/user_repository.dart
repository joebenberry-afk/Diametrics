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
