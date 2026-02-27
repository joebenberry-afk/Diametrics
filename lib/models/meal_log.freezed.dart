// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealLog {

 String get id; DateTime get timestamp; String? get name; double get carbohydrates;// Required for baseline bolus calculation
 double get dietaryFiber;// To calculate net carbs and gastric delay
 double get proteins;// Spikes BG 3-6 hrs post-meal
 double get fats;// Delays gastric emptying
 double get calories; bool get containsAlcohol;// Inhibits gluconeogenesis
 bool get containsCaffeine;// Can spike BG
 String get mealType;// Enum stored as string: breakfast, lunch, dinner, snack
 String? get notes; bool get isSynced;
/// Create a copy of MealLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealLogCopyWith<MealLog> get copyWith => _$MealLogCopyWithImpl<MealLog>(this as MealLog, _$identity);

  /// Serializes this MealLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealLog&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.name, name) || other.name == name)&&(identical(other.carbohydrates, carbohydrates) || other.carbohydrates == carbohydrates)&&(identical(other.dietaryFiber, dietaryFiber) || other.dietaryFiber == dietaryFiber)&&(identical(other.proteins, proteins) || other.proteins == proteins)&&(identical(other.fats, fats) || other.fats == fats)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.containsAlcohol, containsAlcohol) || other.containsAlcohol == containsAlcohol)&&(identical(other.containsCaffeine, containsCaffeine) || other.containsCaffeine == containsCaffeine)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,name,carbohydrates,dietaryFiber,proteins,fats,calories,containsAlcohol,containsCaffeine,mealType,notes,isSynced);

