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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LogsTable logs = $LogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [logs];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
}
