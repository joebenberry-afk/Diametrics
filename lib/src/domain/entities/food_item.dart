import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_item.freezed.dart';
part 'food_item.g.dart';

@freezed
abstract class FoodItem with _$FoodItem {
  const FoodItem._();

  const factory FoodItem({
    @Default('Unknown') String name,
    @Default('1 serving') String portion,
    @JsonKey(name: 'carbs_g') @Default(0.0) double carbsGrams,
    @Default(0.0) double calories,
    @JsonKey(name: 'protein_g') @Default(0.0) double proteinGrams,
    @JsonKey(name: 'fat_g') @Default(0.0) double fatGrams,
    @Default('AI Estimate') String source,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  /// Returns a copy with USDA nutritional data replacing the AI estimates.
  FoodItem withUsdaData({required double carbsPer100g}) {
    return copyWith(carbsGrams: carbsPer100g, source: 'USDA');
  }
}
