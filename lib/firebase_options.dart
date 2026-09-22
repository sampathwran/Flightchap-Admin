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
    apiKey: 'AIzaSyAqKRcaw2sEC4qDlF8Sb3sVYJ45gevPJt',
    appId: '1:821020780283:web:d1bb6a1415186b969f725e',
    messagingSenderId: '821020780283',
    projectId: 'flightchap-6b6f2',
    authDomain: 'flightchap-6b6f2.firebaseapp.com',
    storageBucket: 'flightchap-6b6f2.firebasestorage.app',
    measurementId: 'G-RG109GPLEW',
  );
}
