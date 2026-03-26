import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1A237E); // Deep Navy Blue
  static const Color secondaryColor = Color(0xFFFFB300); // Amber/Construction Yellow
  static const Color tertiaryColor = Color(0xFF455A64); // Steel Grey
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light Neutral Grey
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontSize: 24,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: tertiaryColor,
          fontSize: 14,
        ),
        labelSmall: GoogleFonts.poppins(
          color: Colors.grey, // Light grey for subtitles
        ),
      ),
      // Component Themes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
