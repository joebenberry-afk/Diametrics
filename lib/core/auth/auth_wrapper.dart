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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AppLockConfig.lastBackgroundedTime = DateTime.now();
    }
    if (state == AppLifecycleState.resumed) {
      if (AppLockConfig.ignoreNextResume) {
        AppLockConfig.ignoreNextResume = false;
        return;
      }
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
    await _attemptAuth();
  }

  Future<void> _attemptAuth() async {
    final auth = BiometricAuthService();
    final success = await auth.authenticate(
      reason: 'Authenticate to access DiaMetrics',
    );
    if (!mounted) return;
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
