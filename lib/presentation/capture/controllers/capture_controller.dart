import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imageflow/app/routes/app_routes.dart';



class CaptureController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  //Opens camera and navigates directly to processing.
  Future<void> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked != null) _navigateToProcessing(picked.path);
  }

  //Opens gallery and navigates directly to processing.
  Future<void> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) _navigateToProcessing(picked.path);
  }

  //Closes the bottom sheet and pushes the processing screen atomically.
  void _navigateToProcessing(String sourcePath) {
    Get.offNamedUntil(
      AppRoutes.processing,
      (route) => route.settings.name == AppRoutes.home,
      arguments: {'imagePath': sourcePath},
    );
  }
}
