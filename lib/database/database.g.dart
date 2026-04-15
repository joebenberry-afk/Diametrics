// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _totalCaloriesMeta = const VerificationMeta(
    'totalCalories',
  );
  @override
  late final GeneratedColumn<double> totalCalories = GeneratedColumn<double>(
    'total_calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalProteinMeta = const VerificationMeta(
    'totalProtein',
  );
  @override
  late final GeneratedColumn<double> totalProtein = GeneratedColumn<double>(
    'total_protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalFatMeta = const VerificationMeta(
    'totalFat',
  );
  @override
  late final GeneratedColumn<double> totalFat = GeneratedColumn<double>(
    'total_fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    totalCalories,
    totalProtein,
    totalFat,
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
    if (data.containsKey('total_calories')) {
      context.handle(
        _totalCaloriesMeta,
        totalCalories.isAcceptableOrUnknown(
          data['total_calories']!,
          _totalCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('total_protein')) {
      context.handle(
        _totalProteinMeta,
        totalProtein.isAcceptableOrUnknown(
          data['total_protein']!,
          _totalProteinMeta,
        ),
      );
    }
    if (data.containsKey('total_fat')) {
      context.handle(
        _totalFatMeta,
        totalFat.isAcceptableOrUnknown(data['total_fat']!, _totalFatMeta),
      );
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
      totalCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_calories'],
      )!,
      totalProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_protein'],
      )!,
      totalFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_fat'],
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
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final int completionPercentage;
  final String syncStatus;
  final bool isOfflineEstimate;
  const MealLog({
    required this.id,
    required this.timestamp,
    this.imagePath,
    this.transcription,
    required this.estimatedCarbs,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
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
    map['total_calories'] = Variable<double>(totalCalories);
    map['total_protein'] = Variable<double>(totalProtein);
    map['total_fat'] = Variable<double>(totalFat);
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
      totalCalories: Value(totalCalories),
      totalProtein: Value(totalProtein),
      totalFat: Value(totalFat),
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
      totalCalories: serializer.fromJson<double>(json['totalCalories']),
      totalProtein: serializer.fromJson<double>(json['totalProtein']),
      totalFat: serializer.fromJson<double>(json['totalFat']),
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
      'totalCalories': serializer.toJson<double>(totalCalories),
      'totalProtein': serializer.toJson<double>(totalProtein),
      'totalFat': serializer.toJson<double>(totalFat),
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
    double? totalCalories,
    double? totalProtein,
    double? totalFat,
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
    totalCalories: totalCalories ?? this.totalCalories,
    totalProtein: totalProtein ?? this.totalProtein,
    totalFat: totalFat ?? this.totalFat,
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
      totalCalories: data.totalCalories.present
          ? data.totalCalories.value
          : this.totalCalories,
      totalProtein: data.totalProtein.present
          ? data.totalProtein.value
          : this.totalProtein,
      totalFat: data.totalFat.present ? data.totalFat.value : this.totalFat,
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
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalFat: $totalFat, ')
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
    totalCalories,
    totalProtein,
    totalFat,
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
          other.totalCalories == this.totalCalories &&
          other.totalProtein == this.totalProtein &&
          other.totalFat == this.totalFat &&
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
  final Value<double> totalCalories;
  final Value<double> totalProtein;
  final Value<double> totalFat;
  final Value<int> completionPercentage;
  final Value<String> syncStatus;
  final Value<bool> isOfflineEstimate;
  const MealLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.transcription = const Value.absent(),
    this.estimatedCarbs = const Value.absent(),
    this.totalCalories = const Value.absent(),
    this.totalProtein = const Value.absent(),
    this.totalFat = const Value.absent(),
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
    this.totalCalories = const Value.absent(),
    this.totalProtein = const Value.absent(),
    this.totalFat = const Value.absent(),
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
    Expression<double>? totalCalories,
    Expression<double>? totalProtein,
    Expression<double>? totalFat,
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
      if (totalCalories != null) 'total_calories': totalCalories,
      if (totalProtein != null) 'total_protein': totalProtein,
      if (totalFat != null) 'total_fat': totalFat,
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
    Value<double>? totalCalories,
    Value<double>? totalProtein,
    Value<double>? totalFat,
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
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFat: totalFat ?? this.totalFat,
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
    if (totalCalories.present) {
      map['total_calories'] = Variable<double>(totalCalories.value);
    }
    if (totalProtein.present) {
      map['total_protein'] = Variable<double>(totalProtein.value);
    }
    if (totalFat.present) {
      map['total_fat'] = Variable<double>(totalFat.value);
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
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalFat: $totalFat, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isOfflineEstimate: $isOfflineEstimate')
          ..write(')'))
        .toString();
  }
}

class $N5kIngredientsTable extends N5kIngredients
    with TableInfo<$N5kIngredientsTable, N5kIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $N5kIngredientsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _calPerGMeta = const VerificationMeta(
    'calPerG',
  );
  @override
  late final GeneratedColumn<double> calPerG = GeneratedColumn<double>(
    'cal_per_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPerGMeta = const VerificationMeta(
    'fatPerG',
  );
  @override
  late final GeneratedColumn<double> fatPerG = GeneratedColumn<double>(
    'fat_per_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbPerGMeta = const VerificationMeta(
    'carbPerG',
  );
  @override
  late final GeneratedColumn<double> carbPerG = GeneratedColumn<double>(
    'carb_per_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPerGMeta = const VerificationMeta(
    'proteinPerG',
  );
  @override
  late final GeneratedColumn<double> proteinPerG = GeneratedColumn<double>(
    'protein_per_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    calPerG,
    fatPerG,
    carbPerG,
    proteinPerG,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'n5k_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<N5kIngredient> instance, {
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
    if (data.containsKey('cal_per_g')) {
      context.handle(
        _calPerGMeta,
        calPerG.isAcceptableOrUnknown(data['cal_per_g']!, _calPerGMeta),
      );
    } else if (isInserting) {
      context.missing(_calPerGMeta);
    }
    if (data.containsKey('fat_per_g')) {
      context.handle(
        _fatPerGMeta,
        fatPerG.isAcceptableOrUnknown(data['fat_per_g']!, _fatPerGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPerGMeta);
    }
    if (data.containsKey('carb_per_g')) {
      context.handle(
        _carbPerGMeta,
        carbPerG.isAcceptableOrUnknown(data['carb_per_g']!, _carbPerGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbPerGMeta);
    }
    if (data.containsKey('protein_per_g')) {
      context.handle(
        _proteinPerGMeta,
        proteinPerG.isAcceptableOrUnknown(
          data['protein_per_g']!,
          _proteinPerGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPerGMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  N5kIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return N5kIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calPerG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cal_per_g'],
      )!,
      fatPerG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per_g'],
      )!,
      carbPerG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb_per_g'],
      )!,
      proteinPerG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_g'],
      )!,
    );
  }

  @override
  $N5kIngredientsTable createAlias(String alias) {
    return $N5kIngredientsTable(attachedDatabase, alias);
  }
}

class N5kIngredient extends DataClass implements Insertable<N5kIngredient> {
  final int id;
  final String name;
  final double calPerG;
  final double fatPerG;
  final double carbPerG;
  final double proteinPerG;
  const N5kIngredient({
    required this.id,
    required this.name,
    required this.calPerG,
    required this.fatPerG,
    required this.carbPerG,
    required this.proteinPerG,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cal_per_g'] = Variable<double>(calPerG);
    map['fat_per_g'] = Variable<double>(fatPerG);
    map['carb_per_g'] = Variable<double>(carbPerG);
    map['protein_per_g'] = Variable<double>(proteinPerG);
    return map;
  }

  N5kIngredientsCompanion toCompanion(bool nullToAbsent) {
    return N5kIngredientsCompanion(
      id: Value(id),
      name: Value(name),
      calPerG: Value(calPerG),
      fatPerG: Value(fatPerG),
      carbPerG: Value(carbPerG),
      proteinPerG: Value(proteinPerG),
    );
  }

  factory N5kIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return N5kIngredient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      calPerG: serializer.fromJson<double>(json['calPerG']),
      fatPerG: serializer.fromJson<double>(json['fatPerG']),
      carbPerG: serializer.fromJson<double>(json['carbPerG']),
      proteinPerG: serializer.fromJson<double>(json['proteinPerG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'calPerG': serializer.toJson<double>(calPerG),
      'fatPerG': serializer.toJson<double>(fatPerG),
      'carbPerG': serializer.toJson<double>(carbPerG),
      'proteinPerG': serializer.toJson<double>(proteinPerG),
    };
  }

  N5kIngredient copyWith({
    int? id,
    String? name,
    double? calPerG,
    double? fatPerG,
    double? carbPerG,
    double? proteinPerG,
  }) => N5kIngredient(
    id: id ?? this.id,
    name: name ?? this.name,
    calPerG: calPerG ?? this.calPerG,
    fatPerG: fatPerG ?? this.fatPerG,
    carbPerG: carbPerG ?? this.carbPerG,
    proteinPerG: proteinPerG ?? this.proteinPerG,
  );
  N5kIngredient copyWithCompanion(N5kIngredientsCompanion data) {
    return N5kIngredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calPerG: data.calPerG.present ? data.calPerG.value : this.calPerG,
      fatPerG: data.fatPerG.present ? data.fatPerG.value : this.fatPerG,
      carbPerG: data.carbPerG.present ? data.carbPerG.value : this.carbPerG,
      proteinPerG: data.proteinPerG.present
          ? data.proteinPerG.value
          : this.proteinPerG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('N5kIngredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calPerG: $calPerG, ')
          ..write('fatPerG: $fatPerG, ')
          ..write('carbPerG: $carbPerG, ')
          ..write('proteinPerG: $proteinPerG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, calPerG, fatPerG, carbPerG, proteinPerG);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is N5kIngredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.calPerG == this.calPerG &&
          other.fatPerG == this.fatPerG &&
          other.carbPerG == this.carbPerG &&
          other.proteinPerG == this.proteinPerG);
}

class N5kIngredientsCompanion extends UpdateCompanion<N5kIngredient> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> calPerG;
  final Value<double> fatPerG;
  final Value<double> carbPerG;
  final Value<double> proteinPerG;
  const N5kIngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calPerG = const Value.absent(),
    this.fatPerG = const Value.absent(),
    this.carbPerG = const Value.absent(),
    this.proteinPerG = const Value.absent(),
  });
  N5kIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double calPerG,
    required double fatPerG,
    required double carbPerG,
    required double proteinPerG,
  }) : name = Value(name),
       calPerG = Value(calPerG),
       fatPerG = Value(fatPerG),
       carbPerG = Value(carbPerG),
       proteinPerG = Value(proteinPerG);
  static Insertable<N5kIngredient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? calPerG,
    Expression<double>? fatPerG,
    Expression<double>? carbPerG,
    Expression<double>? proteinPerG,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calPerG != null) 'cal_per_g': calPerG,
      if (fatPerG != null) 'fat_per_g': fatPerG,
      if (carbPerG != null) 'carb_per_g': carbPerG,
      if (proteinPerG != null) 'protein_per_g': proteinPerG,
    });
  }

  N5kIngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? calPerG,
    Value<double>? fatPerG,
    Value<double>? carbPerG,
    Value<double>? proteinPerG,
  }) {
    return N5kIngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      calPerG: calPerG ?? this.calPerG,
      fatPerG: fatPerG ?? this.fatPerG,
      carbPerG: carbPerG ?? this.carbPerG,
      proteinPerG: proteinPerG ?? this.proteinPerG,
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
    if (calPerG.present) {
      map['cal_per_g'] = Variable<double>(calPerG.value);
    }
    if (fatPerG.present) {
      map['fat_per_g'] = Variable<double>(fatPerG.value);
    }
    if (carbPerG.present) {
      map['carb_per_g'] = Variable<double>(carbPerG.value);
    }
    if (proteinPerG.present) {
      map['protein_per_g'] = Variable<double>(proteinPerG.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('N5kIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calPerG: $calPerG, ')
          ..write('fatPerG: $fatPerG, ')
          ..write('carbPerG: $carbPerG, ')
          ..write('proteinPerG: $proteinPerG')
          ..write(')'))
        .toString();
  }
}

class $GlucoseLogsTable extends GlucoseLogs
    with TableInfo<$GlucoseLogsTable, GlucoseLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlucoseLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    value,
    unit,
    context,
    timestamp,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glucose_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlucoseLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlucoseLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlucoseLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GlucoseLogsTable createAlias(String alias) {
    return $GlucoseLogsTable(attachedDatabase, alias);
  }
}

