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

      // Load all data in parallel
      final results = await Future.wait([
        _expenses.getTotalSpent(from: monthStart, to: monthEnd),
        _categories.getAll(),
        _categories.getSpendingPerCategory(from: monthStart, to: monthEnd),
        _tasks.getNextUp(),
        _budgets.getActive(),
        _loadDailyTotals(state.trendDays),
      ]);

      final totalSpent = results[0] as double;
      final categories = results[1] as List;
      final catSpending = results[2] as Map<int, double>;
      final nextUp = results[3] as List;
      final budget = results[4];
      final dailyTotals = results[5] as Map<DateTime, double>;

      emit(state.copyWith(
        status: HomeStatus.loaded,
        totalSpent: totalSpent,
        budgetAmount: budget?.amount,
        categories: List.from(categories),
        categorySpending: catSpending,
        nextUpTasks: List.from(nextUp),
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
