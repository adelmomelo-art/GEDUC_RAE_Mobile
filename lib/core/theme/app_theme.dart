import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'fenix_visual_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.azulInstitucional,
      scaffoldBackgroundColor: AppColors.cinzaClaro,
      colorScheme: const ColorScheme.light(
        primary: FenixVisualTokens.teal,
        onPrimary: FenixVisualTokens.surface,
        secondary: FenixVisualTokens.orange,
        onSecondary: FenixVisualTokens.surface,
        tertiary: FenixVisualTokens.blue,
        error: FenixVisualTokens.danger,
        surface: FenixVisualTokens.surface,
        onSurface: FenixVisualTokens.text,
        outline: FenixVisualTokens.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulInstitucional,
        foregroundColor: AppColors.branco,
        centerTitle: false,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.laranjaEducacao,
          foregroundColor: AppColors.branco,
          minimumSize: const Size(
            double.infinity,
            FenixVisualTokens.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FenixVisualTokens.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FenixVisualTokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FenixVisualTokens.radiusMedium),
          borderSide: const BorderSide(color: FenixVisualTokens.border),
        ),
      ),
      cardTheme: CardThemeData(
        color: FenixVisualTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FenixVisualTokens.radiusMedium),
          side: const BorderSide(color: FenixVisualTokens.border),
        ),
      ),
    );
  }
}
