import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final int id;
  final double amount;
  final DateTime periodStart;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.amount,
    required this.periodStart,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, amount, periodStart, isActive];
}
