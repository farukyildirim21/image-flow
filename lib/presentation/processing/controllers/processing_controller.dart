import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:imageflow/app/routes/app_routes.dart';
import 'package:imageflow/core/errors/app_errors.dart';
import 'package:imageflow/data/datasources/ml/face_detection_service.dart';
import 'package:imageflow/data/datasources/ml/text_recognition_service.dart';
import 'package:imageflow/domain/usecases/process_document_image_usecase.dart';
import 'package:imageflow/domain/usecases/process_face_image_usecase.dart';
import 'package:path_provider/path_provider.dart';

enum ProcessingStep {
  analysing,
  faceEffect,
  recognising,
  generating,
  saving,
  done,
  error,
}

class ProcessingController extends GetxController {
  final FaceDetectionService _faceDetection;
  final TextRecognitionService _textRecognition;
  final ProcessFaceImageUseCase _processFace;
  final ProcessDocumentImageUseCase _processDocument;

  ProcessingController({
    required FaceDetectionService faceDetection,
    required TextRecognitionService textRecognition,
    required ProcessFaceImageUseCase processFace,
    required ProcessDocumentImageUseCase processDocument,
  })  : _faceDetection = faceDetection,
        _textRecognition = textRecognition,
        _processFace = processFace,
        _processDocument = processDocument;

  final Rx<ProcessingStep> step = ProcessingStep.analysing.obs;
  final RxString errorMessage = ''.obs;

  late String imagePath;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    imagePath = (args?['imagePath'] as String?) ?? '';
    if (imagePath.isEmpty) {
      _setError(AppErrors.noImagePath);
      return;
    }
    _run();
  }

  Future<String> _normalizeImage(String sourcePath) async {
    try {
      final rawBytes = await File(sourcePath).readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded != null) {
        final jpgBytes = img.encodeJpg(decoded, quality: 90);
        final tmp = await getTemporaryDirectory();
        final out = File(
          '${tmp.path}/imgflow_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await out.writeAsBytes(jpgBytes);
        return out.path;
      }
    } catch (_) {
      // Normalisation failed — proceed with original file.
    }
    return sourcePath;
  }

  Future<void> _run() async {
    try {
      step.value = ProcessingStep.analysing;
      imagePath = await _normalizeImage(imagePath);

      final faces = await _faceDetection.detectFaces(imagePath);

      if (faces.isNotEmpty) {
        step.value = ProcessingStep.faceEffect;
        final record = await _processFace(imagePath);
        step.value = ProcessingStep.done;
        Get.offNamed(AppRoutes.result, arguments: record);
        return;
      }

      step.value = ProcessingStep.recognising;
      final recognized = await _textRecognition.recognizeText(imagePath);

      if (_textRecognition.hasText(recognized)) {
        step.value = ProcessingStep.generating;
        final record = await _processDocument(imagePath);
        step.value = ProcessingStep.done;
        Get.offNamed(AppRoutes.result, arguments: record);
        return;
      }

      _setError(AppErrors.nothingDetected);
    } catch (e, stack) {
      debugPrint('ProcessingController error: $e\n$stack');
      _setError(AppErrors.processingFailed);
    }
  }

  void _setError(String message) {
    errorMessage.value = message;
    step.value = ProcessingStep.error;
  }

  void retry() {
    errorMessage.value = '';
    _run();
  }

  void goBack() => Get.back();

  String get stepLabel {
    switch (step.value) {
      case ProcessingStep.analysing:
        return 'Analysing image…';
      case ProcessingStep.faceEffect:
        return 'Detecting faces…';
      case ProcessingStep.recognising:
        return 'Recognising text…';
      case ProcessingStep.generating:
        return 'Generating document…';
      case ProcessingStep.saving:
        return 'Saving result…';
      case ProcessingStep.done:
        return 'Done';
      case ProcessingStep.error:
        return 'Error';
    }
  }
}
