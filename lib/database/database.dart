import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'database.g.dart';

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
  RealColumn get totalCalories => real().withDefault(const Constant(0.0))();
  RealColumn get totalProtein => real().withDefault(const Constant(0.0))();
  RealColumn get totalFat => real().withDefault(const Constant(0.0))();
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

@DataClassName('GlucoseLogRow')
class GlucoseLogs extends Table {
  TextColumn get id => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get context => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealMacroLog')
class MealMacroLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get name => text().nullable()();
  RealColumn get carbohydrates => real()();
  RealColumn get dietaryFiber => real().withDefault(const Constant(0.0))();
  RealColumn get proteins => real()();
  RealColumn get fats => real()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  BoolColumn get containsAlcohol => boolean().withDefault(const Constant(false))();
  BoolColumn get containsCaffeine => boolean().withDefault(const Constant(false))();
  TextColumn get mealType => text()();
  TextColumn get foodFormFactor => text().withDefault(const Constant('standard'))();
  BoolColumn get postExercise => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationLogRow')
class MedicationLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get medicationType => text()();
  TextColumn get insulinType => text().withDefault(const Constant('Humalog / NovoLog'))();
  TextColumn get name => text().nullable()();
  RealColumn get units => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  RealColumn get targetWeightKg => real().nullable()();
  TextColumn get diabetesType => text()();
  IntColumn get diagnosisYear => integer()();
  TextColumn get preferredGlucoseUnit => text()();
  BoolColumn get usesInsulin => boolean().withDefault(const Constant(false))();
  BoolColumn get usesPills => boolean().withDefault(const Constant(false))();
  BoolColumn get usesCgm => boolean().withDefault(const Constant(false))();
  RealColumn get targetGlucoseMin => real()();
  RealColumn get targetGlucoseMax => real()();
  RealColumn get metabolicClearanceRate => real().withDefault(const Constant(0.010))();
  RealColumn get insulinSensitivityFactor => real().withDefault(const Constant(50.0))();
  RealColumn get absorptionDelayBase => real().withDefault(const Constant(40.0))();
  IntColumn get tuningMealCount => integer().withDefault(const Constant(0))();
  RealColumn get fastingSetpoint => real().withDefault(const Constant(90.0))();
  TextColumn get insulinCategory => text().withDefault(const Constant('standard_rapid'))();
  RealColumn get insulinDiaMinutes => real().withDefault(const Constant(240.0))();
  RealColumn get ekfCovP1 => real().withDefault(const Constant(1.0))();
  RealColumn get ekfCovISF => real().withDefault(const Constant(1.0))();
  RealColumn get ekfCovTMax => real().withDefault(const Constant(1.0))();
  BoolColumn get hasAgreedToDisclaimer => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  LocalFoods, CustomFoods, MealLogs, N5kIngredients,
  GlucoseLogs, MealMacroLogs, MedicationLogs, UserProfiles,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Constructor for testing with custom executor (e.g., in-memory database)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

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
      if (from <= 3) {
        await m.addColumn(mealLogs, mealLogs.totalCalories);
        await m.addColumn(mealLogs, mealLogs.totalProtein);
        await m.addColumn(mealLogs, mealLogs.totalFat);
      }
      if (from <= 4) {
        await m.createTable(glucoseLogs);
        await m.createTable(mealMacroLogs);
        await m.createTable(medicationLogs);
        await m.createTable(userProfiles);
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

}
