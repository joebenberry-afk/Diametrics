import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'database/db_instance.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the AES-256 encrypted database
  await initDatabase();

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
      home: onboardingComplete ? const MainLayout() : const LoginScreen(),
    );
  }
}
