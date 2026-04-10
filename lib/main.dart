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

  // Essential blocking init — open & migrate the encrypted DB.
  // ReminderService (timezone parsing) is intentionally NOT awaited here
  // because tz.initializeTimeZones() is slow (~2-5s) and reminders are not
  // required before the UI becomes interactive.
  try {
    await initDatabase();
    await LegacyMigrationService.runIfNeeded();
  } catch (e, st) {
    debugPrint('Database initialization failed: $e\n$st');
    runApp(DatabaseErrorScreen(error: e));
    return;
  }

  // Start the app immediately.
  runApp(
    const ProviderScope(
      child: AuthWrapper(
        child: DiametricsApp(),
      ),
    ),
  );

  // ReminderService (timezone parsing) doesn't touch the DB — safe to fire now.
  unawaited(ReminderService.initialize().catchError(
    (e) => debugPrint('Reminder initialization failed: $e'),
  ));

  // Food seeding MUST start after the first frame renders.
  //
  // runApp() is non-blocking: main() continues before Flutter builds the widget
  // tree. If seeding starts here, its COUNT queries reach the DB isolate BEFORE
  // ProfileViewModel.getProfile(), causing it to queue behind a batch insert of
  // thousands of rows on first install — keeping userProfileProvider in
  // isLoading indefinitely.
  //
  // addPostFrameCallback fires after the first frame is built, by which time
  // ProfileViewModel.build() has already sent getProfile() to the isolate.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(db.populateLocalFoodsIfEmpty().catchError(
      (e) => debugPrint('Food DB seeding failed: $e'),
    ));
    unawaited(db.populateN5kIfEmpty().catchError(
      (e) => debugPrint('N5K seeding failed: $e'),
    ));
  });
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
