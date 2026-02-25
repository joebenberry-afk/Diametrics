/// Global configuration for the app lock lifecycle behavior.
///
/// Used to prevent the biometric lock screen from triggering when the app
/// is briefly backgrounded (e.g., opening the image picker gallery/camera).
class AppLockConfig {
  /// When true, the next [AppLifecycleState.resumed] event will be ignored
  /// by the auth wrapper. Automatically reset to false after being consumed.
  static bool ignoreNextResume = false;

  /// Timestamp of when the app was last pushed to the background.
  static DateTime? lastBackgroundedTime;

  /// The minimum duration the app must be in the background before the
  /// lock screen is triggered. Brief interruptions (gallery, camera, etc.)
  /// will not trigger re-authentication.
  static const Duration lockTimeout = Duration(minutes: 1);
}
