import 'package:get/get.dart';
import 'package:imageflow/data/datasources/ml/document_processing_service.dart';
import 'package:imageflow/data/datasources/ml/face_detection_service.dart';
import 'package:imageflow/data/datasources/ml/face_processing_service.dart';
import 'package:imageflow/data/datasources/ml/text_recognition_service.dart';
import 'package:imageflow/data/repositories/image_processing_repository_impl.dart';
import 'package:imageflow/domain/usecases/process_document_image_usecase.dart';
import 'package:imageflow/domain/usecases/process_face_image_usecase.dart';
import 'package:imageflow/presentation/processing/controllers/processing_controller.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    // ML services – fenix: true so they are recreated if previously disposed.
    Get.lazyPut<FaceDetectionService>(() => FaceDetectionService(), fenix: true);
    Get.lazyPut<FaceProcessingService>(() => FaceProcessingService(), fenix: true);
    Get.lazyPut<TextRecognitionService>(() => TextRecognitionService(), fenix: true);
    Get.lazyPut<DocumentProcessingService>(() => DocumentProcessingService(), fenix: true);

    // FileStorageService is registered via HomeBinding.
    Get.lazyPut<ImageProcessingRepositoryImpl>(
      () => ImageProcessingRepositoryImpl(
        fileStorage: Get.find(),
        faceDetection: Get.find(),
        faceProcessing: Get.find(),
        textRecognition: Get.find(),
        documentProcessing: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProcessFaceImageUseCase>(
      () => ProcessFaceImageUseCase(Get.find<ImageProcessingRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<ProcessDocumentImageUseCase>(
      () => ProcessDocumentImageUseCase(Get.find<ImageProcessingRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<ProcessingController>(
      () => ProcessingController(
        faceDetection: Get.find(),
        textRecognition: Get.find(),
        processFace: Get.find(),
        processDocument: Get.find(),
      ),
    );
  }
}
