// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LogsTable extends Logs with TableInfo<$LogsTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bgValueMeta = const VerificationMeta(
    'bgValue',
  );
  @override
  late final GeneratedColumn<double> bgValue = GeneratedColumn<double>(
    'bg_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bgUnitMeta = const VerificationMeta('bgUnit');
  @override
  late final GeneratedColumn<String> bgUnit = GeneratedColumn<String>(
    'bg_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mmol/L'),
  );
  static const VerificationMeta _contextTagsMeta = const VerificationMeta(
    'contextTags',
  );
  @override
  late final GeneratedColumn<String> contextTags = GeneratedColumn<String>(
    'context_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodVolumeMeta = const VerificationMeta(
    'foodVolume',
  );
  @override
  late final GeneratedColumn<String> foodVolume = GeneratedColumn<String>(
    'food_volume',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedMealMeta = const VerificationMeta(
    'finishedMeal',
  );
  @override
  late final GeneratedColumn<bool> finishedMeal = GeneratedColumn<bool>(
    'finished_meal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("finished_meal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    bgValue,
    bgUnit,
    contextTags,
    foodVolume,
    finishedMeal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Log> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('bg_value')) {
      context.handle(
        _bgValueMeta,
        bgValue.isAcceptableOrUnknown(data['bg_value']!, _bgValueMeta),
      );
    }
    if (data.containsKey('bg_unit')) {
      context.handle(
        _bgUnitMeta,
        bgUnit.isAcceptableOrUnknown(data['bg_unit']!, _bgUnitMeta),
      );
    }
    if (data.containsKey('context_tags')) {
      context.handle(
        _contextTagsMeta,
        contextTags.isAcceptableOrUnknown(
          data['context_tags']!,
          _contextTagsMeta,
        ),
      );
    }
    if (data.containsKey('food_volume')) {
      context.handle(
        _foodVolumeMeta,
        foodVolume.isAcceptableOrUnknown(data['food_volume']!, _foodVolumeMeta),
      );
    }
    if (data.containsKey('finished_meal')) {
      context.handle(
        _finishedMealMeta,
        finishedMeal.isAcceptableOrUnknown(
          data['finished_meal']!,
          _finishedMealMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      bgValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bg_value'],
      ),
      bgUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bg_unit'],
      )!,
      contextTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_tags'],
      ),
      foodVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_volume'],
      ),
      finishedMeal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}finished_meal'],
      )!,
    );
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }
}

