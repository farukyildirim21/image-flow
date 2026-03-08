import 'package:uuid/uuid.dart';
import 'package:imageflow/data/datasources/local/file_storage_service.dart';
import 'package:imageflow/data/datasources/ml/document_processing_service.dart';
import 'package:imageflow/data/datasources/ml/face_detection_service.dart';
import 'package:imageflow/data/datasources/ml/face_processing_service.dart';
import 'package:imageflow/data/datasources/ml/text_recognition_service.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/image_processing_repository.dart';

class ImageProcessingRepositoryImpl implements ImageProcessingRepository {
  final FileStorageService _fileStorage;
  final FaceDetectionService _faceDetection;
  final FaceProcessingService _faceProcessing;
  final TextRecognitionService _textRecognition;
  final DocumentProcessingService _documentProcessing;

  ImageProcessingRepositoryImpl({
    required FileStorageService fileStorage,
    required FaceDetectionService faceDetection,
    required FaceProcessingService faceProcessing,
    required TextRecognitionService textRecognition,
    required DocumentProcessingService documentProcessing,
  })  : _fileStorage = fileStorage,
        _faceDetection = faceDetection,
        _faceProcessing = faceProcessing,
        _textRecognition = textRecognition,
        _documentProcessing = documentProcessing;

  @override
  Future<ProcessingRecord> processFaceImage(String imagePath) async {
    final faces = await _faceDetection.detectFaces(imagePath);
    final processedBytes = await _faceProcessing.process(imagePath, faces);

    final id = const Uuid().v4();
    final savedFile = await _fileStorage.saveBytes(processedBytes, 'face_$id.png');

    final record = ProcessingRecord(
      id: id,
      type: ProcessingType.face,
      processedAt: DateTime.now(),
      resultPath: savedFile.path,
      originalPath: imagePath,
      fileSizeBytes: await savedFile.length(),
    );

    return record;
  }

  @override
  Future<ProcessingRecord> processDocumentImage(String imagePath) async {
    final recognized = await _textRecognition.recognizeText(imagePath);
    final extractedText = recognized.text.trim();

    final title = ProcessingRecord.extractTitle(extractedText);
    final slug = ProcessingRecord.toFilename(title);

    final result = await _documentProcessing.generatePdf(
      imagePath,
      extractedText,
      title: title,
    );

    final id = const Uuid().v4();
    final savedFile = await _fileStorage.saveBytes(
      result.pdfBytes,
      '$slug.pdf',
      isPdf: true,
    );
    final thumbFile = await _fileStorage.saveBytes(
      result.thumbnailBytes,
      'thumb_$id.jpg',
    );

    final record = ProcessingRecord(
      id: id,
      type: ProcessingType.document,
      processedAt: DateTime.now(),
      resultPath: savedFile.path,
      originalPath: imagePath,
      thumbnailPath: thumbFile.path,
      fileSizeBytes: await savedFile.length(),
      extractedText: extractedText.isEmpty ? null : extractedText,
    );

    return record;
  }
}
