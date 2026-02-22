import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/database/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Use in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Tests', () {
    test('should insert a log entry', () async {
      // Arrange
      final testTimestamp = DateTime.now();

      // Act
      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: testTimestamp,
              bgValue: const Value(5.5),
              bgUnit: const Value('mmol/L'),
              contextTags: const Value('Fasting'),
              foodVolume: const Value('None'),
              finishedMeal: const Value(false),
            ),
          );

      // Assert
      final logs = await database.select(database.logs).get();
      expect(logs.length, 1);
      expect(logs.first.bgValue, 5.5);
      expect(logs.first.bgUnit, 'mmol/L');
      expect(logs.first.contextTags, 'Fasting');
    });

    test('should retrieve recent logs within time window', () async {
      // Arrange - Insert logs at different times
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final lastWeek = now.subtract(const Duration(days: 7));

      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(timestamp: now, bgValue: const Value(6.0)),
          );
      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: yesterday,
              bgValue: const Value(5.5),
            ),
          );
      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: lastWeek,
              bgValue: const Value(5.0),
            ),
          );

      // Act - Get logs from last 2 days
      final recentLogs = await database.getRecentLogs(const Duration(days: 2));

      // Assert
      expect(recentLogs.length, 2);
      expect(recentLogs.any((l) => l.bgValue == 6.0), true);
      expect(recentLogs.any((l) => l.bgValue == 5.5), true);
      expect(recentLogs.any((l) => l.bgValue == 5.0), false);
    });

    test('should store all log fields correctly', () async {
      // Arrange
      final testTimestamp = DateTime(2026, 2, 7, 10, 30, 0);

      // Act
      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: testTimestamp,
              bgValue: const Value(7.2),
              bgUnit: const Value('mmol/L'),
              contextTags: const Value('After Meal'),
              foodVolume: const Value('1 fist size'),
              finishedMeal: const Value(true),
            ),
          );

      // Assert
      final log = (await database.select(database.logs).get()).first;
      expect(log.bgValue, 7.2);
      expect(log.bgUnit, 'mmol/L');
      expect(log.contextTags, 'After Meal');
      expect(log.foodVolume, '1 fist size');
      expect(log.finishedMeal, true);
      expect(log.timestamp, testTimestamp);
    });

    test('should handle nullable fields', () async {
      // Act - Insert with minimal required fields
      await database
          .into(database.logs)
          .insert(LogsCompanion.insert(timestamp: DateTime.now()));

      // Assert
      final log = (await database.select(database.logs).get()).first;
      expect(log.bgValue, isNull);
      expect(log.contextTags, isNull);
      expect(log.foodVolume, isNull);
      expect(log.bgUnit, 'mmol/L'); // Default value
      expect(log.finishedMeal, false); // Default value
    });

    test('should delete logs', () async {
      // Arrange
      await database
          .into(database.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: DateTime.now(),
              bgValue: const Value(5.5),
            ),
          );

      // Verify inserted
      var logs = await database.select(database.logs).get();
      expect(logs.length, 1);

      // Act
      await database.delete(database.logs).go();

      // Assert
      logs = await database.select(database.logs).get();
      expect(logs.length, 0);
    });
  });
}
