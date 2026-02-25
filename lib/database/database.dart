import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'database.g.dart';

class Logs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get bgValue => real().nullable()();
  TextColumn get bgUnit => text().withDefault(const Constant('mmol/L'))();
  TextColumn get contextTags => text().nullable()();
  TextColumn get foodVolume => text().nullable()();
  BoolColumn get finishedMeal => boolean().withDefault(const Constant(false))();
}

class LocalFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get servingSize => text().withDefault(const Constant('100g'))();
  RealColumn get carbsPerServing => real()();
}

class CustomFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userDefinedName => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get servingSize =>
      text().withDefault(const Constant('1 serving'))();
  RealColumn get carbsPerServing => real()();
}

class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get transcription => text().nullable()();
  RealColumn get estimatedCarbs => real()();
  IntColumn get completionPercentage =>
      integer().withDefault(const Constant(100))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isOfflineEstimate =>
      boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Logs, LocalFoods, CustomFoods, MealLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Constructor for testing with custom executor (e.g., in-memory database)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        await m.createTable(localFoods);
        await m.createTable(customFoods);
        await m.createTable(mealLogs);
      }
    },
  );

  Future<void> populateLocalFoodsIfEmpty() async {
    final count = await customSelect(
      'SELECT COUNT(*) FROM local_foods',
    ).getSingle();
    final rowCount = count.data.values.first as int;
    if (rowCount == 0) {
      try {
        final csvString = await rootBundle.loadString(
          'assets/database/cleaned_food_database.csv',
        );
        final lines = csvString.split('\n');

        await batch((batch) {
          for (int i = 1; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.isEmpty) continue;

            final lastCommaIndex = line.lastIndexOf(',');
            if (lastCommaIndex != -1) {
              String name = line.substring(0, lastCommaIndex);
              // Clean wrapping quotes
              if (name.startsWith('"') && name.endsWith('"')) {
                name = name.substring(1, name.length - 1);
              }
              final carbsStr = line.substring(lastCommaIndex + 1);
              final carbs = double.tryParse(carbsStr) ?? 0.0;

              batch.insert(
                localFoods,
                LocalFoodsCompanion.insert(name: name, carbsPerServing: carbs),
              );
            }
          }
        });
      } catch (e) {
        // Safe fail if asset is missing or not reachable
        print('Error populating local foods: \$e');
      }
    }
  }

  Future<int> insertGlucoseLog({
    required DateTime timestamp,
    required double bgValue,
    String bgUnit = 'mmol/L',
  }) {
    return into(logs).insert(
      LogsCompanion.insert(
        timestamp: timestamp,
        bgValue: Value(bgValue),
        bgUnit: Value(bgUnit),
      ),
    );
  }

  Future<List<Log>> getLogsLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(logs)
          ..where((l) => l.timestamp.isBiggerThanValue(cutoff))
          ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
        .get();
  }

  Future<List<Log>> getAllLogs() {
    return (select(
      logs,
    )..orderBy([(l) => OrderingTerm.desc(l.timestamp)])).get();
  }

  Future deleteLog(int id) =>
      (delete(logs)..where((t) => t.id.equals(id))).go();

  Future<List<Log>> getRecentLogs(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return (select(
      logs,
    )..where((l) => l.timestamp.isBiggerThanValue(cutoff))).get();
  }

  /// Searches local and custom foods for a name match to enrich AI data
  Future<LocalFood?> searchLocalFood(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(localFoods)
          ..where((f) => f.name.lower().like(searchTerm))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<CustomFood?> searchCustomFood(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(customFoods)
          ..where((f) => f.userDefinedName.lower().like(searchTerm))
          ..limit(1))
        .getSingleOrNull();
  }
}
