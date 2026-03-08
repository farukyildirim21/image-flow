import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/image_processing_repository.dart';

class ProcessDocumentImageUseCase {
  final ImageProcessingRepository _repository;

  ProcessDocumentImageUseCase(this._repository);

  Future<ProcessingRecord> call(String imagePath) {
    return _repository.processDocumentImage(imagePath);
  }
}
