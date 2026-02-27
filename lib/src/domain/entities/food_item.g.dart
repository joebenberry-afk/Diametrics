// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => _FoodItem(
  name: json['name'] as String? ?? 'Unknown',
  portion: json['portion'] as String? ?? '1 serving',
  carbsGrams: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
  calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
  proteinGrams: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
  fatGrams: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
  source: json['source'] as String? ?? 'AI Estimate',
);

Map<String, dynamic> _$FoodItemToJson(_FoodItem instance) => <String, dynamic>{
  'name': instance.name,
  'portion': instance.portion,
  'carbs_g': instance.carbsGrams,
  'calories': instance.calories,
  'protein_g': instance.proteinGrams,
  'fat_g': instance.fatGrams,
  'source': instance.source,
};
