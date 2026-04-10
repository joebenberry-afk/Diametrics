import 'package:drift/drift.dart' hide isNull, isNotNull;
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
    test('should insert a local food entry', () async {
      // Act
      await database.into(database.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'Brown Rice',
              carbsPerServing: 45.0,
            ),
          );

      // Assert
      final foods = await database.select(database.localFoods).get();
      expect(foods.length, 1);
      expect(foods.first.name, 'Brown Rice');
      expect(foods.first.carbsPerServing, 45.0);
    });

    test('should search local food by name', () async {
      // Arrange
      await database.into(database.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'White Bread',
              carbsPerServing: 15.0,
            ),
          );
      await database.into(database.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'Chicken Breast',
              carbsPerServing: 0.0,
            ),
          );

      // Act
      final result = await database.searchLocalFood('bread');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'White Bread');
      expect(result.carbsPerServing, 15.0);
    });

    test('should store all local food fields correctly', () async {
      // Act
      await database.into(database.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'Oatmeal',
              servingSize: const Value('40g'),
              carbsPerServing: 27.0,
            ),
          );

      // Assert
      final food = (await database.select(database.localFoods).get()).first;
      expect(food.name, 'Oatmeal');
      expect(food.servingSize, '40g');
      expect(food.carbsPerServing, 27.0);
    });

    test('should handle nullable barcode in custom foods', () async {
      // Act — insert without barcode (nullable)
      await database.into(database.customFoods).insert(
            CustomFoodsCompanion.insert(
              userDefinedName: 'Homemade Granola',
              carbsPerServing: 32.0,
            ),
          );

      // Assert
      final food = (await database.select(database.customFoods).get()).first;
      expect(food.userDefinedName, 'Homemade Granola');
      expect(food.barcode, isNull);
      expect(food.servingSize, '1 serving'); // Default value
    });

    test('should delete local foods', () async {
      // Arrange
      await database.into(database.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'Apple',
              carbsPerServing: 25.0,
            ),
          );

      // Verify inserted
      var foods = await database.select(database.localFoods).get();
      expect(foods.length, 1);

      // Act
      await database.delete(database.localFoods).go();

      // Assert
      foods = await database.select(database.localFoods).get();
      expect(foods.length, 0);
    });
  });
}
