import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary (Indigo) ---
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF818CF8);

  // --- Secondary (Emerald) ---
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF34D399);

  // --- Surface ---
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // --- Background ---
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // --- Card (slightly elevated surface) ---
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);

  // --- Status ---
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerLight = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFF87171);
  static const Color successLight = Color(0xFF10B981);
  static const Color successDark = Color(0xFF34D399);

  // --- Text ---
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // --- Border / Divider ---
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // --- Importance levels ---
  static const Color importanceLow = Color(0xFF10B981);
  static const Color importanceMedium = Color(0xFFF59E0B);
  static const Color importanceHigh = Color(0xFFEF4444);

  // --- Budget progress ---
  static const Color budgetSafe = Color(0xFF10B981);    // < 70%
  static const Color budgetWarn = Color(0xFFF59E0B);    // 70–100%
  static const Color budgetOver = Color(0xFFEF4444);    // > 100%

  // --- Default category colors (consistent palette) ---
  static const List<Color> categoryPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
  ];
}
