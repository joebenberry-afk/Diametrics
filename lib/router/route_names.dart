/// All GoRouter path constants. Use these instead of raw strings.
abstract final class Routes {
  static const splash             = '/splash';
  static const onboarding         = '/onboarding';
  static const dashboard          = '/dashboard';
  static const glucoseTrend       = '/dashboard/glucose-trend';
  static const glucoseHistory     = '/dashboard/glucose-history';
  static const mealHistory        = '/dashboard/meal-history';
  static const medicationHistory  = '/dashboard/medication-history';
  static const emergencyContacts  = '/dashboard/emergency-contacts';
  static const logGlucose         = '/log/glucose';
  static const logMeal            = '/log/meal';
  static const logMealBarcode     = '/log/meal/barcode';
  static const logMealProjection  = '/log/meal/projection';
  static const logMedication      = '/log/medication';
  static const settings                  = '/settings';
  static const settingsEmergencyContacts = '/settings/emergency-contacts';
}
