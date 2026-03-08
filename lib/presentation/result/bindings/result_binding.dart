import 'package:get/get.dart';
import 'package:imageflow/data/repositories/history_repository_impl.dart';
import 'package:imageflow/domain/usecases/save_record_usecase.dart';
import 'package:imageflow/presentation/result/controllers/result_controller.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(
      () => ResultController(
        saveRecord: SaveRecordUseCase(Get.find<HistoryRepositoryImpl>()),
      ),
    );
  }
}
