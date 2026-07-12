/// Time-of-day boundary hours (24h format).
class AppConstants {
  AppConstants._();

  // Time-of-day boundaries
  static const int morningStart = 5;   // 05:00
  static const int noonStart = 12;     // 12:00
  static const int eveningStart = 14;  // 14:00
  static const int nightStart = 19;    // 19:00

  // Budget alert thresholds (as fractions of the limit)
  static const double budgetWarnThreshold = 0.70; // amber at 70%
  static const double budgetOverThreshold = 1.00; // red at 100%

  // Category alert thresholds (same scale)
  static const double categoryWarnThreshold = 0.70;
  static const double categoryOverThreshold = 1.00;

  // "Next Up" — number of tasks to show on the home screen
  static const int nextUpCount = 2;

  // Default reminder presets (in minutes)
  static const List<int> reminderPresets = [5, 15, 30, 60];

  // Settings keys stored in app_settings table
  static const String keyCurrency = 'currency';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyMonthlyBudget = 'monthly_budget';
  static const String keyMonthlyIncome = 'monthly_income';
  static const String keyAppLockTimeout = 'app_lock_timeout';
}
