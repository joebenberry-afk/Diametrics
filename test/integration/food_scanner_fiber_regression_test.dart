import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:diametrics/src/domain/entities/food_scanner_result.dart';
import 'package:diametrics/src/domain/entities/food_analysis_result.dart';
import 'package:diametrics/src/domain/repositories/food_analyzer_repository.dart';
import 'package:diametrics/viewmodels/food_scanner_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodAnalyzerRepository extends Mock
    implements FoodAnalyzerRepository {}

void main() {
  group('fiber regression —', () {
    late ProviderContainer container;
    late MockFoodAnalyzerRepository mockRepo;

    setUp(() {
      mockRepo = MockFoodAnalyzerRepository();
      container = ProviderContainer(overrides: [
        foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);
    });

    const itemWithFiber = FoodItem(
      name: 'Black Beans',
      portion: '1 cup',
      carbsGrams: 40.0,
      fiberGrams: 15.0, // ← must survive the full flow
      proteinGrams: 15.0,
      fatGrams: 1.0,
      calories: 227.0,
      source: 'USDA+N5K',
    );

    test('fiberGrams preserved when item arrives via barcode result', () {
      container
          .read(foodScannerProvider.notifier)
          .submitBarcodeResult(itemWithFiber);

      final state = container.read(foodScannerProvider);
      expect(state.items.first.fiberGrams, 15.0,
          reason: 'fiberGrams must not be dropped when wrapping barcode result');
    });

    test('FoodScannerResult carries totalFiber from scanner state', () {
      container
          .read(foodScannerProvider.notifier)
          .submitBarcodeResult(itemWithFiber);

      final state = container.read(foodScannerProvider);
      final result = FoodScannerResult(
        items: state.items,
        totalCarbs: state.totalCarbs,
        totalProtein: state.totalProtein,
        totalFat: state.totalFat,
        totalCalories: state.totalCalories,
        totalFiber: state.totalFiber,
      );

      expect(result.totalFiber, 15.0,
          reason:
              'totalFiber must reach MealWizardView so pendingFiber is non-zero');
    });

    test('totalFiber aggregates across a multi-item photo analysis', () async {
      final second = itemWithFiber.copyWith(
        name: 'Avocado',
        carbsGrams: 12.0,
        fiberGrams: 10.0,
      );

      when(() => mockRepo.analyzeImage(any())).thenAnswer(
        (_) async => FoodAnalysisResult(
          items: [itemWithFiber, second],
          totalCarbs: 52.0,
          totalCalories: 454.0,
          summary: 'Beans and Avocado',
        ),
      );

      await container
          .read(foodScannerProvider.notifier)
          .analyseImage('/fake/photo.jpg');

      final state = container.read(foodScannerProvider);
      expect(state.totalFiber, closeTo(25.0, 0.001),
          reason: 'fiber from every analysed item must contribute to the total');
    });
  });
}
