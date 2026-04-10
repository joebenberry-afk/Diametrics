import 'dart:math';

import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/user_profile.dart';
import '../repositories/health_data_repository.dart';
import '../repositories/user_repository.dart';
import 'glucose_projection_service.dart';

/// Extended Kalman Filter (EKF) Adaptive Tuning Service
///
/// Replaces the Phase 2 gradient descent tuner with a recursive Bayesian
/// state estimator. The EKF mathematically balances "trust" between the
/// deterministic Bergman/Hovorka model prediction and the noisy sensor
/// measurement, preventing a single anomalous reading from corrupting
/// the user's digital twin parameters.
///
/// **State vector:**
///   x = [p1, ISF, tMax]
///
/// **Covariance:**
///   Diagonal P = [ekfCovP1, ekfCovISF, ekfCovTMax]
///   (off-diagonal cross-correlations are neglected for computational
///   simplicity and because the decoupled context naturally separates
///   absorption from clearance.)
///
/// **Measurement noise (R):**
///   100.0  (finger-stick meter variance, ~10 mg/dL std dev)
///
/// **Process noise (Q):**
///   Small constant added each cycle to prevent covariance collapse,
///   allowing the filter to track slow physiological drift (e.g.,
///   seasonal insulin resistance changes).
///
/// Safety constraints (per ADA/Hovorka guidance):
///   - metabolicClearanceRate   : [0.002, 0.020]
///   - insulinSensitivityFactor : [20.0, 150.0]
///   - absorptionDelayBase      : [20.0, 90.0]
class EkfTuningService {
  EkfTuningService._();

  // ── Constants ──────────────────────────────────────────────────────────────

  /// Measurement noise variance (R).
  /// For finger-stick meters: variance = (10 mg/dL)^2 = 100.
  static const double _measurementNoise = 100.0;

  /// Process noise (Q) — injected each cycle to prevent covariance starvation.
  /// Small enough to maintain stability, large enough to track drift.
  static const double _processNoiseP1 = 0.00001;
  static const double _processNoiseISF = 0.5;
  static const double _processNoiseTMax = 0.1;

  /// Maximum window for associating a post-meal glucose to a prior meal.
  static const Duration _mealLookback = Duration(hours: 3);

  /// Physiological clamp bounds for each parameter.
  static const double _p1Min = 0.002;
  static const double _p1Max = 0.020;
  static const double _isfMin = 20.0;
  static const double _isfMax = 150.0;
  static const double _tMaxMin = 20.0;
  static const double _tMaxMax = 90.0;

