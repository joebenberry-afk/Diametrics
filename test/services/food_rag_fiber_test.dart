import 'package:diametrics/database/database.dart';
import 'package:diametrics/database/db_instance.dart';
import 'package:diametrics/services/food_rag_service.dart';
import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodRagService fiber preservation —', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
      setDbForTesting(testDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('local-DB tier keeps the AI fiber estimate (no fiber column in DB)',
        () async {
      // Seed a Tier-2 local match. The local food table carries carbs only —
      // no fiber — so the AI's fiber estimate is the only fiber source.
      await testDb.into(testDb.localFoods).insert(
            LocalFoodsCompanion.insert(
              name: 'Brown Rice',
              carbsPerServing: 45.0,
            ),
          );

      const aiItem = FoodItem(
        name: 'Brown Rice',
        portion: '1 cup',
        carbsGrams: 45.0,
        fiberGrams: 3.5,
        proteinGrams: 5.0,
        fatGrams: 1.0,
        calories: 216.0,
        source: 'AI Estimate',
      );

      final enriched = await FoodRagService.enrichWithLocalData([aiItem]);

      expect(enriched.single.source, 'Local DB',
          reason: 'sanity: the local tier should have matched and enriched');
      expect(enriched.single.fiberGrams, closeTo(3.5, 0.001),
          reason:
              'local DBs carry no fiber, so the AI fiber estimate must survive enrichment');
    });
  });
}
