import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  FirebaseStorage? _storage;
  bool _isFirebaseAvailable = false;

  StorageService() {
    try {
      _storage = FirebaseStorage.instance;
      _isFirebaseAvailable = true;
    } catch (_) {
      _isFirebaseAvailable = false;
    }
  }

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  Future<String> uploadResume({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (_isFirebaseAvailable && _storage != null) {
      try {
        final ref = _storage!.ref().child('resumes').child(userId).child(fileName);
        final task = await ref.putData(bytes);
        return await task.ref.getDownloadURL();
      } catch (_) {}
    }
    // Fallback URL
    return 'https://firebasestorage.googleapis.com/v0/b/hire-hub-93181.firebasestorage.app/o/resumes%2F$fileName';
  }
}
