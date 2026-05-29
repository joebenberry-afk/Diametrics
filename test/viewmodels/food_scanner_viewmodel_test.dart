import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:diametrics/src/domain/entities/food_analysis_result.dart';
import 'package:diametrics/src/domain/repositories/food_analyzer_repository.dart';
import 'package:diametrics/viewmodels/food_scanner_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodAnalyzerRepository extends Mock
    implements FoodAnalyzerRepository {}

void main() {
  late ProviderContainer container;
  late MockFoodAnalyzerRepository mockRepo;

  const testItem = FoodItem(
    name: 'Rice',
    portion: '1 cup',
    carbsGrams: 45.0,
    proteinGrams: 4.0,
    fatGrams: 0.5,
    calories: 200.0,
    weightG: 186.0,
    source: 'USDA API',
  );

  setUp(() {
    mockRepo = MockFoodAnalyzerRepository();
    container = ProviderContainer(overrides: [
      foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    addTearDown(container.dispose);
  });

  test('initial state is idle with no items', () {
    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.idle);
    expect(state.items, isEmpty);
  });

  test('submitBarcodeResult transitions to results with item', () {
    container
        .read(foodScannerProvider.notifier)
        .submitBarcodeResult(testItem);
    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.results);
    expect(state.items.length, 1);
    expect(state.items.first.weightG, 186.0); // weightG preserved
  });

  test('handleBarcodeNotFound transitions to barcodeNotFound', () {
    container
        .read(foodScannerProvider.notifier)
        .handleBarcodeNotFound();
    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.barcodeNotFound);
  });

  test('updateItem replaces item at index and recomputes totals', () {
    container
        .read(foodScannerProvider.notifier)
        .submitBarcodeResult(testItem);
    final updated = testItem.copyWith(carbsGrams: 60.0);
    container.read(foodScannerProvider.notifier).updateItem(0, updated);
    final state = container.read(foodScannerProvider);
    expect(state.items.first.carbsGrams, 60.0);
    expect(state.totalCarbs, 60.0);
  });

  test('totalFiber sums fiberGrams across all items', () {
    const state = FoodScannerState(items: [
      FoodItem(name: 'Black Beans', carbsGrams: 30.0, fiberGrams: 9.0),
      FoodItem(name: 'Whole Wheat Bread', carbsGrams: 24.0, fiberGrams: 2.5),
    ]);
    expect(state.totalFiber, closeTo(11.5, 0.001));
  });

  test('submitManualEntry transitions to results', () {
    const manual = FoodItem(
      name: 'Bread',
      portion: '2 slices',
      carbsGrams: 28.0,
      proteinGrams: 4.0,
      fatGrams: 2.0,
      calories: 140.0,
      source: 'Manual Entry',
    );
    container
        .read(foodScannerProvider.notifier)
        .submitManualEntry(manual);
    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.results);
    expect(state.items.first.name, 'Bread');
  });

  test('reset returns state to idle', () {
    container
        .read(foodScannerProvider.notifier)
        .submitBarcodeResult(testItem);
    container.read(foodScannerProvider.notifier).reset();
    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.idle);
    expect(state.items, isEmpty);
  });

  test('analyseImage transitions idle→analysing→results on success', () async {
    when(() => mockRepo.analyzeImage(any())).thenAnswer(
      (_) async => FoodAnalysisResult(
        items: [testItem],
        totalCarbs: 45.0,
        totalCalories: 200.0,
        summary: 'Rice',
      ),
    );

    await container
        .read(foodScannerProvider.notifier)
        .analyseImage('/fake/path.jpg');

    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.results);
    expect(state.items.first.name, 'Rice');
  });

  test('analyseImage transitions to error on exception', () async {
    when(() => mockRepo.analyzeImage(any()))
        .thenThrow(Exception('Network error'));

    await container
        .read(foodScannerProvider.notifier)
        .analyseImage('/fake/path.jpg');

    final state = container.read(foodScannerProvider);
    expect(state.status, FoodScannerStatus.error);
    expect(state.errorMessage, isNotNull);
  });
}
