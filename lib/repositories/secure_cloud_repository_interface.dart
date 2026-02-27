import '../../models/user_profile.dart';

/// Defines the contract for securely synchronizing health data with HIPAA compliant cloud backends.
/// Implementations of this repository MUST utilize `SecureStorageService` to retrieve API tokens
/// and securely encrypt HTTP payloads prior to transmission.
abstract class SecureCloudRepositoryInterface {
  /// Uploads user profile data securely.
  Future<void> syncProfile(UserProfile profile);

  /// Synchronizes aggregated health logs. Time series payload should be encrypted in transit.
  Future<void> syncHealthLogs(List<Map<String, dynamic>> logs);

  /// Validates session tokens and confirms backend connectivity using robust TLS.
  Future<bool> verifyConnection();
}
