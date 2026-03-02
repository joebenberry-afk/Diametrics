import 'dart:developer' as developer;
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

/// Nutrition5K ingredient table — 555 common ingredients with full per-gram macros.
/// Source: Google Research Nutrition5K dataset (metadata CSV only, no images).
class N5kIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get calPerG => real()();     // calories per gram
  RealColumn get fatPerG => real()();     // fat grams per gram
  RealColumn get carbPerG => real()();    // carb grams per gram
  RealColumn get proteinPerG => real()(); // protein grams per gram
}

@DriftDatabase(tables: [Logs, LocalFoods, CustomFoods, MealLogs, N5kIngredients])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Constructor for testing with custom executor (e.g., in-memory database)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

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
      if (from <= 2) {
        await m.createTable(n5kIngredients);
      }
    },
  );

  // ── Seeding ────────────────────────────────────────────────────────────

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
        developer.log('Error populating local foods: $e');
      }
    }
  }

  /// Seeds the N5K ingredient table from the bundled CSV on first run.
  /// CSV format: ingr_name, ingr_id, cal/g, fat(g), carb(g), protein(g)
  Future<void> populateN5kIfEmpty() async {
    final count = await customSelect(
      'SELECT COUNT(*) FROM n5k_ingredients',
    ).getSingle();
    final rowCount = count.data.values.first as int;
    if (rowCount > 0) return;

    try {
      final csvString = await rootBundle.loadString(
        'assets/database/n5k_ingredients.csv',
      );
      final lines = csvString.split('\n');

      await batch((b) {
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.length < 6) continue;

          final name = parts[0].trim();
          // parts[1] = ingr_id (skip)
          final calPerG = double.tryParse(parts[2].trim()) ?? 0.0;
          final fatPerG = double.tryParse(parts[3].trim()) ?? 0.0;
          final carbPerG = double.tryParse(parts[4].trim()) ?? 0.0;
          final proteinPerG = double.tryParse(parts[5].trim()) ?? 0.0;

          if (name.isEmpty) continue;

          b.insert(
            n5kIngredients,
            N5kIngredientsCompanion.insert(
              name: name,
              calPerG: calPerG,
              fatPerG: fatPerG,
              carbPerG: carbPerG,
              proteinPerG: proteinPerG,
            ),
          );
        }
      });
      developer.log('N5K: seeded ${lines.length - 1} ingredients');
    } catch (e) {
      developer.log('Error populating N5K ingredients: $e');
    }
  }

  // ── Log queries ────────────────────────────────────────────────────────

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

  // ── Food search ────────────────────────────────────────────────────────

  /// Searches local USDA foods for a name match (carbs only).
  Future<LocalFood?> searchLocalFood(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(localFoods)
          ..where((f) => f.name.lower().like(searchTerm))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Searches user-defined custom foods.
  Future<CustomFood?> searchCustomFood(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(customFoods)
          ..where((f) => f.userDefinedName.lower().like(searchTerm))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Searches N5K ingredients for full per-gram macro data.
  Future<N5kIngredient?> searchN5kIngredient(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(n5kIngredients)
          ..where((f) => f.name.lower().like(searchTerm))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Looks up a custom food directly by barcode string.
  Future<CustomFood?> searchCustomFoodByBarcode(String barcode) async {
    return (select(customFoods)
          ..where((f) => f.barcode.equals(barcode))
          ..limit(1))
        .getSingleOrNull();
  }
}
