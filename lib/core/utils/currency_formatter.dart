import 'package:intl/intl.dart';

class CurrencyFormatter {
  final String symbol;
  final String code;

  const CurrencyFormatter({required this.symbol, required this.code});

  /// Format an amount as a currency string, e.g. "₹ 1,250.00"
  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Compact format for chart labels, e.g. "₹1.2K"
  String compact(double amount) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}
