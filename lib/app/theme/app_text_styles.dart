import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imageflow/app/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      );
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 14, 
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  
  static TextStyle get highlight => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        backgroundColor: AppColors.burrowingOwl.withValues(alpha: 0.35),
      );
}
