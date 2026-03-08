enum ProcessingType { face, document }

class ProcessingRecord {
  final String id;
  final ProcessingType type; //face or document
  final DateTime processedAt;
  final String resultPath;
  final String? originalPath;
  final String? thumbnailPath;
  final int fileSizeBytes;
  // Text extracted via OCR (document type only).
  final String? extractedText;

  const ProcessingRecord({
    required this.id,
    required this.type,
    required this.processedAt,
    required this.resultPath,
    this.originalPath,
    this.thumbnailPath,
    required this.fileSizeBytes,
    this.extractedText,
  });
  //Display title derived from the first meaningful OCR line.
  //Falls back to 'Scanned Document' when no text is available.
  String get documentTitle => _extractTitle(extractedText);

  //Filesystem-safe slug of 
  String get documentFilename => _toFilename(documentTitle);


  //Returns the first non-trivial line of [text] trimmed to 40 characters.
  static String extractTitle(String? text) => _extractTitle(text);

  //Converts [title] into a filesystem-safe slug.
  static String toFilename(String title) => _toFilename(title);

  static String _extractTitle(String? text) {
    if (text == null || text.trim().isEmpty) return 'Scanned Document';
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.length >= 2)
        .toList();
    if (lines.isEmpty) return 'Scanned Document';
    var title = lines.first;
    if (title.length > 40) title = '${title.substring(0, 37)}…';
    return title;
  }

  static String _toFilename(String title) {
    if (title == 'Scanned Document') return 'Scanned_Document';
    final slug = title
        .replaceAll(RegExp(r'[^\w\s\-]'), '') 
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')  
        .replaceAll(RegExp(r'_+'), '_')  
        .replaceAll(RegExp(r'^_+|_+$'), ''); 
    return slug.isEmpty ? 'Scanned_Document' : slug;
  }
}
