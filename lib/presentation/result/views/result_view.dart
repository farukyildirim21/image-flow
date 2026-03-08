import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_gradients.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/presentation/result/controllers/result_controller.dart';
import 'package:imageflow/presentation/shared/widgets/ocr_text_panel.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResultController>();
    final record = controller.record;
    final isFace = record.type == ProcessingType.face;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                      _TitleRow(
                text: isFace ? 'Face Result' : 'PDF Created',
                onBack: controller.discard,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isFace) ...[
                _FaceSwipeCompare(record: record),
                const Spacer(),
              ] else ...[
                Expanded(
                  child: _DocumentSection(
                    record: record,
                    controller: controller,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _PrimaryButton(
                label: isFace ? 'Done' : 'Open PDF',
                onTap: isFace ? controller.done : controller.openPdf,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.text, required this.onBack});
  final String text;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _FaceSwipeCompare extends StatefulWidget {
  const _FaceSwipeCompare({required this.record});
  final ProcessingRecord record;

  @override
  State<_FaceSwipeCompare> createState() => _FaceSwipeCompareState();
}

class _FaceSwipeCompareState extends State<_FaceSwipeCompare> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 360,
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _ImageCard(label: 'Before', path: widget.record.originalPath),
              _ImageCard(label: 'After', path: widget.record.resultPath),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _page == i
                    ? AppColors.burrowingOwl
                    : AppColors.greatGreyOwl,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '← swipe to compare →',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.label, required this.path});
  final String label;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(child: _buildImage()),
      ],
    );
  }

  Widget _buildImage() {
    if (path == null || path!.isEmpty) return _placeholder();
    final file = File(path!);
    if (!file.existsSync()) return _placeholder();

    return Image.file(
      file,
      fit: BoxFit.contain,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.image_outlined, size: 36, color: AppColors.textMuted),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({required this.record, required this.controller});
  final ProcessingRecord record;
  final ResultController controller;

  @override
  Widget build(BuildContext context) {
    final hasText = record.extractedText?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DocThumbnail(
          path: record.thumbnailPath ?? record.originalPath,
          title: record.documentTitle,
        ),
        if (hasText) ...[
          const SizedBox(height: AppSpacing.md),
          Expanded(child: OcrTextPanel(text: record.extractedText!)),
        ] else
          const Spacer(),
      ],
    );
  }
}

class _DocThumbnail extends StatefulWidget {
  const _DocThumbnail({required this.path, required this.title});
  final String? path;
  final String title;

  @override
  State<_DocThumbnail> createState() => _DocThumbnailState();
}

class _DocThumbnailState extends State<_DocThumbnail> {
  Future<double?>? _aspectFuture;

  @override
  void initState() {
    super.initState();
    final p = widget.path;
    if (p != null && File(p).existsSync()) {
      _aspectFuture = _detectAspectRatio(p);
    }
  }

  static Future<double?> _detectAspectRatio(String path) {
    final completer = Completer<double?>();
    FileImage(File(path))
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener(
          (info, _) {
            if (!completer.isCompleted) {
              completer.complete(info.image.width / info.image.height);
            }
          },
          onError: (_, __) {
            if (!completer.isCompleted) completer.complete(null);
          },
        ));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.path;
    final hasImage = p != null && File(p).existsSync();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage)
            FutureBuilder<double?>(
              future: _aspectFuture,
              builder: (_, snap) => _buildImage(p!, snap.data),
            )
          else
            _buildFallback(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, double? ar) {
    if (ar == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(width: 120, height: 150, color: AppColors.bgElevated),
      );
    }

    final isLandscape = ar > 1;

    if (isLandscape) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AspectRatio(
          aspectRatio: ar,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: 720,
          ),
        ),
      );
    }

    // Portrait: fixed 120 px wide, height capped at 180 px.
    final h = (120.0 / ar).clamp(0.0, 180.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 120,
        height: h,
        child: Image.file(File(path), fit: BoxFit.cover, cacheWidth: 360),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(234, 79, 108, 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(
          'PDF',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.burrowingOwl,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style:  AppTextStyles.buttonLabel
        ),
      ),
    );
  }
}
