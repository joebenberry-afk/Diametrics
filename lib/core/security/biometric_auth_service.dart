import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService() : _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to view sensitive health data',
  }) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException catch (_) {
      return false;
    }
  }
}
