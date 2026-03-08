import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<List<ProcessingRecord>> call() {
    return _repository.getHistory();
  }
}
