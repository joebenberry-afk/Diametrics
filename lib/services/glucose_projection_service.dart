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
    double p1 = 0.010, // ML parameter: metabolicClearanceRate (Glucose Effectiveness)
    double isf = 50.0, // ML parameter: insulinSensitivityFactor  
    double tMaxBase = 40.0, // ML parameter: absorptionDelayBase
  }) {
    // ── STEP 1: Total Available Glucose (TAG) ─────────────────────────
    final netCarbs = max(0.0, carbsGrams - fiberGrams);
    final tag = netCarbs + (0.58 * proteinGrams) + (0.10 * fatGrams);

    // ── STEP 2: Hovorka Parameters ────────────────────────────────────
    const double aG = 0.8; // Bioavailability factor

    // Time-to-maximum gut absorption (minutes)
    double tMax = tMaxBase;
    if (fatGrams > 40 || proteinGrams > 25) {
      tMax += 30.0; // High fat/protein delay (Sieradzki)
    }
    if (containsAlcohol) {
      tMax += 20.0; // Alcohol delays gastric emptying
    }

    // Glucose distribution volume (liters)
    final double vG = 0.16 * weightKg;

    // TAG to blood glucose conversion factor:
    // tag grams → mmol → mg/dL change = tag / 180 * 1000 * 180 / (vG_dL)
    // Simplifies to: tag * 1000 / (vG * 10) = tag * 100 / vG
    // This is the TOTAL potential rise if all glucose absorbed instantly.
    final double totalPotentialRise = aG * tag * 100.0 / vG;

    // IOB effect: spread evenly over the remaining DIA window.
    // isf = mg/dL drop per unit; insulinOnBoard in units.
    // Total drop over entire DIA; spread linearly declining with time.
    final double totalInsulinDrop = insulinOnBoard * isf;

    // ── STEP 3: Minute-by-minute simulation ───────────────────────────
    double gCurrent = baselineGlucose;
    final points = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];

    // Pre-calculate the unnormalized sum of gamma weights to normalize correctly
    // so that total absorption integrates exactly to totalPotentialRise.
    double gammaSum = 0.0;
    for (int t = 1; t <= _projectionMinutes; t++) {
      gammaSum += t * exp(-t / tMax);
    }
    // Avoid division by zero
    if (gammaSum < 1e-10) gammaSum = 1.0;

    for (int t = 1; t <= _projectionMinutes; t++) {
      // Hovorka gamma-shaped absorption — fraction of total glucose at minute t
      final double gammaWeight = t * exp(-t / tMax);
      // Rise rate normalized so total integral = totalPotentialRise
      double riseRate = totalPotentialRise * gammaWeight / gammaSum;

      // Caffeine amplifies absorption rate by 10%
      if (containsCaffeine) {
        riseRate *= 1.10;
      }

      // Glucose-dependent endogenous clearance (Bergman Minimal Model).
      // Only acts on glucose ABOVE fasting baseline (~90 mg/dL).
      double clearanceRate = max(0.0, gCurrent - 90.0) * p1;
      // Cap to max physiological clearance (~1.5 mg/dL/min without heavy insulin)
      clearanceRate = min(clearanceRate, 1.5);

      // Insulin-on-Board: spread uniformly over the projection window.
      // Only subtract if glucose is currently above hypoglycemic threshold (60)
      // to prevent driving into dangerous lows.
      final double iobMinute = gCurrent > 60.0
          ? (totalInsulinDrop / _projectionMinutes)
          : 0.0;

      // Alcohol: inhibits gluconeogenesis → extra ~3 mg/dL drop per hour after 60 min
      final double alcoholDrop =
          containsAlcohol && t > 60 ? 3.0 / 60.0 : 0.0;

      // Net rate of change
      final double deltaG = riseRate - clearanceRate - iobMinute - alcoholDrop;
      gCurrent += deltaG;

      // Safety clamp to physiological bounds
      gCurrent = gCurrent.clamp(10.0, 500.0);

      // Store every 5 minutes for plotting
      if (t % 5 == 0) {
        points.add(
          ProjectionPoint(
            timeMinutes: t,
            glucoseValue: double.parse(gCurrent.toStringAsFixed(1)),
          ),
        );
      }
    }

    // ── STEP 4: Extract metrics ───────────────────────────────────────
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

    // Human-readable summary
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
