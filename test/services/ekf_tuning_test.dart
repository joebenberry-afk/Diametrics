import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diametrics/models/glucose_log.dart';
import 'package:diametrics/models/meal_log.dart';
import 'package:diametrics/models/user_profile.dart';
import 'package:diametrics/repositories/health_data_repository.dart';
import 'package:diametrics/repositories/user_repository.dart';
import 'package:diametrics/services/ekf_tuning_service.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockHealthDataRepository extends Mock implements HealthDataRepository {}
class MockUserRepository extends Mock implements UserRepository {}

// ── Test Fixtures ──────────────────────────────────────────────────────────

UserProfile _testProfile() => UserProfile(
  id: 'profile-1',
  age: 35,
  gender: 'male',
  heightCm: 175.0,
  weightKg: 70.0,
  diabetesType: 'type2',
  diagnosisYear: 2020,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  metabolicClearanceRate: 0.010,
  insulinSensitivityFactor: 50.0,
  absorptionDelayBase: 40.0,
  ekfCovP1: 1.0,
  ekfCovISF: 1.0,
  ekfCovTMax: 1.0,
  tuningMealCount: 5,
);

MealLog _testMeal({String id = 'meal-1', DateTime? timestamp}) => MealLog(
  id: id,
  timestamp: timestamp ?? DateTime(2024, 6, 1, 12, 0),
  name: 'Lunch',
  carbohydrates: 45.0,
  proteins: 20.0,
  fats: 10.0,
  mealType: 'lunch',
);

GlucoseLog _preMealGlucose({DateTime? mealTime}) {
  final t = (mealTime ?? DateTime(2024, 6, 1, 12, 0))
      .subtract(const Duration(minutes: 5));
  return GlucoseLog(
    id: 'gl-pre',
    timestamp: t,
    value: 100.0,
    unit: 'mg/dL',
    context: 'pre_meal',
  );
}

