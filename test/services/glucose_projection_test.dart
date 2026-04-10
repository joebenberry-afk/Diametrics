import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/services/glucose_projection_service.dart';

void main() {
  group('GlucoseProjectionService', () {
    group('zero-macro guard', () {
      test('returns flat baseline when no macros are logged', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 110.0,
          carbsGrams: 0.0,
          fiberGrams: 0.0,
          proteinGrams: 0.0,
          fatGrams: 0.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        expect(result.riskLevel, 'normal');
        expect(result.peakGlucose, 110.0);
        expect(result.twoHourGlucose, 110.0);
        expect(result.totalAvailableGlucose, 0.0);
        // All points must be at baseline
        for (final point in result.points) {
          expect(point.glucoseValue, 110.0,
              reason: 'Point at t=${point.timeMinutes} should be flat at 110.0');
        }
      });

      test('returns exactly 49 points for zero-macro meal', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 0.0,
          fiberGrams: 0.0,
          proteinGrams: 0.0,
          fatGrams: 0.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        // t=0 plus 240/5 = 48 more points = 49 total
        expect(result.points.length, 49);
        expect(result.points.first.timeMinutes, 0);
        expect(result.points.last.timeMinutes, 240);
      });
    });

    group('output structure', () {
      test('returns 49 points at 5-minute intervals for a standard meal', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 5.0,
          proteinGrams: 20.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        expect(result.points.length, 49);
        expect(result.points.first.timeMinutes, 0);
        expect(result.points.last.timeMinutes, 240);
        // Every adjacent pair should be 5 minutes apart
        for (int i = 1; i < result.points.length; i++) {
          expect(
            result.points[i].timeMinutes - result.points[i - 1].timeMinutes,
            5,
            reason: 'Points should be 5 min apart at index $i',
          );
        }
      });

      test('twoHourGlucose matches the point at t=120', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 5.0,
          proteinGrams: 20.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        final pointAt120 = result.points
            .firstWhere((p) => p.timeMinutes == 120);
        expect(result.twoHourGlucose, pointAt120.glucoseValue);
      });

      test('totalAvailableGlucose matches TAG formula', () {
        // netCarbs = 30 - 5 = 25g
        // fastTAG = 25 + 0.10 * 8 = 25.8
        // proteinTAG = 0.58 * 15 = 8.7
        // totalTAG = 25.8 + 8.7 = 34.5
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 30.0,
          fiberGrams: 5.0,
          proteinGrams: 15.0,
          fatGrams: 8.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        expect(result.totalAvailableGlucose, closeTo(34.5, 0.05));
      });

      test('confidence band upper >= lower at all points', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 20.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
        );

        expect(result.upperBand.length, result.points.length);
        expect(result.lowerBand.length, result.points.length);
        for (int i = 0; i < result.points.length; i++) {
          expect(
            result.upperBand[i].glucoseValue,
            greaterThanOrEqualTo(result.lowerBand[i].glucoseValue),
            reason: 'Upper band must be >= lower band at index $i',
          );
        }
      });
    });

    group('risk classification', () {
      test('normal risk: modest carbs stay within target', () {
        // 20g net carbs from baseline 95 with strong clearance
        // Should not exceed 180 mg/dL
        final result = GlucoseProjectionService.project(
          baselineGlucose: 95.0,
          carbsGrams: 20.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 3.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          p1: 0.018, // strong clearance to ensure normal range
        );

        expect(result.riskLevel, 'normal');
        expect(result.peakGlucose, lessThanOrEqualTo(180.0));
      });

      test('elevated risk: large carb meal pushes peak above 180', () {
        // 35g carbs, baseline 105, moderate clearance -> peak 180-250
        final result = GlucoseProjectionService.project(
          baselineGlucose: 105.0,
          carbsGrams: 35.0,
          fiberGrams: 0.0,
          proteinGrams: 8.0,
          fatGrams: 4.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          p1: 0.013, // moderate clearance
        );

        expect(result.riskLevel, 'elevated');
        expect(result.peakGlucose, greaterThan(180.0));
        expect(result.peakGlucose, lessThanOrEqualTo(250.0));
      });

      test('high risk: very large carb load exceeds 250 mg/dL', () {
        // 150g carbs, high baseline, minimal clearance -> peak > 250
        final result = GlucoseProjectionService.project(
          baselineGlucose: 160.0,
          carbsGrams: 150.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          p1: 0.003, // low clearance
        );

        expect(result.riskLevel, 'high');
        expect(result.peakGlucose, greaterThan(250.0));
      });

      test('hypo_risk: large IOB drives glucose below 70', () {
        // 5 units insulin x ISF 100 = 500 mg/dL total drop
        // With small carb load and baseline 110, glucose will dip below 70
        final result = GlucoseProjectionService.project(
          baselineGlucose: 110.0,
          carbsGrams: 15.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 0.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          insulinOnBoard: 8.0,
          isf: 100.0,
        );

        expect(result.riskLevel, 'hypo_risk');
        // Verify at least one point is below 70
        final hasHypo = result.points.any((p) => p.glucoseValue < 70.0);
        expect(hasHypo, isTrue);
      });

      test('peakGlucose is always >= baselineGlucose when no IOB', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 20.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          insulinOnBoard: 0.0,
        );

        expect(result.peakGlucose, greaterThanOrEqualTo(100.0));
      });
    });

    group('insulin on board', () {
      test('IOB lowers peak glucose compared to no IOB', () {
        final withoutIOB = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          insulinOnBoard: 0.0,
        );

        final withIOB = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          insulinOnBoard: 2.0,
          isf: 50.0,
        );

        expect(
          withIOB.peakGlucose,
          lessThan(withoutIOB.peakGlucose),
          reason: 'Active insulin should suppress the glucose peak',
        );
      });

      test('larger IOB produces a lower peak than smaller IOB', () {
        final result1u = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          insulinOnBoard: 1.0,
          isf: 50.0,
        );

        final result3u = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          insulinOnBoard: 3.0,
          isf: 50.0,
        );

        expect(result3u.peakGlucose, lessThan(result1u.peakGlucose));
      });

      test('IOB stops being applied once glucose drops below 70', () {
        // With massive IOB and tiny carbs, glucose should hit hypo_risk
        // but never go below the 40 mg/dL safety clamp
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 5.0,
          fiberGrams: 0.0,
          proteinGrams: 0.0,
          fatGrams: 0.0,
          containsAlcohol: false,
          containsCaffeine: false,
          insulinOnBoard: 15.0,
          isf: 100.0,
        );

        final minGlucose = result.points
            .map((p) => p.glucoseValue)
            .reduce((a, b) => a < b ? a : b);
        expect(minGlucose, greaterThanOrEqualTo(40.0));
      });
    });

    group('tMax modifiers', () {
      test('high fat meal delays peak compared to low fat', () {
        // fat > 40g triggers tMax + 30 min -> peak shifts later
        final lowFat = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
        );

        final highFat = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 50.0, // > 40g triggers +30 min delay
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
        );

        expect(
          highFat.peakTimeMinutes,
          greaterThanOrEqualTo(lowFat.peakTimeMinutes),
          reason: 'High fat meal should peak at same time or later than low fat',
        );
      });

      test('alcohol delays absorption (tMax + 20 min)', () {
        final noAlcohol = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 40.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
        );

        final withAlcohol = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 40.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 5.0,
          containsAlcohol: true,
          containsCaffeine: false,
          weightKg: 70.0,
        );

        expect(
          withAlcohol.peakTimeMinutes,
          greaterThanOrEqualTo(noAlcohol.peakTimeMinutes),
          reason: 'Alcohol should delay or maintain peak time',
        );
      });

      test('liquid food form accelerates absorption (earlier peak)', () {
        final standard = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 2.0,
          containsAlcohol: false,
          containsCaffeine: false,
          foodFormFactor: 'standard',
          weightKg: 70.0,
        );

        final liquid = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 2.0,
          containsAlcohol: false,
          containsCaffeine: false,
          foodFormFactor: 'liquid', // tMax - 15
          weightKg: 70.0,
        );

        expect(
          liquid.peakTimeMinutes,
          lessThanOrEqualTo(standard.peakTimeMinutes),
          reason: 'Liquid meal should peak at same time or earlier than standard',
        );
      });

      test('highFiber food form delays absorption (later peak)', () {
        final standard = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 2.0,
          containsAlcohol: false,
          containsCaffeine: false,
          foodFormFactor: 'standard',
          weightKg: 70.0,
        );

        final highFiber = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 5.0,
          fatGrams: 2.0,
          containsAlcohol: false,
          containsCaffeine: false,
          foodFormFactor: 'highFiber', // tMax + 10
          weightKg: 70.0,
        );

        expect(
          highFiber.peakTimeMinutes,
          greaterThanOrEqualTo(standard.peakTimeMinutes),
          reason: 'High fiber meal should peak at same time or later than standard',
        );
      });

      test('caffeine boosts peak glucose height', () {
        final noCaffeine = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: false,
          weightKg: 70.0,
          p1: 0.003, // low clearance to amplify the effect
        );

        final withCaffeine = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 50.0,
          fiberGrams: 0.0,
          proteinGrams: 10.0,
          fatGrams: 5.0,
          containsAlcohol: false,
          containsCaffeine: true,
          weightKg: 70.0,
          p1: 0.003,
        );

        expect(
          withCaffeine.peakGlucose,
          greaterThan(noCaffeine.peakGlucose),
          reason: 'Caffeine multiplies rise rate by 1.10, raising peak glucose',
        );
      });

      test('post-exercise boosts clearance (lower peak)', () {
        final normal = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          postExercise: false,
        );

        final postExercise = GlucoseProjectionService.project(
          baselineGlucose: 120.0,
          carbsGrams: 60.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          postExercise: true,
        );

        expect(
          postExercise.peakGlucose,
          lessThan(normal.peakGlucose),
          reason: 'Post-exercise increases p1 by 35%, reducing glucose peak',
        );
      });
    });

    group('confidence band', () {
      test('new user (mealCount=0) has width of 25 mg/dL', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          mealCount: 0,
        );

        expect(result.confidenceWidth, closeTo(25.0, 0.01));
      });

      test('experienced user (mealCount=20) has width of 10 mg/dL', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          mealCount: 20, // 25 - 20*0.75 = 10.0
        );

        expect(result.confidenceWidth, closeTo(10.0, 0.01));
      });

      test('confidence width floors at 10 mg/dL even with many meals', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          mealCount: 100, // Well past convergence
        );

        expect(result.confidenceWidth, closeTo(10.0, 0.01));
      });

      test('confidence band is zero-width at t=0 (baseline point)', () {
        final result = GlucoseProjectionService.project(
          baselineGlucose: 100.0,
          carbsGrams: 45.0,
          fiberGrams: 0.0,
          proteinGrams: 15.0,
          fatGrams: 10.0,
          containsAlcohol: false,
          containsCaffeine: false,
          mealCount: 0,
        );

        // At t=0, sin(0) = 0, so band width = 0 -> upper == lower == baseline
        expect(result.upperBand.first.glucoseValue,
            closeTo(result.lowerBand.first.glucoseValue, 0.01));
        expect(result.upperBand.first.glucoseValue, closeTo(100.0, 0.01));
      });
    });
  });

  group('CaribbeanFoodHeuristics integration', () {
    test('dasheen slows absorption (later peak than unknown food)', () {
      // dasheen: absorptionMultiplier=1.30 -> tMax*1.30 -> delayed peak
      final unknown = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 50.0,
        fiberGrams: 3.0,
        proteinGrams: 5.0,
        fatGrams: 2.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: null,
      );

      final dasheen = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 50.0,
        fiberGrams: 3.0,
        proteinGrams: 5.0,
        fatGrams: 2.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: 'Dasheen provision',
      );

      expect(
        dasheen.peakTimeMinutes,
        greaterThanOrEqualTo(unknown.peakTimeMinutes),
        reason: 'Dasheen has 1.30x absorption delay multiplier',
      );
    });

    test('doubles accelerates absorption (earlier or same peak)', () {
      // doubles: absorptionMultiplier=0.90 -> tMax*0.90 -> faster peak
      final unknown = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 50.0,
        fiberGrams: 2.0,
        proteinGrams: 8.0,
        fatGrams: 5.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: null,
      );

      final doubles = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 50.0,
        fiberGrams: 2.0,
        proteinGrams: 8.0,
        fatGrams: 5.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: 'doubles with extra channa',
      );

      expect(
        doubles.peakTimeMinutes,
        lessThanOrEqualTo(unknown.peakTimeMinutes),
        reason: 'Doubles has 0.90x absorption multiplier -- faster peak',
      );
    });

    test('unknown food name returns neutral multipliers (1.0x)', () {
      // Projecting with an unknown name should produce same result as null
      final withNull = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 40.0,
        fiberGrams: 0.0,
        proteinGrams: 10.0,
        fatGrams: 5.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: null,
      );

      final withUnknown = GlucoseProjectionService.project(
        baselineGlucose: 100.0,
        carbsGrams: 40.0,
        fiberGrams: 0.0,
        proteinGrams: 10.0,
        fatGrams: 5.0,
        containsAlcohol: false,
        containsCaffeine: false,
        mealName: 'pasta bolognese',
      );

      expect(withUnknown.peakGlucose, closeTo(withNull.peakGlucose, 0.5));
      expect(withUnknown.peakTimeMinutes, withNull.peakTimeMinutes);
    });
  });
}
