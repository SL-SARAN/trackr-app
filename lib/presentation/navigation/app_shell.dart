import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../services/notification_service.dart';
import '../analytics/cubit/analytics_cubit.dart';
import '../analytics/screens/analytics_screen.dart';
import '../home/cubit/home_cubit.dart';
import '../home/screens/home_screen.dart';
import '../schedule/cubit/schedule_cubit.dart';
import '../schedule/screens/schedule_screen.dart';
import '../settings/cubit/settings_cubit.dart';
import '../settings/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final symbol = await sl<SettingsRepository>().get('currency_symbol');
    if (mounted && symbol != null) {
      setState(() => _currencySymbol = symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      BlocProvider(
        create: (_) => HomeCubit(
          expenses: sl<ExpenseRepository>(),
          categories: sl<CategoryRepository>(),
          budgets: sl<BudgetRepository>(),
          tasks: sl<TaskRepository>(),
        ),
        child: HomeScreen(currencySymbol: _currencySymbol),
      ),
      BlocProvider(
        create: (_) => AnalyticsCubit(
          expenses: sl<ExpenseRepository>(),
          categories: sl<CategoryRepository>(),
        ),
        child: AnalyticsScreen(currencySymbol: _currencySymbol),
      ),
      BlocProvider(
        create: (_) => ScheduleCubit(
          expenses: sl<ExpenseRepository>(),
          tasks: sl<TaskRepository>(),
          categories: sl<CategoryRepository>(),
          notifications: sl<NotificationService>(),
        ),
        child: ScheduleScreen(currencySymbol: _currencySymbol),
      ),
      BlocProvider(
        create: (_) => SettingsCubit(
          settings: sl<SettingsRepository>(),
          budgets: sl<BudgetRepository>(),
        ),
        child: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
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
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
