import 'dart:convert';

import 'package:diametrics/services/backend_food_service.dart';
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
  group('weightG regression —', () {
    late ProviderContainer container;
    late MockFoodAnalyzerRepository mockRepo;

    setUp(() {
      mockRepo = MockFoodAnalyzerRepository();
      container = ProviderContainer(overrides: [
        foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);
    });

    const itemWithWeight = FoodItem(
      name: 'Basmati Rice',
      portion: '1 cup cooked',
      carbsGrams: 45.6,
      proteinGrams: 4.2,
      fatGrams: 0.4,
      calories: 202.0,
      weightG: 186.0, // ← this must survive the full flow
      source: 'USDA+N5K',
    );

    test('weightG is preserved when item arrives via barcode result', () {
      container
          .read(foodScannerProvider.notifier)
          .submitBarcodeResult(itemWithWeight);

      final state = container.read(foodScannerProvider);
      expect(state.status, FoodScannerStatus.results);
      expect(state.items.first.weightG, 186.0,
          reason: 'weightG must not be dropped when wrapping barcode result');
    });

    test('weightG is preserved after updateItem edit', () {
      container
          .read(foodScannerProvider.notifier)
          .submitBarcodeResult(itemWithWeight);

      // User edits carbs in FoodItemEditSheet
      final edited = itemWithWeight.copyWith(carbsGrams: 50.0);
      container.read(foodScannerProvider.notifier).updateItem(0, edited);

      final state = container.read(foodScannerProvider);
      expect(state.items.first.carbsGrams, 50.0);
      expect(state.items.first.weightG, 186.0,
          reason: 'weightG must survive FoodItemEditSheet save');
    });

    test('FoodScannerResult carries items list with weightG intact', () {
      container
          .read(foodScannerProvider.notifier)
          .submitBarcodeResult(itemWithWeight);

      final state = container.read(foodScannerProvider);
      final result = FoodScannerResult(
        items: state.items,
        totalCarbs: state.totalCarbs,
        totalFiber: state.totalFiber,
        totalProtein: state.totalProtein,
        totalFat: state.totalFat,
        totalCalories: state.totalCalories,
      );

      expect(result.items.first.weightG, 186.0,
          reason:
              'weightG must be present in FoodScannerResult handed to MealWizardView');
    });

    test('totals computed correctly from multi-item photo analysis result',
        () async {
      final secondItem = itemWithWeight.copyWith(
        name: 'Chicken',
        carbsGrams: 0.0,
        proteinGrams: 31.0,
        fatGrams: 3.6,
        calories: 165.0,
        weightG: 100.0,
        source: 'USDA API',
      );

      when(() => mockRepo.analyzeImage(any())).thenAnswer(
        (_) async => FoodAnalysisResult(
          items: [itemWithWeight, secondItem],
          totalCarbs: 45.6,
          totalCalories: 367.0,
          totalProtein: 35.2,
          totalFat: 4.0,
          summary: 'Rice and Chicken',
        ),
      );

      await container
          .read(foodScannerProvider.notifier)
          .analyseImage('/fake/photo.jpg');

      final state = container.read(foodScannerProvider);
      expect(state.status, FoodScannerStatus.results);
      expect(state.totalCarbs, closeTo(45.6, 0.01));
      expect(state.totalProtein, closeTo(35.2, 0.01));
      expect(state.totalCalories, closeTo(367.0, 0.01));
      expect(state.items[0].weightG, 186.0,
          reason: 'weightG preserved for item 0');
      expect(state.items[1].weightG, 100.0,
          reason: 'weightG preserved for item 1');
    });
  });

  // The backend-proxy AI path (BackendFoodService.analyzeImage) reconstructs
  // each FoodItem with UI-defence clamps in parseFoodAnalysisResponse. This is
  // the only path that previously dropped weightG; the on-device Gemini path
  // uses FoodItem.fromJson directly and was unaffected.
  group('parseFoodAnalysisResponse —', () {
    String backendBody(Map<String, dynamic> item) => jsonEncode({
          'items': [item],
          'summary': 'Meal analyzed',
        });

    test('weightG survives the backend clamp-reconstruction path', () {
      final result = BackendFoodService.parseFoodAnalysisResponse(backendBody({
        'name': 'Basmati Rice',
        'portion': '1 cup cooked',
        'carbs_g': 45.6,
        'fiber_g': 0.6,
        'protein_g': 4.2,
        'fat_g': 0.4,
        'calories': 202.0,
        'weight_g': 186.0,
        'source': 'AI Estimate',
      }));

      expect(result.items.first.weightG, 186.0,
          reason:
              'weightG must not be dropped by parseFoodAnalysisResponse — '
              'FoodRagService.enrichWithLocalData relies on it for portion scaling');
    });

    test('weightG is clamped to the 0..600 ceiling', () {
      final result = BackendFoodService.parseFoodAnalysisResponse(backendBody({
        'name': 'Giant Plate',
        'portion': '1 serving',
        'carbs_g': 10.0,
        'weight_g': 999.0,
        'source': 'AI Estimate',
      }));

      expect(result.items.first.weightG, 600.0,
          reason: 'weightG ceiling must match RAG servingG clamp (10..600)');
    });

    test('missing weight_g defaults to 0.0 (portion-string fallback path)', () {
      final result = BackendFoodService.parseFoodAnalysisResponse(backendBody({
        'name': 'Mystery Snack',
        'portion': '2 pieces',
        'carbs_g': 30.0,
        'source': 'AI Estimate',
      }));

      expect(result.items.first.weightG, 0.0,
          reason: 'no AI weight estimate -> 0.0 so RAG uses quantity parsing');
    });
  });
}
