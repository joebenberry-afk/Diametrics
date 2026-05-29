import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodItem.fiberGrams —', () {
    test('parses fiber_g from JSON into fiberGrams', () {
      final item = FoodItem.fromJson({
        'name': 'Brown Rice',
        'portion': '1 cup',
        'carbs_g': 45.0,
        'fiber_g': 3.5,
        'protein_g': 5.0,
        'fat_g': 1.0,
        'calories': 216.0,
      });
      expect(item.fiberGrams, 3.5);
    });

    test('defaults fiberGrams to 0.0 when fiber_g absent', () {
      final item = FoodItem.fromJson({'name': 'Mystery'});
      expect(item.fiberGrams, 0.0);
    });

    test('serializes fiberGrams back to the fiber_g key', () {
      const item = FoodItem(name: 'Oats', fiberGrams: 8.0);
      expect(item.toJson()['fiber_g'], 8.0);
    });
  });
}
