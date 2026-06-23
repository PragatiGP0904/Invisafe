import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Single source of truth for the app-wide [ThemeData].
///
/// Standardizing the theme here was one of the integration requirements: the
/// three source apps each shipped their own theme (Theme.InviSafe / Theme.Invisafe
/// in Material3 and Material.Light variants). They are unified into one dark
/// glassmorphism Material 3 theme.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.structuralCyan,
        secondary: AppColors.airSentinelBlue,
        surface: AppColors.surface,
        error: AppColors.severityCritical,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// A heading font used for the brand wordmark and module titles.
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.syncopate(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
        letterSpacing: 2,
      );
}
