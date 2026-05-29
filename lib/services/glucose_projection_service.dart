import 'dart:math';
import '../models/projection_result.dart';
import 'caribbean_food_heuristics.dart';

/// Post-meal blood glucose projection using a simplified Hovorka gut absorption
/// model with Total Available Glucose (TAG) and Insulin-on-Board (IOB) safety
/// deduction.
///
/// Phase 2 improvements (clinical audit):
///   - Walsh bilinear IOB decay (replaces linear decay)
///   - Separated protein gluconeogenesis with offset gamma kernel
///   - Food form heuristic for tMax adjustment
///   - Confidence band generation for uncertainty quantification
///
/// References:
///   - Hovorka R. et al. (2004) Compartmental model for gut absorption
///   - TAG formula: Carbs + 0.58xProtein + 0.10xFat
///   - Walsh (2014): Bilinear insulin action curves
///   - Sieradzki (2010): high-fat/protein delay for mixed meals
///   - Bergman (1981): Minimal Model -- Glucose Effectiveness parameter
class GlucoseProjectionService {
  GlucoseProjectionService._();

  /// Duration of the projection in minutes (4 hours).
  static const int _projectionMinutes = 240;

  /// Protein gluconeogenesis offset in minutes.
  /// Protein-derived glucose starts appearing ~60 min after ingestion.
  static const int _proteinOnsetDelay = 60;

  /// Default tMax for the slow protein gamma kernel (peaks much later).
  static const double _proteinTMaxDefault = 120.0;

  // ── Walsh Bilinear IOB Model ─────────────────────────────────────────

  /// Returns the fraction of insulin still active at [elapsedMinutes] using the
  /// Walsh bilinear approximation for rapid-acting insulin.
  ///
  /// This replaces the naive linear decay (1 - t/DIA) which overestimates
  /// insulin effect in the first hour and underestimates it in the last.
  /// The Walsh curve peaks at ~30% of DIA with more aggressive early decay.
  static double _iobFraction(double elapsedMinutes, {double dia = 240.0}) {
    if (elapsedMinutes >= dia) return 0.0;
    if (elapsedMinutes <= 0.0) return 1.0;
    final t = elapsedMinutes / dia;
    // Walsh bilinear: S-curve that peaks action at ~30% DIA
    return (1.0 - (t * t * (3.0 - 2.0 * t))).clamp(0.0, 1.0);
  }

  // ── Dawn Phenomenon Circadian Modifier ──────────────────────────────

  /// Maximum fasting setpoint elevation during the dawn window (mg/dL).
  /// Conservative clinical estimate for mixed T1D/T2D population.
  static const double _dawnAmplitude = 15.0;

  /// Returns the circadian fasting setpoint modifier for a given simulation
  /// minute, based on the meal's real-world timestamp.
  ///
  /// Between 4:00 AM and 8:00 AM, cortisol and growth hormone release
  /// causes temporary insulin resistance, raising the body's natural
  /// glucose equilibrium. This method applies a sine-wave bump peaking
  /// at 6:00 AM (+[_dawnAmplitude] mg/dL) and returning to 0 outside
  /// the window.
  ///
  /// [mealTime] is when the meal was consumed in local time.
  /// [simulationMinute] is the current simulation offset (1..240).
  static double _dawnPhenomenonModifier(
    DateTime mealTime,
    int simulationMinute,
  ) {
    // Calculate the real-world time at this simulation minute
    final realTime = mealTime.add(Duration(minutes: simulationMinute));
    final hour = realTime.hour + realTime.minute / 60.0;

    // Dawn window: 4:00 AM to 8:00 AM (4 hours)
    if (hour < 4.0 || hour > 8.0) return 0.0;

    // Sine-wave phase: 0 at 4 AM, pi at 8 AM, peak (pi/2) at 6 AM
    final phase = (hour - 4.0) / 4.0 * pi;
    return _dawnAmplitude * sin(phase);
  }

