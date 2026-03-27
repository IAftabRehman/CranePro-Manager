import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Premium Palette ---
  static const Color primaryNavy = Color(0xFF0D1B3E); // Deep Navy Base
  static const Color primaryPurple = Color(0xFF2A1B3D); // Purple Hue
  static const Color accentGold = Color(0xFFFFB300); // Amber/Gold for contrast
  static const Color accentLightBlue = Color(0xFF4FC3F7); // For subtle links/glows
  static const Color surfaceTranslucent = Color(0x14FFFFFF); // 8% White opacity
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Gradient for global background
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primaryNavy, primaryPurple],
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
        fillColor: surfaceTranslucent,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryNavy,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
    );
  }
}
