import 'package:freezed_annotation/freezed_annotation.dart';

import 'food_item.dart';

part 'food_scanner_result.freezed.dart';

/// Returned by [FoodScannerView] when the user confirms their food selection.
/// This is the push/pop contract between FoodScannerView and MealWizardView.
/// No JSON serialisation — this is an in-memory return value only.
@freezed
abstract class FoodScannerResult with _$FoodScannerResult {
  const factory FoodScannerResult({
    required List<FoodItem> items,
    required double totalCarbs,
    required double totalProtein,
    required double totalFat,
    required double totalCalories,
  }) = _FoodScannerResult;
}
