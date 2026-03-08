import 'package:get/get.dart';
import 'package:imageflow/presentation/history_detail/bindings/history_detail_binding.dart';
import 'package:imageflow/presentation/history_detail/views/history_detail_view.dart';
import 'package:imageflow/presentation/home/bindings/home_binding.dart';
import 'package:imageflow/presentation/home/views/home_view.dart';
import 'package:imageflow/presentation/processing/bindings/processing_binding.dart';
import 'package:imageflow/presentation/processing/views/processing_view.dart';
import 'package:imageflow/presentation/result/bindings/result_binding.dart';
import 'package:imageflow/presentation/result/views/result_view.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // capture is shown as a bottom sheet — no route needed
    GetPage(
      name: AppRoutes.processing,
      page: () => const ProcessingView(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.historyDetail,
      page: () => const HistoryDetailView(),
      binding: HistoryDetailBinding(),
    ),
  ];
}
