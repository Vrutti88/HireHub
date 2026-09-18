import 'dart:typed_data';
import 'document_picker_stub.dart'
    if (dart.library.js_interop) 'document_picker_web.dart'
    if (dart.library.io) 'document_picker_io.dart' as impl;

/// Result of picking a document
class PickedDocument {
  final String name;
  final Uint8List bytes;
  final int size;

  const PickedDocument({
    required this.name,
    required this.bytes,
    required this.size,
  });
}

/// Universal cross-platform document picker
/// Seamlessly handles Web (with native HTML5 fallback) and Native (iOS/Android/Desktop)
class DocumentPicker {
  DocumentPicker._();

  /// Picks a document file (PDF, DOCX, DOC, TXT) across all platforms.
  /// Never throws UnimplementedError on Web even if plugin registration was skipped.
  static Future<PickedDocument?> pickDocument({
    List<String> allowedExtensions = const ['pdf', 'docx', 'doc', 'txt', 'rtf'],
  }) {
    return impl.pickDocumentImpl(allowedExtensions: allowedExtensions);
  }
}
