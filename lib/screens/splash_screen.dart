import 'package:flutter/material.dart';

import '../database/db_instance.dart';
import '../services/sync_manager.dart';
import '../theme.dart';
import '../widgets/auth_wrapper.dart';

/// SplashScreen - Displays the app branding while async initialization runs.
///
/// This screen is shown immediately on app launch so the user sees a branded
/// loading screen instead of a blank white native splash. All heavy async
/// work (database init, CSV population, preference reads) runs here.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _errorMessage; // Keep this for error display

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize encrypted database with secure key management
      await initDatabase();

      // 2. Populate offline clinical food database if empty
      await db.populateLocalFoodsIfEmpty();

      // 3. Initialize background sync manager
      SyncManager().initialize();

      // Add a minimum delay to show off the splash screen animations
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Since this is a clinical app, we bypass login directly to the biometric AuthWrapper
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to start: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeniorTheme.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot / App Icon
              Semantics(
                label: 'DiaMetrics Robot Mascot',
                child: Image.asset(
                  'assets/images/robot_mascot.png',
                  width: 140,
                  height: 140,
                ),
              ),
              const SizedBox(height: 24),

              // App title
              Text(
                'DiaMetrics',
                style: SeniorTheme.headingStyle.copyWith(
                  fontSize: 36,
                  color: SeniorTheme.primaryCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),

              if (_errorMessage != null) ...[
                // Error state
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: SeniorTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: SeniorTheme.bodyStyle.copyWith(
                    color: SeniorTheme.errorRed,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _initializeApp();
                    },
                    child: Text('Retry', style: SeniorTheme.buttonTextStyle),
                  ),
                ),
              ] else ...[
                // Loading state
                const CircularProgressIndicator(
                  color: SeniorTheme.primaryCyan,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: SeniorTheme.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
