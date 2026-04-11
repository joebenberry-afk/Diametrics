import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../services/food_rag_service.dart';
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
    state = FoodScannerState(
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
    state = FoodScannerState(
      status: FoodScannerStatus.results,
      items: [item],
    );
  }

  /// Called when [BarcodeScannerView] returns null (product not found).
  void handleBarcodeNotFound() {
    state = FoodScannerState(status: FoodScannerStatus.barcodeNotFound);
  }

  /// Replaces the item at [index] and recomputes totals (via computed getters).
  void updateItem(int index, FoodItem updated) {
    final newItems = [...state.items];
    newItems[index] = updated;
    state = state.copyWith(items: newItems);
  }

  /// Builds a single-item result from the manual-entry form in State 5.
  void submitManualEntry(FoodItem item) {
    state = FoodScannerState(
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
