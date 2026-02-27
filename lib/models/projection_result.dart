import 'package:freezed_annotation/freezed_annotation.dart';

part 'projection_result.freezed.dart';
part 'projection_result.g.dart';

@freezed
abstract class ProjectionPoint with _$ProjectionPoint {
  const factory ProjectionPoint({
    required int timeMinutes,
    required double glucoseValue, // mg/dL
  }) = _ProjectionPoint;

  factory ProjectionPoint.fromJson(Map<String, dynamic> json) =>
      _$ProjectionPointFromJson(json);
}

@freezed
abstract class ProjectionResult with _$ProjectionResult {
  const factory ProjectionResult({
    required List<ProjectionPoint> points,
    required double peakGlucose,
    required int peakTimeMinutes,
    required double twoHourGlucose,
    required double totalAvailableGlucose, // TAG value
    required String riskLevel, // normal / elevated / high / hypo_risk
    required String summary,
  }) = _ProjectionResult;

  factory ProjectionResult.fromJson(Map<String, dynamic> json) =>
      _$ProjectionResultFromJson(json);
}
