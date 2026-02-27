// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodItem {

 String get name; String get portion;@JsonKey(name: 'carbs_g') double get carbsGrams; double get calories;@JsonKey(name: 'protein_g') double get proteinGrams;@JsonKey(name: 'fat_g') double get fatGrams; String get source;
/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodItemCopyWith<FoodItem> get copyWith => _$FoodItemCopyWithImpl<FoodItem>(this as FoodItem, _$identity);

  /// Serializes this FoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodItem&&(identical(other.name, name) || other.name == name)&&(identical(other.portion, portion) || other.portion == portion)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,portion,carbsGrams,calories,proteinGrams,fatGrams,source);

@override
String toString() {
  return 'FoodItem(name: $name, portion: $portion, carbsGrams: $carbsGrams, calories: $calories, proteinGrams: $proteinGrams, fatGrams: $fatGrams, source: $source)';
}


}

/// @nodoc
abstract mixin class $FoodItemCopyWith<$Res>  {
  factory $FoodItemCopyWith(FoodItem value, $Res Function(FoodItem) _then) = _$FoodItemCopyWithImpl;
@useResult
$Res call({
 String name, String portion,@JsonKey(name: 'carbs_g') double carbsGrams, double calories,@JsonKey(name: 'protein_g') double proteinGrams,@JsonKey(name: 'fat_g') double fatGrams, String source
});




}
/// @nodoc
class _$FoodItemCopyWithImpl<$Res>
    implements $FoodItemCopyWith<$Res> {
  _$FoodItemCopyWithImpl(this._self, this._then);

  final FoodItem _self;
  final $Res Function(FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? portion = null,Object? carbsGrams = null,Object? calories = null,Object? proteinGrams = null,Object? fatGrams = null,Object? source = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,portion: null == portion ? _self.portion : portion // ignore: cast_nullable_to_non_nullable
as String,carbsGrams: null == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinGrams: null == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double,fatGrams: null == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodItem].
extension FoodItemPatterns on FoodItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodItem value)  $default,){
final _that = this;
switch (_that) {
case _FoodItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String portion, @JsonKey(name: 'carbs_g')  double carbsGrams,  double calories, @JsonKey(name: 'protein_g')  double proteinGrams, @JsonKey(name: 'fat_g')  double fatGrams,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.name,_that.portion,_that.carbsGrams,_that.calories,_that.proteinGrams,_that.fatGrams,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String portion, @JsonKey(name: 'carbs_g')  double carbsGrams,  double calories, @JsonKey(name: 'protein_g')  double proteinGrams, @JsonKey(name: 'fat_g')  double fatGrams,  String source)  $default,) {final _that = this;
switch (_that) {
case _FoodItem():
return $default(_that.name,_that.portion,_that.carbsGrams,_that.calories,_that.proteinGrams,_that.fatGrams,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String portion, @JsonKey(name: 'carbs_g')  double carbsGrams,  double calories, @JsonKey(name: 'protein_g')  double proteinGrams, @JsonKey(name: 'fat_g')  double fatGrams,  String source)?  $default,) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.name,_that.portion,_that.carbsGrams,_that.calories,_that.proteinGrams,_that.fatGrams,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodItem extends FoodItem {
  const _FoodItem({this.name = 'Unknown', this.portion = '1 serving', @JsonKey(name: 'carbs_g') this.carbsGrams = 0.0, this.calories = 0.0, @JsonKey(name: 'protein_g') this.proteinGrams = 0.0, @JsonKey(name: 'fat_g') this.fatGrams = 0.0, this.source = 'AI Estimate'}): super._();
  factory _FoodItem.fromJson(Map<String, dynamic> json) => _$FoodItemFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String portion;
@override@JsonKey(name: 'carbs_g') final  double carbsGrams;
@override@JsonKey() final  double calories;
@override@JsonKey(name: 'protein_g') final  double proteinGrams;
@override@JsonKey(name: 'fat_g') final  double fatGrams;
@override@JsonKey() final  String source;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodItemCopyWith<_FoodItem> get copyWith => __$FoodItemCopyWithImpl<_FoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodItem&&(identical(other.name, name) || other.name == name)&&(identical(other.portion, portion) || other.portion == portion)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,portion,carbsGrams,calories,proteinGrams,fatGrams,source);

@override
String toString() {
  return 'FoodItem(name: $name, portion: $portion, carbsGrams: $carbsGrams, calories: $calories, proteinGrams: $proteinGrams, fatGrams: $fatGrams, source: $source)';
}


}

/// @nodoc
abstract mixin class _$FoodItemCopyWith<$Res> implements $FoodItemCopyWith<$Res> {
  factory _$FoodItemCopyWith(_FoodItem value, $Res Function(_FoodItem) _then) = __$FoodItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String portion,@JsonKey(name: 'carbs_g') double carbsGrams, double calories,@JsonKey(name: 'protein_g') double proteinGrams,@JsonKey(name: 'fat_g') double fatGrams, String source
});




}
/// @nodoc
class __$FoodItemCopyWithImpl<$Res>
    implements _$FoodItemCopyWith<$Res> {
  __$FoodItemCopyWithImpl(this._self, this._then);

  final _FoodItem _self;
  final $Res Function(_FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? portion = null,Object? carbsGrams = null,Object? calories = null,Object? proteinGrams = null,Object? fatGrams = null,Object? source = null,}) {
  return _then(_FoodItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,portion: null == portion ? _self.portion : portion // ignore: cast_nullable_to_non_nullable
as String,carbsGrams: null == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinGrams: null == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double,fatGrams: null == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
