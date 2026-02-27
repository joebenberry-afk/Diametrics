import 'package:diametrics/models/user_profile.dart';
import 'package:diametrics/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Provides a temporary state during the onboarding flow before saving to SQLite
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, UserProfile>((ref) {
      final userRepository = UserRepository();
      return OnboardingViewModel(userRepository);
    });

class OnboardingViewModel extends StateNotifier<UserProfile> {
  final UserRepository _userRepository;

  OnboardingViewModel(this._userRepository)
    : super(
        UserProfile(
          id: const Uuid().v4(),
          age: 0,
          gender: '',
          heightCm: 0,
          weightKg: 0,
          diabetesType: '',
          diagnosisYear: DateTime.now().year,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

  // Disclaimer
  void agreeToDisclaimer() {
    state = state.copyWith(hasAgreedToDisclaimer: true);
  }

  // Demographics
  void updateDemographics({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    double? targetWeightKg,
  }) {
    state = state.copyWith(
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      targetWeightKg: targetWeightKg,
    );
  }

  // Diabetes Context
  void updateDiabetesContext({
    required String diabetesType,
    required int diagnosisYear,
    required String unit,
  }) {
    state = state.copyWith(
      diabetesType: diabetesType,
      diagnosisYear: diagnosisYear,
      preferredGlucoseUnit: unit,
    );
  }

  // Management
  void updateMedicationFlags({
    required bool usesInsulin,
    required bool usesPills,
    required bool usesCgm,
  }) {
    state = state.copyWith(
      usesInsulin: usesInsulin,
      usesPills: usesPills,
      usesCgm: usesCgm,
    );
  }

  // Targets
  void updateTargets({required double min, required double max}) {
    state = state.copyWith(targetGlucoseMin: min, targetGlucoseMax: max);
  }

  // Finalize Targets and Onboarding
  Future<void> updateTargetsAndFinish({
    required double minTarget,
    required double maxTarget,
  }) async {
    updateTargets(min: minTarget, max: maxTarget);
    await _userRepository.saveProfile(state);
  }
}
