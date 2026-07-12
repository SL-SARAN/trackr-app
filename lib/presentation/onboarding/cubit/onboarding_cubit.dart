import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_defaults.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../services/notification_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SettingsRepository _settings;
  final CategoryRepository _categories;
  final NotificationService _notifications;
  final BudgetRepository _budgets;

  OnboardingCubit({
    required SettingsRepository settings,
    required CategoryRepository categories,
    required NotificationService notifications,
    required BudgetRepository budgets,
  })  : _settings = settings,
        _categories = categories,
        _notifications = notifications,
        _budgets = budgets,
        super(const OnboardingState());

  void selectCurrency(CurrencyOption currency) {
    emit(state.copyWith(selected: currency));
  }

  void setBudget(double? amount) {
    if (amount == null) {
      emit(state.copyWith(clearBudget: true));
    } else {
      emit(state.copyWith(budget: amount));
    }
  }

  void setIncome(double? amount) {
    if (amount == null) {
      emit(state.copyWith(clearIncome: true));
    } else {
      emit(state.copyWith(income: amount));
    }
  }

  Future<void> confirm() async {
    final currency = state.selected;
    if (currency == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Persist currency
      await _settings.set(AppConstants.keyCurrency, currency.code);
      await _settings.set(AppConstants.keyCurrencySymbol, currency.symbol);

      // Persist budget if provided
      if (state.budget != null && state.budget! > 0) {
        await _budgets.setAmount(state.budget!);
      }

      // Persist monthly income if provided
      if (state.income != null && state.income! > 0) {
        await _settings.set(
            AppConstants.keyMonthlyIncome, state.income!.toStringAsFixed(2));
      }

      // Seed system categories if not already present
      final existing = await _categories.getAll();
      if (existing.isEmpty) {
        for (int i = 0; i < CategoryDefaults.values.length; i++) {
          final cat = CategoryDefaults.values[i];
          await _categories.create(
            name: cat.name,
            color: cat.color,
            isSystem: true,
            sortOrder: i,
            type: cat.type,
          );
        }
      }

      // Request notification permission (Android 13+ requires runtime request)
      await _notifications.requestPermission();

      // Mark onboarding as done
      await _settings.set(AppConstants.keyOnboardingDone, 'true');

      emit(state.copyWith(isLoading: false, isDone: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
