/// All GoRouter path constants. Use these instead of raw strings.
///
/// The app uses a four-tab bottom navigation shell (Home / Trends / Log /
/// Profile). Each tab is its own branch in a `StatefulShellRoute`, so
/// switching tabs preserves the navigation stack inside the other tabs.
abstract final class Routes {
  // Pre-shell screens
  static const splash     = '/splash';
  static const onboarding = '/onboarding';

  // Shell tab roots
  static const home    = '/';        // Home tab root → DashboardView
  static const trends  = '/trends';  // Trends tab root → TrendsView
  static const log     = '/log';     // Log tab root → LogHubView
  static const profile = '/profile'; // Profile tab root → SettingsView

  // Home-tab sub-routes (history drill-downs)
  static const glucoseHistory    = '/history/glucose';
  static const mealHistory       = '/history/meal';
  static const medicationHistory = '/history/medication';

  // Log-tab sub-routes (wizards + scanner stack)
  static const logGlucose         = '/log/glucose';
  static const logMeal            = '/log/meal';
  static const logMealBarcode     = '/log/meal/barcode';
  static const logMealFoodScanner = '/log/meal/food-scanner';
  static const logMealProjection  = '/log/meal/projection';
  static const logMedication      = '/log/medication';

  // Profile-tab sub-routes
  static const emergencyContacts         = '/profile/emergency-contacts';
  static const settingsEmergencyContacts = '/profile/emergency-contacts';

  // Aliases kept for backwards compatibility with existing call sites.
  // Will be migrated in a follow-up cleanup pass.
  static const dashboard    = home;
  static const settings     = profile;
  static const glucoseTrend = trends;
}
