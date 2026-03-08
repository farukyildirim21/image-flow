import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imageflow/app/theme/app_gradients.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/domain/entities/processing_record.dart';

class HistoryThumbnail extends StatelessWidget {
  final ProcessingType type;
  final String? imagePath;
  final double size;

  const HistoryThumbnail({
    super.key,
    required this.type,
    this.imagePath,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = type == ProcessingType.face
        ? AppGradients.primary
        : AppGradients.subtle;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: size,
        height: size,
        child: imagePath != null && File(imagePath!).existsSync()
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              )
            : Container(
                decoration: BoxDecoration(gradient: gradient),
              ),
      ),
    );
  }
}
