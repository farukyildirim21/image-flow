import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DocumentProcessingService {
  Future<({Uint8List pdfBytes, Uint8List thumbnailBytes})> generatePdf(
    String imagePath,
    String extractedText, {
    String title = 'Scanned Document',
  }) async {
    try {
      return await _generateWithOpenCv(imagePath, extractedText, title);
    } catch (_) {
      return _generateFallback(imagePath, extractedText, title);
    }
  }

  Future<({Uint8List pdfBytes, Uint8List thumbnailBytes})> _generateWithOpenCv(
    String imagePath,
    String extractedText,
    String title,
  ) async {
    final src = cv.imread(imagePath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) throw Exception('cv.imread returned empty Mat for: $imagePath');

    final corners = _detectDocumentCorners(src);

    final cv.Mat corrected;
    if (corners != null) {
      corrected = _applyPerspective(src, corners);
    } else {
      corrected = src.clone();
    }
    src.dispose();

    final enhanced = cv.convertScaleAbs(corrected, alpha: 1.2, beta: 10);
    corrected.dispose();

    final cv.Mat toEncode;
    if (enhanced.width > 1800) {
      final scale = 1800 / enhanced.width;
      toEncode = cv.resize(
        enhanced,
        (1800, (enhanced.height * scale).round()),
      );
      enhanced.dispose();
    } else {
      toEncode = enhanced;
    }

    final (_, jpgBytes) = cv.imencode(
      '.jpg',
      toEncode,
      params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 85]),
    );
    toEncode.dispose();

    final pdfBytes = await _buildPdf(jpgBytes, extractedText, title);
    return (pdfBytes: pdfBytes, thumbnailBytes: jpgBytes);
  }

  Future<({Uint8List pdfBytes, Uint8List thumbnailBytes})> _generateFallback(
    String imagePath,
    String extractedText,
    String title,
  ) async {
    final rawBytes = await File(imagePath).readAsBytes();
    var source = img.decodeImage(rawBytes);
    if (source == null) throw Exception('image package could not decode: $imagePath');

    if (source.width > 1800) {
      source = img.copyResize(source, width: 1800, interpolation: img.Interpolation.linear);
    }

    img.adjustColor(source, contrast: 1.15, brightness: 1.05);
    final jpgBytes = Uint8List.fromList(img.encodeJpg(source, quality: 85));
    final pdfBytes = await _buildPdf(jpgBytes, extractedText, title);
    return (pdfBytes: pdfBytes, thumbnailBytes: jpgBytes);
  }

  List<cv.Point>? _detectDocumentCorners(cv.Mat src) {
    const int targetW = 1000;
    final double scale = src.width > targetW ? targetW / src.width : 1.0;
    final cv.Mat small = scale < 1.0
        ? cv.resize(src, (targetW, (src.height * scale).round()))
        : src;

    final corners = _detectOnMat(small, small.width * small.height);

    if (scale < 1.0) small.dispose();
    if (corners == null) return null;

    return corners
        .map((p) => cv.Point((p.x / scale).round(), (p.y / scale).round()))
        .toList();
  }

  List<cv.Point>? _detectOnMat(cv.Mat mat, int area) {
    final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

    const cannyProfiles = [
      (21, 30.0, 90.0, 11),
      (21, 30.0, 90.0, 21),
      (13, 20.0, 80.0, 15),
      (7,  15.0, 60.0, 21),
    ];

    for (final (ksize, lo, hi, closeSize) in cannyProfiles) {
      try {
        final blurred = cv.gaussianBlur(gray, (ksize, ksize), 0);
        final edges   = cv.canny(blurred, lo, hi);
        blurred.dispose();
        final ck     = cv.getStructuringElement(cv.MORPH_RECT, (closeSize, closeSize));
        final dil    = cv.dilate(edges, ck);
        edges.dispose();
        final closed = cv.erode(dil, ck);
        dil.dispose();
        ck.dispose();
        final (ct, _) = cv.findContours(
            closed, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
        closed.dispose();

        final maxArea = lo < 20.0 ? 0.80 : 0.92;
        final r = _bestQuad(ct, area, maxAreaFraction: maxArea);
        if (r != null) {
          gray.dispose();
          return r;
        }
      } catch (_) {
        break;
      }
    }

    // Threshold-based fallback — used when Canny can't find the boundary
    // (e.g. paper on a light table). Large morphological close bridges gaps
    // so the full page is detected as one contour.
    try {
      final b = cv.gaussianBlur(gray, (5, 5), 0);
      for (final thresh in [180.0, 150.0, 120.0]) {
        final (_, binary) = cv.threshold(b, thresh, 255, cv.THRESH_BINARY);
        final ck     = cv.getStructuringElement(cv.MORPH_RECT, (50, 50));
        final dil    = cv.dilate(binary, ck);
        binary.dispose();
        final closed = cv.erode(dil, ck);
        dil.dispose();
        ck.dispose();
        final (ct, _) = cv.findContours(
            closed, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
        closed.dispose();
        final r = _bestQuad(ct, area);
        if (r != null) {
          b.dispose();
          gray.dispose();
          return r;
        }
      }
      b.dispose();
    } catch (_) {}

    gray.dispose();
    return null;
  }

  /// Returns the corners of the largest quadrilateral contour, or null.
  /// [maxAreaFraction] rejects image-boundary false positives on textured
  /// backgrounds where Canny merges edges into a single frame-sized blob.
  List<cv.Point>? _bestQuad(
    dynamic contours,
    int area, {
    double minAreaFraction = 0.10,
    double maxAreaFraction = 0.92,
  }) {
    final ranked = <({int idx, double a})>[];
    for (var i = 0; i < (contours.length as int); i++) {
      ranked.add((idx: i, a: cv.contourArea(contours[i])));
    }
    ranked.sort((x, y) => y.a.compareTo(x.a));

    for (final entry in ranked.take(10)) {
      if (entry.a < area * minAreaFraction) break;
      if (entry.a > area * maxAreaFraction) continue;
      final ct   = contours[entry.idx];
      final peri = cv.arcLength(ct, true);
      for (final eps in [0.02, 0.03, 0.04, 0.05, 0.06]) {
        final approx = cv.approxPolyDP(ct, eps * peri, true);
        if (approx.length == 4) return approx.toList();
      }
    }
    return null;
  }

  cv.Mat _applyPerspective(cv.Mat src, List<cv.Point> rawCorners) {
    final corners = _orderCorners(rawCorners);
    final w = _calcWidth(corners);
    final h = _calcHeight(corners);

    final dst = [
      cv.Point(0, 0),
      cv.Point(w - 1, 0),
      cv.Point(w - 1, h - 1),
      cv.Point(0, h - 1),
    ];

    final M = cv.getPerspectiveTransform(corners.cvd, dst.cvd);
    final warped = cv.warpPerspective(src, M, (w, h));
    M.dispose();
    return warped;
  }

  /// Orders 4 points as [TL, TR, BR, BL].
  /// TL = min(x+y),  BR = max(x+y),  TR = max(x−y),  BL = min(x−y)
  List<cv.Point> _orderCorners(List<cv.Point> pts) {
    final sorted = [...pts]
      ..sort((a, b) => (a.x + a.y).compareTo(b.x + b.y));
    final tl = sorted[0];
    final br = sorted[3];
    final mid = [sorted[1], sorted[2]]
      ..sort((a, b) => (a.x - a.y).compareTo(b.x - b.y));
    return [tl, mid[1], br, mid[0]];
  }

  int _calcWidth(List<cv.Point> c) =>
      max(_dist(c[0], c[1]), _dist(c[3], c[2])).ceil();

  int _calcHeight(List<cv.Point> c) =>
      max(_dist(c[0], c[3]), _dist(c[1], c[2])).ceil();

  double _dist(cv.Point a, cv.Point b) =>
      sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

  Future<Uint8List> _buildPdf(
    Uint8List imageBytes,
    String extractedText,
    String title,
  ) async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold    = await PdfGoogleFonts.notoSansBold();

    final doc = pw.Document(
      title: title,
      author: 'ImageFlow',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    // Page sized to match image dimensions (longest side capped at 841.89 pt = A4).
    // This eliminates the white background behind the scan.
    final decoded = img.decodeImage(imageBytes)!;
    final imgW    = decoded.width.toDouble();
    final imgH    = decoded.height.toDouble();
    const maxPts  = 841.89;
    final ptScale = maxPts / (imgW > imgH ? imgW : imgH);
    final pageFormat = PdfPageFormat(
      imgW * ptScale,
      imgH * ptScale,
      marginAll: 0,
    );

    final pdfImage = pw.MemoryImage(imageBytes);
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.Image(pdfImage, fit: pw.BoxFit.fill),
      ),
    );

    return Uint8List.fromList(await doc.save());
  }
}
