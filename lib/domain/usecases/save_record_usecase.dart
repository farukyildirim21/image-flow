import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/history_repository.dart';

class SaveRecordUseCase {
  final HistoryRepository _repository;

  SaveRecordUseCase(this._repository);

  Future<void> call(ProcessingRecord record) {
    return _repository.saveRecord(record);
  }
}
