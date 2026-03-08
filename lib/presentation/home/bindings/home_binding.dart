import 'package:get/get.dart';
import 'package:imageflow/data/datasources/local/file_storage_service.dart';
import 'package:imageflow/data/repositories/history_repository_impl.dart';
import 'package:imageflow/domain/usecases/delete_record_usecase.dart';
import 'package:imageflow/domain/usecases/get_history_usecase.dart';
import 'package:imageflow/presentation/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // HiveService is already registered in main.dart as permanent.
    Get.lazyPut(() => FileStorageService());
    Get.lazyPut(() => HistoryRepositoryImpl(
          hiveService: Get.find(),
          fileStorage: Get.find(),
        ));
    Get.lazyPut(() => GetHistoryUseCase(Get.find<HistoryRepositoryImpl>()));
    Get.lazyPut(() => DeleteRecordUseCase(Get.find<HistoryRepositoryImpl>()));
    Get.lazyPut<HomeController>(() => HomeController(
          getHistory: Get.find(),
          deleteRecord: Get.find(),
        ));
  }
}
