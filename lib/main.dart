import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'package:diametrics/screens/onboarding/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

  runApp(DiametricsApp(onboardingComplete: onboardingComplete));
}

class DiametricsApp extends StatelessWidget {
  final bool onboardingComplete;

  const DiametricsApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaMetrics',
      debugShowCheckedModeBanner: false,
      theme: SeniorTheme.lightTheme,
      darkTheme: SeniorTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: onboardingComplete ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
