import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../screens/dashboard/main_layout.dart';
import '../theme.dart';

/// A wrapper that enforces biometric/PIN authentication when the app is launched
/// or resumed from the background to protect sensitive medical data.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the app is resumed from the background, require re-authentication
    if (state == AppLifecycleState.resumed) {
      if (!_isAuthenticated && !_isAuthenticating) {
        _authenticate();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Lock the app as soon as it goes to the background
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Unlock DiaMetrics to access your medical data',
        );

        setState(() {
          _isAuthenticated = didAuthenticate;
        });
      } else {
        // Device doesn't support auth or it's not set up.
        // In a strict clinical app, we might force them to set it up, but for now we let them in.
        setState(() {
          _isAuthenticated = true;
        });
      }
    } on PlatformException {
      setState(() {
        _isAuthenticated = false;
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const MainLayout();
    }

    // Locked Screen UI
    return Scaffold(
      backgroundColor: SeniorTheme.surfaceBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: SeniorTheme.primaryCyan,
            ),
            const SizedBox(height: 24),
            Text(
              'App Locked',
              style: SeniorTheme.headingStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DiaMetrics requires biometric or\ndevice authentication to proceed.',
              textAlign: TextAlign.center,
              style: SeniorTheme.bodyStyle.copyWith(
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 48),
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint, color: Colors.black),
                label: const Text(
                  'Unlock',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeniorTheme.primaryCyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(color: SeniorTheme.primaryCyan),
          ],
        ),
      ),
    );
  }
}
