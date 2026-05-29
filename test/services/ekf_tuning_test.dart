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
    // Needed so any() can match the DateTime arg of the windowed repo queries.
    registerFallbackValue(DateTime(2024, 1, 1));
  });

  setUp(() {
    mockDataRepo = MockHealthDataRepository();
    mockUserRepo = MockUserRepository();
    // Default: updateEkfParameters is a no-op
    when(() => mockUserRepo.updateEkfParameters(
      profileId: any(named: 'profileId'),
      metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
      insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
      absorptionDelayBase: any(named: 'absorptionDelayBase'),
      tuningMealCount: any(named: 'tuningMealCount'),
      fastingSetpoint: any(named: 'fastingSetpoint'),
      ekfCovP1: any(named: 'ekfCovP1'),
      ekfCovISF: any(named: 'ekfCovISF'),
      ekfCovTMax: any(named: 'ekfCovTMax'),
    )).thenAnswer((_) async {});
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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
    });

    test('does NOT update when no meal is found in 3-hour window', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      // No meal logs at all
      when(() => mockDataRepo.getMealLogsSince(any())).thenAnswer((_) async => []);

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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
    });

    test('does NOT update when no pre-meal glucose in 30-min window', () async {
      final mealTime = DateTime(2024, 6, 1, 12, 0);
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      when(() => mockDataRepo.getMealLogsSince(any()))
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      // Only a fasting reading 2 hours before -- outside 30-min window
      when(() => mockDataRepo.getGlucoseLogsSince(any())).thenAnswer((_) async => [
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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
    });

    test('does NOT update when >2 overlapping meals create superposition noise', () async {
      final mealTime = DateTime(2024, 6, 1, 12, 0);
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());

      // 3 overlapping meals between mealTime and readingTime (> _maxSuperpositionMeals=2)
      when(() => mockDataRepo.getMealLogsSince(any())).thenAnswer((_) async => [
        _testMeal(id: 'meal-0', timestamp: mealTime),
        _testMeal(id: 'meal-1', timestamp: mealTime.add(const Duration(minutes: 30))),
        _testMeal(id: 'meal-2', timestamp: mealTime.add(const Duration(minutes: 60))),
        _testMeal(id: 'meal-3', timestamp: mealTime.add(const Duration(minutes: 90))),
      ]);
      when(() => mockDataRepo.getGlucoseLogsSince(any())).thenAnswer((_) async => [
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

      verifyNever(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      ));
    });
  });

  group('EkfTuningService post_meal_30 updates', () {
    late DateTime mealTime;

    setUp(() {
      mealTime = DateTime(2024, 6, 1, 12, 0);

      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      when(() => mockDataRepo.getMealLogsSince(any()))
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      when(() => mockDataRepo.getGlucoseLogsSince(any())).thenAnswer((_) async => [
        _preMealGlucose(mealTime: mealTime),
      ]);
    });

    test('updateEkfParameters is called once after a post_meal_30 reading', () async {
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

      verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      )).called(1);
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

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      // captured[0] = metabolicClearanceRate
      // captured[1] = insulinSensitivityFactor
      // captured[2] = absorptionDelayBase
      // captured[3] = tuningMealCount
      // captured[4] = fastingSetpoint
      // captured[5] = ekfCovP1
      // captured[6] = ekfCovISF
      // captured[7] = ekfCovTMax
      final mcr = captured[0] as double;
      final isf = captured[1] as double;
      final tMax = captured[2] as double;

      // p1 and ISF must remain exactly as in original profile
      expect(mcr, closeTo(profile.metabolicClearanceRate, 1e-9));
      expect(isf, closeTo(profile.insulinSensitivityFactor, 1e-9));
      // tMax must have changed
      expect(tMax, isNot(closeTo(profile.absorptionDelayBase, 1e-9)));
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

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final tMax = captured[2] as double;

      expect(tMax,
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

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final ekfCovTMax = captured[7] as double;

      // After update: covTMax grows by processNoise (0.1), then shrinks by Kalman gain.
      // Net: new_cov < initial_cov + processNoise
      const processNoise = 0.1;
      expect(ekfCovTMax,
          lessThan(_testProfile().ekfCovTMax + processNoise),
          reason: 'EKF update should consume some covariance');
    });
  });

  group('EkfTuningService post_meal_120 updates', () {
    late DateTime mealTime;

    setUp(() {
      mealTime = DateTime(2024, 6, 1, 12, 0);

      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => _testProfile());
      when(() => mockDataRepo.getMealLogsSince(any()))
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      when(() => mockDataRepo.getGlucoseLogsSince(any())).thenAnswer((_) async => [
        _preMealGlucose(mealTime: mealTime),
      ]);
    });

    test('updateEkfParameters is called once after a post_meal_120 reading', () async {
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 165.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: any(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: any(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: any(named: 'absorptionDelayBase'),
        tuningMealCount: any(named: 'tuningMealCount'),
        fastingSetpoint: any(named: 'fastingSetpoint'),
        ekfCovP1: any(named: 'ekfCovP1'),
        ekfCovISF: any(named: 'ekfCovISF'),
        ekfCovTMax: any(named: 'ekfCovTMax'),
      )).called(1);
    });

    test('post_meal_120: p1 and ISF change; tMax stays the same', () async {
      final profile = _testProfile();
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 200.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final mcr = captured[0] as double;
      final isf = captured[1] as double;
      final tMax = captured[2] as double;

      // tMax must be unchanged for post_meal_120
      expect(tMax, closeTo(profile.absorptionDelayBase, 1e-9));
      // p1 and ISF must have changed
      expect(mcr, isNot(closeTo(profile.metabolicClearanceRate, 1e-9)));
      expect(isf, isNot(closeTo(profile.insulinSensitivityFactor, 1e-9)));
    });

    test('positive innovation: p1 decreases (clearance was overestimated)', () async {
      // actual=350 is well above the 120-min projection from baseline=100, 45g carbs.
      // positive innovation -> p1Sensitivity=-0.001 -> p1 decreases
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 350.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final mcr = captured[0] as double;

      expect(mcr,
          lessThan(_testProfile().metabolicClearanceRate),
          reason: 'Positive innovation: body cleared glucose slower than '
              'predicted, so p1 should decrease');
    });

    test('positive innovation: ISF increases (insulin had less effect)', () async {
      // actual=350 is well above the 120-min projection from baseline=100, 45g carbs.
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 350.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final isf = captured[1] as double;

      expect(isf,
          greaterThan(_testProfile().insulinSensitivityFactor),
          reason: 'Positive innovation: insulin was less effective, '
              'so ISF should increase');
    });

    test('tuningMealCount increments by 1 after update', () async {
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 200.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final mealCount = captured[3] as int;

      expect(mealCount, _testProfile().tuningMealCount + 1);
    });

    test('"post_meal" context triggers the same 120-min update path', () async {
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 90,
        ctx: 'post_meal', // same code path as post_meal_120
        value: 200.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final tMax = captured[2] as double;

      // tMax must be unchanged (120-min path, not 30-min path)
      expect(tMax, closeTo(_testProfile().absorptionDelayBase, 1e-9));
    });
  });

  group('EkfTuningService parameter bounds clamping', () {
    late DateTime mealTime;

    UserProfile nearLowerBound() => UserProfile(
      id: 'profile-low',
      age: 35,
      gender: 'male',
      heightCm: 175.0,
      weightKg: 70.0,
      diabetesType: 'type2',
      diagnosisYear: 2020,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      // Parameters close to lower bounds
      metabolicClearanceRate: 0.0021,
      insulinSensitivityFactor: 21.0,
      absorptionDelayBase: 21.0,
      ekfCovP1: 100.0,   // high cov -> large Kalman gain -> large update step
      ekfCovISF: 100.0,
      ekfCovTMax: 100.0,
      tuningMealCount: 5,
    );

    UserProfile nearUpperBound() => UserProfile(
      id: 'profile-high',
      age: 35,
      gender: 'male',
      heightCm: 175.0,
      weightKg: 70.0,
      diabetesType: 'type2',
      diagnosisYear: 2020,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      // Parameters close to upper bounds
      metabolicClearanceRate: 0.0299,
      insulinSensitivityFactor: 149.0,
      absorptionDelayBase: 89.0,
      ekfCovP1: 100.0,
      ekfCovISF: 100.0,
      ekfCovTMax: 100.0,
      tuningMealCount: 5,
    );

    setUp(() {
      mealTime = DateTime(2024, 6, 1, 12, 0);
      when(() => mockDataRepo.getMealLogsSince(any()))
          .thenAnswer((_) async => [_testMeal(timestamp: mealTime)]);
      when(() => mockDataRepo.getGlucoseLogsSince(any())).thenAnswer((_) async => [
        _preMealGlucose(mealTime: mealTime),
      ]);
    });

    test('p1 never falls below 0.002', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearLowerBound());

      // Large positive innovation -> p1 wants to decrease below 0.002 -> clamped
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 300.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final mcr = captured[0] as double;

      expect(mcr, greaterThanOrEqualTo(0.002));
    });

    test('p1 never exceeds 0.030', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearUpperBound());

      // Large negative innovation -> p1 wants to increase above 0.030 -> clamped
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 50.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final mcr = captured[0] as double;

      expect(mcr, lessThanOrEqualTo(0.030));
    });

    test('ISF never falls below 20.0', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearLowerBound());

      // Negative innovation -> ISF wants to decrease below 20 -> clamped
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 50.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final isf = captured[1] as double;

      expect(isf, greaterThanOrEqualTo(20.0));
    });

    test('ISF never exceeds 150.0', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearUpperBound());

      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 120,
        ctx: 'post_meal_120',
        value: 300.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final isf = captured[1] as double;

      expect(isf, lessThanOrEqualTo(150.0));
    });

    test('tMax never falls below 20.0', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearLowerBound());

      // Large 30-min reading -> big positive innovation -> tMax wants to go below 20
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 300.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final tMax = captured[2] as double;

      expect(tMax, greaterThanOrEqualTo(20.0));
    });

    test('tMax never exceeds 90.0', () async {
      when(() => mockUserRepo.getProfile())
          .thenAnswer((_) async => nearUpperBound());

      // Low 30-min reading -> negative innovation -> tMax wants to go above 90
      final glucoseLog = _postMealGlucose(
        mealTime: mealTime,
        minutesAfter: 30,
        ctx: 'post_meal_30',
        value: 50.0,
      );

      await EkfTuningService.tuneFromGlucoseLog(
        glucoseLog: glucoseLog,
        dataRepo: mockDataRepo,
        userRepo: mockUserRepo,
      );

      final captured = verify(() => mockUserRepo.updateEkfParameters(
        profileId: any(named: 'profileId'),
        metabolicClearanceRate: captureAny(named: 'metabolicClearanceRate'),
        insulinSensitivityFactor: captureAny(named: 'insulinSensitivityFactor'),
        absorptionDelayBase: captureAny(named: 'absorptionDelayBase'),
        tuningMealCount: captureAny(named: 'tuningMealCount'),
        fastingSetpoint: captureAny(named: 'fastingSetpoint'),
        ekfCovP1: captureAny(named: 'ekfCovP1'),
        ekfCovISF: captureAny(named: 'ekfCovISF'),
        ekfCovTMax: captureAny(named: 'ekfCovTMax'),
      )).captured;
      final tMax = captured[2] as double;

      expect(tMax, lessThanOrEqualTo(90.0));
    });
  });
}
