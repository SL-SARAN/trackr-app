import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String currencySymbol;
  final String currencyCode;
  final double? budgetAmount;
  final double? monthlyIncome;
  final bool isDarkMode;
  final bool isLoading;
  final String appLockTimeout; // 'off', '0', '60', '300'

  const SettingsState({
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.budgetAmount,
    this.monthlyIncome,
    this.isDarkMode = false,
    this.isLoading = false,
    this.appLockTimeout = 'off',
  });

  SettingsState copyWith({
    String? currencySymbol,
    String? currencyCode,
    double? budgetAmount,
    double? monthlyIncome,
    bool? isDarkMode,
    bool? isLoading,
    String? appLockTimeout,
  }) =>
      SettingsState(
        currencySymbol: currencySymbol ?? this.currencySymbol,
        currencyCode: currencyCode ?? this.currencyCode,
        budgetAmount: budgetAmount ?? this.budgetAmount,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isLoading: isLoading ?? this.isLoading,
        appLockTimeout: appLockTimeout ?? this.appLockTimeout,
      );

  @override
  List<Object?> get props => [
        currencySymbol,
        currencyCode,
        budgetAmount,
        monthlyIncome,
        isDarkMode,
        isLoading,
        appLockTimeout,
      ];
}
