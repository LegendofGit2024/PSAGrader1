// ⚠️  PLACEHOLDER — replace with your actual Firebase project config.
//
// Run:  flutterfire configure --project=slab-stack-prod
// This will overwrite this file with real values for all target platforms.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name}. '
          'Run: flutterfire configure',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8aJpSbaQ5VIArFMO2XQ4Nu8ruPQ1gJAw',
    appId: '1:382785095100:web:2ede18fd499aeb533897b9',
    messagingSenderId: '382785095100',
    projectId: 'slab-stack',
    authDomain: 'slab-stack.firebaseapp.com',
    storageBucket: 'slab-stack.firebasestorage.app',
  );

  // Replace all values below with output from `flutterfire configure`

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'slab-stack-prod',
    storageBucket: 'slab-stack-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'slab-stack-prod',
    storageBucket: 'slab-stack-prod.appspot.com',
    iosBundleId: 'com.yourorg.slabstack',
  );
}