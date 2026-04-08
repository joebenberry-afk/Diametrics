// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicationLog _$MedicationLogFromJson(Map<String, dynamic> json) =>
    _MedicationLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      medicationType: json['medicationType'] as String,
      insulinType: json['insulinType'] as String? ?? 'Humalog / NovoLog',
      name: json['name'] as String?,
      units: (json['units'] as num).toDouble(),
      notes: json['notes'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$MedicationLogToJson(_MedicationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'medicationType': instance.medicationType,
      'insulinType': instance.insulinType,
      'name': instance.name,
      'units': instance.units,
      'notes': instance.notes,
      'isSynced': instance.isSynced,
    };
