import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_gradients.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/presentation/history_detail/controllers/history_detail_controller.dart';
import 'package:imageflow/presentation/shared/widgets/ocr_text_panel.dart';

class HistoryDetailView extends StatelessWidget {
  const HistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryDetailController>();
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
                text: isFace ? 'Face Processed' : record.documentTitle,
                onBack: controller.goBack,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isFace) ...[
                Expanded(child: _FacePreview(path: record.resultPath)),
              ] else ...[
                _PdfPreview(
                  title: record.documentTitle,
                  thumbnailPath: record.thumbnailPath ?? record.originalPath,
                ),
                if (record.extractedText?.isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.md),
                  Expanded(child: OcrTextPanel(text: record.extractedText!)),
                ] else
                  const Spacer(),
              ],
              const SizedBox(height: AppSpacing.md),
              _MetadataCard(record: record),
              if (!isFace) ...[
                const SizedBox(height: AppSpacing.md),
                _OpenPdfButton(onTap: controller.openPdf),
              ],
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

class _FacePreview extends StatelessWidget {
  const _FacePreview({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: path.isNotEmpty && File(path).existsSync()
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.bgElevated,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted),
      ),
    );
  }
}

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({required this.title, this.thumbnailPath});
  final String title;
  final String? thumbnailPath;

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  Future<double?>? _aspectFuture;

  @override
  void initState() {
    super.initState();
    final path = widget.thumbnailPath;
    if (path != null && File(path).existsSync()) {
      _aspectFuture = _detectAspectRatio(path);
    }
  }

  static Future<double?> _detectAspectRatio(String path) {
    final completer = Completer<double?>();
    FileImage(File(path))
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (info, _) {
              if (!completer.isCompleted) {
                completer.complete(info.image.width / info.image.height);
              }
            },
            onError: (_, __) {
              if (!completer.isCompleted) completer.complete(null);
            },
          ),
        );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.thumbnailPath;
    final hasImage = path != null && File(path).existsSync();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasImage)
          FutureBuilder<double?>(
            future: _aspectFuture,
            builder: (_, snap) => _buildImage(path, snap.data),
          )
        else
          _buildFallback(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String path, double? ar) {
    if (ar == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(height: 140, color: AppColors.bgElevated),
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

    final h = (130.0 / ar).clamp(0.0, 140.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 130,
        height: h,
        child: Image.file(File(path), fit: BoxFit.cover, cacheWidth: 390),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: 100,
      height: 130,
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

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.record});
  final ProcessingRecord record;

  String get _formattedDate =>
      DateFormat('MMM d, yyyy – HH:mm').format(record.processedAt);

  String get _typeLabel =>
      record.type == ProcessingType.face ? 'Face Processing' : 'Document Scan';

  String get _fileSize {
    final bytes = record.fileSizeBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.auto_awesome_outlined,
            label: 'Type',
            value: _typeLabel,
          ),
          const _Divider(),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formattedDate,
          ),
          const _Divider(),
          _MetaRow(
            icon: Icons.data_usage_outlined,
            label: 'Size',
            value: _fileSize,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color.fromRGBO(72, 76, 109, 0.3), height: 1);
  }
}

class _OpenPdfButton extends StatelessWidget {
  const _OpenPdfButton({required this.onTap});
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
        child: const Text(
          'Open PDF',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
