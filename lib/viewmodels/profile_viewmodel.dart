import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// Provides the current [UserProfile] to the entire app.
/// Returns `null` when onboarding has not been completed yet.
final userProfileProvider =
    AsyncNotifierProvider<ProfileViewModel, UserProfile?>(ProfileViewModel.new);

class ProfileViewModel extends AsyncNotifier<UserProfile?> {
  late final UserRepository _repo;

  @override
  Future<UserProfile?> build() async {
    _repo = UserRepository();
    try {
      return await _repo.getProfile();
    } catch (e, st) {
      // If the DB query fails for any reason (schema mismatch, migration
      // failure, corruption), return null so the router sends the user to
      // onboarding rather than leaving the splash screen stuck forever.
      debugPrint('ProfileViewModel: getProfile() failed — $e\n$st');
      return null;
    }
  }

  /// Persists [profile] and updates the in-memory state.
  Future<void> updateProfile(UserProfile profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _repo.saveProfile(updated);
    state = AsyncData(updated);
  }

  /// Sets the in-memory profile state without a DB write.
  ///
  /// Used after onboarding where the profile has already been persisted
  /// by the caller. Avoids [ref.invalidate] which would put the provider
  /// into a loading state and cause the router to flash back to splash.
  void setProfile(UserProfile profile) {
    state = AsyncData(profile);
  }
}
