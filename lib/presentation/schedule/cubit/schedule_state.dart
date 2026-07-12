import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/recurring_expense_entity.dart';

enum ScheduleStatus { initial, loading, saving, saved, error }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final List<CategoryEntity> categories;
  final List<RecurringExpenseEntity> recurringExpenses;
  final String? error;
  final bool permissionDenied;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.categories = const [],
    this.recurringExpenses = const [],
    this.error,
    this.permissionDenied = false,
  });

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<CategoryEntity>? categories,
    List<RecurringExpenseEntity>? recurringExpenses,
    String? error,
    bool? permissionDenied,
  }) =>
      ScheduleState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        recurringExpenses: recurringExpenses ?? this.recurringExpenses,
        error: error,
        permissionDenied: permissionDenied ?? this.permissionDenied,
      );

  @override
  List<Object?> get props => [status, categories, recurringExpenses, error, permissionDenied];
}

