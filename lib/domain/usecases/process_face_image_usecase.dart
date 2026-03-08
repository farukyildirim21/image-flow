import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/image_processing_repository.dart';

class ProcessFaceImageUseCase {
  final ImageProcessingRepository _repository;

  ProcessFaceImageUseCase(this._repository);

  Future<ProcessingRecord> call(String imagePath) {
    return _repository.processFaceImage(imagePath);
  }
}
