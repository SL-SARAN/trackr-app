import 'package:equatable/equatable.dart';
import 'enums.dart';

class TaskEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final ImportanceLevel importance;
  final DateTime scheduledAt;
  final int? reminderMinutes;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final bool isCompleted;
  final bool isPlannedExpense;
  final int? linkedExpenseId;
  final double? estimatedAmount;
  final int? categoryId;
  final int? notificationId;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.importance,
    required this.scheduledAt,
    this.reminderMinutes,
    required this.isRecurring,
    required this.recurrenceType,
    required this.isCompleted,
    required this.isPlannedExpense,
    this.linkedExpenseId,
    this.estimatedAmount,
    this.categoryId,
    this.notificationId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, importance, scheduledAt, isCompleted];
}
