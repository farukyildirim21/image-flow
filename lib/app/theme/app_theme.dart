import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.burrowingOwl,
      secondary: AppColors.greatHornedOwl,
      surface: AppColors.bgSecondary,
      error: AppColors.error,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor:
        AppColors.bgSecondary, // #1A1A24 — matches .mockup background
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.elfOwl,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.elfOwl,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTextStyles.titleSmall,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.burrowingOwl,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.bgElevated,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
  );
}
