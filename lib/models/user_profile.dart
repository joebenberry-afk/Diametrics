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

    // Insulin Configuration (set once during onboarding)
    // Categories: 'ultra_fast', 'standard_rapid', 'regular', 'basal_only', 'none'
    @Default('standard_rapid') String insulinCategory,
    @Default(240.0) double insulinDiaMinutes, // Duration of Insulin Action

    // Targets
    @Default(70.0) double targetGlucoseMin,
    @Default(180.0) double targetGlucoseMax,
    @Default(90.0) double fastingSetpoint,

    // ML Metabolic Parameters (Local Adaptive Tuning Constants)
    // Default 0.025 is the realistic clearance operating point the projection
    // was calibrated around (previously enforced by a hard floor that silently
    // disabled EKF p1 tuning). EKF refines this per-user within [0.002, 0.030].
    @Default(0.025) double metabolicClearanceRate,
    @Default(50.0) double insulinSensitivityFactor,
    @Default(40.0) double absorptionDelayBase,
    @Default(0) int tuningMealCount, // Tracks meals used for adaptive tuning

    // EKF Covariance State (diagonal elements of P matrix)
    // These store the Kalman filter's uncertainty in each metabolic parameter.
    // High values = high uncertainty (new user), low values = converged estimate.
    @Default(1.0) double ekfCovP1, // Uncertainty in metabolicClearanceRate
    @Default(1.0) double ekfCovISF, // Uncertainty in insulinSensitivityFactor
    @Default(1.0) double ekfCovTMax, // Uncertainty in absorptionDelayBase

    // Meta
    @Default(false) bool hasAgreedToDisclaimer,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
