# Food Scanner Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the food-scanning flow embedded in `MealWizardView` with a dedicated `FoodScannerView` screen, fix two missing fields in `FoodAnalysisResult`, and deliver a clinical-precision UI for all 5 scanner states.

**Architecture:** `MealWizardView` pushes `FoodScannerView` via go_router and awaits a `FoodScannerResult`. `FoodScannerView` owns all scanning states (source picker, analysing, results, barcode-not-found) managed by a Riverpod `AutoDisposeNotifier`. `FoodItemEditSheet` is a bottom sheet overlay on the results state.

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod: ^2.6.1`), Freezed (`freezed_annotation: ^3.1.0`), go_router (`^14.6.3`), `image_picker: ^1.2.1`, `lucide_icons: ^0.257.0`, `mocktail: ^1.0.4` (tests), `get_it` for service resolution.

---

## File Map

| Status | File | Responsibility |
|---|---|---|
| **Modify** | `lib/src/domain/entities/food_analysis_result.dart` | Add `totalProtein`, `totalFat`, `confidenceScore` |
| **Modify** | `lib/src/data/repositories/gemini_food_analyzer_impl.dart` | Compute + populate new totals |
| **Modify** | `lib/services/food_rag_service.dart` | Emit progress stream events per tier |
| **Create** | `lib/src/domain/entities/food_scanner_result.dart` | Return type: FoodScannerView → MealWizardView |
| **Create** | `lib/viewmodels/food_scanner_viewmodel.dart` | `FoodScannerState` + `FoodScannerNotifier` + provider |
| **Create** | `lib/views/food_scanner/food_scanner_view.dart` | Main screen — all 5 states |
| **Create** | `lib/views/food_scanner/food_item_edit_sheet.dart` | Per-item editing bottom sheet |
| **Modify** | `lib/router/route_names.dart` | Add `logMealFoodScanner` constant |
| **Modify** | `lib/router/app_router.dart` | Register `food-scanner` child route |
| **Modify** | `lib/views/logging/meal_wizard_view.dart` | Remove embedded scanning; add `_openFoodScanner` |
| **Create** | `test/viewmodels/food_scanner_viewmodel_test.dart` | Unit tests — state transitions |
| **Create** | `test/views/food_item_edit_sheet_test.dart` | Widget test — field binding |
| **Create** | `test/views/food_scanner_view_test.dart` | Widget tests — one per state |
| **Create** | `test/integration/food_scanner_weight_regression_test.dart` | weightG preservation regression |

---

## Task 1: Fix FoodAnalysisResult + Populate New Fields in GeminiFoodAnalyzerImpl

**Files:**
- Modify: `lib/src/domain/entities/food_analysis_result.dart`
- Modify: `lib/src/data/repositories/gemini_food_analyzer_impl.dart`

- [ ] **Step 1.1: Update FoodAnalysisResult to add the three missing fields**

  Replace the factory in `lib/src/domain/entities/food_analysis_result.dart`:

  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';

  import 'food_item.dart';

  part 'food_analysis_result.freezed.dart';
  part 'food_analysis_result.g.dart';

  @freezed
  abstract class FoodAnalysisResult with _$FoodAnalysisResult {
    const factory FoodAnalysisResult({
      required List<FoodItem> items,
      required double totalCarbs,
      required double totalCalories,
      required String summary,
      @Default(0.0) double totalProtein,
      @Default(0.0) double totalFat,
      @Default({}) Map<String, double> confidenceScore,
    }) = _FoodAnalysisResult;

    factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) =>
        _$FoodAnalysisResultFromJson(json);
  }
  ```

  > `totalProtein` and `totalFat` use `@Default(0.0)` so Gemini's JSON response (which only has `totalCarbs` and `totalCalories`) still deserializes correctly. The correct values are computed post-enrichment in `GeminiFoodAnalyzerImpl`.

- [ ] **Step 1.2: Regenerate Freezed code**

  Run: `dart run build_runner build --delete-conflicting-outputs`

  Expected: `food_analysis_result.freezed.dart` and `food_analysis_result.g.dart` regenerated with no errors.

- [ ] **Step 1.3: Add confidence helper and update enrichedResult construction in GeminiFoodAnalyzerImpl**

  In `lib/src/data/repositories/gemini_food_analyzer_impl.dart`, replace the block that computes totals and builds `enrichedResult` (currently lines ~76–93):

  ```dart
  double newTotalCarbs = 0;
  double newTotalCalories = 0;
  double newTotalProtein = 0;
  double newTotalFat = 0;
  for (final item in enrichedItems) {
    newTotalCarbs += item.carbsGrams;
    newTotalCalories += item.calories;
    newTotalProtein += item.proteinGrams;
    newTotalFat += item.fatGrams;
  }

  final enrichedResult = FoodAnalysisResult(
    items: enrichedItems,
    totalCarbs: newTotalCarbs,
    totalCalories: newTotalCalories,
    totalProtein: newTotalProtein,
    totalFat: newTotalFat,
    summary: result.summary,
    confidenceScore: _computeConfidence(enrichedItems),
  );
  ```

  Then add this private helper anywhere in the class (before the closing `}`):

  ```dart
  /// Computes an average confidence score across all items based on their
  /// data source tier. Higher tier = more reliable = higher score (0.0–1.0).
  Map<String, double> _computeConfidence(List<FoodItem> items) {
    if (items.isEmpty) return {};
    const sourceTiers = <String, double>{
      'Custom Food DB': 1.0,
      'USDA+N5K': 0.9,
      'USDA API': 0.9,
      'Open Food Facts': 0.9,
      'N5K': 0.85,
      'Local DB': 0.8,
      'AI Estimate': 0.4,
    };
    double total = 0;
    for (final item in items) {
      total += sourceTiers[item.source] ?? 0.4;
    }
    final avg = (total / items.length).clamp(0.0, 1.0);
    return {'carbs': avg, 'protein': avg, 'fat': avg, 'calories': avg};
  }
  ```

