import 'package:hive/hive.dart';
import 'package:imageflow/domain/entities/processing_record.dart';


part 'processing_record_model.g.dart';

@HiveType(typeId: 0)
class ProcessingRecordModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type;

  @HiveField(2)
  late DateTime processedAt;

  @HiveField(3)
  late String resultPath;

  @HiveField(4)
  String? originalPath;

  @HiveField(5)
  late int fileSizeBytes;

  @HiveField(6)
  String? extractedText;

  @HiveField(7)
  String? thumbnailPath;

  ProcessingRecord toEntity() => ProcessingRecord(
        id: id,
        type: type == 'face' ? ProcessingType.face : ProcessingType.document,
        processedAt: processedAt,
        resultPath: resultPath,
        originalPath: originalPath,
        thumbnailPath: thumbnailPath,
        fileSizeBytes: fileSizeBytes,
        extractedText: extractedText,
      );

  static ProcessingRecordModel fromEntity(ProcessingRecord record) {
    final model = ProcessingRecordModel()
      ..id = record.id
      ..type = record.type == ProcessingType.face ? 'face' : 'document'
      ..processedAt = record.processedAt
      ..resultPath = record.resultPath
      ..originalPath = record.originalPath
      ..thumbnailPath = record.thumbnailPath
      ..fileSizeBytes = record.fileSizeBytes
      ..extractedText = record.extractedText;
    return model;
  }
}
