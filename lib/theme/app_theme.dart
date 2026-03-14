import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Brand Colors (Strictly matched to Logo)
  static const Color primary = Color(0xFFB48C36); // Logo Gold/Bronze
  static const Color secondary = Color(0xFFD4AF37); // Lighter Gold
  static const Color dark = Color(0xFF121212); // Logo Text Charcoal
  static const Color background = Colors.white; // Crisp White/Grey
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1A1A1A); // Darker text
  static const Color textLight = Color(0xFF757575); // Grey for captions

  static ThemeData get lightTheme {
    // Check if ScreenUtil is initialized safely
    bool isInit = false;
    try {
      isInit = ScreenUtil().screenWidth > 0;
    } catch (_) {
      isInit = false;
    }
    final bool isScreenUtilInitialized = isInit;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        onPrimary: Colors.white,
        surface: surface,
        error: Color(0xFFB00020),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: dark),
        titleTextStyle: TextStyle(
          color: dark,
          fontSize: isScreenUtilInitialized ? 20.sp : 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: isScreenUtilInitialized ? 16.h : 16,
            horizontal: isScreenUtilInitialized ? 32.w : 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          ),
          textStyle: TextStyle(
            fontSize: isScreenUtilInitialized ? 16.sp : 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: EdgeInsets.symmetric(
            vertical: isScreenUtilInitialized ? 16.h : 16,
            horizontal: isScreenUtilInitialized ? 32.w : 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          ),
          textStyle: TextStyle(
            fontSize: isScreenUtilInitialized ? 16.sp : 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isScreenUtilInitialized ? 20.w : 20,
          vertical: isScreenUtilInitialized ? 16.h : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 12.r : 12),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        hintStyle: TextStyle(
          color: textLight,
          fontSize: isScreenUtilInitialized ? 14.sp : 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isScreenUtilInitialized ? 16.r : 16),
        ),
      ),
    );
  }
}