  /// Maximum number of overlapping meals the superposition engine handles.
  /// Beyond this, the signal entropy is too high for reliable estimation.
  static const int _maxSuperpositionMeals = 2;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this after saving a post-meal glucose log. Runs the EKF update
  /// and persists updated parameters + covariance to the user profile.
  ///
  /// Fully silent — never blocks UI or throws user-visible errors.
  static Future<void> tuneFromGlucoseLog({
    required GlucoseLog glucoseLog,
    required HealthDataRepository dataRepo,
    required UserRepository userRepo,
  }) async {
    try {
      // Only act on post-meal context readings
      final ctx = glucoseLog.context;
      if (ctx != 'post_meal' &&
          ctx != 'post_meal_120' &&
          ctx != 'post_meal_30') {
        return;
      }

      final profile = await userRepo.getProfile();
      if (profile == null) return;

      // Find the most recent meal logged before this glucose reading
      final meal = await _findAssociatedMeal(glucoseLog, dataRepo);
      if (meal == null) return;

      // Find the pre-meal glucose that preceded this meal
      final preMealGlucose = await _findPreMealGlucose(meal, dataRepo);
      if (preMealGlucose == null) return;

      // ── Superposition: handle overlapping meals ──────────────────────
      final overlapping = await _findOverlappingMeals(meal, glucoseLog, dataRepo);

      // If more than _maxSuperpositionMeals overlap, abort — too noisy
      if (overlapping.length > _maxSuperpositionMeals) return;

      double residualContribution = 0.0;
      if (overlapping.isNotEmpty) {
        // Calculate the decaying glucose contribution from the primary meal
        // at the time each overlapping meal was consumed, then sum the
        // residual tails as a baseline disturbance.
        residualContribution = _calculateResidualContribution(
          primaryMeal: meal,
          overlappingMeals: overlapping,
          preMealGlucose: preMealGlucose,
          profile: profile,
          readingTime: glucoseLog.timestamp,
        );
      }

      // Re-run the projection using current profile parameters
      final projected = GlucoseProjectionService.project(
        baselineGlucose: preMealGlucose,
        carbsGrams: meal.carbohydrates,
        fiberGrams: meal.dietaryFiber,
        proteinGrams: meal.proteins,
        fatGrams: meal.fats,
        containsAlcohol: meal.containsAlcohol,
        containsCaffeine: meal.containsCaffeine,
        weightKg: profile.weightKg,
        p1: profile.metabolicClearanceRate,
        isf: profile.insulinSensitivityFactor,
        tMaxBase: profile.absorptionDelayBase,
        foodFormFactor: meal.foodFormFactor,
        mealCount: profile.tuningMealCount,
        mealTimestamp: meal.timestamp,
        mealName: meal.name,
      );

      // Determine the projection value at the matching time offset
      final minutesElapsed = glucoseLog.timestamp
          .difference(meal.timestamp)
          .inMinutes
          .clamp(0, 240);
      final predictedAtTime = _interpolateAtMinute(
        projected.points,
        minutesElapsed,
      );

      // ── EKF Innovation ──────────────────────────────────────────────
      // The "actual" is adjusted for residual contributions from
      // overlapping meals to isolate this meal's metabolic signal.
      final double actual = glucoseLog.value - residualContribution;
      final double innovation = actual - predictedAtTime;

      // ── EKF Update (decoupled by context) ───────────────────────────
      double newP1 = profile.metabolicClearanceRate;
      double newISF = profile.insulinSensitivityFactor;
      double newTMax = profile.absorptionDelayBase;
      double newCovP1 = profile.ekfCovP1 + _processNoiseP1;
      double newCovISF = profile.ekfCovISF + _processNoiseISF;
      double newCovTMax = profile.ekfCovTMax + _processNoiseTMax;

      if (ctx == 'post_meal_30') {
        // 30-min reading: early spike dominated by absorption speed.
        // Only update tMax via EKF.
        final kalmanGainTMax =
            newCovTMax / (newCovTMax + _measurementNoise);

        // Sensitivity: how tMax affects the predicted glucose.
        // A higher tMax delays the peak, so if we underpredicted (positive
        // innovation), tMax should decrease (food arrived faster).
        // Scale factor converts glucose-space error to tMax-space.
        final tMaxSensitivity = -0.3; // empirical Jacobian approximation
        newTMax = (newTMax + kalmanGainTMax * innovation * tMaxSensitivity)
            .clamp(_tMaxMin, _tMaxMax);
        newCovTMax = (1.0 - kalmanGainTMax) * newCovTMax;
      } else if (ctx == 'post_meal_120' || ctx == 'post_meal') {
        // 120-min reading: absorption is mostly complete, clearance dominates.
        // Update p1 and ISF via EKF.

        // p1 update (clearance rate)
        final kalmanGainP1 =
            newCovP1 / (newCovP1 + _measurementNoise);
        // If we underpredicted (positive innovation), clearance is lower
        // than estimated, so p1 should decrease.
        final p1Sensitivity = -0.001; // empirical Jacobian approximation
        newP1 = (newP1 + kalmanGainP1 * innovation * p1Sensitivity)
            .clamp(_p1Min, _p1Max);
        newCovP1 = (1.0 - kalmanGainP1) * newCovP1;

        // ISF update (insulin sensitivity)
        final kalmanGainISF =
            newCovISF / (newCovISF + _measurementNoise);
        // If we underpredicted (positive innovation), insulin had less
        // effect than expected, so ISF should increase.
        final isfSensitivity = 0.1; // empirical Jacobian approximation
        newISF = (newISF + kalmanGainISF * innovation * isfSensitivity)
            .clamp(_isfMin, _isfMax);
        newCovISF = (1.0 - kalmanGainISF) * newCovISF;
      }

      // Only update if change is meaningful (avoid churn on tiny noise)
      final p1Changed =
          (newP1 - profile.metabolicClearanceRate).abs() > 1e-6;
      final isfChanged =
          (newISF - profile.insulinSensitivityFactor).abs() > 0.01;
      final tMaxChanged =
          (newTMax - profile.absorptionDelayBase).abs() > 0.01;
      final covChanged =
          (newCovP1 - profile.ekfCovP1).abs() > 1e-6 ||
              (newCovISF - profile.ekfCovISF).abs() > 0.01 ||
              (newCovTMax - profile.ekfCovTMax).abs() > 0.01;

      if (!p1Changed && !isfChanged && !tMaxChanged && !covChanged) return;

      await userRepo.updateEkfParameters(
        profileId: profile.id,
        metabolicClearanceRate: newP1,
        insulinSensitivityFactor: newISF,
        absorptionDelayBase: newTMax,
        tuningMealCount: profile.tuningMealCount + 1,
        fastingSetpoint: profile.fastingSetpoint,
        ekfCovP1: newCovP1,
        ekfCovISF: newCovISF,
        ekfCovTMax: newCovTMax,
      );
    } catch (_) {
      // Silent failure: never crash the app for a background tuning event
    }
  }

  // ── Superposition Engine ───────────────────────────────────────────────────

