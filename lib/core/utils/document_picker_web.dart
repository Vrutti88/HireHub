import 'dart:async';
import 'dart:js_interop';
import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;
import 'document_picker.dart';

Future<PickedDocument?> pickDocumentImpl({
  required List<String> allowedExtensions,
}) async {
  // 1. First attempt: standard FilePicker plugin
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result.isNotEmpty) {
      final file = result.first;
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        return PickedDocument(
          name: file.name,
          bytes: bytes,
          size: bytes.length,
        );
      }
    }
  } catch (_) {
    // Silently fall through to native HTML5 DOM input fallback
    // This happens when the web plugin wasn't compiled into the running dev server
  }

  // 2. Native HTML5 DOM Fallback: Works 100% of the time in any web browser
  final completer = Completer<PickedDocument?>();
  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = allowedExtensions.map((e) => '.$e').join(',');
  input.style.display = 'none';
  web.document.body?.append(input);

  input.addEventListener(
    'change',
    ((web.Event event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        if (!completer.isCompleted) completer.complete(null);
        input.remove();
        return;
      }

      final file = files.item(0)!;
      final fileName = file.name;
      final reader = web.FileReader();

      reader.addEventListener(
        'loadend',
        ((web.Event _) {
          if (!completer.isCompleted) {
            final result = reader.result;
            if (result != null) {
              final byteBuffer = (result as JSArrayBuffer).toDart;
              final bytes = byteBuffer.asUint8List();
              completer.complete(
                PickedDocument(
                  name: fileName,
                  bytes: bytes,
                  size: bytes.length,
                ),
              );
            } else {
              completer.complete(null);
            }
          }
          input.remove();
        }).toJS,
      );

      reader.addEventListener(
        'error',
        ((web.Event _) {
          if (!completer.isCompleted) completer.complete(null);
          input.remove();
        }).toJS,
      );

      reader.readAsArrayBuffer(file);
    }).toJS,
  );

  input.addEventListener(
    'cancel',
    ((web.Event _) {
      if (!completer.isCompleted) completer.complete(null);
      input.remove();
    }).toJS,
  );

  input.click();
  return completer.future;
}
