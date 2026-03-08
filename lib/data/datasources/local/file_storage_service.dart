import 'dart:io';
import 'package:imageflow/core/constants/app_constants.dart';
import 'package:path_provider/path_provider.dart';


class FileStorageService {
  Future<String> getProcessedImagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/${AppConstants.processedImagesDir}');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<String> getPdfsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/${AppConstants.pdfsDir}');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<File> saveBytes(List<int> bytes, String fileName, {bool isPdf = false}) async {
    final dir = isPdf ? await getPdfsDir() : await getProcessedImagesDir();
    final file = File('$dir/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
