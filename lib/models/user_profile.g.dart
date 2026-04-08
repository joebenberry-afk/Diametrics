// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  heightCm: (json['heightCm'] as num).toDouble(),
  weightKg: (json['weightKg'] as num).toDouble(),
  targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
  diabetesType: json['diabetesType'] as String,
  diagnosisYear: (json['diagnosisYear'] as num).toInt(),
  preferredGlucoseUnit: json['preferredGlucoseUnit'] as String? ?? 'mg/dL',
  usesInsulin: json['usesInsulin'] as bool? ?? false,
  usesPills: json['usesPills'] as bool? ?? false,
  usesCgm: json['usesCgm'] as bool? ?? false,
  insulinCategory: json['insulinCategory'] as String? ?? 'standard_rapid',
  insulinDiaMinutes: (json['insulinDiaMinutes'] as num?)?.toDouble() ?? 240.0,
  targetGlucoseMin: (json['targetGlucoseMin'] as num?)?.toDouble() ?? 70.0,
  targetGlucoseMax: (json['targetGlucoseMax'] as num?)?.toDouble() ?? 180.0,
  fastingSetpoint: (json['fastingSetpoint'] as num?)?.toDouble() ?? 90.0,
  metabolicClearanceRate:
      (json['metabolicClearanceRate'] as num?)?.toDouble() ?? 0.010,
  insulinSensitivityFactor:
      (json['insulinSensitivityFactor'] as num?)?.toDouble() ?? 50.0,
  absorptionDelayBase:
      (json['absorptionDelayBase'] as num?)?.toDouble() ?? 40.0,
  tuningMealCount: (json['tuningMealCount'] as num?)?.toInt() ?? 0,
  ekfCovP1: (json['ekfCovP1'] as num?)?.toDouble() ?? 1.0,
  ekfCovISF: (json['ekfCovISF'] as num?)?.toDouble() ?? 1.0,
  ekfCovTMax: (json['ekfCovTMax'] as num?)?.toDouble() ?? 1.0,
  hasAgreedToDisclaimer: json['hasAgreedToDisclaimer'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'targetWeightKg': instance.targetWeightKg,
      'diabetesType': instance.diabetesType,
      'diagnosisYear': instance.diagnosisYear,
      'preferredGlucoseUnit': instance.preferredGlucoseUnit,
      'usesInsulin': instance.usesInsulin,
      'usesPills': instance.usesPills,
      'usesCgm': instance.usesCgm,
      'insulinCategory': instance.insulinCategory,
      'insulinDiaMinutes': instance.insulinDiaMinutes,
      'targetGlucoseMin': instance.targetGlucoseMin,
      'targetGlucoseMax': instance.targetGlucoseMax,
      'fastingSetpoint': instance.fastingSetpoint,
      'metabolicClearanceRate': instance.metabolicClearanceRate,
      'insulinSensitivityFactor': instance.insulinSensitivityFactor,
      'absorptionDelayBase': instance.absorptionDelayBase,
      'tuningMealCount': instance.tuningMealCount,
      'ekfCovP1': instance.ekfCovP1,
      'ekfCovISF': instance.ekfCovISF,
      'ekfCovTMax': instance.ekfCovTMax,
      'hasAgreedToDisclaimer': instance.hasAgreedToDisclaimer,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
