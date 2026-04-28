import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      displayLarge: _lighten(base.textTheme.displayLarge),
      displayMedium: _lighten(base.textTheme.displayMedium),
      displaySmall: _lighten(base.textTheme.displaySmall),
      headlineLarge: _lighten(base.textTheme.headlineLarge),
      headlineMedium: _lighten(base.textTheme.headlineMedium),
      headlineSmall: _lighten(base.textTheme.headlineSmall),
      titleLarge: _lighten(base.textTheme.titleLarge),
      titleMedium: _lighten(base.textTheme.titleMedium),
      titleSmall: _lighten(base.textTheme.titleSmall),
      bodyLarge: _lighten(base.textTheme.bodyLarge),
      bodyMedium: _lighten(base.textTheme.bodyMedium),
      bodySmall: _lighten(base.textTheme.bodySmall),
      labelLarge: _lighten(base.textTheme.labelLarge),
      labelMedium: _lighten(base.textTheme.labelMedium),
      labelSmall: _lighten(base.textTheme.labelSmall),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgWhite,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.headerEnd,
        surface: AppColors.bgWhite,
      ),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  static TextStyle? _lighten(TextStyle? style) {
    if (style == null) return null;
    final weight = style.fontWeight ?? FontWeight.normal;
    // Map weights down slightly to achieve the "10% reduction" look.
    final newWeight = switch (weight) {
      FontWeight.w900 => FontWeight.w800,
      FontWeight.w800 => FontWeight.w700,
      FontWeight.w700 => FontWeight.w600,
      FontWeight.w600 => FontWeight.w500,
      FontWeight.w500 => FontWeight.w400,
      FontWeight.w400 => FontWeight.w300,
      _ => weight,
    };
    return style.copyWith(fontWeight: newWeight);
  }
}
