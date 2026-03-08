class AppErrors {
  AppErrors._();

  // Processing
  static const String noImagePath       = 'No image path provided.';
  static const String nothingDetected   = 'No face or text detected in this image.\nTry a clearer photo.';
  static const String processingFailed  = 'Something went wrong.\nPlease try again.';

  // File operations
  static const String fileNotFound      = 'File not found.';
  static const String noAppToOpen       = 'No app available to open this file type.';
  static const String openFailed        = 'Could not open the file.';

  // History
  static const String loadFailed        = 'Failed to load history.';
  static const String saveFailed        = 'Failed to save result.';
  static const String deleteFailed      = 'Failed to delete record.';
}