@override
String toString() {
  return 'MealLog(id: $id, timestamp: $timestamp, name: $name, carbohydrates: $carbohydrates, dietaryFiber: $dietaryFiber, proteins: $proteins, fats: $fats, calories: $calories, containsAlcohol: $containsAlcohol, containsCaffeine: $containsCaffeine, mealType: $mealType, notes: $notes, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $MealLogCopyWith<$Res>  {
  factory $MealLogCopyWith(MealLog value, $Res Function(MealLog) _then) = _$MealLogCopyWithImpl;
@useResult
$Res call({
 String id, DateTime timestamp, String? name, double carbohydrates, double dietaryFiber, double proteins, double fats, double calories, bool containsAlcohol, bool containsCaffeine, String mealType, String? notes, bool isSynced
});




}
/// @nodoc
class _$MealLogCopyWithImpl<$Res>
    implements $MealLogCopyWith<$Res> {
  _$MealLogCopyWithImpl(this._self, this._then);

  final MealLog _self;
  final $Res Function(MealLog) _then;

/// Create a copy of MealLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? name = freezed,Object? carbohydrates = null,Object? dietaryFiber = null,Object? proteins = null,Object? fats = null,Object? calories = null,Object? containsAlcohol = null,Object? containsCaffeine = null,Object? mealType = null,Object? notes = freezed,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,carbohydrates: null == carbohydrates ? _self.carbohydrates : carbohydrates // ignore: cast_nullable_to_non_nullable
as double,dietaryFiber: null == dietaryFiber ? _self.dietaryFiber : dietaryFiber // ignore: cast_nullable_to_non_nullable
as double,proteins: null == proteins ? _self.proteins : proteins // ignore: cast_nullable_to_non_nullable
as double,fats: null == fats ? _self.fats : fats // ignore: cast_nullable_to_non_nullable
as double,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,containsAlcohol: null == containsAlcohol ? _self.containsAlcohol : containsAlcohol // ignore: cast_nullable_to_non_nullable
as bool,containsCaffeine: null == containsCaffeine ? _self.containsCaffeine : containsCaffeine // ignore: cast_nullable_to_non_nullable
as bool,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MealLog].
extension MealLogPatterns on MealLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealLog value)  $default,){
final _that = this;
switch (_that) {
case _MealLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealLog value)?  $default,){
final _that = this;
switch (_that) {
case _MealLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String? name,  double carbohydrates,  double dietaryFiber,  double proteins,  double fats,  double calories,  bool containsAlcohol,  bool containsCaffeine,  String mealType,  String? notes,  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealLog() when $default != null:
return $default(_that.id,_that.timestamp,_that.name,_that.carbohydrates,_that.dietaryFiber,_that.proteins,_that.fats,_that.calories,_that.containsAlcohol,_that.containsCaffeine,_that.mealType,_that.notes,_that.isSynced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime timestamp,  String? name,  double carbohydrates,  double dietaryFiber,  double proteins,  double fats,  double calories,  bool containsAlcohol,  bool containsCaffeine,  String mealType,  String? notes,  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _MealLog():
return $default(_that.id,_that.timestamp,_that.name,_that.carbohydrates,_that.dietaryFiber,_that.proteins,_that.fats,_that.calories,_that.containsAlcohol,_that.containsCaffeine,_that.mealType,_that.notes,_that.isSynced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime timestamp,  String? name,  double carbohydrates,  double dietaryFiber,  double proteins,  double fats,  double calories,  bool containsAlcohol,  bool containsCaffeine,  String mealType,  String? notes,  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _MealLog() when $default != null:
return $default(_that.id,_that.timestamp,_that.name,_that.carbohydrates,_that.dietaryFiber,_that.proteins,_that.fats,_that.calories,_that.containsAlcohol,_that.containsCaffeine,_that.mealType,_that.notes,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealLog implements MealLog {
  const _MealLog({required this.id, required this.timestamp, this.name, required this.carbohydrates, this.dietaryFiber = 0.0, required this.proteins, required this.fats, this.calories = 0.0, this.containsAlcohol = false, this.containsCaffeine = false, required this.mealType, this.notes, this.isSynced = false});
  factory _MealLog.fromJson(Map<String, dynamic> json) => _$MealLogFromJson(json);

@override final  String id;
@override final  DateTime timestamp;
@override final  String? name;
@override final  double carbohydrates;
// Required for baseline bolus calculation
@override@JsonKey() final  double dietaryFiber;
// To calculate net carbs and gastric delay
@override final  double proteins;
// Spikes BG 3-6 hrs post-meal
@override final  double fats;
// Delays gastric emptying
@override@JsonKey() final  double calories;
@override@JsonKey() final  bool containsAlcohol;
// Inhibits gluconeogenesis
@override@JsonKey() final  bool containsCaffeine;
// Can spike BG
@override final  String mealType;
// Enum stored as string: breakfast, lunch, dinner, snack
@override final  String? notes;
@override@JsonKey() final  bool isSynced;

/// Create a copy of MealLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealLogCopyWith<_MealLog> get copyWith => __$MealLogCopyWithImpl<_MealLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealLog&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.name, name) || other.name == name)&&(identical(other.carbohydrates, carbohydrates) || other.carbohydrates == carbohydrates)&&(identical(other.dietaryFiber, dietaryFiber) || other.dietaryFiber == dietaryFiber)&&(identical(other.proteins, proteins) || other.proteins == proteins)&&(identical(other.fats, fats) || other.fats == fats)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.containsAlcohol, containsAlcohol) || other.containsAlcohol == containsAlcohol)&&(identical(other.containsCaffeine, containsCaffeine) || other.containsCaffeine == containsCaffeine)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,name,carbohydrates,dietaryFiber,proteins,fats,calories,containsAlcohol,containsCaffeine,mealType,notes,isSynced);

@override
String toString() {
  return 'MealLog(id: $id, timestamp: $timestamp, name: $name, carbohydrates: $carbohydrates, dietaryFiber: $dietaryFiber, proteins: $proteins, fats: $fats, calories: $calories, containsAlcohol: $containsAlcohol, containsCaffeine: $containsCaffeine, mealType: $mealType, notes: $notes, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$MealLogCopyWith<$Res> implements $MealLogCopyWith<$Res> {
  factory _$MealLogCopyWith(_MealLog value, $Res Function(_MealLog) _then) = __$MealLogCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime timestamp, String? name, double carbohydrates, double dietaryFiber, double proteins, double fats, double calories, bool containsAlcohol, bool containsCaffeine, String mealType, String? notes, bool isSynced
});




}
/// @nodoc
class __$MealLogCopyWithImpl<$Res>
    implements _$MealLogCopyWith<$Res> {
  __$MealLogCopyWithImpl(this._self, this._then);

  final _MealLog _self;
  final $Res Function(_MealLog) _then;

/// Create a copy of MealLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? name = freezed,Object? carbohydrates = null,Object? dietaryFiber = null,Object? proteins = null,Object? fats = null,Object? calories = null,Object? containsAlcohol = null,Object? containsCaffeine = null,Object? mealType = null,Object? notes = freezed,Object? isSynced = null,}) {
  return _then(_MealLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,carbohydrates: null == carbohydrates ? _self.carbohydrates : carbohydrates // ignore: cast_nullable_to_non_nullable
as double,dietaryFiber: null == dietaryFiber ? _self.dietaryFiber : dietaryFiber // ignore: cast_nullable_to_non_nullable
as double,proteins: null == proteins ? _self.proteins : proteins // ignore: cast_nullable_to_non_nullable
as double,fats: null == fats ? _self.fats : fats // ignore: cast_nullable_to_non_nullable
as double,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,containsAlcohol: null == containsAlcohol ? _self.containsAlcohol : containsAlcohol // ignore: cast_nullable_to_non_nullable
as bool,containsCaffeine: null == containsCaffeine ? _self.containsCaffeine : containsCaffeine // ignore: cast_nullable_to_non_nullable
as bool,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
