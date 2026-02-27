import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_log.freezed.dart';
part 'meal_log.g.dart';

@freezed
abstract class MealLog with _$MealLog {
  const factory MealLog({
    required String id,
    required DateTime timestamp,
    String? name,
    required double carbohydrates, // Required for baseline bolus calculation
    @Default(0.0)
    double dietaryFiber, // To calculate net carbs and gastric delay
    required double proteins, // Spikes BG 3-6 hrs post-meal
    required double fats, // Delays gastric emptying
    @Default(0.0) double calories,
    @Default(false) bool containsAlcohol, // Inhibits gluconeogenesis
    @Default(false) bool containsCaffeine, // Can spike BG
    required String
    mealType, // Enum stored as string: breakfast, lunch, dinner, snack
    String? notes,
    @Default(false) bool isSynced,
  }) = _MealLog;

  factory MealLog.fromJson(Map<String, Object?> json) =>
      _$MealLogFromJson(json);
}
