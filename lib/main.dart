import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_colors.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/models/processing_record_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.elfOwl,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(ProcessingRecordModelAdapter());

  final hiveService = HiveService();
  await hiveService.init();
  Get.put(hiveService, permanent: true);

  runApp(const ImageFlowApp());
}

class ImageFlowApp extends StatelessWidget {
  const ImageFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ImageFlow',
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
