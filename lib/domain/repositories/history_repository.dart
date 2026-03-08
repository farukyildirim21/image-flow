import 'package:imageflow/domain/entities/processing_record.dart';

abstract class HistoryRepository {
  Future<void> saveRecord(ProcessingRecord record);
  Future<List<ProcessingRecord>> getHistory();
  Future<void> deleteRecord(String id);
}
