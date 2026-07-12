import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/recurring_expense_repository.dart';
import '../../services/notification_service.dart';
import '../analytics/cubit/analytics_cubit.dart';
import '../analytics/cubit/analytics_state.dart';
import '../analytics/screens/analytics_screen.dart';
import '../home/cubit/home_cubit.dart';
import '../home/screens/home_screen.dart';
import '../schedule/cubit/schedule_cubit.dart';
import '../schedule/cubit/schedule_state.dart';
import '../schedule/screens/schedule_screen.dart';
import '../settings/cubit/settings_cubit.dart';
import '../settings/cubit/settings_state.dart';
import '../settings/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  String _currencySymbol = '\$';
  bool _homeDirty = false;
  bool _analyticsDirty = false;

  late final HomeCubit _homeCubit;
  late final AnalyticsCubit _analyticsCubit;
  late final ScheduleCubit _scheduleCubit;
  late final SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _loadCurrency();

    _homeCubit = HomeCubit(
      expenses: sl<ExpenseRepository>(),
      categories: sl<CategoryRepository>(),
      budgets: sl<BudgetRepository>(),
      tasks: sl<TaskRepository>(),
      settings: sl<SettingsRepository>(),
    );
    _analyticsCubit = AnalyticsCubit(
      expenses: sl<ExpenseRepository>(),
      categories: sl<CategoryRepository>(),
    );
    _scheduleCubit = ScheduleCubit(
      expenses: sl<ExpenseRepository>(),
      tasks: sl<TaskRepository>(),
      categories: sl<CategoryRepository>(),
      recurring: sl<RecurringExpenseRepository>(),
      notifications: sl<NotificationService>(),
    );
    _settingsCubit = SettingsCubit(
      settings: sl<SettingsRepository>(),
      budgets: sl<BudgetRepository>(),
    );
  }

  @override
  void dispose() {
    _homeCubit.close();
    _analyticsCubit.close();
    _scheduleCubit.close();
    _settingsCubit.close();
    super.dispose();
  }

  Future<void> _loadCurrency() async {
    final symbol = await sl<SettingsRepository>().get('currency_symbol');
    if (mounted && symbol != null) {
      setState(() => _currencySymbol = symbol);
    }
  }

  void _onTabSelected(int index) {
    if (index == 0 && _homeDirty) {
      _homeCubit.load();
      _homeDirty = false;
    }
    if (index == 1 && _analyticsDirty) {
      _analyticsCubit.load();
      _analyticsDirty = false;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeCubit),
        BlocProvider.value(value: _analyticsCubit),
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _settingsCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          // When an expense or task is saved on the Add tab
          BlocListener<ScheduleCubit, ScheduleState>(
            listenWhen: (prev, curr) =>
                prev.status != ScheduleStatus.saved &&
                curr.status == ScheduleStatus.saved,
            listener: (context, state) {
              _homeDirty = true;
              _analyticsDirty = true;
            },
          ),
          // When an expense is deleted/updated in Analytics, refresh Home
          BlocListener<AnalyticsCubit, AnalyticsState>(
            listenWhen: (prev, curr) =>
                prev.expenses.length != curr.expenses.length ||
                prev.expenses != curr.expenses,
            listener: (context, state) {
              _homeDirty = true;
            },
          ),
          // When budget is changed in Settings, refresh Home
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (prev, curr) =>
                prev.budgetAmount != curr.budgetAmount,
            listener: (context, state) {
              _homeDirty = true;
            },
          ),
        ],
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                currencySymbol: _currencySymbol,
                onNavigateToTab: _onTabSelected,
              ),
              AnalyticsScreen(currencySymbol: _currencySymbol),
              ScheduleScreen(currencySymbol: _currencySymbol),
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Add',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
