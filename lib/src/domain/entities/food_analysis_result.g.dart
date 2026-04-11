// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodAnalysisResult _$FoodAnalysisResultFromJson(Map<String, dynamic> json) =>
    _FoodAnalysisResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      summary: json['summary'] as String,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      confidenceScore:
          (json['confidenceScore'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$FoodAnalysisResultToJson(_FoodAnalysisResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCarbs': instance.totalCarbs,
      'totalCalories': instance.totalCalories,
      'summary': instance.summary,
      'totalProtein': instance.totalProtein,
      'totalFat': instance.totalFat,
      'confidenceScore': instance.confidenceScore,
    };
