import 'package:get/get.dart';
import 'package:imageflow/app/routes/app_routes.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/core/errors/app_errors.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/usecases/delete_record_usecase.dart';
import 'package:imageflow/domain/usecases/get_history_usecase.dart';
import 'package:imageflow/presentation/capture/controllers/capture_controller.dart';
import 'package:imageflow/presentation/capture/views/capture_view.dart';

class HomeController extends GetxController {
  final GetHistoryUseCase _getHistory;
  final DeleteRecordUseCase _deleteRecord;

  HomeController({
    required GetHistoryUseCase getHistory,
    required DeleteRecordUseCase deleteRecord,
  })  : _getHistory = getHistory,
        _deleteRecord = deleteRecord;
  //reactive list
  final RxList<ProcessingRecord> history = <ProcessingRecord>[].obs; //obervable ->Yani değiştiğinde UI otomatik güncellenir.
  //reactive boolean
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void reloadHistory() => loadHistory();

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final records = await _getHistory();
      history.assignAll(records);
    } catch (_) {
      _showError(AppErrors.loadFailed);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _deleteRecord(id);
      history.removeWhere((r) => r.id == id);
    } catch (_) {
      _showError(AppErrors.deleteFailed);
    }
  }

  void goToCapture() {
    Get.lazyPut<CaptureController>(() => CaptureController(), fenix: true);
    Get.bottomSheet(
      const CaptureView(),
      backgroundColor: AppColors.transparent,
      isScrollControlled: false,
    );
  }

  void goToDetail(ProcessingRecord record) {
    Get.toNamed(AppRoutes.historyDetail, arguments: record);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error.withValues(alpha: 0.9),
      colorText:AppColors.textPrimary,
      duration: const Duration(seconds: 3),
    );
  }
}