class Log extends DataClass implements Insertable<Log> {
  final int id;
  final DateTime timestamp;
  final double? bgValue;
  final String bgUnit;
  final String? contextTags;
  final String? foodVolume;
  final bool finishedMeal;
  const Log({
    required this.id,
    required this.timestamp,
    this.bgValue,
    required this.bgUnit,
    this.contextTags,
    this.foodVolume,
    required this.finishedMeal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || bgValue != null) {
      map['bg_value'] = Variable<double>(bgValue);
    }
    map['bg_unit'] = Variable<String>(bgUnit);
    if (!nullToAbsent || contextTags != null) {
      map['context_tags'] = Variable<String>(contextTags);
    }
    if (!nullToAbsent || foodVolume != null) {
      map['food_volume'] = Variable<String>(foodVolume);
    }
    map['finished_meal'] = Variable<bool>(finishedMeal);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      bgValue: bgValue == null && nullToAbsent
          ? const Value.absent()
          : Value(bgValue),
      bgUnit: Value(bgUnit),
      contextTags: contextTags == null && nullToAbsent
          ? const Value.absent()
          : Value(contextTags),
      foodVolume: foodVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(foodVolume),
      finishedMeal: Value(finishedMeal),
    );
  }

  factory Log.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      bgValue: serializer.fromJson<double?>(json['bgValue']),
      bgUnit: serializer.fromJson<String>(json['bgUnit']),
      contextTags: serializer.fromJson<String?>(json['contextTags']),
      foodVolume: serializer.fromJson<String?>(json['foodVolume']),
      finishedMeal: serializer.fromJson<bool>(json['finishedMeal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'bgValue': serializer.toJson<double?>(bgValue),
      'bgUnit': serializer.toJson<String>(bgUnit),
      'contextTags': serializer.toJson<String?>(contextTags),
      'foodVolume': serializer.toJson<String?>(foodVolume),
      'finishedMeal': serializer.toJson<bool>(finishedMeal),
    };
  }

  Log copyWith({
    int? id,
    DateTime? timestamp,
    Value<double?> bgValue = const Value.absent(),
    String? bgUnit,
    Value<String?> contextTags = const Value.absent(),
    Value<String?> foodVolume = const Value.absent(),
    bool? finishedMeal,
  }) => Log(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    bgValue: bgValue.present ? bgValue.value : this.bgValue,
    bgUnit: bgUnit ?? this.bgUnit,
    contextTags: contextTags.present ? contextTags.value : this.contextTags,
    foodVolume: foodVolume.present ? foodVolume.value : this.foodVolume,
    finishedMeal: finishedMeal ?? this.finishedMeal,
  );
  Log copyWithCompanion(LogsCompanion data) {
    return Log(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      bgValue: data.bgValue.present ? data.bgValue.value : this.bgValue,
      bgUnit: data.bgUnit.present ? data.bgUnit.value : this.bgUnit,
      contextTags: data.contextTags.present
          ? data.contextTags.value
          : this.contextTags,
      foodVolume: data.foodVolume.present
          ? data.foodVolume.value
          : this.foodVolume,
      finishedMeal: data.finishedMeal.present
          ? data.finishedMeal.value
          : this.finishedMeal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('bgValue: $bgValue, ')
          ..write('bgUnit: $bgUnit, ')
          ..write('contextTags: $contextTags, ')
          ..write('foodVolume: $foodVolume, ')
          ..write('finishedMeal: $finishedMeal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    bgValue,
    bgUnit,
    contextTags,
    foodVolume,
    finishedMeal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.bgValue == this.bgValue &&
          other.bgUnit == this.bgUnit &&
          other.contextTags == this.contextTags &&
          other.foodVolume == this.foodVolume &&
          other.finishedMeal == this.finishedMeal);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<double?> bgValue;
  final Value<String> bgUnit;
  final Value<String?> contextTags;
  final Value<String?> foodVolume;
  final Value<bool> finishedMeal;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bgValue = const Value.absent(),
    this.bgUnit = const Value.absent(),
    this.contextTags = const Value.absent(),
    this.foodVolume = const Value.absent(),
    this.finishedMeal = const Value.absent(),
  });
  LogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    this.bgValue = const Value.absent(),
    this.bgUnit = const Value.absent(),
    this.contextTags = const Value.absent(),
    this.foodVolume = const Value.absent(),
    this.finishedMeal = const Value.absent(),
  }) : timestamp = Value(timestamp);
  static Insertable<Log> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<double>? bgValue,
    Expression<String>? bgUnit,
    Expression<String>? contextTags,
    Expression<String>? foodVolume,
    Expression<bool>? finishedMeal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (bgValue != null) 'bg_value': bgValue,
      if (bgUnit != null) 'bg_unit': bgUnit,
      if (contextTags != null) 'context_tags': contextTags,
      if (foodVolume != null) 'food_volume': foodVolume,
      if (finishedMeal != null) 'finished_meal': finishedMeal,
    });
  }

  LogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<double?>? bgValue,
    Value<String>? bgUnit,
    Value<String?>? contextTags,
    Value<String?>? foodVolume,
    Value<bool>? finishedMeal,
  }) {
    return LogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      bgValue: bgValue ?? this.bgValue,
      bgUnit: bgUnit ?? this.bgUnit,
      contextTags: contextTags ?? this.contextTags,
      foodVolume: foodVolume ?? this.foodVolume,
      finishedMeal: finishedMeal ?? this.finishedMeal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (bgValue.present) {
      map['bg_value'] = Variable<double>(bgValue.value);
    }
    if (bgUnit.present) {
      map['bg_unit'] = Variable<String>(bgUnit.value);
    }
    if (contextTags.present) {
      map['context_tags'] = Variable<String>(contextTags.value);
    }
    if (foodVolume.present) {
      map['food_volume'] = Variable<String>(foodVolume.value);
    }
    if (finishedMeal.present) {
      map['finished_meal'] = Variable<bool>(finishedMeal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('bgValue: $bgValue, ')
          ..write('bgUnit: $bgUnit, ')
          ..write('contextTags: $contextTags, ')
          ..write('foodVolume: $foodVolume, ')
          ..write('finishedMeal: $finishedMeal')
          ..write(')'))
        .toString();
  }
}

class $LocalFoodsTable extends LocalFoods
    with TableInfo<$LocalFoodsTable, LocalFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<String> servingSize = GeneratedColumn<String>(
    'serving_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('100g'),
  );
  static const VerificationMeta _carbsPerServingMeta = const VerificationMeta(
    'carbsPerServing',
  );
  @override
  late final GeneratedColumn<double> carbsPerServing = GeneratedColumn<double>(
    'carbs_per_serving',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    servingSize,
    carbsPerServing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('carbs_per_serving')) {
      context.handle(
        _carbsPerServingMeta,
        carbsPerServing.isAcceptableOrUnknown(
          data['carbs_per_serving']!,
          _carbsPerServingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPerServingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_size'],
      )!,
      carbsPerServing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per_serving'],
      )!,
    );
  }

  @override
  $LocalFoodsTable createAlias(String alias) {
    return $LocalFoodsTable(attachedDatabase, alias);
  }
}

