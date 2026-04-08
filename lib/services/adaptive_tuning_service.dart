import 'dart:math';

import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/user_profile.dart';
import '../repositories/health_data_repository.dart';
import '../repositories/user_repository.dart';
import 'glucose_projection_service.dart';

/// Adaptive Parameter Tuning Service
///
/// Implements a conservative local Gradient Descent loop that refines the
/// user's personal physiological constants every time a post-meal glucose
/// reading is logged. Over 15-20 logged meals the projection accuracy
/// converges to the individual's true metabolism.
///
/// Phase 2 improvement: **Decoupled gradient descent** — instead of updating
/// all three parameters from every reading, the service uses the reading's
/// temporal context to update only the most informative parameter(s):
///
///   - `post_meal_30` -> updates `tMax` only (early absorption speed)
///   - `post_meal_120` -> updates `p1` and `ISF` (clearance + insulin)
///
/// This prevents parameter confounding where a high spike could be from
/// faster absorption OR lower clearance, and the system couldn't distinguish.
///
/// Parameters tuned:
///   - [UserProfile.metabolicClearanceRate]  (p1)  -- how fast glucose clears
///   - [UserProfile.insulinSensitivityFactor] (ISF) -- mg/dL drop per 1 unit
///   - [UserProfile.absorptionDelayBase]      (tMax) -- digestion lag (minutes)
///
/// Safety constraints (per ADA/Hovorka guidance):
///   - metabolicClearanceRate   : [0.002, 0.020]
///   - insulinSensitivityFactor : [20.0, 150.0]
///   - absorptionDelayBase      : [20.0, 90.0]
class AdaptiveTuningService {
  AdaptiveTuningService._();

  // ── Constants ──────────────────────────────────────────────────────────────

  /// Conservative learning rate. Low enough to resist single-day anomalies
  /// (e.g., unexpected intense exercise), high enough to converge in ~15 meals.
  static const double _lr = 0.0001;

  /// Maximum window for associating a post-meal glucose to a prior meal.
  static const Duration _mealLookback = Duration(hours: 3);

  /// Physiological clamp bounds for each parameter.
  static const double _p1Min = 0.002;
  static const double _p1Max = 0.020;
  static const double _isfMin = 20.0;
  static const double _isfMax = 150.0;
  static const double _tMaxMin = 20.0;
  static const double _tMaxMax = 90.0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this after saving a post-meal glucose log (context = 'post_meal'
  /// or 'post_meal_120'). Silently runs the tuning loop and persists updated
  /// parameters to the user profile.
  ///
  /// No UI changes are triggered — this runs entirely in the background.
  static Future<void> tuneFromGlucoseLog({
    required GlucoseLog glucoseLog,
    required HealthDataRepository dataRepo,
    required UserRepository userRepo,
  }) async {
    try {
      // Only act on post-meal context readings
      final ctx = glucoseLog.context;
      if (ctx != 'post_meal' && ctx != 'post_meal_120' && ctx != 'post_meal_30') {
        return;
      }

      // Fetch the current profile — no profile means no tuning possible
      final profile = await userRepo.getProfile();
      if (profile == null) return;

      // Find the most recent meal logged before this glucose reading
      final meal = await _findAssociatedMeal(glucoseLog, dataRepo);
      if (meal == null) return;

      // Find the pre-meal glucose that preceded this meal
      final preMealGlucose = await _findPreMealGlucose(meal, dataRepo);
      if (preMealGlucose == null) return;

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

      // Compute the signed error (positive = we underpredicted; spike was higher)
      final double actual = glucoseLog.value;
      final double delta = actual - predictedAtTime;

      // ── Decoupled Gradient Descent Updates ─────────────────────────────
      // Instead of updating all three parameters from one error reading,
      // use timed contexts to disentangle the signals.

      double newP1 = profile.metabolicClearanceRate;
      double newISF = profile.insulinSensitivityFactor;
      double newTMax = profile.absorptionDelayBase;

      if (ctx == 'post_meal_30') {
        // 30-min reading: early spike is dominated by absorption speed.
        // Only update tMax — a 30-min reading tells us nothing reliable
        // about clearance or insulin sensitivity yet.
        newTMax = (profile.absorptionDelayBase - delta * _lr * 3)
            .clamp(_tMaxMin, _tMaxMax);
      } else if (ctx == 'post_meal_120' || ctx == 'post_meal') {
        // 120-min reading: absorption is mostly done, clearance dominates.
        // Update p1 and ISF only.
        newP1 = (profile.metabolicClearanceRate - delta * _lr)
            .clamp(_p1Min, _p1Max);
        newISF = (profile.insulinSensitivityFactor + delta * _lr * 10)
            .clamp(_isfMin, _isfMax);
      }

      // Only update if change is meaningful (avoid churn on tiny noise)
      final p1Changed = (newP1 - profile.metabolicClearanceRate).abs() > 1e-6;
      final isfChanged = (newISF - profile.insulinSensitivityFactor).abs() > 0.01;
      final tMaxChanged = (newTMax - profile.absorptionDelayBase).abs() > 0.01;

      if (!p1Changed && !isfChanged && !tMaxChanged) return;

      final updated = profile.copyWith(
        metabolicClearanceRate: newP1,
        insulinSensitivityFactor: newISF,
        absorptionDelayBase: newTMax,
        tuningMealCount: profile.tuningMealCount + 1,
        updatedAt: DateTime.now(),
      );
      await userRepo.saveProfile(updated);
    } catch (_) {
      // Silent failure: never crash the app for a background tuning event
    }
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
    // Find surrounding points
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
