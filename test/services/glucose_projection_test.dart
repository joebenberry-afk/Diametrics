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
  });
}
