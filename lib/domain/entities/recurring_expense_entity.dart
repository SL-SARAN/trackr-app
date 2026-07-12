import 'package:equatable/equatable.dart';

class RecurringExpenseEntity extends Equatable {
  final int id;
  final String title;
  final double amount;
  final int categoryId;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime nextDueDate;
  final bool autoLog;
  final bool isActive;
  final DateTime createdAt;

  const RecurringExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.frequency,
    required this.nextDueDate,
    required this.autoLog,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        categoryId,
        frequency,
        nextDueDate,
        autoLog,
        isActive,
        createdAt,
      ];
}
