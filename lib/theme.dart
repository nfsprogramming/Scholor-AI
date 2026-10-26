import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color surface = Color(0xFFFAF4FF);
  static const Color background = Color(0xFFFAF4FF);
  static const Color primary = Color(0xFF4A40E0);
  static const Color onPrimary = Color(0xFFF4F1FF);
  static const Color secondary = Color(0xFF702AE1);
  static const Color onSurface = Color(0xFF32294F);
  static const Color onSurfaceVariant = Color(0xFF5F557F);
  static const Color surfaceContainer = Color(0xFFEDE4FF);
  static const Color surfaceContainerLow = Color(0xFFF5EEFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE8DEFF);
  static const Color surfaceContainerHighest = Color(0xFFE2D7FF);
  static const Color inverseSurface = Color(0xFF10062D);
  static const Color outline = Color(0xFF7B719C);
  static const Color error = Color(0xFFB41340);
  static const Color primaryFixed = Color(0xFF9795FF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.inter(
          color: onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
    );
  }
}