class LocalFood extends DataClass implements Insertable<LocalFood> {
  final int id;
  final String name;
  final String servingSize;
  final double carbsPerServing;
  const LocalFood({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.carbsPerServing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['serving_size'] = Variable<String>(servingSize);
    map['carbs_per_serving'] = Variable<double>(carbsPerServing);
    return map;
  }

  LocalFoodsCompanion toCompanion(bool nullToAbsent) {
    return LocalFoodsCompanion(
      id: Value(id),
      name: Value(name),
      servingSize: Value(servingSize),
      carbsPerServing: Value(carbsPerServing),
    );
  }

  factory LocalFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFood(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      servingSize: serializer.fromJson<String>(json['servingSize']),
      carbsPerServing: serializer.fromJson<double>(json['carbsPerServing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'servingSize': serializer.toJson<String>(servingSize),
      'carbsPerServing': serializer.toJson<double>(carbsPerServing),
    };
  }

  LocalFood copyWith({
    int? id,
    String? name,
    String? servingSize,
    double? carbsPerServing,
  }) => LocalFood(
    id: id ?? this.id,
    name: name ?? this.name,
    servingSize: servingSize ?? this.servingSize,
    carbsPerServing: carbsPerServing ?? this.carbsPerServing,
  );
  LocalFood copyWithCompanion(LocalFoodsCompanion data) {
    return LocalFood(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      carbsPerServing: data.carbsPerServing.present
          ? data.carbsPerServing.value
          : this.carbsPerServing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFood(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servingSize: $servingSize, ')
          ..write('carbsPerServing: $carbsPerServing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, servingSize, carbsPerServing);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFood &&
          other.id == this.id &&
          other.name == this.name &&
          other.servingSize == this.servingSize &&
          other.carbsPerServing == this.carbsPerServing);
}

class LocalFoodsCompanion extends UpdateCompanion<LocalFood> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> servingSize;
  final Value<double> carbsPerServing;
  const LocalFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.carbsPerServing = const Value.absent(),
  });
  LocalFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.servingSize = const Value.absent(),
    required double carbsPerServing,
  }) : name = Value(name),
       carbsPerServing = Value(carbsPerServing);
  static Insertable<LocalFood> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? servingSize,
    Expression<double>? carbsPerServing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (servingSize != null) 'serving_size': servingSize,
      if (carbsPerServing != null) 'carbs_per_serving': carbsPerServing,
    });
  }

  LocalFoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? servingSize,
    Value<double>? carbsPerServing,
  }) {
    return LocalFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      servingSize: servingSize ?? this.servingSize,
      carbsPerServing: carbsPerServing ?? this.carbsPerServing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<String>(servingSize.value);
    }
    if (carbsPerServing.present) {
      map['carbs_per_serving'] = Variable<double>(carbsPerServing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servingSize: $servingSize, ')
          ..write('carbsPerServing: $carbsPerServing')
          ..write(')'))
        .toString();
  }
}

class $CustomFoodsTable extends CustomFoods
    with TableInfo<$CustomFoodsTable, CustomFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userDefinedNameMeta = const VerificationMeta(
    'userDefinedName',
  );
  @override
  late final GeneratedColumn<String> userDefinedName = GeneratedColumn<String>(
    'user_defined_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<String> servingSize = GeneratedColumn<String>(
    'serving_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1 serving'),
  );
  static const VerificationMeta _carbsPerServingMeta = const VerificationMeta(
    'carbsPerServing',
  );
  @override
  late final GeneratedColumn<double> carbsPerServing = GeneratedColumn<double>(
    'carbs_per_serving',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userDefinedName,
    barcode,
    servingSize,
    carbsPerServing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_defined_name')) {
      context.handle(
        _userDefinedNameMeta,
        userDefinedName.isAcceptableOrUnknown(
          data['user_defined_name']!,
          _userDefinedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userDefinedNameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('carbs_per_serving')) {
      context.handle(
        _carbsPerServingMeta,
        carbsPerServing.isAcceptableOrUnknown(
          data['carbs_per_serving']!,
          _carbsPerServingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPerServingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userDefinedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_defined_name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_size'],
      )!,
      carbsPerServing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per_serving'],
      )!,
    );
  }

  @override
  $CustomFoodsTable createAlias(String alias) {
    return $CustomFoodsTable(attachedDatabase, alias);
  }
}

