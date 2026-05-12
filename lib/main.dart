import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up dependency injection
  await initDependencies();

  // Determine if user has completed onboarding
  final settings = sl<SettingsRepository>();
  final onboardingDone =
      (await settings.get(AppConstants.keyOnboardingDone)) == 'true';

  runApp(TrackrApp(onboardingDone: onboardingDone));
}