- [ ] **Step 1.4: Verify the build compiles**

  Run: `flutter analyze`

  Expected: No errors. Warnings about unused imports are acceptable.

- [ ] **Step 1.5: Commit**

  ```bash
  git add lib/src/domain/entities/food_analysis_result.dart \
          lib/src/domain/entities/food_analysis_result.freezed.dart \
          lib/src/domain/entities/food_analysis_result.g.dart \
          lib/src/data/repositories/gemini_food_analyzer_impl.dart
  git commit -m "feat: add totalProtein, totalFat, confidenceScore to FoodAnalysisResult"
  ```

---

## Task 2: Create FoodScannerResult Entity

**Files:**
- Create: `lib/src/domain/entities/food_scanner_result.dart`

- [ ] **Step 2.1: Create the entity file**

  Create `lib/src/domain/entities/food_scanner_result.dart`:

  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';

  import 'food_item.dart';

  part 'food_scanner_result.freezed.dart';

  /// Returned by [FoodScannerView] when the user confirms their food selection.
  /// This is the push/pop contract between FoodScannerView and MealWizardView.
  /// No JSON serialisation — this is an in-memory return value only.
  @freezed
  abstract class FoodScannerResult with _$FoodScannerResult {
    const factory FoodScannerResult({
      required List<FoodItem> items,
      required double totalCarbs,
      required double totalProtein,
      required double totalFat,
      required double totalCalories,
    }) = _FoodScannerResult;
  }
  ```

- [ ] **Step 2.2: Regenerate Freezed code**

  Run: `dart run build_runner build --delete-conflicting-outputs`

  Expected: `lib/src/domain/entities/food_scanner_result.freezed.dart` created.

- [ ] **Step 2.3: Commit**

  ```bash
  git add lib/src/domain/entities/food_scanner_result.dart \
          lib/src/domain/entities/food_scanner_result.freezed.dart
  git commit -m "feat: add FoodScannerResult entity"
  ```

---

## Task 3: Add Progress Stream to FoodRagService

**Files:**
- Modify: `lib/services/food_rag_service.dart`

- [ ] **Step 3.1: Add the stream controller and public stream to FoodRagService**

  Add these two lines immediately after the class declaration opening brace in `lib/services/food_rag_service.dart`:

  ```dart
  class FoodRagService {
    static final _progressController = StreamController<String>.broadcast();

    /// Emits a status string at the start of each enrichment tier.
    /// Listen to this from [FoodScannerNotifier] to show live progress in State 2.
    static Stream<String> get progressStream => _progressController.stream;
  ```

  Also add the missing import at the top of the file:

  ```dart
  import 'dart:async';
  ```

- [ ] **Step 3.2: Emit progress events at each tier inside enrichWithLocalData**

  Inside `enrichWithLocalData`, add `_progressController.add(...)` calls at the START of each tier block. The for-loop already has `if/continue` branches — add one emit per tier check before the relevant lookup:

  ```dart
  for (final item in items) {
    if (item.name.toLowerCase() == 'unknown') {
      enrichedItems.add(item);
      continue;
    }

    final qty = item.weightG > 0 ? 1.0 : _extractQuantity(item.portion);
    final searchName = _extractFoodName(item.portion, item.name);

    debugPrint('RAG: enriching "${item.name}" qty=$qty search="$searchName"');

    // Tier 1
    _progressController.add('Checking custom foods…');
    final customMatch = await db.searchCustomFood(searchName);
    if (customMatch != null) {
      // ... existing Tier 1 code unchanged ...
      continue;
    }

    // Tier 2
    _progressController.add('Enriching from local database…');
    final localMatch = await db.searchLocalFood(searchName);
    if (localMatch != null) {
      // ... existing Tier 2 code unchanged ...
      continue;
    }

    // Tier 2.5
    final n5kOnly = await db.searchN5kIngredient(searchName);
    if (n5kOnly != null) {
      // ... existing Tier 2.5 code unchanged ...
      continue;
    }

    // Tier 3
    _progressController.add('Fetching USDA data…');
    final usdaData = await UsdaFoodService.search(searchName);
    if (usdaData != null) {
      // ... existing Tier 3 code unchanged ...
      continue;
    }

    // Tier 4
    _progressController.add('Finalising…');
    // ... existing Tier 4 code unchanged ...
  }
  ```

  > Only add the `_progressController.add(...)` lines — do NOT change any existing logic.

- [ ] **Step 3.3: Verify compilation**

  Run: `flutter analyze`

  Expected: No errors.

- [ ] **Step 3.4: Commit**

  ```bash
  git add lib/services/food_rag_service.dart
  git commit -m "feat: emit progress stream events from FoodRagService enrichment tiers"
  ```

---

## Task 4: Create FoodScannerState + FoodScannerNotifier (with Unit Tests)

**Files:**
- Create: `lib/viewmodels/food_scanner_viewmodel.dart`
- Create: `test/viewmodels/food_scanner_viewmodel_test.dart`

- [ ] **Step 4.1: Write the failing unit tests first**

  Create `test/viewmodels/food_scanner_viewmodel_test.dart`:

  ```dart
  import 'package:diametrics/src/domain/entities/food_item.dart';
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
  ```

- [ ] **Step 4.2: Run the test to confirm it fails**

  Run: `flutter test test/viewmodels/food_scanner_viewmodel_test.dart`

  Expected: FAIL — `food_scanner_viewmodel.dart` does not exist yet.

- [ ] **Step 4.3: Create the viewmodel**

  Create `lib/viewmodels/food_scanner_viewmodel.dart`:

  ```dart
  import 'dart:async';

  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:get_it/get_it.dart';

  import '../services/food_rag_service.dart';
  import '../src/domain/entities/food_analysis_result.dart';
  import '../src/domain/entities/food_item.dart';
  import '../src/domain/repositories/food_analyzer_repository.dart';

  // ---------------------------------------------------------------------------
  // Provider for FoodAnalyzerRepository — enables test injection via Riverpod
  // ---------------------------------------------------------------------------
  final foodAnalyzerRepositoryProvider = Provider<FoodAnalyzerRepository>(
    (ref) => GetIt.instance<FoodAnalyzerRepository>(),
  );

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  enum FoodScannerStatus { idle, analysing, results, barcodeNotFound, error }

  class FoodScannerState {
    final FoodScannerStatus status;
    final String analysisStatus;
    final List<FoodItem> items;
    final String? imagePath;
    final String? errorMessage;

    const FoodScannerState({
      this.status = FoodScannerStatus.idle,
      this.analysisStatus = '',
      this.items = const [],
      this.imagePath,
      this.errorMessage,
    });

    double get totalCarbs =>
        items.fold(0.0, (s, i) => s + i.carbsGrams);
    double get totalProtein =>
        items.fold(0.0, (s, i) => s + i.proteinGrams);
    double get totalFat =>
        items.fold(0.0, (s, i) => s + i.fatGrams);
    double get totalCalories =>
        items.fold(0.0, (s, i) => s + i.calories);

    FoodScannerState copyWith({
      FoodScannerStatus? status,
      String? analysisStatus,
      List<FoodItem>? items,
      String? imagePath,
      String? errorMessage,
    }) =>
        FoodScannerState(
          status: status ?? this.status,
          analysisStatus: analysisStatus ?? this.analysisStatus,
          items: items ?? this.items,
          imagePath: imagePath ?? this.imagePath,
          errorMessage: errorMessage ?? this.errorMessage,
        );
  }

  // ---------------------------------------------------------------------------
  // Notifier
  // ---------------------------------------------------------------------------
  class FoodScannerNotifier extends AutoDisposeNotifier<FoodScannerState> {
    StreamSubscription<String>? _progressSub;

    @override
    FoodScannerState build() => const FoodScannerState();

    /// Analyses [imagePath] via the Gemini backend + RAG enrichment pipeline.
    /// Subscribes to [FoodRagService.progressStream] to update the progress
    /// label shown in State 2 of [FoodScannerView].
    Future<void> analyseImage(String imagePath) async {
      state = state.copyWith(
        status: FoodScannerStatus.analysing,
        analysisStatus: 'Sending to Gemini…',
        imagePath: imagePath,
      );

      _progressSub?.cancel();
      _progressSub = FoodRagService.progressStream.listen(
        (msg) => state = state.copyWith(analysisStatus: msg),
      );

      try {
        final repo = ref.read(foodAnalyzerRepositoryProvider);
        final result = await repo.analyzeImage(imagePath);
        state = state.copyWith(
          status: FoodScannerStatus.results,
          items: result.items,
        );
      } catch (e) {
        state = state.copyWith(
          status: FoodScannerStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        );
      } finally {
        _progressSub?.cancel();
      }
    }

    /// Called when [BarcodeScannerView] returns a found [FoodItem].
    void submitBarcodeResult(FoodItem item) {
      state = state.copyWith(
        status: FoodScannerStatus.results,
        items: [item],
      );
    }

    /// Called when [BarcodeScannerView] returns null (product not found).
    void handleBarcodeNotFound() {
      state = state.copyWith(status: FoodScannerStatus.barcodeNotFound);
    }

    /// Replaces the item at [index] and recomputes totals (via computed getters).
    void updateItem(int index, FoodItem updated) {
      final newItems = [...state.items];
      newItems[index] = updated;
      state = state.copyWith(items: newItems);
    }

    /// Builds a single-item result from the manual-entry form in State 5.
    void submitManualEntry(FoodItem item) {
      state = state.copyWith(
        status: FoodScannerStatus.results,
        items: [item],
      );
    }

    /// Returns to State 1 (source picker). Used by the app bar back/reset.
    void reset() => state = const FoodScannerState();
  }

  // ---------------------------------------------------------------------------
  // Provider
  // ---------------------------------------------------------------------------
  final foodScannerProvider =
      NotifierProvider.autoDispose<FoodScannerNotifier, FoodScannerState>(
    FoodScannerNotifier.new,
  );
  ```

  > `NotifierProvider.autoDispose` means the state is automatically reset every time `FoodScannerView` is pushed — no stale data from a previous session.

- [ ] **Step 4.4: Add missing import for FoodAnalysisResult in the test**

  At the top of `test/viewmodels/food_scanner_viewmodel_test.dart`, add:

  ```dart
  import 'package:diametrics/src/domain/entities/food_analysis_result.dart';
  ```

- [ ] **Step 4.5: Run tests to confirm they pass**

  Run: `flutter test test/viewmodels/food_scanner_viewmodel_test.dart`

  Expected: All 7 tests PASS.

- [ ] **Step 4.6: Commit**

  ```bash
  git add lib/viewmodels/food_scanner_viewmodel.dart \
          test/viewmodels/food_scanner_viewmodel_test.dart
  git commit -m "feat: FoodScannerNotifier with state machine and unit tests"
  ```

---

## Task 5: Create FoodItemEditSheet (with Widget Test)

**Files:**
- Create: `lib/views/food_scanner/food_item_edit_sheet.dart`
- Create: `test/views/food_item_edit_sheet_test.dart`

- [ ] **Step 5.1: Write the failing widget test**

  Create `test/views/food_item_edit_sheet_test.dart`:

  ```dart
  import 'package:diametrics/src/domain/entities/food_item.dart';
  import 'package:diametrics/views/food_scanner/food_item_edit_sheet.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';

  void main() {
    const item = FoodItem(
      name: 'Chicken Curry',
      portion: '1 bowl',
      carbsGrams: 45.0,
      proteinGrams: 28.0,
      fatGrams: 12.0,
      calories: 396.0,
      weightG: 300.0,
      source: 'USDA+N5K',
    );

    testWidgets('displays item values in text fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FoodItemEditSheet(item: item, onSave: (_) {}),
        ),
      ));

      expect(find.widgetWithText(TextFormField, 'Chicken Curry'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '45.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '28.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '12.0'), findsOneWidget);
    });

    testWidgets('onSave callback receives updated values', (tester) async {
      FoodItem? savedItem;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FoodItemEditSheet(
            item: item,
            onSave: (updated) => savedItem = updated,
          ),
        ),
      ));

      // Edit the carbs field
      await tester.enterText(
        find.widgetWithText(TextFormField, '45.0'),
        '55.0',
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(savedItem, isNotNull);
      expect(savedItem!.carbsGrams, 55.0);
      expect(savedItem!.weightG, 300.0); // weightG preserved
      expect(savedItem!.name, 'Chicken Curry'); // unchanged fields preserved
    });
  }
  ```

- [ ] **Step 5.2: Run the test to confirm it fails**

  Run: `flutter test test/views/food_item_edit_sheet_test.dart`

  Expected: FAIL — `food_item_edit_sheet.dart` does not exist yet.

- [ ] **Step 5.3: Create the FoodItemEditSheet widget**

  Create `lib/views/food_scanner/food_item_edit_sheet.dart`:

  ```dart
  import 'package:flutter/material.dart';

  import '../../src/domain/entities/food_item.dart';

  class FoodItemEditSheet extends StatefulWidget {
    final FoodItem item;
    final void Function(FoodItem updated) onSave;

    const FoodItemEditSheet({
      required this.item,
      required this.onSave,
      super.key,
    });

    @override
    State<FoodItemEditSheet> createState() => _FoodItemEditSheetState();
  }

  class _FoodItemEditSheetState extends State<FoodItemEditSheet> {
    late final TextEditingController _nameCtrl;
    late final TextEditingController _portionCtrl;
    late final TextEditingController _weightCtrl;
    late final TextEditingController _carbsCtrl;
    late final TextEditingController _proteinCtrl;
    late final TextEditingController _fatCtrl;
    late final TextEditingController _kcalCtrl;

    @override
    void initState() {
      super.initState();
      final i = widget.item;
      _nameCtrl = TextEditingController(text: i.name);
      _portionCtrl = TextEditingController(text: i.portion);
      _weightCtrl = TextEditingController(
          text: i.weightG > 0 ? i.weightG.toStringAsFixed(0) : '');
      _carbsCtrl = TextEditingController(text: i.carbsGrams.toStringAsFixed(1));
      _proteinCtrl =
          TextEditingController(text: i.proteinGrams.toStringAsFixed(1));
      _fatCtrl = TextEditingController(text: i.fatGrams.toStringAsFixed(1));
      _kcalCtrl = TextEditingController(text: i.calories.toStringAsFixed(0));
    }

    @override
    void dispose() {
      _nameCtrl.dispose();
      _portionCtrl.dispose();
      _weightCtrl.dispose();
      _carbsCtrl.dispose();
      _proteinCtrl.dispose();
      _fatCtrl.dispose();
      _kcalCtrl.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2d3a),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Read-only macro summary
              _MacroSummaryRow(item: widget.item),
              const SizedBox(height: 20),
              // Editable fields
              _EditField(ctrl: _nameCtrl, label: 'Food Name'),
              const SizedBox(height: 12),
              _EditField(ctrl: _portionCtrl, label: 'Portion'),
              const SizedBox(height: 12),
              _EditField(
                ctrl: _weightCtrl,
                label: 'Weight (g)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _EditField(
                    ctrl: _carbsCtrl,
                    label: 'Carbs (g)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EditField(
                    ctrl: _proteinCtrl,
                    label: 'Protein (g)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _EditField(
                    ctrl: _fatCtrl,
                    label: 'Fat (g)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EditField(
                    ctrl: _kcalCtrl,
                    label: 'kcal',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4a9eff),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      );
    }

    void _onSave() {
      final i = widget.item;
      final updated = i.copyWith(
        name: _nameCtrl.text.trim().isNotEmpty
            ? _nameCtrl.text.trim()
            : i.name,
        portion: _portionCtrl.text.trim().isNotEmpty
            ? _portionCtrl.text.trim()
            : i.portion,
        weightG: double.tryParse(_weightCtrl.text) ?? i.weightG,
        carbsGrams: double.tryParse(_carbsCtrl.text) ?? i.carbsGrams,
        proteinGrams: double.tryParse(_proteinCtrl.text) ?? i.proteinGrams,
        fatGrams: double.tryParse(_fatCtrl.text) ?? i.fatGrams,
        calories: double.tryParse(_kcalCtrl.text) ?? i.calories,
      );
      widget.onSave(updated);
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Private sub-widgets
  // ---------------------------------------------------------------------------

  class _MacroSummaryRow extends StatelessWidget {
    final FoodItem item;
    const _MacroSummaryRow({required this.item});

    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13151f),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          _MacroCell(
            label: 'Carbs',
            value: item.carbsGrams.toStringAsFixed(1),
            unit: 'g',
            color: const Color(0xFF4a9eff),
          ),
          _MacroCell(
            label: 'Protein',
            value: item.proteinGrams.toStringAsFixed(1),
            unit: 'g',
            color: const Color(0xFFc8cfe0),
          ),
          _MacroCell(
            label: 'Fat',
            value: item.fatGrams.toStringAsFixed(1),
            unit: 'g',
            color: const Color(0xFFc8cfe0),
          ),
          _MacroCell(
            label: 'kcal',
            value: item.calories.toStringAsFixed(0),
            unit: '',
            color: const Color(0xFFc8cfe0),
          ),
        ]),
      );
    }
  }

  class _MacroCell extends StatelessWidget {
    final String label;
    final String value;
    final String unit;
    final Color color;

    const _MacroCell({
      required this.label,
      required this.value,
      required this.unit,
      required this.color,
    });

    @override
    Widget build(BuildContext context) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(children: [
            Text(
              label,
              style: TextStyle(
                color: color == const Color(0xFF4a9eff)
                    ? color
                    : const Color(0xFF8892aa),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      );
    }
  }

  class _EditField extends StatelessWidget {
    final TextEditingController ctrl;
    final String label;
    final TextInputType keyboardType;

    const _EditField({
      required this.ctrl,
      required this.label,
      this.keyboardType = TextInputType.text,
    });

    @override
    Widget build(BuildContext context) {
      return TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8892aa), fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF1a1d27),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4a9eff)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
    }
  }
  ```

- [ ] **Step 5.4: Run the widget tests to confirm they pass**

  Run: `flutter test test/views/food_item_edit_sheet_test.dart`

  Expected: Both tests PASS.

- [ ] **Step 5.5: Commit**

  ```bash
  git add lib/views/food_scanner/food_item_edit_sheet.dart \
          test/views/food_item_edit_sheet_test.dart
  git commit -m "feat: FoodItemEditSheet bottom sheet with widget tests"
  ```

---

## Task 6: Create FoodScannerView

**Files:**
- Create: `lib/views/food_scanner/food_scanner_view.dart`
- Create: `test/views/food_scanner_view_test.dart`

- [ ] **Step 6.0: Pre-requisite — add route constant before creating FoodScannerView**

  `FoodScannerView` imports `Routes.logMealFoodScanner`. Add it to `lib/router/route_names.dart` now (full router registration happens in Task 7):

  ```dart
  static const logMealFoodScanner = '/log/meal/food-scanner';
  ```

- [ ] **Step 6.1: Write the failing widget tests**

  Create `test/views/food_scanner_view_test.dart`:

  ```dart
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

  void main() {
    late MockFoodAnalyzerRepository mockRepo;

    setUp(() => mockRepo = MockFoodAnalyzerRepository());

    testWidgets('State 1: shows source picker buttons', (tester) async {
      await tester.pumpWidget(_wrap(const FoodScannerView(),
          overrides: [
            foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)
          ]));
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Scan Barcode'), findsOneWidget);
    });

    testWidgets('State 2: shows progress indicator and status text',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderScope(
          overrides: [
            foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
            foodScannerProvider.overrideWith(() {
              final notifier = FoodScannerNotifier();
              return notifier;
            }),
          ],
          child: const MaterialApp(home: FoodScannerView()),
        ),
      ));

      // Manually put notifier in analysing state
      final container = ProviderScope.containerOf(
          tester.element(find.byType(FoodScannerView)));
      container.read(foodScannerProvider.notifier).state =
          const FoodScannerState(
        status: FoodScannerStatus.analysing,
        analysisStatus: 'Sending to Gemini…',
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

      await tester.pumpWidget(ProviderScope(
        overrides: [
          foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: FoodScannerView()),
      ));

      final container = ProviderScope.containerOf(
          tester.element(find.byType(FoodScannerView)));
      container.read(foodScannerProvider.notifier).submitBarcodeResult(item);
      await tester.pump();

      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Confirm & Add to Meal'), findsOneWidget);
    });

    testWidgets('State 5: shows not-found message and recovery options',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: FoodScannerView()),
      ));

      final container = ProviderScope.containerOf(
          tester.element(find.byType(FoodScannerView)));
      container.read(foodScannerProvider.notifier).handleBarcodeNotFound();
      await tester.pump();

      expect(find.text('Product not found'), findsOneWidget);
      expect(find.text('Take a Photo Instead'), findsOneWidget);
      expect(find.text('Add to Meal'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 6.2: Run the test to confirm it fails**

  Run: `flutter test test/views/food_scanner_view_test.dart`

  Expected: FAIL — `food_scanner_view.dart` does not exist yet.

- [ ] **Step 6.3: Create FoodScannerView**

  Create `lib/views/food_scanner/food_scanner_view.dart`:

  ```dart
  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:lucide_icons/lucide_icons.dart';

  import '../../router/route_names.dart';
  import '../../src/domain/entities/food_item.dart';
  import '../../src/domain/entities/food_scanner_result.dart';
  import '../../viewmodels/food_scanner_viewmodel.dart';
  import 'food_item_edit_sheet.dart';

  class FoodScannerView extends ConsumerStatefulWidget {
    const FoodScannerView({super.key});

    @override
    ConsumerState<FoodScannerView> createState() => _FoodScannerViewState();
  }

  class _FoodScannerViewState extends ConsumerState<FoodScannerView> {
    final _picker = ImagePicker();
    final _manualFormKey = GlobalKey<FormState>();
    final _manualNameCtrl = TextEditingController();
    final _manualCarbsCtrl = TextEditingController();
    final _manualProteinCtrl = TextEditingController();
    final _manualFatCtrl = TextEditingController();
    final _manualKcalCtrl = TextEditingController();

    @override
    void dispose() {
      _manualNameCtrl.dispose();
      _manualCarbsCtrl.dispose();
      _manualProteinCtrl.dispose();
      _manualFatCtrl.dispose();
      _manualKcalCtrl.dispose();
      super.dispose();
    }

    // ── Navigation helpers ────────────────────────────────────────────────────

    Future<void> _onTakePhoto() async {
      final xFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (xFile == null || !mounted) return;
      ref.read(foodScannerProvider.notifier).analyseImage(xFile.path);
    }

    Future<void> _onGallery() async {
      final xFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (xFile == null || !mounted) return;
      ref.read(foodScannerProvider.notifier).analyseImage(xFile.path);
    }

    Future<void> _onBarcodePressed() async {
      final result = await context.push<FoodItem>(Routes.logMealBarcode);
      if (!mounted) return;
      if (result != null) {
        ref.read(foodScannerProvider.notifier).submitBarcodeResult(result);
      } else {
        ref.read(foodScannerProvider.notifier).handleBarcodeNotFound();
      }
    }

    void _openEditSheet(int index, FoodItem item) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF13151f),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => FoodItemEditSheet(
          item: item,
          onSave: (updated) =>
              ref.read(foodScannerProvider.notifier).updateItem(index, updated),
        ),
      );
    }

    void _confirm(FoodScannerState state) {
      final result = FoodScannerResult(
        items: state.items,
        totalCarbs: state.totalCarbs,
        totalProtein: state.totalProtein,
        totalFat: state.totalFat,
        totalCalories: state.totalCalories,
      );
      context.pop(result);
    }

    void _submitManualEntry() {
      if (!_manualFormKey.currentState!.validate()) return;
      final item = FoodItem(
        name: _manualNameCtrl.text.trim(),
        portion: '1 serving',
        carbsGrams: double.tryParse(_manualCarbsCtrl.text) ?? 0,
        proteinGrams: double.tryParse(_manualProteinCtrl.text) ?? 0,
        fatGrams: double.tryParse(_manualFatCtrl.text) ?? 0,
        calories: double.tryParse(_manualKcalCtrl.text) ?? 0,
        source: 'Manual Entry',
      );
      ref.read(foodScannerProvider.notifier).submitManualEntry(item);
    }

    // ── Build ─────────────────────────────────────────────────────────────────

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(foodScannerProvider);

      return Scaffold(
        backgroundColor: const Color(0xFF0D0F1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0F1A),
          foregroundColor: const Color(0xFFc8cfe0),
          elevation: 0,
          title: const Text(
            'Food Scanner',
            style: TextStyle(
              color: Color(0xFFc8cfe0),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(null),
          ),
          actions: [
            if (state.status == FoodScannerStatus.results)
              TextButton(
                onPressed: () =>
                    ref.read(foodScannerProvider.notifier).reset(),
                child: const Text(
                  'Start Over',
                  style: TextStyle(color: Color(0xFF8892aa), fontSize: 13),
                ),
              ),
          ],
        ),
        body: switch (state.status) {
          FoodScannerStatus.idle => _buildSourcePicker(),
          FoodScannerStatus.analysing => _buildAnalysing(state),
          FoodScannerStatus.results => _buildResults(state),
          FoodScannerStatus.barcodeNotFound => _buildBarcodeNotFound(),
          FoodScannerStatus.error => _buildError(state),
        },
      );
    }

    // ── State 1: Source Picker ────────────────────────────────────────────────

    Widget _buildSourcePicker() {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Add Food',
              style: TextStyle(
                color: Color(0xFFc8cfe0),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how to identify your food',
              style: TextStyle(color: Color(0xFF8892aa), fontSize: 14),
            ),
            const SizedBox(height: 40),
            _SourceButton(
              icon: LucideIcons.camera,
              label: 'Take Photo',
              onTap: _onTakePhoto,
            ),
            const SizedBox(height: 12),
            _SourceButton(
              icon: LucideIcons.image,
              label: 'Choose from Gallery',
              onTap: _onGallery,
            ),
            const SizedBox(height: 12),
            _SourceButton(
              icon: LucideIcons.barcode,
              label: 'Scan Barcode',
              onTap: _onBarcodePressed,
            ),
          ],
        ),
      );
    }

    // ── State 2: Analysing ────────────────────────────────────────────────────

    Widget _buildAnalysing(FoodScannerState state) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF4a9eff),
                strokeWidth: 2,
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  state.analysisStatus,
                  key: ValueKey(state.analysisStatus),
                  style: const TextStyle(
                    color: Color(0xFF8892aa),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── State 3: Results ──────────────────────────────────────────────────────

    Widget _buildResults(FoodScannerState state) {
      return Column(
        children: [
          if (state.imagePath != null)
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.file(
                File(state.imagePath!),
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _FoodItemCard(
                  item: item,
                  onTap: () => _openEditSheet(index, item),
                );
              },
            ),
          ),
          _buildTotalsFooter(state),
        ],
      );
    }

    Widget _buildTotalsFooter(FoodScannerState state) {
      return Container(
        color: const Color(0xFF13151f),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            Row(children: [
              _TotalCell(
                label: 'Total Carbs',
                value: state.totalCarbs.toStringAsFixed(1),
                unit: 'g',
                isCarbs: true,
              ),
              _TotalCell(
                label: 'Total Protein',
                value: state.totalProtein.toStringAsFixed(1),
                unit: 'g',
                isCarbs: false,
              ),
              _TotalCell(
                label: 'Total Fat',
                value: state.totalFat.toStringAsFixed(1),
                unit: 'g',
                isCarbs: false,
              ),
              _TotalCell(
                label: 'kcal',
                value: state.totalCalories.toStringAsFixed(0),
                unit: '',
                isCarbs: false,
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _confirm(state),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4a9eff),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm & Add to Meal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // ── State 5: Barcode Not Found ────────────────────────────────────────────

    Widget _buildBarcodeNotFound() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Icon(
              LucideIcons.scanLine,
              color: Color(0xFF8892aa),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Product not found',
              style: TextStyle(
                color: Color(0xFFc8cfe0),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This product isn\'t in our database yet.',
              style: TextStyle(color: Color(0xFF8892aa), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.camera, size: 16),
              label: const Text('Take a Photo Instead'),
              onPressed: _onTakePhoto,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFc8cfe0),
                side: const BorderSide(color: Color(0xFF2a2d3a)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '— or enter manually —',
              style: TextStyle(color: Color(0xFF8892aa), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildManualEntryForm(),
          ],
        ),
      );
    }

    Widget _buildManualEntryForm() {
      final inputDecoration = InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1a1d27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4a9eff)),
        ),
        labelStyle:
            const TextStyle(color: Color(0xFF8892aa), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

      return Form(
        key: _manualFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _manualNameCtrl,
              style: const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
              decoration:
                  inputDecoration.copyWith(labelText: 'Food Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _manualCarbsCtrl,
                  keyboardType: TextInputType.number,
                  style:
                      const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                  decoration:
                      inputDecoration.copyWith(labelText: 'Carbs (g)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _manualProteinCtrl,
                  keyboardType: TextInputType.number,
                  style:
                      const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                  decoration:
                      inputDecoration.copyWith(labelText: 'Protein (g)'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _manualFatCtrl,
                  keyboardType: TextInputType.number,
                  style:
                      const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                  decoration: inputDecoration.copyWith(labelText: 'Fat (g)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _manualKcalCtrl,
                  keyboardType: TextInputType.number,
                  style:
                      const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                  decoration:
                      inputDecoration.copyWith(labelText: 'kcal'),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitManualEntry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4a9eff),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add to Meal'),
            ),
          ],
        ),
      );
    }

    // ── Error state ───────────────────────────────────────────────────────────

    Widget _buildError(FoodScannerState state) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                color: Color(0xFFef5350),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Something went wrong.',
                style:
                    const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    ref.read(foodScannerProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFc8cfe0),
                  side: const BorderSide(color: Color(0xFF2a2d3a)),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private sub-widgets (file-scoped)
  // ---------------------------------------------------------------------------

  class _SourceButton extends StatelessWidget {
    final IconData icon;
    final String label;
    final VoidCallback onTap;

    const _SourceButton({
      required this.icon,
      required this.label,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return Material(
        color: const Color(0xFF13151f),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(children: [
              Icon(icon, color: const Color(0xFF4a9eff), size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFc8cfe0),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                LucideIcons.chevronRight,
                color: Color(0xFF8892aa),
                size: 16,
              ),
            ]),
          ),
        ),
      );
    }
  }

  class _FoodItemCard extends StatelessWidget {
    final FoodItem item;
    final VoidCallback onTap;

    const _FoodItemCard({required this.item, required this.onTap});

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13151f),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1e2130)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row + source badge + edit icon
              Row(children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFFc8cfe0),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SourceBadge(source: item.source),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.pencil,
                  color: Color(0xFF8892aa),
                  size: 14,
                ),
              ]),
              const SizedBox(height: 4),
              // Portion + weight
              Text(
                item.weightG > 0
                    ? '${item.portion} · ${item.weightG.toStringAsFixed(0)}g'
                    : item.portion,
                style: const TextStyle(
                  color: Color(0xFF8892aa),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              // Macro inline row (horizontally scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(children: [
                    _MacroInlineCell(
                      label: 'Carbs',
                      value: item.carbsGrams.toStringAsFixed(1),
                      unit: 'g',
                      isCarbs: true,
                    ),
                    _MacroInlineCell(
                      label: 'Protein',
                      value: item.proteinGrams.toStringAsFixed(1),
                      unit: 'g',
                      isCarbs: false,
                    ),
                    _MacroInlineCell(
                      label: 'Fat',
                      value: item.fatGrams.toStringAsFixed(1),
                      unit: 'g',
                      isCarbs: false,
                    ),
                    _MacroInlineCell(
                      label: 'kcal',
                      value: item.calories.toStringAsFixed(0),
                      unit: '',
                      isCarbs: false,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _MacroInlineCell extends StatelessWidget {
    final String label;
    final String value;
    final String unit;
    final bool isCarbs;

    const _MacroInlineCell({
      required this.label,
      required this.value,
      required this.unit,
      required this.isCarbs,
    });

    @override
    Widget build(BuildContext context) {
      final color =
          isCarbs ? const Color(0xFF4a9eff) : const Color(0xFFc8cfe0);
      final labelColor =
          isCarbs ? const Color(0xFF4a9eff) : const Color(0xFF8892aa);

      return Container(
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: const Color(0xFF1e2130),
              width: label == 'Carbs' ? 0 : 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ]),
            ),
          ],
        ),
      );
    }
  }

  class _TotalCell extends StatelessWidget {
    final String label;
    final String value;
    final String unit;
    final bool isCarbs;

    const _TotalCell({
      required this.label,
      required this.value,
      required this.unit,
      required this.isCarbs,
    });

    @override
    Widget build(BuildContext context) {
      final color =
          isCarbs ? const Color(0xFF4a9eff) : const Color(0xFFc8cfe0);
      final labelColor =
          isCarbs ? const Color(0xFF4a9eff) : const Color(0xFF8892aa);

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: isCarbs ? 22 : 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ]),
            ),
          ],
        ),
      );
    }
  }

  class _SourceBadge extends StatelessWidget {
    final String source;
    const _SourceBadge({required this.source});

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1d27),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF2a2d3a)),
        ),
        child: Text(
          source,
          style: const TextStyle(
            color: Color(0xFF8892aa),
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 6.4: Run widget tests to confirm they pass**

  Run: `flutter test test/views/food_scanner_view_test.dart`

  Expected: All 4 tests PASS.

- [ ] **Step 6.5: Commit**

  ```bash
  git add lib/views/food_scanner/food_scanner_view.dart \
          test/views/food_scanner_view_test.dart
  git commit -m "feat: FoodScannerView — all 5 states with widget tests"
  ```

---

## Task 7: Register FoodScannerView Route

**Files:**
- Modify: `lib/router/route_names.dart`
- Modify: `lib/router/app_router.dart`

- [ ] **Step 7.1: Add route constant**

  In `lib/router/route_names.dart`, add inside the `Routes` class (after `logMealBarcode`):

  ```dart
  static const logMealFoodScanner = '/log/meal/food-scanner';
  ```

- [ ] **Step 7.2: Register the route in app_router.dart**

  Open `lib/router/app_router.dart`. Find the `GoRoute` with path matching `/log/meal` (or the equivalent that contains the `barcode` child route). Add `food-scanner` as a sibling child route:

  ```dart
  GoRoute(
    path: 'food-scanner',
    builder: (context, state) => const FoodScannerView(),
  ),
  ```

  Add the import at the top of `app_router.dart`:

  ```dart
  import '../views/food_scanner/food_scanner_view.dart';
  ```

- [ ] **Step 7.3: Verify the build**

  Run: `flutter analyze`

  Expected: No errors.

- [ ] **Step 7.4: Commit**

  ```bash
  git add lib/router/route_names.dart lib/router/app_router.dart
  git commit -m "feat: register /log/meal/food-scanner route"
  ```

---

## Task 8: Refactor MealWizardView

**Files:**
- Modify: `lib/views/logging/meal_wizard_view.dart`

- [ ] **Step 8.1: Identify the code to remove**

  Open `lib/views/logging/meal_wizard_view.dart`. Locate and DELETE the following methods and their associated state variables:

  | To remove | Why |
  |---|---|
  | `_buildCameraArea()` | Replaced by FoodScannerView's source picker |
  | `_showSourceSheet()` | Replaced by FoodScannerView's source picker |
  | `_runAnalysis()` | Replaced by FoodScannerNotifier.analyseImage |
  | `_openBarcodeScanner()` | FoodScannerView now handles barcode routing |
  | State fields: `_imageFile`, `_awaitingConfirm`, `_analysisResult`, `_analysisError`, `_isAnalyzing` | Owned by FoodScannerView |
  | The 72×72 thumbnail widget inside the build method | Replaced by FoodScannerView's full-height thumbnail |
  | The compressed items list section (non-editable) | Replaced by FoodScannerView's results state |

  > Read the full file before deleting. Use the method names above to locate each block. If a removed field is referenced elsewhere in the view (e.g. in `_buildMacroFields()`), update those references to remove the dependency.

- [ ] **Step 8.2: Add the replacement scanning method and button**

  Add these two methods to `MealWizardView` (or its `_MealWizardViewState`):

  ```dart
  import 'package:diametrics/src/domain/entities/food_scanner_result.dart';
  import 'package:diametrics/views/food_scanner/food_scanner_view.dart';
  // (add to existing imports at the top of the file)
  ```

  ```dart
  /// Pushes FoodScannerView and applies the confirmed result to the meal form.
  Future<void> _openFoodScanner() async {
    final result = await context.push<FoodScannerResult>(
      Routes.logMealFoodScanner,
    );
    if (result == null || !mounted) return;

    // Apply totals from the scanner result to the wizard's macro fields
    ref.read(loggingWizardProvider.notifier).updateMealMacros(
      carbs: result.totalCarbs,
      proteins: result.totalProtein,
      fats: result.totalFat,
      calories: result.totalCalories,
    );

    // Sync text controllers so the UI reflects the new values
    _carbsCtrl.text = result.totalCarbs.toStringAsFixed(1);
    _proteinCtrl.text = result.totalProtein.toStringAsFixed(1);
    _fatsCtrl.text = result.totalFat.toStringAsFixed(1);

    if (mounted) {
      final itemNames = result.items.map((i) => i.name).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.items.length} item(s) added: $itemNames',
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF2D6A4F),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Simple scan-food button — replaces the old camera area widget.
  Widget _buildFoodScanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(LucideIcons.scanLine, size: 18),
        label: const Text('Scan Food'),
        onPressed: _openFoodScanner,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4a9eff),
          side: const BorderSide(color: Color(0xFF4a9eff)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  ```

  Replace every call site of the old `_buildCameraArea()` in the build tree with `_buildFoodScanButton()`.

- [ ] **Step 8.3: Add missing imports if needed**

  If `LucideIcons` is not already imported in `meal_wizard_view.dart`, add:

  ```dart
  import 'package:lucide_icons/lucide_icons.dart';
  ```

- [ ] **Step 8.4: Verify compilation and run all tests**

  Run: `flutter analyze && flutter test`

  Expected: No errors, all tests pass.

- [ ] **Step 8.5: Commit**

  ```bash
  git add lib/views/logging/meal_wizard_view.dart
  git commit -m "refactor: replace embedded food scanning in MealWizardView with FoodScannerView push"
  ```

---

## Task 9: Regression Test — weightG Preserved Through Full Flow

**Files:**
- Create: `test/integration/food_scanner_weight_regression_test.dart`

This test guards against the specific regression where `weightG` was silently lost when a `FoodItem` was saved from a scan result to `MealLog`.

- [ ] **Step 9.1: Write the regression test**

  Create `test/integration/food_scanner_weight_regression_test.dart`:

  ```dart
  import 'package:diametrics/src/domain/entities/food_item.dart';
  import 'package:diametrics/src/domain/entities/food_scanner_result.dart';
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
  }
  ```

- [ ] **Step 9.2: Run the regression tests**

  Run: `flutter test test/integration/food_scanner_weight_regression_test.dart`

  Expected: All 4 tests PASS.

- [ ] **Step 9.3: Run the full test suite**

  Run: `flutter test`

  Expected: All tests PASS.

- [ ] **Step 9.4: Commit**

  ```bash
  git add test/integration/food_scanner_weight_regression_test.dart
  git commit -m "test: weightG regression tests for FoodScannerView flow"
  ```

---

## Self-Review Checklist

After completing all tasks, verify:

- [ ] `flutter analyze` — zero errors
- [ ] `flutter test` — all tests green
- [ ] State 1 shows three source buttons in the app
- [ ] State 2 shows live progress text changing during enrichment
- [ ] State 3 items are tappable and open `FoodItemEditSheet`
- [ ] State 3 "Confirm & Add to Meal" pops `FoodScannerResult` to `MealWizardView`
- [ ] State 5 manual entry form submits to State 3 results
- [ ] `MealWizardView` no longer contains `_buildCameraArea`, `_runAnalysis`, or `_showSourceSheet`
- [ ] `FoodAnalysisResult` has `totalProtein`, `totalFat`, `confidenceScore` populated
- [ ] `weightG` regression tests pass
