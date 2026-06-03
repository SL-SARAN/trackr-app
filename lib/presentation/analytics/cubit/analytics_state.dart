import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final List<ExpenseEntity> expenses;
  final List<CategoryEntity> categories;
  final int? filterCategoryId;
  final DateTime? filterFrom;
  final DateTime? filterTo;
  final String? searchQuery;
  final bool hasMore;
  final String? error;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.expenses = const [],
    this.categories = const [],
    this.filterCategoryId,
    this.filterFrom,
    this.filterTo,
    this.searchQuery,
    this.hasMore = true,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<ExpenseEntity>? expenses,
    List<CategoryEntity>? categories,
    int? filterCategoryId,
    DateTime? filterFrom,
    DateTime? filterTo,
    String? searchQuery,
    bool? hasMore,
    String? error,
    bool clearCategoryFilter = false,
    bool clearDateFilter = false,
    bool clearSearch = false,
  }) =>
      AnalyticsState(
        status: status ?? this.status,
        expenses: expenses ?? this.expenses,
        categories: categories ?? this.categories,
        filterCategoryId:
            clearCategoryFilter ? null : (filterCategoryId ?? this.filterCategoryId),
        filterFrom: clearDateFilter ? null : (filterFrom ?? this.filterFrom),
        filterTo: clearDateFilter ? null : (filterTo ?? this.filterTo),
        searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );

  @override
  List<Object?> get props => [
        status,
        expenses,
        categories,
        filterCategoryId,
        filterFrom,
        filterTo,
        searchQuery,
        hasMore,
        error,
      ];
}
