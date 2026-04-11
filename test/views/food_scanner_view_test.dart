import 'package:diametrics/core/theme/app_theme.dart';
import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:diametrics/src/domain/repositories/food_analyzer_repository.dart';
import 'package:diametrics/viewmodels/food_scanner_viewmodel.dart';
import 'package:diametrics/views/food_scanner/food_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodAnalyzerRepository extends Mock
    implements FoodAnalyzerRepository {}

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

Widget _wrapThemed(
  Widget child,
  ThemeData theme, {
  List<Override> overrides = const [],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(theme: theme, home: child),
);

void main() {
  late MockFoodAnalyzerRepository mockRepo;

  setUp(() => mockRepo = MockFoodAnalyzerRepository());

  testWidgets('State 1: shows source picker buttons', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const FoodScannerView(),
        overrides: [foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)],
      ),
    );
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    expect(find.text('Scan Barcode'), findsOneWidget);
  });

  testWidgets('State 2: shows progress indicator and status text', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
          foodScannerProvider.overrideWith(() => _AnalysingStateNotifier()),
        ],
        child: const MaterialApp(home: FoodScannerView()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sending to Gemini…'), findsOneWidget);
  });

  testWidgets('State 3: shows item list and confirm button', (tester) async {
    const item = FoodItem(
      name: 'Rice',
      portion: '1 cup',
      carbsGrams: 45.0,
      proteinGrams: 4.0,
      fatGrams: 0.5,
      calories: 200.0,
      weightG: 186.0,
      source: 'USDA+N5K',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: FoodScannerView()),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FoodScannerView)),
    );
    container.read(foodScannerProvider.notifier).submitBarcodeResult(item);
    await tester.pump();

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Confirm & Add to Meal'), findsOneWidget);
  });

  testWidgets('State 5: shows not-found message and recovery options', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: FoodScannerView()),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FoodScannerView)),
    );
    container.read(foodScannerProvider.notifier).handleBarcodeNotFound();
    await tester.pump();

    expect(find.text('Product not found'), findsOneWidget);
    expect(find.text('Take a Photo Instead'), findsOneWidget);
    expect(find.text('Add to Meal'), findsOneWidget);
  });

  group('theme rendering', () {
    testWidgets('renders under AppTheme.lightTheme without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapThemed(
          const FoodScannerView(),
          AppTheme.lightTheme,
          overrides: [
            foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(FoodScannerView), findsOneWidget);
    });

    testWidgets('renders under AppTheme.darkTheme without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapThemed(
          const FoodScannerView(),
          AppTheme.darkTheme,
          overrides: [
            foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(FoodScannerView), findsOneWidget);
    });
  });
}

/// Test notifier that immediately enters the analysing state.
class _AnalysingStateNotifier extends FoodScannerNotifier {
  @override
  FoodScannerState build() => const FoodScannerState(
    status: FoodScannerStatus.analysing,
    analysisStatus: 'Sending to Gemini…',
  );
}
