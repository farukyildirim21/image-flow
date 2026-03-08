import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceProcessingService {
 
  //Returns PNG-encoded bytes of the processed image.
  Future<Uint8List> process(String imagePath, List<Face> faces) async {
    final rawBytes = await File(imagePath).readAsBytes();
    final source = img.decodeImage(rawBytes);
    if (source == null) throw Exception('Could not decode image at $imagePath');

    // Downscale large images for a manageable output size (max 1500 px wide).
    final resized = source.width > 1500
        ? img.copyResize(
            source,
            width: 1500,
            interpolation: img.Interpolation.linear,
          )
        : source;

    // Start with the full-colour image as the output canvas.
    final output = resized.clone();

    if (faces.isNotEmpty) {
      final scaleX = resized.width / source.width;
      final scaleY = resized.height / source.height;

      for (final face in faces) {
        final box = face.boundingBox;

        final padX = (box.width * 0.30 * scaleX).toInt();
        final padY = (box.height * 0.30 * scaleY).toInt();

        final x1 = ((box.left * scaleX).toInt() - padX).clamp(
          0,
          resized.width - 1,
        );
        final y1 = ((box.top * scaleY).toInt() - padY).clamp(
          0,
          resized.height - 1,
        );

        final cropW = ((box.width * scaleX).toInt() + padX * 2).clamp(
          1,
          resized.width - x1,
        );

        final cropH = ((box.height * scaleY).toInt() + padY * 2).clamp(
          1,
          resized.height - y1,
        );

        final faceCrop = img.copyCrop(
          resized,
          x: x1,
          y: y1,
          width: cropW,
          height: cropH,
        );

        img.grayscale(faceCrop);

        img.compositeImage(output, faceCrop, dstX: x1, dstY: y1);
      }
    }

    return Uint8List.fromList(img.encodePng(output));
  }
}
