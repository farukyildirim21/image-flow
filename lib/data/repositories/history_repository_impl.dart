import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:imageflow/core/constants/app_constants.dart';
import 'package:imageflow/data/datasources/local/file_storage_service.dart';
import 'package:imageflow/data/datasources/local/hive_service.dart';
import 'package:imageflow/data/models/processing_record_model.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HiveService _hiveService;
  final FileStorageService _fileStorage;

  HistoryRepositoryImpl({
    required HiveService hiveService,
    required FileStorageService fileStorage,
  })  : _hiveService = hiveService,
        _fileStorage = fileStorage;

  @override
  Future<void> saveRecord(ProcessingRecord record) async {
    await _hiveService.save(ProcessingRecordModel.fromEntity(record));
  }

  @override
  Future<List<ProcessingRecord>> getHistory() async {
    final appDocs = (await getApplicationDocumentsDirectory()).path;
    return _hiveService.getAll()
        .map((m) => _repairPaths(m.toEntity(), appDocs))
        .toList();
  }

  @override
  Future<void> deleteRecord(String id) async {
    final records = _hiveService.getAll();
    final record = records.where((r) => r.id == id).firstOrNull;
    if (record != null) {
      await _fileStorage.deleteFile(record.resultPath);
      if (record.thumbnailPath != null) {
        await _fileStorage.deleteFile(record.thumbnailPath!);
      }
      if (record.originalPath != null) {
        final original = File(record.originalPath!);
        final docsDir = original.parent.path;
        final managedDirs = [
          await _fileStorage.getProcessedImagesDir(),
          await _fileStorage.getPdfsDir(),
        ];
        if (managedDirs.any((d) => docsDir.startsWith(d))) {
          await _fileStorage.deleteFile(record.originalPath!);
        }
      }
    }
    await _hiveService.delete(id);
  }

  /// On iOS the app-container path can change between launches.
  /// If a stored path no longer exists, reconstruct it from the filename
  /// against the current AppDocs directory.
  static ProcessingRecord _repairPaths(ProcessingRecord r, String appDocs) {
    return ProcessingRecord(
      id: r.id,
      type: r.type,
      processedAt: r.processedAt,
      resultPath: _fixPath(r.resultPath, appDocs),
      originalPath: r.originalPath,
      thumbnailPath: r.thumbnailPath != null
          ? _fixPath(r.thumbnailPath!, appDocs)
          : null,
      fileSizeBytes: r.fileSizeBytes,
      extractedText: r.extractedText,
    );
  }

  static String _fixPath(String stored, String appDocs) {
    if (File(stored).existsSync()) return stored;
    final name = stored.split('/').last;
    final subdir = name.endsWith('.pdf')
        ? AppConstants.pdfsDir
        : AppConstants.processedImagesDir;
    return '$appDocs/$subdir/$name';
  }
}
