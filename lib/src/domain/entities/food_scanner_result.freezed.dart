// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_scanner_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FoodScannerResult {

 List<FoodItem> get items; double get totalCarbs; double get totalFiber; double get totalProtein; double get totalFat; double get totalCalories;
/// Create a copy of FoodScannerResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodScannerResultCopyWith<FoodScannerResult> get copyWith => _$FoodScannerResultCopyWithImpl<FoodScannerResult>(this as FoodScannerResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodScannerResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFiber, totalFiber) || other.totalFiber == totalFiber)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCarbs,totalFiber,totalProtein,totalFat,totalCalories);

@override
String toString() {
  return 'FoodScannerResult(items: $items, totalCarbs: $totalCarbs, totalFiber: $totalFiber, totalProtein: $totalProtein, totalFat: $totalFat, totalCalories: $totalCalories)';
}


}

/// @nodoc
abstract mixin class $FoodScannerResultCopyWith<$Res>  {
  factory $FoodScannerResultCopyWith(FoodScannerResult value, $Res Function(FoodScannerResult) _then) = _$FoodScannerResultCopyWithImpl;
@useResult
$Res call({
 List<FoodItem> items, double totalCarbs, double totalFiber, double totalProtein, double totalFat, double totalCalories
});




}
/// @nodoc
class _$FoodScannerResultCopyWithImpl<$Res>
    implements $FoodScannerResultCopyWith<$Res> {
  _$FoodScannerResultCopyWithImpl(this._self, this._then);

  final FoodScannerResult _self;
  final $Res Function(FoodScannerResult) _then;

/// Create a copy of FoodScannerResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCarbs = null,Object? totalFiber = null,Object? totalProtein = null,Object? totalFat = null,Object? totalCalories = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFiber: null == totalFiber ? _self.totalFiber : totalFiber // ignore: cast_nullable_to_non_nullable
as double,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodScannerResult].
extension FoodScannerResultPatterns on FoodScannerResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodScannerResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodScannerResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodScannerResult value)  $default,){
final _that = this;
switch (_that) {
case _FoodScannerResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodScannerResult value)?  $default,){
final _that = this;
switch (_that) {
case _FoodScannerResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FoodItem> items,  double totalCarbs,  double totalFiber,  double totalProtein,  double totalFat,  double totalCalories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodScannerResult() when $default != null:
return $default(_that.items,_that.totalCarbs,_that.totalFiber,_that.totalProtein,_that.totalFat,_that.totalCalories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FoodItem> items,  double totalCarbs,  double totalFiber,  double totalProtein,  double totalFat,  double totalCalories)  $default,) {final _that = this;
switch (_that) {
case _FoodScannerResult():
return $default(_that.items,_that.totalCarbs,_that.totalFiber,_that.totalProtein,_that.totalFat,_that.totalCalories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FoodItem> items,  double totalCarbs,  double totalFiber,  double totalProtein,  double totalFat,  double totalCalories)?  $default,) {final _that = this;
switch (_that) {
case _FoodScannerResult() when $default != null:
return $default(_that.items,_that.totalCarbs,_that.totalFiber,_that.totalProtein,_that.totalFat,_that.totalCalories);case _:
  return null;

}
}

}

/// @nodoc


class _FoodScannerResult implements FoodScannerResult {
  const _FoodScannerResult({required final  List<FoodItem> items, required this.totalCarbs, required this.totalFiber, required this.totalProtein, required this.totalFat, required this.totalCalories}): _items = items;
  

 final  List<FoodItem> _items;
@override List<FoodItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double totalCarbs;
@override final  double totalFiber;
@override final  double totalProtein;
@override final  double totalFat;
@override final  double totalCalories;

/// Create a copy of FoodScannerResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodScannerResultCopyWith<_FoodScannerResult> get copyWith => __$FoodScannerResultCopyWithImpl<_FoodScannerResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodScannerResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFiber, totalFiber) || other.totalFiber == totalFiber)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCarbs,totalFiber,totalProtein,totalFat,totalCalories);

@override
String toString() {
  return 'FoodScannerResult(items: $items, totalCarbs: $totalCarbs, totalFiber: $totalFiber, totalProtein: $totalProtein, totalFat: $totalFat, totalCalories: $totalCalories)';
}


}

/// @nodoc
abstract mixin class _$FoodScannerResultCopyWith<$Res> implements $FoodScannerResultCopyWith<$Res> {
  factory _$FoodScannerResultCopyWith(_FoodScannerResult value, $Res Function(_FoodScannerResult) _then) = __$FoodScannerResultCopyWithImpl;
@override @useResult
$Res call({
 List<FoodItem> items, double totalCarbs, double totalFiber, double totalProtein, double totalFat, double totalCalories
});




}
/// @nodoc
class __$FoodScannerResultCopyWithImpl<$Res>
    implements _$FoodScannerResultCopyWith<$Res> {
  __$FoodScannerResultCopyWithImpl(this._self, this._then);

  final _FoodScannerResult _self;
  final $Res Function(_FoodScannerResult) _then;

/// Create a copy of FoodScannerResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCarbs = null,Object? totalFiber = null,Object? totalProtein = null,Object? totalFat = null,Object? totalCalories = null,}) {
  return _then(_FoodScannerResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFiber: null == totalFiber ? _self.totalFiber : totalFiber // ignore: cast_nullable_to_non_nullable
as double,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
