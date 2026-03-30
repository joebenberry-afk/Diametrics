import 'dart:math';
import '../models/projection_result.dart';

/// Post-meal blood glucose projection using a simplified Hovorka gut absorption
/// model with Total Available Glucose (TAG) and Insulin-on-Board (IOB) safety
/// deduction.
///
/// References:
///   - Hovorka R. et al. (2004) Compartmental model for gut absorption
///   - TAG formula: Carbs + 0.58×Protein + 0.10×Fat
///   - Sieradzki (2010): high-fat/protein delay for mixed meals
///   - Bergman (1981): Minimal Model – Glucose Effectiveness parameter
class GlucoseProjectionService {
  GlucoseProjectionService._();

  /// Duration of the projection in minutes (4 hours).
  static const int _projectionMinutes = 240;

  /// Computes a minute-by-minute post-meal glucose projection.
  ///
  /// Returns a [ProjectionResult] containing the plotted curve, peak,
  /// 2-hour value, and a risk classification.
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
    double p1 = 0.010, // ML parameter: metabolicClearanceRate
    double isf = 50.0, // ML parameter: insulinSensitivityFactor
    double tMaxBase = 40.0, // ML parameter: absorptionDelayBase
  }) {
    // ── STEP 1: Total Available Glucose (TAG) ─────────────────────────
    final netCarbs = max(0.0, carbsGrams - fiberGrams);
    final tag = netCarbs + (0.58 * proteinGrams) + (0.10 * fatGrams);

    // Guard: if the meal has no macros logged, return a flat baseline line.
    if (tag < 0.01) {
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
      );
    }

    // ── STEP 2: Hovorka Parameters ────────────────────────────────────
    const double aG = 0.8; // Bioavailability factor

    // Time-to-maximum gut absorption in minutes
    double tMax = tMaxBase;
    if (fatGrams > 40 || proteinGrams > 25) tMax += 30.0;
    if (containsAlcohol) tMax += 20.0;

    // Glucose distribution volume (liters) — Hovorka standard
    final double vG = 0.16 * weightKg;

    // Total blood-glucose-equivalent rise from this meal (mg/dL)
    // Derivation: tag_g → tag_mmol (÷180) → BG rise = mmol / vG_dL × 180
    //             = tag × 1000 / (vG × 10) = tag × 100 / vG
    final double bgEquivalent = aG * tag * 100.0 / vG;

    // ── STEP 3: Pre-compute gamma-distribution weights ─────────────────
    // The gamma kernel f(t) = t * exp(-t / tMax) peaks at t = tMax.
    // Normalising over 240 minutes ensures total absorbed = bgEquivalent.
    double gammaSum = 0.0;
    for (int t = 1; t <= _projectionMinutes; t++) {
      gammaSum += t * exp(-t / tMax);
    }
    if (gammaSum < 1e-10) gammaSum = 1.0;

    // IOB: total insulin-driven drop spread evenly across DIA window
    final double totalInsulinDrop = insulinOnBoard * isf;

    // ── STEP 4: Minute-by-minute simulation ───────────────────────────
    double gCurrent = baselineGlucose;
    final points = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];

    for (int t = 1; t <= _projectionMinutes; t++) {
      // — Absorption rise —
      final double gammaWeight = t * exp(-t / tMax);
      double riseRate = bgEquivalent * gammaWeight / gammaSum;
      if (containsCaffeine) riseRate *= 1.10;

      // — Endogenous clearance —
      // Only applies ABOVE the body's natural fasting equilibrium (~90 mg/dL).
      // Importantly, clearance is scaled by the current absorption fraction:
      // when the meal is barely absorbed (early minutes), clearance is minimal
      // so glucose does not plummet before the food arrives.
      final double absorptionFraction = gammaWeight / (gammaSum / _projectionMinutes);
      final double clearanceFraction = (absorptionFraction / (absorptionFraction + 1.0)).clamp(0.1, 1.0);
      final double rawClearance = max(0.0, gCurrent - 90.0) * p1;
      final double clearanceRate = min(rawClearance * clearanceFraction, 1.5);

      // — Insulin on Board —
      // Only subtract when glucose is safely above hypoglycaemic threshold.
      final double iobMinute = gCurrent > 70.0
          ? (totalInsulinDrop / _projectionMinutes)
          : 0.0;

      // — Alcohol effect (after 60 min) —
      final double alcoholDrop =
          containsAlcohol && t > 60 ? (3.0 / 60.0) : 0.0;

      // — Net change —
      gCurrent += riseRate - clearanceRate - iobMinute - alcoholDrop;

      // Physiological safety clamp
      gCurrent = gCurrent.clamp(40.0, 500.0);

      if (t % 5 == 0) {
        points.add(ProjectionPoint(
          timeMinutes: t,
          glucoseValue: double.parse(gCurrent.toStringAsFixed(1)),
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
      totalAvailableGlucose: double.parse(tag.toStringAsFixed(1)),
      riskLevel: riskLevel,
      summary: summary,
    );
  }
}
