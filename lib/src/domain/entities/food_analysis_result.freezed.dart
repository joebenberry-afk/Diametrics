// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodAnalysisResult {

 List<FoodItem> get items; double get totalCarbs; double get totalCalories; String get summary; double get totalProtein; double get totalFat; Map<String, double> get confidenceScore;
/// Create a copy of FoodAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodAnalysisResultCopyWith<FoodAnalysisResult> get copyWith => _$FoodAnalysisResultCopyWithImpl<FoodAnalysisResult>(this as FoodAnalysisResult, _$identity);

  /// Serializes this FoodAnalysisResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodAnalysisResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other.confidenceScore, confidenceScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCarbs,totalCalories,summary,totalProtein,totalFat,const DeepCollectionEquality().hash(confidenceScore));

@override
String toString() {
  return 'FoodAnalysisResult(items: $items, totalCarbs: $totalCarbs, totalCalories: $totalCalories, summary: $summary, totalProtein: $totalProtein, totalFat: $totalFat, confidenceScore: $confidenceScore)';
}


}

/// @nodoc
abstract mixin class $FoodAnalysisResultCopyWith<$Res>  {
  factory $FoodAnalysisResultCopyWith(FoodAnalysisResult value, $Res Function(FoodAnalysisResult) _then) = _$FoodAnalysisResultCopyWithImpl;
@useResult
$Res call({
 List<FoodItem> items, double totalCarbs, double totalCalories, String summary, double totalProtein, double totalFat, Map<String, double> confidenceScore
});




}
/// @nodoc
class _$FoodAnalysisResultCopyWithImpl<$Res>
    implements $FoodAnalysisResultCopyWith<$Res> {
  _$FoodAnalysisResultCopyWithImpl(this._self, this._then);

  final FoodAnalysisResult _self;
  final $Res Function(FoodAnalysisResult) _then;

/// Create a copy of FoodAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCarbs = null,Object? totalCalories = null,Object? summary = null,Object? totalProtein = null,Object? totalFat = null,Object? confidenceScore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodAnalysisResult].
extension FoodAnalysisResultPatterns on FoodAnalysisResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodAnalysisResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodAnalysisResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodAnalysisResult value)  $default,){
final _that = this;
switch (_that) {
case _FoodAnalysisResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodAnalysisResult value)?  $default,){
final _that = this;
switch (_that) {
case _FoodAnalysisResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FoodItem> items,  double totalCarbs,  double totalCalories,  String summary,  double totalProtein,  double totalFat,  Map<String, double> confidenceScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodAnalysisResult() when $default != null:
return $default(_that.items,_that.totalCarbs,_that.totalCalories,_that.summary,_that.totalProtein,_that.totalFat,_that.confidenceScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FoodItem> items,  double totalCarbs,  double totalCalories,  String summary,  double totalProtein,  double totalFat,  Map<String, double> confidenceScore)  $default,) {final _that = this;
switch (_that) {
case _FoodAnalysisResult():
return $default(_that.items,_that.totalCarbs,_that.totalCalories,_that.summary,_that.totalProtein,_that.totalFat,_that.confidenceScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FoodItem> items,  double totalCarbs,  double totalCalories,  String summary,  double totalProtein,  double totalFat,  Map<String, double> confidenceScore)?  $default,) {final _that = this;
switch (_that) {
case _FoodAnalysisResult() when $default != null:
return $default(_that.items,_that.totalCarbs,_that.totalCalories,_that.summary,_that.totalProtein,_that.totalFat,_that.confidenceScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodAnalysisResult implements FoodAnalysisResult {
  const _FoodAnalysisResult({required final  List<FoodItem> items, required this.totalCarbs, required this.totalCalories, required this.summary, this.totalProtein = 0.0, this.totalFat = 0.0, final  Map<String, double> confidenceScore = const {}}): _items = items,_confidenceScore = confidenceScore;
  factory _FoodAnalysisResult.fromJson(Map<String, dynamic> json) => _$FoodAnalysisResultFromJson(json);

 final  List<FoodItem> _items;
@override List<FoodItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double totalCarbs;
@override final  double totalCalories;
@override final  String summary;
@override@JsonKey() final  double totalProtein;
@override@JsonKey() final  double totalFat;
 final  Map<String, double> _confidenceScore;
@override@JsonKey() Map<String, double> get confidenceScore {
  if (_confidenceScore is EqualUnmodifiableMapView) return _confidenceScore;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_confidenceScore);
}


/// Create a copy of FoodAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodAnalysisResultCopyWith<_FoodAnalysisResult> get copyWith => __$FoodAnalysisResultCopyWithImpl<_FoodAnalysisResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodAnalysisResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodAnalysisResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other._confidenceScore, _confidenceScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCarbs,totalCalories,summary,totalProtein,totalFat,const DeepCollectionEquality().hash(_confidenceScore));

@override
String toString() {
  return 'FoodAnalysisResult(items: $items, totalCarbs: $totalCarbs, totalCalories: $totalCalories, summary: $summary, totalProtein: $totalProtein, totalFat: $totalFat, confidenceScore: $confidenceScore)';
}


}

/// @nodoc
abstract mixin class _$FoodAnalysisResultCopyWith<$Res> implements $FoodAnalysisResultCopyWith<$Res> {
  factory _$FoodAnalysisResultCopyWith(_FoodAnalysisResult value, $Res Function(_FoodAnalysisResult) _then) = __$FoodAnalysisResultCopyWithImpl;
@override @useResult
$Res call({
 List<FoodItem> items, double totalCarbs, double totalCalories, String summary, double totalProtein, double totalFat, Map<String, double> confidenceScore
});




}
/// @nodoc
class __$FoodAnalysisResultCopyWithImpl<$Res>
    implements _$FoodAnalysisResultCopyWith<$Res> {
  __$FoodAnalysisResultCopyWithImpl(this._self, this._then);

  final _FoodAnalysisResult _self;
  final $Res Function(_FoodAnalysisResult) _then;

/// Create a copy of FoodAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCarbs = null,Object? totalCalories = null,Object? summary = null,Object? totalProtein = null,Object? totalFat = null,Object? confidenceScore = null,}) {
  return _then(_FoodAnalysisResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,confidenceScore: null == confidenceScore ? _self._confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
