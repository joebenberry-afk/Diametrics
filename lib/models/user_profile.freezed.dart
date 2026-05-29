// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id;// Demographics
 String get name; int get age; String get gender; double get heightCm; double get weightKg; double? get targetWeightKg;// Diabetes Context
 String get diabetesType; int get diagnosisYear; String get preferredGlucoseUnit;// Management
 bool get usesInsulin; bool get usesPills; bool get usesCgm;// Insulin Configuration (set once during onboarding)
// Categories: 'ultra_fast', 'standard_rapid', 'regular', 'basal_only', 'none'
 String get insulinCategory; double get insulinDiaMinutes;// Duration of Insulin Action
// Targets
 double get targetGlucoseMin; double get targetGlucoseMax; double get fastingSetpoint;// ML Metabolic Parameters (Local Adaptive Tuning Constants)
// Default 0.025 is the realistic clearance operating point the projection
// was calibrated around (previously enforced by a hard floor that silently
// disabled EKF p1 tuning). EKF refines this per-user within [0.002, 0.030].
 double get metabolicClearanceRate; double get insulinSensitivityFactor; double get absorptionDelayBase; int get tuningMealCount;// Tracks meals used for adaptive tuning
// EKF Covariance State (diagonal elements of P matrix)
// These store the Kalman filter's uncertainty in each metabolic parameter.
// High values = high uncertainty (new user), low values = converged estimate.
 double get ekfCovP1;// Uncertainty in metabolicClearanceRate
 double get ekfCovISF;// Uncertainty in insulinSensitivityFactor
 double get ekfCovTMax;// Uncertainty in absorptionDelayBase