class CustomFood extends DataClass implements Insertable<CustomFood> {
  final int id;
  final String userDefinedName;
  final String? barcode;
  final String servingSize;
  final double carbsPerServing;
  const CustomFood({
    required this.id,
    required this.userDefinedName,
    this.barcode,
    required this.servingSize,
    required this.carbsPerServing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_defined_name'] = Variable<String>(userDefinedName);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['serving_size'] = Variable<String>(servingSize);
    map['carbs_per_serving'] = Variable<double>(carbsPerServing);
    return map;
  }

  CustomFoodsCompanion toCompanion(bool nullToAbsent) {
    return CustomFoodsCompanion(
      id: Value(id),
      userDefinedName: Value(userDefinedName),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      servingSize: Value(servingSize),
      carbsPerServing: Value(carbsPerServing),
    );
  }

  factory CustomFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFood(
      id: serializer.fromJson<int>(json['id']),
      userDefinedName: serializer.fromJson<String>(json['userDefinedName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      servingSize: serializer.fromJson<String>(json['servingSize']),
      carbsPerServing: serializer.fromJson<double>(json['carbsPerServing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userDefinedName': serializer.toJson<String>(userDefinedName),
      'barcode': serializer.toJson<String?>(barcode),
      'servingSize': serializer.toJson<String>(servingSize),
      'carbsPerServing': serializer.toJson<double>(carbsPerServing),
    };
  }

  CustomFood copyWith({
    int? id,
    String? userDefinedName,
    Value<String?> barcode = const Value.absent(),
    String? servingSize,
    double? carbsPerServing,
  }) => CustomFood(
    id: id ?? this.id,
    userDefinedName: userDefinedName ?? this.userDefinedName,
    barcode: barcode.present ? barcode.value : this.barcode,
    servingSize: servingSize ?? this.servingSize,
    carbsPerServing: carbsPerServing ?? this.carbsPerServing,
  );
  CustomFood copyWithCompanion(CustomFoodsCompanion data) {
    return CustomFood(
      id: data.id.present ? data.id.value : this.id,
      userDefinedName: data.userDefinedName.present
          ? data.userDefinedName.value
          : this.userDefinedName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      carbsPerServing: data.carbsPerServing.present
          ? data.carbsPerServing.value
          : this.carbsPerServing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFood(')
          ..write('id: $id, ')
          ..write('userDefinedName: $userDefinedName, ')
          ..write('barcode: $barcode, ')
          ..write('servingSize: $servingSize, ')
          ..write('carbsPerServing: $carbsPerServing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userDefinedName, barcode, servingSize, carbsPerServing);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFood &&
          other.id == this.id &&
          other.userDefinedName == this.userDefinedName &&
          other.barcode == this.barcode &&
          other.servingSize == this.servingSize &&
          other.carbsPerServing == this.carbsPerServing);
}

class CustomFoodsCompanion extends UpdateCompanion<CustomFood> {
  final Value<int> id;
  final Value<String> userDefinedName;
  final Value<String?> barcode;
  final Value<String> servingSize;
  final Value<double> carbsPerServing;
  const CustomFoodsCompanion({
    this.id = const Value.absent(),
    this.userDefinedName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.carbsPerServing = const Value.absent(),
  });
  CustomFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String userDefinedName,
    this.barcode = const Value.absent(),
    this.servingSize = const Value.absent(),
    required double carbsPerServing,
  }) : userDefinedName = Value(userDefinedName),
       carbsPerServing = Value(carbsPerServing);
  static Insertable<CustomFood> custom({
    Expression<int>? id,
    Expression<String>? userDefinedName,
    Expression<String>? barcode,
    Expression<String>? servingSize,
    Expression<double>? carbsPerServing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userDefinedName != null) 'user_defined_name': userDefinedName,
      if (barcode != null) 'barcode': barcode,
      if (servingSize != null) 'serving_size': servingSize,
      if (carbsPerServing != null) 'carbs_per_serving': carbsPerServing,
    });
  }

  CustomFoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? userDefinedName,
    Value<String?>? barcode,
    Value<String>? servingSize,
    Value<double>? carbsPerServing,
  }) {
    return CustomFoodsCompanion(
      id: id ?? this.id,
      userDefinedName: userDefinedName ?? this.userDefinedName,
      barcode: barcode ?? this.barcode,
      servingSize: servingSize ?? this.servingSize,
      carbsPerServing: carbsPerServing ?? this.carbsPerServing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userDefinedName.present) {
      map['user_defined_name'] = Variable<String>(userDefinedName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<String>(servingSize.value);
    }
    if (carbsPerServing.present) {
      map['carbs_per_serving'] = Variable<double>(carbsPerServing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userDefinedName: $userDefinedName, ')
          ..write('barcode: $barcode, ')
          ..write('servingSize: $servingSize, ')
          ..write('carbsPerServing: $carbsPerServing')
          ..write(')'))
        .toString();
  }
}

class $MealLogsTable extends MealLogs with TableInfo<$MealLogsTable, MealLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptionMeta = const VerificationMeta(
    'transcription',
  );
  @override
  late final GeneratedColumn<String> transcription = GeneratedColumn<String>(
    'transcription',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedCarbsMeta = const VerificationMeta(
    'estimatedCarbs',
  );
  @override
  late final GeneratedColumn<double> estimatedCarbs = GeneratedColumn<double>(
    'estimated_carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionPercentageMeta =
      const VerificationMeta('completionPercentage');
  @override
  late final GeneratedColumn<int> completionPercentage = GeneratedColumn<int>(
    'completion_percentage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isOfflineEstimateMeta = const VerificationMeta(
    'isOfflineEstimate',
  );
  @override
  late final GeneratedColumn<bool> isOfflineEstimate = GeneratedColumn<bool>(
    'is_offline_estimate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_offline_estimate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    imagePath,
    transcription,
    estimatedCarbs,
    completionPercentage,
    syncStatus,
    isOfflineEstimate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('transcription')) {
      context.handle(
        _transcriptionMeta,
        transcription.isAcceptableOrUnknown(
          data['transcription']!,
          _transcriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimated_carbs')) {
      context.handle(
        _estimatedCarbsMeta,
        estimatedCarbs.isAcceptableOrUnknown(
          data['estimated_carbs']!,
          _estimatedCarbsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedCarbsMeta);
    }
    if (data.containsKey('completion_percentage')) {
      context.handle(
        _completionPercentageMeta,
        completionPercentage.isAcceptableOrUnknown(
          data['completion_percentage']!,
          _completionPercentageMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_offline_estimate')) {
      context.handle(
        _isOfflineEstimateMeta,
        isOfflineEstimate.isAcceptableOrUnknown(
          data['is_offline_estimate']!,
          _isOfflineEstimateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      transcription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription'],
      ),
      estimatedCarbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_carbs'],
      )!,
      completionPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_percentage'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isOfflineEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_offline_estimate'],
      )!,
    );
  }

  @override
  $MealLogsTable createAlias(String alias) {
    return $MealLogsTable(attachedDatabase, alias);
  }
}

class MealLog extends DataClass implements Insertable<MealLog> {
  final int id;
  final DateTime timestamp;
  final String? imagePath;
  final String? transcription;
  final double estimatedCarbs;
  final int completionPercentage;
  final String syncStatus;
  final bool isOfflineEstimate;
  const MealLog({
    required this.id,
    required this.timestamp,
    this.imagePath,
    this.transcription,
    required this.estimatedCarbs,
    required this.completionPercentage,
    required this.syncStatus,
    required this.isOfflineEstimate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || transcription != null) {
      map['transcription'] = Variable<String>(transcription);
    }
    map['estimated_carbs'] = Variable<double>(estimatedCarbs);
    map['completion_percentage'] = Variable<int>(completionPercentage);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_offline_estimate'] = Variable<bool>(isOfflineEstimate);
    return map;
  }

  MealLogsCompanion toCompanion(bool nullToAbsent) {
    return MealLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      transcription: transcription == null && nullToAbsent
          ? const Value.absent()
          : Value(transcription),
      estimatedCarbs: Value(estimatedCarbs),
      completionPercentage: Value(completionPercentage),
      syncStatus: Value(syncStatus),
      isOfflineEstimate: Value(isOfflineEstimate),
    );
  }

  factory MealLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealLog(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      transcription: serializer.fromJson<String?>(json['transcription']),
      estimatedCarbs: serializer.fromJson<double>(json['estimatedCarbs']),
      completionPercentage: serializer.fromJson<int>(
        json['completionPercentage'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isOfflineEstimate: serializer.fromJson<bool>(json['isOfflineEstimate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'imagePath': serializer.toJson<String?>(imagePath),
      'transcription': serializer.toJson<String?>(transcription),
      'estimatedCarbs': serializer.toJson<double>(estimatedCarbs),
      'completionPercentage': serializer.toJson<int>(completionPercentage),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isOfflineEstimate': serializer.toJson<bool>(isOfflineEstimate),
    };
  }

  MealLog copyWith({
    int? id,
    DateTime? timestamp,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> transcription = const Value.absent(),
    double? estimatedCarbs,
    int? completionPercentage,
    String? syncStatus,
    bool? isOfflineEstimate,
  }) => MealLog(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    transcription: transcription.present
        ? transcription.value
        : this.transcription,
    estimatedCarbs: estimatedCarbs ?? this.estimatedCarbs,
    completionPercentage: completionPercentage ?? this.completionPercentage,
    syncStatus: syncStatus ?? this.syncStatus,
    isOfflineEstimate: isOfflineEstimate ?? this.isOfflineEstimate,
  );
  MealLog copyWithCompanion(MealLogsCompanion data) {
    return MealLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      transcription: data.transcription.present
          ? data.transcription.value
          : this.transcription,
      estimatedCarbs: data.estimatedCarbs.present
          ? data.estimatedCarbs.value
          : this.estimatedCarbs,
      completionPercentage: data.completionPercentage.present
          ? data.completionPercentage.value
          : this.completionPercentage,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isOfflineEstimate: data.isOfflineEstimate.present
          ? data.isOfflineEstimate.value
          : this.isOfflineEstimate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('imagePath: $imagePath, ')
          ..write('transcription: $transcription, ')
          ..write('estimatedCarbs: $estimatedCarbs, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isOfflineEstimate: $isOfflineEstimate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    imagePath,
    transcription,
    estimatedCarbs,
    completionPercentage,
    syncStatus,
    isOfflineEstimate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.imagePath == this.imagePath &&
          other.transcription == this.transcription &&
          other.estimatedCarbs == this.estimatedCarbs &&
          other.completionPercentage == this.completionPercentage &&
          other.syncStatus == this.syncStatus &&
          other.isOfflineEstimate == this.isOfflineEstimate);
}

class MealLogsCompanion extends UpdateCompanion<MealLog> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String?> imagePath;
  final Value<String?> transcription;
  final Value<double> estimatedCarbs;
  final Value<int> completionPercentage;
  final Value<String> syncStatus;
  final Value<bool> isOfflineEstimate;
  const MealLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.transcription = const Value.absent(),
    this.estimatedCarbs = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isOfflineEstimate = const Value.absent(),
  });
  MealLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    this.imagePath = const Value.absent(),
    this.transcription = const Value.absent(),
    required double estimatedCarbs,
    this.completionPercentage = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isOfflineEstimate = const Value.absent(),
  }) : timestamp = Value(timestamp),
       estimatedCarbs = Value(estimatedCarbs);
  static Insertable<MealLog> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? imagePath,
    Expression<String>? transcription,
    Expression<double>? estimatedCarbs,
    Expression<int>? completionPercentage,
    Expression<String>? syncStatus,
    Expression<bool>? isOfflineEstimate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (imagePath != null) 'image_path': imagePath,
      if (transcription != null) 'transcription': transcription,
      if (estimatedCarbs != null) 'estimated_carbs': estimatedCarbs,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isOfflineEstimate != null) 'is_offline_estimate': isOfflineEstimate,
    });
  }

  MealLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<String?>? imagePath,
    Value<String?>? transcription,
    Value<double>? estimatedCarbs,
    Value<int>? completionPercentage,
    Value<String>? syncStatus,
    Value<bool>? isOfflineEstimate,
  }) {
    return MealLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      transcription: transcription ?? this.transcription,
      estimatedCarbs: estimatedCarbs ?? this.estimatedCarbs,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      syncStatus: syncStatus ?? this.syncStatus,
      isOfflineEstimate: isOfflineEstimate ?? this.isOfflineEstimate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (transcription.present) {
      map['transcription'] = Variable<String>(transcription.value);
    }
    if (estimatedCarbs.present) {
      map['estimated_carbs'] = Variable<double>(estimatedCarbs.value);
    }
    if (completionPercentage.present) {
      map['completion_percentage'] = Variable<int>(completionPercentage.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isOfflineEstimate.present) {
      map['is_offline_estimate'] = Variable<bool>(isOfflineEstimate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('imagePath: $imagePath, ')
          ..write('transcription: $transcription, ')
          ..write('estimatedCarbs: $estimatedCarbs, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isOfflineEstimate: $isOfflineEstimate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LogsTable logs = $LogsTable(this);
  late final $LocalFoodsTable localFoods = $LocalFoodsTable(this);
  late final $CustomFoodsTable customFoods = $CustomFoodsTable(this);
  late final $MealLogsTable mealLogs = $MealLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    logs,
    localFoods,
    customFoods,
    mealLogs,
  ];
}

typedef $$LogsTableCreateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      Value<double?> bgValue,
      Value<String> bgUnit,
      Value<String?> contextTags,
      Value<String?> foodVolume,
      Value<bool> finishedMeal,
    });
typedef $$LogsTableUpdateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<double?> bgValue,
      Value<String> bgUnit,
      Value<String?> contextTags,
      Value<String?> foodVolume,
      Value<bool> finishedMeal,
    });

