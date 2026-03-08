import 'package:flutter/material.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCapture;

  const EmptyStateWidget({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.burrowingOwl,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.textPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No processed images yet', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap the + button to get started',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
