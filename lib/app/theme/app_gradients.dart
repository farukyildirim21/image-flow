import 'package:flutter/material.dart';
import 'package:imageflow/app/theme/app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.burrowingOwl, AppColors.greatHornedOwl],
  );

  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.screechOwl, AppColors.greatGreyOwl],
  );
}
