import '../models/glucose_log.dart';
import '../repositories/health_data_repository.dart';
import '../repositories/user_repository.dart';
import 'ekf_tuning_service.dart';

/// Adaptive Parameter Tuning Service (DEPRECATED)
///
/// This class is preserved for backward compatibility. All tuning logic
/// has been migrated to [EkfTuningService], which uses an Extended Kalman
/// Filter instead of gradient descent for more robust state estimation.
///
/// The EKF provides:
///   - Noise-resistant parameter updates (bad test strips won't corrupt ISF)
///   - Mathematically principled uncertainty tracking via covariance
///   - Meal superposition (learning continues through snacking)
///
/// See [EkfTuningService] for the full implementation.
@Deprecated('Use EkfTuningService directly. This class delegates to it.')
class AdaptiveTuningService {
  AdaptiveTuningService._();

  /// Delegates to [EkfTuningService.tuneFromGlucoseLog].
  static Future<void> tuneFromGlucoseLog({
    required GlucoseLog glucoseLog,
    required HealthDataRepository dataRepo,
    required UserRepository userRepo,
  }) {
    return EkfTuningService.tuneFromGlucoseLog(
      glucoseLog: glucoseLog,
      dataRepo: dataRepo,
      userRepo: userRepo,
    );
  }
}
