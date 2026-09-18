import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with HireHub Firebase application.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-oNNnpdHNjBA9Hrf53i23aXP6YM_-h4A',
    appId: '1:351234632257:web:3390b9111360c13c6134c0',
    messagingSenderId: '351234632257',
    projectId: 'hire-hub-93181',
    authDomain: 'hire-hub-93181.firebaseapp.com',
    storageBucket: 'hire-hub-93181.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-oNNnpdHNjBA9Hrf53i23aXP6YM_-h4A',
    appId: '1:351234632257:android:3390b9111360c13c6134c0',
    messagingSenderId: '351234632257',
    projectId: 'hire-hub-93181',
    storageBucket: 'hire-hub-93181.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-oNNnpdHNjBA9Hrf53i23aXP6YM_-h4A',
    appId: '1:351234632257:ios:3390b9111360c13c6134c0',
    messagingSenderId: '351234632257',
    projectId: 'hire-hub-93181',
    storageBucket: 'hire-hub-93181.firebasestorage.app',
    iosBundleId: 'com.example.hirehub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-oNNnpdHNjBA9Hrf53i23aXP6YM_-h4A',
    appId: '1:351234632257:ios:3390b9111360c13c6134c0',
    messagingSenderId: '351234632257',
    projectId: 'hire-hub-93181',
    storageBucket: 'hire-hub-93181.firebasestorage.app',
    iosBundleId: 'com.example.hirehub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-oNNnpdHNjBA9Hrf53i23aXP6YM_-h4A',
    appId: '1:351234632257:web:3390b9111360c13c6134c0',
    messagingSenderId: '351234632257',
    projectId: 'hire-hub-93181',
    authDomain: 'hire-hub-93181.firebaseapp.com',
    storageBucket: 'hire-hub-93181.firebasestorage.app',
  );
}
