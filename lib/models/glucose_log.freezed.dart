// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'glucose_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GlucoseLog {

 String get id; DateTime get timestamp; double get value; String get unit;// Enum: mg/dL, mmol/L
 String get context;// Enum stored as string: fasting, pre_meal, post_meal_30, post_meal_120, bedtime, night_time
 String? get notes;// E.g., stress, exercise
 bool get isSynced;
/// Create a copy of GlucoseLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlucoseLogCopyWith<GlucoseLog> get copyWith => _$GlucoseLogCopyWithImpl<GlucoseLog>(this as GlucoseLog, _$identity);

  /// Serializes this GlucoseLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlucoseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.context, context) || other.context == context)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,value,unit,context,notes,isSynced);

@override
String toString() {
  return 'GlucoseLog(id: $id, timestamp: $timestamp, value: $value, unit: $unit, context: $context, notes: $notes, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $GlucoseLogCopyWith<$Res>  {
  factory $GlucoseLogCopyWith(GlucoseLog value, $Res Function(GlucoseLog) _then) = _$GlucoseLogCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, double value, String unit, String context, String? notes, bool isSynced
});




}
/// @nodoc
class _$GlucoseLogCopyWithImpl<$Res>
    implements $GlucoseLogCopyWith<$Res> {
  _$GlucoseLogCopyWithImpl(this._self, this._then);

  final GlucoseLog _self;
  final $Res Function(GlucoseLog) _then;

/// Create a copy of GlucoseLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? value = null,Object? unit = null,Object? context = null,Object? notes = freezed,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GlucoseLog].
extension GlucoseLogPatterns on GlucoseLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlucoseLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlucoseLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlucoseLog value)  $default,){
final _that = this;
switch (_that) {
case _GlucoseLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlucoseLog value)?  $default,){
final _that = this;
switch (_that) {
case _GlucoseLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  double value,  String unit,  String context,  String? notes,  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlucoseLog() when $default != null:
return $default(_that.id,_that.timestamp,_that.value,_that.unit,_that.context,_that.notes,_that.isSynced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  double value,  String unit,  String context,  String? notes,  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _GlucoseLog():
return $default(_that.id,_that.timestamp,_that.value,_that.unit,_that.context,_that.notes,_that.isSynced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  double value,  String unit,  String context,  String? notes,  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _GlucoseLog() when $default != null:
return $default(_that.id,_that.timestamp,_that.value,_that.unit,_that.context,_that.notes,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GlucoseLog implements GlucoseLog {
  const _GlucoseLog({required this.id, required this.timestamp, required this.value, required this.unit, required this.context, this.notes, this.isSynced = false});
  factory _GlucoseLog.fromJson(Map<String, dynamic> json) => _$GlucoseLogFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  double value;
@override final  String unit;
// Enum: mg/dL, mmol/L
@override final  String context;
// Enum stored as string: fasting, pre_meal, post_meal_30, post_meal_120, bedtime, night_time
@override final  String? notes;
// E.g., stress, exercise
@override@JsonKey() final  bool isSynced;

/// Create a copy of GlucoseLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlucoseLogCopyWith<_GlucoseLog> get copyWith => __$GlucoseLogCopyWithImpl<_GlucoseLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GlucoseLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlucoseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.context, context) || other.context == context)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,value,unit,context,notes,isSynced);

@override
String toString() {
  return 'GlucoseLog(id: $id, timestamp: $timestamp, value: $value, unit: $unit, context: $context, notes: $notes, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$GlucoseLogCopyWith<$Res> implements $GlucoseLogCopyWith<$Res> {
  factory _$GlucoseLogCopyWith(_GlucoseLog value, $Res Function(_GlucoseLog) _then) = __$GlucoseLogCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, double value, String unit, String context, String? notes, bool isSynced
});




}
/// @nodoc
class __$GlucoseLogCopyWithImpl<$Res>
    implements _$GlucoseLogCopyWith<$Res> {
  __$GlucoseLogCopyWithImpl(this._self, this._then);

  final _GlucoseLog _self;
  final $Res Function(_GlucoseLog) _then;

/// Create a copy of GlucoseLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? value = null,Object? unit = null,Object? context = null,Object? notes = freezed,Object? isSynced = null,}) {
  return _then(_GlucoseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
