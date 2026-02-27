import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import '../models/projection_result.dart';
import '../services/glucose_projection_service.dart';
import 'health_data_viewmodel.dart';

// A state class to hold the temporary data during wizard entry
class LoggingWizardState {
  // Glucose Wizard
  final double? pendingGlucoseValue;
  final String glucoseUnit;
  final String glucoseContext;

  // Meal Wizard
  final double? pendingCarbs;
  final double? pendingFiber;
  final double? pendingProteins;
  final double? pendingFats;
  final bool containsAlcohol;
  final bool containsCaffeine;
  final String mealType;

  // Pre-meal glucose gate (used by Meal Wizard)
  final double? preMealGlucose;
  final bool hasAutoDetectedGlucose;

  // Medication Wizard
  final double? pendingMedicationUnits;
  final String medicationType;

  final bool isSubmitting;
  final String? error;

  LoggingWizardState({
    this.pendingGlucoseValue,
    this.glucoseUnit = 'mg/dL',
    this.glucoseContext = 'pre_meal',
    this.pendingCarbs,
    this.pendingFiber,
    this.pendingProteins,
    this.pendingFats,
    this.containsAlcohol = false,
    this.containsCaffeine = false,
    this.mealType = 'lunch',
    this.preMealGlucose,
    this.hasAutoDetectedGlucose = false,
    this.pendingMedicationUnits,
    this.medicationType = 'rapid_acting_insulin',
    this.isSubmitting = false,
    this.error,
  });

