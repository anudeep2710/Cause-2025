import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Color Palette
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryTeal = Color(0xFF1DE9B6);
  static const Color secondaryPurple = Color(0xFF8E24AA);
  static const Color secondaryLavender = Color(0xFFCE93D8);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2F);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Gradients
  static const ecoGradient = LinearGradient(
    colors: [primaryGreen, primaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const solarGradient = LinearGradient(
    colors: [accentYellow, Color(0xFFFF9100)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const techGradient = LinearGradient(
    colors: [Color(0xFF00B0FF), secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism Effect
  static BoxDecoration glassMorphism({bool isDark = true}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          (isDark ? Colors.white : Colors.black).withOpacity(0.02),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // Typography
  static final headingStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final bodyStyle = GoogleFonts.poppins(
    fontSize: 16,
  );

  // IMPROVED Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
      titleTextStyle: headingStyle.copyWith(
        color: Colors.black87,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: primaryGreen),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: Colors.black87),
      displayMedium: headingStyle.copyWith(color: Colors.black87, fontSize: 22),
      displaySmall: headingStyle.copyWith(color: Colors.black87, fontSize: 20),
      headlineMedium:
          headingStyle.copyWith(color: Colors.black87, fontSize: 18),
      headlineSmall: headingStyle.copyWith(color: Colors.black87, fontSize: 16),
      titleLarge: headingStyle.copyWith(color: Colors.black87, fontSize: 16),
      titleMedium: headingStyle.copyWith(
          color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: headingStyle.copyWith(
          color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
      bodyLarge: bodyStyle.copyWith(color: Colors.black87),
      bodyMedium: bodyStyle.copyWith(color: Colors.black87, fontSize: 14),
      bodySmall: bodyStyle.copyWith(color: Colors.black54, fontSize: 12),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: primaryGreen.withOpacity(0.15),
      onPrimaryContainer: primaryGreen.withOpacity(0.8),
      secondary: secondaryPurple,
      onSecondary: Colors.white,
      secondaryContainer: secondaryLavender.withOpacity(0.3),
      onSecondaryContainer: secondaryPurple.withOpacity(0.8),
      surface: lightSurface,
      onSurface: Colors.black87,
      error: Colors.red.shade700,
      onError: Colors.white,
      errorContainer: Colors.red.shade200,
      onErrorContainer: Colors.red.shade900,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightSurface,
      modalBackgroundColor: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 32,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      labelStyle: bodyStyle.copyWith(color: Colors.black87, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: lightSurface),
  );

  // ENHANCED Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkBackground,
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      scrolledUnderElevation: 4,
      titleTextStyle: headingStyle.copyWith(
        color: Colors.white,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: primaryTeal),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: Colors.white),
      displayMedium: headingStyle.copyWith(color: Colors.white, fontSize: 22),
      displaySmall: headingStyle.copyWith(color: Colors.white, fontSize: 20),
      headlineMedium: headingStyle.copyWith(color: Colors.white, fontSize: 18),
      headlineSmall: headingStyle.copyWith(color: Colors.white, fontSize: 16),
      titleLarge: headingStyle.copyWith(color: Colors.white, fontSize: 16),
      titleMedium: headingStyle.copyWith(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: headingStyle.copyWith(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      bodyLarge: bodyStyle.copyWith(color: Colors.white),
      bodyMedium: bodyStyle.copyWith(color: Colors.white70, fontSize: 14),
      bodySmall: bodyStyle.copyWith(color: Colors.white54, fontSize: 12),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryTeal,
      onPrimary: Colors.black,
      primaryContainer: primaryGreen.withOpacity(0.2),
      onPrimaryContainer: primaryTeal,
      secondary: secondaryLavender,
      onSecondary: Colors.black,
      secondaryContainer: secondaryPurple.withOpacity(0.2),
      onSecondaryContainer: secondaryLavender,
      surface: darkSurface,
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      errorContainer: Colors.red.shade900,
      onErrorContainer: Colors.red.shade200,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      modalBackgroundColor: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
      space: 32,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800,
      labelStyle: bodyStyle.copyWith(color: Colors.white, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
  );
}
