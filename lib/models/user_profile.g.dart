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
  targetGlucoseMin: (json['targetGlucoseMin'] as num?)?.toDouble() ?? 70.0,
  targetGlucoseMax: (json['targetGlucoseMax'] as num?)?.toDouble() ?? 180.0,
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
      'targetGlucoseMin': instance.targetGlucoseMin,
      'targetGlucoseMax': instance.targetGlucoseMax,
      'hasAgreedToDisclaimer': instance.hasAgreedToDisclaimer,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