class $$LogsTableFilterComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bgValue => $composableBuilder(
    column: $table.bgValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bgUnit => $composableBuilder(
    column: $table.bgUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodVolume => $composableBuilder(
    column: $table.foodVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finishedMeal => $composableBuilder(
    column: $table.finishedMeal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogsTableOrderingComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bgValue => $composableBuilder(
    column: $table.bgValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bgUnit => $composableBuilder(
    column: $table.bgUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodVolume => $composableBuilder(
    column: $table.foodVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finishedMeal => $composableBuilder(
    column: $table.finishedMeal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get bgValue =>
      $composableBuilder(column: $table.bgValue, builder: (column) => column);

  GeneratedColumn<String> get bgUnit =>
      $composableBuilder(column: $table.bgUnit, builder: (column) => column);

  GeneratedColumn<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodVolume => $composableBuilder(
    column: $table.foodVolume,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get finishedMeal => $composableBuilder(
    column: $table.finishedMeal,
    builder: (column) => column,
  );
}

class $$LogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogsTable,
          Log,
          $$LogsTableFilterComposer,
          $$LogsTableOrderingComposer,
          $$LogsTableAnnotationComposer,
          $$LogsTableCreateCompanionBuilder,
          $$LogsTableUpdateCompanionBuilder,
          (Log, BaseReferences<_$AppDatabase, $LogsTable, Log>),
          Log,
          PrefetchHooks Function()
        > {
  $$LogsTableTableManager(_$AppDatabase db, $LogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> bgValue = const Value.absent(),
                Value<String> bgUnit = const Value.absent(),
                Value<String?> contextTags = const Value.absent(),
                Value<String?> foodVolume = const Value.absent(),
                Value<bool> finishedMeal = const Value.absent(),
              }) => LogsCompanion(
                id: id,
                timestamp: timestamp,
                bgValue: bgValue,
                bgUnit: bgUnit,
                contextTags: contextTags,
                foodVolume: foodVolume,
                finishedMeal: finishedMeal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                Value<double?> bgValue = const Value.absent(),
                Value<String> bgUnit = const Value.absent(),
                Value<String?> contextTags = const Value.absent(),
                Value<String?> foodVolume = const Value.absent(),
                Value<bool> finishedMeal = const Value.absent(),
              }) => LogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                bgValue: bgValue,
                bgUnit: bgUnit,
                contextTags: contextTags,
                foodVolume: foodVolume,
                finishedMeal: finishedMeal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogsTable,
      Log,
      $$LogsTableFilterComposer,
      $$LogsTableOrderingComposer,
      $$LogsTableAnnotationComposer,
      $$LogsTableCreateCompanionBuilder,
      $$LogsTableUpdateCompanionBuilder,
      (Log, BaseReferences<_$AppDatabase, $LogsTable, Log>),
      Log,
      PrefetchHooks Function()
    >;
typedef $$LocalFoodsTableCreateCompanionBuilder =
    LocalFoodsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> servingSize,
      required double carbsPerServing,
    });
typedef $$LocalFoodsTableUpdateCompanionBuilder =
    LocalFoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> servingSize,
      Value<double> carbsPerServing,
    });

class $$LocalFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => column,
  );
}

class $$LocalFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFoodsTable,
          LocalFood,
          $$LocalFoodsTableFilterComposer,
          $$LocalFoodsTableOrderingComposer,
          $$LocalFoodsTableAnnotationComposer,
          $$LocalFoodsTableCreateCompanionBuilder,
          $$LocalFoodsTableUpdateCompanionBuilder,
          (
            LocalFood,
            BaseReferences<_$AppDatabase, $LocalFoodsTable, LocalFood>,
          ),
          LocalFood,
          PrefetchHooks Function()
        > {
  $$LocalFoodsTableTableManager(_$AppDatabase db, $LocalFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> servingSize = const Value.absent(),
                Value<double> carbsPerServing = const Value.absent(),
              }) => LocalFoodsCompanion(
                id: id,
                name: name,
                servingSize: servingSize,
                carbsPerServing: carbsPerServing,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> servingSize = const Value.absent(),
                required double carbsPerServing,
              }) => LocalFoodsCompanion.insert(
                id: id,
                name: name,
                servingSize: servingSize,
                carbsPerServing: carbsPerServing,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFoodsTable,
      LocalFood,
      $$LocalFoodsTableFilterComposer,
      $$LocalFoodsTableOrderingComposer,
      $$LocalFoodsTableAnnotationComposer,
      $$LocalFoodsTableCreateCompanionBuilder,
      $$LocalFoodsTableUpdateCompanionBuilder,
      (LocalFood, BaseReferences<_$AppDatabase, $LocalFoodsTable, LocalFood>),
      LocalFood,
      PrefetchHooks Function()
    >;
typedef $$CustomFoodsTableCreateCompanionBuilder =
    CustomFoodsCompanion Function({
      Value<int> id,
      required String userDefinedName,
      Value<String?> barcode,
      Value<String> servingSize,
      required double carbsPerServing,
    });
typedef $$CustomFoodsTableUpdateCompanionBuilder =
    CustomFoodsCompanion Function({
      Value<int> id,
      Value<String> userDefinedName,
      Value<String?> barcode,
      Value<String> servingSize,
      Value<double> carbsPerServing,
    });

class $$CustomFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userDefinedName => $composableBuilder(
    column: $table.userDefinedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userDefinedName => $composableBuilder(
    column: $table.userDefinedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userDefinedName => $composableBuilder(
    column: $table.userDefinedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPerServing => $composableBuilder(
    column: $table.carbsPerServing,
    builder: (column) => column,
  );
}

class $$CustomFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFoodsTable,
          CustomFood,
          $$CustomFoodsTableFilterComposer,
          $$CustomFoodsTableOrderingComposer,
          $$CustomFoodsTableAnnotationComposer,
          $$CustomFoodsTableCreateCompanionBuilder,
          $$CustomFoodsTableUpdateCompanionBuilder,
          (
            CustomFood,
            BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>,
          ),
          CustomFood,
          PrefetchHooks Function()
        > {
  $$CustomFoodsTableTableManager(_$AppDatabase db, $CustomFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userDefinedName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> servingSize = const Value.absent(),
                Value<double> carbsPerServing = const Value.absent(),
              }) => CustomFoodsCompanion(
                id: id,
                userDefinedName: userDefinedName,
                barcode: barcode,
                servingSize: servingSize,
                carbsPerServing: carbsPerServing,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userDefinedName,
                Value<String?> barcode = const Value.absent(),
                Value<String> servingSize = const Value.absent(),
                required double carbsPerServing,
              }) => CustomFoodsCompanion.insert(
                id: id,
                userDefinedName: userDefinedName,
                barcode: barcode,
                servingSize: servingSize,
                carbsPerServing: carbsPerServing,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFoodsTable,
      CustomFood,
      $$CustomFoodsTableFilterComposer,
      $$CustomFoodsTableOrderingComposer,
      $$CustomFoodsTableAnnotationComposer,
      $$CustomFoodsTableCreateCompanionBuilder,
      $$CustomFoodsTableUpdateCompanionBuilder,
      (
        CustomFood,
        BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>,
      ),
      CustomFood,
      PrefetchHooks Function()
    >;
typedef $$MealLogsTableCreateCompanionBuilder =
    MealLogsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      Value<String?> imagePath,
      Value<String?> transcription,
      required double estimatedCarbs,
      Value<int> completionPercentage,
      Value<String> syncStatus,
      Value<bool> isOfflineEstimate,
    });
typedef $$MealLogsTableUpdateCompanionBuilder =
    MealLogsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<String?> imagePath,
      Value<String?> transcription,
      Value<double> estimatedCarbs,
      Value<int> completionPercentage,
      Value<String> syncStatus,
      Value<bool> isOfflineEstimate,
    });

