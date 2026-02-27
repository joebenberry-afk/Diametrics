import 'dart:math';
import '../models/projection_result.dart';

/// Phase 1 blood glucose projection using a simplified Hovorka gut absorption
/// model with Total Available Glucose (TAG) and Insulin-on-Board (IOB) safety
/// deduction.
///
/// References:
///   - Hovorka R. et al. (2004) Compartmental model for gut absorption
///   - TAG formula: Carbs + 0.58×Protein + 0.10×Fat
///   - Sieradzki (2010): high-fat/protein delay for mixed meals
class GlucoseProjectionService {
  GlucoseProjectionService._();

  /// Duration of the projection in minutes (4 hours).
  static const int _projectionMinutes = 240;

  /// Default insulin sensitivity factor (mg/dL drop per unit of insulin).
  static const double _defaultISF = 50.0;

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
  }) {
    // ── STEP 1: Total Available Glucose (TAG) ─────────────────────────
    final netCarbs = max(0.0, carbsGrams - fiberGrams);
    final tag = netCarbs + (0.58 * proteinGrams) + (0.10 * fatGrams);

    // ── STEP 2: Hovorka Parameters ────────────────────────────────────
    const double aG = 0.8; // Bioavailability
    final double dG = tag / 180.0 * 1000.0; // mmol glucose dose

    // Time-to-maximum gut absorption (minutes)
    double tMax = 40.0;
    if (fatGrams > 40 || proteinGrams > 25) {
      tMax += 30.0; // High fat/protein delay (Sieradzki)
    }
    if (containsAlcohol) {
      tMax += 20.0; // Alcohol delays gastric emptying
    }

    // Glucose distribution volume (liters)
    final double vG = 0.16 * weightKg;

    // Fractional clearance rate (per minute)
    const double p1 = 0.02;

    // IOB insulin action rate (mg/dL per minute over 4-hour DIA)
    final double iobRate = insulinOnBoard * _defaultISF / _projectionMinutes;

    // ── STEP 3: Minute-by-minute simulation ───────────────────────────
    double gCurrent = baselineGlucose;
    final points = <ProjectionPoint>[
      ProjectionPoint(timeMinutes: 0, glucoseValue: baselineGlucose),
    ];

    for (int t = 1; t <= _projectionMinutes; t++) {
      // Hovorka gut absorption rate (mmol/min)
      // R_a(t) = A_G × D_G × t × e^(-t/t_max) / t_max²
      final double ra = aG * dG * t * exp(-t / tMax) / (tMax * tMax);

      // Convert R_a from mmol/min to mg/dL/min:
      // mmol/min × 180 mg/mmol / (V_G L × 10 dL/L)
      double riseRate = ra * 180.0 / (vG * 10.0);

      // Caffeine amplifies absorption by 10%
      if (containsCaffeine) {
        riseRate *= 1.10;
      }

      // Glucose-dependent clearance
      final double clearanceRate = gCurrent * p1;

      // Alcohol: inhibits gluconeogenesis → ~3 mg/dL drop per hour after 60 min
      final double alcoholDrop =
          containsAlcohol && t > 60 ? 3.0 / 60.0 : 0.0;

      // Net rate of change
      final dG_ = riseRate - clearanceRate - iobRate - alcoholDrop;
      gCurrent += dG_;

      // Safety clamp to physiological bounds
      gCurrent = gCurrent.clamp(30.0, 500.0);

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
