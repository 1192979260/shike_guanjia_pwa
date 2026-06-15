import 'package:flutter/material.dart';
import 'package:shike_guanjia/models/models.dart';

class AppTheme {
  static const Color primary = Color(0xFFC66B3D);
  static const Color primaryLight = Color(0xFFD88A5F);
  static const Color primaryDark = Color(0xFF9A4F2D);
  static const Color accent = Color(0xFFC08E3A);
  static const Color sage = Color(0xFF8B9D83);
  static const Color moss = Color(0xFF606C38);
  static const Color clay = Color(0xFFB08B6E);
  static const Color sand = Color(0xFFE8DCC7);
  static const Color oat = Color(0xFFD4B895);
  static const Color background = Color(0xFFE8DCC7);
  static const Color surface = Color(0xFFF9F1E3);
  static const Color surfaceAlt = Color(0xFFD4B895);
  static const Color textPrimary = Color(0xFF3F3428);
  static const Color textSecondary = Color(0xFF7D6B58);
  static const Color textTertiary = Color(0xFFA38F78);
  static const Color textInverse = Color(0xFFFFFBF3);
  static const Color success = Color(0xFF6F8F58);
  static const Color warning = Color(0xFFC08E3A);
  static const Color error = Color(0xFFB8563F);
  static const Color info = Color(0xFF7F9B9B);

  static const List<Color> gradeColors = [
    primary,
    sage,
    accent,
    clay,
    moss,
    info,
  ];

  static ThemeData get lightTheme {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      borderSide: BorderSide(color: Color(0xFFD4B895), width: 1.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Epilogue',
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: textInverse,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textInverse,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: surface,
        indicatorColor: sand,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? primary
                : textTertiary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textInverse,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: oat, width: 1.2),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: error, width: 1.2),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(color: textTertiary),
        prefixIconColor: clay,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: moss,
        contentTextStyle: const TextStyle(
          color: textInverse,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          height: 1.45,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          height: 1.05,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          height: 1.1,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          height: 1.15,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, color: textTertiary, height: 1.35),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
    );
  }

  static ThemeData themeFor(ThemeSkin skin) {
    switch (skin) {
      case ThemeSkin.warm:
        return lightTheme;
      case ThemeSkin.fresh:
        return freshTheme;
      case ThemeSkin.classic:
        return classicTheme;
    }
  }

  static ThemeData get freshTheme {
    const freshPrimary = Color(0xFF2F8F83);
    const freshSecondary = Color(0xFF5B9BD5);
    const freshBackground = Color(0xFFEFF7F4);
    const freshSurface = Color(0xFFFFFFFF);
    const freshText = Color(0xFF243B3A);

    return _variantTheme(
      primaryColor: freshPrimary,
      secondaryColor: freshSecondary,
      backgroundColor: freshBackground,
      surfaceColor: freshSurface,
      textColor: freshText,
    );
  }

  static ThemeData get classicTheme {
    const classicPrimary = Color(0xFF4D5C7A);
    const classicSecondary = Color(0xFF8A6F4D);
    const classicBackground = Color(0xFFF4F5F7);
    const classicSurface = Color(0xFFFFFFFF);
    const classicText = Color(0xFF283040);

    return _variantTheme(
      primaryColor: classicPrimary,
      secondaryColor: classicSecondary,
      backgroundColor: classicBackground,
      surfaceColor: classicSurface,
      textColor: classicText,
    );
  }

  static ThemeData _variantTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final base = lightTheme;
    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: error,
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
        onError: Colors.white,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        foregroundColor: textColor,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: textColor,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : textTertiary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(
            color: primaryColor.withValues(alpha: 0.36),
            width: 1.2,
          ),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(color: surfaceColor),
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }
}