class $$MealLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MealLogsTable> {
  $$MealLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedCarbs => $composableBuilder(
    column: $table.estimatedCarbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOfflineEstimate => $composableBuilder(
    column: $table.isOfflineEstimate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealLogsTable> {
  $$MealLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedCarbs => $composableBuilder(
    column: $table.estimatedCarbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOfflineEstimate => $composableBuilder(
    column: $table.isOfflineEstimate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealLogsTable> {
  $$MealLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get estimatedCarbs => $composableBuilder(
    column: $table.estimatedCarbs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOfflineEstimate => $composableBuilder(
    column: $table.isOfflineEstimate,
    builder: (column) => column,
  );
}

class $$MealLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealLogsTable,
          MealLog,
          $$MealLogsTableFilterComposer,
          $$MealLogsTableOrderingComposer,
          $$MealLogsTableAnnotationComposer,
          $$MealLogsTableCreateCompanionBuilder,
          $$MealLogsTableUpdateCompanionBuilder,
          (MealLog, BaseReferences<_$AppDatabase, $MealLogsTable, MealLog>),
          MealLog,
          PrefetchHooks Function()
        > {
  $$MealLogsTableTableManager(_$AppDatabase db, $MealLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> transcription = const Value.absent(),
                Value<double> estimatedCarbs = const Value.absent(),
                Value<int> completionPercentage = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isOfflineEstimate = const Value.absent(),
              }) => MealLogsCompanion(
                id: id,
                timestamp: timestamp,
                imagePath: imagePath,
                transcription: transcription,
                estimatedCarbs: estimatedCarbs,
                completionPercentage: completionPercentage,
                syncStatus: syncStatus,
                isOfflineEstimate: isOfflineEstimate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> transcription = const Value.absent(),
                required double estimatedCarbs,
                Value<int> completionPercentage = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isOfflineEstimate = const Value.absent(),
              }) => MealLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                imagePath: imagePath,
                transcription: transcription,
                estimatedCarbs: estimatedCarbs,
                completionPercentage: completionPercentage,
                syncStatus: syncStatus,
                isOfflineEstimate: isOfflineEstimate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealLogsTable,
      MealLog,
      $$MealLogsTableFilterComposer,
      $$MealLogsTableOrderingComposer,
      $$MealLogsTableAnnotationComposer,
      $$MealLogsTableCreateCompanionBuilder,
      $$MealLogsTableUpdateCompanionBuilder,
      (MealLog, BaseReferences<_$AppDatabase, $MealLogsTable, MealLog>),
      MealLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
  $$LocalFoodsTableTableManager get localFoods =>
      $$LocalFoodsTableTableManager(_db, _db.localFoods);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db, _db.customFoods);
  $$MealLogsTableTableManager get mealLogs =>
      $$MealLogsTableTableManager(_db, _db.mealLogs);
}