// Meta
 bool get hasAgreedToDisclaimer; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.diabetesType, diabetesType) || other.diabetesType == diabetesType)&&(identical(other.diagnosisYear, diagnosisYear) || other.diagnosisYear == diagnosisYear)&&(identical(other.preferredGlucoseUnit, preferredGlucoseUnit) || other.preferredGlucoseUnit == preferredGlucoseUnit)&&(identical(other.usesInsulin, usesInsulin) || other.usesInsulin == usesInsulin)&&(identical(other.usesPills, usesPills) || other.usesPills == usesPills)&&(identical(other.usesCgm, usesCgm) || other.usesCgm == usesCgm)&&(identical(other.insulinCategory, insulinCategory) || other.insulinCategory == insulinCategory)&&(identical(other.insulinDiaMinutes, insulinDiaMinutes) || other.insulinDiaMinutes == insulinDiaMinutes)&&(identical(other.targetGlucoseMin, targetGlucoseMin) || other.targetGlucoseMin == targetGlucoseMin)&&(identical(other.targetGlucoseMax, targetGlucoseMax) || other.targetGlucoseMax == targetGlucoseMax)&&(identical(other.fastingSetpoint, fastingSetpoint) || other.fastingSetpoint == fastingSetpoint)&&(identical(other.metabolicClearanceRate, metabolicClearanceRate) || other.metabolicClearanceRate == metabolicClearanceRate)&&(identical(other.insulinSensitivityFactor, insulinSensitivityFactor) || other.insulinSensitivityFactor == insulinSensitivityFactor)&&(identical(other.absorptionDelayBase, absorptionDelayBase) || other.absorptionDelayBase == absorptionDelayBase)&&(identical(other.tuningMealCount, tuningMealCount) || other.tuningMealCount == tuningMealCount)&&(identical(other.ekfCovP1, ekfCovP1) || other.ekfCovP1 == ekfCovP1)&&(identical(other.ekfCovISF, ekfCovISF) || other.ekfCovISF == ekfCovISF)&&(identical(other.ekfCovTMax, ekfCovTMax) || other.ekfCovTMax == ekfCovTMax)&&(identical(other.hasAgreedToDisclaimer, hasAgreedToDisclaimer) || other.hasAgreedToDisclaimer == hasAgreedToDisclaimer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,age,gender,heightCm,weightKg,targetWeightKg,diabetesType,diagnosisYear,preferredGlucoseUnit,usesInsulin,usesPills,usesCgm,insulinCategory,insulinDiaMinutes,targetGlucoseMin,targetGlucoseMax,fastingSetpoint,metabolicClearanceRate,insulinSensitivityFactor,absorptionDelayBase,tuningMealCount,ekfCovP1,ekfCovISF,ekfCovTMax,hasAgreedToDisclaimer,createdAt,updatedAt]);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, targetWeightKg: $targetWeightKg, diabetesType: $diabetesType, diagnosisYear: $diagnosisYear, preferredGlucoseUnit: $preferredGlucoseUnit, usesInsulin: $usesInsulin, usesPills: $usesPills, usesCgm: $usesCgm, insulinCategory: $insulinCategory, insulinDiaMinutes: $insulinDiaMinutes, targetGlucoseMin: $targetGlucoseMin, targetGlucoseMax: $targetGlucoseMax, fastingSetpoint: $fastingSetpoint, metabolicClearanceRate: $metabolicClearanceRate, insulinSensitivityFactor: $insulinSensitivityFactor, absorptionDelayBase: $absorptionDelayBase, tuningMealCount: $tuningMealCount, ekfCovP1: $ekfCovP1, ekfCovISF: $ekfCovISF, ekfCovTMax: $ekfCovTMax, hasAgreedToDisclaimer: $hasAgreedToDisclaimer, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, int age, String gender, double heightCm, double weightKg, double? targetWeightKg, String diabetesType, int diagnosisYear, String preferredGlucoseUnit, bool usesInsulin, bool usesPills, bool usesCgm, String insulinCategory, double insulinDiaMinutes, double targetGlucoseMin, double targetGlucoseMax, double fastingSetpoint, double metabolicClearanceRate, double insulinSensitivityFactor, double absorptionDelayBase, int tuningMealCount, double ekfCovP1, double ekfCovISF, double ekfCovTMax, bool hasAgreedToDisclaimer, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? age = null,Object? gender = null,Object? heightCm = null,Object? weightKg = null,Object? targetWeightKg = freezed,Object? diabetesType = null,Object? diagnosisYear = null,Object? preferredGlucoseUnit = null,Object? usesInsulin = null,Object? usesPills = null,Object? usesCgm = null,Object? insulinCategory = null,Object? insulinDiaMinutes = null,Object? targetGlucoseMin = null,Object? targetGlucoseMax = null,Object? fastingSetpoint = null,Object? metabolicClearanceRate = null,Object? insulinSensitivityFactor = null,Object? absorptionDelayBase = null,Object? tuningMealCount = null,Object? ekfCovP1 = null,Object? ekfCovISF = null,Object? ekfCovTMax = null,Object? hasAgreedToDisclaimer = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,diabetesType: null == diabetesType ? _self.diabetesType : diabetesType // ignore: cast_nullable_to_non_nullable
