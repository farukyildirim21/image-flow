import 'package:imageflow/domain/entities/processing_record.dart';

abstract class ImageProcessingRepository {
  Future<ProcessingRecord> processFaceImage(String imagePath);
  Future<ProcessingRecord> processDocumentImage(String imagePath);
}
