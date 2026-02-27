// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectionPoint _$ProjectionPointFromJson(Map<String, dynamic> json) =>
    _ProjectionPoint(
      timeMinutes: (json['timeMinutes'] as num).toInt(),
      glucoseValue: (json['glucoseValue'] as num).toDouble(),
    );

Map<String, dynamic> _$ProjectionPointToJson(_ProjectionPoint instance) =>
    <String, dynamic>{
      'timeMinutes': instance.timeMinutes,
      'glucoseValue': instance.glucoseValue,
    };

_ProjectionResult _$ProjectionResultFromJson(Map<String, dynamic> json) =>
    _ProjectionResult(
      points: (json['points'] as List<dynamic>)
          .map((e) => ProjectionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      peakGlucose: (json['peakGlucose'] as num).toDouble(),
      peakTimeMinutes: (json['peakTimeMinutes'] as num).toInt(),
      twoHourGlucose: (json['twoHourGlucose'] as num).toDouble(),
      totalAvailableGlucose: (json['totalAvailableGlucose'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$ProjectionResultToJson(_ProjectionResult instance) =>
    <String, dynamic>{
      'points': instance.points,
      'peakGlucose': instance.peakGlucose,
      'peakTimeMinutes': instance.peakTimeMinutes,
      'twoHourGlucose': instance.twoHourGlucose,
      'totalAvailableGlucose': instance.totalAvailableGlucose,
      'riskLevel': instance.riskLevel,
      'summary': instance.summary,
    };
