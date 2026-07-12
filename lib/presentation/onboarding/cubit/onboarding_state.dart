part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final CurrencyOption? selected;
  final double? budget;
  final double? income;
  final bool isLoading;
  final bool isDone;
  final String? error;

  const OnboardingState({
    this.selected,
    this.budget,
    this.income,
    this.isLoading = false,
    this.isDone = false,
    this.error,
  });

  OnboardingState copyWith({
    CurrencyOption? selected,
    double? budget,
    double? income,
    bool? isLoading,
    bool? isDone,
    String? error,
    bool clearBudget = false,
    bool clearIncome = false,
  }) =>
      OnboardingState(
        selected: selected ?? this.selected,
        budget: clearBudget ? null : (budget ?? this.budget),
        income: clearIncome ? null : (income ?? this.income),
        isLoading: isLoading ?? this.isLoading,
        isDone: isDone ?? this.isDone,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [selected, budget, income, isLoading, isDone, error];
}
