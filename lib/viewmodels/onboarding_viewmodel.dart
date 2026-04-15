import 'package:diametrics/models/user_profile.dart';
import 'package:diametrics/repositories/user_repository.dart';
import 'package:diametrics/viewmodels/profile_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Provides a temporary state during the onboarding flow before saving to SQLite
final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, UserProfile>(OnboardingViewModel.new);

class OnboardingViewModel extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return UserProfile(
      id: const Uuid().v4(),
      age: 0,
      gender: '',
      heightCm: 0,
      weightKg: 0,
      diabetesType: '',
      diagnosisYear: DateTime.now().year,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

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
    String insulinCategory = 'standard_rapid',
    double insulinDiaMinutes = 240.0,
  }) {
    state = state.copyWith(
      usesInsulin: usesInsulin,
      usesPills: usesPills,
      usesCgm: usesCgm,
      insulinCategory: insulinCategory,
      insulinDiaMinutes: insulinDiaMinutes,
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
    final updated = state.copyWith(
      targetGlucoseMin: minTarget,
      targetGlucoseMax: maxTarget,
    );
    state = updated;
    await UserRepository().saveProfile(updated);
    // Set the profile state directly instead of invalidating (which would
    // trigger an async re-fetch, putting the provider into a loading state).
    // The router redirect checks isLoading and bounces back to splash if
    // true — causing a visible flash after onboarding completes.
    ref.read(userProfileProvider.notifier).setProfile(updated);
  }
}
