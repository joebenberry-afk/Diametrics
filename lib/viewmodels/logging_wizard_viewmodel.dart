import 'dart:async' show unawaited;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import '../models/projection_result.dart';
import '../repositories/user_repository.dart';
import '../services/ekf_tuning_service.dart';
import '../services/glucose_projection_service.dart';
import '../services/reminder_service.dart';
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
  final double? pendingCalories;
  final bool containsAlcohol;
  final bool containsCaffeine;
  final String mealType;
  final String foodFormFactor; // standard, liquid, highFiber, processed
  final String? mealName; // For regional heuristic lookup

  // Pre-meal glucose gate (used by Meal Wizard)
  final double? preMealGlucose;
  final bool hasAutoDetectedGlucose;

  // Medication Wizard
  final double? pendingMedicationUnits;
  final String medicationType;

  final bool postExercise; // Track exercise flag for meal wizard

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
    this.pendingCalories,
    this.containsAlcohol = false,
    this.containsCaffeine = false,
    this.mealType = 'lunch',
    this.foodFormFactor = 'standard',
    this.mealName,
    this.preMealGlucose,
    this.hasAutoDetectedGlucose = false,
    this.pendingMedicationUnits,
    this.medicationType = 'rapid_acting_insulin',
    this.postExercise = false,
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
    double? pendingCalories,
    bool? containsAlcohol,
    bool? containsCaffeine,
    String? mealType,
    String? foodFormFactor,
    String? mealName,
    double? preMealGlucose,
    bool? hasAutoDetectedGlucose,
    double? pendingMedicationUnits,
    String? medicationType,
    bool? postExercise,
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
      pendingCalories: pendingCalories ?? this.pendingCalories,
      containsAlcohol: containsAlcohol ?? this.containsAlcohol,
      containsCaffeine: containsCaffeine ?? this.containsCaffeine,
      mealType: mealType ?? this.mealType,
      foodFormFactor: foodFormFactor ?? this.foodFormFactor,
      mealName: mealName ?? this.mealName,
      preMealGlucose: preMealGlucose ?? this.preMealGlucose,
      hasAutoDetectedGlucose:
          hasAutoDetectedGlucose ?? this.hasAutoDetectedGlucose,
      pendingMedicationUnits:
          pendingMedicationUnits ?? this.pendingMedicationUnits,
      medicationType: medicationType ?? this.medicationType,
      postExercise: postExercise ?? this.postExercise,
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
    double? calories,
  }) {
    state = state.copyWith(
      pendingCarbs: carbs,
      pendingFiber: fiber,
      pendingProteins: proteins,
      pendingFats: fats,
      pendingCalories: calories,
    );
  }

  void toggleAlcohol(bool val) => state = state.copyWith(containsAlcohol: val);
  void toggleCaffeine(bool val) =>
      state = state.copyWith(containsCaffeine: val);
  void updateMealType(String type) => state = state.copyWith(mealType: type);
  void updateFoodFormFactor(String factor) =>
      state = state.copyWith(foodFormFactor: factor);
  void togglePostExercise(bool val) =>
      state = state.copyWith(postExercise: val);

  /// Populates meal macro fields from a barcode scan result (FoodItem).
  /// Called after the user successfully scans a packaged food barcode.
  void setFromBarcodeResult({
    required double carbs,
    required double proteins,
    required double fats,
    required double calories,
  }) {
    state = state.copyWith(
      pendingCarbs: carbs,
      pendingProteins: proteins,
      pendingFats: fats,
      pendingCalories: calories,
      pendingFiber: 0.0,
    );
  }

  // --- Medication Adjustments ---
  void updateMedicationUnits(double units) =>
      state = state.copyWith(pendingMedicationUnits: units);
  void updateMedicationType(String type) =>
      state = state.copyWith(medicationType: type);

  // --- IOB Calculation (Walsh Bilinear) ---

  /// Calculates Insulin-on-Board from rapid-acting insulin logged within the
  /// user's configured DIA window, using the Walsh bilinear decay model.
  ///
  /// The DIA is stored at the **profile level** (set once during onboarding)
  /// rather than per-dose, reducing cognitive load. If the user's insulin
  /// category is 'basal_only' or 'none', IOB is zero — preventing phantom
  /// bolus action from corrupting projections for non-bolus users.
  Future<double> _calculateIOB() async {
    final profile = await UserRepository().getProfile();
    final category = profile?.insulinCategory ?? 'standard_rapid';

    // Guard: basal-only or non-insulin users have no mealtime IOB
    if (category == 'basal_only' || category == 'none') return 0.0;

    final double dia = profile?.insulinDiaMinutes ?? 240.0;
    final repo = ref.read(healthDataRepositoryProvider);
    final recentMeds = await repo.getRecentMedicationLogs(
      Duration(minutes: dia.toInt()),
    );
    double iob = 0.0;
    final now = DateTime.now();
    for (final med in recentMeds) {
      if (med.medicationType != 'rapid_acting_insulin') continue;
      final elapsedMin = now.difference(med.timestamp).inMinutes.toDouble();
      if (elapsedMin >= dia) continue;
      // Walsh bilinear: S-curve fraction remaining
      final t = elapsedMin / dia;
      final remaining = (1.0 - (t * t * (3.0 - 2.0 * t))).clamp(0.0, 1.0);
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

      final dataRepo = ref.read(healthDataRepositoryProvider);
      await dataRepo.addGlucoseLog(log);
      ref.invalidate(glucoseLogsProvider);

      // Fire adaptive tuning (EKF) in the background for post-meal readings.
      // Never awaited so it never blocks or disrupts the user flow.
      EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: log,
        dataRepo: dataRepo,
        userRepo: UserRepository(),
      );

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
  /// Returns a Map with the [ProjectionResult] and user [unit] on success, or `null` on failure.
  Future<Map<String, dynamic>?> saveMealWithProjection({
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
          unit: state.glucoseUnit,
          context: 'pre_meal',
        );
        await repo.addGlucoseLog(glucoseLog);
        ref.invalidate(glucoseLogsProvider);
      }

      // Calculate fallback calories if not explicitly provided by AI
      final computedCalories = (state.pendingCarbs! * 4.0) +
          (state.pendingProteins! * 4.0) +
          (state.pendingFats! * 9.0);
      final finalCalories = (state.pendingCalories != null && state.pendingCalories! > 0)
          ? state.pendingCalories!
          : computedCalories;

      // 2. Save the meal log
      final mealLog = MealLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        carbohydrates: state.pendingCarbs!,
        dietaryFiber: state.pendingFiber ?? 0.0,
        proteins: state.pendingProteins!,
        fats: state.pendingFats!,
        calories: finalCalories,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        mealType: state.mealType,
        foodFormFactor: state.foodFormFactor,
        postExercise: state.postExercise,
      );
      await repo.addMealLog(mealLog);
      ref.invalidate(mealLogsProvider);

      // Schedule post-meal glucose check reminders (fire-and-forget, never blocks)
      unawaited(ReminderService.schedulePostMealReminders(DateTime.now()));

      // 3. Calculate IOB and run the projection using personalized ML params.
      final iob = await _calculateIOB();
      final profile = await UserRepository().getProfile();
      final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';
      final mealCount = profile?.tuningMealCount ?? 0;
      
      // Normalize baseline to mg/dL for the projection service math
      double normalizedBaseline = state.preMealGlucose!;
      if (unit == 'mmol/L') {
        normalizedBaseline *= 18.0182;
      }

      final result = GlucoseProjectionService.project(
        baselineGlucose: normalizedBaseline,
        carbsGrams: state.pendingCarbs!,
        fiberGrams: state.pendingFiber ?? 0.0,
        proteinGrams: state.pendingProteins!,
        fatGrams: state.pendingFats!,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        weightKg: weightKg,
        insulinOnBoard: iob,
        p1: profile?.metabolicClearanceRate ?? 0.010,
        isf: profile?.insulinSensitivityFactor ?? 50.0,
        tMaxBase: profile?.absorptionDelayBase ?? 40.0,
        fastingSetpoint: profile?.fastingSetpoint ?? 90.0,
        foodFormFactor: state.foodFormFactor,
        postExercise: state.postExercise,
        mealCount: mealCount,
        mealTimestamp: DateTime.now(),
        mealName: state.mealName,
      );

      // Reset wizard state
      state = LoggingWizardState();
      return {
        'result': result,
        'unit': unit,
        'mealCount': mealCount,
      };
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
      final computedCalories = (state.pendingCarbs! * 4.0) +
          (state.pendingProteins! * 4.0) +
          (state.pendingFats! * 9.0);
      final finalCalories = (state.pendingCalories != null && state.pendingCalories! > 0)
          ? state.pendingCalories!
          : computedCalories;

      final log = MealLog(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        carbohydrates: state.pendingCarbs!,
        dietaryFiber: state.pendingFiber ?? 0.0,
        proteins: state.pendingProteins!,
        fats: state.pendingFats!,
        calories: finalCalories,
        containsAlcohol: state.containsAlcohol,
        containsCaffeine: state.containsCaffeine,
        mealType: state.mealType,
        foodFormFactor: state.foodFormFactor,
        postExercise: state.postExercise,
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
        insulinType: state.medicationType == 'rapid_acting_insulin' ? 'Humalog / NovoLog' : 'N/A', // Auto-set generic for now, the UI can pass it later.
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
