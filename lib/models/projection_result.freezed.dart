// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projection_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectionPoint {

 int get timeMinutes; double get glucoseValue;
/// Create a copy of ProjectionPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectionPointCopyWith<ProjectionPoint> get copyWith => _$ProjectionPointCopyWithImpl<ProjectionPoint>(this as ProjectionPoint, _$identity);

  /// Serializes this ProjectionPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectionPoint&&(identical(other.timeMinutes, timeMinutes) || other.timeMinutes == timeMinutes)&&(identical(other.glucoseValue, glucoseValue) || other.glucoseValue == glucoseValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeMinutes,glucoseValue);

@override
String toString() {
  return 'ProjectionPoint(timeMinutes: $timeMinutes, glucoseValue: $glucoseValue)';
}


}

/// @nodoc
abstract mixin class $ProjectionPointCopyWith<$Res>  {
  factory $ProjectionPointCopyWith(ProjectionPoint value, $Res Function(ProjectionPoint) _then) = _$ProjectionPointCopyWithImpl;
@useResult
$Res call({
 int timeMinutes, double glucoseValue
});




}
/// @nodoc
class _$ProjectionPointCopyWithImpl<$Res>
    implements $ProjectionPointCopyWith<$Res> {
  _$ProjectionPointCopyWithImpl(this._self, this._then);

  final ProjectionPoint _self;
  final $Res Function(ProjectionPoint) _then;

/// Create a copy of ProjectionPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeMinutes = null,Object? glucoseValue = null,}) {
  return _then(_self.copyWith(
timeMinutes: null == timeMinutes ? _self.timeMinutes : timeMinutes // ignore: cast_nullable_to_non_nullable
as int,glucoseValue: null == glucoseValue ? _self.glucoseValue : glucoseValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectionPoint].
extension ProjectionPointPatterns on ProjectionPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectionPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectionPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectionPoint value)  $default,){
final _that = this;
switch (_that) {
case _ProjectionPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectionPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectionPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int timeMinutes,  double glucoseValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectionPoint() when $default != null:
return $default(_that.timeMinutes,_that.glucoseValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int timeMinutes,  double glucoseValue)  $default,) {final _that = this;
switch (_that) {
case _ProjectionPoint():
return $default(_that.timeMinutes,_that.glucoseValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int timeMinutes,  double glucoseValue)?  $default,) {final _that = this;
switch (_that) {
case _ProjectionPoint() when $default != null:
return $default(_that.timeMinutes,_that.glucoseValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectionPoint implements ProjectionPoint {
  const _ProjectionPoint({required this.timeMinutes, required this.glucoseValue});
  factory _ProjectionPoint.fromJson(Map<String, dynamic> json) => _$ProjectionPointFromJson(json);

@override final  int timeMinutes;
@override final  double glucoseValue;

/// Create a copy of ProjectionPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectionPointCopyWith<_ProjectionPoint> get copyWith => __$ProjectionPointCopyWithImpl<_ProjectionPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectionPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectionPoint&&(identical(other.timeMinutes, timeMinutes) || other.timeMinutes == timeMinutes)&&(identical(other.glucoseValue, glucoseValue) || other.glucoseValue == glucoseValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeMinutes,glucoseValue);

@override
String toString() {
  return 'ProjectionPoint(timeMinutes: $timeMinutes, glucoseValue: $glucoseValue)';
}


}

/// @nodoc
abstract mixin class _$ProjectionPointCopyWith<$Res> implements $ProjectionPointCopyWith<$Res> {
  factory _$ProjectionPointCopyWith(_ProjectionPoint value, $Res Function(_ProjectionPoint) _then) = __$ProjectionPointCopyWithImpl;
@override @useResult
$Res call({
 int timeMinutes, double glucoseValue
});




}
/// @nodoc
class __$ProjectionPointCopyWithImpl<$Res>
    implements _$ProjectionPointCopyWith<$Res> {
  __$ProjectionPointCopyWithImpl(this._self, this._then);

  final _ProjectionPoint _self;
  final $Res Function(_ProjectionPoint) _then;

/// Create a copy of ProjectionPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeMinutes = null,Object? glucoseValue = null,}) {
  return _then(_ProjectionPoint(
timeMinutes: null == timeMinutes ? _self.timeMinutes : timeMinutes // ignore: cast_nullable_to_non_nullable
as int,glucoseValue: null == glucoseValue ? _self.glucoseValue : glucoseValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ProjectionResult {

 List<ProjectionPoint> get points; double get peakGlucose; int get peakTimeMinutes; double get twoHourGlucose; double get totalAvailableGlucose;// TAG value
 String get riskLevel;// normal / elevated / high / hypo_risk
 String get summary; List<ProjectionPoint> get upperBand;// +1 SD confidence bound
 List<ProjectionPoint> get lowerBand;// -1 SD confidence bound
 double get confidenceWidth;
/// Create a copy of ProjectionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectionResultCopyWith<ProjectionResult> get copyWith => _$ProjectionResultCopyWithImpl<ProjectionResult>(this as ProjectionResult, _$identity);

  /// Serializes this ProjectionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectionResult&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.peakGlucose, peakGlucose) || other.peakGlucose == peakGlucose)&&(identical(other.peakTimeMinutes, peakTimeMinutes) || other.peakTimeMinutes == peakTimeMinutes)&&(identical(other.twoHourGlucose, twoHourGlucose) || other.twoHourGlucose == twoHourGlucose)&&(identical(other.totalAvailableGlucose, totalAvailableGlucose) || other.totalAvailableGlucose == totalAvailableGlucose)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.upperBand, upperBand)&&const DeepCollectionEquality().equals(other.lowerBand, lowerBand)&&(identical(other.confidenceWidth, confidenceWidth) || other.confidenceWidth == confidenceWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),peakGlucose,peakTimeMinutes,twoHourGlucose,totalAvailableGlucose,riskLevel,summary,const DeepCollectionEquality().hash(upperBand),const DeepCollectionEquality().hash(lowerBand),confidenceWidth);

@override
String toString() {
  return 'ProjectionResult(points: $points, peakGlucose: $peakGlucose, peakTimeMinutes: $peakTimeMinutes, twoHourGlucose: $twoHourGlucose, totalAvailableGlucose: $totalAvailableGlucose, riskLevel: $riskLevel, summary: $summary, upperBand: $upperBand, lowerBand: $lowerBand, confidenceWidth: $confidenceWidth)';
}


}

/// @nodoc
abstract mixin class $ProjectionResultCopyWith<$Res>  {
  factory $ProjectionResultCopyWith(ProjectionResult value, $Res Function(ProjectionResult) _then) = _$ProjectionResultCopyWithImpl;
@useResult
$Res call({
 List<ProjectionPoint> points, double peakGlucose, int peakTimeMinutes, double twoHourGlucose, double totalAvailableGlucose, String riskLevel, String summary, List<ProjectionPoint> upperBand, List<ProjectionPoint> lowerBand, double confidenceWidth
});




}
/// @nodoc
class _$ProjectionResultCopyWithImpl<$Res>
    implements $ProjectionResultCopyWith<$Res> {
  _$ProjectionResultCopyWithImpl(this._self, this._then);

  final ProjectionResult _self;
  final $Res Function(ProjectionResult) _then;

/// Create a copy of ProjectionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? peakGlucose = null,Object? peakTimeMinutes = null,Object? twoHourGlucose = null,Object? totalAvailableGlucose = null,Object? riskLevel = null,Object? summary = null,Object? upperBand = null,Object? lowerBand = null,Object? confidenceWidth = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,peakGlucose: null == peakGlucose ? _self.peakGlucose : peakGlucose // ignore: cast_nullable_to_non_nullable
as double,peakTimeMinutes: null == peakTimeMinutes ? _self.peakTimeMinutes : peakTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,twoHourGlucose: null == twoHourGlucose ? _self.twoHourGlucose : twoHourGlucose // ignore: cast_nullable_to_non_nullable
as double,totalAvailableGlucose: null == totalAvailableGlucose ? _self.totalAvailableGlucose : totalAvailableGlucose // ignore: cast_nullable_to_non_nullable
as double,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,upperBand: null == upperBand ? _self.upperBand : upperBand // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,lowerBand: null == lowerBand ? _self.lowerBand : lowerBand // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,confidenceWidth: null == confidenceWidth ? _self.confidenceWidth : confidenceWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectionResult].
extension ProjectionResultPatterns on ProjectionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectionResult value)  $default,){
final _that = this;
switch (_that) {
case _ProjectionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectionResult value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProjectionPoint> points,  double peakGlucose,  int peakTimeMinutes,  double twoHourGlucose,  double totalAvailableGlucose,  String riskLevel,  String summary,  List<ProjectionPoint> upperBand,  List<ProjectionPoint> lowerBand,  double confidenceWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectionResult() when $default != null:
return $default(_that.points,_that.peakGlucose,_that.peakTimeMinutes,_that.twoHourGlucose,_that.totalAvailableGlucose,_that.riskLevel,_that.summary,_that.upperBand,_that.lowerBand,_that.confidenceWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProjectionPoint> points,  double peakGlucose,  int peakTimeMinutes,  double twoHourGlucose,  double totalAvailableGlucose,  String riskLevel,  String summary,  List<ProjectionPoint> upperBand,  List<ProjectionPoint> lowerBand,  double confidenceWidth)  $default,) {final _that = this;
switch (_that) {
case _ProjectionResult():
return $default(_that.points,_that.peakGlucose,_that.peakTimeMinutes,_that.twoHourGlucose,_that.totalAvailableGlucose,_that.riskLevel,_that.summary,_that.upperBand,_that.lowerBand,_that.confidenceWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProjectionPoint> points,  double peakGlucose,  int peakTimeMinutes,  double twoHourGlucose,  double totalAvailableGlucose,  String riskLevel,  String summary,  List<ProjectionPoint> upperBand,  List<ProjectionPoint> lowerBand,  double confidenceWidth)?  $default,) {final _that = this;
switch (_that) {
case _ProjectionResult() when $default != null:
return $default(_that.points,_that.peakGlucose,_that.peakTimeMinutes,_that.twoHourGlucose,_that.totalAvailableGlucose,_that.riskLevel,_that.summary,_that.upperBand,_that.lowerBand,_that.confidenceWidth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectionResult implements ProjectionResult {
  const _ProjectionResult({required final  List<ProjectionPoint> points, required this.peakGlucose, required this.peakTimeMinutes, required this.twoHourGlucose, required this.totalAvailableGlucose, required this.riskLevel, required this.summary, final  List<ProjectionPoint> upperBand = const [], final  List<ProjectionPoint> lowerBand = const [], this.confidenceWidth = 25.0}): _points = points,_upperBand = upperBand,_lowerBand = lowerBand;
  factory _ProjectionResult.fromJson(Map<String, dynamic> json) => _$ProjectionResultFromJson(json);

 final  List<ProjectionPoint> _points;
@override List<ProjectionPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  double peakGlucose;
@override final  int peakTimeMinutes;
@override final  double twoHourGlucose;
@override final  double totalAvailableGlucose;
// TAG value
@override final  String riskLevel;
// normal / elevated / high / hypo_risk
@override final  String summary;
 final  List<ProjectionPoint> _upperBand;
@override@JsonKey() List<ProjectionPoint> get upperBand {
  if (_upperBand is EqualUnmodifiableListView) return _upperBand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upperBand);
}

// +1 SD confidence bound
 final  List<ProjectionPoint> _lowerBand;
// +1 SD confidence bound
@override@JsonKey() List<ProjectionPoint> get lowerBand {
  if (_lowerBand is EqualUnmodifiableListView) return _lowerBand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lowerBand);
}

// -1 SD confidence bound
@override@JsonKey() final  double confidenceWidth;

/// Create a copy of ProjectionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectionResultCopyWith<_ProjectionResult> get copyWith => __$ProjectionResultCopyWithImpl<_ProjectionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectionResult&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.peakGlucose, peakGlucose) || other.peakGlucose == peakGlucose)&&(identical(other.peakTimeMinutes, peakTimeMinutes) || other.peakTimeMinutes == peakTimeMinutes)&&(identical(other.twoHourGlucose, twoHourGlucose) || other.twoHourGlucose == twoHourGlucose)&&(identical(other.totalAvailableGlucose, totalAvailableGlucose) || other.totalAvailableGlucose == totalAvailableGlucose)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._upperBand, _upperBand)&&const DeepCollectionEquality().equals(other._lowerBand, _lowerBand)&&(identical(other.confidenceWidth, confidenceWidth) || other.confidenceWidth == confidenceWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),peakGlucose,peakTimeMinutes,twoHourGlucose,totalAvailableGlucose,riskLevel,summary,const DeepCollectionEquality().hash(_upperBand),const DeepCollectionEquality().hash(_lowerBand),confidenceWidth);

@override
String toString() {
  return 'ProjectionResult(points: $points, peakGlucose: $peakGlucose, peakTimeMinutes: $peakTimeMinutes, twoHourGlucose: $twoHourGlucose, totalAvailableGlucose: $totalAvailableGlucose, riskLevel: $riskLevel, summary: $summary, upperBand: $upperBand, lowerBand: $lowerBand, confidenceWidth: $confidenceWidth)';
}


}

/// @nodoc
abstract mixin class _$ProjectionResultCopyWith<$Res> implements $ProjectionResultCopyWith<$Res> {
  factory _$ProjectionResultCopyWith(_ProjectionResult value, $Res Function(_ProjectionResult) _then) = __$ProjectionResultCopyWithImpl;
@override @useResult
$Res call({
 List<ProjectionPoint> points, double peakGlucose, int peakTimeMinutes, double twoHourGlucose, double totalAvailableGlucose, String riskLevel, String summary, List<ProjectionPoint> upperBand, List<ProjectionPoint> lowerBand, double confidenceWidth
});




}
/// @nodoc
class __$ProjectionResultCopyWithImpl<$Res>
    implements _$ProjectionResultCopyWith<$Res> {
  __$ProjectionResultCopyWithImpl(this._self, this._then);

  final _ProjectionResult _self;
  final $Res Function(_ProjectionResult) _then;

/// Create a copy of ProjectionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? peakGlucose = null,Object? peakTimeMinutes = null,Object? twoHourGlucose = null,Object? totalAvailableGlucose = null,Object? riskLevel = null,Object? summary = null,Object? upperBand = null,Object? lowerBand = null,Object? confidenceWidth = null,}) {
  return _then(_ProjectionResult(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,peakGlucose: null == peakGlucose ? _self.peakGlucose : peakGlucose // ignore: cast_nullable_to_non_nullable
as double,peakTimeMinutes: null == peakTimeMinutes ? _self.peakTimeMinutes : peakTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,twoHourGlucose: null == twoHourGlucose ? _self.twoHourGlucose : twoHourGlucose // ignore: cast_nullable_to_non_nullable
as double,totalAvailableGlucose: null == totalAvailableGlucose ? _self.totalAvailableGlucose : totalAvailableGlucose // ignore: cast_nullable_to_non_nullable
as double,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,upperBand: null == upperBand ? _self._upperBand : upperBand // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,lowerBand: null == lowerBand ? _self._lowerBand : lowerBand // ignore: cast_nullable_to_non_nullable
as List<ProjectionPoint>,confidenceWidth: null == confidenceWidth ? _self.confidenceWidth : confidenceWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
