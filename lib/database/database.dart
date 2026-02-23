import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// NOTE: Temporarily using shared_preferences for the encryption key since flutter_secure_storage
// is failing to compile on Windows due to a missing C++ header dependency.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
}

/// Securely generates or retrieves the AES-256 encryption key.
///
/// Due to local build constraints on Windows with `flutter_secure_storage`,
/// this fallback temporarily uses SharedPreferences.
Future<String> _getOrCreateEncryptionKey() async {
  final prefs = await SharedPreferences.getInstance();
  const keyName = 'diametrics_db_key_fallback';

  String? existingKey = prefs.getString(keyName);
  if (existingKey != null) {
    return existingKey;
  }

  // Generate a 32-byte (256-bit) random key as hex
  final random = Random.secure();
  final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
  final newKey = keyBytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  await prefs.setString(keyName, newKey);
  return newKey;
}

/// Opens an AES-256 encrypted SQLite database using SQLCipher.
Future<NativeDatabase> openEncryptedDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app.db'));
  final encryptionKey = await _getOrCreateEncryptionKey();

  return NativeDatabase(
    file,
    setup: (rawDb) {
      // PRAGMA key must be the first statement executed on the database.
      // This sets the AES-256 encryption key for SQLCipher.
      rawDb.execute("PRAGMA key = '$encryptionKey'");
    },
  );
}
