import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto';

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      // Display — large hero numbers (e.g. total budget)
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -1.0,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: -0.5,
      ),

      // Headline — section titles
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),

      // Title — card headers, list headers
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),

      // Body — content text
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),

      // Label — badges, tags, buttons
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryText,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }
}
