import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'database/db_instance.dart';
import 'package:diametrics/src/core/di/injection.dart';
import 'router/app_router.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  try {
    await ReminderService.initialize();
  } catch (e) {
    debugPrint('Reminder initialization failed: $e');
  }

  try {
    await initDatabase();
    await db.populateLocalFoodsIfEmpty();
    await db.populateN5kIfEmpty();
  } catch (e) {
    debugPrint('Database initialization or seeding failed: $e');
  }

  runApp(const ProviderScope(child: DiametricsApp()));
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
