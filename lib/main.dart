import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'data/repositories/settings_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'services/recurring_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up dependency injection
  await initDependencies();

  // Initialize notification service
  await sl<NotificationService>().init();

  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
  );
  Workmanager().registerPeriodicTask(
    'recurring-expenses-task',
    recurringTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 15),
  );

  // Determine if user has completed onboarding
  final settings = sl<SettingsRepository>();
  final onboardingDone =
      (await settings.get(AppConstants.keyOnboardingDone)) == 'true';

  runApp(TrackrApp(onboardingDone: onboardingDone));
}
