import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/navigation/app_shell.dart';
import 'presentation/onboarding/cubit/onboarding_cubit.dart';
import 'presentation/onboarding/screens/onboarding_screen.dart';
import 'presentation/shared/cubit/theme_cubit.dart';
import 'presentation/shared/widgets/lock_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

class TrackrApp extends StatefulWidget {
  final bool onboardingDone;

  const TrackrApp({super.key, required this.onboardingDone});

  @override
  State<TrackrApp> createState() => _TrackrAppState();
}

class _TrackrAppState extends State<TrackrApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  DateTime? _lastPaused;
  String _lockTimeout = 'off';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLockSetting();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLockSetting() async {
    final timeout =
        await sl<SettingsRepository>().get(AppConstants.keyAppLockTimeout);
    if (mounted) {
      setState(() => _lockTimeout = timeout ?? 'off');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lastPaused = DateTime.now();
      // Reload lock setting in case it was changed
      _loadLockSetting();
    } else if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  void _checkLock() {
    if (_lockTimeout == 'off' || !widget.onboardingDone) return;

    final timeoutSeconds = int.tryParse(_lockTimeout) ?? -1;
    if (timeoutSeconds < 0) return;

    if (_lastPaused == null) return;

    final elapsed = DateTime.now().difference(_lastPaused!).inSeconds;
    if (elapsed >= timeoutSeconds) {
      setState(() => _isLocked = true);
    }
  }

  Future<void> _unlock() async {
    final success = await sl<AuthService>().authenticate();
    if (success && mounted) {
      setState(() => _isLocked = false);
    }
  }

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
            initialRoute: widget.onboardingDone ? '/home' : '/onboarding',
            routes: {
              '/onboarding': (context) => BlocProvider(
                    create: (_) => OnboardingCubit(
                      settings: sl<SettingsRepository>(),
                      categories: sl<CategoryRepository>(),
                      notifications: sl<NotificationService>(),
                      budgets: sl<BudgetRepository>(),
                    ),
                    child: const OnboardingScreen(),
                  ),
              '/home': (context) => const AppShell(),
            },
            builder: (context, child) {
              // Overlay lock screen on top of the app when locked
              if (_isLocked) {
                return Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    LockScreen(onUnlock: _unlock),
                  ],
                );
              }
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
