import 'package:freezed_annotation/freezed_annotation.dart';

import 'food_item.dart';

part 'food_analysis_result.freezed.dart';
part 'food_analysis_result.g.dart';

@freezed
abstract class FoodAnalysisResult with _$FoodAnalysisResult {
  const factory FoodAnalysisResult({
    required List<FoodItem> items,
    required double totalCarbs,
    required double totalCalories,
    required String summary,
    @Default(0.0) double totalProtein,
    @Default(0.0) double totalFat,
    @Default({}) Map<String, double> confidenceScore,
  }) = _FoodAnalysisResult;

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$FoodAnalysisResultFromJson(json);
}
