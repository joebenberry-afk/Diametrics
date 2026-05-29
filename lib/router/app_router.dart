import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/profile_viewmodel.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/food_scanner/food_scanner_view.dart';
import '../views/history/glucose_history_view.dart';
import '../views/history/meal_history_view.dart';
import '../views/history/medication_history_view.dart';
import '../views/log/log_hub_view.dart';
import '../views/logging/barcode_scanner_view.dart';
import '../views/logging/glucose_wizard_view.dart';
import '../views/logging/meal_wizard_view.dart';
import '../views/logging/medication_wizard_view.dart';
import '../views/onboarding/onboarding_wrapper.dart';
import '../views/projection/projection_result_view.dart';
import '../views/settings/emergency_contacts_view.dart';
import '../views/settings/settings_view.dart';
import '../views/splash/splash_screen.dart';
import '../views/trends/trends_view.dart';
import 'app_shell.dart';
import 'projection_route_args.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeShellNavigatorKey = GlobalKey<NavigatorState>();
final _trendsShellNavigatorKey = GlobalKey<NavigatorState>();
final _logShellNavigatorKey = GlobalKey<NavigatorState>();
final _profileShellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _ProfileListenable(ref);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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

      // If the profile failed to load due to a DB error, keep the user on
      // splash so the timeout UI can surface a retry button. Avoid pushing
      // them into onboarding (which would risk a duplicate profile entry).
      if (profileAsync.hasError) {
        return atSplash ? null : Routes.splash;
      }

      // No profile (genuine first run) — go to onboarding.
      if (!hasProfile) {
        return atOnboarding ? null : Routes.onboarding;
      }

      // Profile exists — leave splash/onboarding and land on home tab.
      if (atSplash || atOnboarding) return Routes.home;

      return null;
    },
    routes: [
      // ── Pre-shell screens (full-screen, no bottom nav) ──
      GoRoute(
        path: Routes.splash,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const OnboardingWrapper(),
      ),

      // ── Main app shell with four-tab bottom navigation ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Home ──
          StatefulShellBranch(
            navigatorKey: _homeShellNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const DashboardView(),
                routes: [
                  GoRoute(
                    path: 'history/glucose',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const GlucoseHistoryView(),
                  ),
                  GoRoute(
                    path: 'history/meal',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const MealHistoryView(),
                  ),
                  GoRoute(
                    path: 'history/medication',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const MedicationHistoryView(),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 1: Trends ──
          StatefulShellBranch(
            navigatorKey: _trendsShellNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.trends,
                builder: (_, _) => const TrendsView(),
              ),
            ],
          ),

          // ── Branch 2: Log ──
          StatefulShellBranch(
            navigatorKey: _logShellNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.log,
                builder: (_, _) => const LogHubView(),
                routes: [
                  GoRoute(
                    path: 'glucose',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const GlucoseWizardView(),
                  ),
                  GoRoute(
                    path: 'medication',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const MedicationWizardView(),
                  ),
                  GoRoute(
                    path: 'meal',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const MealWizardView(),
                    routes: [
                      GoRoute(
                        path: 'barcode',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, _) => const BarcodeScannerView(),
                      ),
                      GoRoute(
                        path: 'food-scanner',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, _) => const FoodScannerView(),
                      ),
                      GoRoute(
                        path: 'projection',
                        parentNavigatorKey: _rootNavigatorKey,
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
                                    const Text(
                                        'Could not load projection data.'),
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
                ],
              ),
            ],
          ),

          // ── Branch 3: Profile ──
          StatefulShellBranch(
            navigatorKey: _profileShellNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const SettingsView(),
                routes: [
                  GoRoute(
                    path: 'emergency-contacts',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const EmergencyContactsView(),
                  ),
                ],
              ),
            ],
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
