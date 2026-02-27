import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// Provides the current [UserProfile] to the entire app.
/// Returns `null` when onboarding has not been completed yet.
final userProfileProvider =
    AsyncNotifierProvider<ProfileViewModel, UserProfile?>(
      ProfileViewModel.new,
    );

class ProfileViewModel extends AsyncNotifier<UserProfile?> {
  late final UserRepository _repo;

  @override
  Future<UserProfile?> build() async {
    _repo = UserRepository();
    return _repo.getProfile();
  }

  /// Persists [profile] and updates the in-memory state.
  Future<void> updateProfile(UserProfile profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _repo.saveProfile(updated);
    state = AsyncData(updated);
  }
}
