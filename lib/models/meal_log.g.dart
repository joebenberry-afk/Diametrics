// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealLog _$MealLogFromJson(Map<String, dynamic> json) => _MealLog(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  name: json['name'] as String?,
  carbohydrates: (json['carbohydrates'] as num).toDouble(),
  dietaryFiber: (json['dietaryFiber'] as num?)?.toDouble() ?? 0.0,
  proteins: (json['proteins'] as num).toDouble(),
  fats: (json['fats'] as num).toDouble(),
  calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
  containsAlcohol: json['containsAlcohol'] as bool? ?? false,
  containsCaffeine: json['containsCaffeine'] as bool? ?? false,
  mealType: json['mealType'] as String,
  notes: json['notes'] as String?,
  isSynced: json['isSynced'] as bool? ?? false,
);

Map<String, dynamic> _$MealLogToJson(_MealLog instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'name': instance.name,
  'carbohydrates': instance.carbohydrates,
  'dietaryFiber': instance.dietaryFiber,
  'proteins': instance.proteins,
  'fats': instance.fats,
  'calories': instance.calories,
  'containsAlcohol': instance.containsAlcohol,
  'containsCaffeine': instance.containsCaffeine,
  'mealType': instance.mealType,
  'notes': instance.notes,
  'isSynced': instance.isSynced,
};
