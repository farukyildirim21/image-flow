import 'package:get/get.dart';
import 'package:imageflow/app/routes/app_routes.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/core/errors/app_errors.dart';
import 'package:imageflow/domain/entities/processing_record.dart';
import 'package:open_filex/open_filex.dart';

class HistoryDetailController extends GetxController {
  late final ProcessingRecord record;

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

  Future<void> openPdf() async {
    if (record.resultPath.isEmpty) {
      _showError(AppErrors.fileNotFound);
      return;
    }
    final result = await OpenFilex.open(record.resultPath);
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
  }

  void goBack() => Get.back();

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
