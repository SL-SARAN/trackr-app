import 'package:flutter/material.dart';

/// Seed data for the three system categories.
/// These are inserted into the DB on first launch and cannot be deleted.
class CategoryDefaults {
  CategoryDefaults._();

  static const List<DefaultCategory> values = [
    DefaultCategory(
      name: 'Food',
      colorValue: 0xFFF59E0B, // Amber
    ),
    DefaultCategory(
      name: 'Travel',
      colorValue: 0xFF6366F1, // Indigo
    ),
    DefaultCategory(
      name: 'Entertainment',
      colorValue: 0xFF8B5CF6, // Violet
    ),
  ];
}

class DefaultCategory {
  final String name;
  final int colorValue;

  const DefaultCategory({
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}

/// Currencies available during onboarding.
class CurrencyOption {
  final String code;   // e.g. USD
  final String symbol; // e.g. $
  final String name;   // e.g. US Dollar

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyOption> kCurrencies = [
  CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyOption(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  CurrencyOption(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  CurrencyOption(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
  CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  CurrencyOption(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
  CurrencyOption(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  CurrencyOption(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  CurrencyOption(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
  CurrencyOption(code: 'THB', symbol: '฿', name: 'Thai Baht'),
  CurrencyOption(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
  CurrencyOption(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
  CurrencyOption(code: 'MXN', symbol: 'Mex\$', name: 'Mexican Peso'),
  CurrencyOption(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
  CurrencyOption(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
  CurrencyOption(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
];
