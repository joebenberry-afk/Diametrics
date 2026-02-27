import 'package:freezed_annotation/freezed_annotation.dart';

part 'glucose_log.freezed.dart';
part 'glucose_log.g.dart';

@freezed
abstract class GlucoseLog with _$GlucoseLog {
  const factory GlucoseLog({
    required String id,
    required DateTime timestamp,
    required double value,
    required String unit, // Enum: mg/dL, mmol/L
    required String
    context, // Enum stored as string: fasting, pre_meal, post_meal_30, post_meal_120, bedtime, night_time
    String? notes, // E.g., stress, exercise
    @Default(false) bool isSynced,
  }) = _GlucoseLog;

  factory GlucoseLog.fromJson(Map<String, Object?> json) =>
      _$GlucoseLogFromJson(json);
}
