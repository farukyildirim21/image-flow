import 'package:get/get.dart';
import 'package:imageflow/app/routes/app_routes.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/core/errors/app_errors.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:imageflow/domain/usecases/save_record_usecase.dart';
import 'package:imageflow/presentation/home/controllers/home_controller.dart';

import 'package:open_filex/open_filex.dart';

class ResultController extends GetxController {
  final SaveRecordUseCase _saveRecord;

  ResultController({required SaveRecordUseCase saveRecord})
      : _saveRecord = saveRecord;

  late final ProcessingRecord record;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ProcessingRecord) {
      record = arg;
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> done() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      await _saveRecord(record);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().reloadHistory();
      }
      Get.offAllNamed(AppRoutes.home);
    } catch (_) {
      _showError(AppErrors.saveFailed);
      isSaving.value = false;
    }
  }

  void discard() {
    Get.offAllNamed(AppRoutes.home);
  }

  /// Document flow: save to history then open the PDF.
  Future<void> openPdf() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      await _saveRecord(record);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().reloadHistory();
      }
    } catch (_) {
      _showError(AppErrors.saveFailed);
      isSaving.value = false;
      return;
    }

    final path = record.resultPath;
    final result = await OpenFilex.open(path);
    switch (result.type) {
      case ResultType.done:
        break;
      case ResultType.fileNotFound:
        _showError(AppErrors.fileNotFound);
      case ResultType.noAppToOpen:
        _showError(AppErrors.noAppToOpen);
      case ResultType.permissionDenied:
        _showError(AppErrors.openFailed);
      case ResultType.error:
        _showError(AppErrors.openFailed);
    }
    isSaving.value = false;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error.withValues(alpha: 0.9),
      colorText: AppColors.textPrimary,
      duration: const Duration(seconds: 3),
    );
  }
}