class GlucoseLogRow extends DataClass implements Insertable<GlucoseLogRow> {
  final String id;
  final double value;
  final String unit;
  final String context;
  final DateTime timestamp;
  final String? notes;
  const GlucoseLogRow({
    required this.id,
    required this.value,
    required this.unit,
    required this.context,
    required this.timestamp,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['context'] = Variable<String>(context);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GlucoseLogsCompanion toCompanion(bool nullToAbsent) {
    return GlucoseLogsCompanion(
      id: Value(id),
      value: Value(value),
      unit: Value(unit),
      context: Value(context),
      timestamp: Value(timestamp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory GlucoseLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlucoseLogRow(
      id: serializer.fromJson<String>(json['id']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      context: serializer.fromJson<String>(json['context']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'context': serializer.toJson<String>(context),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  GlucoseLogRow copyWith({
    String? id,
    double? value,
    String? unit,
    String? context,
    DateTime? timestamp,
    Value<String?> notes = const Value.absent(),
  }) => GlucoseLogRow(
    id: id ?? this.id,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    context: context ?? this.context,
    timestamp: timestamp ?? this.timestamp,
    notes: notes.present ? notes.value : this.notes,
  );
  GlucoseLogRow copyWithCompanion(GlucoseLogsCompanion data) {
    return GlucoseLogRow(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      context: data.context.present ? data.context.value : this.context,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseLogRow(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value, unit, context, timestamp, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlucoseLogRow &&
          other.id == this.id &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.context == this.context &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes);
}

class GlucoseLogsCompanion extends UpdateCompanion<GlucoseLogRow> {
  final Value<String> id;
  final Value<double> value;
  final Value<String> unit;
  final Value<String> context;
  final Value<DateTime> timestamp;
  final Value<String?> notes;
  final Value<int> rowid;
  const GlucoseLogsCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.context = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlucoseLogsCompanion.insert({
    required String id,
    required double value,
    required String unit,
    required String context,
    required DateTime timestamp,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       value = Value(value),
       unit = Value(unit),
       context = Value(context),
       timestamp = Value(timestamp);
  static Insertable<GlucoseLogRow> custom({
    Expression<String>? id,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? context,
    Expression<DateTime>? timestamp,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (context != null) 'context': context,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlucoseLogsCompanion copyWith({
    Value<String>? id,
    Value<double>? value,
    Value<String>? unit,
    Value<String>? context,
    Value<DateTime>? timestamp,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return GlucoseLogsCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseLogsCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealMacroLogsTable extends MealMacroLogs
    with TableInfo<$MealMacroLogsTable, MealMacroLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealMacroLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbohydratesMeta = const VerificationMeta(
    'carbohydrates',
  );
  @override
  late final GeneratedColumn<double> carbohydrates = GeneratedColumn<double>(
    'carbohydrates',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dietaryFiberMeta = const VerificationMeta(
    'dietaryFiber',
  );
  @override
  late final GeneratedColumn<double> dietaryFiber = GeneratedColumn<double>(
    'dietary_fiber',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _proteinsMeta = const VerificationMeta(
    'proteins',
  );
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
    'proteins',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
    'fats',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _containsAlcoholMeta = const VerificationMeta(
    'containsAlcohol',
  );
  @override
  late final GeneratedColumn<bool> containsAlcohol = GeneratedColumn<bool>(
    'contains_alcohol',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("contains_alcohol" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _containsCaffeineMeta = const VerificationMeta(
    'containsCaffeine',
  );
  @override
  late final GeneratedColumn<bool> containsCaffeine = GeneratedColumn<bool>(
    'contains_caffeine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("contains_caffeine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodFormFactorMeta = const VerificationMeta(
    'foodFormFactor',
  );
  @override
  late final GeneratedColumn<String> foodFormFactor = GeneratedColumn<String>(
    'food_form_factor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _postExerciseMeta = const VerificationMeta(
    'postExercise',
  );
  @override
  late final GeneratedColumn<bool> postExercise = GeneratedColumn<bool>(
    'post_exercise',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("post_exercise" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    name,
    carbohydrates,
    dietaryFiber,
    proteins,
    fats,
    calories,
    containsAlcohol,
    containsCaffeine,
    mealType,
    foodFormFactor,
    postExercise,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_macro_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealMacroLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('carbohydrates')) {
      context.handle(
        _carbohydratesMeta,
        carbohydrates.isAcceptableOrUnknown(
          data['carbohydrates']!,
          _carbohydratesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydratesMeta);
    }
    if (data.containsKey('dietary_fiber')) {
      context.handle(
        _dietaryFiberMeta,
        dietaryFiber.isAcceptableOrUnknown(
          data['dietary_fiber']!,
          _dietaryFiberMeta,
        ),
      );
    }
    if (data.containsKey('proteins')) {
      context.handle(
        _proteinsMeta,
        proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinsMeta);
    }
    if (data.containsKey('fats')) {
      context.handle(
        _fatsMeta,
        fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('contains_alcohol')) {
      context.handle(
        _containsAlcoholMeta,
        containsAlcohol.isAcceptableOrUnknown(
          data['contains_alcohol']!,
          _containsAlcoholMeta,
        ),
      );
    }
    if (data.containsKey('contains_caffeine')) {
      context.handle(
        _containsCaffeineMeta,
        containsCaffeine.isAcceptableOrUnknown(
          data['contains_caffeine']!,
          _containsCaffeineMeta,
        ),
      );
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('food_form_factor')) {
      context.handle(
        _foodFormFactorMeta,
        foodFormFactor.isAcceptableOrUnknown(
          data['food_form_factor']!,
          _foodFormFactorMeta,
        ),
      );
    }
    if (data.containsKey('post_exercise')) {
      context.handle(
        _postExerciseMeta,
        postExercise.isAcceptableOrUnknown(
          data['post_exercise']!,
          _postExerciseMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealMacroLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealMacroLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      carbohydrates: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrates'],
      )!,
      dietaryFiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dietary_fiber'],
      )!,
      proteins: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteins'],
      )!,
      fats: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fats'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      containsAlcohol: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}contains_alcohol'],
      )!,
      containsCaffeine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}contains_caffeine'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      foodFormFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_form_factor'],
      )!,
      postExercise: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}post_exercise'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MealMacroLogsTable createAlias(String alias) {
    return $MealMacroLogsTable(attachedDatabase, alias);
  }
}

class MealMacroLog extends DataClass implements Insertable<MealMacroLog> {
  final String id;
  final DateTime timestamp;
  final String? name;
  final double carbohydrates;
  final double dietaryFiber;
  final double proteins;
  final double fats;
  final double calories;
  final bool containsAlcohol;
  final bool containsCaffeine;
  final String mealType;
  final String foodFormFactor;
  final bool postExercise;
  final String? notes;
  const MealMacroLog({
    required this.id,
    required this.timestamp,
    this.name,
    required this.carbohydrates,
    required this.dietaryFiber,
    required this.proteins,
    required this.fats,
    required this.calories,
    required this.containsAlcohol,
    required this.containsCaffeine,
    required this.mealType,
    required this.foodFormFactor,
    required this.postExercise,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['carbohydrates'] = Variable<double>(carbohydrates);
    map['dietary_fiber'] = Variable<double>(dietaryFiber);
    map['proteins'] = Variable<double>(proteins);
    map['fats'] = Variable<double>(fats);
    map['calories'] = Variable<double>(calories);
    map['contains_alcohol'] = Variable<bool>(containsAlcohol);
    map['contains_caffeine'] = Variable<bool>(containsCaffeine);
    map['meal_type'] = Variable<String>(mealType);
    map['food_form_factor'] = Variable<String>(foodFormFactor);
    map['post_exercise'] = Variable<bool>(postExercise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MealMacroLogsCompanion toCompanion(bool nullToAbsent) {
    return MealMacroLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      carbohydrates: Value(carbohydrates),
      dietaryFiber: Value(dietaryFiber),
      proteins: Value(proteins),
      fats: Value(fats),
      calories: Value(calories),
      containsAlcohol: Value(containsAlcohol),
      containsCaffeine: Value(containsCaffeine),
      mealType: Value(mealType),
      foodFormFactor: Value(foodFormFactor),
      postExercise: Value(postExercise),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory MealMacroLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealMacroLog(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      name: serializer.fromJson<String?>(json['name']),
      carbohydrates: serializer.fromJson<double>(json['carbohydrates']),
      dietaryFiber: serializer.fromJson<double>(json['dietaryFiber']),
      proteins: serializer.fromJson<double>(json['proteins']),
      fats: serializer.fromJson<double>(json['fats']),
      calories: serializer.fromJson<double>(json['calories']),
      containsAlcohol: serializer.fromJson<bool>(json['containsAlcohol']),
      containsCaffeine: serializer.fromJson<bool>(json['containsCaffeine']),
      mealType: serializer.fromJson<String>(json['mealType']),
      foodFormFactor: serializer.fromJson<String>(json['foodFormFactor']),
      postExercise: serializer.fromJson<bool>(json['postExercise']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'name': serializer.toJson<String?>(name),
      'carbohydrates': serializer.toJson<double>(carbohydrates),
      'dietaryFiber': serializer.toJson<double>(dietaryFiber),
      'proteins': serializer.toJson<double>(proteins),
      'fats': serializer.toJson<double>(fats),
      'calories': serializer.toJson<double>(calories),
      'containsAlcohol': serializer.toJson<bool>(containsAlcohol),
      'containsCaffeine': serializer.toJson<bool>(containsCaffeine),
      'mealType': serializer.toJson<String>(mealType),
      'foodFormFactor': serializer.toJson<String>(foodFormFactor),
      'postExercise': serializer.toJson<bool>(postExercise),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  MealMacroLog copyWith({
    String? id,
    DateTime? timestamp,
    Value<String?> name = const Value.absent(),
    double? carbohydrates,
    double? dietaryFiber,
    double? proteins,
    double? fats,
    double? calories,
    bool? containsAlcohol,
    bool? containsCaffeine,
    String? mealType,
    String? foodFormFactor,
    bool? postExercise,
    Value<String?> notes = const Value.absent(),
  }) => MealMacroLog(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    name: name.present ? name.value : this.name,
    carbohydrates: carbohydrates ?? this.carbohydrates,
    dietaryFiber: dietaryFiber ?? this.dietaryFiber,
    proteins: proteins ?? this.proteins,
    fats: fats ?? this.fats,
    calories: calories ?? this.calories,
    containsAlcohol: containsAlcohol ?? this.containsAlcohol,
    containsCaffeine: containsCaffeine ?? this.containsCaffeine,
    mealType: mealType ?? this.mealType,
    foodFormFactor: foodFormFactor ?? this.foodFormFactor,
    postExercise: postExercise ?? this.postExercise,
    notes: notes.present ? notes.value : this.notes,
  );
  MealMacroLog copyWithCompanion(MealMacroLogsCompanion data) {
    return MealMacroLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      name: data.name.present ? data.name.value : this.name,
      carbohydrates: data.carbohydrates.present
          ? data.carbohydrates.value
          : this.carbohydrates,
      dietaryFiber: data.dietaryFiber.present
          ? data.dietaryFiber.value
          : this.dietaryFiber,
      proteins: data.proteins.present ? data.proteins.value : this.proteins,
      fats: data.fats.present ? data.fats.value : this.fats,
      calories: data.calories.present ? data.calories.value : this.calories,
      containsAlcohol: data.containsAlcohol.present
          ? data.containsAlcohol.value
          : this.containsAlcohol,
      containsCaffeine: data.containsCaffeine.present
          ? data.containsCaffeine.value
          : this.containsCaffeine,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodFormFactor: data.foodFormFactor.present
          ? data.foodFormFactor.value
          : this.foodFormFactor,
      postExercise: data.postExercise.present
          ? data.postExercise.value
          : this.postExercise,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealMacroLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('name: $name, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('dietaryFiber: $dietaryFiber, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('calories: $calories, ')
          ..write('containsAlcohol: $containsAlcohol, ')
          ..write('containsCaffeine: $containsCaffeine, ')
          ..write('mealType: $mealType, ')
          ..write('foodFormFactor: $foodFormFactor, ')
          ..write('postExercise: $postExercise, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    name,
    carbohydrates,
    dietaryFiber,
    proteins,
    fats,
    calories,
    containsAlcohol,
    containsCaffeine,
    mealType,
    foodFormFactor,
    postExercise,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealMacroLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.name == this.name &&
          other.carbohydrates == this.carbohydrates &&
          other.dietaryFiber == this.dietaryFiber &&
          other.proteins == this.proteins &&
          other.fats == this.fats &&
          other.calories == this.calories &&
          other.containsAlcohol == this.containsAlcohol &&
          other.containsCaffeine == this.containsCaffeine &&
          other.mealType == this.mealType &&
          other.foodFormFactor == this.foodFormFactor &&
          other.postExercise == this.postExercise &&
          other.notes == this.notes);
}

class MealMacroLogsCompanion extends UpdateCompanion<MealMacroLog> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String?> name;
  final Value<double> carbohydrates;
  final Value<double> dietaryFiber;
  final Value<double> proteins;
  final Value<double> fats;
  final Value<double> calories;
  final Value<bool> containsAlcohol;
  final Value<bool> containsCaffeine;
  final Value<String> mealType;
  final Value<String> foodFormFactor;
  final Value<bool> postExercise;
  final Value<String?> notes;
  final Value<int> rowid;
  const MealMacroLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.name = const Value.absent(),
    this.carbohydrates = const Value.absent(),
    this.dietaryFiber = const Value.absent(),
    this.proteins = const Value.absent(),
    this.fats = const Value.absent(),
    this.calories = const Value.absent(),
    this.containsAlcohol = const Value.absent(),
    this.containsCaffeine = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodFormFactor = const Value.absent(),
    this.postExercise = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealMacroLogsCompanion.insert({
    required String id,
    required DateTime timestamp,
    this.name = const Value.absent(),
    required double carbohydrates,
    this.dietaryFiber = const Value.absent(),
    required double proteins,
    required double fats,
    this.calories = const Value.absent(),
    this.containsAlcohol = const Value.absent(),
    this.containsCaffeine = const Value.absent(),
    required String mealType,
    this.foodFormFactor = const Value.absent(),
    this.postExercise = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       carbohydrates = Value(carbohydrates),
       proteins = Value(proteins),
       fats = Value(fats),
       mealType = Value(mealType);
  static Insertable<MealMacroLog> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? name,
    Expression<double>? carbohydrates,
    Expression<double>? dietaryFiber,
    Expression<double>? proteins,
    Expression<double>? fats,
    Expression<double>? calories,
    Expression<bool>? containsAlcohol,
    Expression<bool>? containsCaffeine,
    Expression<String>? mealType,
    Expression<String>? foodFormFactor,
    Expression<bool>? postExercise,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (name != null) 'name': name,
      if (carbohydrates != null) 'carbohydrates': carbohydrates,
      if (dietaryFiber != null) 'dietary_fiber': dietaryFiber,
      if (proteins != null) 'proteins': proteins,
      if (fats != null) 'fats': fats,
      if (calories != null) 'calories': calories,
      if (containsAlcohol != null) 'contains_alcohol': containsAlcohol,
      if (containsCaffeine != null) 'contains_caffeine': containsCaffeine,
      if (mealType != null) 'meal_type': mealType,
      if (foodFormFactor != null) 'food_form_factor': foodFormFactor,
      if (postExercise != null) 'post_exercise': postExercise,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealMacroLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? timestamp,
    Value<String?>? name,
    Value<double>? carbohydrates,
    Value<double>? dietaryFiber,
    Value<double>? proteins,
    Value<double>? fats,
    Value<double>? calories,
    Value<bool>? containsAlcohol,
    Value<bool>? containsCaffeine,
    Value<String>? mealType,
    Value<String>? foodFormFactor,
    Value<bool>? postExercise,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MealMacroLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      dietaryFiber: dietaryFiber ?? this.dietaryFiber,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      calories: calories ?? this.calories,
      containsAlcohol: containsAlcohol ?? this.containsAlcohol,
      containsCaffeine: containsCaffeine ?? this.containsCaffeine,
      mealType: mealType ?? this.mealType,
      foodFormFactor: foodFormFactor ?? this.foodFormFactor,
      postExercise: postExercise ?? this.postExercise,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (carbohydrates.present) {
      map['carbohydrates'] = Variable<double>(carbohydrates.value);
    }
    if (dietaryFiber.present) {
      map['dietary_fiber'] = Variable<double>(dietaryFiber.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (containsAlcohol.present) {
      map['contains_alcohol'] = Variable<bool>(containsAlcohol.value);
    }
    if (containsCaffeine.present) {
      map['contains_caffeine'] = Variable<bool>(containsCaffeine.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (foodFormFactor.present) {
      map['food_form_factor'] = Variable<String>(foodFormFactor.value);
    }
    if (postExercise.present) {
      map['post_exercise'] = Variable<bool>(postExercise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealMacroLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('name: $name, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('dietaryFiber: $dietaryFiber, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('calories: $calories, ')
          ..write('containsAlcohol: $containsAlcohol, ')
          ..write('containsCaffeine: $containsCaffeine, ')
          ..write('mealType: $mealType, ')
          ..write('foodFormFactor: $foodFormFactor, ')
          ..write('postExercise: $postExercise, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationLogsTable extends MedicationLogs
    with TableInfo<$MedicationLogsTable, MedicationLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _medicationTypeMeta = const VerificationMeta(
    'medicationType',
  );
  @override
  late final GeneratedColumn<String> medicationType = GeneratedColumn<String>(
    'medication_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insulinTypeMeta = const VerificationMeta(
    'insulinType',
  );
  @override
  late final GeneratedColumn<String> insulinType = GeneratedColumn<String>(
    'insulin_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Humalog / NovoLog'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<double> units = GeneratedColumn<double>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    medicationType,
    insulinType,
    name,
    units,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('medication_type')) {
      context.handle(
        _medicationTypeMeta,
        medicationType.isAcceptableOrUnknown(
          data['medication_type']!,
          _medicationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationTypeMeta);
    }
    if (data.containsKey('insulin_type')) {
      context.handle(
        _insulinTypeMeta,
        insulinType.isAcceptableOrUnknown(
          data['insulin_type']!,
          _insulinTypeMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      medicationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_type'],
      )!,
      insulinType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insulin_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}units'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MedicationLogsTable createAlias(String alias) {
    return $MedicationLogsTable(attachedDatabase, alias);
  }
}

class MedicationLogRow extends DataClass
    implements Insertable<MedicationLogRow> {
  final String id;
  final DateTime timestamp;
  final String medicationType;
  final String insulinType;
  final String? name;
  final double units;
  final String? notes;
  const MedicationLogRow({
    required this.id,
    required this.timestamp,
    required this.medicationType,
    required this.insulinType,
    this.name,
    required this.units,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['medication_type'] = Variable<String>(medicationType);
    map['insulin_type'] = Variable<String>(insulinType);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['units'] = Variable<double>(units);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MedicationLogsCompanion toCompanion(bool nullToAbsent) {
    return MedicationLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      medicationType: Value(medicationType),
      insulinType: Value(insulinType),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      units: Value(units),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory MedicationLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationLogRow(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      medicationType: serializer.fromJson<String>(json['medicationType']),
      insulinType: serializer.fromJson<String>(json['insulinType']),
      name: serializer.fromJson<String?>(json['name']),
      units: serializer.fromJson<double>(json['units']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'medicationType': serializer.toJson<String>(medicationType),
      'insulinType': serializer.toJson<String>(insulinType),
      'name': serializer.toJson<String?>(name),
      'units': serializer.toJson<double>(units),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  MedicationLogRow copyWith({
    String? id,
    DateTime? timestamp,
    String? medicationType,
    String? insulinType,
    Value<String?> name = const Value.absent(),
    double? units,
    Value<String?> notes = const Value.absent(),
  }) => MedicationLogRow(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    medicationType: medicationType ?? this.medicationType,
    insulinType: insulinType ?? this.insulinType,
    name: name.present ? name.value : this.name,
    units: units ?? this.units,
    notes: notes.present ? notes.value : this.notes,
  );
  MedicationLogRow copyWithCompanion(MedicationLogsCompanion data) {
    return MedicationLogRow(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      medicationType: data.medicationType.present
          ? data.medicationType.value
          : this.medicationType,
      insulinType: data.insulinType.present
          ? data.insulinType.value
          : this.insulinType,
      name: data.name.present ? data.name.value : this.name,
      units: data.units.present ? data.units.value : this.units,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLogRow(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('medicationType: $medicationType, ')
          ..write('insulinType: $insulinType, ')
          ..write('name: $name, ')
          ..write('units: $units, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    medicationType,
    insulinType,
    name,
    units,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationLogRow &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.medicationType == this.medicationType &&
          other.insulinType == this.insulinType &&
          other.name == this.name &&
          other.units == this.units &&
          other.notes == this.notes);
}

class MedicationLogsCompanion extends UpdateCompanion<MedicationLogRow> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String> medicationType;
  final Value<String> insulinType;
  final Value<String?> name;
  final Value<double> units;
  final Value<String?> notes;
  final Value<int> rowid;
  const MedicationLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.medicationType = const Value.absent(),
    this.insulinType = const Value.absent(),
    this.name = const Value.absent(),
    this.units = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationLogsCompanion.insert({
    required String id,
    required DateTime timestamp,
    required String medicationType,
    this.insulinType = const Value.absent(),
    this.name = const Value.absent(),
    required double units,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       medicationType = Value(medicationType),
       units = Value(units);
  static Insertable<MedicationLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? medicationType,
    Expression<String>? insulinType,
    Expression<String>? name,
    Expression<double>? units,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (medicationType != null) 'medication_type': medicationType,
      if (insulinType != null) 'insulin_type': insulinType,
      if (name != null) 'name': name,
      if (units != null) 'units': units,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? timestamp,
    Value<String>? medicationType,
    Value<String>? insulinType,
    Value<String?>? name,
    Value<double>? units,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MedicationLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      medicationType: medicationType ?? this.medicationType,
      insulinType: insulinType ?? this.insulinType,
      name: name ?? this.name,
      units: units ?? this.units,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (medicationType.present) {
      map['medication_type'] = Variable<String>(medicationType.value);
    }
    if (insulinType.present) {
      map['insulin_type'] = Variable<String>(insulinType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (units.present) {
      map['units'] = Variable<double>(units.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('medicationType: $medicationType, ')
          ..write('insulinType: $insulinType, ')
          ..write('name: $name, ')
          ..write('units: $units, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diabetesTypeMeta = const VerificationMeta(
    'diabetesType',
  );
  @override
  late final GeneratedColumn<String> diabetesType = GeneratedColumn<String>(
    'diabetes_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosisYearMeta = const VerificationMeta(
    'diagnosisYear',
  );
  @override
  late final GeneratedColumn<int> diagnosisYear = GeneratedColumn<int>(
    'diagnosis_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredGlucoseUnitMeta =
      const VerificationMeta('preferredGlucoseUnit');
  @override
  late final GeneratedColumn<String> preferredGlucoseUnit =
      GeneratedColumn<String>(
        'preferred_glucose_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _usesInsulinMeta = const VerificationMeta(
    'usesInsulin',
  );
  @override
  late final GeneratedColumn<bool> usesInsulin = GeneratedColumn<bool>(
    'uses_insulin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uses_insulin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usesPillsMeta = const VerificationMeta(
    'usesPills',
  );
  @override
  late final GeneratedColumn<bool> usesPills = GeneratedColumn<bool>(
    'uses_pills',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uses_pills" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usesCgmMeta = const VerificationMeta(
    'usesCgm',
  );
  @override
  late final GeneratedColumn<bool> usesCgm = GeneratedColumn<bool>(
    'uses_cgm',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uses_cgm" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetGlucoseMinMeta = const VerificationMeta(
    'targetGlucoseMin',
  );
  @override
  late final GeneratedColumn<double> targetGlucoseMin = GeneratedColumn<double>(
    'target_glucose_min',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetGlucoseMaxMeta = const VerificationMeta(
    'targetGlucoseMax',
  );
  @override
  late final GeneratedColumn<double> targetGlucoseMax = GeneratedColumn<double>(
    'target_glucose_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metabolicClearanceRateMeta =
      const VerificationMeta('metabolicClearanceRate');
  @override
  late final GeneratedColumn<double> metabolicClearanceRate =
      GeneratedColumn<double>(
        'metabolic_clearance_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.010),
      );
  static const VerificationMeta _insulinSensitivityFactorMeta =
      const VerificationMeta('insulinSensitivityFactor');
  @override
  late final GeneratedColumn<double> insulinSensitivityFactor =
      GeneratedColumn<double>(
        'insulin_sensitivity_factor',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(50.0),
      );
  static const VerificationMeta _absorptionDelayBaseMeta =
      const VerificationMeta('absorptionDelayBase');
  @override
  late final GeneratedColumn<double> absorptionDelayBase =
      GeneratedColumn<double>(
        'absorption_delay_base',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(40.0),
      );
  static const VerificationMeta _tuningMealCountMeta = const VerificationMeta(
    'tuningMealCount',
  );
  @override
  late final GeneratedColumn<int> tuningMealCount = GeneratedColumn<int>(
    'tuning_meal_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fastingSetpointMeta = const VerificationMeta(
    'fastingSetpoint',
  );
  @override
  late final GeneratedColumn<double> fastingSetpoint = GeneratedColumn<double>(
    'fasting_setpoint',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(90.0),
  );
  static const VerificationMeta _insulinCategoryMeta = const VerificationMeta(
    'insulinCategory',
  );
  @override
  late final GeneratedColumn<String> insulinCategory = GeneratedColumn<String>(
    'insulin_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard_rapid'),
  );
  static const VerificationMeta _insulinDiaMinutesMeta = const VerificationMeta(
    'insulinDiaMinutes',
  );
  @override
  late final GeneratedColumn<double> insulinDiaMinutes =
      GeneratedColumn<double>(
        'insulin_dia_minutes',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(240.0),
      );
  static const VerificationMeta _ekfCovP1Meta = const VerificationMeta(
    'ekfCovP1',
  );
  @override
  late final GeneratedColumn<double> ekfCovP1 = GeneratedColumn<double>(
    'ekf_cov_p1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _ekfCovISFMeta = const VerificationMeta(
    'ekfCovISF',
  );
  @override
  late final GeneratedColumn<double> ekfCovISF = GeneratedColumn<double>(
    'ekf_cov_i_s_f',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _ekfCovTMaxMeta = const VerificationMeta(
    'ekfCovTMax',
  );
  @override
  late final GeneratedColumn<double> ekfCovTMax = GeneratedColumn<double>(
    'ekf_cov_t_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _hasAgreedToDisclaimerMeta =
      const VerificationMeta('hasAgreedToDisclaimer');
  @override
  late final GeneratedColumn<bool> hasAgreedToDisclaimer =
      GeneratedColumn<bool>(
        'has_agreed_to_disclaimer',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_agreed_to_disclaimer" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    age,
    gender,
    heightCm,
    weightKg,
    targetWeightKg,
    diabetesType,
    diagnosisYear,
    preferredGlucoseUnit,
    usesInsulin,
    usesPills,
    usesCgm,
    targetGlucoseMin,
    targetGlucoseMax,
    metabolicClearanceRate,
    insulinSensitivityFactor,
    absorptionDelayBase,
    tuningMealCount,
    fastingSetpoint,
    insulinCategory,
    insulinDiaMinutes,
    ekfCovP1,
    ekfCovISF,
    ekfCovTMax,
    hasAgreedToDisclaimer,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('diabetes_type')) {
      context.handle(
        _diabetesTypeMeta,
        diabetesType.isAcceptableOrUnknown(
          data['diabetes_type']!,
          _diabetesTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diabetesTypeMeta);
    }
    if (data.containsKey('diagnosis_year')) {
      context.handle(
        _diagnosisYearMeta,
        diagnosisYear.isAcceptableOrUnknown(
          data['diagnosis_year']!,
          _diagnosisYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diagnosisYearMeta);
    }
    if (data.containsKey('preferred_glucose_unit')) {
      context.handle(
        _preferredGlucoseUnitMeta,
        preferredGlucoseUnit.isAcceptableOrUnknown(
          data['preferred_glucose_unit']!,
          _preferredGlucoseUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredGlucoseUnitMeta);
    }
    if (data.containsKey('uses_insulin')) {
      context.handle(
        _usesInsulinMeta,
        usesInsulin.isAcceptableOrUnknown(
          data['uses_insulin']!,
          _usesInsulinMeta,
        ),
      );
    }
    if (data.containsKey('uses_pills')) {
      context.handle(
        _usesPillsMeta,
        usesPills.isAcceptableOrUnknown(data['uses_pills']!, _usesPillsMeta),
      );
    }
    if (data.containsKey('uses_cgm')) {
      context.handle(
        _usesCgmMeta,
        usesCgm.isAcceptableOrUnknown(data['uses_cgm']!, _usesCgmMeta),
      );
    }
    if (data.containsKey('target_glucose_min')) {
      context.handle(
        _targetGlucoseMinMeta,
        targetGlucoseMin.isAcceptableOrUnknown(
          data['target_glucose_min']!,
          _targetGlucoseMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetGlucoseMinMeta);
    }
    if (data.containsKey('target_glucose_max')) {
      context.handle(
        _targetGlucoseMaxMeta,
        targetGlucoseMax.isAcceptableOrUnknown(
          data['target_glucose_max']!,
          _targetGlucoseMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetGlucoseMaxMeta);
    }
    if (data.containsKey('metabolic_clearance_rate')) {
      context.handle(
        _metabolicClearanceRateMeta,
        metabolicClearanceRate.isAcceptableOrUnknown(
          data['metabolic_clearance_rate']!,
          _metabolicClearanceRateMeta,
        ),
      );
    }
    if (data.containsKey('insulin_sensitivity_factor')) {
      context.handle(
        _insulinSensitivityFactorMeta,
        insulinSensitivityFactor.isAcceptableOrUnknown(
          data['insulin_sensitivity_factor']!,
          _insulinSensitivityFactorMeta,
        ),
      );
    }
    if (data.containsKey('absorption_delay_base')) {
      context.handle(
        _absorptionDelayBaseMeta,
        absorptionDelayBase.isAcceptableOrUnknown(
          data['absorption_delay_base']!,
          _absorptionDelayBaseMeta,
        ),
      );
    }
    if (data.containsKey('tuning_meal_count')) {
      context.handle(
        _tuningMealCountMeta,
        tuningMealCount.isAcceptableOrUnknown(
          data['tuning_meal_count']!,
          _tuningMealCountMeta,
        ),
      );
    }
    if (data.containsKey('fasting_setpoint')) {
      context.handle(
        _fastingSetpointMeta,
        fastingSetpoint.isAcceptableOrUnknown(
          data['fasting_setpoint']!,
          _fastingSetpointMeta,
        ),
      );
    }
    if (data.containsKey('insulin_category')) {
      context.handle(
        _insulinCategoryMeta,
        insulinCategory.isAcceptableOrUnknown(
          data['insulin_category']!,
          _insulinCategoryMeta,
        ),
      );
    }
    if (data.containsKey('insulin_dia_minutes')) {
      context.handle(
        _insulinDiaMinutesMeta,
        insulinDiaMinutes.isAcceptableOrUnknown(
          data['insulin_dia_minutes']!,
          _insulinDiaMinutesMeta,
        ),
      );
    }
    if (data.containsKey('ekf_cov_p1')) {
      context.handle(
        _ekfCovP1Meta,
        ekfCovP1.isAcceptableOrUnknown(data['ekf_cov_p1']!, _ekfCovP1Meta),
      );
    }
    if (data.containsKey('ekf_cov_i_s_f')) {
      context.handle(
        _ekfCovISFMeta,
        ekfCovISF.isAcceptableOrUnknown(data['ekf_cov_i_s_f']!, _ekfCovISFMeta),
      );
    }
    if (data.containsKey('ekf_cov_t_max')) {
      context.handle(
        _ekfCovTMaxMeta,
        ekfCovTMax.isAcceptableOrUnknown(
          data['ekf_cov_t_max']!,
          _ekfCovTMaxMeta,
        ),
      );
    }
    if (data.containsKey('has_agreed_to_disclaimer')) {
      context.handle(
        _hasAgreedToDisclaimerMeta,
        hasAgreedToDisclaimer.isAcceptableOrUnknown(
          data['has_agreed_to_disclaimer']!,
          _hasAgreedToDisclaimerMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      diabetesType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diabetes_type'],
      )!,
      diagnosisYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diagnosis_year'],
      )!,
      preferredGlucoseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_glucose_unit'],
      )!,
      usesInsulin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uses_insulin'],
      )!,
      usesPills: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uses_pills'],
      )!,
      usesCgm: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uses_cgm'],
      )!,
      targetGlucoseMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_glucose_min'],
      )!,
      targetGlucoseMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_glucose_max'],
      )!,
      metabolicClearanceRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}metabolic_clearance_rate'],
      )!,
      insulinSensitivityFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insulin_sensitivity_factor'],
      )!,
      absorptionDelayBase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}absorption_delay_base'],
      )!,
      tuningMealCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tuning_meal_count'],
      )!,
      fastingSetpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fasting_setpoint'],
      )!,
      insulinCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insulin_category'],
      )!,
      insulinDiaMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insulin_dia_minutes'],
      )!,
      ekfCovP1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ekf_cov_p1'],
      )!,
      ekfCovISF: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ekf_cov_i_s_f'],
      )!,
      ekfCovTMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ekf_cov_t_max'],
      )!,
      hasAgreedToDisclaimer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_agreed_to_disclaimer'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final String diabetesType;
  final int diagnosisYear;
  final String preferredGlucoseUnit;
  final bool usesInsulin;
  final bool usesPills;
  final bool usesCgm;
  final double targetGlucoseMin;
  final double targetGlucoseMax;
  final double metabolicClearanceRate;
  final double insulinSensitivityFactor;
  final double absorptionDelayBase;
  final int tuningMealCount;
  final double fastingSetpoint;
  final String insulinCategory;
  final double insulinDiaMinutes;
  final double ekfCovP1;
  final double ekfCovISF;
  final double ekfCovTMax;
  final bool hasAgreedToDisclaimer;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfileRow({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.targetWeightKg,
    required this.diabetesType,
    required this.diagnosisYear,
    required this.preferredGlucoseUnit,
    required this.usesInsulin,
    required this.usesPills,
    required this.usesCgm,
    required this.targetGlucoseMin,
    required this.targetGlucoseMax,
    required this.metabolicClearanceRate,
    required this.insulinSensitivityFactor,
    required this.absorptionDelayBase,
    required this.tuningMealCount,
    required this.fastingSetpoint,
    required this.insulinCategory,
    required this.insulinDiaMinutes,
    required this.ekfCovP1,
    required this.ekfCovISF,
    required this.ekfCovTMax,
    required this.hasAgreedToDisclaimer,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    map['gender'] = Variable<String>(gender);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    map['diabetes_type'] = Variable<String>(diabetesType);
    map['diagnosis_year'] = Variable<int>(diagnosisYear);
    map['preferred_glucose_unit'] = Variable<String>(preferredGlucoseUnit);
    map['uses_insulin'] = Variable<bool>(usesInsulin);
    map['uses_pills'] = Variable<bool>(usesPills);
    map['uses_cgm'] = Variable<bool>(usesCgm);
    map['target_glucose_min'] = Variable<double>(targetGlucoseMin);
    map['target_glucose_max'] = Variable<double>(targetGlucoseMax);
    map['metabolic_clearance_rate'] = Variable<double>(metabolicClearanceRate);
    map['insulin_sensitivity_factor'] = Variable<double>(
      insulinSensitivityFactor,
    );
    map['absorption_delay_base'] = Variable<double>(absorptionDelayBase);
    map['tuning_meal_count'] = Variable<int>(tuningMealCount);
    map['fasting_setpoint'] = Variable<double>(fastingSetpoint);
    map['insulin_category'] = Variable<String>(insulinCategory);
    map['insulin_dia_minutes'] = Variable<double>(insulinDiaMinutes);
    map['ekf_cov_p1'] = Variable<double>(ekfCovP1);
    map['ekf_cov_i_s_f'] = Variable<double>(ekfCovISF);
    map['ekf_cov_t_max'] = Variable<double>(ekfCovTMax);
    map['has_agreed_to_disclaimer'] = Variable<bool>(hasAgreedToDisclaimer);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      gender: Value(gender),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      diabetesType: Value(diabetesType),
      diagnosisYear: Value(diagnosisYear),
      preferredGlucoseUnit: Value(preferredGlucoseUnit),
      usesInsulin: Value(usesInsulin),
      usesPills: Value(usesPills),
      usesCgm: Value(usesCgm),
      targetGlucoseMin: Value(targetGlucoseMin),
      targetGlucoseMax: Value(targetGlucoseMax),
      metabolicClearanceRate: Value(metabolicClearanceRate),
      insulinSensitivityFactor: Value(insulinSensitivityFactor),
      absorptionDelayBase: Value(absorptionDelayBase),
      tuningMealCount: Value(tuningMealCount),
      fastingSetpoint: Value(fastingSetpoint),
      insulinCategory: Value(insulinCategory),
      insulinDiaMinutes: Value(insulinDiaMinutes),
      ekfCovP1: Value(ekfCovP1),
      ekfCovISF: Value(ekfCovISF),
      ekfCovTMax: Value(ekfCovTMax),
      hasAgreedToDisclaimer: Value(hasAgreedToDisclaimer),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      gender: serializer.fromJson<String>(json['gender']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      diabetesType: serializer.fromJson<String>(json['diabetesType']),
      diagnosisYear: serializer.fromJson<int>(json['diagnosisYear']),
      preferredGlucoseUnit: serializer.fromJson<String>(
        json['preferredGlucoseUnit'],
      ),
      usesInsulin: serializer.fromJson<bool>(json['usesInsulin']),
      usesPills: serializer.fromJson<bool>(json['usesPills']),
      usesCgm: serializer.fromJson<bool>(json['usesCgm']),
      targetGlucoseMin: serializer.fromJson<double>(json['targetGlucoseMin']),
      targetGlucoseMax: serializer.fromJson<double>(json['targetGlucoseMax']),
      metabolicClearanceRate: serializer.fromJson<double>(
        json['metabolicClearanceRate'],
      ),
      insulinSensitivityFactor: serializer.fromJson<double>(
        json['insulinSensitivityFactor'],
      ),
      absorptionDelayBase: serializer.fromJson<double>(
        json['absorptionDelayBase'],
      ),
      tuningMealCount: serializer.fromJson<int>(json['tuningMealCount']),
      fastingSetpoint: serializer.fromJson<double>(json['fastingSetpoint']),
      insulinCategory: serializer.fromJson<String>(json['insulinCategory']),
      insulinDiaMinutes: serializer.fromJson<double>(json['insulinDiaMinutes']),
      ekfCovP1: serializer.fromJson<double>(json['ekfCovP1']),
      ekfCovISF: serializer.fromJson<double>(json['ekfCovISF']),
      ekfCovTMax: serializer.fromJson<double>(json['ekfCovTMax']),
      hasAgreedToDisclaimer: serializer.fromJson<bool>(
        json['hasAgreedToDisclaimer'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'gender': serializer.toJson<String>(gender),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'diabetesType': serializer.toJson<String>(diabetesType),
      'diagnosisYear': serializer.toJson<int>(diagnosisYear),
      'preferredGlucoseUnit': serializer.toJson<String>(preferredGlucoseUnit),
      'usesInsulin': serializer.toJson<bool>(usesInsulin),
      'usesPills': serializer.toJson<bool>(usesPills),
      'usesCgm': serializer.toJson<bool>(usesCgm),
      'targetGlucoseMin': serializer.toJson<double>(targetGlucoseMin),
      'targetGlucoseMax': serializer.toJson<double>(targetGlucoseMax),
      'metabolicClearanceRate': serializer.toJson<double>(
        metabolicClearanceRate,
      ),
      'insulinSensitivityFactor': serializer.toJson<double>(
        insulinSensitivityFactor,
      ),
      'absorptionDelayBase': serializer.toJson<double>(absorptionDelayBase),
      'tuningMealCount': serializer.toJson<int>(tuningMealCount),
      'fastingSetpoint': serializer.toJson<double>(fastingSetpoint),
      'insulinCategory': serializer.toJson<String>(insulinCategory),
      'insulinDiaMinutes': serializer.toJson<double>(insulinDiaMinutes),
      'ekfCovP1': serializer.toJson<double>(ekfCovP1),
      'ekfCovISF': serializer.toJson<double>(ekfCovISF),
      'ekfCovTMax': serializer.toJson<double>(ekfCovTMax),
      'hasAgreedToDisclaimer': serializer.toJson<bool>(hasAgreedToDisclaimer),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    Value<double?> targetWeightKg = const Value.absent(),
    String? diabetesType,
    int? diagnosisYear,
    String? preferredGlucoseUnit,
    bool? usesInsulin,
    bool? usesPills,
    bool? usesCgm,
    double? targetGlucoseMin,
    double? targetGlucoseMax,
    double? metabolicClearanceRate,
    double? insulinSensitivityFactor,
    double? absorptionDelayBase,
    int? tuningMealCount,
    double? fastingSetpoint,
    String? insulinCategory,
    double? insulinDiaMinutes,
    double? ekfCovP1,
    double? ekfCovISF,
    double? ekfCovTMax,
    bool? hasAgreedToDisclaimer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    diabetesType: diabetesType ?? this.diabetesType,
    diagnosisYear: diagnosisYear ?? this.diagnosisYear,
    preferredGlucoseUnit: preferredGlucoseUnit ?? this.preferredGlucoseUnit,
    usesInsulin: usesInsulin ?? this.usesInsulin,
    usesPills: usesPills ?? this.usesPills,
    usesCgm: usesCgm ?? this.usesCgm,
    targetGlucoseMin: targetGlucoseMin ?? this.targetGlucoseMin,
    targetGlucoseMax: targetGlucoseMax ?? this.targetGlucoseMax,
    metabolicClearanceRate:
        metabolicClearanceRate ?? this.metabolicClearanceRate,
    insulinSensitivityFactor:
        insulinSensitivityFactor ?? this.insulinSensitivityFactor,
    absorptionDelayBase: absorptionDelayBase ?? this.absorptionDelayBase,
    tuningMealCount: tuningMealCount ?? this.tuningMealCount,
    fastingSetpoint: fastingSetpoint ?? this.fastingSetpoint,
    insulinCategory: insulinCategory ?? this.insulinCategory,
    insulinDiaMinutes: insulinDiaMinutes ?? this.insulinDiaMinutes,
    ekfCovP1: ekfCovP1 ?? this.ekfCovP1,
    ekfCovISF: ekfCovISF ?? this.ekfCovISF,
    ekfCovTMax: ekfCovTMax ?? this.ekfCovTMax,
    hasAgreedToDisclaimer: hasAgreedToDisclaimer ?? this.hasAgreedToDisclaimer,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      diabetesType: data.diabetesType.present
          ? data.diabetesType.value
          : this.diabetesType,
      diagnosisYear: data.diagnosisYear.present
          ? data.diagnosisYear.value
          : this.diagnosisYear,
      preferredGlucoseUnit: data.preferredGlucoseUnit.present
          ? data.preferredGlucoseUnit.value
          : this.preferredGlucoseUnit,
      usesInsulin: data.usesInsulin.present
          ? data.usesInsulin.value
          : this.usesInsulin,
      usesPills: data.usesPills.present ? data.usesPills.value : this.usesPills,
      usesCgm: data.usesCgm.present ? data.usesCgm.value : this.usesCgm,
      targetGlucoseMin: data.targetGlucoseMin.present
          ? data.targetGlucoseMin.value
          : this.targetGlucoseMin,
      targetGlucoseMax: data.targetGlucoseMax.present
          ? data.targetGlucoseMax.value
          : this.targetGlucoseMax,
      metabolicClearanceRate: data.metabolicClearanceRate.present
          ? data.metabolicClearanceRate.value
          : this.metabolicClearanceRate,
      insulinSensitivityFactor: data.insulinSensitivityFactor.present
          ? data.insulinSensitivityFactor.value
          : this.insulinSensitivityFactor,
      absorptionDelayBase: data.absorptionDelayBase.present
          ? data.absorptionDelayBase.value
          : this.absorptionDelayBase,
      tuningMealCount: data.tuningMealCount.present
          ? data.tuningMealCount.value
          : this.tuningMealCount,
      fastingSetpoint: data.fastingSetpoint.present
          ? data.fastingSetpoint.value
          : this.fastingSetpoint,
      insulinCategory: data.insulinCategory.present
          ? data.insulinCategory.value
          : this.insulinCategory,
      insulinDiaMinutes: data.insulinDiaMinutes.present
          ? data.insulinDiaMinutes.value
          : this.insulinDiaMinutes,
      ekfCovP1: data.ekfCovP1.present ? data.ekfCovP1.value : this.ekfCovP1,
      ekfCovISF: data.ekfCovISF.present ? data.ekfCovISF.value : this.ekfCovISF,
      ekfCovTMax: data.ekfCovTMax.present
          ? data.ekfCovTMax.value
          : this.ekfCovTMax,
      hasAgreedToDisclaimer: data.hasAgreedToDisclaimer.present
          ? data.hasAgreedToDisclaimer.value
          : this.hasAgreedToDisclaimer,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('diabetesType: $diabetesType, ')
          ..write('diagnosisYear: $diagnosisYear, ')
          ..write('preferredGlucoseUnit: $preferredGlucoseUnit, ')
          ..write('usesInsulin: $usesInsulin, ')
          ..write('usesPills: $usesPills, ')
          ..write('usesCgm: $usesCgm, ')
          ..write('targetGlucoseMin: $targetGlucoseMin, ')
          ..write('targetGlucoseMax: $targetGlucoseMax, ')
          ..write('metabolicClearanceRate: $metabolicClearanceRate, ')
          ..write('insulinSensitivityFactor: $insulinSensitivityFactor, ')
          ..write('absorptionDelayBase: $absorptionDelayBase, ')
          ..write('tuningMealCount: $tuningMealCount, ')
          ..write('fastingSetpoint: $fastingSetpoint, ')
          ..write('insulinCategory: $insulinCategory, ')
          ..write('insulinDiaMinutes: $insulinDiaMinutes, ')
          ..write('ekfCovP1: $ekfCovP1, ')
          ..write('ekfCovISF: $ekfCovISF, ')
          ..write('ekfCovTMax: $ekfCovTMax, ')
          ..write('hasAgreedToDisclaimer: $hasAgreedToDisclaimer, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    age,
    gender,
    heightCm,
    weightKg,
    targetWeightKg,
    diabetesType,
    diagnosisYear,
    preferredGlucoseUnit,
    usesInsulin,
    usesPills,
    usesCgm,
    targetGlucoseMin,
    targetGlucoseMax,
    metabolicClearanceRate,
    insulinSensitivityFactor,
    absorptionDelayBase,
    tuningMealCount,
    fastingSetpoint,
    insulinCategory,
    insulinDiaMinutes,
    ekfCovP1,
    ekfCovISF,
    ekfCovTMax,
    hasAgreedToDisclaimer,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.diabetesType == this.diabetesType &&
          other.diagnosisYear == this.diagnosisYear &&
          other.preferredGlucoseUnit == this.preferredGlucoseUnit &&
          other.usesInsulin == this.usesInsulin &&
          other.usesPills == this.usesPills &&
          other.usesCgm == this.usesCgm &&
          other.targetGlucoseMin == this.targetGlucoseMin &&
          other.targetGlucoseMax == this.targetGlucoseMax &&
          other.metabolicClearanceRate == this.metabolicClearanceRate &&
          other.insulinSensitivityFactor == this.insulinSensitivityFactor &&
          other.absorptionDelayBase == this.absorptionDelayBase &&
          other.tuningMealCount == this.tuningMealCount &&
          other.fastingSetpoint == this.fastingSetpoint &&
          other.insulinCategory == this.insulinCategory &&
          other.insulinDiaMinutes == this.insulinDiaMinutes &&
          other.ekfCovP1 == this.ekfCovP1 &&
          other.ekfCovISF == this.ekfCovISF &&
          other.ekfCovTMax == this.ekfCovTMax &&
          other.hasAgreedToDisclaimer == this.hasAgreedToDisclaimer &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> gender;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<double?> targetWeightKg;
  final Value<String> diabetesType;
  final Value<int> diagnosisYear;
  final Value<String> preferredGlucoseUnit;
  final Value<bool> usesInsulin;
  final Value<bool> usesPills;
  final Value<bool> usesCgm;
  final Value<double> targetGlucoseMin;
  final Value<double> targetGlucoseMax;
  final Value<double> metabolicClearanceRate;
  final Value<double> insulinSensitivityFactor;
  final Value<double> absorptionDelayBase;
  final Value<int> tuningMealCount;
  final Value<double> fastingSetpoint;
  final Value<String> insulinCategory;
  final Value<double> insulinDiaMinutes;
  final Value<double> ekfCovP1;
  final Value<double> ekfCovISF;
  final Value<double> ekfCovTMax;
  final Value<bool> hasAgreedToDisclaimer;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.diabetesType = const Value.absent(),
    this.diagnosisYear = const Value.absent(),
    this.preferredGlucoseUnit = const Value.absent(),
    this.usesInsulin = const Value.absent(),
    this.usesPills = const Value.absent(),
    this.usesCgm = const Value.absent(),
    this.targetGlucoseMin = const Value.absent(),
    this.targetGlucoseMax = const Value.absent(),
    this.metabolicClearanceRate = const Value.absent(),
    this.insulinSensitivityFactor = const Value.absent(),
    this.absorptionDelayBase = const Value.absent(),
    this.tuningMealCount = const Value.absent(),
    this.fastingSetpoint = const Value.absent(),
    this.insulinCategory = const Value.absent(),
    this.insulinDiaMinutes = const Value.absent(),
    this.ekfCovP1 = const Value.absent(),
    this.ekfCovISF = const Value.absent(),
    this.ekfCovTMax = const Value.absent(),
    this.hasAgreedToDisclaimer = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    this.targetWeightKg = const Value.absent(),
    required String diabetesType,
    required int diagnosisYear,
    required String preferredGlucoseUnit,
    this.usesInsulin = const Value.absent(),
    this.usesPills = const Value.absent(),
    this.usesCgm = const Value.absent(),
    required double targetGlucoseMin,
    required double targetGlucoseMax,
    this.metabolicClearanceRate = const Value.absent(),
    this.insulinSensitivityFactor = const Value.absent(),
    this.absorptionDelayBase = const Value.absent(),
    this.tuningMealCount = const Value.absent(),
    this.fastingSetpoint = const Value.absent(),
    this.insulinCategory = const Value.absent(),
    this.insulinDiaMinutes = const Value.absent(),
    this.ekfCovP1 = const Value.absent(),
    this.ekfCovISF = const Value.absent(),
    this.ekfCovTMax = const Value.absent(),
    this.hasAgreedToDisclaimer = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       age = Value(age),
       gender = Value(gender),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       diabetesType = Value(diabetesType),
       diagnosisYear = Value(diagnosisYear),
       preferredGlucoseUnit = Value(preferredGlucoseUnit),
       targetGlucoseMin = Value(targetGlucoseMin),
       targetGlucoseMax = Value(targetGlucoseMax),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? targetWeightKg,
    Expression<String>? diabetesType,
    Expression<int>? diagnosisYear,
    Expression<String>? preferredGlucoseUnit,
    Expression<bool>? usesInsulin,
    Expression<bool>? usesPills,
    Expression<bool>? usesCgm,
    Expression<double>? targetGlucoseMin,
    Expression<double>? targetGlucoseMax,
    Expression<double>? metabolicClearanceRate,
    Expression<double>? insulinSensitivityFactor,
    Expression<double>? absorptionDelayBase,
    Expression<int>? tuningMealCount,
    Expression<double>? fastingSetpoint,
    Expression<String>? insulinCategory,
    Expression<double>? insulinDiaMinutes,
    Expression<double>? ekfCovP1,
    Expression<double>? ekfCovISF,
    Expression<double>? ekfCovTMax,
    Expression<bool>? hasAgreedToDisclaimer,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (diabetesType != null) 'diabetes_type': diabetesType,
      if (diagnosisYear != null) 'diagnosis_year': diagnosisYear,
      if (preferredGlucoseUnit != null)
        'preferred_glucose_unit': preferredGlucoseUnit,
      if (usesInsulin != null) 'uses_insulin': usesInsulin,
      if (usesPills != null) 'uses_pills': usesPills,
      if (usesCgm != null) 'uses_cgm': usesCgm,
      if (targetGlucoseMin != null) 'target_glucose_min': targetGlucoseMin,
      if (targetGlucoseMax != null) 'target_glucose_max': targetGlucoseMax,
      if (metabolicClearanceRate != null)
        'metabolic_clearance_rate': metabolicClearanceRate,
      if (insulinSensitivityFactor != null)
        'insulin_sensitivity_factor': insulinSensitivityFactor,
      if (absorptionDelayBase != null)
        'absorption_delay_base': absorptionDelayBase,
      if (tuningMealCount != null) 'tuning_meal_count': tuningMealCount,
      if (fastingSetpoint != null) 'fasting_setpoint': fastingSetpoint,
      if (insulinCategory != null) 'insulin_category': insulinCategory,
      if (insulinDiaMinutes != null) 'insulin_dia_minutes': insulinDiaMinutes,
      if (ekfCovP1 != null) 'ekf_cov_p1': ekfCovP1,
      if (ekfCovISF != null) 'ekf_cov_i_s_f': ekfCovISF,
      if (ekfCovTMax != null) 'ekf_cov_t_max': ekfCovTMax,
      if (hasAgreedToDisclaimer != null)
        'has_agreed_to_disclaimer': hasAgreedToDisclaimer,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? age,
    Value<String>? gender,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<double?>? targetWeightKg,
    Value<String>? diabetesType,
    Value<int>? diagnosisYear,
    Value<String>? preferredGlucoseUnit,
    Value<bool>? usesInsulin,
    Value<bool>? usesPills,
    Value<bool>? usesCgm,
    Value<double>? targetGlucoseMin,
    Value<double>? targetGlucoseMax,
    Value<double>? metabolicClearanceRate,
    Value<double>? insulinSensitivityFactor,
    Value<double>? absorptionDelayBase,
    Value<int>? tuningMealCount,
    Value<double>? fastingSetpoint,
    Value<String>? insulinCategory,
    Value<double>? insulinDiaMinutes,
    Value<double>? ekfCovP1,
    Value<double>? ekfCovISF,
    Value<double>? ekfCovTMax,
    Value<bool>? hasAgreedToDisclaimer,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      diabetesType: diabetesType ?? this.diabetesType,
      diagnosisYear: diagnosisYear ?? this.diagnosisYear,
      preferredGlucoseUnit: preferredGlucoseUnit ?? this.preferredGlucoseUnit,
      usesInsulin: usesInsulin ?? this.usesInsulin,
      usesPills: usesPills ?? this.usesPills,
      usesCgm: usesCgm ?? this.usesCgm,
      targetGlucoseMin: targetGlucoseMin ?? this.targetGlucoseMin,
      targetGlucoseMax: targetGlucoseMax ?? this.targetGlucoseMax,
      metabolicClearanceRate:
          metabolicClearanceRate ?? this.metabolicClearanceRate,
      insulinSensitivityFactor:
          insulinSensitivityFactor ?? this.insulinSensitivityFactor,
      absorptionDelayBase: absorptionDelayBase ?? this.absorptionDelayBase,
      tuningMealCount: tuningMealCount ?? this.tuningMealCount,
      fastingSetpoint: fastingSetpoint ?? this.fastingSetpoint,
      insulinCategory: insulinCategory ?? this.insulinCategory,
      insulinDiaMinutes: insulinDiaMinutes ?? this.insulinDiaMinutes,
      ekfCovP1: ekfCovP1 ?? this.ekfCovP1,
      ekfCovISF: ekfCovISF ?? this.ekfCovISF,
      ekfCovTMax: ekfCovTMax ?? this.ekfCovTMax,
      hasAgreedToDisclaimer:
          hasAgreedToDisclaimer ?? this.hasAgreedToDisclaimer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (diabetesType.present) {
      map['diabetes_type'] = Variable<String>(diabetesType.value);
    }
    if (diagnosisYear.present) {
      map['diagnosis_year'] = Variable<int>(diagnosisYear.value);
    }
    if (preferredGlucoseUnit.present) {
      map['preferred_glucose_unit'] = Variable<String>(
        preferredGlucoseUnit.value,
      );
    }
    if (usesInsulin.present) {
      map['uses_insulin'] = Variable<bool>(usesInsulin.value);
    }
    if (usesPills.present) {
      map['uses_pills'] = Variable<bool>(usesPills.value);
    }
    if (usesCgm.present) {
      map['uses_cgm'] = Variable<bool>(usesCgm.value);
    }
    if (targetGlucoseMin.present) {
      map['target_glucose_min'] = Variable<double>(targetGlucoseMin.value);
    }
    if (targetGlucoseMax.present) {
      map['target_glucose_max'] = Variable<double>(targetGlucoseMax.value);
    }
    if (metabolicClearanceRate.present) {
      map['metabolic_clearance_rate'] = Variable<double>(
        metabolicClearanceRate.value,
      );
    }
    if (insulinSensitivityFactor.present) {
      map['insulin_sensitivity_factor'] = Variable<double>(
        insulinSensitivityFactor.value,
      );
    }
    if (absorptionDelayBase.present) {
      map['absorption_delay_base'] = Variable<double>(
        absorptionDelayBase.value,
      );
    }
    if (tuningMealCount.present) {
      map['tuning_meal_count'] = Variable<int>(tuningMealCount.value);
    }
    if (fastingSetpoint.present) {
      map['fasting_setpoint'] = Variable<double>(fastingSetpoint.value);
    }
    if (insulinCategory.present) {
      map['insulin_category'] = Variable<String>(insulinCategory.value);
    }
    if (insulinDiaMinutes.present) {
      map['insulin_dia_minutes'] = Variable<double>(insulinDiaMinutes.value);
    }
    if (ekfCovP1.present) {
      map['ekf_cov_p1'] = Variable<double>(ekfCovP1.value);
    }
    if (ekfCovISF.present) {
      map['ekf_cov_i_s_f'] = Variable<double>(ekfCovISF.value);
    }
    if (ekfCovTMax.present) {
      map['ekf_cov_t_max'] = Variable<double>(ekfCovTMax.value);
    }
    if (hasAgreedToDisclaimer.present) {
      map['has_agreed_to_disclaimer'] = Variable<bool>(
        hasAgreedToDisclaimer.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('diabetesType: $diabetesType, ')
          ..write('diagnosisYear: $diagnosisYear, ')
          ..write('preferredGlucoseUnit: $preferredGlucoseUnit, ')
          ..write('usesInsulin: $usesInsulin, ')
          ..write('usesPills: $usesPills, ')
          ..write('usesCgm: $usesCgm, ')
          ..write('targetGlucoseMin: $targetGlucoseMin, ')
          ..write('targetGlucoseMax: $targetGlucoseMax, ')
          ..write('metabolicClearanceRate: $metabolicClearanceRate, ')
          ..write('insulinSensitivityFactor: $insulinSensitivityFactor, ')
          ..write('absorptionDelayBase: $absorptionDelayBase, ')
          ..write('tuningMealCount: $tuningMealCount, ')
          ..write('fastingSetpoint: $fastingSetpoint, ')
          ..write('insulinCategory: $insulinCategory, ')
          ..write('insulinDiaMinutes: $insulinDiaMinutes, ')
          ..write('ekfCovP1: $ekfCovP1, ')
          ..write('ekfCovISF: $ekfCovISF, ')
          ..write('ekfCovTMax: $ekfCovTMax, ')
          ..write('hasAgreedToDisclaimer: $hasAgreedToDisclaimer, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectionLogsTable extends ProjectionLogs
    with TableInfo<$ProjectionLogsTable, ProjectionLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealLogIdMeta = const VerificationMeta(
    'mealLogId',
  );
  @override
  late final GeneratedColumn<String> mealLogId = GeneratedColumn<String>(
    'meal_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _baselineGlucoseMeta = const VerificationMeta(
    'baselineGlucose',
  );
  @override
  late final GeneratedColumn<double> baselineGlucose = GeneratedColumn<double>(
    'baseline_glucose',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakGlucoseMeta = const VerificationMeta(
    'peakGlucose',
  );
  @override
  late final GeneratedColumn<double> peakGlucose = GeneratedColumn<double>(
    'peak_glucose',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakTimeMinutesMeta = const VerificationMeta(
    'peakTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> peakTimeMinutes = GeneratedColumn<int>(
    'peak_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _twoHourGlucoseMeta = const VerificationMeta(
    'twoHourGlucose',
  );
  @override
  late final GeneratedColumn<double> twoHourGlucose = GeneratedColumn<double>(
    'two_hour_glucose',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsJsonMeta = const VerificationMeta(
    'pointsJson',
  );
  @override
  late final GeneratedColumn<String> pointsJson = GeneratedColumn<String>(
    'points_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upperBandJsonMeta = const VerificationMeta(
    'upperBandJson',
  );
  @override
  late final GeneratedColumn<String> upperBandJson = GeneratedColumn<String>(
    'upper_band_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lowerBandJsonMeta = const VerificationMeta(
    'lowerBandJson',
  );
  @override
  late final GeneratedColumn<String> lowerBandJson = GeneratedColumn<String>(
    'lower_band_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _confidenceWidthMeta = const VerificationMeta(
    'confidenceWidth',
  );
  @override
  late final GeneratedColumn<double> confidenceWidth = GeneratedColumn<double>(
    'confidence_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(25.0),
  );
  static const VerificationMeta _totalAvailableGlucoseMeta =
      const VerificationMeta('totalAvailableGlucose');
  @override
  late final GeneratedColumn<double> totalAvailableGlucose =
      GeneratedColumn<double>(
        'total_available_glucose',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealLogId,
    timestamp,
    baselineGlucose,
    peakGlucose,
    peakTimeMinutes,
    twoHourGlucose,
    riskLevel,
    summary,
    pointsJson,
    upperBandJson,
    lowerBandJson,
    confidenceWidth,
    totalAvailableGlucose,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projection_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectionLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_log_id')) {
      context.handle(
        _mealLogIdMeta,
        mealLogId.isAcceptableOrUnknown(data['meal_log_id']!, _mealLogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealLogIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('baseline_glucose')) {
      context.handle(
        _baselineGlucoseMeta,
        baselineGlucose.isAcceptableOrUnknown(
          data['baseline_glucose']!,
          _baselineGlucoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineGlucoseMeta);
    }
    if (data.containsKey('peak_glucose')) {
      context.handle(
        _peakGlucoseMeta,
        peakGlucose.isAcceptableOrUnknown(
          data['peak_glucose']!,
          _peakGlucoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakGlucoseMeta);
    }
    if (data.containsKey('peak_time_minutes')) {
      context.handle(
        _peakTimeMinutesMeta,
        peakTimeMinutes.isAcceptableOrUnknown(
          data['peak_time_minutes']!,
          _peakTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakTimeMinutesMeta);
    }
    if (data.containsKey('two_hour_glucose')) {
      context.handle(
        _twoHourGlucoseMeta,
        twoHourGlucose.isAcceptableOrUnknown(
          data['two_hour_glucose']!,
          _twoHourGlucoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_twoHourGlucoseMeta);
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_riskLevelMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('points_json')) {
      context.handle(
        _pointsJsonMeta,
        pointsJson.isAcceptableOrUnknown(data['points_json']!, _pointsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsJsonMeta);
    }
    if (data.containsKey('upper_band_json')) {
      context.handle(
        _upperBandJsonMeta,
        upperBandJson.isAcceptableOrUnknown(
          data['upper_band_json']!,
          _upperBandJsonMeta,
        ),
      );
    }
    if (data.containsKey('lower_band_json')) {
      context.handle(
        _lowerBandJsonMeta,
        lowerBandJson.isAcceptableOrUnknown(
          data['lower_band_json']!,
          _lowerBandJsonMeta,
        ),
      );
    }
    if (data.containsKey('confidence_width')) {
      context.handle(
        _confidenceWidthMeta,
        confidenceWidth.isAcceptableOrUnknown(
          data['confidence_width']!,
          _confidenceWidthMeta,
        ),
      );
    }
    if (data.containsKey('total_available_glucose')) {
      context.handle(
        _totalAvailableGlucoseMeta,
        totalAvailableGlucose.isAcceptableOrUnknown(
          data['total_available_glucose']!,
          _totalAvailableGlucoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAvailableGlucoseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectionLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectionLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mealLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_log_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      baselineGlucose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_glucose'],
      )!,
      peakGlucose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_glucose'],
      )!,
      peakTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peak_time_minutes'],
      )!,
      twoHourGlucose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}two_hour_glucose'],
      )!,
      riskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_level'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      pointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}points_json'],
      )!,
      upperBandJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upper_band_json'],
      )!,
      lowerBandJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lower_band_json'],
      )!,
      confidenceWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_width'],
      )!,
      totalAvailableGlucose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_available_glucose'],
      )!,
    );
  }

  @override
  $ProjectionLogsTable createAlias(String alias) {
    return $ProjectionLogsTable(attachedDatabase, alias);
  }
}

class ProjectionLogRow extends DataClass
    implements Insertable<ProjectionLogRow> {
  final String id;
  final String mealLogId;
  final DateTime timestamp;
  final double baselineGlucose;
  final double peakGlucose;
  final int peakTimeMinutes;
  final double twoHourGlucose;
  final String riskLevel;
  final String summary;
  final String pointsJson;
  final String upperBandJson;
  final String lowerBandJson;
  final double confidenceWidth;
  final double totalAvailableGlucose;
  const ProjectionLogRow({
    required this.id,
    required this.mealLogId,
    required this.timestamp,
    required this.baselineGlucose,
    required this.peakGlucose,
    required this.peakTimeMinutes,
    required this.twoHourGlucose,
    required this.riskLevel,
    required this.summary,
    required this.pointsJson,
    required this.upperBandJson,
    required this.lowerBandJson,
    required this.confidenceWidth,
    required this.totalAvailableGlucose,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meal_log_id'] = Variable<String>(mealLogId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['baseline_glucose'] = Variable<double>(baselineGlucose);
    map['peak_glucose'] = Variable<double>(peakGlucose);
    map['peak_time_minutes'] = Variable<int>(peakTimeMinutes);
    map['two_hour_glucose'] = Variable<double>(twoHourGlucose);
    map['risk_level'] = Variable<String>(riskLevel);
    map['summary'] = Variable<String>(summary);
    map['points_json'] = Variable<String>(pointsJson);
    map['upper_band_json'] = Variable<String>(upperBandJson);
    map['lower_band_json'] = Variable<String>(lowerBandJson);
    map['confidence_width'] = Variable<double>(confidenceWidth);
    map['total_available_glucose'] = Variable<double>(totalAvailableGlucose);
    return map;
  }

  ProjectionLogsCompanion toCompanion(bool nullToAbsent) {
    return ProjectionLogsCompanion(
      id: Value(id),
      mealLogId: Value(mealLogId),
      timestamp: Value(timestamp),
      baselineGlucose: Value(baselineGlucose),
      peakGlucose: Value(peakGlucose),
      peakTimeMinutes: Value(peakTimeMinutes),
      twoHourGlucose: Value(twoHourGlucose),
      riskLevel: Value(riskLevel),
      summary: Value(summary),
      pointsJson: Value(pointsJson),
      upperBandJson: Value(upperBandJson),
      lowerBandJson: Value(lowerBandJson),
      confidenceWidth: Value(confidenceWidth),
      totalAvailableGlucose: Value(totalAvailableGlucose),
    );
  }

  factory ProjectionLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectionLogRow(
      id: serializer.fromJson<String>(json['id']),
      mealLogId: serializer.fromJson<String>(json['mealLogId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      baselineGlucose: serializer.fromJson<double>(json['baselineGlucose']),
      peakGlucose: serializer.fromJson<double>(json['peakGlucose']),
      peakTimeMinutes: serializer.fromJson<int>(json['peakTimeMinutes']),
      twoHourGlucose: serializer.fromJson<double>(json['twoHourGlucose']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      summary: serializer.fromJson<String>(json['summary']),
      pointsJson: serializer.fromJson<String>(json['pointsJson']),
      upperBandJson: serializer.fromJson<String>(json['upperBandJson']),
      lowerBandJson: serializer.fromJson<String>(json['lowerBandJson']),
      confidenceWidth: serializer.fromJson<double>(json['confidenceWidth']),
      totalAvailableGlucose: serializer.fromJson<double>(
        json['totalAvailableGlucose'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mealLogId': serializer.toJson<String>(mealLogId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'baselineGlucose': serializer.toJson<double>(baselineGlucose),
      'peakGlucose': serializer.toJson<double>(peakGlucose),
      'peakTimeMinutes': serializer.toJson<int>(peakTimeMinutes),
      'twoHourGlucose': serializer.toJson<double>(twoHourGlucose),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'summary': serializer.toJson<String>(summary),
      'pointsJson': serializer.toJson<String>(pointsJson),
      'upperBandJson': serializer.toJson<String>(upperBandJson),
      'lowerBandJson': serializer.toJson<String>(lowerBandJson),
      'confidenceWidth': serializer.toJson<double>(confidenceWidth),
      'totalAvailableGlucose': serializer.toJson<double>(totalAvailableGlucose),
    };
  }

  ProjectionLogRow copyWith({
    String? id,
    String? mealLogId,
    DateTime? timestamp,
    double? baselineGlucose,
    double? peakGlucose,
    int? peakTimeMinutes,
    double? twoHourGlucose,
    String? riskLevel,
    String? summary,
    String? pointsJson,
    String? upperBandJson,
    String? lowerBandJson,
    double? confidenceWidth,
    double? totalAvailableGlucose,
  }) => ProjectionLogRow(
    id: id ?? this.id,
    mealLogId: mealLogId ?? this.mealLogId,
    timestamp: timestamp ?? this.timestamp,
    baselineGlucose: baselineGlucose ?? this.baselineGlucose,
    peakGlucose: peakGlucose ?? this.peakGlucose,
    peakTimeMinutes: peakTimeMinutes ?? this.peakTimeMinutes,
    twoHourGlucose: twoHourGlucose ?? this.twoHourGlucose,
    riskLevel: riskLevel ?? this.riskLevel,
    summary: summary ?? this.summary,
    pointsJson: pointsJson ?? this.pointsJson,
    upperBandJson: upperBandJson ?? this.upperBandJson,
    lowerBandJson: lowerBandJson ?? this.lowerBandJson,
    confidenceWidth: confidenceWidth ?? this.confidenceWidth,
    totalAvailableGlucose: totalAvailableGlucose ?? this.totalAvailableGlucose,
  );
  ProjectionLogRow copyWithCompanion(ProjectionLogsCompanion data) {
    return ProjectionLogRow(
      id: data.id.present ? data.id.value : this.id,
      mealLogId: data.mealLogId.present ? data.mealLogId.value : this.mealLogId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      baselineGlucose: data.baselineGlucose.present
          ? data.baselineGlucose.value
          : this.baselineGlucose,
      peakGlucose: data.peakGlucose.present
          ? data.peakGlucose.value
          : this.peakGlucose,
      peakTimeMinutes: data.peakTimeMinutes.present
          ? data.peakTimeMinutes.value
          : this.peakTimeMinutes,
      twoHourGlucose: data.twoHourGlucose.present
          ? data.twoHourGlucose.value
          : this.twoHourGlucose,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      summary: data.summary.present ? data.summary.value : this.summary,
      pointsJson: data.pointsJson.present
          ? data.pointsJson.value
          : this.pointsJson,
      upperBandJson: data.upperBandJson.present
          ? data.upperBandJson.value
          : this.upperBandJson,
      lowerBandJson: data.lowerBandJson.present
          ? data.lowerBandJson.value
          : this.lowerBandJson,
      confidenceWidth: data.confidenceWidth.present
          ? data.confidenceWidth.value
          : this.confidenceWidth,
      totalAvailableGlucose: data.totalAvailableGlucose.present
          ? data.totalAvailableGlucose.value
          : this.totalAvailableGlucose,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionLogRow(')
          ..write('id: $id, ')
          ..write('mealLogId: $mealLogId, ')
          ..write('timestamp: $timestamp, ')
          ..write('baselineGlucose: $baselineGlucose, ')
          ..write('peakGlucose: $peakGlucose, ')
          ..write('peakTimeMinutes: $peakTimeMinutes, ')
          ..write('twoHourGlucose: $twoHourGlucose, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('summary: $summary, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('upperBandJson: $upperBandJson, ')
          ..write('lowerBandJson: $lowerBandJson, ')
          ..write('confidenceWidth: $confidenceWidth, ')
          ..write('totalAvailableGlucose: $totalAvailableGlucose')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealLogId,
    timestamp,
    baselineGlucose,
    peakGlucose,
    peakTimeMinutes,
    twoHourGlucose,
    riskLevel,
    summary,
    pointsJson,
    upperBandJson,
    lowerBandJson,
    confidenceWidth,
    totalAvailableGlucose,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectionLogRow &&
          other.id == this.id &&
          other.mealLogId == this.mealLogId &&
          other.timestamp == this.timestamp &&
          other.baselineGlucose == this.baselineGlucose &&
          other.peakGlucose == this.peakGlucose &&
          other.peakTimeMinutes == this.peakTimeMinutes &&
          other.twoHourGlucose == this.twoHourGlucose &&
          other.riskLevel == this.riskLevel &&
          other.summary == this.summary &&
          other.pointsJson == this.pointsJson &&
          other.upperBandJson == this.upperBandJson &&
          other.lowerBandJson == this.lowerBandJson &&
          other.confidenceWidth == this.confidenceWidth &&
          other.totalAvailableGlucose == this.totalAvailableGlucose);
}

class ProjectionLogsCompanion extends UpdateCompanion<ProjectionLogRow> {
  final Value<String> id;
  final Value<String> mealLogId;
  final Value<DateTime> timestamp;
  final Value<double> baselineGlucose;
  final Value<double> peakGlucose;
  final Value<int> peakTimeMinutes;
  final Value<double> twoHourGlucose;
  final Value<String> riskLevel;
  final Value<String> summary;
  final Value<String> pointsJson;
  final Value<String> upperBandJson;
  final Value<String> lowerBandJson;
  final Value<double> confidenceWidth;
  final Value<double> totalAvailableGlucose;
  final Value<int> rowid;
  const ProjectionLogsCompanion({
    this.id = const Value.absent(),
    this.mealLogId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.baselineGlucose = const Value.absent(),
    this.peakGlucose = const Value.absent(),
    this.peakTimeMinutes = const Value.absent(),
    this.twoHourGlucose = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.summary = const Value.absent(),
    this.pointsJson = const Value.absent(),
    this.upperBandJson = const Value.absent(),
    this.lowerBandJson = const Value.absent(),
    this.confidenceWidth = const Value.absent(),
    this.totalAvailableGlucose = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectionLogsCompanion.insert({
    required String id,
    required String mealLogId,
    required DateTime timestamp,
    required double baselineGlucose,
    required double peakGlucose,
    required int peakTimeMinutes,
    required double twoHourGlucose,
    required String riskLevel,
    required String summary,
    required String pointsJson,
    this.upperBandJson = const Value.absent(),
    this.lowerBandJson = const Value.absent(),
    this.confidenceWidth = const Value.absent(),
    required double totalAvailableGlucose,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mealLogId = Value(mealLogId),
       timestamp = Value(timestamp),
       baselineGlucose = Value(baselineGlucose),
       peakGlucose = Value(peakGlucose),
       peakTimeMinutes = Value(peakTimeMinutes),
       twoHourGlucose = Value(twoHourGlucose),
       riskLevel = Value(riskLevel),
       summary = Value(summary),
       pointsJson = Value(pointsJson),
       totalAvailableGlucose = Value(totalAvailableGlucose);
  static Insertable<ProjectionLogRow> custom({
    Expression<String>? id,
    Expression<String>? mealLogId,
    Expression<DateTime>? timestamp,
    Expression<double>? baselineGlucose,
    Expression<double>? peakGlucose,
    Expression<int>? peakTimeMinutes,
    Expression<double>? twoHourGlucose,
    Expression<String>? riskLevel,
    Expression<String>? summary,
    Expression<String>? pointsJson,
    Expression<String>? upperBandJson,
    Expression<String>? lowerBandJson,
    Expression<double>? confidenceWidth,
    Expression<double>? totalAvailableGlucose,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealLogId != null) 'meal_log_id': mealLogId,
      if (timestamp != null) 'timestamp': timestamp,
      if (baselineGlucose != null) 'baseline_glucose': baselineGlucose,
      if (peakGlucose != null) 'peak_glucose': peakGlucose,
      if (peakTimeMinutes != null) 'peak_time_minutes': peakTimeMinutes,
      if (twoHourGlucose != null) 'two_hour_glucose': twoHourGlucose,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (summary != null) 'summary': summary,
      if (pointsJson != null) 'points_json': pointsJson,
      if (upperBandJson != null) 'upper_band_json': upperBandJson,
      if (lowerBandJson != null) 'lower_band_json': lowerBandJson,
      if (confidenceWidth != null) 'confidence_width': confidenceWidth,
      if (totalAvailableGlucose != null)
        'total_available_glucose': totalAvailableGlucose,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectionLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? mealLogId,
    Value<DateTime>? timestamp,
    Value<double>? baselineGlucose,
    Value<double>? peakGlucose,
    Value<int>? peakTimeMinutes,
    Value<double>? twoHourGlucose,
    Value<String>? riskLevel,
    Value<String>? summary,
    Value<String>? pointsJson,
    Value<String>? upperBandJson,
    Value<String>? lowerBandJson,
    Value<double>? confidenceWidth,
    Value<double>? totalAvailableGlucose,
    Value<int>? rowid,
  }) {
    return ProjectionLogsCompanion(
      id: id ?? this.id,
      mealLogId: mealLogId ?? this.mealLogId,
      timestamp: timestamp ?? this.timestamp,
      baselineGlucose: baselineGlucose ?? this.baselineGlucose,
      peakGlucose: peakGlucose ?? this.peakGlucose,
      peakTimeMinutes: peakTimeMinutes ?? this.peakTimeMinutes,
      twoHourGlucose: twoHourGlucose ?? this.twoHourGlucose,
      riskLevel: riskLevel ?? this.riskLevel,
      summary: summary ?? this.summary,
      pointsJson: pointsJson ?? this.pointsJson,
      upperBandJson: upperBandJson ?? this.upperBandJson,
      lowerBandJson: lowerBandJson ?? this.lowerBandJson,
      confidenceWidth: confidenceWidth ?? this.confidenceWidth,
      totalAvailableGlucose:
          totalAvailableGlucose ?? this.totalAvailableGlucose,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealLogId.present) {
      map['meal_log_id'] = Variable<String>(mealLogId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (baselineGlucose.present) {
      map['baseline_glucose'] = Variable<double>(baselineGlucose.value);
    }
    if (peakGlucose.present) {
      map['peak_glucose'] = Variable<double>(peakGlucose.value);
    }
    if (peakTimeMinutes.present) {
      map['peak_time_minutes'] = Variable<int>(peakTimeMinutes.value);
    }
    if (twoHourGlucose.present) {
      map['two_hour_glucose'] = Variable<double>(twoHourGlucose.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (pointsJson.present) {
      map['points_json'] = Variable<String>(pointsJson.value);
    }
    if (upperBandJson.present) {
      map['upper_band_json'] = Variable<String>(upperBandJson.value);
    }
    if (lowerBandJson.present) {
      map['lower_band_json'] = Variable<String>(lowerBandJson.value);
    }
    if (confidenceWidth.present) {
      map['confidence_width'] = Variable<double>(confidenceWidth.value);
    }
    if (totalAvailableGlucose.present) {
      map['total_available_glucose'] = Variable<double>(
        totalAvailableGlucose.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionLogsCompanion(')
          ..write('id: $id, ')
          ..write('mealLogId: $mealLogId, ')
          ..write('timestamp: $timestamp, ')
          ..write('baselineGlucose: $baselineGlucose, ')
          ..write('peakGlucose: $peakGlucose, ')
          ..write('peakTimeMinutes: $peakTimeMinutes, ')
          ..write('twoHourGlucose: $twoHourGlucose, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('summary: $summary, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('upperBandJson: $upperBandJson, ')
          ..write('lowerBandJson: $lowerBandJson, ')
          ..write('confidenceWidth: $confidenceWidth, ')
          ..write('totalAvailableGlucose: $totalAvailableGlucose, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalFoodsTable localFoods = $LocalFoodsTable(this);
  late final $CustomFoodsTable customFoods = $CustomFoodsTable(this);
  late final $MealLogsTable mealLogs = $MealLogsTable(this);
  late final $N5kIngredientsTable n5kIngredients = $N5kIngredientsTable(this);
  late final $GlucoseLogsTable glucoseLogs = $GlucoseLogsTable(this);
  late final $MealMacroLogsTable mealMacroLogs = $MealMacroLogsTable(this);
  late final $MedicationLogsTable medicationLogs = $MedicationLogsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $ProjectionLogsTable projectionLogs = $ProjectionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localFoods,
    customFoods,
    mealLogs,
    n5kIngredients,
    glucoseLogs,
    mealMacroLogs,
    medicationLogs,
    userProfiles,
    projectionLogs,
  ];
}

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
      Value<double> totalCalories,
      Value<double> totalProtein,
      Value<double> totalFat,
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
      Value<double> totalCalories,
      Value<double> totalProtein,
      Value<double> totalFat,
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

  ColumnFilters<double> get totalCalories => $composableBuilder(
    column: $table.totalCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalProtein => $composableBuilder(
    column: $table.totalProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalFat => $composableBuilder(
    column: $table.totalFat,
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

  ColumnOrderings<double> get totalCalories => $composableBuilder(
    column: $table.totalCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalProtein => $composableBuilder(
    column: $table.totalProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalFat => $composableBuilder(
    column: $table.totalFat,
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

  GeneratedColumn<double> get totalCalories => $composableBuilder(
    column: $table.totalCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalProtein => $composableBuilder(
    column: $table.totalProtein,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalFat =>
      $composableBuilder(column: $table.totalFat, builder: (column) => column);

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
                Value<double> totalCalories = const Value.absent(),
                Value<double> totalProtein = const Value.absent(),
                Value<double> totalFat = const Value.absent(),
                Value<int> completionPercentage = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isOfflineEstimate = const Value.absent(),
              }) => MealLogsCompanion(
                id: id,
                timestamp: timestamp,
                imagePath: imagePath,
                transcription: transcription,
                estimatedCarbs: estimatedCarbs,
                totalCalories: totalCalories,
                totalProtein: totalProtein,
                totalFat: totalFat,
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
                Value<double> totalCalories = const Value.absent(),
                Value<double> totalProtein = const Value.absent(),
                Value<double> totalFat = const Value.absent(),
                Value<int> completionPercentage = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isOfflineEstimate = const Value.absent(),
              }) => MealLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                imagePath: imagePath,
                transcription: transcription,
                estimatedCarbs: estimatedCarbs,
                totalCalories: totalCalories,
                totalProtein: totalProtein,
                totalFat: totalFat,
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
typedef $$N5kIngredientsTableCreateCompanionBuilder =
    N5kIngredientsCompanion Function({
      Value<int> id,
      required String name,
      required double calPerG,
      required double fatPerG,
      required double carbPerG,
      required double proteinPerG,
    });
typedef $$N5kIngredientsTableUpdateCompanionBuilder =
    N5kIngredientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> calPerG,
      Value<double> fatPerG,
      Value<double> carbPerG,
      Value<double> proteinPerG,
    });

class $$N5kIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $N5kIngredientsTable> {
  $$N5kIngredientsTableFilterComposer({
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

  ColumnFilters<double> get calPerG => $composableBuilder(
    column: $table.calPerG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPerG => $composableBuilder(
    column: $table.fatPerG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbPerG => $composableBuilder(
    column: $table.carbPerG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPerG => $composableBuilder(
    column: $table.proteinPerG,
    builder: (column) => ColumnFilters(column),
  );
}

class $$N5kIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $N5kIngredientsTable> {
  $$N5kIngredientsTableOrderingComposer({
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

  ColumnOrderings<double> get calPerG => $composableBuilder(
    column: $table.calPerG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPerG => $composableBuilder(
    column: $table.fatPerG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbPerG => $composableBuilder(
    column: $table.carbPerG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPerG => $composableBuilder(
    column: $table.proteinPerG,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$N5kIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $N5kIngredientsTable> {
  $$N5kIngredientsTableAnnotationComposer({
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

  GeneratedColumn<double> get calPerG =>
      $composableBuilder(column: $table.calPerG, builder: (column) => column);

  GeneratedColumn<double> get fatPerG =>
      $composableBuilder(column: $table.fatPerG, builder: (column) => column);

  GeneratedColumn<double> get carbPerG =>
      $composableBuilder(column: $table.carbPerG, builder: (column) => column);

  GeneratedColumn<double> get proteinPerG => $composableBuilder(
    column: $table.proteinPerG,
    builder: (column) => column,
  );
}

class $$N5kIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $N5kIngredientsTable,
          N5kIngredient,
          $$N5kIngredientsTableFilterComposer,
          $$N5kIngredientsTableOrderingComposer,
          $$N5kIngredientsTableAnnotationComposer,
          $$N5kIngredientsTableCreateCompanionBuilder,
          $$N5kIngredientsTableUpdateCompanionBuilder,
          (
            N5kIngredient,
            BaseReferences<_$AppDatabase, $N5kIngredientsTable, N5kIngredient>,
          ),
          N5kIngredient,
          PrefetchHooks Function()
        > {
  $$N5kIngredientsTableTableManager(
    _$AppDatabase db,
    $N5kIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$N5kIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$N5kIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$N5kIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> calPerG = const Value.absent(),
                Value<double> fatPerG = const Value.absent(),
                Value<double> carbPerG = const Value.absent(),
                Value<double> proteinPerG = const Value.absent(),
              }) => N5kIngredientsCompanion(
                id: id,
                name: name,
                calPerG: calPerG,
                fatPerG: fatPerG,
                carbPerG: carbPerG,
                proteinPerG: proteinPerG,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double calPerG,
                required double fatPerG,
                required double carbPerG,
                required double proteinPerG,
              }) => N5kIngredientsCompanion.insert(
                id: id,
                name: name,
                calPerG: calPerG,
                fatPerG: fatPerG,
                carbPerG: carbPerG,
                proteinPerG: proteinPerG,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$N5kIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $N5kIngredientsTable,
      N5kIngredient,
      $$N5kIngredientsTableFilterComposer,
      $$N5kIngredientsTableOrderingComposer,
      $$N5kIngredientsTableAnnotationComposer,
      $$N5kIngredientsTableCreateCompanionBuilder,
      $$N5kIngredientsTableUpdateCompanionBuilder,
      (
        N5kIngredient,
        BaseReferences<_$AppDatabase, $N5kIngredientsTable, N5kIngredient>,
      ),
      N5kIngredient,
      PrefetchHooks Function()
    >;
typedef $$GlucoseLogsTableCreateCompanionBuilder =
    GlucoseLogsCompanion Function({
      required String id,
      required double value,
      required String unit,
      required String context,
      required DateTime timestamp,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$GlucoseLogsTableUpdateCompanionBuilder =
    GlucoseLogsCompanion Function({
      Value<String> id,
      Value<double> value,
      Value<String> unit,
      Value<String> context,
      Value<DateTime> timestamp,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$GlucoseLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GlucoseLogsTable> {
  $$GlucoseLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlucoseLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GlucoseLogsTable> {
  $$GlucoseLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlucoseLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlucoseLogsTable> {
  $$GlucoseLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$GlucoseLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GlucoseLogsTable,
          GlucoseLogRow,
          $$GlucoseLogsTableFilterComposer,
          $$GlucoseLogsTableOrderingComposer,
          $$GlucoseLogsTableAnnotationComposer,
          $$GlucoseLogsTableCreateCompanionBuilder,
          $$GlucoseLogsTableUpdateCompanionBuilder,
          (
            GlucoseLogRow,
            BaseReferences<_$AppDatabase, $GlucoseLogsTable, GlucoseLogRow>,
          ),
          GlucoseLogRow,
          PrefetchHooks Function()
        > {
  $$GlucoseLogsTableTableManager(_$AppDatabase db, $GlucoseLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlucoseLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlucoseLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlucoseLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlucoseLogsCompanion(
                id: id,
                value: value,
                unit: unit,
                context: context,
                timestamp: timestamp,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double value,
                required String unit,
                required String context,
                required DateTime timestamp,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlucoseLogsCompanion.insert(
                id: id,
                value: value,
                unit: unit,
                context: context,
                timestamp: timestamp,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlucoseLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GlucoseLogsTable,
      GlucoseLogRow,
      $$GlucoseLogsTableFilterComposer,
      $$GlucoseLogsTableOrderingComposer,
      $$GlucoseLogsTableAnnotationComposer,
      $$GlucoseLogsTableCreateCompanionBuilder,
      $$GlucoseLogsTableUpdateCompanionBuilder,
      (
        GlucoseLogRow,
        BaseReferences<_$AppDatabase, $GlucoseLogsTable, GlucoseLogRow>,
      ),
      GlucoseLogRow,
      PrefetchHooks Function()
    >;
typedef $$MealMacroLogsTableCreateCompanionBuilder =
    MealMacroLogsCompanion Function({
      required String id,
      required DateTime timestamp,
      Value<String?> name,
      required double carbohydrates,
      Value<double> dietaryFiber,
      required double proteins,
      required double fats,
      Value<double> calories,
      Value<bool> containsAlcohol,
      Value<bool> containsCaffeine,
      required String mealType,
      Value<String> foodFormFactor,
      Value<bool> postExercise,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MealMacroLogsTableUpdateCompanionBuilder =
    MealMacroLogsCompanion Function({
      Value<String> id,
      Value<DateTime> timestamp,
      Value<String?> name,
      Value<double> carbohydrates,
      Value<double> dietaryFiber,
      Value<double> proteins,
      Value<double> fats,
      Value<double> calories,
      Value<bool> containsAlcohol,
      Value<bool> containsCaffeine,
      Value<String> mealType,
      Value<String> foodFormFactor,
      Value<bool> postExercise,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$MealMacroLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MealMacroLogsTable> {
  $$MealMacroLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dietaryFiber => $composableBuilder(
    column: $table.dietaryFiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteins => $composableBuilder(
    column: $table.proteins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fats => $composableBuilder(
    column: $table.fats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get containsAlcohol => $composableBuilder(
    column: $table.containsAlcohol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get containsCaffeine => $composableBuilder(
    column: $table.containsCaffeine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodFormFactor => $composableBuilder(
    column: $table.foodFormFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get postExercise => $composableBuilder(
    column: $table.postExercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealMacroLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealMacroLogsTable> {
  $$MealMacroLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dietaryFiber => $composableBuilder(
    column: $table.dietaryFiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteins => $composableBuilder(
    column: $table.proteins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fats => $composableBuilder(
    column: $table.fats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get containsAlcohol => $composableBuilder(
    column: $table.containsAlcohol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get containsCaffeine => $composableBuilder(
    column: $table.containsCaffeine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodFormFactor => $composableBuilder(
    column: $table.foodFormFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get postExercise => $composableBuilder(
    column: $table.postExercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealMacroLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealMacroLogsTable> {
  $$MealMacroLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dietaryFiber => $composableBuilder(
    column: $table.dietaryFiber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteins =>
      $composableBuilder(column: $table.proteins, builder: (column) => column);

  GeneratedColumn<double> get fats =>
      $composableBuilder(column: $table.fats, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<bool> get containsAlcohol => $composableBuilder(
    column: $table.containsAlcohol,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get containsCaffeine => $composableBuilder(
    column: $table.containsCaffeine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get foodFormFactor => $composableBuilder(
    column: $table.foodFormFactor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get postExercise => $composableBuilder(
    column: $table.postExercise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$MealMacroLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealMacroLogsTable,
          MealMacroLog,
          $$MealMacroLogsTableFilterComposer,
          $$MealMacroLogsTableOrderingComposer,
          $$MealMacroLogsTableAnnotationComposer,
          $$MealMacroLogsTableCreateCompanionBuilder,
          $$MealMacroLogsTableUpdateCompanionBuilder,
          (
            MealMacroLog,
            BaseReferences<_$AppDatabase, $MealMacroLogsTable, MealMacroLog>,
          ),
          MealMacroLog,
          PrefetchHooks Function()
        > {
  $$MealMacroLogsTableTableManager(_$AppDatabase db, $MealMacroLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealMacroLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealMacroLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealMacroLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> carbohydrates = const Value.absent(),
                Value<double> dietaryFiber = const Value.absent(),
                Value<double> proteins = const Value.absent(),
                Value<double> fats = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<bool> containsAlcohol = const Value.absent(),
                Value<bool> containsCaffeine = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<String> foodFormFactor = const Value.absent(),
                Value<bool> postExercise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealMacroLogsCompanion(
                id: id,
                timestamp: timestamp,
                name: name,
                carbohydrates: carbohydrates,
                dietaryFiber: dietaryFiber,
                proteins: proteins,
                fats: fats,
                calories: calories,
                containsAlcohol: containsAlcohol,
                containsCaffeine: containsCaffeine,
                mealType: mealType,
                foodFormFactor: foodFormFactor,
                postExercise: postExercise,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime timestamp,
                Value<String?> name = const Value.absent(),
                required double carbohydrates,
                Value<double> dietaryFiber = const Value.absent(),
                required double proteins,
                required double fats,
                Value<double> calories = const Value.absent(),
                Value<bool> containsAlcohol = const Value.absent(),
                Value<bool> containsCaffeine = const Value.absent(),
                required String mealType,
                Value<String> foodFormFactor = const Value.absent(),
                Value<bool> postExercise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealMacroLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                name: name,
                carbohydrates: carbohydrates,
                dietaryFiber: dietaryFiber,
                proteins: proteins,
                fats: fats,
                calories: calories,
                containsAlcohol: containsAlcohol,
                containsCaffeine: containsCaffeine,
                mealType: mealType,
                foodFormFactor: foodFormFactor,
                postExercise: postExercise,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealMacroLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealMacroLogsTable,
      MealMacroLog,
      $$MealMacroLogsTableFilterComposer,
      $$MealMacroLogsTableOrderingComposer,
      $$MealMacroLogsTableAnnotationComposer,
      $$MealMacroLogsTableCreateCompanionBuilder,
      $$MealMacroLogsTableUpdateCompanionBuilder,
      (
        MealMacroLog,
        BaseReferences<_$AppDatabase, $MealMacroLogsTable, MealMacroLog>,
      ),
      MealMacroLog,
      PrefetchHooks Function()
    >;
typedef $$MedicationLogsTableCreateCompanionBuilder =
    MedicationLogsCompanion Function({
      required String id,
      required DateTime timestamp,
      required String medicationType,
      Value<String> insulinType,
      Value<String?> name,
      required double units,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MedicationLogsTableUpdateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<String> id,
      Value<DateTime> timestamp,
      Value<String> medicationType,
      Value<String> insulinType,
      Value<String?> name,
      Value<double> units,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$MedicationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationType => $composableBuilder(
    column: $table.medicationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insulinType => $composableBuilder(
    column: $table.insulinType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationType => $composableBuilder(
    column: $table.medicationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insulinType => $composableBuilder(
    column: $table.insulinType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get medicationType => $composableBuilder(
    column: $table.medicationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insulinType => $composableBuilder(
    column: $table.insulinType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$MedicationLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationLogsTable,
          MedicationLogRow,
          $$MedicationLogsTableFilterComposer,
          $$MedicationLogsTableOrderingComposer,
          $$MedicationLogsTableAnnotationComposer,
          $$MedicationLogsTableCreateCompanionBuilder,
          $$MedicationLogsTableUpdateCompanionBuilder,
          (
            MedicationLogRow,
            BaseReferences<
              _$AppDatabase,
              $MedicationLogsTable,
              MedicationLogRow
            >,
          ),
          MedicationLogRow,
          PrefetchHooks Function()
        > {
  $$MedicationLogsTableTableManager(
    _$AppDatabase db,
    $MedicationLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> medicationType = const Value.absent(),
                Value<String> insulinType = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> units = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationLogsCompanion(
                id: id,
                timestamp: timestamp,
                medicationType: medicationType,
                insulinType: insulinType,
                name: name,
                units: units,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime timestamp,
                required String medicationType,
                Value<String> insulinType = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required double units,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                medicationType: medicationType,
                insulinType: insulinType,
                name: name,
                units: units,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationLogsTable,
      MedicationLogRow,
      $$MedicationLogsTableFilterComposer,
      $$MedicationLogsTableOrderingComposer,
      $$MedicationLogsTableAnnotationComposer,
      $$MedicationLogsTableCreateCompanionBuilder,
      $$MedicationLogsTableUpdateCompanionBuilder,
      (
        MedicationLogRow,
        BaseReferences<_$AppDatabase, $MedicationLogsTable, MedicationLogRow>,
      ),
      MedicationLogRow,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      Value<String> name,
      required int age,
      required String gender,
      required double heightCm,
      required double weightKg,
      Value<double?> targetWeightKg,
      required String diabetesType,
      required int diagnosisYear,
      required String preferredGlucoseUnit,
      Value<bool> usesInsulin,
      Value<bool> usesPills,
      Value<bool> usesCgm,
      required double targetGlucoseMin,
      required double targetGlucoseMax,
      Value<double> metabolicClearanceRate,
      Value<double> insulinSensitivityFactor,
      Value<double> absorptionDelayBase,
      Value<int> tuningMealCount,
      Value<double> fastingSetpoint,
      Value<String> insulinCategory,
      Value<double> insulinDiaMinutes,
      Value<double> ekfCovP1,
      Value<double> ekfCovISF,
      Value<double> ekfCovTMax,
      Value<bool> hasAgreedToDisclaimer,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> age,
      Value<String> gender,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<double?> targetWeightKg,
      Value<String> diabetesType,
      Value<int> diagnosisYear,
      Value<String> preferredGlucoseUnit,
      Value<bool> usesInsulin,
      Value<bool> usesPills,
      Value<bool> usesCgm,
      Value<double> targetGlucoseMin,
      Value<double> targetGlucoseMax,
      Value<double> metabolicClearanceRate,
      Value<double> insulinSensitivityFactor,
      Value<double> absorptionDelayBase,
      Value<int> tuningMealCount,
      Value<double> fastingSetpoint,
      Value<String> insulinCategory,
      Value<double> insulinDiaMinutes,
      Value<double> ekfCovP1,
      Value<double> ekfCovISF,
      Value<double> ekfCovTMax,
      Value<bool> hasAgreedToDisclaimer,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diabetesType => $composableBuilder(
    column: $table.diabetesType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diagnosisYear => $composableBuilder(
    column: $table.diagnosisYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredGlucoseUnit => $composableBuilder(
    column: $table.preferredGlucoseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usesInsulin => $composableBuilder(
    column: $table.usesInsulin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usesPills => $composableBuilder(
    column: $table.usesPills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usesCgm => $composableBuilder(
    column: $table.usesCgm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetGlucoseMin => $composableBuilder(
    column: $table.targetGlucoseMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetGlucoseMax => $composableBuilder(
    column: $table.targetGlucoseMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metabolicClearanceRate => $composableBuilder(
    column: $table.metabolicClearanceRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insulinSensitivityFactor => $composableBuilder(
    column: $table.insulinSensitivityFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get absorptionDelayBase => $composableBuilder(
    column: $table.absorptionDelayBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tuningMealCount => $composableBuilder(
    column: $table.tuningMealCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fastingSetpoint => $composableBuilder(
    column: $table.fastingSetpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insulinCategory => $composableBuilder(
    column: $table.insulinCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insulinDiaMinutes => $composableBuilder(
    column: $table.insulinDiaMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ekfCovP1 => $composableBuilder(
    column: $table.ekfCovP1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ekfCovISF => $composableBuilder(
    column: $table.ekfCovISF,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ekfCovTMax => $composableBuilder(
    column: $table.ekfCovTMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAgreedToDisclaimer => $composableBuilder(
    column: $table.hasAgreedToDisclaimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diabetesType => $composableBuilder(
    column: $table.diabetesType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diagnosisYear => $composableBuilder(
    column: $table.diagnosisYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredGlucoseUnit => $composableBuilder(
    column: $table.preferredGlucoseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesInsulin => $composableBuilder(
    column: $table.usesInsulin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesPills => $composableBuilder(
    column: $table.usesPills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesCgm => $composableBuilder(
    column: $table.usesCgm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetGlucoseMin => $composableBuilder(
    column: $table.targetGlucoseMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetGlucoseMax => $composableBuilder(
    column: $table.targetGlucoseMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metabolicClearanceRate => $composableBuilder(
    column: $table.metabolicClearanceRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insulinSensitivityFactor => $composableBuilder(
    column: $table.insulinSensitivityFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get absorptionDelayBase => $composableBuilder(
    column: $table.absorptionDelayBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tuningMealCount => $composableBuilder(
    column: $table.tuningMealCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fastingSetpoint => $composableBuilder(
    column: $table.fastingSetpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insulinCategory => $composableBuilder(
    column: $table.insulinCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insulinDiaMinutes => $composableBuilder(
    column: $table.insulinDiaMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ekfCovP1 => $composableBuilder(
    column: $table.ekfCovP1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ekfCovISF => $composableBuilder(
    column: $table.ekfCovISF,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ekfCovTMax => $composableBuilder(
    column: $table.ekfCovTMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAgreedToDisclaimer => $composableBuilder(
    column: $table.hasAgreedToDisclaimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diabetesType => $composableBuilder(
    column: $table.diabetesType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diagnosisYear => $composableBuilder(
    column: $table.diagnosisYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredGlucoseUnit => $composableBuilder(
    column: $table.preferredGlucoseUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usesInsulin => $composableBuilder(
    column: $table.usesInsulin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usesPills =>
      $composableBuilder(column: $table.usesPills, builder: (column) => column);

  GeneratedColumn<bool> get usesCgm =>
      $composableBuilder(column: $table.usesCgm, builder: (column) => column);

  GeneratedColumn<double> get targetGlucoseMin => $composableBuilder(
    column: $table.targetGlucoseMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetGlucoseMax => $composableBuilder(
    column: $table.targetGlucoseMax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metabolicClearanceRate => $composableBuilder(
    column: $table.metabolicClearanceRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insulinSensitivityFactor => $composableBuilder(
    column: $table.insulinSensitivityFactor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get absorptionDelayBase => $composableBuilder(
    column: $table.absorptionDelayBase,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tuningMealCount => $composableBuilder(
    column: $table.tuningMealCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fastingSetpoint => $composableBuilder(
    column: $table.fastingSetpoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insulinCategory => $composableBuilder(
    column: $table.insulinCategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insulinDiaMinutes => $composableBuilder(
    column: $table.insulinDiaMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ekfCovP1 =>
      $composableBuilder(column: $table.ekfCovP1, builder: (column) => column);

  GeneratedColumn<double> get ekfCovISF =>
      $composableBuilder(column: $table.ekfCovISF, builder: (column) => column);

  GeneratedColumn<double> get ekfCovTMax => $composableBuilder(
    column: $table.ekfCovTMax,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasAgreedToDisclaimer => $composableBuilder(
    column: $table.hasAgreedToDisclaimer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<String> diabetesType = const Value.absent(),
                Value<int> diagnosisYear = const Value.absent(),
                Value<String> preferredGlucoseUnit = const Value.absent(),
                Value<bool> usesInsulin = const Value.absent(),
                Value<bool> usesPills = const Value.absent(),
                Value<bool> usesCgm = const Value.absent(),
                Value<double> targetGlucoseMin = const Value.absent(),
                Value<double> targetGlucoseMax = const Value.absent(),
                Value<double> metabolicClearanceRate = const Value.absent(),
                Value<double> insulinSensitivityFactor = const Value.absent(),
                Value<double> absorptionDelayBase = const Value.absent(),
                Value<int> tuningMealCount = const Value.absent(),
                Value<double> fastingSetpoint = const Value.absent(),
                Value<String> insulinCategory = const Value.absent(),
                Value<double> insulinDiaMinutes = const Value.absent(),
                Value<double> ekfCovP1 = const Value.absent(),
                Value<double> ekfCovISF = const Value.absent(),
                Value<double> ekfCovTMax = const Value.absent(),
                Value<bool> hasAgreedToDisclaimer = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                diabetesType: diabetesType,
                diagnosisYear: diagnosisYear,
                preferredGlucoseUnit: preferredGlucoseUnit,
                usesInsulin: usesInsulin,
                usesPills: usesPills,
                usesCgm: usesCgm,
                targetGlucoseMin: targetGlucoseMin,
                targetGlucoseMax: targetGlucoseMax,
                metabolicClearanceRate: metabolicClearanceRate,
                insulinSensitivityFactor: insulinSensitivityFactor,
                absorptionDelayBase: absorptionDelayBase,
                tuningMealCount: tuningMealCount,
                fastingSetpoint: fastingSetpoint,
                insulinCategory: insulinCategory,
                insulinDiaMinutes: insulinDiaMinutes,
                ekfCovP1: ekfCovP1,
                ekfCovISF: ekfCovISF,
                ekfCovTMax: ekfCovTMax,
                hasAgreedToDisclaimer: hasAgreedToDisclaimer,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                required int age,
                required String gender,
                required double heightCm,
                required double weightKg,
                Value<double?> targetWeightKg = const Value.absent(),
                required String diabetesType,
                required int diagnosisYear,
                required String preferredGlucoseUnit,
                Value<bool> usesInsulin = const Value.absent(),
                Value<bool> usesPills = const Value.absent(),
                Value<bool> usesCgm = const Value.absent(),
                required double targetGlucoseMin,
                required double targetGlucoseMax,
                Value<double> metabolicClearanceRate = const Value.absent(),
                Value<double> insulinSensitivityFactor = const Value.absent(),
                Value<double> absorptionDelayBase = const Value.absent(),
                Value<int> tuningMealCount = const Value.absent(),
                Value<double> fastingSetpoint = const Value.absent(),
                Value<String> insulinCategory = const Value.absent(),
                Value<double> insulinDiaMinutes = const Value.absent(),
                Value<double> ekfCovP1 = const Value.absent(),
                Value<double> ekfCovISF = const Value.absent(),
                Value<double> ekfCovTMax = const Value.absent(),
                Value<bool> hasAgreedToDisclaimer = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                diabetesType: diabetesType,
                diagnosisYear: diagnosisYear,
                preferredGlucoseUnit: preferredGlucoseUnit,
                usesInsulin: usesInsulin,
                usesPills: usesPills,
                usesCgm: usesCgm,
                targetGlucoseMin: targetGlucoseMin,
                targetGlucoseMax: targetGlucoseMax,
                metabolicClearanceRate: metabolicClearanceRate,
                insulinSensitivityFactor: insulinSensitivityFactor,
                absorptionDelayBase: absorptionDelayBase,
                tuningMealCount: tuningMealCount,
                fastingSetpoint: fastingSetpoint,
                insulinCategory: insulinCategory,
                insulinDiaMinutes: insulinDiaMinutes,
                ekfCovP1: ekfCovP1,
                ekfCovISF: ekfCovISF,
                ekfCovTMax: ekfCovTMax,
                hasAgreedToDisclaimer: hasAgreedToDisclaimer,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectionLogsTableCreateCompanionBuilder =
    ProjectionLogsCompanion Function({
      required String id,
      required String mealLogId,
      required DateTime timestamp,
      required double baselineGlucose,
      required double peakGlucose,
      required int peakTimeMinutes,
      required double twoHourGlucose,
      required String riskLevel,
      required String summary,
      required String pointsJson,
      Value<String> upperBandJson,
      Value<String> lowerBandJson,
      Value<double> confidenceWidth,
      required double totalAvailableGlucose,
      Value<int> rowid,
    });
typedef $$ProjectionLogsTableUpdateCompanionBuilder =
    ProjectionLogsCompanion Function({
      Value<String> id,
      Value<String> mealLogId,
      Value<DateTime> timestamp,
      Value<double> baselineGlucose,
      Value<double> peakGlucose,
      Value<int> peakTimeMinutes,
      Value<double> twoHourGlucose,
      Value<String> riskLevel,
      Value<String> summary,
      Value<String> pointsJson,
      Value<String> upperBandJson,
      Value<String> lowerBandJson,
      Value<double> confidenceWidth,
      Value<double> totalAvailableGlucose,
      Value<int> rowid,
    });

class $$ProjectionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectionLogsTable> {
  $$ProjectionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealLogId => $composableBuilder(
    column: $table.mealLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineGlucose => $composableBuilder(
    column: $table.baselineGlucose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakGlucose => $composableBuilder(
    column: $table.peakGlucose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peakTimeMinutes => $composableBuilder(
    column: $table.peakTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get twoHourGlucose => $composableBuilder(
    column: $table.twoHourGlucose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upperBandJson => $composableBuilder(
    column: $table.upperBandJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lowerBandJson => $composableBuilder(
    column: $table.lowerBandJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceWidth => $composableBuilder(
    column: $table.confidenceWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAvailableGlucose => $composableBuilder(
    column: $table.totalAvailableGlucose,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectionLogsTable> {
  $$ProjectionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealLogId => $composableBuilder(
    column: $table.mealLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineGlucose => $composableBuilder(
    column: $table.baselineGlucose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakGlucose => $composableBuilder(
    column: $table.peakGlucose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peakTimeMinutes => $composableBuilder(
    column: $table.peakTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get twoHourGlucose => $composableBuilder(
    column: $table.twoHourGlucose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upperBandJson => $composableBuilder(
    column: $table.upperBandJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lowerBandJson => $composableBuilder(
    column: $table.lowerBandJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceWidth => $composableBuilder(
    column: $table.confidenceWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAvailableGlucose => $composableBuilder(
    column: $table.totalAvailableGlucose,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectionLogsTable> {
  $$ProjectionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealLogId =>
      $composableBuilder(column: $table.mealLogId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get baselineGlucose => $composableBuilder(
    column: $table.baselineGlucose,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakGlucose => $composableBuilder(
    column: $table.peakGlucose,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peakTimeMinutes => $composableBuilder(
    column: $table.peakTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get twoHourGlucose => $composableBuilder(
    column: $table.twoHourGlucose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get pointsJson => $composableBuilder(
    column: $table.pointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upperBandJson => $composableBuilder(
    column: $table.upperBandJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lowerBandJson => $composableBuilder(
    column: $table.lowerBandJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidenceWidth => $composableBuilder(
    column: $table.confidenceWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAvailableGlucose => $composableBuilder(
    column: $table.totalAvailableGlucose,
    builder: (column) => column,
  );
}

class $$ProjectionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectionLogsTable,
          ProjectionLogRow,
          $$ProjectionLogsTableFilterComposer,
          $$ProjectionLogsTableOrderingComposer,
          $$ProjectionLogsTableAnnotationComposer,
          $$ProjectionLogsTableCreateCompanionBuilder,
          $$ProjectionLogsTableUpdateCompanionBuilder,
          (
            ProjectionLogRow,
            BaseReferences<
              _$AppDatabase,
              $ProjectionLogsTable,
              ProjectionLogRow
            >,
          ),
          ProjectionLogRow,
          PrefetchHooks Function()
        > {
  $$ProjectionLogsTableTableManager(
    _$AppDatabase db,
    $ProjectionLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mealLogId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> baselineGlucose = const Value.absent(),
                Value<double> peakGlucose = const Value.absent(),
                Value<int> peakTimeMinutes = const Value.absent(),
                Value<double> twoHourGlucose = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> pointsJson = const Value.absent(),
                Value<String> upperBandJson = const Value.absent(),
                Value<String> lowerBandJson = const Value.absent(),
                Value<double> confidenceWidth = const Value.absent(),
                Value<double> totalAvailableGlucose = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectionLogsCompanion(
                id: id,
                mealLogId: mealLogId,
                timestamp: timestamp,
                baselineGlucose: baselineGlucose,
                peakGlucose: peakGlucose,
                peakTimeMinutes: peakTimeMinutes,
                twoHourGlucose: twoHourGlucose,
                riskLevel: riskLevel,
                summary: summary,
                pointsJson: pointsJson,
                upperBandJson: upperBandJson,
                lowerBandJson: lowerBandJson,
                confidenceWidth: confidenceWidth,
                totalAvailableGlucose: totalAvailableGlucose,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mealLogId,
                required DateTime timestamp,
                required double baselineGlucose,
                required double peakGlucose,
                required int peakTimeMinutes,
                required double twoHourGlucose,
                required String riskLevel,
                required String summary,
                required String pointsJson,
                Value<String> upperBandJson = const Value.absent(),
                Value<String> lowerBandJson = const Value.absent(),
                Value<double> confidenceWidth = const Value.absent(),
                required double totalAvailableGlucose,
                Value<int> rowid = const Value.absent(),
              }) => ProjectionLogsCompanion.insert(
                id: id,
                mealLogId: mealLogId,
                timestamp: timestamp,
                baselineGlucose: baselineGlucose,
                peakGlucose: peakGlucose,
                peakTimeMinutes: peakTimeMinutes,
                twoHourGlucose: twoHourGlucose,
                riskLevel: riskLevel,
                summary: summary,
                pointsJson: pointsJson,
                upperBandJson: upperBandJson,
                lowerBandJson: lowerBandJson,
                confidenceWidth: confidenceWidth,
                totalAvailableGlucose: totalAvailableGlucose,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectionLogsTable,
      ProjectionLogRow,
      $$ProjectionLogsTableFilterComposer,
      $$ProjectionLogsTableOrderingComposer,
      $$ProjectionLogsTableAnnotationComposer,
      $$ProjectionLogsTableCreateCompanionBuilder,
      $$ProjectionLogsTableUpdateCompanionBuilder,
      (
        ProjectionLogRow,
        BaseReferences<_$AppDatabase, $ProjectionLogsTable, ProjectionLogRow>,
      ),
      ProjectionLogRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalFoodsTableTableManager get localFoods =>
      $$LocalFoodsTableTableManager(_db, _db.localFoods);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db, _db.customFoods);
  $$MealLogsTableTableManager get mealLogs =>
      $$MealLogsTableTableManager(_db, _db.mealLogs);
  $$N5kIngredientsTableTableManager get n5kIngredients =>
      $$N5kIngredientsTableTableManager(_db, _db.n5kIngredients);
  $$GlucoseLogsTableTableManager get glucoseLogs =>
      $$GlucoseLogsTableTableManager(_db, _db.glucoseLogs);
  $$MealMacroLogsTableTableManager get mealMacroLogs =>
      $$MealMacroLogsTableTableManager(_db, _db.mealMacroLogs);
  $$MedicationLogsTableTableManager get medicationLogs =>
      $$MedicationLogsTableTableManager(_db, _db.medicationLogs);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$ProjectionLogsTableTableManager get projectionLogs =>
      $$ProjectionLogsTableTableManager(_db, _db.projectionLogs);
}
