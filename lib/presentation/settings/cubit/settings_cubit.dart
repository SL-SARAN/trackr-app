import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settings;
  final BudgetRepository _budgets;

  SettingsCubit({
    required SettingsRepository settings,
    required BudgetRepository budgets,
  })  : _settings = settings,
        _budgets = budgets,
        super(const SettingsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final symbol = await _settings.get(AppConstants.keyCurrencySymbol) ?? '\$';
    final code = await _settings.get(AppConstants.keyCurrency) ?? 'USD';
    final themeMode = await _settings.get(AppConstants.keyThemeMode);
    final budget = await _budgets.getActive();

    emit(state.copyWith(
      currencySymbol: symbol,
      currencyCode: code,
      budgetAmount: budget?.amount ?? 0,
      isDarkMode: themeMode == 'dark',
      isLoading: false,
    ));
  }

  Future<void> setBudget(double amount) async {
    await _budgets.setAmount(amount);
    emit(state.copyWith(budgetAmount: amount));
  }

  Future<void> setDarkMode(bool dark) async {
    await _settings.set(AppConstants.keyThemeMode, dark ? 'dark' : 'light');
    emit(state.copyWith(isDarkMode: dark));
  }
}
