import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/task_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final double totalSpent;
  final double totalIncome;
  final double? budgetAmount;
  final Map<int, double> categorySpending; // categoryId -> amount
  final List<CategoryEntity> categories;
  final List<TaskEntity> nextUpTasks;
  final Map<DateTime, double> dailyTotals;
  final int trendDays; // 7, 30, 365
  final bool hasMonthlyIncome;
  final String? error;

  const HomeState({
    this.status = HomeStatus.initial,
    this.totalSpent = 0,
    this.totalIncome = 0,
    this.budgetAmount,
    this.categorySpending = const {},
    this.categories = const [],
    this.nextUpTasks = const [],
    this.dailyTotals = const {},
    this.trendDays = 7,
    this.hasMonthlyIncome = false,
    this.error,
  });

  double get netSavings => totalIncome - totalSpent;

  double get budgetProgress {
    if (budgetAmount == null || budgetAmount == 0) return 0;
    return totalSpent / budgetAmount!;
  }

  bool get isOverBudget => budgetProgress > 1.0;

  HomeState copyWith({
    HomeStatus? status,
    double? totalSpent,
    double? totalIncome,
    double? budgetAmount,
    Map<int, double>? categorySpending,
    List<CategoryEntity>? categories,
    List<TaskEntity>? nextUpTasks,
    Map<DateTime, double>? dailyTotals,
    int? trendDays,
    bool? hasMonthlyIncome,
    String? error,
  }) =>
      HomeState(
        status: status ?? this.status,
        totalSpent: totalSpent ?? this.totalSpent,
        totalIncome: totalIncome ?? this.totalIncome,
        budgetAmount: budgetAmount ?? this.budgetAmount,
        categorySpending: categorySpending ?? this.categorySpending,
        categories: categories ?? this.categories,
        nextUpTasks: nextUpTasks ?? this.nextUpTasks,
        dailyTotals: dailyTotals ?? this.dailyTotals,
        trendDays: trendDays ?? this.trendDays,
        hasMonthlyIncome: hasMonthlyIncome ?? this.hasMonthlyIncome,
        error: error,
      );

  @override
  List<Object?> get props => [
        status,
        totalSpent,
        totalIncome,
        budgetAmount,
        categorySpending,
        categories,
        nextUpTasks,
        dailyTotals,
        trendDays,
        hasMonthlyIncome,
        error,
      ];
}
