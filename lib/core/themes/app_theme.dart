import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Premium Palette ---
  static const Color primaryNavy = Color(0xFF0D1B3E); // Deep Navy Base
  static const Color primaryPurple = Color(0xFF2A1B3D); // Purple Hue
  static const Color deepNavyBlue = Color(0xFF0A1931); // Darker variant
  static const Color lavenderPrimary = Color(0xFFE6E6FA); // Lavender
  static const Color bluePrimary = Color(0xFF4A90E2); // Professional Blue
  static const Color accentGold = Color(0xFFFFB300); // Amber/Gold for contrast
  static const Color surfaceTranslucent = Color(0x14FFFFFF); // 8% White opacity
  
  // Gradient for global background
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primaryNavy, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderBlueGradient = LinearGradient(
    colors: [Color(0xFF7474BF), Color(0xFF348AC7)], // Lavender to Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Treat application as 'Dark' for contrast
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: accentGold,
        surface: primaryNavy,
        onPrimary: Colors.white,
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Background handled by PremiumBackground
      
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontSize: 26,
          letterSpacing: 1.2,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
        ),
        labelSmall: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Component Themes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          color: primaryNavy.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIconColor: primaryNavy,
        suffixIconColor: primaryNavy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryNavy, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bluePrimary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