  LoggingWizardState copyWith({
    double? pendingGlucoseValue,
    String? glucoseUnit,
    String? glucoseContext,
    double? pendingCarbs,
    double? pendingFiber,
    double? pendingProteins,
    double? pendingFats,
    bool? containsAlcohol,
    bool? containsCaffeine,
    String? mealType,
    double? preMealGlucose,
    bool? hasAutoDetectedGlucose,
    double? pendingMedicationUnits,
    String? medicationType,
    bool? isSubmitting,
    String? error,
  }) {
    return LoggingWizardState(
      pendingGlucoseValue: pendingGlucoseValue ?? this.pendingGlucoseValue,
      glucoseUnit: glucoseUnit ?? this.glucoseUnit,
      glucoseContext: glucoseContext ?? this.glucoseContext,
      pendingCarbs: pendingCarbs ?? this.pendingCarbs,
      pendingFiber: pendingFiber ?? this.pendingFiber,
      pendingProteins: pendingProteins ?? this.pendingProteins,
      pendingFats: pendingFats ?? this.pendingFats,
      containsAlcohol: containsAlcohol ?? this.containsAlcohol,
      containsCaffeine: containsCaffeine ?? this.containsCaffeine,
      mealType: mealType ?? this.mealType,
      preMealGlucose: preMealGlucose ?? this.preMealGlucose,
      hasAutoDetectedGlucose:
          hasAutoDetectedGlucose ?? this.hasAutoDetectedGlucose,
      pendingMedicationUnits:
          pendingMedicationUnits ?? this.pendingMedicationUnits,
      medicationType: medicationType ?? this.medicationType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

class LoggingWizardViewModel extends StateNotifier<LoggingWizardState> {
  final Ref ref;
  final _uuid = const Uuid();

  LoggingWizardViewModel(this.ref) : super(LoggingWizardState());

  // --- Glucose Adjustments ---
  void updateGlucoseValue(double value) =>
      state = state.copyWith(pendingGlucoseValue: value);
  void updateGlucoseContext(String context) =>
      state = state.copyWith(glucoseContext: context);

  // --- Pre-meal Glucose Gate ---

  /// Called when the MealWizard opens. Checks the DB for a pre_meal glucose
  /// reading logged within the last 30 minutes and auto-fills it.
  Future<void> checkRecentPreMealGlucose() async {
    final repo = ref.read(healthDataRepositoryProvider);
    final recent = await repo.getRecentGlucoseByContext(
      'pre_meal',
      const Duration(minutes: 30),
    );
    if (recent != null) {
      state = state.copyWith(
        preMealGlucose: recent.value,
        hasAutoDetectedGlucose: true,
      );
    }
  }

  /// Manual entry of pre-meal glucose from the meal wizard UI.
  void setPreMealGlucose(double value) {
    state = state.copyWith(
      preMealGlucose: value,
      hasAutoDetectedGlucose: false,
    );
  }

  // --- Meal Adjustments ---
  void updateMealMacros({
    double? carbs,
    double? fiber,
    double? proteins,
    double? fats,
  }) {
    state = state.copyWith(
      pendingCarbs: carbs,
      pendingFiber: fiber,
      pendingProteins: proteins,
      pendingFats: fats,
    );
  }

  void toggleAlcohol(bool val) => state = state.copyWith(containsAlcohol: val);
  void toggleCaffeine(bool val) =>
      state = state.copyWith(containsCaffeine: val);
  void updateMealType(String type) => state = state.copyWith(mealType: type);

  // --- Medication Adjustments ---
  void updateMedicationUnits(double units) =>
      state = state.copyWith(pendingMedicationUnits: units);
  void updateMedicationType(String type) =>
      state = state.copyWith(medicationType: type);

  // --- IOB Calculation ---

  /// Calculates Insulin-on-Board from rapid-acting insulin logged in the
  /// last 4 hours, using a simple linear decay model (DIA = 240 min).
  Future<double> _calculateIOB() async {
    final repo = ref.read(healthDataRepositoryProvider);
    final recentMeds = await repo.getRecentMedicationLogs(
      const Duration(hours: 4),
    );
    double iob = 0.0;
    final now = DateTime.now();
    for (final med in recentMeds) {
      if (med.medicationType != 'rapid_acting_insulin') continue;
      final elapsedMin = now.difference(med.timestamp).inMinutes;
      final remaining = (1.0 - elapsedMin / 240.0).clamp(0.0, 1.0);
      iob += med.units * remaining;
    }
    return iob;
  }

  // --- Submission Logic ---
  Future<bool> saveGlucoseLog() async {
    if (state.pendingGlucoseValue == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final log = GlucoseLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        value: state.pendingGlucoseValue!,
        unit: state.glucoseUnit,
        context: state.glucoseContext,
      );

      await ref.read(healthDataRepositoryProvider).addGlucoseLog(log);
      ref.invalidate(glucoseLogsProvider);
      state = LoggingWizardState(); // Reset wizard
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// Saves the meal log, records the pre-meal glucose reading (if manually
  /// entered), then runs the Phase 1 Hovorka glucose projection.
  ///
  /// Returns the [ProjectionResult] on success, or `null` on failure.
  Future<ProjectionResult?> saveMealWithProjection({
    double weightKg = 70.0,
  }) async {
    if (state.preMealGlucose == null ||
        state.pendingCarbs == null ||
        state.pendingProteins == null ||
        state.pendingFats == null) {
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final repo = ref.read(healthDataRepositoryProvider);

      // 1. Save the pre-meal glucose reading if user entered it manually
      //    (auto-detected readings are already in the DB)
      if (!state.hasAutoDetectedGlucose) {
        final glucoseLog = GlucoseLog(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          value: state.preMealGlucose!,
          unit: 'mg/dL',
          context: 'pre_meal',
        );
        await repo.addGlucoseLog(glucoseLog);
        ref.invalidate(glucoseLogsProvider);
      }

      // 2. Save the meal log
      final mealLog = MealLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        carbohydrates: state.pendingCarbs!,
        dietaryFiber: state.pendingFiber ?? 0.0,
        proteins: state.pendingProteins!,
        fats: state.pendingFats!,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        mealType: state.mealType,
      );
      await repo.addMealLog(mealLog);
      ref.invalidate(mealLogsProvider);

      // 3. Calculate IOB and run the projection
      final iob = await _calculateIOB();
      final result = GlucoseProjectionService.project(
        baselineGlucose: state.preMealGlucose!,
        carbsGrams: state.pendingCarbs!,
        fiberGrams: state.pendingFiber ?? 0.0,
        proteinGrams: state.pendingProteins!,
        fatGrams: state.pendingFats!,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        weightKg: weightKg,
        insulinOnBoard: iob,
      );

      // Reset wizard state
      state = LoggingWizardState();
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  /// Legacy save without projection (kept for backwards compatibility).
  Future<bool> saveMealLog() async {
    if (state.pendingCarbs == null ||
        state.pendingProteins == null ||
        state.pendingFats == null) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final log = MealLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        carbohydrates: state.pendingCarbs!,
        dietaryFiber: state.pendingFiber ?? 0.0,
        proteins: state.pendingProteins!,
        fats: state.pendingFats!,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        mealType: state.mealType,
      );

      await ref.read(healthDataRepositoryProvider).addMealLog(log);
      ref.invalidate(mealLogsProvider);
      state = LoggingWizardState();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> saveMedicationLog() async {
    if (state.pendingMedicationUnits == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final log = MedicationLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        medicationType: state.medicationType,
        units: state.pendingMedicationUnits!,
      );

      await ref.read(healthDataRepositoryProvider).addMedicationLog(log);
      ref.invalidate(medicationLogsProvider);
      state = LoggingWizardState();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final loggingWizardProvider =
    StateNotifierProvider<LoggingWizardViewModel, LoggingWizardState>((ref) {
      return LoggingWizardViewModel(ref);
    });
