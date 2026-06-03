import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/task_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ExpenseRepository _expenses;
  final CategoryRepository _categories;
  final BudgetRepository _budgets;
  final TaskRepository _tasks;

  HomeCubit({
    required ExpenseRepository expenses,
    required CategoryRepository categories,
    required BudgetRepository budgets,
    required TaskRepository tasks,
  })  : _expenses = expenses,
        _categories = categories,
        _budgets = budgets,
        _tasks = tasks,
        super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final now = DateTime.now();
      final monthStart = DateHelper.startOfMonth(now);
      final monthEnd = DateHelper.endOfMonth(now);

      // Load data concurrently
      final totalSpentFuture = _expenses.getTotalSpent(from: monthStart, to: monthEnd);
      final categoriesFuture = _categories.getAll();
      final catSpendingFuture = _categories.getSpendingPerCategory(from: monthStart, to: monthEnd);
      final nextUpFuture = _tasks.getNextUp();
      final budgetFuture = _budgets.getActive();
      final dailyTotalsFuture = _loadDailyTotals(state.trendDays);

      final totalSpent = await totalSpentFuture;
      final categories = await categoriesFuture;
      final catSpending = await catSpendingFuture;
      final nextUp = await nextUpFuture;
      final budget = await budgetFuture;
      final dailyTotals = await dailyTotalsFuture;

      emit(state.copyWith(
        status: HomeStatus.loaded,
        totalSpent: totalSpent,
        budgetAmount: budget?.amount,
        categories: categories,
        categorySpending: catSpending,
        nextUpTasks: nextUp,
        dailyTotals: dailyTotals,
      ));

    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }

  Future<void> changeTrendPeriod(int days) async {
    emit(state.copyWith(trendDays: days));
    try {
      final totals = await _loadDailyTotals(days);
      emit(state.copyWith(dailyTotals: totals));
    } catch (_) {}
  }

  Future<Map<DateTime, double>> _loadDailyTotals(int days) {
    final now = DateTime.now();
    final from = DateHelper.startOfDay(now.subtract(Duration(days: days - 1)));
    final to = DateHelper.endOfDay(now);
    return _expenses.getDailyTotals(from: from, to: to);
  }
}
