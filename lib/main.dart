import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'package:diametrics/src/core/di/injection.dart';
import 'services/reminder_service.dart';
import 'views/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await ReminderService.initialize();
  runApp(const ProviderScope(child: DiametricsApp()));
}

class DiametricsApp extends StatelessWidget {
  const DiametricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaMetrics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // Prefer system for dark/light mode switching
      home: const DashboardView(),
    );
  }
}
