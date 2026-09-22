import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For now, we only configure Web since we are running in Chrome.
    // If you compile for Windows later, we will configure Windows.
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiuLmkscXaDJ2gBtOvKMnqhvcnOmWqRsM',
    appId: '1:649987888032:web:bfb040f6ef19844bf6cac5',
    messagingSenderId: '649987888032',
    projectId: 'flightchap-8926a',
    authDomain: 'flightchap-8926a.firebaseapp.com',
    storageBucket: 'flightchap-8926a.firebasestorage.app',
    measurementId: 'G-TQ9GZ94KWZ',
  );
}
