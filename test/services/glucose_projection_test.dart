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
  });
}
