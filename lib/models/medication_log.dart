import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_log.freezed.dart';
part 'medication_log.g.dart';

@freezed
abstract class MedicationLog with _$MedicationLog {
  const factory MedicationLog({
    required String id,
    required DateTime timestamp,
    required String
    medicationType, // Enum: rapid_acting_insulin, long_acting_insulin, pill
    String? name, // e.g., Humalog, Metformin
    required double units, // Active drug volume to deduct from future boluses
    String? notes,
    @Default(false) bool isSynced,
  }) = _MedicationLog;

  factory MedicationLog.fromJson(Map<String, Object?> json) =>
      _$MedicationLogFromJson(json);
}
