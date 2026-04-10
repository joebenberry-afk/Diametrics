import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/biometric_auth_service.dart';
import '../theme/app_tokens.dart';
import '../../config/app_lock_config.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _authInProgress = false;

  // True until the first genuine background/resume cycle after launch.
  // Prevents spurious locks from lifecycle events fired during startup
  // (e.g., initial 'resumed' delivery, notification plugin init, etc.)
  bool _startupGuard = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Clear the startup guard after the first frame so normal lock logic
    // applies from the second lifecycle event onwards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startupGuard = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Don't record background time during startup or while auth is showing —
      // the biometric dialog on Samsung One UI triggers paused/resumed itself.
      if (!_startupGuard && !_authInProgress) {
        AppLockConfig.lastBackgroundedTime = DateTime.now();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (_startupGuard) return; // ignore events during startup
      if (AppLockConfig.ignoreNextResume) {
        AppLockConfig.ignoreNextResume = false;
        return;
      }
      if (_authInProgress) return; // already authenticating
      final bg = AppLockConfig.lastBackgroundedTime;
      if (bg != null &&
          DateTime.now().difference(bg) >= AppLockConfig.lockTimeout) {
        _triggerLock();
      }
    }
  }

  Future<void> _triggerLock() async {
    if (_locked || _authInProgress) return;
    setState(() {
      _locked = true;
      _authInProgress = true;
    });
    // Tell the wrapper to ignore lifecycle events caused by the biometric
    // dialog itself (Samsung One UI and some other OEMs trigger paused/resumed
    // when the fingerprint overlay appears).
    AppLockConfig.ignoreNextResume = true;
    await _attemptAuth();
  }

  Future<void> _attemptAuth() async {
    final auth = BiometricAuthService();
    final success = await auth.authenticate(
      reason: 'Authenticate to access DiaMetrics',
    );
    if (!mounted) return;
    if (success) {
      // Clear the background timestamp so any subsequent resumed event
      // (e.g., a second lifecycle callback from the OEM after the dialog
      // closes) doesn't immediately re-lock.
      AppLockConfig.lastBackgroundedTime = null;
    }
    setState(() {
      _authInProgress = false;
      _locked = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppThemeTokens.bgBackgroundDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  color: AppThemeTokens.textPrimaryInverse,
                  size: 64,
                ),
                const SizedBox(height: AppThemeTokens.spaceLg),
                const Text(
                  'DiaMetrics is locked',
                  style: TextStyle(
                    color: AppThemeTokens.textPrimaryInverse,
                    fontSize: 18,
                    fontFamily: AppThemeTokens.fontFamily,
                  ),
                ),
                const SizedBox(height: AppThemeTokens.spaceMd),
                if (!_authInProgress)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeTokens.brandSecondary,
                      foregroundColor: AppThemeTokens.textPrimaryInverse,
                      minimumSize: const Size(
                        160,
                        AppThemeTokens.minTapTarget,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppThemeTokens.radiusMd,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _authInProgress = true);
                      _attemptAuth();
                    },
                    child: const Text('Unlock'),
                  )
                else
                  const CircularProgressIndicator(
                    color: AppThemeTokens.brandAccent,
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
