import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'package:imageflow/presentation/capture/controllers/capture_controller.dart';


//Bottom sheet — Camera / Gallery source selection.
//After picking, ML Kit on the processing screen auto-detects face vs document.
class CaptureView extends StatelessWidget {
  const CaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaptureController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        // "Choose Source"
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Text('Choose Source', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSpacing.md),
              _buildOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: controller.pickFromCamera,
                marginBottom: true,
              ),

              // Gallery
              _buildOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: controller.pickFromGallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

 
  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool marginBottom = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: marginBottom
            ? const EdgeInsets.only(bottom: AppSpacing.sm)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(72, 76, 109, 0.2),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,  
          horizontal: AppSpacing.md, 
        ),
        child: Row(
          children: [
            
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: AppSpacing.sm), 
            Text(label, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
