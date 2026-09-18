import 'document_picker.dart';

Future<PickedDocument?> pickDocumentImpl({
  required List<String> allowedExtensions,
}) async {
  throw UnsupportedError('Document picking is not supported on this platform.');
}
