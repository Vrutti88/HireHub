import 'package:file_picker/file_picker.dart';
import 'document_picker.dart';

Future<PickedDocument?> pickDocumentImpl({
  required List<String> allowedExtensions,
}) async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result.isEmpty) return null;
    final file = result.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;

    return PickedDocument(
      name: file.name,
      bytes: bytes,
      size: bytes.length,
    );
  } catch (e) {
    return null;
  }
}
