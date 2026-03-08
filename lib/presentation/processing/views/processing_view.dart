import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_gradients.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'package:imageflow/presentation/processing/controllers/processing_controller.dart';


class ProcessingView extends StatelessWidget {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessingController>();

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: SafeArea(
        child: Obx(() {
          if (controller.step.value == ProcessingStep.error) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ErrorCard(
                    message: controller.errorMessage.value,
                    onRetry: controller.retry,
                    onBack: controller.goBack,
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Image thumbnail 
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.greatGreyOwl.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: controller.imagePath.isNotEmpty
                        ? Image.file(
                            File(controller.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: AppColors.textMuted,
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppColors.textMuted,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  //"Processing..." title 
                  Text('Processing...', style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppSpacing.md),

                  //Progress bar 
                  _AnimatedProgressBar(step: controller.step.value),
                  const SizedBox(height: AppSpacing.md),

                  // Step label 
                  Text(
                    controller.stepLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

//Animated progress bar 

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({required this.step});

  final ProcessingStep step;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progress;

  static double _progressForStep(ProcessingStep step) {
    switch (step) {
      case ProcessingStep.analysing:
        return 0.20;
      case ProcessingStep.faceEffect:
      case ProcessingStep.recognising:
        return 0.50;
      case ProcessingStep.generating:
        return 0.70;
      case ProcessingStep.saving:
        return 0.85;
      case ProcessingStep.done:
        return 1.0;
      case ProcessingStep.error:
        return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progress = Tween<double>(
      begin: 0,
      end: _progressForStep(widget.step),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      final current = _progress.value;
      final next = _progressForStep(widget.step);
      _progress = Tween<double>(
        begin: current,
        end: next,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        return Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.greatGreyOwl.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          clipBehavior: Clip.hardEdge,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

//Error card 
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.greatGreyOwl),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burrowingOwl,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
