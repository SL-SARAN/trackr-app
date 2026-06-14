import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final ExpenseRepository _expenses;
  final CategoryRepository _categories;

  static const int _pageSize = 30;

  AnalyticsCubit({
    required ExpenseRepository expenses,
    required CategoryRepository categories,
  })  : _expenses = expenses,
        _categories = categories,
        super(const AnalyticsState());

  Future<void> load() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final cats = await _categories.getAll();
      final expenses = await _expenses.getFiltered(
        from: state.filterFrom,
        to: state.filterTo,
        categoryId: state.filterCategoryId,
        searchQuery: state.searchQuery,
        limit: _pageSize,
        offset: 0,
      );
      emit(state.copyWith(
        status: AnalyticsStatus.loaded,
        categories: cats,
        expenses: expenses,
        hasMore: expenses.length >= _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(status: AnalyticsStatus.error, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == AnalyticsStatus.loading) return;
    try {
      final more = await _expenses.getFiltered(
        from: state.filterFrom,
        to: state.filterTo,
        categoryId: state.filterCategoryId,
        searchQuery: state.searchQuery,
        limit: _pageSize,
        offset: state.expenses.length,
      );
      emit(state.copyWith(
        expenses: [...state.expenses, ...more],
        hasMore: more.length >= _pageSize,
      ));
    } catch (_) {}
  }

  Future<void> setCategory(int? categoryId) async {
    emit(state.copyWith(
      filterCategoryId: categoryId ?? 0,
      clearCategoryFilter: categoryId == null,
    ));
    await load();
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    emit(state.copyWith(
      filterFrom: from,
      filterTo: to,
      clearDateFilter: from == null && to == null,
    ));
    await load();
  }

  Future<void> setSearch(String? query) async {
    emit(state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    ));
    await load();
  }

  Future<void> deleteExpense(int id) async {
    await _expenses.delete(id);
    await load();
  }

  Future<void> updateExpense({
    required int id,
    double? amount,
    int? categoryId,
    String? description,
    DateTime? date,
  }) async {
    await _expenses.update(
      id: id,
      amount: amount,
      categoryId: categoryId,
      description: description,
      date: date,
    );
    await load();
  }
}
