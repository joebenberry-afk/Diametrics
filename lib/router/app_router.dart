import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/profile_viewmodel.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/history/glucose_history_view.dart';
import '../views/trends/trends_view.dart';
import '../views/history/meal_history_view.dart';
import '../views/history/medication_history_view.dart';
import '../views/logging/barcode_scanner_view.dart';
import '../views/logging/glucose_wizard_view.dart';
import '../views/logging/meal_wizard_view.dart';
import '../views/logging/medication_wizard_view.dart';
import '../views/onboarding/onboarding_wrapper.dart';
import '../views/projection/projection_result_view.dart';
import '../views/settings/emergency_contacts_view.dart';
import '../views/settings/settings_view.dart';
import '../views/splash/splash_screen.dart';
import 'projection_route_args.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _ProfileListenable(ref);
  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final profileAsync = ref.read(userProfileProvider);

      // Still loading — stay on splash.
      if (profileAsync.isLoading) {
        return state.matchedLocation == Routes.splash ? null : Routes.splash;
      }

      final hasProfile = profileAsync.valueOrNull != null;
      final atSplash = state.matchedLocation == Routes.splash;
      final atOnboarding = state.matchedLocation.startsWith(Routes.onboarding);

      // If the profile failed to load due to a DB error, stay on the current
      // route (or splash) rather than redirecting to onboarding — sending users
      // to onboarding on an error risks creating a duplicate profile entry.
      // A dedicated error/retry screen would be the ideal production solution.
      if (profileAsync.hasError) {
        // Keep the user on splash so the splash timeout UI can surface the
        // retry button; avoid pushing them into onboarding unnecessarily.
        return atSplash ? null : Routes.splash;
      }

      // No profile yet (genuine first run) — go to onboarding.
      if (!hasProfile) {
        return atOnboarding ? null : Routes.onboarding;
      }

      // Profile exists — leave splash/onboarding.
      if (atSplash || atOnboarding) return Routes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingWrapper(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (_, _) => const DashboardView(),
        routes: [
          GoRoute(
            path: 'glucose-trend',
            builder: (_, _) => const TrendsView(),
          ),
          GoRoute(
            path: 'glucose-history',
            builder: (_, _) => const GlucoseHistoryView(),
          ),
          GoRoute(
            path: 'meal-history',
            builder: (_, _) => const MealHistoryView(),
          ),
          GoRoute(
            path: 'medication-history',
            builder: (_, _) => const MedicationHistoryView(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.logGlucose,
        builder: (_, _) => const GlucoseWizardView(),
      ),
      GoRoute(
        path: Routes.logMeal,
        builder: (_, _) => const MealWizardView(),
        routes: [
          GoRoute(
            path: 'barcode',
            builder: (_, _) => const BarcodeScannerView(),
          ),
          GoRoute(
            path: 'projection',
            builder: (context, state) {
              final args = state.extra;
              if (args is! ProjectionRouteArgs) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Projection')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text('Could not load projection data.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ProjectionResultView(
                result: args.result,
                unit: args.unit,
                mealCount: args.mealCount,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.logMedication,
        builder: (_, _) => const MedicationWizardView(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsView(),
        routes: [
          GoRoute(
            path: 'emergency-contacts',
            builder: (_, _) => const EmergencyContactsView(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    listenable.dispose();
  });
  return router;
});

/// Makes GoRouter re-evaluate redirects whenever the profile AsyncValue changes.
class _ProfileListenable extends ChangeNotifier {
  _ProfileListenable(Ref ref) {
    ref.listen(userProfileProvider, (_, _) => notifyListeners());
  }
}
