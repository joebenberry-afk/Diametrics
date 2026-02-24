import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_instance.dart';
import '../services/sync_manager.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'dashboard/main_layout.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Initialize the AES-256 encrypted database
      await initDatabase();

      // 2. Populate the offline generic food database if it is empty
      await db.populateLocalFoodsIfEmpty();

      // 3. Initialize the SyncManager lifecycle observer
      SyncManager().initialize();

      // 4. Read onboarding status
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

      if (!mounted) return;

      // 5. Navigate to the correct screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              onboardingComplete ? const MainLayout() : const LoginScreen(),
        ),
      );
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
                      _initialize();
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
