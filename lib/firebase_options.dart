// Replace by running `flutterfire configure`.
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAyjYqTIKDI2IedSrQJCvM0OAH2eXDaQB4',
    appId: '1:827148490229:web:514df605e0910ee9573cbc',
    messagingSenderId: '827148490229',
    projectId: 'databaseqget',
    authDomain: 'databaseqget.firebaseapp.com',
    databaseURL: 'https://databaseqget-default-rtdb.firebaseio.com',
    storageBucket: 'databaseqget.appspot.com',
    measurementId: 'G-WKD3PRRQRN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdhDLgTDbGbglkniBtDMwb-u2xjJ9jEIE',
    appId: '1:827148490229:android:7ec7ca2692c5c706573cbc',
    messagingSenderId: '827148490229',
    projectId: 'databaseqget',
    databaseURL: 'https://databaseqget-default-rtdb.firebaseio.com',
    storageBucket: 'databaseqget.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkglooQpGzTpbdNWBxGrZHiaYYT2HQhSk',
    appId: '1:827148490229:ios:5c9553d743466a72573cbc',
    messagingSenderId: '827148490229',
    projectId: 'databaseqget',
    databaseURL: 'https://databaseqget-default-rtdb.firebaseio.com',
    storageBucket: 'databaseqget.appspot.com',
    iosBundleId: 'com.qget.qgetPortal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:ios:replace_me_macos_app_id',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
    storageBucket: 'replace-with-your-project-id.appspot.com',
    iosBundleId: 'com.qget.qgetPortal',
  );
}