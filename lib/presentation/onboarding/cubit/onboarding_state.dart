part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final CurrencyOption? selected;
  final bool isLoading;
  final bool isDone;
  final String? error;

  const OnboardingState({
    this.selected,
    this.isLoading = false,
    this.isDone = false,
    this.error,
  });

  OnboardingState copyWith({
    CurrencyOption? selected,
    bool? isLoading,
    bool? isDone,
    String? error,
  }) =>
      OnboardingState(
        selected: selected ?? this.selected,
        isLoading: isLoading ?? this.isLoading,
        isDone: isDone ?? this.isDone,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [selected, isLoading, isDone, error];
}
