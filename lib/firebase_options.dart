// File generated normally by the FlutterFire CLI, hand-written here as a
// placeholder template.
//
// IMPORTANT: Before running the app, replace the placeholder values below
// by running (see README.md "Setup" step 3):
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// This will overwrite this file with your real project's API keys and
// app IDs for Android/iOS/web, pulled from your Firebase project
// "birtakhabar" (see firebase.json for the project id already on file).

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform. '
          'Run `flutterfire configure` to generate them.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:770308863554:web:09938729aba320ffa0dfdb',
    messagingSenderId: '770308863554',
    projectId: 'birtakhabar',
    authDomain: 'birtakhabar.firebaseapp.com',
    storageBucket: 'birtakhabar.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:770308863554:android:edfc0571d95a71c0a0dfdb',
    messagingSenderId: '770308863554',
    projectId: 'birtakhabar',
    storageBucket: 'birtakhabar.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '770308863554',
    projectId: 'birtakhabar',
    storageBucket: 'birtakhabar.appspot.com',
    iosBundleId: 'com.example.birtakhabar',
  );
}
