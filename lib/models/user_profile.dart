import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,

    // Demographics
    @Default('') String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    double? targetWeightKg,

    // Diabetes Context
    required String diabetesType,
    required int diagnosisYear,
    @Default('mg/dL') String preferredGlucoseUnit,

    // Management
    @Default(false) bool usesInsulin,
    @Default(false) bool usesPills,
    @Default(false) bool usesCgm,

    // Targets
    @Default(70.0) double targetGlucoseMin,
    @Default(180.0) double targetGlucoseMax,

    // Meta
    @Default(false) bool hasAgreedToDisclaimer,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