GlucoseLog _postMealGlucose({
  required DateTime mealTime,
  required int minutesAfter,
  required String ctx,
  double value = 160.0,
}) {
  return GlucoseLog(
    id: 'gl-post',
    timestamp: mealTime.add(Duration(minutes: minutesAfter)),
    value: value,
    unit: 'mg/dL',
    context: ctx,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MockHealthDataRepository mockDataRepo;
  late MockUserRepository mockUserRepo;

  setUpAll(() {
    registerFallbackValue(_testProfile());
  });

  setUp(() {
    mockDataRepo = MockHealthDataRepository();
    mockUserRepo = MockUserRepository();
    // Default: saveProfile is a no-op
    when(() => mockUserRepo.saveProfile(any())).thenAnswer((_) async {});
  });

  group('EkfTuningService early-exit guards', () {
    test('does NOT update profile for non-post-meal context (fasting)', () async {
      final fastingLog = GlucoseLog(
        id: 'gl-1',
        timestamp: DateTime(2024, 6, 1, 8, 0),
        value: 95.0,
        unit: 'mg/dL',
        context: 'fasting',
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: fastingLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });

    test('does NOT update profile for bedtime context', () async {
      final bedtimeLog = GlucoseLog(
        id: 'gl-2',
        timestamp: DateTime(2024, 6, 1, 22, 0),
        value: 130.0,
        unit: 'mg/dL',
        context: 'bedtime',
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: bedtimeLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });

    test('does NOT update when profile is null', () async {
      when(() => mockUserRepo.getProfile()).thenAnswer((_) async => null);

      final glucoseLog = GlucoseLog(
        id: 'gl-3',
        timestamp: DateTime(2024, 6, 1, 14, 0),
        value: 150.0,
        unit: 'mg/dL',
        context: 'post_meal_120',
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });

    test('does NOT update when no meal is found in 3-hour window', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      // No meal logs at all
      when(() => mockDataRepo.getMealLogs()).thenAnswer((_) async => []);

      final glucoseLog = GlucoseLog(
        id: 'gl-4',
        timestamp: DateTime(2024, 6, 1, 14, 0),
        value: 150.0,
        unit: 'mg/dL',
        context: 'post_meal_120',
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });

    test('does NOT update when no pre-meal glucose in 30-min window', () async {
      final mealTime = DateTime(2024, 6, 1, 12, 0);
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      when(() => mockDataRepo.getMealLogs())
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      // Only a fasting reading 2 hours before -- outside 30-min window
      when(() => mockDataRepo.getGlucoseLogs()).thenAnswer((_) async => [
        GlucoseLog(
          id: 'gl-wrong',
          timestamp: mealTime.subtract(const Duration(hours: 2)),
          value: 95.0,
          unit: 'mg/dL',
          context: 'fasting',
        ),
      ]);

      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });

    test('does NOT update when >2 overlapping meals create superposition noise', () async {
      final mealTime = DateTime(2024, 6, 1, 12, 0);
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());

      // 3 overlapping meals between mealTime and readingTime (> _maxSuperpositionMeals=2)
      when(() => mockDataRepo.getMealLogs()).thenAnswer((_) async => [
        _testMeal(id: 'meal-0', timestamp: mealTime),
        _testMeal(id: 'meal-1', timestamp: mealTime.add(const Duration(minutes: 30))),
        _testMeal(id: 'meal-2', timestamp: mealTime.add(const Duration(minutes: 60))),
        _testMeal(id: 'meal-3', timestamp: mealTime.add(const Duration(minutes: 90))),
      ]);
      when(() => mockDataRepo.getGlucoseLogs()).thenAnswer((_) async => [
        _preMealGlucose(mealTime: mealTime),
      ]);

      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 160.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verifyNever(() => mockUserRepo.saveProfile(any()));
    });
  });

  group('EkfTuningService post_meal_30 updates', () {
    late DateTime mealTime;

    setUp(() {
      mealTime = DateTime(2024, 6, 1, 12, 0);

      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      when(() => mockDataRepo.getMealLogs())
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      when(() => mockDataRepo.getGlucoseLogs()).thenAnswer((_) async => [
        _preMealGlucose(mealTime: mealTime),
      ]);
    });

    test('saveProfile is called once after a post_meal_30 reading', () async {
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 170.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verify(() => mockUserRepo.saveProfile(any())).called(1);
    });

    test('post_meal_30: only tMax changes, p1 and ISF remain the same', () async {
      final profile = _testProfile();
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 170.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured =
          verify(() => mockUserRepo.saveProfile(captureAny())).captured;
      final saved = captured.last as UserProfile;

      // p1 and ISF must remain exactly as in original profile
      expect(saved.metabolicClearanceRate,
          closeTo(profile.metabolicClearanceRate, 1e-9));
      expect(saved.insulinSensitivityFactor,
          closeTo(profile.insulinSensitivityFactor, 1e-9));
      // tMax must have changed
      expect(saved.absorptionDelayBase,
          isNot(closeTo(profile.absorptionDelayBase, 1e-9)));
    });

    test('post_meal_30 positive innovation decreases tMax', () async {
      // actual=250 is well above any 30-min projection from baseline=100, 45g carbs
      // positive innovation -> tMaxSensitivity=-0.3 -> tMax decreases
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 250.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured =
          verify(() => mockUserRepo.saveProfile(captureAny())).captured;
      final saved = captured.last as UserProfile;

      expect(saved.absorptionDelayBase,
          lessThan(_testProfile().absorptionDelayBase),
          reason: 'Positive innovation should decrease tMax '
              '(food absorbed faster than model predicted)');
    });

    test('post_meal_30: tMax covariance shrinks after EKF update', () async {
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 200.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured =
          verify(() => mockUserRepo.saveProfile(captureAny())).captured;
      final saved = captured.last as UserProfile;

      // After update: covTMax grows by processNoise (0.1), then shrinks by Kalman gain.
      // Net: new_cov < initial_cov + processNoise
      const processNoise = 0.1;
      expect(saved.ekfCovTMax,
          lessThan(_testProfile().ekfCovTMax + processNoise),
          reason: 'EKF update should consume some covariance');
    });
  });

}
