import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/database_error_screen.dart';
import 'database/db_instance.dart';
import 'package:diametrics/src/core/di/injection.dart';
import 'router/app_router.dart';
import 'services/legacy_migration_service.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  try {
    await ReminderService.initialize();
  } catch (e) {
    debugPrint('Reminder initialization failed: $e');
  }

  // Essential blocking init — open & migrate the encrypted DB
  try {
    await initDatabase();
    await LegacyMigrationService.runIfNeeded();
  } catch (e, st) {
    debugPrint('Database initialization failed: $e\n$st');
    runApp(DatabaseErrorScreen(error: e));
    return;
  }

  // Start the app immediately — food seeding happens in the background
  runApp(
    const ProviderScope(
      child: AuthWrapper(
        child: DiametricsApp(),
      ),
    ),
  );

  // Seed food reference data after the UI is live (non-blocking)
  unawaited(db.populateLocalFoodsIfEmpty().catchError(
    (e) => debugPrint('Food DB seeding failed: $e'),
  ));
  unawaited(db.populateN5kIfEmpty().catchError(
    (e) => debugPrint('N5K seeding failed: $e'),
  ));
}

class DiametricsApp extends ConsumerWidget {
  const DiametricsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DiaMetrics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