as String,diagnosisYear: null == diagnosisYear ? _self.diagnosisYear : diagnosisYear // ignore: cast_nullable_to_non_nullable
as int,preferredGlucoseUnit: null == preferredGlucoseUnit ? _self.preferredGlucoseUnit : preferredGlucoseUnit // ignore: cast_nullable_to_non_nullable
as String,usesInsulin: null == usesInsulin ? _self.usesInsulin : usesInsulin // ignore: cast_nullable_to_non_nullable
as bool,usesPills: null == usesPills ? _self.usesPills : usesPills // ignore: cast_nullable_to_non_nullable
as bool,usesCgm: null == usesCgm ? _self.usesCgm : usesCgm // ignore: cast_nullable_to_non_nullable
as bool,insulinCategory: null == insulinCategory ? _self.insulinCategory : insulinCategory // ignore: cast_nullable_to_non_nullable
as String,insulinDiaMinutes: null == insulinDiaMinutes ? _self.insulinDiaMinutes : insulinDiaMinutes // ignore: cast_nullable_to_non_nullable
as double,targetGlucoseMin: null == targetGlucoseMin ? _self.targetGlucoseMin : targetGlucoseMin // ignore: cast_nullable_to_non_nullable
as double,targetGlucoseMax: null == targetGlucoseMax ? _self.targetGlucoseMax : targetGlucoseMax // ignore: cast_nullable_to_non_nullable
as double,fastingSetpoint: null == fastingSetpoint ? _self.fastingSetpoint : fastingSetpoint // ignore: cast_nullable_to_non_nullable
as double,metabolicClearanceRate: null == metabolicClearanceRate ? _self.metabolicClearanceRate : metabolicClearanceRate // ignore: cast_nullable_to_non_nullable
as double,insulinSensitivityFactor: null == insulinSensitivityFactor ? _self.insulinSensitivityFactor : insulinSensitivityFactor // ignore: cast_nullable_to_non_nullable
as double,absorptionDelayBase: null == absorptionDelayBase ? _self.absorptionDelayBase : absorptionDelayBase // ignore: cast_nullable_to_non_nullable
as double,tuningMealCount: null == tuningMealCount ? _self.tuningMealCount : tuningMealCount // ignore: cast_nullable_to_non_nullable
as int,ekfCovP1: null == ekfCovP1 ? _self.ekfCovP1 : ekfCovP1 // ignore: cast_nullable_to_non_nullable
as double,ekfCovISF: null == ekfCovISF ? _self.ekfCovISF : ekfCovISF // ignore: cast_nullable_to_non_nullable
as double,ekfCovTMax: null == ekfCovTMax ? _self.ekfCovTMax : ekfCovTMax // ignore: cast_nullable_to_non_nullable
as double,hasAgreedToDisclaimer: null == hasAgreedToDisclaimer ? _self.hasAgreedToDisclaimer : hasAgreedToDisclaimer // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String gender,  double heightCm,  double weightKg,  double? targetWeightKg,  String diabetesType,  int diagnosisYear,  String preferredGlucoseUnit,  bool usesInsulin,  bool usesPills,  bool usesCgm,  String insulinCategory,  double insulinDiaMinutes,  double targetGlucoseMin,  double targetGlucoseMax,  double fastingSetpoint,  double metabolicClearanceRate,  double insulinSensitivityFactor,  double absorptionDelayBase,  int tuningMealCount,  double ekfCovP1,  double ekfCovISF,  double ekfCovTMax,  bool hasAgreedToDisclaimer,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.targetWeightKg,_that.diabetesType,_that.diagnosisYear,_that.preferredGlucoseUnit,_that.usesInsulin,_that.usesPills,_that.usesCgm,_that.insulinCategory,_that.insulinDiaMinutes,_that.targetGlucoseMin,_that.targetGlucoseMax,_that.fastingSetpoint,_that.metabolicClearanceRate,_that.insulinSensitivityFactor,_that.absorptionDelayBase,_that.tuningMealCount,_that.ekfCovP1,_that.ekfCovISF,_that.ekfCovTMax,_that.hasAgreedToDisclaimer,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String gender,  double heightCm,  double weightKg,  double? targetWeightKg,  String diabetesType,  int diagnosisYear,  String preferredGlucoseUnit,  bool usesInsulin,  bool usesPills,  bool usesCgm,  String insulinCategory,  double insulinDiaMinutes,  double targetGlucoseMin,  double targetGlucoseMax,  double fastingSetpoint,  double metabolicClearanceRate,  double insulinSensitivityFactor,  double absorptionDelayBase,  int tuningMealCount,  double ekfCovP1,  double ekfCovISF,  double ekfCovTMax,  bool hasAgreedToDisclaimer,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.name,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.targetWeightKg,_that.diabetesType,_that.diagnosisYear,_that.preferredGlucoseUnit,_that.usesInsulin,_that.usesPills,_that.usesCgm,_that.insulinCategory,_that.insulinDiaMinutes,_that.targetGlucoseMin,_that.targetGlucoseMax,_that.fastingSetpoint,_that.metabolicClearanceRate,_that.insulinSensitivityFactor,_that.absorptionDelayBase,_that.tuningMealCount,_that.ekfCovP1,_that.ekfCovISF,_that.ekfCovTMax,_that.hasAgreedToDisclaimer,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int age,  String gender,  double heightCm,  double weightKg,  double? targetWeightKg,  String diabetesType,  int diagnosisYear,  String preferredGlucoseUnit,  bool usesInsulin,  bool usesPills,  bool usesCgm,  String insulinCategory,  double insulinDiaMinutes,  double targetGlucoseMin,  double targetGlucoseMax,  double fastingSetpoint,  double metabolicClearanceRate,  double insulinSensitivityFactor,  double absorptionDelayBase,  int tuningMealCount,  double ekfCovP1,  double ekfCovISF,  double ekfCovTMax,  bool hasAgreedToDisclaimer,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.targetWeightKg,_that.diabetesType,_that.diagnosisYear,_that.preferredGlucoseUnit,_that.usesInsulin,_that.usesPills,_that.usesCgm,_that.insulinCategory,_that.insulinDiaMinutes,_that.targetGlucoseMin,_that.targetGlucoseMax,_that.fastingSetpoint,_that.metabolicClearanceRate,_that.insulinSensitivityFactor,_that.absorptionDelayBase,_that.tuningMealCount,_that.ekfCovP1,_that.ekfCovISF,_that.ekfCovTMax,_that.hasAgreedToDisclaimer,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, this.name = '', required this.age, required this.gender, required this.heightCm, required this.weightKg, this.targetWeightKg, required this.diabetesType, required this.diagnosisYear, this.preferredGlucoseUnit = 'mg/dL', this.usesInsulin = false, this.usesPills = false, this.usesCgm = false, this.insulinCategory = 'standard_rapid', this.insulinDiaMinutes = 240.0, this.targetGlucoseMin = 70.0, this.targetGlucoseMax = 180.0, this.fastingSetpoint = 90.0, this.metabolicClearanceRate = 0.025, this.insulinSensitivityFactor = 50.0, this.absorptionDelayBase = 40.0, this.tuningMealCount = 0, this.ekfCovP1 = 1.0, this.ekfCovISF = 1.0, this.ekfCovTMax = 1.0, this.hasAgreedToDisclaimer = false, required this.createdAt, required this.updatedAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
// Demographics
@override@JsonKey() final  String name;
@override final  int age;
@override final  String gender;
@override final  double heightCm;
@override final  double weightKg;
@override final  double? targetWeightKg;
// Diabetes Context
@override final  String diabetesType;
@override final  int diagnosisYear;
@override@JsonKey() final  String preferredGlucoseUnit;
// Management
@override@JsonKey() final  bool usesInsulin;
@override@JsonKey() final  bool usesPills;
@override@JsonKey() final  bool usesCgm;
// Insulin Configuration (set once during onboarding)
// Categories: 'ultra_fast', 'standard_rapid', 'regular', 'basal_only', 'none'
@override@JsonKey() final  String insulinCategory;
@override@JsonKey() final  double insulinDiaMinutes;
// Duration of Insulin Action
// Targets
@override@JsonKey() final  double targetGlucoseMin;
@override@JsonKey() final  double targetGlucoseMax;
@override@JsonKey() final  double fastingSetpoint;
// ML Metabolic Parameters (Local Adaptive Tuning Constants)
// Default 0.025 is the realistic clearance operating point the projection
// was calibrated around (previously enforced by a hard floor that silently
// disabled EKF p1 tuning). EKF refines this per-user within [0.002, 0.030].
@override@JsonKey() final  double metabolicClearanceRate;
@override@JsonKey() final  double insulinSensitivityFactor;
@override@JsonKey() final  double absorptionDelayBase;
@override@JsonKey() final  int tuningMealCount;
// Tracks meals used for adaptive tuning
// EKF Covariance State (diagonal elements of P matrix)
// These store the Kalman filter's uncertainty in each metabolic parameter.
// High values = high uncertainty (new user), low values = converged estimate.
@override@JsonKey() final  double ekfCovP1;
// Uncertainty in metabolicClearanceRate
@override@JsonKey() final  double ekfCovISF;
// Uncertainty in insulinSensitivityFactor
@override@JsonKey() final  double ekfCovTMax;
// Uncertainty in absorptionDelayBase
// Meta
@override@JsonKey() final  bool hasAgreedToDisclaimer;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.diabetesType, diabetesType) || other.diabetesType == diabetesType)&&(identical(other.diagnosisYear, diagnosisYear) || other.diagnosisYear == diagnosisYear)&&(identical(other.preferredGlucoseUnit, preferredGlucoseUnit) || other.preferredGlucoseUnit == preferredGlucoseUnit)&&(identical(other.usesInsulin, usesInsulin) || other.usesInsulin == usesInsulin)&&(identical(other.usesPills, usesPills) || other.usesPills == usesPills)&&(identical(other.usesCgm, usesCgm) || other.usesCgm == usesCgm)&&(identical(other.insulinCategory, insulinCategory) || other.insulinCategory == insulinCategory)&&(identical(other.insulinDiaMinutes, insulinDiaMinutes) || other.insulinDiaMinutes == insulinDiaMinutes)&&(identical(other.targetGlucoseMin, targetGlucoseMin) || other.targetGlucoseMin == targetGlucoseMin)&&(identical(other.targetGlucoseMax, targetGlucoseMax) || other.targetGlucoseMax == targetGlucoseMax)&&(identical(other.fastingSetpoint, fastingSetpoint) || other.fastingSetpoint == fastingSetpoint)&&(identical(other.metabolicClearanceRate, metabolicClearanceRate) || other.metabolicClearanceRate == metabolicClearanceRate)&&(identical(other.insulinSensitivityFactor, insulinSensitivityFactor) || other.insulinSensitivityFactor == insulinSensitivityFactor)&&(identical(other.absorptionDelayBase, absorptionDelayBase) || other.absorptionDelayBase == absorptionDelayBase)&&(identical(other.tuningMealCount, tuningMealCount) || other.tuningMealCount == tuningMealCount)&&(identical(other.ekfCovP1, ekfCovP1) || other.ekfCovP1 == ekfCovP1)&&(identical(other.ekfCovISF, ekfCovISF) || other.ekfCovISF == ekfCovISF)&&(identical(other.ekfCovTMax, ekfCovTMax) || other.ekfCovTMax == ekfCovTMax)&&(identical(other.hasAgreedToDisclaimer, hasAgreedToDisclaimer) || other.hasAgreedToDisclaimer == hasAgreedToDisclaimer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,age,gender,heightCm,weightKg,targetWeightKg,diabetesType,diagnosisYear,preferredGlucoseUnit,usesInsulin,usesPills,usesCgm,insulinCategory,insulinDiaMinutes,targetGlucoseMin,targetGlucoseMax,fastingSetpoint,metabolicClearanceRate,insulinSensitivityFactor,absorptionDelayBase,tuningMealCount,ekfCovP1,ekfCovISF,ekfCovTMax,hasAgreedToDisclaimer,createdAt,updatedAt]);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, targetWeightKg: $targetWeightKg, diabetesType: $diabetesType, diagnosisYear: $diagnosisYear, preferredGlucoseUnit: $preferredGlucoseUnit, usesInsulin: $usesInsulin, usesPills: $usesPills, usesCgm: $usesCgm, insulinCategory: $insulinCategory, insulinDiaMinutes: $insulinDiaMinutes, targetGlucoseMin: $targetGlucoseMin, targetGlucoseMax: $targetGlucoseMax, fastingSetpoint: $fastingSetpoint, metabolicClearanceRate: $metabolicClearanceRate, insulinSensitivityFactor: $insulinSensitivityFactor, absorptionDelayBase: $absorptionDelayBase, tuningMealCount: $tuningMealCount, ekfCovP1: $ekfCovP1, ekfCovISF: $ekfCovISF, ekfCovTMax: $ekfCovTMax, hasAgreedToDisclaimer: $hasAgreedToDisclaimer, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int age, String gender, double heightCm, double weightKg, double? targetWeightKg, String diabetesType, int diagnosisYear, String preferredGlucoseUnit, bool usesInsulin, bool usesPills, bool usesCgm, String insulinCategory, double insulinDiaMinutes, double targetGlucoseMin, double targetGlucoseMax, double fastingSetpoint, double metabolicClearanceRate, double insulinSensitivityFactor, double absorptionDelayBase, int tuningMealCount, double ekfCovP1, double ekfCovISF, double ekfCovTMax, bool hasAgreedToDisclaimer, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? age = null,Object? gender = null,Object? heightCm = null,Object? weightKg = null,Object? targetWeightKg = freezed,Object? diabetesType = null,Object? diagnosisYear = null,Object? preferredGlucoseUnit = null,Object? usesInsulin = null,Object? usesPills = null,Object? usesCgm = null,Object? insulinCategory = null,Object? insulinDiaMinutes = null,Object? targetGlucoseMin = null,Object? targetGlucoseMax = null,Object? fastingSetpoint = null,Object? metabolicClearanceRate = null,Object? insulinSensitivityFactor = null,Object? absorptionDelayBase = null,Object? tuningMealCount = null,Object? ekfCovP1 = null,Object? ekfCovISF = null,Object? ekfCovTMax = null,Object? hasAgreedToDisclaimer = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,diabetesType: null == diabetesType ? _self.diabetesType : diabetesType // ignore: cast_nullable_to_non_nullable
as String,diagnosisYear: null == diagnosisYear ? _self.diagnosisYear : diagnosisYear // ignore: cast_nullable_to_non_nullable
as int,preferredGlucoseUnit: null == preferredGlucoseUnit ? _self.preferredGlucoseUnit : preferredGlucoseUnit // ignore: cast_nullable_to_non_nullable
as String,usesInsulin: null == usesInsulin ? _self.usesInsulin : usesInsulin // ignore: cast_nullable_to_non_nullable
as bool,usesPills: null == usesPills ? _self.usesPills : usesPills // ignore: cast_nullable_to_non_nullable
as bool,usesCgm: null == usesCgm ? _self.usesCgm : usesCgm // ignore: cast_nullable_to_non_nullable
as bool,insulinCategory: null == insulinCategory ? _self.insulinCategory : insulinCategory // ignore: cast_nullable_to_non_nullable
as String,insulinDiaMinutes: null == insulinDiaMinutes ? _self.insulinDiaMinutes : insulinDiaMinutes // ignore: cast_nullable_to_non_nullable
as double,targetGlucoseMin: null == targetGlucoseMin ? _self.targetGlucoseMin : targetGlucoseMin // ignore: cast_nullable_to_non_nullable
as double,targetGlucoseMax: null == targetGlucoseMax ? _self.targetGlucoseMax : targetGlucoseMax // ignore: cast_nullable_to_non_nullable
as double,fastingSetpoint: null == fastingSetpoint ? _self.fastingSetpoint : fastingSetpoint // ignore: cast_nullable_to_non_nullable
as double,metabolicClearanceRate: null == metabolicClearanceRate ? _self.metabolicClearanceRate : metabolicClearanceRate // ignore: cast_nullable_to_non_nullable
as double,insulinSensitivityFactor: null == insulinSensitivityFactor ? _self.insulinSensitivityFactor : insulinSensitivityFactor // ignore: cast_nullable_to_non_nullable
as double,absorptionDelayBase: null == absorptionDelayBase ? _self.absorptionDelayBase : absorptionDelayBase // ignore: cast_nullable_to_non_nullable
as double,tuningMealCount: null == tuningMealCount ? _self.tuningMealCount : tuningMealCount // ignore: cast_nullable_to_non_nullable
as int,ekfCovP1: null == ekfCovP1 ? _self.ekfCovP1 : ekfCovP1 // ignore: cast_nullable_to_non_nullable
as double,ekfCovISF: null == ekfCovISF ? _self.ekfCovISF : ekfCovISF // ignore: cast_nullable_to_non_nullable
as double,ekfCovTMax: null == ekfCovTMax ? _self.ekfCovTMax : ekfCovTMax // ignore: cast_nullable_to_non_nullable
as double,hasAgreedToDisclaimer: null == hasAgreedToDisclaimer ? _self.hasAgreedToDisclaimer : hasAgreedToDisclaimer // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
