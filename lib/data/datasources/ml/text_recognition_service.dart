import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<RecognizedText> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return _recognizer.processImage(inputImage);
  }

  bool hasText(RecognizedText result) => result.text.trim().isNotEmpty;

  void dispose() {
    _recognizer.close();
  }
}