  /// Computes the confidence band half-width in mg/dL based on how many
  /// meals have contributed to adaptive tuning.
  /// Starts at +/-25 mg/dL for new users, narrows to +/-10 after ~20 meals.
  static double _confidenceWidth(int mealCount) {
    return max(10.0, 25.0 - (mealCount * 0.75));
  }

  /// Computes a minute-by-minute post-meal glucose projection.
  ///
  /// Returns a [ProjectionResult] containing the plotted curve, peak,
  /// 2-hour value, confidence band, and a risk classification.
  static ProjectionResult project({
    required double baselineGlucose,
    required double carbsGrams,
    required double fiberGrams,
    required double proteinGrams,
    required double fatGrams,
    required bool containsAlcohol,
    required bool containsCaffeine,
    double weightKg = 70.0,
    double insulinOnBoard = 0.0,
    double p1 = 0.025, // ML parameter: metabolicClearanceRate
    double isf = 50.0, // ML parameter: insulinSensitivityFactor
    double tMaxBase = 40.0, // ML parameter: absorptionDelayBase
    double fastingSetpoint = 90.0, // ML parameter: clearance equilibrium point
    String foodFormFactor = 'standard', // Food form heuristic
    bool postExercise = false, // Post-exercise disposal boost
    int mealCount = 0, // Logged meals for confidence band width
    DateTime? mealTimestamp, // When the meal was consumed (for circadian)
    String? mealName, // Meal name (for regional heuristics)
  }) {
    final effectiveMealTime = mealTimestamp ?? DateTime.now();
    // ── STEP 1: Total Available Glucose — split into fast and slow ──────
    final netCarbs = max(0.0, carbsGrams - fiberGrams);

    // Fast component: carbs + small fat contribution
    final fastTAG = netCarbs + (0.10 * fatGrams);

    // Slow component: protein gluconeogenesis (delayed, separate kernel)
    final proteinTAG = 0.58 * proteinGrams;

    final totalTAG = fastTAG + proteinTAG;

    // Guard: if the meal has no macros logged, return a flat baseline line.
    if (totalTAG < 0.01) {
      final flatPoints = List.generate(
        _projectionMinutes ~/ 5 + 1,
        (i) => ProjectionPoint(
          timeMinutes: i * 5,
          glucoseValue: baselineGlucose,
        ),
      );
      return ProjectionResult(
        points: flatPoints,
        peakGlucose: baselineGlucose,
        peakTimeMinutes: 0,
        twoHourGlucose: baselineGlucose,
        totalAvailableGlucose: 0.0,
        riskLevel: 'normal',
        summary: 'No carbohydrates logged — glucose expected to remain stable.',
        upperBand: flatPoints,
        lowerBand: flatPoints,
        confidenceWidth: _confidenceWidth(mealCount),
      );
    }

    // ── STEP 2: Hovorka Parameters ────────────────────────────────────
    const double aG = 0.8; // Bioavailability factor

    // Apply post-exercise heuristics before basic logic.
    // Numerical safety floor ONLY — must stay <= EkfTuningService._p1Min so the
    // adaptive clearance estimate is never silently clamped away. A prior 0.025
    // floor sat ABOVE the EKF's max bound (0.020), which neutralised every
    // clearance-rate update the filter produced. Realistic peaks are now
    // achieved via the profile default + EKF tuning, not a hard floor.
    double effectiveP1 = max(p1, 0.002);
    if (postExercise) {
      // Enhanced glucose disposal (GLUT4 uptake) only. Don't cut tMax here:
      // faster absorption front-loads glucose before clearance ramps up
      // (clearanceFraction = t/45) and paradoxically RAISES the peak — the
      // opposite of the intended post-exercise effect.
      effectiveP1 *= 1.35; // 35% faster disposal
    }

    // Time-to-maximum gut absorption in minutes (fast carb component)
    double tMax = tMaxBase;
    if (fatGrams > 40 || proteinGrams > 25) tMax += 30.0;
    if (containsAlcohol) tMax += 20.0;

    // Food form heuristic — adjusts tMax without needing a GI database
    switch (foodFormFactor) {
      case 'liquid':
        tMax -= 15.0; // Juice, sports drinks absorb faster
      case 'highFiber':
        tMax += 10.0; // Whole grains, lentils slow absorption
      case 'processed':
        tMax -= 10.0; // Refined carbs absorb faster
      default:
        break; // 'standard' — no adjustment
    }
    tMax = tMax.clamp(15.0, 120.0); // Safety clamp

    // ── STEP 2b: Caribbean Regional Heuristics ──────────────────────
    // Apply regional absorption and TAG multipliers for Caribbean foods.
    // This is invisible to the user — the intelligence lives in the data layer.
    final regionalAbsorption =
        CaribbeanFoodHeuristics.getRegionalAbsorptionMultiplier(mealName);
    final regionalTag =
        CaribbeanFoodHeuristics.getRegionalTagMultiplier(mealName);
    tMax *= regionalAbsorption;
    tMax = tMax.clamp(15.0, 120.0); // Re-clamp after regional adjustment

    // Protein kernel tMax (always slower than carb absorption)
    final double proteinTMax = _proteinTMaxDefault;

    // Glucose distribution volume (liters) — Hovorka standard
    final double vG = 0.16 * weightKg;

    // Blood-glucose-equivalent rise from fast and slow components
    // (with regional TAG scaling applied to the fast component)
    final double fastBgEquiv = aG * (fastTAG * regionalTag) * 100.0 / vG;
    final double proteinBgEquiv = aG * proteinTAG * 100.0 / vG;

    // ── STEP 3: Pre-compute gamma-distribution weights ─────────────────
    // Fast carb gamma kernel
    double fastGammaSum = 0.0;
    for (int t = 1; t <= _projectionMinutes; t++) {
      fastGammaSum += t * exp(-t / tMax);
    }
    if (fastGammaSum < 1e-10) fastGammaSum = 1.0;

    // Slow protein gamma kernel (offset by _proteinOnsetDelay)
    double proteinGammaSum = 0.0;
    for (int t = 1; t <= _projectionMinutes; t++) {
      final tOffset = t - _proteinOnsetDelay;
      if (tOffset > 0) {
        proteinGammaSum += tOffset * exp(-tOffset / proteinTMax);
      }
    }
    if (proteinGammaSum < 1e-10) proteinGammaSum = 1.0;

    // IOB: total insulin-driven drop using Walsh bilinear model
    final double totalInsulinDrop = insulinOnBoard * isf;

    // Confidence band half-width
    final double bandWidthMaxWidth = _confidenceWidth(mealCount);

    double bandAtTime(int minute) {
      // Error grows with time, peaks around midway, shrinks toward t=240
      final phase = minute / _projectionMinutes.toDouble();
      final envelope = sin(phase * pi); // 0 -> 1 -> 0 shape
      return bandWidthMaxWidth * envelope;
    }

    // ── STEP 4: Minute-by-minute simulation ───────────────────────────
    double gCurrent = baselineGlucose;
    final points = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];
    final upperBand = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];
    final lowerBand = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];

    for (int t = 1; t <= _projectionMinutes; t++) {
      // — Fast carb absorption rise —
      final double fastGamma = t * exp(-t / tMax);
      double fastRise = fastBgEquiv * fastGamma / fastGammaSum;

      // — Slow protein absorption rise (offset) —
      double proteinRise = 0.0;
      final tOffset = t - _proteinOnsetDelay;
      if (tOffset > 0) {
        final double proteinGamma = tOffset * exp(-tOffset / proteinTMax);
        proteinRise = proteinBgEquiv * proteinGamma / proteinGammaSum;
      }

      double riseRate = fastRise + proteinRise;
      if (containsCaffeine) riseRate *= 1.10;

      // — Endogenous clearance —
      // Only applies ABOVE the body's natural fasting equilibrium.
      // Dawn Phenomenon: shift the equilibrium upward between 4-8 AM.
      final double dawnShift =
          _dawnPhenomenonModifier(effectiveMealTime, t);
      final double effectiveFasting = fastingSetpoint + dawnShift;
      // Clearance should not drop just because food absorption drops.
      // Instead, we simulate endogenous insulin ramping up over the first 45 minutes
      // avoiding a stall in clearance when glucose is still high.
      final double clearanceFraction = (t / 45.0).clamp(0.1, 1.0);
      final double rawClearance = max(0.0, gCurrent - effectiveFasting) * effectiveP1;
      // Allow a higher maximum clearance (4.0 instead of 1.5) to enable realistic return to baseline within 2-3 hours
      final double clearanceRate = min(rawClearance * clearanceFraction, 4.0);

      // — Insulin on Board (Walsh bilinear) —
      // Differential IOB: insulin consumed in this minute
      // Only subtract when glucose is safely above hypoglycaemic threshold.
      double iobMinute = 0.0;
      if (gCurrent > 70.0 && totalInsulinDrop > 0) {
        final double iobNow = _iobFraction(t.toDouble());
        final double iobPrev = _iobFraction((t - 1).toDouble());
        // iobPrev > iobNow: the fraction consumed this minute
        iobMinute = max(0.0, iobPrev - iobNow) * totalInsulinDrop;
      }

      // — Alcohol effect (after 60 min) —
      final double alcoholDrop =
          containsAlcohol && t > 60 ? (3.0 / 60.0) : 0.0;

      // — Net change —
      gCurrent += riseRate - clearanceRate - iobMinute - alcoholDrop;

      // Physiological safety clamp
      gCurrent = gCurrent.clamp(40.0, 500.0);

      if (t % 5 == 0) {
        final roundedValue = double.parse(gCurrent.toStringAsFixed(1));
        final currentBandWidth = bandAtTime(t);
        points.add(ProjectionPoint(
          timeMinutes: t,
          glucoseValue: roundedValue,
        ));
        upperBand.add(ProjectionPoint(
          timeMinutes: t,
          glucoseValue: (roundedValue + currentBandWidth).clamp(40.0, 500.0),
        ));
        lowerBand.add(ProjectionPoint(
          timeMinutes: t,
          glucoseValue: (roundedValue - currentBandWidth).clamp(40.0, 500.0),
        ));
      }
    }

    // ── STEP 5: Extract metrics ───────────────────────────────────────
    double peakGlucose = baselineGlucose;
    int peakTime = 0;
    double twoHourGlucose = baselineGlucose;
    bool hasHypo = false;

    for (final point in points) {
      if (point.glucoseValue > peakGlucose) {
        peakGlucose = point.glucoseValue;
        peakTime = point.timeMinutes;
      }
      if (point.timeMinutes == 120) {
        twoHourGlucose = point.glucoseValue;
      }
      if (point.glucoseValue < 70.0) {
        hasHypo = true;
      }
    }

    // Risk classification
    final String riskLevel;
    if (hasHypo) {
      riskLevel = 'hypo_risk';
    } else if (peakGlucose > 250) {
      riskLevel = 'high';
    } else if (peakGlucose > 180) {
      riskLevel = 'elevated';
    } else {
      riskLevel = 'normal';
    }

    final riskText = switch (riskLevel) {
      'normal' => 'Within target range.',
      'elevated' => 'Above target. Consider portion adjustment.',
      'high' => 'Significantly elevated. Consult your care team.',
      'hypo_risk' =>
        'Hypoglycemia risk detected. Have fast-acting glucose ready.',
      _ => '',
    };

    final summary = 'Peak ${peakGlucose.toStringAsFixed(0)} mg/dL at '
        '$peakTime min. '
        '2hr: ${twoHourGlucose.toStringAsFixed(0)} mg/dL. '
        '$riskText';

    return ProjectionResult(
      points: points,
      peakGlucose: peakGlucose,
      peakTimeMinutes: peakTime,
      twoHourGlucose: twoHourGlucose,
      totalAvailableGlucose: double.parse(totalTAG.toStringAsFixed(1)),
      riskLevel: riskLevel,
      summary: summary,
      upperBand: upperBand,
      lowerBand: lowerBand,
      confidenceWidth: bandWidthMaxWidth,
    );
  }
}
