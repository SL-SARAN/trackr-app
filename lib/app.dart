import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/navigation/app_shell.dart';
import 'presentation/onboarding/cubit/onboarding_cubit.dart';
import 'presentation/onboarding/screens/currency_setup_screen.dart';
import 'presentation/shared/cubit/theme_cubit.dart';
import 'services/notification_service.dart';

class TrackrApp extends StatelessWidget {
  final bool onboardingDone;

  const TrackrApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Trackr',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeState.themeMode,
            initialRoute: onboardingDone ? '/home' : '/onboarding',
            routes: {
              '/onboarding': (context) => BlocProvider(
                    create: (_) => OnboardingCubit(
                      settings: sl<SettingsRepository>(),
                      categories: sl<CategoryRepository>(),
                      notifications: sl<NotificationService>(),
                    ),
                    child: const CurrencySetupScreen(),
                  ),
              '/home': (context) => const AppShell(),
            },
          );
        },
      ),
    );
  }
}
