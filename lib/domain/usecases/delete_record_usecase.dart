import 'package:imageflow/domain/repositories/history_repository.dart';

class DeleteRecordUseCase {
  final HistoryRepository _repository;

  DeleteRecordUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteRecord(id);
  }
}
