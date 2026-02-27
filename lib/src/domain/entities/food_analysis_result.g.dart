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
    );

Map<String, dynamic> _$FoodAnalysisResultToJson(_FoodAnalysisResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCarbs': instance.totalCarbs,
      'totalCalories': instance.totalCalories,
      'summary': instance.summary,
    };
