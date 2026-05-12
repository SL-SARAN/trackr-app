import 'package:equatable/equatable.dart';
import 'enums.dart';

class ExpenseEntity extends Equatable {
  final int id;
  final double amount;
  final int categoryId;
  final String? description;
  final DateTime date;
  final TimeOfDayTag timeOfDayTag;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    required this.timeOfDayTag,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, categoryId, description, date, timeOfDayTag];
}
