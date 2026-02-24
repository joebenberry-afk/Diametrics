import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiametricsApp());
}

class DiametricsApp extends StatelessWidget {
  const DiametricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaMetrics',
      debugShowCheckedModeBanner: false,
      theme: SeniorTheme.lightTheme,
      darkTheme: SeniorTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
