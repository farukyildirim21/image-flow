import 'package:hive_flutter/hive_flutter.dart';
import 'package:imageflow/core/constants/app_constants.dart';
import 'package:imageflow/data/models/processing_record_model.dart';


class HiveService {
  late Box<ProcessingRecordModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ProcessingRecordModel>(AppConstants.historyBoxName);
  }

  Future<void> save(ProcessingRecordModel record) async {
    await _box.put(record.id, record);
  }

  List<ProcessingRecordModel> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.processedAt.compareTo(a.processedAt));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
