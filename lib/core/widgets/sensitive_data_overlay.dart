import 'dart:ui';
import 'package:flutter/material.dart';
import '../security/biometric_auth_service.dart';

/// A widget that intentionally obscures sensitive health data until
/// the user authenticates with device biometrics (FaceID/TouchID).
/// This satisfies basic HIPAA compliance for shoulder-surfing and
/// unauthorized physical device access.
class SensitiveDataOverlay extends StatefulWidget {
  final Widget child;
  final bool initiallyObscured;

  const SensitiveDataOverlay({
    super.key,
    required this.child,
    this.initiallyObscured = true,
  });

  @override
  State<SensitiveDataOverlay> createState() => _SensitiveDataOverlayState();
}

class _SensitiveDataOverlayState extends State<SensitiveDataOverlay> {
  late bool _isObscured;
  final BiometricAuthService _authService = BiometricAuthService();

  @override
  void initState() {
    super.initState();
    _isObscured = widget.initiallyObscured;
  }

  Future<void> _unlockData() async {
    if (!_isObscured) return;

    final authenticated = await _authService.authenticate();
    if (authenticated) {
      if (mounted) {
        setState(() {
          _isObscured = false;
        });
      }

      // Auto-lock after 1 minute for security
      Future.delayed(const Duration(minutes: 1), () {
        if (mounted) {
          setState(() {
            _isObscured = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isObscured) {
      return widget.child;
    }

    return GestureDetector(
      onTap: _unlockData,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ), // Match AppThemeTokens radius
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to unlock',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
