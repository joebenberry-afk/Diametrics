import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'database/db_instance.dart';
import 'package:diametrics/src/core/di/injection.dart';
import 'services/reminder_service.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/onboarding/onboarding_wrapper.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await ReminderService.initialize();

  // Initialize & seed the Drift food databases (required for RAG pipeline).
  await initDatabase();
  await db.populateLocalFoodsIfEmpty(); // 7,803 USDA foods (carbs)
  await db.populateN5kIfEmpty();        // 555 N5K ingredients (full macros)

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
      themeMode: ThemeMode.system,
      home: const _StartupRouter(),
    );
  }
}

/// Routes to OnboardingWrapper on first launch (no profile),
/// or DashboardView when a profile already exists.
class _StartupRouter extends ConsumerWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const SplashScreen(),
      error: (e, s) => const OnboardingWrapper(),
      data: (profile) =>
          profile != null ? const DashboardView() : const OnboardingWrapper(),
    );
  }
}
