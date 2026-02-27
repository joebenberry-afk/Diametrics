// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glucose_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GlucoseLog _$GlucoseLogFromJson(Map<String, dynamic> json) => _GlucoseLog(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  context: json['context'] as String,
  notes: json['notes'] as String?,
  isSynced: json['isSynced'] as bool? ?? false,
);

Map<String, dynamic> _$GlucoseLogToJson(_GlucoseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'unit': instance.unit,
      'context': instance.context,
      'notes': instance.notes,
      'isSynced': instance.isSynced,
    };