  /// Calculates the residual glucose contribution from overlapping meals.
  ///
  /// For each overlapping meal, re-runs the primary meal's projection to
  /// determine how much glucose from the primary is still "in flight" at
  /// the time the overlapping meal started. This residual is subtracted
  /// from the actual reading to isolate the primary meal's signal.
  static double _calculateResidualContribution({
    required MealLog primaryMeal,
    required List<MealLog> overlappingMeals,
    required double preMealGlucose,
    required UserProfile profile,
    required DateTime readingTime,
  }) {
    double totalResidual = 0.0;

    for (final overlapMeal in overlappingMeals) {
      // Re-project the overlapping meal's contribution
      // We use the time between the overlap meal and the reading to estimate
      // how much glucose it has contributed by the reading time.
      final overlapMinutes = readingTime
          .difference(overlapMeal.timestamp)
          .inMinutes
          .clamp(0, 240);

      if (overlapMinutes <= 0) continue;

      // Project the overlapping meal from a neutral baseline (0 offset)
      // to isolate its contribution
      final overlapProjection = GlucoseProjectionService.project(
        baselineGlucose: 0.0, // Zero baseline to get pure contribution
        carbsGrams: overlapMeal.carbohydrates,
        fiberGrams: overlapMeal.dietaryFiber,
        proteinGrams: overlapMeal.proteins,
        fatGrams: overlapMeal.fats,
        containsAlcohol: overlapMeal.containsAlcohol,
        containsCaffeine: overlapMeal.containsCaffeine,
        weightKg: profile.weightKg,
        p1: profile.metabolicClearanceRate,
        isf: profile.insulinSensitivityFactor,
        tMaxBase: profile.absorptionDelayBase,
        foodFormFactor: overlapMeal.foodFormFactor,
        mealCount: profile.tuningMealCount,
        mealTimestamp: overlapMeal.timestamp,
        mealName: overlapMeal.name,
      );

      // The residual is the projected value at the elapsed time
      // minus the baseline (which is 0), giving us the pure glucose
      // contribution from this overlapping meal.
      final contribution = _interpolateAtMinute(
        overlapProjection.points,
        overlapMinutes,
      );

      // Clamp contribution to avoid negative residuals from the safety clamp
      totalResidual += max(0.0, contribution);
    }

    return totalResidual;
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  /// Finds the most recent meal log that was saved before [glucoseLog] and
  /// within the [_mealLookback] window.
  static Future<MealLog?> _findAssociatedMeal(
    GlucoseLog glucoseLog,
    HealthDataRepository dataRepo,
  ) async {
    final allMeals = await dataRepo.getMealLogs();
    final cutoff = glucoseLog.timestamp.subtract(_mealLookback);
    MealLog? best;
    for (final meal in allMeals) {
      if (meal.timestamp.isAfter(cutoff) &&
          meal.timestamp.isBefore(glucoseLog.timestamp)) {
        if (best == null || meal.timestamp.isAfter(best.timestamp)) {
          best = meal;
        }
      }
    }
    return best;
  }

  /// Finds all meals logged between [candidate] and [reading] (excluding
  /// the candidate itself). These are the overlapping meals for superposition.
  static Future<List<MealLog>> _findOverlappingMeals(
    MealLog candidate,
    GlucoseLog reading,
    HealthDataRepository dataRepo,
  ) async {
    final allMeals = await dataRepo.getMealLogs();
    return allMeals
        .where((m) =>
            m.timestamp.isAfter(candidate.timestamp) &&
            m.timestamp.isBefore(reading.timestamp) &&
            m.id != candidate.id)
        .toList();
  }

  /// Finds a pre-meal glucose reading within 30 minutes before [meal].
  static Future<double?> _findPreMealGlucose(
    MealLog meal,
    HealthDataRepository dataRepo,
  ) async {
    final allGlucose = await dataRepo.getGlucoseLogs();
    final windowStart = meal.timestamp.subtract(const Duration(minutes: 30));
    GlucoseLog? best;
    for (final g in allGlucose) {
      if ((g.context == 'pre_meal' || g.context == 'fasting') &&
          g.timestamp.isAfter(windowStart) &&
          g.timestamp.isBefore(meal.timestamp)) {
        if (best == null || g.timestamp.isAfter(best.timestamp)) {
          best = g;
        }
      }
    }
    return best?.value;
  }

  /// Linearly interpolates the projected glucose curve at [minute].
  static double _interpolateAtMinute(
    List<dynamic> points,
    int minute,
  ) {
    if (points.isEmpty) return 100.0;
    dynamic prev = points.first;
    dynamic next = points.last;
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a.timeMinutes <= minute && b.timeMinutes >= minute) {
        prev = a;
        next = b;
        break;
      }
    }
    if (prev.timeMinutes == next.timeMinutes) return prev.glucoseValue;
    final t = (minute - prev.timeMinutes) /
        max(1, next.timeMinutes - prev.timeMinutes);
    return prev.glucoseValue + t * (next.glucoseValue - prev.glucoseValue);
  }
}
